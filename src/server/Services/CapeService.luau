--!strict
-- Capes : achetées avec les Victoires (achat vérifié par le serveur), elles multiplient les gains
-- de Vitesse. La meilleure cape possédée est portée sur le dos, avec une traînée en vol.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Capes = require(Shared.Config.Capes)
local Gameplay = require(Shared.Config.Gameplay)
local Format = require(Shared.Util.Format)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local LobbyService = require(script.Parent.LobbyService)
local NotifyService = require(script.Parent.NotifyService)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local CapeService = {}

local FIRST_X = -35
local SPACING_X = 9
local ROW_Z = 15
local PLAZA_TOP = 0.4
local CAPE_SIZE = Vector3.new(2.2, 3.2, 0.12)
local buyCooldown = Cooldown.new(0.5)
local rainbowParts: { [BasePart]: boolean } = {}

local function bestCape(player: Player): Capes.Cape?
	local data = DataService.Get(player)
	if not data then
		return nil
	end
	local best: Capes.Cape? = nil
	for _, cape in Capes.List do
		if data.Capes[cape.Id] and (not best or cape.Multiplier > best.Multiplier) then
			best = cape
		end
	end
	return best
end

local function makeCapePart(cape: Capes.Cape): Part
	local p = Instance.new("Part")
	p.Name = "CapeHeros"
	p.Size = CAPE_SIZE
	p.Color = cape.Color
	p.Material = cape.Material
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if cape.Sparkles then
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = cape.Color
		sparkles.Parent = p
	end
	if cape.Rainbow then
		rainbowParts[p] = true
	end
	return p
end

-- Met la meilleure cape sur le dos du personnage (ou l'enlève s'il n'en a aucune).
local function attach(player: Player, character: Model)
	local old = character:FindFirstChild("CapeHeros")
	if old then
		old:Destroy()
	end
	local cape = bestCape(player)
	if not cape then
		return
	end
	local torso = character:WaitForChild("UpperTorso", 10)
	if not torso or not torso:IsA("BasePart") then
		return
	end
	local capePart = makeCapePart(cape)
	capePart.CFrame = torso.CFrame * CFrame.new(0, -0.95, 0.62) * CFrame.Angles(math.rad(8), 0, 0)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = capePart
	weld.Parent = capePart

	-- Traînée colorée (visible quand on va vite).
	local top = Instance.new("Attachment")
	top.Position = Vector3.new(0, CAPE_SIZE.Y / 2, 0)
	top.Parent = capePart
	local bottom = Instance.new("Attachment")
	bottom.Position = Vector3.new(0, -CAPE_SIZE.Y / 2, 0)
	bottom.Parent = capePart
	local trail = Instance.new("Trail")
	trail.Attachment0 = top
	trail.Attachment1 = bottom
	trail.Color = ColorSequence.new(cape.Color)
	trail.Lifetime = 0.35
	trail.MinLength = 0.5
	trail.LightEmission = 0.5
	trail.Transparency = NumberSequence.new(0.4, 1)
	trail.Parent = capePart

	capePart.Parent = character
end

function CapeService.Refresh(player: Player)
	local data = DataService.Get(player)
	if data then
		for _, cape in Capes.List do
			player:SetAttribute(`OwnsCape_{cape.Id}`, data.Capes[cape.Id] == true)
		end
	end
	if player.Character then
		task.spawn(attach, player, player.Character)
	end
	StatsService.Sync(player)
end

local function onBuy(player: Player, cape: Capes.Cape, pedestal: BasePart)
	if not buyCooldown:try(player) then
		return
	end
	local data = DataService.Get(player)
	if not data then
		NotifyService.Send(player, "Chargement de tes données… réessaie dans une seconde", "warning")
		return
	end
	if data.Capes[cape.Id] then
		NotifyService.Send(player, "Tu as déjà cette cape ✅", "info")
		return
	end
	local missing = cape.Price - data.Wins
	if not StatsService.TrySpendWins(player, cape.Price, cape.Id) then
		NotifyService.Send(player, `Il te manque {Format.Number(missing)} 🏆 : gagne des courses !`, "warning")
		return
	end
	data.Capes[cape.Id] = true
	CapeService.Refresh(player)
	FxService.Confetti(pedestal.Position + Vector3.new(0, 5, 0), 150)
	FxService.Sound(pedestal, "Cash")
	NotifyService.Send(
		player,
		`🦸 {cape.Name} achetée ! Gains de vitesse ×{StatsService.CapeMultiplier(player)}`,
		"success"
	)
	OnboardingService.Advance(player, "Cape")
end

local function buildShop(folder: Instance)
	for index, cape in Capes.List do
		local x = FIRST_X - (index - 1) * SPACING_X
		local pedestal = Instance.new("Part")
		pedestal.Name = `Cape_{cape.Id}`
		pedestal.Anchored = true
		pedestal.Size = Vector3.new(5, 2, 5)
		pedestal.Position = Vector3.new(x, PLAZA_TOP + 1, ROW_Z)
		pedestal.Color = Color3.fromRGB(90, 95, 120)
		pedestal.Material = Enum.Material.Marble
		pedestal.Parent = folder

		local torso = Instance.new("Part")
		torso.Name = "Mannequin"
		torso.Anchored = true
		torso.Size = Vector3.new(2, 2.6, 1)
		torso.Position = Vector3.new(x, PLAZA_TOP + 3.3, ROW_Z)
		torso.Color = Color3.fromRGB(235, 235, 240)
		torso.Parent = pedestal
		local head = Instance.new("Part")
		head.Name = "Tete"
		head.Anchored = true
		head.Shape = Enum.PartType.Ball
		head.Size = Vector3.new(1.4, 1.4, 1.4)
		head.Position = torso.Position + Vector3.new(0, 2, 0)
		head.Color = Color3.fromRGB(235, 235, 240)
		head.Parent = pedestal
		-- Cape montée côté joueurs (le mannequin est vu de dos).
		local display = makeCapePart(cape)
		display.Name = "CapeExposee"
		display.Anchored = true
		display.CFrame = CFrame.new(torso.Position + Vector3.new(0, -0.3, -0.6)) * CFrame.Angles(math.rad(-6), 0, 0)
		display.Parent = pedestal

		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(180, 70)
		gui.StudsOffset = Vector3.new(0, 2, 0)
		gui.MaxDistance = 80
		gui.Adornee = head
		gui.Parent = head
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
		label.BackgroundTransparency = 0.2
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		label.Text = `{cape.Name}\nVitesse ×{cape.Multiplier}\n{Format.Number(cape.Price)} 🏆`
		label.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = label

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Acheter"
		prompt.ObjectText = `{cape.Name} ({Format.Number(cape.Price)} 🏆)`
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.HoldDuration = 0.4 -- évite les achats par erreur
		prompt.MaxActivationDistance = Gameplay.Interaction.MaxDistance
		prompt.RequiresLineOfSight = false
		prompt:SetAttribute("CapeId", cape.Id)
		prompt.Parent = pedestal
		prompt.Triggered:Connect(function(player: Player)
			onBuy(player, cape, pedestal)
		end)
	end
end

function CapeService:Start()
	local lobby = LobbyService.Folder
	assert(lobby, "Le lobby n'a pas été construit")
	local folder = Instance.new("Folder")
	folder.Name = "Capes"
	folder.Parent = lobby
	buildShop(folder)

	DataService.OnLoaded(function(player: Player)
		CapeService.Refresh(player)
	end)
	local function watch(player: Player)
		player.CharacterAdded:Connect(function(character)
			attach(player, character)
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		buyCooldown:forget(player)
	end)

	-- Capes arc-en-ciel : la couleur défile.
	task.spawn(function()
		while true do
			task.wait(0.15)
			local hue = (os.clock() / 3) % 1
			for capePart in rainbowParts do
				if capePart.Parent then
					capePart.Color = Color3.fromHSV(hue, 0.8, 1)
				else
					rainbowParts[capePart] = nil
				end
			end
		end
	end)
end

return CapeService
