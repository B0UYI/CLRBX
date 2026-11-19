--!strict
-- Vitesse de course côté joueur : vitesse de marche = vitesse permise par le serveur (« MaxWalkSpeed »)
-- × limiteur choisi par le joueur (100 / 50 / 25 / 10 %), utile pour les sauts délicats.
-- Barre en bas de l'écran : bouton du limiteur et bouton « 🏠 Lobby » quand on est dans un monde.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Movement = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Movement"))

local MovementController = {}

local player = Players.LocalPlayer
local LIMITER_KEY = Enum.KeyCode.L

local function button(parent: Instance, color: Color3): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(150, 44)
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextScaled = true
	b.Font = Enum.Font.FredokaOne
	b.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = b
	return b
end

function MovementController:Start()
	local stepIndex = 1

	local gui = Instance.new("ScreenGui")
	gui.Name = "BarreCourse"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0.5, 1)
	bar.Position = UDim2.new(0.5, 0, 1, -16)
	bar.Size = UDim2.fromOffset(310, 44)
	bar.BackgroundTransparency = 1
	bar.Parent = gui
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 10)
	layout.Parent = bar

	local limiter = button(bar, Color3.fromRGB(60, 140, 255))
	local hub = button(bar, Color3.fromRGB(120, 80, 200))
	hub.Text = "🏠 Lobby"

	local function fraction(): number
		return Movement.LimiterSteps[stepIndex]
	end
	local function cycle()
		stepIndex = stepIndex % #Movement.LimiterSteps + 1
		-- Attribut local (non répliqué) lu par le panneau d'infos.
		player:SetAttribute("Limiter", fraction())
	end
	player:SetAttribute("Limiter", fraction())

	limiter.Activated:Connect(cycle)
	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if not processed and input.KeyCode == LIMITER_KEY then
			cycle()
		end
	end)
	hub.Activated:Connect(function()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local remote = remotes and remotes:FindFirstChild("ReturnToHub")
		if remote and remote:IsA("RemoteEvent") then
			remote:FireServer()
		end
	end)

	RunService.RenderStepped:Connect(function()
		limiter.Text = `🏃 {math.floor(fraction() * 100)} % (L)`
		hub.Visible = player:GetAttribute("World") ~= nil
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local maxSpeed = player:GetAttribute("MaxWalkSpeed")
		if humanoid and type(maxSpeed) == "number" then
			humanoid.WalkSpeed = math.max(8, maxSpeed * fraction())
		end
	end)
end

return MovementController
