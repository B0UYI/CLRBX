--!strict
-- Courses : intermède dans le lobby → compte à rebours sur la ligne de départ → 20 s de vol → résultats.
-- La distance de chaque joueur est CALCULÉE par le serveur à partir de sa Vitesse (le client ne fait
-- qu'afficher le vol) : impossible de tricher sur les victoires.
-- État publié dans ReplicatedStorage.GameState (RacePhase, PhaseEndsAt, RaceStartAt, RaceDuration).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local Race = require(Shared.Config.Race)
local Format = require(Shared.Util.Format)
local DailyService = require(script.Parent.DailyService)
local DataService = require(script.Parent.DataService)
local LobbyService = require(script.Parent.LobbyService)
local NotifyService = require(script.Parent.NotifyService)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local RaceService = {}

type Racer = {
	Velocity: number,
	Lane: Vector3,
	Distance: number,
	Zone: number,
	Wins: number,
	Finished: boolean,
}

local GATE_WIDTH = 110
local GATE_HEIGHT = 40
local GATE_THICKNESS = 1.5
local TRACK_CLOUDS = 60

local racers: { [Player]: Racer } = {}
local gameState: Configuration

local function now(): number
	return workspace:GetServerTimeNow()
end

local function setPhase(phase: string, duration: number)
	gameState:SetAttribute("RacePhase", phase)
	gameState:SetAttribute("PhaseEndsAt", now() + duration)
end

local function formatTime(seconds: number): string
	local s = math.max(0, math.ceil(seconds))
	return string.format("%d:%02d", s // 60, s % 60)
end

local function rightVector(): Vector3
	return Race.Direction:Cross(Vector3.yAxis).Unit
end

local function bar(parent: Instance, cframe: CFrame, size: Vector3, color: Color3): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = size
	p.CFrame = cframe
	p.Color = color
	p.Material = Enum.Material.Neon
	p.Parent = parent
	return p
end

local function label(adornee: BasePart, text: string, color: Color3)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(280, 60)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.MaxDistance = 1500
	gui.Adornee = adornee
	gui.Parent = adornee
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = color
	textLabel.TextStrokeTransparency = 0.2
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.Text = text
	textLabel.Parent = gui
end

-- Piste dans le ciel : aire de départ, un portique par zone, arche d'arrivée, nuages.
local function buildTrack()
	local existing = workspace:FindFirstChild("Piste")
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "Piste"

	local startFrame = CFrame.lookAt(Race.Start, Race.Start + Race.Direction)
	local pad = bar(folder, startFrame * CFrame.new(0, -6, 0), Vector3.new(GATE_WIDTH, 1, 16), Color3.new(1, 1, 1))
	pad.Name = "AireDeDepart"

	for _, zone in Race.Zones do
		local center = Race.Start + Race.Direction * zone.Distance
		local frame = CFrame.lookAt(center, center + Race.Direction)
		local isFinish = zone.Index == #Race.Zones
		local color = if isFinish
			then Color3.fromRGB(255, 210, 60)
			else Color3.fromHSV((zone.Index / #Race.Zones) * 0.8, 0.8, 1)
		local top = bar(
			folder,
			frame * CFrame.new(0, GATE_HEIGHT / 2, 0),
			Vector3.new(GATE_WIDTH, GATE_THICKNESS, GATE_THICKNESS),
			color
		)
		bar(
			folder,
			frame * CFrame.new(0, -GATE_HEIGHT / 2, 0),
			Vector3.new(GATE_WIDTH, GATE_THICKNESS, GATE_THICKNESS),
			color
		)
		for _, side in { -1, 1 } do
			bar(
				folder,
				frame * CFrame.new(side * GATE_WIDTH / 2, 0, 0),
				Vector3.new(GATE_THICKNESS, GATE_HEIGHT, GATE_THICKNESS),
				color
			)
		end
		top.Name = `Zone_{zone.Index}`
		local text = if isFinish
			then `🏁 ARRIVÉE · +{zone.Wins + Race.FinishBonusWins} 🏆`
			else `Zone {zone.Index} · +{zone.Wins} 🏆`
		label(top, text, color)
	end

	local random = Random.new(7)
	local right = rightVector()
	for _ = 1, TRACK_CLOUDS do
		local along = random:NextNumber(0, Race.TrackLength)
		local side = if random:NextNumber() < 0.5 then -1 else 1
		local size = random:NextNumber(14, 30)
		local cloud = Instance.new("Part")
		cloud.Name = "Nuage"
		cloud.Anchored = true
		cloud.CanCollide = false
		cloud.CanQuery = false
		cloud.CanTouch = false
		cloud.Shape = Enum.PartType.Ball
		cloud.Size = Vector3.new(size, size, size)
		cloud.Position = Race.Start
			+ Race.Direction * along
			+ right * side * random:NextNumber(75, 170)
			+ Vector3.new(0, random:NextNumber(-40, 40), 0)
		cloud.Color = Color3.new(1, 1, 1)
		cloud.Material = Enum.Material.SmoothPlastic
		cloud.Transparency = 0.15
		cloud.Parent = folder
	end

	folder.Parent = workspace
end

local function laneFor(index: number, count: number): Vector3
	local spacing = math.min(Race.LaneSpacing, (GATE_WIDTH - 10) / math.max(count, 1))
	return Race.Start + rightVector() * ((index - (count + 1) / 2) * spacing)
end

local function runIntermission(duration: number)
	setPhase("Intermission", duration)
	local endsAt = now() + duration
	while now() < endsAt do
		LobbyService.SetBoardText(`🏁 PROCHAINE COURSE\n{formatTime(endsAt - now())}`)
		task.wait(0.5)
	end
end

-- Place les participants sur la ligne de départ. Renvoie false s'il n'y a personne.
local function startRace(): boolean
	local list = {}
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if DataService.Get(player) and humanoid and humanoid.Health > 0 then
			table.insert(list, player)
		end
	end
	if #list == 0 then
		return false
	end

	gameState:SetAttribute("RaceStartAt", now() + Race.CountdownSeconds)
	gameState:SetAttribute("RaceDuration", Race.DurationSeconds)
	setPhase("Countdown", Race.CountdownSeconds)
	LobbyService.SetBoardText("🏁 COURSE EN COURS !")

	for index, player in list do
		local data = DataService.Get(player)
		local character = player.Character
		if data and character then
			local lane = laneFor(index, #list)
			local velocity = Race.VelocityFor(data.Speed)
			racers[player] = {
				Velocity = velocity,
				Lane = lane,
				Distance = 0,
				Zone = 0,
				Wins = 0,
				Finished = false,
			}
			player:SetAttribute("Racing", true)
			player:SetAttribute("Flying", true)
			player:SetAttribute("RaceLane", lane)
			player:SetAttribute("RaceVelocity", velocity)
			player:SetAttribute("RaceDistance", 0)
			player:SetAttribute("RaceWins", 0)
			character:PivotTo(CFrame.lookAt(lane, lane + Race.Direction))
		end
	end
	NotifyService.All("🏁 La course commence dans 5 secondes !", "info")
	task.wait(Race.CountdownSeconds)
	return true
end

local function updateRacer(player: Player, racer: Racer, elapsed: number)
	local distance = math.min(racer.Velocity * elapsed, Race.TrackLength)
	racer.Distance = distance
	while racer.Zone < #Race.Zones and Race.Zones[racer.Zone + 1].Distance <= distance do
		racer.Zone += 1
		local zone = Race.Zones[racer.Zone]
		racer.Wins += StatsService.AddWins(player, zone.Wins, "Gameplay", `Zone_{zone.Index}`)
	end
	if not racer.Finished and distance >= Race.TrackLength then
		racer.Finished = true
		local bonus = StatsService.AddWins(player, Race.FinishBonusWins, "Gameplay", "Arrivee")
		racer.Wins += bonus
		NotifyService.Send(player, `🏁 ARRIVÉE ! Bonus +{Format.Number(bonus)} 🏆`, "success")
	end
	player:SetAttribute("RaceDistance", math.floor(distance))
	player:SetAttribute("RaceWins", racer.Wins)
end

local function runRace()
	local startAt = gameState:GetAttribute("RaceStartAt")
	if type(startAt) ~= "number" then
		return
	end
	setPhase("Racing", Race.DurationSeconds)
	while true do
		local elapsed = math.clamp(now() - startAt, 0, Race.DurationSeconds)
		for player, racer in racers do
			if player.Parent then
				updateRacer(player, racer, elapsed)
			else
				racers[player] = nil
			end
		end
		if elapsed >= Race.DurationSeconds then
			break
		end
		task.wait(0.2)
	end
end

local function finishRace()
	setPhase("Results", Race.ResultsSeconds)
	type Entry = { Player: Player, Racer: Racer }
	local ranking: { Entry } = {}
	for player, racer in racers do
		table.insert(ranking, { Player = player, Racer = racer })
	end
	table.sort(ranking, function(a, b)
		return a.Racer.Distance > b.Racer.Distance
	end)

	local medals = { "🥇", "🥈", "🥉" }
	local podium = {}
	for index = 1, math.min(3, #ranking) do
		local entry = ranking[index]
		table.insert(podium, `{medals[index]} {entry.Player.DisplayName} {Format.Number(entry.Racer.Distance)} m`)
	end
	if #podium > 0 then
		NotifyService.All(table.concat(podium, "  ·  "), "success")
		LobbyService.SetBoardText(`🏆 VAINQUEUR\n{ranking[1].Player.DisplayName}`)
	end

	for _, entry in ranking do
		local player, racer = entry.Player, entry.Racer
		local data = DataService.Get(player)
		if data then
			data.Races += 1
			data.BestDistance = math.max(data.BestDistance, math.floor(racer.Distance))
		end
		NotifyService.Send(
			player,
			`Course terminée : {Format.Number(racer.Distance)} m · +{Format.Number(racer.Wins)} 🏆`,
			"info"
		)
		DailyService.RecordRace(player)
		OnboardingService.Advance(player, "Raced")

		-- Retour au lobby.
		player:SetAttribute("Racing", false)
		player:SetAttribute("Flying", false)
		player:SetAttribute("RaceLane", nil)
		player:SetAttribute("RaceVelocity", nil)
		local character = player.Character
		if character then
			local spot = Gameplay.Lobby.Spawn + Vector3.new(math.random(-12, 12), 0, math.random(-6, 6))
			character:PivotTo(CFrame.new(spot))
		end
	end
	table.clear(racers)
	task.wait(Race.ResultsSeconds)
	for _, player in Players:GetPlayers() do
		player:SetAttribute("RaceDistance", nil)
		player:SetAttribute("RaceWins", nil)
	end
end

function RaceService:Init()
	local existing = ReplicatedStorage:FindFirstChild("GameState")
	if existing then
		existing:Destroy()
	end
	gameState = Instance.new("Configuration")
	gameState.Name = "GameState"
	gameState:SetAttribute("RacePhase", "Intermission")
	gameState:SetAttribute("PhaseEndsAt", 0)
	gameState:SetAttribute("RaceDuration", Race.DurationSeconds)
	gameState.Parent = ReplicatedStorage
end

function RaceService:Start()
	buildTrack()
	Players.PlayerRemoving:Connect(function(player)
		racers[player] = nil
	end)
	task.spawn(function()
		local first = true
		while true do
			runIntermission(if first then Race.FirstIntermissionSeconds else Race.IntermissionSeconds)
			first = false
			if startRace() then
				runRace()
				finishRace()
			end
		end
	end)
end

return RaceService
