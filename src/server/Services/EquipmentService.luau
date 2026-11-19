--!strict
-- Équipement acheté avec les Victoires (achat vérifié par le serveur) : traînées, capes, auras.
-- La meilleure pièce de chaque emplacement est portée automatiquement et multiplie les gains de Vitesse.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Equipment = require(Shared.Config.Equipment)
local Gameplay = require(Shared.Config.Gameplay)
local CapeModel = require(Shared.Util.CapeModel)
local Format = require(Shared.Util.Format)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local LobbyService = require(script.Parent.LobbyService)
local NotifyService = require(script.Parent.NotifyService)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local EquipmentService = {}

local FIRST_X = -30
local SPACING_X = 8
local ROW_Z: { [string]: number } = { Trail = 4, Cape = 18, Aura = 32 }
local PLAZA_TOP = 0.4
-- Attribut posé sur tout ce que l'équipement ajoute au personnage (pour le retirer proprement).
local WORN = "EquipementPorte"

local buyCooldown = Cooldown.new(0.5)
local rainbowParts: { [BasePart]: boolean } = {}

local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 220, 60)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 230, 120)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(80, 160, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 100, 255)),
})

local function colors(item: Equipment.Item): ColorSequence
	return if item.Rainbow then RAINBOW else ColorSequence.new(item.Color)
end

local function worn<T>(instance: T & Instance): T
	instance:SetAttribute(WORN, true)
	return instance
end

local function attachTrail(root: BasePart, item: Equipment.Item)
	local top = worn(Instance.new("Attachment"))
	top.Name = "TraineeHaut"
	top.Position = Vector3.new(0, 1, 0.4)
	top.Parent = root
	local bottom = worn(Instance.new("Attachment"))
	bottom.Name = "TraineeBas"
	bottom.Position = Vector3.new(0, -1.6, 0.4)
	bottom.Parent = root
	local trail = worn(Instance.new("Trail"))
	trail.Name = "Trainee"
	trail.Attachment0 = top
	trail.Attachment1 = bottom
	trail.Color = colors(item)
	trail.Lifetime = 0.6
	trail.MinLength = 0.2
	trail.LightEmission = 0.6
	trail.Transparency = NumberSequence.new(0.15, 1)
	trail.Parent = root
end

local function attachAura(root: BasePart, item: Equipment.Item)
	local emitter = worn(Instance.new("ParticleEmitter"))
	emitter.Name = "Aura"
	emitter.Color = colors(item)
	emitter.LightEmission = 1
	emitter.Rate = 25
	emitter.Lifetime = NumberRange.new(0.8, 1.4)
	emitter.Speed = NumberRange.new(1, 3)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new(0.5, 0)
	emitter.Parent = root
	local light = worn(Instance.new("PointLight"))
	light.Name = "AuraLumiere"
	light.Color = item.Color
	light.Range = 10
	light.Brightness = 1.2
	light.Parent = root
end

-- Habille le personnage avec la meilleure pièce de chaque emplacement.
local function dress(player: Player, character: Model)
	for _, descendant in character:GetDescendants() do
		if descendant:GetAttribute(WORN) == true then
			descendant:Destroy()
		end
	end
	local root = character:WaitForChild("HumanoidRootPart", 10)
	character:WaitForChild("UpperTorso", 10)
	if not root or not root:IsA("BasePart") then
		return
	end
	-- La cape est construite et animée côté joueurs (CapeController) d'après cet attribut.
	local cape = StatsService.BestInSlot(player, "Cape")
	player:SetAttribute("Cape", if cape then cape.Id else nil)
	for _, slot in Equipment.Slots do
		local item = StatsService.BestInSlot(player, slot.Slot)
		if item and slot.Slot ~= "Cape" then
			if slot.Slot == "Trail" then
				attachTrail(root, item)
			else
				attachAura(root, item)
			end
		end
	end
end

function EquipmentService.Refresh(player: Player)
	local data = DataService.Get(player)
	if data then
		for _, item in Equipment.List do
			player:SetAttribute(`OwnsEquip_{item.Id}`, data.Equipment[item.Id] == true)
		end
	end
	if player.Character then
		task.spawn(dress, player, player.Character)
	end
	StatsService.Sync(player)
end

local function onBuy(player: Player, item: Equipment.Item, pedestal: BasePart)
	if not buyCooldown:try(player) then
		return
	end
	local data = DataService.Get(player)
	if not data then
		NotifyService.Send(player, "Chargement de tes données… réessaie dans une seconde", "warning")
		return
	end
	if data.Equipment[item.Id] then
		NotifyService.Send(player, "Tu l'as déjà ✅", "info")
		return
	end
	local best = StatsService.BestInSlot(player, item.Slot)
	if best and best.Multiplier >= item.Multiplier then
		NotifyService.Send(player, `Tu portes déjà mieux : {best.Name} (×{best.Multiplier})`, "info")
		return
	end
	local missing = Format.Number(item.Price - data.Wins)
	if not StatsService.TrySpendWins(player, item.Price, item.Id) then
		NotifyService.Send(player, `Il te manque {missing} 🏆 : termine des parcours !`, "warning")
		return
	end
	data.Equipment[item.Id] = true
	EquipmentService.Refresh(player)
	FxService.Confetti(pedestal.Position + Vector3.new(0, 5, 0), 150)
	FxService.Sound(pedestal, "Cash")
	local total = StatsService.EquipmentMultiplier(player)
	NotifyService.Send(player, `✨ {item.Name} ! Gains de vitesse ×{total}`, "success")
	OnboardingService.Advance(player, "Bought")
end

local function label(adornee: BasePart, text: string, offsetY: number)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(5.5, 0, 2, 0)
	gui.StudsOffset = Vector3.new(0, offsetY, 0)
	gui.MaxDistance = 40
	gui.Adornee = adornee
	gui.Parent = adornee
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	textLabel.BackgroundTransparency = 0.5
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Text = text
	textLabel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = textLabel
end

local function display(pedestal: BasePart, item: Equipment.Item): BasePart
	local top = pedestal.Position + Vector3.new(0, pedestal.Size.Y / 2, 0)
	if item.Slot == "Cape" then
		local torso = Instance.new("Part")
		torso.Name = "Mannequin"
		torso.Anchored = true
		torso.Size = Vector3.new(2, 2.6, 1)
		torso.Position = top + Vector3.new(0, 1.3, 0)
		torso.Color = Color3.fromRGB(235, 235, 240)
		torso.Parent = pedestal
		local cape = CapeModel.Build(item)
		cape.Model.Name = "CapeExposee"
		cape.Model.Parent = pedestal
		-- Montée côté joueurs (le mannequin est vu de dos), légèrement soulevée par le vent.
		local anchor = CFrame.new(torso.Position + Vector3.new(0, 1.2, -0.55)) * CFrame.Angles(0, math.pi, 0)
		CapeModel.Pose(cape, anchor, { 0.1, 0.08, 0.1, 0.12, 0.14 })
		return torso
	end
	local shown = Instance.new("Part")
	shown.Name = "Objet"
	shown.Anchored = true
	shown.CanCollide = false
	shown.Material = Enum.Material.Neon
	shown.Color = item.Color
	if item.Slot == "Trail" then
		shown.Size = Vector3.new(0.6, 4, 0.6)
		shown.Position = top + Vector3.new(0, 2, 0)
		if item.Rainbow then
			rainbowParts[shown] = true
		end
	else
		shown.Shape = Enum.PartType.Ball
		shown.Size = Vector3.new(1.6, 1.6, 1.6)
		shown.Position = top + Vector3.new(0, 1.6, 0)
		shown.Color = Color3.new(1, 1, 1)
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = colors(item)
		emitter.LightEmission = 1
		emitter.Rate = 15
		emitter.Lifetime = NumberRange.new(0.8, 1.2)
		emitter.Speed = NumberRange.new(1, 2)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Size = NumberSequence.new(0.4, 0)
		emitter.Parent = shown
	end
	shown.Parent = pedestal
	return shown
end

local function buildShop(folder: Instance)
	for _, slot in Equipment.Slots do
		local z = ROW_Z[slot.Slot]
		local post = Instance.new("Part")
		post.Name = `Rangee_{slot.Slot}`
		post.Anchored = true
		post.Size = Vector3.new(1, 6, 1)
		post.Position = Vector3.new(FIRST_X + 6, PLAZA_TOP + 3, z)
		post.Color = Color3.fromRGB(70, 60, 100)
		post.Parent = folder
		label(post, slot.Name, 4.5)
		local index = 0
		for _, item in Equipment.List do
			if item.Slot == slot.Slot then
				index += 1
				local pedestal = Instance.new("Part")
				pedestal.Name = `Equip_{item.Id}`
				pedestal.Anchored = true
				pedestal.Size = Vector3.new(5, 2, 5)
				pedestal.Position = Vector3.new(FIRST_X - (index - 1) * SPACING_X, PLAZA_TOP + 1, z)
				pedestal.Color = Color3.fromRGB(90, 95, 120)
				pedestal.Material = Enum.Material.Marble
				pedestal.Parent = folder
				local shown = display(pedestal, item)
				label(shown, `{item.Name}\nVitesse ×{item.Multiplier}\n{Format.Number(item.Price)} 🏆`, 3.5)
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText = "Acheter"
				prompt.ObjectText = `{item.Name} ({Format.Number(item.Price)} 🏆)`
				prompt.KeyboardKeyCode = Enum.KeyCode.E
				prompt.HoldDuration = 0.4 -- évite les achats par erreur
				prompt.MaxActivationDistance = Gameplay.Interaction.MaxDistance
				prompt.RequiresLineOfSight = false
				prompt:SetAttribute("EquipId", item.Id)
				prompt.Parent = pedestal
				prompt.Triggered:Connect(function(player: Player)
					onBuy(player, item, pedestal)
				end)
			end
		end
	end
end

function EquipmentService:Start()
	local lobby = LobbyService.Folder
	assert(lobby, "Le lobby n'a pas été construit")
	local folder = Instance.new("Folder")
	folder.Name = "Equipement"
	folder.Parent = lobby
	buildShop(folder)

	DataService.OnLoaded(function(player: Player)
		EquipmentService.Refresh(player)
	end)
	local function watch(player: Player)
		player.CharacterAdded:Connect(function(character)
			dress(player, character)
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		buyCooldown:forget(player)
	end)

	-- Objets arc-en-ciel exposés : la couleur défile.
	task.spawn(function()
		while true do
			task.wait(0.15)
			local hue = (os.clock() / 3) % 1
			for shown in rainbowParts do
				if shown.Parent then
					shown.Color = Color3.fromHSV(hue, 0.8, 1)
				else
					rainbowParts[shown] = nil
				end
			end
		end
	end)
end

return EquipmentService
