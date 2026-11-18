--!strict
-- Panneau d'infos : niveau de la boutique (barre d'XP), série en cours,
-- Grand Chaudron (compte à rebours ou progression) et recettes secrètes trouvées.
-- Lit uniquement les attributs publiés par le serveur dans ReplicatedStorage.GameState.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
	local s = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", s // 60, s % 60)
end

function HudController:Start()
	local state = ReplicatedStorage:WaitForChild("GameState")

	local gui = Instance.new("ScreenGui")
	gui.Name = "Hud"
	gui.ResetOnSpawn = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0, 0.5)
	panel.Position = UDim2.new(0, 12, 0.45, 0)
	panel.Size = UDim2.fromOffset(260, 150)
	panel.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
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
	-- Plus petit sur téléphone.
	local scale = Instance.new("UIScale")
	scale.Parent = panel
	local camera = workspace.CurrentCamera
	if camera and camera.ViewportSize.X < 800 then
		scale.Scale = 0.75
	end

	local levelLabel = makeLabel(panel, 1, 24)
	local barBack = Instance.new("Frame")
	barBack.LayoutOrder = 2
	barBack.Size = UDim2.new(1, 0, 0, 10)
	barBack.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
	barBack.Parent = panel
	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(0, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(255, 210, 80)
	barFill.Parent = barBack
	for _, frame in { barBack, barFill } do
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = frame
	end
	local comboLabel = makeLabel(panel, 3, 24)
	local eventLabel = makeLabel(panel, 4, 40)
	local secretsLabel = makeLabel(panel, 5, 20)

	local function attr(name: string, default: any): any
		local value = state:GetAttribute(name)
		return if value == nil then default else value
	end

	while true do
		local level = attr("Level", 1)
		local xp = attr("Xp", 0)
		local needed = math.max(attr("XpNeeded", 1), 1)
		levelLabel.Text = `⭐ Boutique niveau {level}`
		barFill.Size = UDim2.fromScale(math.clamp(xp / needed, 0, 1), 1)

		local combo = attr("Combo", 0)
		local multiplier = attr("ComboMultiplier", 1)
		comboLabel.Text = if multiplier > 1
			then `🔥 Série : {combo}  (gains x{multiplier})`
			else `🔥 Série : {combo}`
		comboLabel.TextColor3 = if multiplier > 1 then Color3.fromRGB(255, 170, 60) else Color3.new(1, 1, 1)

		local now = workspace:GetServerTimeNow()
		local eventState = attr("EventState", "Waiting")
		if eventState == "Active" then
			eventLabel.Text = `🏆 GRAND CHAUDRON ! {attr("EventProgress", 0)}/{attr("EventGoal", 0)}\n⏳ {formatTime(
				attr("EventEndsAt", now) - now
			)} — gains x2`
			eventLabel.TextColor3 = Color3.fromRGB(255, 220, 80)
		elseif eventState == "Party" then
			eventLabel.Text = "🎉 FÊTE DES POTIONS !"
			eventLabel.TextColor3 = Color3.fromRGB(255, 120, 220)
		else
			eventLabel.Text = `🏆 Grand Chaudron dans {formatTime(attr("NextEventAt", now) - now)}`
			eventLabel.TextColor3 = Color3.new(1, 1, 1)
		end

		local personal = Players.LocalPlayer:GetAttribute("SecretsFound")
		local found = if type(personal) == "number" then personal else 0
		secretsLabel.Text = `✨ Mes recettes secrètes : {found}/{attr("SecretsTotal", 3)}`
		task.wait(0.25)
	end
end

return HudController
