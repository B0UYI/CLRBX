--!strict
-- Mondes : un parcours d'obstacles par monde (généré depuis Config/Worlds, toujours le même tracé),
-- portails dans le lobby, lave, vide et créatures, 10 étapes (barrière de vitesse requise à l'entrée,
-- victoires à la fin), puis on relance le parcours (pour battre son record).
-- Le serveur suit la position des joueurs pour détecter le passage des lignes (fiable même à très
-- grande vitesse), ignore les déplacements invraisemblables (téléportation), exige les étapes dans
-- l'ordre et la vitesse requise (barrière contournée = retour au début de l'étape).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local Movement = require(Shared.Config.Movement)
local Worlds = require(Shared.Config.Worlds)
local Format = require(Shared.Util.Format)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local Remotes = require(script.Parent.Parent.Util.Remotes)
local DailyService = require(script.Parent.DailyService)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local LobbyService = require(script.Parent.LobbyService)
local NotifyService = require(script.Parent.NotifyService)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local WorldService = {}

-- Disposition : parcours parallèles orientés vers +X, loin du lobby, au-dessus du vide.
local ORIGIN_X = 1200
local WORLD_Y = 60
local SPACING_Z = 120
local COURSE_WIDTH = 40
local HALF_WIDTH = COURSE_WIDTH / 2
local FLOOR_THICKNESS = 2
local START_LENGTH = 40
local SPAWN_OFFSET = 20
local STAGE_PAD_LENGTH = 14
local CREATURE_SIZE = 5
local FINISH_RUNOUT = 30
local CHECK_INTERVAL = 0.1
local VOID_DEPTH = 30
local RESPAWN_DEBOUNCE = 0.5
local PORTAL_Z = -40
local PORTAL_SPACING = 22
local GOLD = Color3.fromRGB(255, 210, 60)
local STAGE_COLOR = Color3.fromRGB(80, 255, 120)
local GATE_COLOR = Color3.fromRGB(255, 70, 70)

type Built = {
	Def: Worlds.World,
	Index: number,
	Start: Vector3,
	-- Pour chaque étape k : X (depuis le départ) de la barrière d'entrée et de la ligne de fin.
	GateX: { number },
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
	gui.Size = UDim2.fromOffset(240, 70)
	gui.StudsOffset = Vector3.new(0, offsetY, 0)
	gui.MaxDistance = maxDistance
	gui.Adornee = adornee
	gui.Parent = adornee
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	label.BackgroundTransparency = 0.2
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
	local x = if stagesDone == 0 then SPAWN_OFFSET else world.EndX[stagesDone] + STAGE_PAD_LENGTH / 2
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
	placeAt(player, spawnPoint(current.World, current.Checkpoint))
end

local function onHazardTouched(hit: BasePart)
	local character = hit:FindFirstAncestorOfClass("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	if player and progress[player] then
		WorldService.RespawnAtCheckpoint(player)
	end
end

local KINDS = { "floor", "islands", "gap", "lava", "wall", "hurdles", "beam", "boulder" }

local function pickKind(random: Random, difficulty: number): string
	local weights: { [string]: number } = {
		floor = 3 - 2 * difficulty,
		islands = 0.5 + 1.5 * difficulty,
		gap = 1 + difficulty,
		lava = 1 + difficulty,
		wall = 1,
		hurdles = 1,
		beam = 0.5 + difficulty,
		boulder = 1.5 * difficulty,
	}
	local total = 0
	for _, kind in KINDS do
		total += weights[kind]
	end
	local roll = random:NextNumber() * total
	for _, kind in KINDS do
		roll -= weights[kind]
		if roll <= 0 then
			return kind
		end
	end
	return "floor"
end

local function buildWorld(index: number, def: Worlds.World, parent: Instance): Built
	local model = Instance.new("Model")
	model.Name = def.Id
	-- Toujours envoyé aux joueurs : pas de sol « pas encore chargé » quand on court très vite.
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	local start = Vector3.new(ORIGIN_X, WORLD_Y, (index - 1) * SPACING_Z - (#Worlds.List - 1) * SPACING_Z / 2)
	local random = Random.new(index * 7919)

	local function floor(x: number, length: number, zOffset: number, width: number, name: string?): Part
		return part(model, {
			Name = name or "Sol",
			Size = Vector3.new(length, FLOOR_THICKNESS, width),
			Position = start + Vector3.new(x + length / 2, -FLOOR_THICKNESS / 2, zOffset),
			Color = def.FloorColor,
			Material = def.FloorMaterial,
		})
	end
	local function edges(x: number, length: number)
		for _, side in { -1, 1 } do
			part(model, {
				Name = "Bordure",
				Size = Vector3.new(length, 0.3, 0.4),
				Position = start + Vector3.new(x + length / 2, 0.15, side * (HALF_WIDTH - 0.2)),
				Color = def.AccentColor,
				Material = Enum.Material.Neon,
				CanCollide = false,
				CanQuery = false,
			})
		end
	end
	local function lava(x: number, length: number)
		local p = part(model, {
			Name = "Lave",
			Size = Vector3.new(length, FLOOR_THICKNESS, COURSE_WIDTH),
			Position = start + Vector3.new(x + length / 2, -FLOOR_THICKNESS / 2 + 0.1, 0),
			Color = def.LavaColor,
			Material = Enum.Material.Neon,
		})
		p.Touched:Connect(onHazardTouched)
	end
	local function wallWithOpening(x: number)
		local opening = 7
		local openZ = random:NextNumber(-HALF_WIDTH + opening / 2 + 1, HALF_WIDTH - opening / 2 - 1)
		local leftWidth = (openZ - opening / 2) + HALF_WIDTH
		local rightWidth = HALF_WIDTH - (openZ + opening / 2)
		for _, piece in { { leftWidth, -HALF_WIDTH + leftWidth / 2 }, { rightWidth, HALF_WIDTH - rightWidth / 2 } } do
			if piece[1] > 0.5 then
				part(model, {
					Name = "Mur",
					Size = Vector3.new(2, 10, piece[1]),
					Position = start + Vector3.new(x, 5, piece[2]),
					Color = def.AccentColor,
					Material = Enum.Material.SmoothPlastic,
				})
			end
		end
	end
	local function hurdle(x: number)
		part(model, {
			Name = "Haie",
			Size = Vector3.new(1.5, 3, COURSE_WIDTH),
			Position = start + Vector3.new(x, 1.5, 0),
			Color = def.AccentColor,
			Material = Enum.Material.SmoothPlastic,
		})
	end

	-- Îlots sur la lave : plateformes séparées par des bandes de lave.
	local function islands(x: number, length: number, difficulty: number)
		lava(x, length)
		local count = math.max(2, math.floor(length / 14))
		local slot = length / count
		local size = math.max(5, slot * (0.8 - 0.35 * difficulty))
		for i = 0, count - 1 do
			local z = random:NextNumber(-HALF_WIDTH * 0.4, HALF_WIDTH * 0.4) * difficulty
			part(model, {
				Name = "Ilot",
				Size = Vector3.new(size, FLOOR_THICKNESS + 0.4, math.max(8, COURSE_WIDTH * (0.7 - 0.4 * difficulty))),
				Position = start + Vector3.new(x + slot * i + slot / 2, -FLOOR_THICKNESS / 2 + 0.3, z),
				Color = def.FloorColor,
				Material = def.FloorMaterial,
			})
		end
	end

	-- Chemin étroit entre deux bandes de lave, avec un boulet qui roule vers les coureurs.
	local function boulder(x: number, length: number)
		local width = 14
		floor(x, length, 0, width, "Chemin")
		local side = (COURSE_WIDTH - width) / 2
		for _, sign in { -1, 1 } do
			local p = part(model, {
				Name = "Lave",
				Size = Vector3.new(length, FLOOR_THICKNESS, side),
				Position = start
					+ Vector3.new(x + length / 2, -FLOOR_THICKNESS / 2 - 0.5, sign * (width / 2 + side / 2)),
				Color = def.LavaColor,
				Material = Enum.Material.Neon,
			})
			p.Touched:Connect(onHazardTouched)
		end
		local ball = part(model, {
			Name = "Boulet",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(10, 10, 10),
			Position = start + Vector3.new(x + length, 5, 0),
			Color = Color3.fromRGB(95, 95, 115),
			Material = Enum.Material.Slate,
			CanCollide = false,
		})
		ball.Touched:Connect(onHazardTouched)
		TweenService:Create(
			ball,
			TweenInfo.new(random:NextNumber(1.5, 2.5), Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false),
			{ Position = start + Vector3.new(x, 5, 0) }
		):Play()
	end

	-- Créature qui patrouille en travers de la piste : la toucher renvoie au début de l'étape.
	local function creature(x: number, speedFactor: number)
		local body = part(model, {
			Name = "Creature",
			Size = Vector3.new(CREATURE_SIZE, CREATURE_SIZE, CREATURE_SIZE),
			Color = def.AccentColor:Lerp(Color3.new(0, 0, 0), 0.35),
			Material = Enum.Material.SmoothPlastic,
		})
		local fromZ = -HALF_WIDTH + CREATURE_SIZE
		local toZ = HALF_WIDTH - CREATURE_SIZE
		if random:NextNumber() < 0.5 then
			fromZ, toZ = toZ, fromZ
		end
		local from = start + Vector3.new(x, CREATURE_SIZE / 2, fromZ)
		-- Face (yeux) tournée vers les coureurs qui arrivent par -X.
		body.CFrame = CFrame.lookAt(from, from - Vector3.xAxis)
		local face = Instance.new("SurfaceGui")
		face.Face = Enum.NormalId.Front
		face.Parent = body
		local eyes = Instance.new("TextLabel")
		eyes.Size = UDim2.fromScale(1, 1)
		eyes.BackgroundTransparency = 1
		eyes.TextScaled = true
		eyes.Text = "👀"
		eyes.Parent = face
		body.Touched:Connect(onHazardTouched)
		local duration = random:NextNumber(1.8, 3.2) / speedFactor
		local goal = CFrame.lookAt(
			start + Vector3.new(x, CREATURE_SIZE / 2, toZ),
			start + Vector3.new(x - 1, CREATURE_SIZE / 2, toZ)
		)
		TweenService:Create(
			body,
			TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ CFrame = goal }
		):Play()
	end

	-- Départ
	local startFloor = floor(0, START_LENGTH, 0, COURSE_WIDTH, "Depart")
	edges(0, START_LENGTH)
	local total = 0
	for stage = 1, Worlds.StageCount do
		total += Worlds.StageWins(def, stage)
	end
	billboard(
		startFloor,
		`🌍 {def.Name}\n10 étapes · jusqu'à +{Format.Number(total)} 🏆`,
		def.AccentColor,
		8,
		200
	)

	local gateX: { number } = {}
	local endX: { number } = {}
	local x = START_LENGTH
	for stage = 1, Worlds.StageCount do
		local difficulty = math.clamp(def.Difficulty + 0.3 * (stage - 1) / (Worlds.StageCount - 1), 0, 1)
		local required = Worlds.RequiredSpeed(def, stage)

		-- Barrière d'entrée (vitesse requise) : bloquante côté joueur tant qu'il est trop lent.
		table.insert(gateX, x + 1)
		if required > 0 then
			local gate = part(model, {
				Name = `Barriere_{stage}`,
				Size = Vector3.new(1, 14, COURSE_WIDTH),
				Position = start + Vector3.new(x + 1, 7, 0),
				Color = GATE_COLOR,
				Material = Enum.Material.ForceField,
				Transparency = 0.3,
			})
			gate:SetAttribute("RequiredSpeed", required)
		end
		local sign = part(model, {
			Name = `Panneau_{stage}`,
			Size = Vector3.new(1, 1, 1),
			Position = start + Vector3.new(x + 1, 16, 0),
			Transparency = 1,
			CanCollide = false,
			CanQuery = false,
		})
		local requirement = if required > 0
			then `⚡ Vitesse requise : {Format.Number(required)}`
			else "⚡ Aucune vitesse requise"
		billboard(
			sign,
			`Étape {stage}\n{requirement}\nNiveau conseillé : {math.max(1, stage * 2 + (def.Difficulty * 50) // 1)}`,
			Color3.fromRGB(255, 240, 120),
			0,
			250
		)

		-- Zone d'obstacles de l'étape.
		local zoneEnd = x + def.StageLength
		local first = true
		while x < zoneEnd do
			local length = math.min(random:NextInteger(18, 30), zoneEnd - x)
			-- L'étape 1 du premier monde : terrain plat (seule la créature est à éviter).
			local kind = if length < 14
					or (first and stage == 1)
					or difficulty < 0.05
				then "floor"
				else pickKind(random, difficulty)
			first = false
			if kind == "boulder" and (stage < 3 or length < 20) then
				kind = "floor"
			end
			if kind == "boulder" then
				boulder(x, length)
			elseif kind == "islands" then
				islands(x, length, difficulty)
			elseif kind == "gap" then
				local gap = math.min(length - 8, math.floor(5 + 9 * difficulty * random:NextNumber() + 0.5))
				floor(x, length - gap, 0, COURSE_WIDTH)
				edges(x, length - gap)
			elseif kind == "lava" then
				local third = length / 3
				floor(x, third, 0, COURSE_WIDTH)
				lava(x + third, third)
				floor(x + 2 * third, third, 0, COURSE_WIDTH)
				edges(x, length)
			elseif kind == "wall" then
				floor(x, length, 0, COURSE_WIDTH)
				edges(x, length)
				wallWithOpening(x + length / 2)
			elseif kind == "hurdles" then
				floor(x, length, 0, COURSE_WIDTH)
				edges(x, length)
				hurdle(x + length / 2)
			elseif kind == "beam" then
				local width = math.max(5, 12 - 7 * difficulty)
				local z = random:NextNumber(-HALF_WIDTH + width / 2, HALF_WIDTH - width / 2)
				floor(x, length, z, width, "Poutre")
			else
				floor(x, length, 0, COURSE_WIDTH)
				edges(x, length)
			end
			x += length
		end
		-- Créatures : 1 à l'étape 1, puis de plus en plus nombreuses et rapides.
		local creatures = 1 + (stage - 1) // 2
		for i = 1, creatures do
			creature(zoneEnd - def.StageLength + def.StageLength * i / (creatures + 1), 1 + 0.15 * (stage - 1))
		end

		-- Fin de l'étape : dalle de victoires (et réapparition de l'étape suivante).
		local pad = floor(x, STAGE_PAD_LENGTH, 0, COURSE_WIDTH, `FinEtape_{stage}`)
		edges(x, STAGE_PAD_LENGTH)
		part(model, {
			Name = "LigneEtape",
			Size = Vector3.new(1, 0.2, COURSE_WIDTH),
			Position = start + Vector3.new(x + 1, 0.1, 0),
			Color = STAGE_COLOR,
			Material = Enum.Material.Neon,
			CanCollide = false,
			CanQuery = false,
		})
		billboard(pad, `✅ Étape {stage}\n+{Format.Number(Worlds.StageWins(def, stage))} 🏆`, STAGE_COLOR, 5, 200)
		table.insert(endX, x + 1)
		x += STAGE_PAD_LENGTH
	end

	-- Arche dorée au-dessus de la dernière ligne + mur invisible au bout.
	local finishX = endX[#endX]
	floor(x, FINISH_RUNOUT, 0, COURSE_WIDTH, "PlateformeArrivee")
	for _, side in { -1, 1 } do
		part(model, {
			Name = "PilierArrivee",
			Size = Vector3.new(2, 16, 2),
			Position = start + Vector3.new(finishX, 8, side * (HALF_WIDTH + 1)),
			Color = GOLD,
			Material = Enum.Material.Neon,
		})
	end
	local arch = part(model, {
		Name = "Arrivee",
		Size = Vector3.new(2, 2, COURSE_WIDTH + 4),
		Position = start + Vector3.new(finishX, 16, 0),
		Color = GOLD,
		Material = Enum.Material.Neon,
	})
	billboard(arch, "🏆 ARRIVÉE FINALE", GOLD, 4, 400)
	part(model, {
		Name = "MurDeFin",
		Size = Vector3.new(2, 40, COURSE_WIDTH + 8),
		Position = start + Vector3.new(x + FINISH_RUNOUT, 20, 0),
		Transparency = 1,
	})

	model.Parent = parent
	return { Def = def, Index = index, Start = start, GateX = gateX, EndX = endX }
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

-- Suivi des joueurs dans les mondes : vide, barrières de vitesse, fins d'étape.
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
				local maxSpeed = player:GetAttribute("MaxWalkSpeed")
				local speed = if type(maxSpeed) == "number" then maxSpeed else 16
				local allowed = (speed * CHECK_INTERVAL + 25) * Movement.TeleportTolerance
				local inLane = math.abs(position.Z - start.Z) <= HALF_WIDTH + 6 and position.Y <= start.Y + 80
				if inLane and (position - previous).Magnitude <= allowed then
					local fromX = previous.X - start.X
					local toX = position.X - start.X
					local world = current.World
					local nextStage = current.Checkpoint + 1
					-- Barrière contournée sans la vitesse requise : retour au début de l'étape.
					local gate = world.GateX[nextStage]
					local data = DataService.Get(player)
					if gate and fromX < gate and toX >= gate and data then
						if data.Speed < Worlds.RequiredSpeed(world.Def, nextStage) then
							WorldService.RespawnAtCheckpoint(player)
							continue
						end
					end
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
end

return WorldService
