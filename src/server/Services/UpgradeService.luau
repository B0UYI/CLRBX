--!strict
-- Armoire du sorcier : améliorations achetées avec les pièces, sauvegardées dans DataService.
-- Achat 100 % côté serveur (invite ProximityPrompt) : prix vérifié, déjà possédé, anti-spam.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Upgrades = require(Shared.Config.Upgrades)
local Gameplay = require(Shared.Config.Gameplay)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local NotifyService = require(script.Parent.NotifyService)
local PlayerService = require(script.Parent.PlayerService)
local WorldService = require(script.Parent.WorldService)

local UpgradeService = {}

local FLOOR_TOP = 1
local ARMOIRE_X = -26
local FIRST_Z = -27
local SPACING_Z = 4.5
local buyCooldown = Cooldown.new(0.5)

-- Meilleure amélioration possédée d'un type donné (la plus chère).
local function bestOwned(player: Player, kind: string): Upgrades.Upgrade?
	local data = DataService.Get(player)
	if not data then
		return nil
	end
	local best: Upgrades.Upgrade? = nil
	for _, upgrade in Upgrades.List do
		if upgrade.Kind == kind and data.Upgrades[upgrade.Id] then
			if not best or upgrade.Price > best.Price then
				best = upgrade
			end
		end
	end
	return best
end

function UpgradeService.BasketSize(player: Player): number
	local upgrade = bestOwned(player, "Basket")
	return if upgrade then upgrade.Value else Gameplay.Player.BasketSize
end

function UpgradeService.WalkSpeed(player: Player): number
	local upgrade = bestOwned(player, "WalkSpeed")
	return if upgrade then upgrade.Value else Gameplay.Player.WalkSpeed
end

function UpgradeService.TipBonus(player: Player): number
	local upgrade = bestOwned(player, "TipBonus")
	return if upgrade then upgrade.Value else 0
end

function UpgradeService.Title(player: Player): string
	local upgrade = bestOwned(player, "Title")
	return if upgrade then upgrade.Value else Upgrades.DefaultTitle
end

-- Vitesse + titre au-dessus de la tête.
local function applyCharacter(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		local speed = UpgradeService.WalkSpeed(player)
		-- Vitesse de base mémorisée : les effets de potion y reviennent à la fin.
		humanoid:SetAttribute("BaseWalkSpeed", speed)
		humanoid.WalkSpeed = speed
	end
	local head = character:WaitForChild("Head", 10)
	if head and head:IsA("BasePart") then
		local existing = head:FindFirstChild("TitreJoueur")
		if existing then
			existing:Destroy()
		end
		local gui = Instance.new("BillboardGui")
		gui.Name = "TitreJoueur"
		gui.Size = UDim2.fromOffset(200, 28)
		gui.StudsOffset = Vector3.new(0, 3.4, 0)
		gui.MaxDistance = 50
		gui.Adornee = head
		gui.Parent = head
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 230, 140)
		label.TextStrokeTransparency = 0.4
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		label.Text = UpgradeService.Title(player)
		label.Parent = gui
	end
end

local function refreshPlayer(player: Player)
	local data = DataService.Get(player)
	if data then
		for _, upgrade in Upgrades.List do
			player:SetAttribute(`Owns_{upgrade.Id}`, data.Upgrades[upgrade.Id] == true)
		end
	end
	if player.Character then
		task.spawn(applyCharacter, player, player.Character)
	end
end

local function onBuy(player: Player, upgrade: Upgrades.Upgrade, pedestal: BasePart)
	if not buyCooldown:try(player) then
		return
	end
	local data = DataService.Get(player)
	if not data then
		NotifyService.Send(player, "Chargement de tes données… réessaie dans une seconde", "warning")
		return
	end
	if data.Upgrades[upgrade.Id] then
		NotifyService.Send(player, "Tu as déjà cette amélioration ✅", "info")
		return
	end
	local missing = upgrade.Price - data.Coins
	if not PlayerService.TrySpend(player, upgrade.Price) then
		NotifyService.Send(player, `Il te manque {missing} pièces 💰 Sers des clients !`, "warning")
		return
	end
	data.Upgrades[upgrade.Id] = true
	refreshPlayer(player)
	FxService.Confetti(pedestal.Position + Vector3.new(0, 4, 0), 120)
	FxService.Sound(pedestal, "Cash")
	NotifyService.Send(player, `✨ {upgrade.Name} acheté ! {upgrade.Description}`, "success")
end

local function buildArmoire()
	local shop = WorldService.Folder
	assert(shop, "La boutique n'a pas été construite")
	local folder = Instance.new("Folder")
	folder.Name = "Armoire"
	folder.Parent = shop

	local lastZ = FIRST_Z + SPACING_Z * (#Upgrades.List - 1)
	local back = Instance.new("Part")
	back.Name = "ArmoireFond"
	back.Anchored = true
	back.Size = Vector3.new(1, 10, lastZ - FIRST_Z + 5)
	back.Position = Vector3.new(ARMOIRE_X - 3, FLOOR_TOP + 5, (FIRST_Z + lastZ) / 2)
	back.Color = Color3.fromRGB(70, 40, 100)
	back.Material = Enum.Material.WoodPlanks
	back.Parent = folder
	local signGui = Instance.new("BillboardGui")
	signGui.Size = UDim2.fromOffset(300, 50)
	signGui.StudsOffset = Vector3.new(2, 6.5, 0)
	signGui.MaxDistance = 80
	signGui.Adornee = back
	signGui.Parent = back
	local sign = Instance.new("TextLabel")
	sign.Size = UDim2.fromScale(1, 1)
	sign.BackgroundColor3 = Color3.fromRGB(70, 40, 100)
	sign.TextColor3 = Color3.fromRGB(255, 230, 140)
	sign.TextScaled = true
	sign.Font = Enum.Font.FredokaOne
	sign.Text = "🧙 ARMOIRE DU SORCIER"
	sign.Parent = signGui
	local signCorner = Instance.new("UICorner")
	signCorner.CornerRadius = UDim.new(0, 10)
	signCorner.Parent = sign

	for index, upgrade in Upgrades.List do
		local z = FIRST_Z + SPACING_Z * (index - 1)
		local pedestal = Instance.new("Part")
		pedestal.Name = `Presentoir_{upgrade.Id}`
		pedestal.Anchored = true
		pedestal.Size = Vector3.new(3, 3, 3)
		pedestal.Position = Vector3.new(ARMOIRE_X, FLOOR_TOP + 1.5, z)
		pedestal.Color = Color3.fromRGB(90, 60, 120)
		pedestal.Material = Enum.Material.Marble
		pedestal.Parent = folder

		local display = Instance.new("Part")
		display.Name = "Objet"
		display.Anchored = true
		display.CanCollide = false
		display.Shape = Enum.PartType.Ball
		display.Size = Vector3.new(1.6, 1.6, 1.6)
		display.Position = pedestal.Position + Vector3.new(0, 2.4, 0)
		display.Color = upgrade.Color
		display.Material = Enum.Material.Neon
		display.Parent = pedestal

		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(190, 64)
		gui.StudsOffset = Vector3.new(0, 2.2, 0)
		gui.MaxDistance = 40
		gui.Adornee = display
		gui.Parent = display
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
		label.BackgroundTransparency = 0.2
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		label.Text = `{upgrade.Name}\n{upgrade.Description}\n{upgrade.Price} 💰`
		label.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = label

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Acheter"
		prompt.ObjectText = `{upgrade.Name} ({upgrade.Price} 💰)`
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.HoldDuration = 0.4 -- évite les achats par erreur
		prompt.MaxActivationDistance = Gameplay.Interaction.MaxDistance
		prompt.RequiresLineOfSight = false
		prompt:SetAttribute("UpgradeId", upgrade.Id)
		prompt.Parent = pedestal
		prompt.Triggered:Connect(function(player: Player)
			onBuy(player, upgrade, pedestal)
		end)
	end
end

function UpgradeService:Start()
	buildArmoire()
	DataService.OnLoaded(function(player: Player)
		refreshPlayer(player)
	end)
	local function watch(player: Player)
		player.CharacterAdded:Connect(function(character)
			applyCharacter(player, character)
		end)
		if player.Character then
			task.spawn(applyCharacter, player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		buyCooldown:forget(player)
	end)
end

return UpgradeService
