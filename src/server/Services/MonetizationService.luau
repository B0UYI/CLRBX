--!strict
-- Game passes et produits de développeur.
-- ProcessReceipt est idempotent : l'Id d'achat est enregistré dans le profil du joueur avec l'objet
-- accordé, et on ne répond « accordé » à Roblox qu'une fois cette sauvegarde confirmée.
-- (Recette recommandée par ProfileStore : pas de double attribution, pas d'achat perdu.)

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local Monetization = require(Shared.Config.Monetization)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local NotifyService = require(script.Parent.NotifyService)
local StatsService = require(script.Parent.StatsService)

local MonetizationService = {}

local PROFILE_WAIT_SECONDS = 30
local SAVE_RETRY_SECONDS = 15

local function celebrate(player: Player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		FxService.Confetti(root.Position + Vector3.new(0, 4, 0), 150)
		FxService.Sound(root, "Cash")
	end
end

local function checkPasses(player: Player)
	for _, pass in Monetization.GamePasses do
		if pass.Id > 0 then
			local ok, owns = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, pass.Id)
			end)
			if ok and owns then
				player:SetAttribute(`Pass_{pass.Key}`, true)
			elseif not ok then
				warn(`[MonetizationService] Vérification du pass {pass.Key} impossible : {owns}`)
			end
		end
	end
	StatsService.Sync(player)
end

-- Accorde l'effet d'un produit. Ne doit PAS céder la main (pas de task.wait) :
-- l'Id d'achat et l'effet doivent être sauvegardés ensemble.
local function grantProduct(buyer: Player, data: DataService.PlayerData, product: Monetization.Product): boolean
	if product.Key == "Turbo" then
		data.BoostUntil = math.max(os.time(), data.BoostUntil) + Gameplay.Turbo.DurationSeconds
		StatsService.Sync(buyer)
		NotifyService.Send(buyer, `🚀 Turbo ×{Gameplay.Turbo.Multiplier} activé pour 10 minutes !`, "success")
		celebrate(buyer)
		return true
	elseif product.Wins then
		StatsService.AddWins(buyer, product.Wins, "IAP", product.Key, true)
		NotifyService.Send(buyer, `🏆 Merci ! +{product.Wins} victoires`, "success")
		celebrate(buyer)
		return true
	end
	warn(`[MonetizationService] Aucun effet défini pour le produit {product.Key}`)
	return false
end

local function processReceipt(receipt: any): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local product = Monetization.ProductById[receipt.ProductId]
	if not product then
		warn(`[MonetizationService] Produit inconnu : {receipt.ProductId} (Id à ajouter dans Config/Monetization)`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = DataService.GetProfile(player)
	local waited = 0
	while profile == nil and player.Parent == Players and waited < PROFILE_WAIT_SECONDS do
		waited += task.wait(0.5)
		profile = DataService.GetProfile(player)
	end
	if profile == nil or not profile:IsActive() then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local purchaseId = tostring(receipt.PurchaseId)
	local ids = profile.Data.PurchaseIds
	if not table.find(ids, purchaseId) then
		if not grantProduct(player, profile.Data, product) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		table.insert(ids, purchaseId)
		while #ids > Monetization.PurchaseIdCacheSize do
			table.remove(ids, 1)
		end
	end

	-- Attendre que la sauvegarde contienne cet achat.
	local result: Enum.ProductPurchaseDecision? = nil
	local function check()
		if result ~= nil then
			return
		end
		local saved = profile.LastSavedData
		if saved and saved.PurchaseIds and table.find(saved.PurchaseIds, purchaseId) then
			result = Enum.ProductPurchaseDecision.PurchaseGranted
		elseif not profile:IsActive() then
			result = Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
	local connection = profile.OnAfterSave:Connect(check)
	check()
	if result == nil then
		profile:Save()
	end
	local sinceSave = 0
	while result == nil do
		sinceSave += task.wait(0.5)
		check()
		if result == nil and sinceSave >= SAVE_RETRY_SECONDS then
			sinceSave = 0
			profile:Save()
		end
	end
	connection:Disconnect()
	return result :: Enum.ProductPurchaseDecision
end

function MonetizationService:Start()
	MarketplaceService.ProcessReceipt = processReceipt
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Player, passId: number, purchased: boolean)
			local pass = Monetization.PassById[passId]
			if not purchased or not pass then
				return
			end
			player:SetAttribute(`Pass_{pass.Key}`, true)
			StatsService.Sync(player)
			NotifyService.Send(player, `🎉 Merci ! {pass.Name} est activé.`, "success")
			celebrate(player)
		end
	)
	Players.PlayerAdded:Connect(function(player)
		checkPasses(player)
	end)
	for _, player in Players:GetPlayers() do
		task.spawn(checkPasses, player)
	end
end

return MonetizationService
