--!strict
-- Interface : panneau (Vitesse +/s, Victoires, gains, vitesse de course, prochain monde, défi du jour)
-- et bandeau en haut (monde actuel, point de contrôle, record).
-- Lit uniquement des attributs publiés par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Format = require(Shared:WaitForChild("Util"):WaitForChild("Format"))
local Worlds = require(Shared:WaitForChild("Config"):WaitForChild("Worlds"))

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

function HudController:Start()
	local player = Players.LocalPlayer

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
	local runLabel = makeLabel(panel, 4, 20)
	local nextLabel = makeLabel(panel, 5, 20)
	nextLabel.TextColor3 = Color3.fromRGB(180, 255, 180)
	local dailyLabel = makeLabel(panel, 6, 20)
	local streakLabel = makeLabel(panel, 7, 20)
	streakLabel.TextColor3 = Color3.fromRGB(255, 200, 120)

	-- Bandeau en haut (monde actuel).
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

	while true do
		local speed = number(player:GetAttribute("Speed"), 0)
		local perSecond = number(player:GetAttribute("SpeedPerSecond"), 0)
		speedLabel.Text = `⚡ Vitesse : {Format.Number(speed)}  (+{Format.Number(perSecond)}/s)`
		winsLabel.Text = `🏆 Victoires : {Format.Number(number(player:GetAttribute("Wins"), 0))}`
		local multiplier = number(player:GetAttribute("Multiplier"), 1)
		local boostLeft = number(player:GetAttribute("BoostUntil"), 0) - os.time()
		gainLabel.Text = if boostLeft > 0
			then `🦸 Gains ×{multiplier} · 🚀 Turbo {formatTime(boostLeft)}`
			else `🦸 Gains ×{multiplier}`
		local limiter = number(player:GetAttribute("Limiter"), 1)
		local walk = math.floor(number(player:GetAttribute("MaxWalkSpeed"), 16) * limiter)
		runLabel.Text = if limiter < 1
			then `🏃 Course : {Format.Number(walk)} ({math.floor(limiter * 100)} %)`
			else `🏃 Course : {Format.Number(walk)}`
		local totalWins = number(player:GetAttribute("TotalWins"), 0)
		local nextWorld = nil
		for _, world in Worlds.List do
			if world.RequiredWins > totalWins then
				nextWorld = world
				break
			end
		end
		nextLabel.Text = if nextWorld
			then `🔓 Prochain monde : {nextWorld.Name} ({Format.Number(nextWorld.RequiredWins)} 🏆)`
			else "🌟 Tous les mondes sont débloqués !"

		local dailyGoal = player:GetAttribute("DailyGoal")
		if type(dailyGoal) == "number" then
			if player:GetAttribute("DailyClaimed") == true then
				dailyLabel.Text = "📅 Défi du jour réussi ✅"
			else
				local finishes = number(player:GetAttribute("DailyFinishes"), 0)
				local reward = number(player:GetAttribute("DailyReward"), 0)
				dailyLabel.Text = `📅 Défi : {finishes}/{dailyGoal} parcours ({reward} 🏆)`
			end
		else
			dailyLabel.Text = ""
		end
		local streak = number(player:GetAttribute("DailyStreak"), 0)
		streakLabel.Text = if streak > 0 then `🎁 Connexion : {streak} jour(s) d'affilée` else ""

		local worldId = player:GetAttribute("World")
		local world = if type(worldId) == "string" then Worlds.ById[worldId] else nil
		if world then
			local checkpoint = number(player:GetAttribute("Checkpoint"), 0)
			pill.Text = `🌍 {world.Name} · 🚩 {checkpoint}/3 · Arrivée +{Format.Number(world.Wins)} 🏆`
		else
			pill.Text = "🏠 Lobby · entre dans un portail pour courir 🏁"
		end

		task.wait(0.1)
	end
end

return HudController
