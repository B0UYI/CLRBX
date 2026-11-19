--!strict
-- Mondes aériens : 10 étapes par monde, chacune = un VOL CONTINU d'une plateforme flottante à la
-- suivante, à travers les obstacles du biome (ciel, ville, glacier, volcan, espace). Les étapes
-- s'allongent (plus d'endurance nécessaire) et se resserrent. Victoires à chaque plateforme atteinte.
-- Le serveur suit la position des joueurs pour détecter les plateformes atteintes (dans l'ordre),
-- ignore les déplacements invraisemblables et renvoie au début de l'étape en cas de chute ou de
-- contact mortel (glace, flamme active, astéroïde).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local Flight = require(Shared.Config.Flight)
local Movement = require(Shared.Config.Movement)
local Worlds = require(Shared.Config.Worlds)
local Format = require(Shared.Util.Format)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local Remotes = require(script.Parent.Parent.Util.Remotes)
local DailyService = require(script.Parent.DailyService)
local DataService = require(script.Parent.DataService)
local FlightService = require(script.Parent.FlightService)
local FxService = require(script.Parent.FxService)
local LobbyService = require(script.Parent.LobbyService)
local NotifyService = require(script.Parent.NotifyService)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local WorldService = {}

-- Disposition : parcours parallèles orientés vers +X, loin du lobby, dans le ciel.
local ORIGIN_X = 1200
local WORLD_Y = 200
local SPACING_Z = 160
local CORRIDOR_WIDTH = 70
local HALF_WIDTH = CORRIDOR_WIDTH / 2
local CORRIDOR_HEIGHT = 60
local PAD_SIZE = 24
local PAD_THICKNESS = 2
local SPAWN_OFFSET = PAD_SIZE / 2
local CHECK_INTERVAL = 0.1
local VOID_DEPTH = 80
local RESPAWN_DEBOUNCE = 0.5
local PORTAL_Z = -40
local PORTAL_SPACING = 22
local GOLD = Color3.fromRGB(255, 210, 60)
local STAGE_COLOR = Color3.fromRGB(80, 255, 120)
local FLAME_ON = Color3.fromRGB(255, 110, 20)
local FLAME_OFF = Color3.fromRGB(90, 40, 30)

type Built = {
	Def: Worlds.World,
	Index: number,
	Start: Vector3,
	-- Pour chaque étape k : X (depuis le départ) de la plateforme d'arrivée de l'étape.
	EndX: { number },
}

type Progress = {
	World: Built,
	-- Nombre d'étapes terminées dans ce passage (0 à 10).
	Checkpoint: number,
	LastPosition: Vector3?,
	RunStart: number,
}

local ordered: { Built } = {}
local progress: { [Player]: Progress } = {}
local lastRespawn: { [Player]: number } = {}
local portalCooldown = Cooldown.new(1)
local hubCooldown = Cooldown.new(1)

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

local function billboard(adornee: BasePart, text: string, color: Color3, offsetY: number, maxDistance: number)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(8, 0, 2.4, 0) -- en studs : discret de loin
	gui.StudsOffset = Vector3.new(0, offsetY, 0)
	gui.MaxDistance = math.min(maxDistance, 150)
	gui.Adornee = adornee
	gui.Parent = adornee
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	label.BackgroundTransparency = 0.5
	label.TextColor3 = color
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Text = text
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
end

local function rootOf(player: Player): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

-- Réapparition : au départ, ou juste après la ligne de fin de la dernière étape terminée.
local function spawnPoint(world: Built, stagesDone: number): Vector3
	local x = if stagesDone == 0 then SPAWN_OFFSET else world.EndX[stagesDone] + PAD_SIZE / 2
	return world.Start + Vector3.new(x, 4, 0)
end

-- Place le personnage (face au parcours) et oublie l'ancienne position pour la détection.
local function placeAt(player: Player, position: Vector3)
	local character = player.Character
	if not character then
		return
	end
	character:PivotTo(CFrame.lookAt(position, position + Vector3.xAxis))
	local root = rootOf(player)
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
	end
	local current = progress[player]
	if current then
		current.LastPosition = position
	end
end

function WorldService.RespawnAtCheckpoint(player: Player)
	local current = progress[player]
	if not current then
		return
	end
	local now = os.clock()
	if now - (lastRespawn[player] or 0) < RESPAWN_DEBOUNCE then
		return
	end
	lastRespawn[player] = now
	FlightService.Land(player)
	FlightService.Refill(player)
	placeAt(player, spawnPoint(current.World, current.Checkpoint))
end

local flames: { { Part: BasePart, Phase: number, Period: number } } = {}

local function lethal(hazard: BasePart)
	hazard:SetAttribute("Mortel", true)
	hazard.Touched:Connect(function(hit: BasePart)
		if hazard:GetAttribute("Active") == false then
			return -- flamme éteinte : on peut passer
		end
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if player and progress[player] then
			WorldService.RespawnAtCheckpoint(player)
		end
	end)
end

local function buildWorld(index: number, def: Worlds.World, parent: Instance): Built
	local model = Instance.new("Model")
	model.Name = def.Id
	-- Toujours envoyé aux joueurs : pas de décor « pas encore chargé » quand on vole vite.
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local start = Vector3.new(ORIGIN_X, WORLD_Y, (index - 1) * SPACING_Z - (#Worlds.List - 1) * SPACING_Z / 2)
	local random = Random.new(index * 7919)

	local function at(x: number, y: number, z: number): Vector3
		return start + Vector3.new(x, y, z)
	end
	local function pad(x: number, name: string): Part
		local p = part(model, {
			Name = name,
			Size = Vector3.new(PAD_SIZE, PAD_THICKNESS, PAD_SIZE),
			Position = at(x + PAD_SIZE / 2, -PAD_THICKNESS / 2, 0),
			Color = def.FloorColor,
			Material = def.FloorMaterial,
		})
		for _, side in { -1, 1 } do
			part(model, {
				Name = "Bordure",
				Size = Vector3.new(PAD_SIZE, 0.4, 0.6),
				Position = at(x + PAD_SIZE / 2, 0.2, side * (PAD_SIZE / 2 - 0.3)),
				Color = def.AccentColor,
				Material = Enum.Material.Neon,
				CanCollide = false,
				CanQuery = false,
			})
		end
		return p
	end
	-- Barrière de vent : disque traversable ; la franchir = mur du son + bonus de vitesse (côté joueur).
	local function wind(position: Vector3, radius: number)
		local disc = part(model, {
			Name = "BarriereDeVent",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.6, radius * 2, radius * 2),
			-- Axe du cylindre (X) dans le sens du parcours.
			CFrame = CFrame.new(position),
			Color = Color3.fromRGB(190, 240, 255),
			Material = Enum.Material.ForceField,
			Transparency = 0.2,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
		})
		disc:SetAttribute("Vent", radius)
	end

	local function randomPoint(x0: number, length: number, margin: number): Vector3
		return at(
			x0 + random:NextNumber(margin, length - margin),
			random:NextNumber(-CORRIDOR_HEIGHT / 2 + 5, CORRIDOR_HEIGHT / 2 - 5),
			random:NextNumber(-HALF_WIDTH + 5, HALF_WIDTH - 5)
		)
	end

	-- Ciel : nuages (obstacles doux) et anneaux décoratifs.
	local function ciel(x0: number, length: number, difficulty: number)
		for _ = 1, math.floor(length / 40 * (1 + 2 * difficulty)) do
			local size = random:NextNumber(10, 18)
			part(model, {
				Name = "Nuage",
				Shape = Enum.PartType.Ball,
				Size = Vector3.new(size, size, size),
				Position = randomPoint(x0, length, 15),
				Color = Color3.new(1, 1, 1),
				Material = Enum.Material.SmoothPlastic,
				Transparency = 0.1,
			})
		end
		for rx = x0 + 40, x0 + length - 30, 60 do
			wind(at(rx, random:NextNumber(-10, 10), random:NextNumber(-15, 15)), 10)
		end
	end

	-- Ville : rangées de buildings avec une seule brèche, de plus en plus étroite.
	local function ville(x0: number, length: number, difficulty: number)
		local spacing = 50 - 15 * difficulty
		local gap = math.max(10, 26 - 14 * difficulty)
		for rx = x0 + 30, x0 + length - 25, spacing do
			local gapZ = random:NextNumber(-HALF_WIDTH + gap, HALF_WIDTH - gap)
			local z = -HALF_WIDTH - 10
			while z < HALF_WIDTH + 10 do
				local width = random:NextNumber(8, 16)
				local center = z + width / 2
				if math.abs(center - gapZ) > gap / 2 + width / 2 then
					local top = random:NextNumber(20, 60)
					local shade = random:NextNumber(0.35, 0.7)
					part(model, {
						Name = "Building",
						Size = Vector3.new(12, 160 + top, width),
						Position = at(rx, -80 + top / 2, center),
						Color = Color3.new(shade, shade, shade + 0.05),
						Material = Enum.Material.Concrete,
					})
				end
				z += width + 1
			end
		end
	end

	-- Glacier : murs de glace MORTELS percés d'une petite ouverture.
	local function glace(x0: number, length: number, difficulty: number)
		local spacing = 45 - 15 * difficulty
		local hole = math.max(7, 18 - 11 * difficulty)
		for rx = x0 + 30, x0 + length - 25, spacing do
			local hy = random:NextNumber(-CORRIDOR_HEIGHT / 2 + hole, CORRIDOR_HEIGHT / 2 - hole)
			local hz = random:NextNumber(-HALF_WIDTH + hole, HALF_WIDTH - hole)
			local bottom = -CORRIDOR_HEIGHT / 2 - 20
			local topEdge = CORRIDOR_HEIGHT / 2 + 20
			local pieces = {
				-- dessus, dessous (toute la largeur), gauche, droite (hauteur du trou)
				{
					Vector3.new(2, topEdge - (hy + hole / 2), CORRIDOR_WIDTH + 40),
					Vector3.new(0, (topEdge + hy + hole / 2) / 2, 0),
				},
				{
					Vector3.new(2, (hy - hole / 2) - bottom, CORRIDOR_WIDTH + 40),
					Vector3.new(0, (bottom + hy - hole / 2) / 2, 0),
				},
				{
					Vector3.new(2, hole, (hz - hole / 2) + HALF_WIDTH + 20),
					Vector3.new(0, hy, (hz - hole / 2 - HALF_WIDTH - 20) / 2),
				},
				{
					Vector3.new(2, hole, HALF_WIDTH + 20 - (hz + hole / 2)),
					Vector3.new(0, hy, (hz + hole / 2 + HALF_WIDTH + 20) / 2),
				},
			}
			for _, piece in pieces do
				local wall = part(model, {
					Name = "MurDeGlace",
					Size = piece[1],
					Position = at(rx, 0, 0) + piece[2],
					Color = Color3.fromRGB(170, 220, 255),
					Material = Enum.Material.Ice,
					Transparency = 0.25,
				})
				lethal(wall)
			end
		end
	end

	-- Volcan : longue ligne droite ; des flammes s'allument en vague, par cycles (boost conseillé).
	local function volcan(x0: number, length: number, difficulty: number)
		local spacing = 22
		local waveSpeed = 80 + 80 * difficulty
		local period = 2.6 - 1.2 * difficulty
		for fx = x0 + 25, x0 + length - 20, spacing do
			local flame = part(model, {
				Name = "Flamme",
				Size = Vector3.new(4, CORRIDOR_HEIGHT + 20, CORRIDOR_WIDTH + 20),
				Position = at(fx, 0, 0),
				Color = FLAME_ON,
				Material = Enum.Material.Neon,
				CanCollide = false,
				Transparency = 0.25,
			})
			lethal(flame)
			table.insert(flames, { Part = flame, Phase = (fx - x0) / waveSpeed, Period = period })
		end
		for _ = 1, math.floor(length / 30) do
			local size = random:NextNumber(8, 20)
			part(model, {
				Name = "Rocher",
				Size = Vector3.new(size, size, size),
				Position = at(
					x0 + random:NextNumber(0, length),
					random:NextNumber(-40, 40),
					(if random:NextNumber() < 0.5 then -1 else 1) * (HALF_WIDTH + 15)
				),
				Color = Color3.fromRGB(70, 55, 50),
				Material = Enum.Material.Basalt,
			})
		end
	end

	-- Espace : astéroïdes MORTELS qui se déplacent.
	local function espace(x0: number, length: number, difficulty: number)
		for _ = 1, math.floor(length / 30 * (1 + difficulty)) do
			local size = random:NextNumber(6, 14)
			local rock = part(model, {
				Name = "Asteroide",
				Shape = Enum.PartType.Ball,
				Size = Vector3.new(size, size, size),
				Position = randomPoint(x0, length, 20),
				Color = Color3.fromRGB(110, 95, 130),
				Material = Enum.Material.Slate,
				CanCollide = false,
			})
			lethal(rock)
			local axis = if random:NextNumber() < 0.5 then Vector3.yAxis else Vector3.zAxis
			TweenService:Create(
				rock,
				TweenInfo.new(
					random:NextNumber(2, 4) / (1 + difficulty),
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.InOut,
					-1,
					true
				),
				{ Position = rock.Position + axis * random:NextNumber(10, 25) }
			):Play()
		end
	end

	local builders: { [string]: (number, number, number) -> () } = {
		ciel = ciel,
		ville = ville,
		glace = glace,
		volcan = volcan,
		espace = espace,
	}
	local buildBiome = builders[def.Biome] or ciel

	-- Départ
	local startPad = pad(0, "Depart")
	local total = 0
	for stage = 1, Worlds.StageCount do
		total += Worlds.StageWins(def, stage)
	end
	local atmosphere = if def.StaminaDrain > 1 then `\n⚠️ Atmosphère : endurance ×{def.StaminaDrain}` else ""
	billboard(
		startPad,
		`🌍 {def.Name}\n10 étapes · jusqu'à +{Format.Number(total)} 🏆{atmosphere}`,
		def.AccentColor,
		10,
		250
	)

	local endX: { number } = {}
	local x = PAD_SIZE
	for stage = 1, Worlds.StageCount do
		local difficulty = math.clamp(def.Difficulty + 0.3 * (stage - 1) / (Worlds.StageCount - 1), 0, 1)
		local length = Worlds.StageLength(def, stage)
		local needed = Worlds.RecommendedStamina(def, stage)

		local sign = part(model, {
			Name = `Panneau_{stage}`,
			Size = Vector3.new(1, 1, 1),
			Position = at(x, 12, 0),
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
		})
		local level = Flight.LevelForStamina(needed)
		local info =
			`Étape {stage} · {length} m de vol\n🔋 Endurance conseillée : {needed} s\nNiveau conseillé : {level}`
		billboard(sign, info, Color3.fromRGB(255, 240, 120), 0, 300)
		-- Une barrière de vent à l'entrée de chaque étape pour prendre de l'élan.
		wind(at(x + 10, 4, 0), 12)
		buildBiome(x, length, difficulty)
		x += length

		local arrival = pad(x, `FinEtape_{stage}`)
		billboard(
			arrival,
			`✅ Étape {stage}\n+{Format.Number(Worlds.StageWins(def, stage))} 🏆`,
			STAGE_COLOR,
			6,
			250
		)
		table.insert(endX, x)
		x += PAD_SIZE
	end

	-- Arche dorée au-dessus de la dernière plateforme.
	local finishX = endX[#endX] + PAD_SIZE / 2
	local arch = part(model, {
		Name = "Arrivee",
		Size = Vector3.new(2, 2, PAD_SIZE + 4),
		Position = at(finishX, 16, 0),
		Color = GOLD,
		Material = Enum.Material.Neon,
	})
	for _, side in { -1, 1 } do
		part(model, {
			Name = "PilierArrivee",
			Size = Vector3.new(2, 16, 2),
			Position = at(finishX, 8, side * (PAD_SIZE / 2 + 1)),
			Color = GOLD,
			Material = Enum.Material.Neon,
		})
	end
	billboard(arch, "🏆 ARRIVÉE FINALE", GOLD, 4, 400)

	model.Parent = parent
	return { Def = def, Index = index, Start = start, EndX = endX }
end

local function enterWorld(player: Player, world: Built)
	local position = spawnPoint(world, 0)
	pcall(function()
		player:RequestStreamAroundAsync(position)
	end)
	progress[player] = { World = world, Checkpoint = 0, LastPosition = position, RunStart = os.clock() }
	player:SetAttribute("World", world.Def.Id)
	player:SetAttribute("Checkpoint", 0)
	placeAt(player, position)
	NotifyService.Send(player, `🌍 {world.Def.Name} : chaque étape terminée rapporte des 🏆 !`, "info")
	OnboardingService.Advance(player, "EnteredWorld")
end

local function tryEnter(player: Player, world: Built)
	if not portalCooldown:try(player) then
		return
	end
	local data = DataService.Get(player)
	if not data then
		return
	end
	if data.TotalWins < world.Def.RequiredWins then
		local required = Format.Number(world.Def.RequiredWins)
		local owned = Format.Number(data.TotalWins)
		NotifyService.Send(
			player,
			`🔒 {world.Def.Name} : il faut {required} 🏆 au total (tu en as {owned})`,
			"warning"
		)
		return
	end
	enterWorld(player, world)
end

function WorldService.ReturnToHub(player: Player)
	progress[player] = nil
	player:SetAttribute("World", nil)
	player:SetAttribute("Checkpoint", nil)
	local character = player.Character
	if character then
		local spot = Gameplay.Lobby.Spawn + Vector3.new(math.random(-10, 10), 0, math.random(-6, 6))
		character:PivotTo(CFrame.new(spot))
	end
end

local function celebrate(player: Player, amount: number)
	local root = rootOf(player)
	if root then
		FxService.Confetti(root.Position + Vector3.new(0, 6, 0), amount)
		FxService.Sound(root, "Cash")
	end
end

-- Étape terminée : victoires de l'étape (et nouveaux mondes débloqués).
local function clearStage(player: Player, current: Progress, stage: number)
	local def = current.World.Def
	local data = DataService.Get(player)
	local before = if data then data.TotalWins else 0
	local gained = StatsService.AddWins(player, Worlds.StageWins(def, stage), "Gameplay", `Etape_{def.Id}_{stage}`)
	current.Checkpoint = stage
	player:SetAttribute("Checkpoint", stage)
	FlightService.Refill(player)
	celebrate(player, 60)
	NotifyService.Send(player, `✅ Étape {stage} : +{Format.Number(gained)} 🏆`, "success")
	if data then
		for _, world in ordered do
			local required = world.Def.RequiredWins
			if before < required and data.TotalWins >= required then
				NotifyService.Send(
					player,
					`🔓 Nouveau monde débloqué : {world.Def.Name} ! Va au portail du lobby.`,
					"boom"
				)
			end
		end
	end
	OnboardingService.Advance(player, "StageCleared")
end

-- Étape 10 terminée : record de temps, défi du jour, et on repart du début.
local function finishWorld(player: Player, current: Progress)
	local def = current.World.Def
	local elapsed = os.clock() - current.RunStart
	local data = DataService.Get(player)
	local record = ""
	if data then
		data.Finishes += 1
		local best = data.BestTimes[def.Id]
		if not best or elapsed < best then
			data.BestTimes[def.Id] = elapsed
			record = " · ⏱️ Nouveau record !"
		end
	end
	celebrate(player, 250)
	local time = (string.gsub(string.format("%.1f", elapsed), "%.", ","))
	NotifyService.Send(player, `🏆 {def.Name} terminé en {time} s{record}`, "success")
	DailyService.RecordFinish(player)
	current.Checkpoint = 0
	current.RunStart = os.clock()
	player:SetAttribute("Checkpoint", 0)
	placeAt(player, spawnPoint(current.World, 0))
end

-- Suivi des joueurs dans les mondes : chute, plateformes d'arrivée d'étape.
local function track()
	for player, current in progress do
		local root = rootOf(player)
		if not player.Parent then
			progress[player] = nil
		elseif root then
			local position = root.Position
			local previous = current.LastPosition or position
			current.LastPosition = position
			local start = current.World.Start
			if position.Y < start.Y - VOID_DEPTH then
				WorldService.RespawnAtCheckpoint(player)
			else
				local walk = player:GetAttribute("MaxWalkSpeed")
				local fly = player:GetAttribute("FlySpeed")
				local speed = math.max(
					if type(walk) == "number" then walk else 16,
					(if type(fly) == "number" then fly else 40) * Flight.BoostMultiplier
				)
				local allowed = (speed * CHECK_INTERVAL + 25) * Movement.TeleportTolerance
				local inLane = math.abs(position.Z - start.Z) <= HALF_WIDTH + 20 and position.Y <= start.Y + 80
				if inLane and (position - previous).Magnitude <= allowed then
					local fromX = previous.X - start.X
					local toX = position.X - start.X
					local world = current.World
					while
						current.Checkpoint < #world.EndX
						and fromX < world.EndX[current.Checkpoint + 1]
						and toX >= world.EndX[current.Checkpoint + 1]
					do
						clearStage(player, current, current.Checkpoint + 1)
					end
					if current.Checkpoint >= #world.EndX then
						finishWorld(player, current)
					end
				end
			end
		end
	end
end

local function buildPortals(lobby: Instance)
	local folder = Instance.new("Folder")
	folder.Name = "Portails"
	folder.Parent = lobby
	local count = #ordered
	for _, world in ordered do
		local def = world.Def
		local base = Vector3.new((world.Index - (count + 1) / 2) * PORTAL_SPACING, 0.4, PORTAL_Z)
		for _, side in { -1, 1 } do
			part(folder, {
				Name = "Pilier",
				Size = Vector3.new(2, 14, 2),
				Position = base + Vector3.new(side * 6, 7, 0),
				Color = def.AccentColor,
				Material = Enum.Material.Neon,
			})
		end
		part(folder, {
			Name = "Fronton",
			Size = Vector3.new(14, 2, 2),
			Position = base + Vector3.new(0, 14, 0),
			Color = def.AccentColor,
			Material = Enum.Material.Neon,
		})
		local gate = part(folder, {
			Name = `Portail_{def.Id}`,
			Size = Vector3.new(10, 12, 0.6),
			Position = base + Vector3.new(0, 6, 0),
			Color = def.FloorColor,
			Material = Enum.Material.Neon,
			Transparency = 0.35,
			CanCollide = false,
		})
		local lock = if def.RequiredWins > 0
			then `🔒 {Format.Number(def.RequiredWins)} 🏆 au total`
			else "✅ Ouvert"
		billboard(
			gate,
			`{def.Name}\n{lock}\nÉtape 1 : +{Format.Number(Worlds.StageWins(def, 1))} 🏆`,
			Color3.new(1, 1, 1),
			10,
			120
		)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Entrer"
		prompt.ObjectText = def.Name
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt:SetAttribute("WorldId", def.Id)
		prompt.Parent = gate
		prompt.Triggered:Connect(function(player: Player)
			tryEnter(player, world)
		end)
		-- On peut aussi entrer en courant dans le portail.
		gate.Touched:Connect(function(hit: BasePart)
			local character = hit:FindFirstAncestorOfClass("Model")
			local player = character and Players:GetPlayerFromCharacter(character)
			if player and not progress[player] then
				tryEnter(player, world)
			end
		end)
	end
end

function WorldService:Init()
	local remote = Remotes.Event("ReturnToHub")
	remote.OnServerEvent:Connect(function(player: Player)
		if hubCooldown:try(player) then
			WorldService.ReturnToHub(player)
		end
	end)
end

function WorldService:Start()
	local existing = workspace:FindFirstChild("Mondes")
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "Mondes"
	for index, def in Worlds.List do
		table.insert(ordered, buildWorld(index, def, folder))
	end
	folder.Parent = workspace

	local lobby = LobbyService.Folder
	assert(lobby, "Le lobby n'a pas été construit")
	buildPortals(lobby)

	local function watch(player: Player)
		player.CharacterAdded:Connect(function(character)
			if progress[player] then
				character:WaitForChild("HumanoidRootPart", 10)
				lastRespawn[player] = 0
				WorldService.RespawnAtCheckpoint(player)
			end
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		progress[player] = nil
		lastRespawn[player] = nil
		portalCooldown:forget(player)
		hubCooldown:forget(player)
	end)

	task.spawn(function()
		while true do
			task.wait(CHECK_INTERVAL)
			track()
		end
	end)

	-- Flammes du volcan : allumées la moitié du cycle, décalées le long de la piste (vague).
	task.spawn(function()
		while true do
			task.wait(0.05)
			local now = workspace:GetServerTimeNow()
			for _, flame in flames do
				local active = ((now - flame.Phase) % flame.Period) < flame.Period * 0.5
				if flame.Part:GetAttribute("Active") ~= active then
					flame.Part:SetAttribute("Active", active)
					flame.Part.Color = if active then FLAME_ON else FLAME_OFF
					flame.Part.Transparency = if active then 0.25 else 0.85
				end
			end
		end
	end)
end

return WorldService
