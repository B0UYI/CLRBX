--!strict
-- Déplacement à pied à vitesse fixe + bouton « 🏠 Lobby » (visible dans un monde).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Movement = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Movement"))

local MovementController = {}

local player = Players.LocalPlayer

function MovementController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BarreLobby"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local hub = Instance.new("TextButton")
	hub.AnchorPoint = Vector2.new(0.5, 1)
	hub.Position = UDim2.new(0.5, 0, 1, -16)
	hub.Size = UDim2.fromOffset(150, 40)
	hub.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
	hub.TextColor3 = Color3.new(1, 1, 1)
	hub.TextScaled = true
	hub.Font = Enum.Font.FredokaOne
	hub.Text = "🏠 Lobby"
	hub.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = hub
	hub.Activated:Connect(function()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local remote = remotes and remotes:FindFirstChild("ReturnToHub")
		if remote and remote:IsA("RemoteEvent") then
			remote:FireServer()
		end
	end)

	RunService.RenderStepped:Connect(function()
		hub.Visible = player:GetAttribute("World") ~= nil
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.WalkSpeed ~= Movement.BaseWalkSpeed then
			humanoid.WalkSpeed = Movement.BaseWalkSpeed
		end
	end)
end

return MovementController
