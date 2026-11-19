--!strict
-- Interface : barre des étapes 1 → 10 (en haut, dans un monde), « Vitesse », barre de niveau et
-- multiplicateurs ×Vitesse / ×Victoires (en bas), panneau d'infos à gauche.
-- Lit uniquement des attributs publiés par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Format = require(Shared:WaitForChild("Util"):WaitForChild("Format"))
local Config = Shared:WaitForChild("Config")
local Worlds = require(Config:WaitForChild("Worlds"))
local Evolutions = require(Config:WaitForChild("Evolutions"))
local Flight = require(Config:WaitForChild("Flight"))

local HudController = {}

local function number(value: unknown, default: number): number
	return if type(value) == "number" then value else default
end

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function text(parent: Instance, size: UDim2, position: UDim2, color: Color3?): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Parent = parent
	return label
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
	panel.Position = UDim2.new(0, 12, 0.42, 0)
	panel.Size = UDim2.fromOffset(270, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
	panel.BackgroundTransparency = 0.25
	panel.Parent = gui
	corner(panel, 12)
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
	local lines: { TextLabel } = {}
	for index = 1, 7 do
		local line = text(panel, UDim2.new(1, 0, 0, if index == 1 then 26 else 20), UDim2.new())
		line.TextXAlignment = Enum.TextXAlignment.Left
		line.LayoutOrder = index
		lines[index] = line
	end
	lines[1].TextColor3 = Color3.fromRGB(255, 220, 80)

	-- Barre des étapes en haut.
	local stageBar = Instance.new("Frame")
	stageBar.AnchorPoint = Vector2.new(0.5, 0)
	stageBar.Position = UDim2.new(0.5, 0, 0, 8)
	stageBar.Size = UDim2.fromOffset(520, 40)
	stageBar.BackgroundTransparency = 1
	stageBar.Parent = gui
	local stageLayout = Instance.new("UIListLayout")
	stageLayout.FillDirection = Enum.FillDirection.Horizontal
	stageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	stageLayout.Padding = UDim.new(0, 6)
	stageLayout.Parent = stageBar
	local stageBoxes: { TextLabel } = {}
	for stage = 1, Worlds.StageCount do
		local box = text(stageBar, UDim2.fromOffset(44, 40), UDim2.new())
		box.BackgroundTransparency = 0
		box.Text = tostring(stage)
		corner(box, 8)
		stageBoxes[stage] = box
	end
	local worldLabel = text(gui, UDim2.fromOffset(520, 26), UDim2.new(0.5, -260, 0, 52), Color3.fromRGB(255, 240, 150))

	-- Bas : Vitesse, barre de niveau, multiplicateurs.
	local bottom = Instance.new("Frame")
	bottom.AnchorPoint = Vector2.new(0.5, 1)
	bottom.Position = UDim2.new(0.5, 0, 1, -70)
	bottom.Size = UDim2.fromOffset(520, 110)
	bottom.BackgroundTransparency = 1
	bottom.Parent = gui
	-- Endurance (au-dessus de la Vitesse).
	local staminaBack = Instance.new("Frame")
	staminaBack.Position = UDim2.new(0.15, 0, 0, 0)
	staminaBack.Size = UDim2.new(0.7, 0, 0, 24)
	staminaBack.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
	staminaBack.Parent = bottom
	corner(staminaBack, 8)
	local staminaFill = Instance.new("Frame")
	staminaFill.Size = UDim2.fromScale(1, 1)
	staminaFill.BackgroundColor3 = Color3.fromRGB(90, 230, 120)
	staminaFill.Parent = staminaBack
	corner(staminaFill, 8)
	local staminaLabel = text(staminaBack, UDim2.fromScale(1, 1), UDim2.new())
	local speedLabel = text(bottom, UDim2.new(0.5, 0, 0, 34), UDim2.new(0.25, 0, 0, 30))
	local speedMult = text(bottom, UDim2.new(0.25, 0, 0, 24), UDim2.new(0, 0, 0, 40), Color3.fromRGB(120, 200, 255))
	local winsMult = text(bottom, UDim2.new(0.25, 0, 0, 24), UDim2.new(0.75, 0, 0, 40), Color3.fromRGB(255, 200, 60))
	local barBack = Instance.new("Frame")
	barBack.Position = UDim2.new(0, 0, 0, 68)
	barBack.Size = UDim2.new(1, 0, 0, 40)
	barBack.BackgroundColor3 = Color3.fromRGB(30, 35, 55)
	barBack.Parent = bottom
	corner(barBack, 10)
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(0, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
	barFill.Parent = barBack
	corner(barFill, 10)
	local levelLabel = text(barBack, UDim2.new(0.5, -10, 1, -8), UDim2.fromOffset(10, 4))
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	local xpLabel = text(barBack, UDim2.new(0.5, -10, 1, -8), UDim2.new(0.5, 0, 0, 4))
	xpLabel.TextXAlignment = Enum.TextXAlignment.Right

	-- Écran étroit (téléphone) : on réduit tout.
	local camera = workspace.CurrentCamera
	if camera and camera.ViewportSize.X < 800 then
		for _, frame in { panel, stageBar, bottom } do
			local scale = Instance.new("UIScale")
			scale.Scale = 0.65
			scale.Parent = frame
		end
	end

	while true do
		local speed = number(player:GetAttribute("Speed"), 0)
		local multiplier = number(player:GetAttribute("Multiplier"), 1)
		local winsMultiplier = number(player:GetAttribute("WinsMultiplier"), 1)
		speedLabel.Text = `Vitesse : {Format.Number(speed)}`
		speedMult.Text = `×{multiplier} Vitesse`
		winsMult.Text = `×{winsMultiplier} Victoires`
		local staminaValue = number(player:GetAttribute("Stamina"), 0)
		local staminaMax = math.max(number(player:GetAttribute("MaxStamina"), 1), 1)
		local ratio = math.clamp(staminaValue / staminaMax, 0, 1)
		staminaFill.Size = UDim2.fromScale(ratio, 1)
		staminaFill.BackgroundColor3 = if ratio < 0.25
			then Color3.fromRGB(240, 70, 70)
			else Color3.fromRGB(90, 230, 120)
		local staminaText = string.format("%.1f", staminaValue)
		staminaLabel.Text = if player:GetAttribute("FreeFlight") == true
			then "♾️ Vol libre : endurance illimitée"
			else `🔋 Endurance {staminaText} / {math.floor(staminaMax)} s`
		local level = number(player:GetAttribute("Level"), 1)
		local xp = number(player:GetAttribute("LevelXp"), 0)
		local need = math.max(number(player:GetAttribute("LevelNeed"), 1), 1)
		barFill.Size = UDim2.fromScale(math.clamp(xp / need, 0, 1), 1)
		levelLabel.Text = `Niveau {level}`
		xpLabel.Text = `{Format.Number(xp)}/{Format.Number(need)}`

		local formIndex = math.clamp(number(player:GetAttribute("Evolution"), 1), 1, #Evolutions.Forms)
		local totalWins = number(player:GetAttribute("TotalWins"), 0)
		local nextWorld = nil
		for _, world in Worlds.List do
			if world.RequiredWins > totalWins then
				nextWorld = world
				break
			end
		end
		lines[1].Text = `🏆 Victoires : {Format.Number(number(player:GetAttribute("Wins"), 0))}`
		local stepValue = Format.Number(number(player:GetAttribute("StepValue"), 1))
		local perSecond = Format.Number(number(player:GetAttribute("SpeedPerSecond"), 0))
		lines[2].Text = `👣 +{stepValue} par pas  (+{perSecond}/s)`
		lines[3].Text = `🧬 Forme : {Evolutions.Forms[formIndex].Name}`
		local fly = math.floor(number(player:GetAttribute("FlySpeed"), 40))
		local boost = math.floor(fly * Flight.BoostMultiplier)
		lines[4].Text = `✈️ Vol : {fly}  ·  🚀 Boost : {boost}`
		lines[5].Text = if nextWorld
			then `🔓 {nextWorld.Name} : {Format.Number(nextWorld.RequiredWins)} 🏆 au total`
			else "🌟 Tous les mondes débloqués !"
		local dailyGoal = player:GetAttribute("DailyGoal")
		lines[6].Text = if type(dailyGoal) ~= "number"
			then ""
			elseif player:GetAttribute("DailyClaimed") == true then "📅 Défi du jour réussi ✅"
			else `📅 Défi : {number(player:GetAttribute("DailyFinishes"), 0)}/{dailyGoal} mondes finis`
		local streak = number(player:GetAttribute("DailyStreak"), 0)
		lines[7].Text = if streak > 0 then `🎁 Connexion : {streak} jour(s) d'affilée` else ""

		local worldId = player:GetAttribute("World")
		local world = if type(worldId) == "string" then Worlds.ById[worldId] else nil
		stageBar.Visible = world ~= nil
		if world then
			local done = number(player:GetAttribute("Checkpoint"), 0)
			for stage, box in stageBoxes do
				box.BackgroundColor3 = if stage <= done
					then Color3.fromRGB(60, 200, 90)
					elseif stage == done + 1 then Color3.fromRGB(70, 150, 255)
					else Color3.fromRGB(40, 45, 70)
			end
			local nextStage = math.min(done + 1, Worlds.StageCount)
			local needed = Worlds.RecommendedStamina(world, nextStage)
			local gate = ` · 🔋 conseillée : {needed} s`
			local reward = Format.Number(Worlds.StageWins(world, nextStage))
			worldLabel.Text = `🌍 {world.Name} · Étape {nextStage} : +{reward} 🏆{gate}`
		else
			worldLabel.Text = "🏠 Lobby · entre dans un portail pour courir 🏁"
		end
		task.wait(0.1)
	end
end

return HudController
