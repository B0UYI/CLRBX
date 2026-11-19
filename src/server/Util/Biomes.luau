--!strict
-- Décors des biomes (purement visuels, sans collision gênante) construits autour des parcours :
-- îles flottantes, ville en contrebas, banquise, volcans, espace. Aussi le dessous des plateformes.
-- Tout est fait de pièces simples (aucun modèle externe) et reste léger en nombre de pièces.

local Biomes = {}

type Props = { [string]: any }

local function part(parent: Instance, props: Props): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	p.Parent = parent
	return p
end

local function upright(position: Vector3): CFrame
	-- Cylindre debout (l'axe d'un cylindre Roblox est X).
	return CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
end

-- Dessous rocheux d'une plateforme (îlot flottant) : couches qui rétrécissent.
function Biomes.Underside(parent: Instance, top: Vector3, size: number, rock: Color3, material: Enum.Material)
	local width = size
	local y = top.Y - 2
	for layer = 1, 3 do
		width *= 0.72
		local height = 3 + layer
		part(parent, {
			Name = "Rocher",
			Size = Vector3.new(width, height, width),
			Position = Vector3.new(top.X, y - height / 2, top.Z),
			Color = rock:Lerp(Color3.new(0, 0, 0), layer * 0.08),
			Material = material,
			CanCollide = false,
		})
		y -= height
	end
end

local function tree(parent: Instance, base: Vector3, random: Random)
	local height = random:NextNumber(5, 9)
	part(parent, {
		Name = "Tronc",
		Size = Vector3.new(1.4, height, 1.4),
		Position = base + Vector3.new(0, height / 2, 0),
		Color = Color3.fromRGB(110, 75, 45),
		Material = Enum.Material.Wood,
		CanCollide = false,
	})
	for i = 1, 3 do
		local size = random:NextNumber(4, 6) - i * 0.6
		part(parent, {
			Name = "Feuillage",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(size, size, size),
			Position = base + Vector3.new(random:NextNumber(-1, 1), height + i * 1.6 - 1, random:NextNumber(-1, 1)),
			Color = Color3.fromRGB(70, 170 + i * 15, 70),
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
	end
end

local function cloud(parent: Instance, center: Vector3, scale: number, random: Random)
	for i = 1, 4 do
		local size = scale * random:NextNumber(0.6, 1)
		part(parent, {
			Name = "Nuage",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(size, size * 0.7, size),
			Position = center + Vector3.new(
				(i - 2.5) * scale * 0.45,
				random:NextNumber(-1, 1) * scale * 0.1,
				random:NextNumber(-0.3, 0.3) * scale
			),
			Color = Color3.new(1, 1, 1),
			Material = Enum.Material.SmoothPlastic,
			Transparency = 0.08,
			CanCollide = false,
		})
	end
end

-- Position hors du couloir de vol (côtés, dessus, dessous) le long du parcours.
local function aside(
	start: Vector3,
	length: number,
	random: Random,
	minSide: number,
	maxSide: number,
	yMin: number,
	yMax: number
): Vector3
	local side = if random:NextNumber() < 0.5 then -1 else 1
	return start
		+ Vector3.new(
			random:NextNumber(-60, length + 60),
			random:NextNumber(yMin, yMax),
			side * random:NextNumber(minSide, maxSide)
		)
end

local function ciel(parent: Instance, start: Vector3, length: number, random: Random)
	-- Mer de nuages en contrebas.
	part(parent, {
		Name = "MerDeNuages",
		Size = Vector3.new(length + 800, 4, 900),
		Position = start + Vector3.new(length / 2, -150, 0),
		Color = Color3.fromRGB(245, 248, 255),
		Material = Enum.Material.SmoothPlastic,
		Transparency = 0.1,
		CanCollide = false,
	})
	for _ = 1, math.floor(length / 45) do
		local center = aside(start, length, random, 70, 260, -90, 60)
		local size = random:NextNumber(18, 40)
		part(parent, {
			Name = "IleHerbe",
			Size = Vector3.new(size, 3, size * 0.8),
			Position = center,
			Color = Color3.fromRGB(100, 200, 90),
			Material = Enum.Material.Grass,
			CanCollide = false,
		})
		Biomes.Underside(parent, center, size, Color3.fromRGB(130, 100, 70), Enum.Material.Slate)
		for _ = 1, random:NextInteger(1, 3) do
			tree(
				parent,
				center
					+ Vector3.new(random:NextNumber(-size / 3, size / 3), 1.5, random:NextNumber(-size / 4, size / 4)),
				random
			)
		end
		if random:NextNumber() < 0.35 then
			-- Petite cascade qui tombe de l'île.
			part(parent, {
				Name = "Cascade",
				Size = Vector3.new(2, 40, 3),
				Position = center + Vector3.new(size / 2, -20, 0),
				Color = Color3.fromRGB(120, 200, 255),
				Material = Enum.Material.Glass,
				Transparency = 0.35,
				CanCollide = false,
			})
		end
	end
	for _ = 1, math.floor(length / 35) do
		cloud(parent, aside(start, length, random, 50, 300, -100, 90), random:NextNumber(14, 34), random)
	end
end

local function ville(parent: Instance, start: Vector3, length: number, random: Random)
	local groundY = -160
	part(parent, {
		Name = "Sol",
		Size = Vector3.new(length + 800, 2, 900),
		Position = start + Vector3.new(length / 2, groundY, 0),
		Color = Color3.fromRGB(60, 62, 70),
		Material = Enum.Material.Asphalt,
		CanCollide = false,
	})
	for _, z in { -20, 20 } do
		part(parent, {
			Name = "Avenue",
			Size = Vector3.new(length + 800, 0.3, 3),
			Position = start + Vector3.new(length / 2, groundY + 1.1, z),
			Color = Color3.fromRGB(255, 220, 90),
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
	end
	local lit = { Color3.fromRGB(255, 230, 150), Color3.fromRGB(150, 220, 255), Color3.fromRGB(255, 150, 220) }
	for _ = 1, math.floor(length / 18) do
		local base = aside(start, length, random, 60, 320, groundY, groundY)
		local width = random:NextNumber(14, 30)
		local height = random:NextNumber(90, 260)
		local shade = random:NextNumber(0.25, 0.55)
		local tower = part(parent, {
			Name = "Tour",
			Size = Vector3.new(width, height, width),
			Position = base + Vector3.new(0, height / 2, 0),
			Color = Color3.new(shade, shade, shade + 0.08),
			Material = if random:NextNumber() < 0.5 then Enum.Material.Glass else Enum.Material.Concrete,
			CanCollide = false,
		})
		-- Bandes de fenêtres éclairées sur la face visible.
		local color = lit[random:NextInteger(1, #lit)]
		for floorIndex = 1, 3 do
			part(parent, {
				Name = "Fenetres",
				Size = Vector3.new(width + 0.2, 1.2, width * 0.8),
				Position = tower.Position + Vector3.new(0, height * (floorIndex / 4 - 0.5), 0),
				Color = color,
				Material = Enum.Material.Neon,
				Transparency = 0.2,
				CanCollide = false,
			})
		end
		if random:NextNumber() < 0.4 then
			part(parent, {
				Name = "Antenne",
				Size = Vector3.new(0.8, 14, 0.8),
				Position = tower.Position + Vector3.new(0, height / 2 + 7, 0),
				Color = Color3.fromRGB(200, 200, 210),
				Material = Enum.Material.Metal,
				CanCollide = false,
			})
			part(parent, {
				Name = "Balise",
				Shape = Enum.PartType.Ball,
				Size = Vector3.new(1.6, 1.6, 1.6),
				Position = tower.Position + Vector3.new(0, height / 2 + 14.5, 0),
				Color = Color3.fromRGB(255, 40, 40),
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
		end
	end
	for _ = 1, math.floor(length / 120) do
		local spot = aside(start, length, random, 45, 70, -40, 20)
		part(parent, {
			Name = "Enseigne",
			Size = Vector3.new(16, 6, 0.6),
			Position = spot,
			Color = lit[random:NextInteger(1, #lit)],
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
	end
end

local function glace(parent: Instance, start: Vector3, length: number, random: Random)
	part(parent, {
		Name = "Banquise",
		Size = Vector3.new(length + 800, 4, 900),
		Position = start + Vector3.new(length / 2, -170, 0),
		Color = Color3.fromRGB(210, 235, 255),
		Material = Enum.Material.Ice,
		CanCollide = false,
	})
	for _ = 1, math.floor(length / 30) do
		local base = aside(start, length, random, 60, 300, -168, -168)
		local width = random:NextNumber(12, 30)
		local y = base.Y
		for layer = 1, 4 do
			local height = random:NextNumber(18, 40)
			part(parent, {
				Name = "Iceberg",
				Size = Vector3.new(width, height, width),
				Position = Vector3.new(base.X, y + height / 2, base.Z),
				Color = Color3.fromRGB(200 - layer * 10, 230, 255),
				Material = if layer % 2 == 0 then Enum.Material.Glacier else Enum.Material.Ice,
				CanCollide = false,
			})
			y += height
			width *= 0.65
		end
	end
	for _ = 1, math.floor(length / 70) do
		local spot = aside(start, length, random, 45, 120, -50, 40)
		part(parent, {
			Name = "Cristal",
			Size = Vector3.new(3, random:NextNumber(10, 22), 3),
			CFrame = CFrame.new(spot)
				* CFrame.Angles(random:NextNumber(-0.4, 0.4), random:NextNumber(0, 3), random:NextNumber(-0.4, 0.4)),
			Color = Color3.fromRGB(120, 230, 255),
			Material = Enum.Material.Neon,
			Transparency = 0.15,
			CanCollide = false,
		})
	end
	-- Neige qui tombe sur tout le parcours.
	local snow = part(parent, {
		Name = "Neige",
		Size = Vector3.new(length + 200, 2, 260),
		Position = start + Vector3.new(length / 2, 90, 0),
		Transparency = 1,
		CanCollide = false,
	})
	local emitter = Instance.new("ParticleEmitter")
	emitter.Shape = Enum.ParticleEmitterShape.Box
	emitter.EmissionDirection = Enum.NormalId.Bottom
	emitter.Rate = math.min(400, length / 4)
	emitter.Lifetime = NumberRange.new(5, 8)
	emitter.Speed = NumberRange.new(8, 14)
	emitter.SpreadAngle = Vector2.new(20, 20)
	emitter.Size = NumberSequence.new(0.35)
	emitter.Color = ColorSequence.new(Color3.new(1, 1, 1))
	emitter.Parent = snow
end

local function volcan(parent: Instance, start: Vector3, length: number, random: Random)
	part(parent, {
		Name = "MerDeLave",
		Size = Vector3.new(length + 800, 4, 900),
		Position = start + Vector3.new(length / 2, -170, 0),
		Color = Color3.fromRGB(255, 90, 10),
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	for _ = 1, math.floor(length / 160) + 2 do
		local base = aside(start, length, random, 140, 340, -168, -168)
		local radius = random:NextNumber(90, 160)
		local y = base.Y
		for layer = 1, 5 do
			local height = 30
			part(parent, {
				Name = "Volcan",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(height, radius * 2, radius * 2),
				CFrame = upright(Vector3.new(base.X, y + height / 2, base.Z)),
				Color = Color3.fromRGB(70, 50, 45):Lerp(Color3.fromRGB(40, 30, 30), layer / 5),
				Material = Enum.Material.Basalt,
				CanCollide = false,
			})
			y += height
			radius *= 0.72
		end
		local crater = part(parent, {
			Name = "Cratere",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2, radius * 1.6, radius * 1.6),
			CFrame = upright(Vector3.new(base.X, y + 1, base.Z)),
			Color = Color3.fromRGB(255, 120, 20),
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		local smoke = Instance.new("Smoke")
		smoke.Size = 30
		smoke.RiseVelocity = 12
		smoke.Opacity = 0.3
		smoke.Color = Color3.fromRGB(60, 50, 50)
		smoke.Parent = crater
	end
	for _ = 1, math.floor(length / 35) do
		local base = aside(start, length, random, 55, 200, -168, -168)
		local height = random:NextNumber(120, 230)
		part(parent, {
			Name = "Fleche",
			Size = Vector3.new(random:NextNumber(8, 16), height, random:NextNumber(8, 16)),
			CFrame = CFrame.new(base + Vector3.new(0, height / 2, 0))
				* CFrame.Angles(0, random:NextNumber(0, 3), random:NextNumber(-0.08, 0.08)),
			Color = Color3.fromRGB(60, 45, 40),
			Material = Enum.Material.Basalt,
			CanCollide = false,
		})
	end
	-- Braises qui montent.
	local embers = part(parent, {
		Name = "Braises",
		Size = Vector3.new(length + 200, 2, 260),
		Position = start + Vector3.new(length / 2, -120, 0),
		Transparency = 1,
		CanCollide = false,
	})
	local emitter = Instance.new("ParticleEmitter")
	emitter.Shape = Enum.ParticleEmitterShape.Box
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Rate = math.min(300, length / 5)
	emitter.Lifetime = NumberRange.new(6, 9)
	emitter.Speed = NumberRange.new(18, 30)
	emitter.Size = NumberSequence.new(0.4, 0)
	emitter.LightEmission = 1
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 160, 40), Color3.fromRGB(255, 60, 10))
	emitter.Parent = embers
end

local function espace(parent: Instance, start: Vector3, length: number, random: Random)
	for _ = 1, 140 do
		local size = random:NextNumber(0.6, 1.6)
		part(parent, {
			Name = "Etoile",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(size, size, size),
			Position = start + Vector3.new(
				random:NextNumber(-200, length + 200),
				random:NextNumber(-250, 250),
				(if random:NextNumber() < 0.5 then -1 else 1) * random:NextNumber(150, 450)
			),
			Color = Color3.new(1, 1, 1),
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
	end
	local planets = {
		{ Color3.fromRGB(240, 130, 90), 160, true },
		{ Color3.fromRGB(110, 170, 255), 110, false },
		{ Color3.fromRGB(190, 120, 255), 80, false },
	}
	for index, planet in planets do
		local center = start
			+ Vector3.new(
				length * index / 4,
				random:NextNumber(-120, 80),
				(if index % 2 == 0 then -1 else 1) * random:NextNumber(380, 520)
			)
		part(parent, {
			Name = "Planete",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(planet[2], planet[2], planet[2]),
			Position = center,
			Color = planet[1],
			Material = Enum.Material.Sand,
			CanCollide = false,
		})
		if planet[3] then
			part(parent, {
				Name = "Anneaux",
				Shape = Enum.PartType.Cylinder,
				Size = Vector3.new(1, planet[2] * 1.9, planet[2] * 1.9),
				CFrame = CFrame.new(center) * CFrame.Angles(0.3, 0, math.rad(80)),
				Color = Color3.fromRGB(255, 220, 170),
				Material = Enum.Material.Neon,
				Transparency = 0.55,
				CanCollide = false,
			})
		end
	end
	for _ = 1, 8 do
		local size = random:NextNumber(90, 180)
		part(parent, {
			Name = "Nebuleuse",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(size, size * 0.6, size),
			Position = aside(start, length, random, 260, 480, -150, 150),
			Color = Color3.fromHSV(random:NextNumber(0.6, 0.95), 0.7, 1),
			Material = Enum.Material.Neon,
			Transparency = 0.85,
			CanCollide = false,
		})
	end
	for _ = 1, math.floor(length / 200) + 1 do
		local center = aside(start, length, random, 80, 140, -30, 30)
		part(parent, {
			Name = "Station",
			Size = Vector3.new(30, 4, 4),
			Position = center,
			Color = Color3.fromRGB(190, 195, 210),
			Material = Enum.Material.DiamondPlate,
			CanCollide = false,
		})
		for _, side in { -1, 1 } do
			part(parent, {
				Name = "PanneauSolaire",
				Size = Vector3.new(10, 0.4, 18),
				Position = center + Vector3.new(side * 20, 0, 0),
				Color = Color3.fromRGB(40, 70, 160),
				Material = Enum.Material.Glass,
				CanCollide = false,
			})
		end
	end
end

local DECORATORS: { [string]: (Instance, Vector3, number, Random) -> () } = {
	ciel = ciel,
	ville = ville,
	glace = glace,
	volcan = volcan,
	espace = espace,
}

-- Décor complet d'un monde autour d'un parcours de `length` studs partant de `start` vers +X.
function Biomes.Decorate(parent: Instance, biome: string, start: Vector3, length: number, seed: number)
	local decorate = DECORATORS[biome]
	if decorate then
		local folder = Instance.new("Folder")
		folder.Name = "Decor"
		folder.Parent = parent
		decorate(folder, start, length, Random.new(seed))
	end
end

-- Couleur et matière du dessous rocheux des plateformes selon le biome.
function Biomes.Rock(biome: string): (Color3, Enum.Material)
	if biome == "glace" then
		return Color3.fromRGB(170, 200, 230), Enum.Material.Glacier
	elseif biome == "volcan" then
		return Color3.fromRGB(60, 45, 40), Enum.Material.Basalt
	elseif biome == "espace" then
		return Color3.fromRGB(110, 100, 130), Enum.Material.Slate
	elseif biome == "ville" then
		return Color3.fromRGB(120, 120, 130), Enum.Material.Concrete
	end
	return Color3.fromRGB(130, 100, 70), Enum.Material.Slate
end

return Biomes
