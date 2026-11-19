--!strict
-- Look des évolutions, vu par ce joueur sur TOUS les personnages (attribut « Evolution »).
-- Selon Config/Evolutions (Look) : lueur, filets de vent, réacteurs aux pieds, arcs électriques,
-- orbes en orbite, halo / couronne, queue de comète, ailes d'énergie, poussière d'étoiles.
-- Tout est local et animé ici (aucun trafic réseau). Évoluer déclenche une explosion de lumière.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Evolutions = require(Shared:WaitForChild("Config"):WaitForChild("Evolutions"))

local FormFxController = {}

local MAX_DISTANCE = 300
local SPARKLE_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"
local FIRE_TEXTURE = "rbxasset://textures/particles/fire_main.dds"
local SPARK_INTERVAL = 0.07
local ORBIT_RADIUS = 3.2
local HALO_DOTS = 10
local FEATHERS = 4
local SPARK_PARTS = { "UpperTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg", "Head" }
local PLANET_COLORS = {
	Color3.fromRGB(255, 170, 80),
	Color3.fromRGB(90, 200, 255),
	Color3.fromRGB(150, 255, 160),
	Color3.fromRGB(255, 110, 180),
	Color3.fromRGB(240, 240, 255),
	Color3.fromRGB(200, 140, 255),
}

type Orb = { Part: BasePart, Tilt: CFrame, Phase: number, Speed: number }
type Feather = { Part: BasePart, Side: number, Rank: number, Length: number }
type Entry = {
	Character: Model,
	Form: Evolutions.Form,
	Model: Model,
	Created: { Instance },
	Moving: { BasePart },
	Orbs: { Orb },
	Halo: { BasePart },
	Feathers: { Feather },
	WingScale: number,
	Beams: { Beam },
	SparkPoints: { Attachment },
	Jets: { ParticleEmitter },
	NextSpark: number,
}

local entries: { [Player]: Entry } = {}
local folder: Folder

local function newPart(entry: Entry, props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	p.Parent = entry.Model
	table.insert(entry.Moving, p)
	return p
end

-- Instance ajoutée DANS le personnage (émetteurs, lumières) : retirée à la reconstruction.
local function inside<T>(entry: Entry, instance: T & Instance, parent: Instance): T
	instance.Parent = parent
	table.insert(entry.Created, instance)
	return instance
end

local function attachment(entry: Entry, parent: Instance, position: Vector3): Attachment
	local a = Instance.new("Attachment")
	a.Name = "FormeFx"
	a.Position = position
	return inside(entry, a, parent)
end

local function emitter(props: { [string]: any }): ParticleEmitter
	local e = Instance.new("ParticleEmitter")
	e.Name = "FormeFx"
	e.LightEmission = 1
	for key, value in props do
		(e :: any)[key] = value
	end
	return e
end

local function clear(player: Player)
	local entry = entries[player]
	if not entry then
		return
	end
	for _, instance in entry.Created do
		instance:Destroy()
	end
	entry.Model:Destroy()
	entries[player] = nil
end

local function build(player: Player, character: Model, form: Evolutions.Form)
	local root = character:FindFirstChild("HumanoidRootPart")
	local torso = character:FindFirstChild("UpperTorso")
	if not root or not torso then
		return
	end
	local look = form.Look
	local model = Instance.new("Model")
	model.Name = `FormeFx_{player.Name}`
	model.Parent = folder
	local entry: Entry = {
		Character = character,
		Form = form,
		Model = model,
		Created = {},
		Moving = {},
		Orbs = {},
		Halo = {},
		Feathers = {},
		WingScale = look.Wings or 0,
		Beams = {},
		SparkPoints = {},
		Jets = {},
		NextSpark = 0,
	}
	entries[player] = entry
	local gradient = ColorSequence.new(form.Color, form.Accent)

	if look.Glow then
		local light = Instance.new("PointLight")
		light.Name = "FormeFx"
		light.Color = form.Color
		light.Range = 8 + form.Index * 1.5
		light.Brightness = 1 + form.Index * 0.2
		inside(entry, light, root)
		inside(
			entry,
			emitter({
				Color = gradient,
				Rate = 6 + form.Index * 2,
				Lifetime = NumberRange.new(0.8, 1.4),
				Speed = NumberRange.new(0.5, 1.5),
				SpreadAngle = Vector2.new(180, 180),
				Acceleration = Vector3.new(0, 2, 0),
				Size = NumberSequence.new(0.5, 0),
				Transparency = NumberSequence.new(0.3, 1),
				Shape = Enum.ParticleEmitterShape.Box,
			}),
			torso
		)
	end

	if look.Wind then
		for _, side in { -1, 1 } do
			local top = attachment(entry, torso, Vector3.new(side * 1.15, 0.6, 0))
			local bottom = attachment(entry, torso, Vector3.new(side * 1.15, -0.4, 0))
			local trail = Instance.new("Trail")
			trail.Name = "FormeFx"
			trail.Attachment0 = top
			trail.Attachment1 = bottom
			trail.Color = ColorSequence.new(form.Accent)
			trail.Lifetime = 0.35
			trail.LightEmission = 1
			trail.Transparency = NumberSequence.new(0.5, 1)
			trail.WidthScale = NumberSequence.new(1, 0.2)
			inside(entry, trail, torso)
		end
	end

	if look.Jets then
		for _, foot in { "LeftFoot", "RightFoot" } do
			local part = character:FindFirstChild(foot)
			if part then
				local jet = inside(
					entry,
					emitter({
						Texture = FIRE_TEXTURE,
						Color = ColorSequence.new(form.Accent, form.Color),
						Rate = 30,
						Lifetime = NumberRange.new(0.2, 0.35),
						Speed = NumberRange.new(8, 14),
						EmissionDirection = Enum.NormalId.Bottom,
						SpreadAngle = Vector2.new(12, 12),
						Size = NumberSequence.new(1.1, 0),
						Transparency = NumberSequence.new(0.1, 1),
					}),
					part
				)
				table.insert(entry.Jets, jet)
			end
		end
	end

	if look.Sparks then
		for _, name in SPARK_PARTS do
			local part = character:FindFirstChild(name)
			if part then
				table.insert(entry.SparkPoints, attachment(entry, part, Vector3.zero))
			end
		end
		for _ = 1, 3 do
			local beam = Instance.new("Beam")
			beam.Name = "FormeFx"
			beam.Color = ColorSequence.new(form.Accent, Color3.new(1, 1, 1))
			beam.LightEmission = 1
			beam.Width0 = 0.15
			beam.Width1 = 0.05
			beam.Segments = 8
			beam.FaceCamera = true
			beam.Enabled = false
			inside(entry, beam, torso)
			table.insert(entry.Beams, beam)
		end
	end

	if look.Tail then
		inside(
			entry,
			emitter({
				Texture = SPARKLE_TEXTURE,
				Color = gradient,
				Rate = 50,
				Lifetime = NumberRange.new(0.6, 1),
				Speed = NumberRange.new(0, 0.5),
				Size = NumberSequence.new(1.8, 0),
				Transparency = NumberSequence.new(0.2, 1),
			}),
			root
		)
	end

	if look.Stars then
		inside(
			entry,
			emitter({
				Texture = SPARKLE_TEXTURE,
				Color = ColorSequence.new(form.Accent),
				Rate = 18,
				Lifetime = NumberRange.new(0.8, 1.6),
				Speed = NumberRange.new(1, 3),
				SpreadAngle = Vector2.new(180, 180),
				RotSpeed = NumberRange.new(-120, 120),
				Size = NumberSequence.new(0.45, 0),
			}),
			root
		)
	end

	local rocks = look.Jets == true and look.Tail == true
	local planets = look.Crown == true
	for i = 1, look.Orbs or 0 do
		local size = if planets then 0.6 + (i % 3) * 0.25 else if rocks then 0.9 else 0.55
		local color = if planets then PLANET_COLORS[(i - 1) % #PLANET_COLORS + 1] else form.Accent
		local orb = newPart(entry, {
			Name = "Orbe",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(size, size, size),
			Color = if rocks then Color3.fromRGB(80, 45, 35) else color,
			Material = if rocks then Enum.Material.Basalt else Enum.Material.Neon,
		})
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, size / 3, 0)
		a0.Parent = orb
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, -size / 3, 0)
		a1.Parent = orb
		local trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Color = ColorSequence.new(if rocks then form.Color else color)
		trail.LightEmission = 1
		trail.Lifetime = 0.3
		trail.Transparency = NumberSequence.new(0.2, 1)
		trail.Parent = orb
		if rocks then
			emitter({
				Texture = FIRE_TEXTURE,
				Color = ColorSequence.new(form.Accent, form.Color),
				Rate = 20,
				Lifetime = NumberRange.new(0.2, 0.4),
				Speed = NumberRange.new(0.5, 1),
				Size = NumberSequence.new(0.9, 0),
			}).Parent =
				orb
		end
		table.insert(entry.Orbs, {
			Part = orb,
			Tilt = CFrame.Angles(math.rad(25 * math.sin(i * 1.7)), i * 0.9, math.rad(30 * math.cos(i * 1.3))),
			Phase = i / (look.Orbs or 1) * math.pi * 2,
			Speed = 2.2 + (i % 2) * 0.6,
		})
	end

	if look.Halo or look.Crown then
		for i = 1, HALO_DOTS do
			local spike = look.Crown == true and i % 2 == 0
			table.insert(
				entry.Halo,
				newPart(entry, {
					Name = "Halo",
					Size = if spike then Vector3.new(0.22, 0.7, 0.22) else Vector3.new(0.3, 0.3, 0.3),
					Shape = if spike then Enum.PartType.Block else Enum.PartType.Ball,
					Color = if spike then form.Accent else form.Color,
				})
			)
		end
	end

	if entry.WingScale > 0 then
		for _, side in { -1, 1 } do
			for rank = 1, FEATHERS do
				local length = (3.4 - rank * 0.45) * entry.WingScale
				table.insert(entry.Feathers, {
					Part = newPart(entry, {
						Name = "Plume",
						Size = Vector3.new(length, 0.32 * entry.WingScale, 0.12),
						Color = form.Color:Lerp(form.Accent, (rank - 1) / (FEATHERS - 1)),
						Transparency = 0.15,
					}),
					Side = side,
					Rank = rank,
					Length = length,
				})
			end
		end
	end
end

local function refresh(player: Player)
	clear(player)
	local character = player.Character
	local index = player:GetAttribute("Evolution")
	if not character or type(index) ~= "number" then
		return
	end
	local form = Evolutions.Forms[math.clamp(math.floor(index), 1, #Evolutions.Forms)]
	if form.Index <= 1 then
		return
	end
	build(player, character, form)
end

-- Explosion de lumière à l'évolution (sphère + anneau qui grandissent et s'effacent).
local function burst(player: Player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local index = player:GetAttribute("Evolution")
	if not root or not root:IsA("BasePart") or type(index) ~= "number" then
		return
	end
	local form = Evolutions.Forms[math.clamp(math.floor(index), 1, #Evolutions.Forms)]
	for i, shape in { Enum.PartType.Ball, Enum.PartType.Cylinder } do
		local p = Instance.new("Part")
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Material = Enum.Material.Neon
		p.Shape = shape
		p.Color = if i == 1 then form.Color else form.Accent
		p.Transparency = 0.2
		p.Size = if i == 1 then Vector3.new(2, 2, 2) else Vector3.new(0.4, 2, 2)
		p.CFrame = if i == 1 then root.CFrame else root.CFrame * CFrame.Angles(0, 0, math.rad(90))
		p.Parent = folder
		local goal = if i == 1 then Vector3.new(30, 30, 30) else Vector3.new(0.4, 60, 60)
		TweenService:Create(p, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = goal,
			Transparency = 1,
		}):Play()
		task.delay(1, p.Destroy, p)
	end
end

local function animate(dt: number)
	local camera = workspace.CurrentCamera
	local now = os.clock()
	local sparkTick = false
	for player, entry in entries do
		local character = entry.Character
		local root = character:FindFirstChild("HumanoidRootPart")
		local torso = character:FindFirstChild("UpperTorso")
		local head = character:FindFirstChild("Head")
		if not character.Parent or not root or not root:IsA("BasePart") or not torso or not torso:IsA("BasePart") then
			continue
		end
		local near = not camera or (root.Position - camera.CFrame.Position).Magnitude < MAX_DISTANCE
		entry.Model.Parent = if near then folder else nil
		if not near then
			continue
		end
		local flying = player:GetAttribute("Flying") == true
		local parts: { BasePart } = {}
		local frames: { CFrame } = {}

		for _, orb in entry.Orbs do
			local angle = now * orb.Speed + orb.Phase
			local offset = orb.Tilt * Vector3.new(math.cos(angle) * ORBIT_RADIUS, 0, math.sin(angle) * ORBIT_RADIUS)
			table.insert(parts, orb.Part)
			table.insert(frames, CFrame.new(root.Position + offset))
		end

		if head and head:IsA("BasePart") and #entry.Halo > 0 then
			local center = head.CFrame * CFrame.new(0, 1.1, 0)
			for i, dot in entry.Halo do
				local angle = i / #entry.Halo * math.pi * 2 + now * 0.8
				table.insert(parts, dot)
				table.insert(frames, center * CFrame.Angles(0, angle, 0) * CFrame.new(0.85, 0, 0))
			end
		end

		if #entry.Feathers > 0 then
			local sweep = math.rad(if flying then 45 else 18)
			local flap = math.sin(now * (if flying then 3 else 1.6)) * math.rad(if flying then 6 else 10)
			for _, feather in entry.Feathers do
				local side = feather.Side
				local spread = math.rad(55 - (feather.Rank - 1) * 27) + flap
				local base = torso.CFrame * CFrame.new(side * 0.35, 0.45, 0.62)
				local rotation = CFrame.Angles(0, -side * sweep, 0) * CFrame.Angles(0, 0, side * spread)
				table.insert(parts, feather.Part)
				table.insert(frames, base * rotation * CFrame.new(side * feather.Length / 2, 0, 0))
			end
		end

		if #parts > 0 then
			workspace:BulkMoveTo(parts, frames, Enum.BulkMoveMode.FireCFrameChanged)
		end

		for _, jet in entry.Jets do
			jet.Rate = if flying then 90 else 25
		end

		if #entry.Beams > 0 and now >= entry.NextSpark then
			sparkTick = true
			local points = entry.SparkPoints
			for _, beam in entry.Beams do
				if #points >= 2 and math.random() < 0.6 then
					local a = points[math.random(1, #points)]
					local b = points[math.random(1, #points)]
					beam.Attachment0 = a
					beam.Attachment1 = if a == b then points[(table.find(points, a) or 1) % #points + 1] else b
					beam.CurveSize0 = math.random(-30, 30) / 10
					beam.CurveSize1 = math.random(-30, 30) / 10
					beam.Enabled = true
				else
					beam.Enabled = false
				end
			end
		end
	end
	if sparkTick then
		for _, entry in entries do
			if now >= entry.NextSpark then
				entry.NextSpark = now + SPARK_INTERVAL + dt
			end
		end
	end
end

function FormFxController:Start()
	folder = Instance.new("Folder")
	folder.Name = "EvolutionsLocales"
	folder.Parent = workspace

	local function watch(player: Player)
		local known = player:GetAttribute("Evolution")
		player:GetAttributeChangedSignal("Evolution"):Connect(function()
			local value = player:GetAttribute("Evolution")
			if type(known) == "number" and type(value) == "number" and value > known then
				burst(player)
			end
			known = value
			refresh(player)
		end)
		player.CharacterAdded:Connect(function(character)
			character:WaitForChild("UpperTorso", 10)
			character:WaitForChild("Head", 10)
			refresh(player)
		end)
		player.CharacterRemoving:Connect(function()
			clear(player)
		end)
		if player.Character then
			task.spawn(refresh, player)
		end
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(clear)
	RunService.RenderStepped:Connect(animate)
end

return FormFxController
