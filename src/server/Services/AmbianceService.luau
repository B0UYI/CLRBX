--!strict
-- Ambiance visuelle (purement cosmétique) : lumière de fin de journée, brume violette,
-- halo des néons, murs latéraux, parquet de la cuisine, bocaux, feu sous le chaudron,
-- appliques murales et lucioles. Aucun impact sur le gameplay.

local Lighting = game:GetService("Lighting")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Ingredients = require(Shared.Config.Ingredients)
local WorldService = require(script.Parent.WorldService)

local AmbianceService = {}

local FLOOR_TOP = 1
local WALL_COLOR = Color3.fromRGB(110, 70, 120)
local TRIM_COLOR = Color3.fromRGB(190, 120, 255)

local function part(parent: Instance, props: { [string]: any }): Part
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

local function light(parent: Instance, color: Color3, range: number, brightness: number)
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Range = range
	pointLight.Brightness = brightness
	pointLight.Parent = parent
end

local function setupLighting()
	Lighting.ClockTime = 18.3
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(70, 55, 95)
	Lighting.OutdoorAmbient = Color3.fromRGB(120, 100, 150)

	-- Une seule Atmosphere compte : on réutilise celle du modèle Baseplate si elle existe.
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	local air = atmosphere :: Atmosphere
	air.Density = 0.3
	air.Offset = 0.2
	air.Color = Color3.fromRGB(200, 170, 230)
	air.Decay = Color3.fromRGB(110, 80, 140)
	air.Glare = 0.2
	air.Haze = 1.5

	local bloom = Lighting:FindFirstChild("PotionBloom")
	if not bloom then
		local created = Instance.new("BloomEffect")
		created.Name = "PotionBloom"
		created.Intensity = 0.5
		created.Size = 24
		created.Threshold = 1.4
		created.Parent = Lighting
	end
	local grading = Lighting:FindFirstChild("PotionColor")
	if not grading then
		local created = Instance.new("ColorCorrectionEffect")
		created.Name = "PotionColor"
		created.Saturation = 0.15
		created.Contrast = 0.08
		created.Brightness = 0.02
		created.Parent = Lighting
	end
end

local function buildWalls(folder: Instance)
	for _, side in { -1, 1 } do
		part(folder, {
			Name = "MurLateral",
			Size = Vector3.new(1, 14, 44),
			Position = Vector3.new(side * 30.5, FLOOR_TOP + 7, -30),
			Color = WALL_COLOR,
			Material = Enum.Material.Brick,
		})
		part(folder, {
			Name = "Frise",
			Size = Vector3.new(1.3, 0.5, 44),
			Position = Vector3.new(side * 30.5, FLOOR_TOP + 14, -30),
			Color = TRIM_COLOR,
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
	end
	part(folder, {
		Name = "FriseFond",
		Size = Vector3.new(62, 0.5, 1.3),
		Position = Vector3.new(0, FLOOR_TOP + 14, -51.5),
		Color = TRIM_COLOR,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	-- Parquet de la cuisine (derrière le comptoir) : sépare visuellement cuisine et salle.
	part(folder, {
		Name = "ParquetCuisine",
		Size = Vector3.new(60, 0.1, 21),
		Position = Vector3.new(0, FLOOR_TOP + 0.05, -41),
		Color = Color3.fromRGB(150, 105, 70),
		Material = Enum.Material.WoodPlanks,
		CanCollide = false,
		CanQuery = false,
	})
end

local function decorateShelves(folder: Instance)
	for _, shelf in WorldService.Shelves do
		local ingredient = Ingredients.ById[shelf.IngredientId]
		local top = shelf.Part.Position + Vector3.new(0, shelf.Part.Size.Y / 2, 0)
		for _, dx in { -1.4, 1.4 } do
			part(folder, {
				Name = "Bocal",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(1.2, 0.8, 0.8),
				CFrame = CFrame.new(top + Vector3.new(dx, 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90)),
				Color = ingredient.Color,
				Material = Enum.Material.Glass,
				Transparency = 0.15,
				CanCollide = false,
				CanQuery = false,
			})
		end
	end
end

local function buildCauldronFire(folder: Instance)
	local cauldron = WorldService.Cauldron
	if not cauldron then
		return
	end
	local base = Vector3.new(cauldron.Body.Position.X, FLOOR_TOP, cauldron.Body.Position.Z)
	for index = 0, 3 do
		local angle = math.rad(45 + index * 90)
		local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 3.3
		part(folder, {
			Name = "Buche",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2.2, 0.6, 0.6),
			CFrame = CFrame.new(base + offset + Vector3.new(0, 0.3, 0)) * CFrame.Angles(0, -angle, 0),
			Color = Color3.fromRGB(90, 55, 30),
			Material = Enum.Material.Wood,
			CanCollide = false,
		})
	end
	local hearth = part(folder, {
		Name = "Foyer",
		Size = Vector3.new(5, 0.4, 5),
		Position = base + Vector3.new(0, 0.3, 0),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
	})
	local fire = Instance.new("Fire")
	fire.Size = 5
	fire.Heat = 2
	fire.Color = Color3.fromRGB(255, 120, 40)
	fire.SecondaryColor = Color3.fromRGB(255, 220, 90)
	fire.Parent = hearth
	light(hearth, Color3.fromRGB(255, 150, 70), 16, 2)
end

local function buildSconces(folder: Instance)
	local spots = {
		Vector3.new(-16, FLOOR_TOP + 11, -50.6),
		Vector3.new(16, FLOOR_TOP + 11, -50.6),
		Vector3.new(-26, FLOOR_TOP + 11, -50.6),
		Vector3.new(26, FLOOR_TOP + 11, -50.6),
		Vector3.new(-29.8, FLOOR_TOP + 10, -40),
		Vector3.new(29.8, FLOOR_TOP + 10, -40),
		Vector3.new(-29.8, FLOOR_TOP + 10, -20),
		Vector3.new(29.8, FLOOR_TOP + 10, -20),
	}
	for index, position in spots do
		local color = if index % 2 == 0 then Color3.fromRGB(120, 230, 255) else Color3.fromRGB(220, 140, 255)
		local orb = part(folder, {
			Name = "Applique",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(1.2, 1.2, 1.2),
			Position = position,
			Color = color,
			Material = Enum.Material.Neon,
			CanCollide = false,
			CanQuery = false,
		})
		light(orb, color, 18, 1.2)
	end
end

local function buildFireflies(folder: Instance)
	local volume = part(folder, {
		Name = "Lucioles",
		Size = Vector3.new(56, 10, 40),
		Position = Vector3.new(0, FLOOR_TOP + 7, -30),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
	})
	local emitter = Instance.new("ParticleEmitter")
	emitter.Shape = Enum.ParticleEmitterShape.Box
	emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	emitter.Rate = 8
	emitter.Lifetime = NumberRange.new(5, 8)
	emitter.Speed = NumberRange.new(0.3, 0.8)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Size = NumberSequence.new(0.18)
	emitter.LightEmission = 1
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 230, 150))
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.1),
		NumberSequenceKeypoint.new(0.8, 0.1),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Parent = volume
end

function AmbianceService:Start()
	local shop = WorldService.Folder
	if not shop then
		return
	end
	local folder = Instance.new("Folder")
	folder.Name = "Ambiance"
	folder.Parent = shop
	setupLighting()
	buildWalls(folder)
	decorateShelves(folder)
	buildCauldronFire(folder)
	buildSconces(folder)
	buildFireflies(folder)
end

return AmbianceService
