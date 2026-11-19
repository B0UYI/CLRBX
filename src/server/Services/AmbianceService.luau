--!strict
-- Ambiance (purement cosmétique) : grand ciel de jour, légère brume, halo des néons,
-- nuages flottants dans le ciel du lobby pour donner envie de voler.

local Lighting = game:GetService("Lighting")

local LobbyService = require(script.Parent.LobbyService)

local AmbianceService = {}

local CLOUD_COUNT = 40

local function setupLighting()
	Lighting.ClockTime = 14
	Lighting.Brightness = 2.5
	Lighting.Ambient = Color3.fromRGB(130, 130, 150)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 170)

	-- Une seule Atmosphere compte : on réutilise celle du modèle Baseplate si elle existe.
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	local air = atmosphere :: Atmosphere
	air.Density = 0.25
	air.Offset = 0.1
	air.Color = Color3.fromRGB(199, 220, 255)
	air.Decay = Color3.fromRGB(106, 140, 180)
	air.Glare = 0.3
	air.Haze = 1

	if not Lighting:FindFirstChild("CielBloom") then
		local bloom = Instance.new("BloomEffect")
		bloom.Name = "CielBloom"
		bloom.Intensity = 0.4
		bloom.Size = 24
		bloom.Threshold = 1.5
		bloom.Parent = Lighting
	end
	if not Lighting:FindFirstChild("CielCouleur") then
		local grading = Instance.new("ColorCorrectionEffect")
		grading.Name = "CielCouleur"
		grading.Saturation = 0.12
		grading.Contrast = 0.05
		grading.Parent = Lighting
	end
end

local function buildClouds(parent: Instance)
	local random = Random.new(42)
	for _ = 1, CLOUD_COUNT do
		local center =
			Vector3.new(random:NextNumber(-300, 300), random:NextNumber(60, 140), random:NextNumber(-300, 300))
		for puff = 1, 3 do
			local size = random:NextNumber(10, 22)
			local cloud = Instance.new("Part")
			cloud.Name = "Nuage"
			cloud.Anchored = true
			cloud.CanCollide = false
			cloud.CanQuery = false
			cloud.CanTouch = false
			cloud.Shape = Enum.PartType.Ball
			cloud.Size = Vector3.new(size, size, size)
			cloud.Position = center + Vector3.new((puff - 2) * size * 0.6, random:NextNumber(-2, 2), 0)
			cloud.Color = Color3.new(1, 1, 1)
			cloud.Material = Enum.Material.SmoothPlastic
			cloud.Transparency = 0.15
			cloud.Parent = parent
		end
	end
end

local WIND_COUNT = 14

-- Barrières de vent dans le ciel du lobby (mur du son côté joueur).
local function buildWinds(parent: Instance)
	local random = Random.new(99)
	for _ = 1, WIND_COUNT do
		local radius = random:NextNumber(8, 14)
		local disc = Instance.new("Part")
		disc.Name = "BarriereDeVent"
		disc.Anchored = true
		disc.CanCollide = false
		disc.CanQuery = false
		disc.CanTouch = false
		disc.Shape = Enum.PartType.Cylinder
		disc.Size = Vector3.new(0.6, radius * 2, radius * 2)
		disc.CFrame = CFrame.new(random:NextNumber(-250, 250), random:NextNumber(30, 110), random:NextNumber(-250, 250))
			* CFrame.Angles(0, random:NextNumber(0, math.pi * 2), 0)
		disc.Color = Color3.fromRGB(190, 240, 255)
		disc.Material = Enum.Material.ForceField
		disc.Transparency = 0.2
		disc:SetAttribute("Vent", radius)
		disc.Parent = parent
	end
end

function AmbianceService:Start()
	setupLighting()
	local lobby = LobbyService.Folder
	if lobby then
		local clouds = Instance.new("Folder")
		clouds.Name = "Nuages"
		clouds.Parent = lobby
		buildClouds(clouds)
		buildWinds(clouds)
	end
end

return AmbianceService
