--!strict
-- Terrain de vol libre au nord du lobby : vallée fermée par des montagnes, aiguilles rocheuses,
-- îles flottantes (arbres, cascades), arches, arbre géant, lac et un sommet à atteindre.
-- Purement décoratif et déterministe ; FlightService y supprime la consommation d'endurance.

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local Biomes = require(script.Parent.Biomes)

local Playground = {}

local CONFIG = Gameplay.Lobby.Playground
local CENTER = CONFIG.Center
local HALF_X = CONFIG.Size.X / 2
local HALF_Z = CONFIG.Size.Z / 2
local PLAZA_EDGE_Z = -55

local GRASS = Color3.fromRGB(95, 185, 85)
local ROCK = Color3.fromRGB(125, 115, 105)
local SNOW = Color3.fromRGB(245, 248, 255)
local STONE = Color3.fromRGB(200, 195, 185)
local WATER = Color3.fromRGB(70, 160, 230)

type Props = { [string]: any }

local function part(parent: Instance, props: Props): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	p.Parent = parent
	return p
end

local function upright(position: Vector3): CFrame
	return CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
end

-- Pile de cylindres qui rétrécissent : montagne ou aiguille. Renvoie le sommet.
local function spire(parent: Instance, base: Vector3, radius: number, height: number, snowy: boolean): Vector3
	local layers = 4
	local y = base.Y
	local r = radius
	for layer = 1, layers do
		local h = height / layers
		part(parent, {
			Name = "Roche",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(h, r * 2, r * 2),
			CFrame = upright(Vector3.new(base.X, y + h / 2, base.Z)),
			Color = ROCK:Lerp(Color3.new(0, 0, 0), layer * 0.05),
			Material = Enum.Material.Slate,
		})
		y += h
		r *= 0.72
	end
	if snowy then
		part(parent, {
			Name = "Neige",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(4, r * 2.2, r * 2.2),
			CFrame = upright(Vector3.new(base.X, y, base.Z)),
			Color = SNOW,
			Material = Enum.Material.Snow,
		})
	end
	return Vector3.new(base.X, y, base.Z)
end

local function island(parent: Instance, center: Vector3, size: number, random: Random, waterfall: boolean)
	part(parent, {
		Name = "IleFlottante",
		Size = Vector3.new(size, 4, size * 0.85),
		Position = center,
		Color = GRASS,
		Material = Enum.Material.Grass,
	})
	Biomes.Underside(parent, center + Vector3.new(0, -2, 0), size * 1.1, ROCK, Enum.Material.Slate)
	for _ = 1, random:NextInteger(1, 3) do
		Biomes.Tree(
			parent,
			center + Vector3.new(random:NextNumber(-size / 3, size / 3), 2, random:NextNumber(-size / 4, size / 4)),
			random
		)
	end
	if waterfall then
		local fall = part(parent, {
			Name = "Cascade",
			Size = Vector3.new(6, center.Y, 2),
			Position = Vector3.new(center.X + size / 2, center.Y / 2, center.Z),
			Color = WATER,
			Material = Enum.Material.Neon,
			Transparency = 0.45,
			CanCollide = false,
			CanQuery = false,
		})
		local mist = Instance.new("ParticleEmitter")
		mist.Name = "Ecume"
		mist.Rate = 25
		mist.Lifetime = NumberRange.new(1, 2)
		mist.Speed = NumberRange.new(2, 5)
		mist.SpreadAngle = Vector2.new(30, 30)
		mist.Size = NumberSequence.new(3, 6)
		mist.Transparency = NumberSequence.new(0.4, 1)
		mist.Color = ColorSequence.new(Color3.new(1, 1, 1))
		mist.Parent = fall
	end
end

local function arch(parent: Instance, base: Vector3, width: number, height: number, yaw: number)
	local frame = CFrame.new(base) * CFrame.Angles(0, yaw, 0)
	local thickness = math.max(4, width / 8)
	for _, side in { -1, 1 } do
		part(parent, {
			Name = "PilierArche",
			Size = Vector3.new(thickness, height, thickness),
			CFrame = frame * CFrame.new(side * width / 2, height / 2, 0),
			Color = STONE,
			Material = Enum.Material.Cobblestone,
		})
	end
	part(parent, {
		Name = "Linteau",
		Size = Vector3.new(width + thickness, thickness, thickness),
		CFrame = frame * CFrame.new(0, height + thickness / 2, 0),
		Color = STONE,
		Material = Enum.Material.Cobblestone,
	})
	part(parent, {
		Name = "LierreArche",
		Size = Vector3.new(width + thickness + 0.4, 1.2, thickness + 0.4),
		CFrame = frame * CFrame.new(0, height + thickness, 0),
		Color = GRASS,
		Material = Enum.Material.Grass,
		CanCollide = false,
	})
end

local function giantTree(parent: Instance, base: Vector3)
	part(parent, {
		Name = "TroncGeant",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(130, 16, 16),
		CFrame = upright(base + Vector3.new(0, 65, 0)),
		Color = Color3.fromRGB(105, 70, 45),
		Material = Enum.Material.Wood,
	})
	for i, offset in
		{
			Vector3.new(0, 140, 0),
			Vector3.new(30, 120, 10),
			Vector3.new(-28, 125, -12),
			Vector3.new(8, 118, 32),
			Vector3.new(-6, 122, -34),
		}
	do
		local size = 62 - i * 5
		part(parent, {
			Name = "FeuillageGeant",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(size, size * 0.8, size),
			Position = base + offset,
			Color = Color3.fromRGB(60, 150 + i * 10, 70),
			Material = Enum.Material.Grass,
		})
	end
	local leaves = Instance.new("ParticleEmitter")
	leaves.Name = "Feuilles"
	leaves.Rate = 6
	leaves.Lifetime = NumberRange.new(6, 9)
	leaves.Speed = NumberRange.new(1, 3)
	leaves.Acceleration = Vector3.new(0, -2, 0)
	leaves.RotSpeed = NumberRange.new(-90, 90)
	leaves.SpreadAngle = Vector2.new(180, 180)
	leaves.Size = NumberSequence.new(0.8)
	leaves.Color = ColorSequence.new(Color3.fromRGB(120, 200, 80))
	leaves.Parent = parent:FindFirstChild("FeuillageGeant") :: Instance
end

local function sign(parent: Instance, position: Vector3, text: string)
	local anchor = part(parent, {
		Name = "PanneauVolLibre",
		Size = Vector3.new(1, 1, 1),
		Position = position,
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
	})
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(26, 0, 6, 0)
	gui.MaxDistance = 260
	gui.Adornee = anchor
	gui.Parent = anchor
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(25, 40, 60)
	label.BackgroundTransparency = 0.35
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Text = text
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = label
end

function Playground.Build(parent: Instance)
	local folder = Instance.new("Folder")
	folder.Name = "TerrainDeVol"
	folder.Parent = parent
	local random = Random.new(4242)

	local function spot(margin: number): Vector3
		return CENTER
			+ Vector3.new(
				random:NextNumber(-HALF_X + margin, HALF_X - margin),
				0,
				random:NextNumber(-HALF_Z + margin, HALF_Z - margin)
			)
	end

	-- Prairie de la vallée et chemin depuis la place.
	part(folder, {
		Name = "Vallee",
		Size = Vector3.new(HALF_X * 2, 4, HALF_Z * 2),
		Position = CENTER + Vector3.new(0, -2, 0),
		Color = GRASS,
		Material = Enum.Material.Grass,
	})
	local pathStart = CENTER.Z + HALF_Z
	part(folder, {
		Name = "Chemin",
		Size = Vector3.new(30, 0.4, PLAZA_EDGE_Z - pathStart + 40),
		Position = Vector3.new(0, 0.2, (PLAZA_EDGE_Z + pathStart - 40) / 2),
		Color = STONE,
		Material = Enum.Material.Cobblestone,
	})
	part(folder, {
		Name = "Lac",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.6, 140, 140),
		CFrame = upright(CENTER + Vector3.new(180, 0.3, -120)),
		Color = WATER,
		Material = Enum.Material.Glass,
		Transparency = 0.25,
		CanCollide = false,
	})
	sign(folder, Vector3.new(0, 14, pathStart - 10), "🕊️ Terrain de vol libre\nEndurance illimitée : amuse-toi !")

	-- Montagnes enneigées tout autour (sauf l'entrée côté place).
	for i = 0, 27 do
		local angle = i / 28 * math.pi * 2
		local direction = Vector3.new(math.sin(angle), 0, math.cos(angle))
		if direction.Z < 0.85 then
			local base = CENTER + Vector3.new(direction.X * HALF_X * 1.02, 0, direction.Z * HALF_Z * 1.02)
			spire(folder, base, random:NextNumber(45, 75), random:NextNumber(160, 300), true)
		end
	end

	-- Aiguilles rocheuses à contourner, avec un arbre au sommet.
	for _ = 1, 9 do
		local top = spire(folder, spot(80), random:NextNumber(10, 18), random:NextNumber(70, 200), false)
		part(folder, {
			Name = "SommetHerbe",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2, 14, 14),
			CFrame = upright(top + Vector3.new(0, 1, 0)),
			Color = GRASS,
			Material = Enum.Material.Grass,
		})
		Biomes.Tree(folder, top + Vector3.new(0, 2, 0), random)
	end

	-- Îles flottantes à différentes hauteurs (dont deux avec cascade).
	for i = 1, 14 do
		local center = spot(90) + Vector3.new(0, random:NextNumber(50, 300), 0)
		island(folder, center, random:NextNumber(26, 60), random, i <= 2)
	end

	-- Arches à traverser (au sol et en altitude).
	arch(folder, CENTER + Vector3.new(0, 0, HALF_Z - 70), 50, 45, 0)
	arch(folder, CENTER + Vector3.new(-200, 0, -60), 70, 70, math.rad(35))
	arch(folder, CENTER + Vector3.new(150, 120, 120), 40, 30, math.rad(-20))
	arch(folder, CENTER + Vector3.new(-90, 220, -230), 46, 36, math.rad(60))

	giantTree(folder, CENTER + Vector3.new(-60, 0, 80))

	-- Nuages hauts.
	for _ = 1, 22 do
		Biomes.Cloud(
			folder,
			spot(40) + Vector3.new(0, random:NextNumber(220, 380), 0),
			random:NextNumber(18, 36),
			random
		)
	end

	-- Sommet à atteindre : plateforme dorée tout en haut.
	local summit = CENTER + Vector3.new(60, CONFIG.Size.Y - 40, -200)
	island(folder, summit, 34, random, false)
	local beacon = part(folder, {
		Name = "PhareSommet",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(6, 6, 6),
		Position = summit + Vector3.new(0, 10, 0),
		Color = Color3.fromRGB(255, 210, 60),
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	local light = Instance.new("PointLight")
	light.Color = beacon.Color
	light.Range = 40
	light.Brightness = 3
	light.Parent = beacon
	sign(folder, summit + Vector3.new(0, 22, 0), "⛰️ Sommet du ciel")
end

return Playground
