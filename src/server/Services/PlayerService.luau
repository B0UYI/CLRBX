--!strict
-- État des joueurs : pièces (sauvegardées via DataService, affichées dans leaderstats)
-- et objet tenu en main.
-- Règle : un joueur tient au plus UN objet : un panier d'ingrédients OU une potion.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local Analytics = require(script.Parent.Parent.Util.Analytics)
local DataService = require(script.Parent.DataService)
local NotifyService = require(script.Parent.NotifyService)

local PlayerService = {}

-- Kind = "Basket" (Items = ingrédients) ou "Potion" (Id = recette).
export type HeldItem = { Tool: Tool, Kind: string, Id: string, Items: { string } }

local ITEM_KIND = "ItemKind"
local ITEM_ID = "ItemId"
local ITEM_LIST = "Items"

local ONBOARDING = {
	{ 1, "Bienvenue à Potion Panique ! 🧪" },
	{ 6, "Suis le rayon jaune : il te montre quoi faire 👉", true },
	{ 40, "🏆 Le GRAND CHAUDRON arrive bientôt : servez vite ensemble pour la fête !" },
	{ 60, "✨ 3 recettes secrètes se cachent… Expérimente au chaudron !" },
}

local function setupPlayer(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = Gameplay.Currency.Name
	-- Si les données sont déjà chargées, on affiche le bon solde tout de suite.
	coins.Value = PlayerService.GetCoins(player)
	coins.Parent = leaderstats
	leaderstats.Parent = player

	for _, step in ONBOARDING do
		task.delay(step[1], function()
			-- step[3] = message réservé aux joueurs qui suivent encore le guide.
			local guideOnly = step[3] == true
			if player.Parent and not (guideOnly and player:GetAttribute("GuideStep") == 0) then
				NotifyService.Send(player, step[2], "info")
			end
		end)
	end
end

local function itemTools(player: Player): { Tool }
	local found = {}
	for _, container in { player.Character, player:FindFirstChildOfClass("Backpack") } do
		if container then
			for _, child in container:GetChildren() do
				if child:IsA("Tool") and child:GetAttribute(ITEM_KIND) then
					table.insert(found, child)
				end
			end
		end
	end
	return found
end

function PlayerService.GetHeld(player: Player): HeldItem?
	local tool = itemTools(player)[1]
	if not tool then
		return nil
	end
	local list = tool:GetAttribute(ITEM_LIST)
	return {
		Tool = tool,
		Kind = tool:GetAttribute(ITEM_KIND) :: string,
		Id = (tool:GetAttribute(ITEM_ID) or "") :: string,
		Items = if type(list) == "string" and list ~= "" then string.split(list, ",") else {},
	}
end

function PlayerService.ClearHeld(player: Player)
	for _, tool in itemTools(player) do
		tool:Destroy()
	end
end

-- Donne un objet au joueur (remplace celui qu'il tenait) et le met en main.
function PlayerService.Give(player: Player, tool: Tool)
	PlayerService.ClearHeld(player)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		tool:Destroy()
		return
	end
	tool.Parent = backpack
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid:EquipTool(tool)
	end
end

-- Pièces gagnées avant le chargement des données (appliquées au chargement).
local pendingCoins: { [Player]: number } = {}

local function syncCoins(player: Player)
	local data = DataService.Get(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild(Gameplay.Currency.Name)
	if data and coins and coins:IsA("IntValue") then
		coins.Value = data.Coins
	end
end

function PlayerService.GetCoins(player: Player): number
	local data = DataService.Get(player)
	return if data then data.Coins else 0
end

-- reason : type de transaction pour les statistiques ("Gameplay", "IAP", "TimedReward"…), sku : détail.
function PlayerService.AddCoins(player: Player, amount: number, reason: string?, sku: string?)
	assert(amount >= 0 and amount == math.floor(amount), "Montant invalide")
	local data = DataService.Get(player)
	if data then
		data.Coins += amount
		syncCoins(player)
		Analytics.Coins(player, amount, data.Coins, reason or "Gameplay", sku)
	else
		pendingCoins[player] = (pendingCoins[player] or 0) + amount
	end
end

-- Retire `amount` pièces si le joueur en a assez. Renvoie true si payé.
function PlayerService.TrySpend(player: Player, amount: number, sku: string?): boolean
	assert(amount > 0 and amount == math.floor(amount), "Montant invalide")
	local data = DataService.Get(player)
	if not data or data.Coins < amount then
		return false
	end
	data.Coins -= amount
	syncCoins(player)
	Analytics.Coins(player, -amount, data.Coins, "Shop", sku)
	return true
end

function PlayerService.ItemAttributes(): (string, string, string)
	return ITEM_KIND, ITEM_ID, ITEM_LIST
end

function PlayerService:Start()
	DataService.OnLoaded(function(player: Player, data)
		local pending = pendingCoins[player]
		pendingCoins[player] = nil
		if pending then
			data.Coins += pending
		end
		syncCoins(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		pendingCoins[player] = nil
	end)
	Players.PlayerAdded:Connect(setupPlayer)
	-- En test Studio, le joueur peut arriver avant le démarrage des scripts.
	for _, player in Players:GetPlayers() do
		if not player:FindFirstChild("leaderstats") then
			setupPlayer(player)
		end
	end
end

return PlayerService
