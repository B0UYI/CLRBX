--!strict
-- Interface : panneau (Vitesse +/s, Victoires, gains, vitesse de vol, défi du jour),
-- bandeau de course en haut, et au centre le compte à rebours puis la distance en course.
-- Lit uniquement des attributs publiés par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Format = require(Shared:WaitForChild("Util"):WaitForChild("Format"))
local Race = require(Shared:WaitForChild("Config"):WaitForChild("Race"))

local HudController = {}

local function makeLabel(parent: Instance, order: number, height: number): TextLabel
	local label = Instance.new("TextLabel")
	label.LayoutOrder = order
	label.Size = UDim2.new(1, 0, 0, height)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Parent = parent
	return label
end

local function formatTime(seconds: number): string
	local s = math.max(0, math.ceil(seconds))
	return string.format("%d:%02d", s // 60, s % 60)
end

local function number(value: unknown, default: number): number
	return if type(value) == "number" then value else default
end

local function zonesReached(distance: number): number
	local count = 0
	for _, zone in Race.Zones do
		if zone.Distance <= distance then
			count += 1
		end
	end
	return count
end

function HudController:Start()
	local player = Players.LocalPlayer
	local state = ReplicatedStorage:WaitForChild("GameState")

	local gui = Instance.new("ScreenGui")
	gui.Name = "Hud"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Panneau à gauche.
	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0, 0.5)
	panel.Position = UDim2.new(0, 12, 0.45, 0)
	panel.Size = UDim2.fromOffset(280, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	panel.BackgroundTransparency = 0.25
	panel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = panel
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = panel
	local scale = Instance.new("UIScale")
	scale.Parent = panel
	local camera = workspace.CurrentCamera
	if camera and camera.ViewportSize.X < 800 then
		scale.Scale = 0.75 -- téléphone
	end

	local speedLabel = makeLabel(panel, 1, 30)
	speedLabel.TextColor3 = Color3.fromRGB(255, 230, 90)
	local winsLabel = makeLabel(panel, 2, 26)
	local gainLabel = makeLabel(panel, 3, 22)
	gainLabel.TextColor3 = Color3.fromRGB(150, 220, 255)
	local flyLabel = makeLabel(panel, 4, 20)
	local dailyLabel = makeLabel(panel, 5, 20)
	local streakLabel = makeLabel(panel, 6, 20)
	streakLabel.TextColor3 = Color3.fromRGB(255, 200, 120)

	-- Bandeau de course en haut.
	local pill = Instance.new("TextLabel")
	pill.AnchorPoint = Vector2.new(0.5, 0)
	pill.Position = UDim2.new(0.5, 0, 0, 10)
	pill.Size = UDim2.new(0.6, 0, 0, 44)
	pill.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	pill.BackgroundTransparency = 0.15
	pill.TextColor3 = Color3.fromRGB(255, 230, 90)
	pill.TextScaled = true
	pill.Font = Enum.Font.FredokaOne
	pill.Parent = gui
	local pillLimit = Instance.new("UISizeConstraint")
	pillLimit.MaxSize = Vector2.new(460, 44)
	pillLimit.Parent = pill
	local pillCorner = Instance.new("UICorner")
	pillCorner.CornerRadius = UDim.new(0, 12)
	pillCorner.Parent = pill

	-- Grand texte au centre (compte à rebours, distance).
	local big = Instance.new("TextLabel")
	big.AnchorPoint = Vector2.new(0.5, 0.5)
	big.Position = UDim2.new(0.5, 0, 0.28, 0)
	big.Size = UDim2.new(0.8, 0, 0, 100)
	big.BackgroundTransparency = 1
	big.TextColor3 = Color3.new(1, 1, 1)
	big.TextStrokeTransparency = 0.2
	big.TextScaled = true
	big.Font = Enum.Font.FredokaOne
	big.Visible = false
	big.Parent = gui

	while true do
		local now = workspace:GetServerTimeNow()
		local speed = number(player:GetAttribute("Speed"), 0)
		local perSecond = number(player:GetAttribute("SpeedPerSecond"), 0)
		speedLabel.Text = `⚡ Vitesse : {Format.Number(speed)}  (+{Format.Number(perSecond)}/s)`
		winsLabel.Text = `🏆 Victoires : {Format.Number(number(player:GetAttribute("Wins"), 0))}`
		local multiplier = number(player:GetAttribute("Multiplier"), 1)
		local boostLeft = number(player:GetAttribute("BoostUntil"), 0) - os.time()
		gainLabel.Text = if boostLeft > 0
			then `🦸 Gains ×{multiplier} · 🚀 Turbo {formatTime(boostLeft)}`
			else `🦸 Gains ×{multiplier}`
		flyLabel.Text = `✈️ Vol : {math.floor(number(player:GetAttribute("FlySpeed"), 0))} m/s`

		local dailyGoal = player:GetAttribute("DailyGoal")
		if type(dailyGoal) == "number" then
			if player:GetAttribute("DailyClaimed") == true then
				dailyLabel.Text = "📅 Défi du jour réussi ✅"
			else
				local races = number(player:GetAttribute("DailyRaces"), 0)
				local reward = number(player:GetAttribute("DailyReward"), 0)
				dailyLabel.Text = `📅 Défi : {races}/{dailyGoal} courses ({reward} 🏆)`
			end
		else
			dailyLabel.Text = ""
		end
		local streak = number(player:GetAttribute("DailyStreak"), 0)
		streakLabel.Text = if streak > 0 then `🎁 Connexion : {streak} jour(s) d'affilée` else ""

		local phase = state:GetAttribute("RacePhase")
		local endsAt = number(state:GetAttribute("PhaseEndsAt"), now)
		local racing = player:GetAttribute("Racing") == true
		local distanceValue = player:GetAttribute("RaceDistance")
		local raceWins = number(player:GetAttribute("RaceWins"), 0)
		big.Visible = false
		if phase == "Intermission" then
			pill.Text = `🏁 Prochaine course dans {formatTime(endsAt - now)}`
		elseif phase == "Countdown" then
			pill.Text = "🏁 Prépare-toi !"
			if racing then
				big.Visible = true
				big.Text = tostring(math.max(1, math.ceil(endsAt - now)))
			end
		elseif phase == "Racing" then
			pill.Text = `🏁 COURSE ! {formatTime(endsAt - now)}`
			if racing and type(distanceValue) == "number" then
				local startAt = number(state:GetAttribute("RaceStartAt"), now)
				big.Visible = true
				local zoneText = `Zone {zonesReached(distanceValue)}/{#Race.Zones}`
				local winsText = Format.Number(raceWins)
				big.Text = if now - startAt < 1
					then "GO ! 🚀"
					else `{Format.Number(distanceValue)} m · {zoneText}\n+{winsText} 🏆`
			end
		elseif phase == "Results" then
			pill.Text = "🏆 Résultats"
			if type(distanceValue) == "number" then
				big.Visible = true
				big.Text = `Résultat : {Format.Number(distanceValue)} m\n+{Format.Number(raceWins)} 🏆`
			end
		else
			pill.Text = ""
		end

		task.wait(0.1)
	end
end

return HudController
