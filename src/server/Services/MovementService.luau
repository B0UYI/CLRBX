--!strict
-- Pas : le serveur compte les pas (à pied ou en vol) à partir de la vitesse horizontale réelle
-- (un pas tous les Steps.Stride studs, au plus Steps.MaxStepsPerSecond par seconde).
-- La vitesse à pied est fixe ; seuls les pas (et le vol) font progresser.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Movement = require(Shared.Config.Movement)
local Steps = require(Shared.Config.Steps)
local StatsService = require(script.Parent.StatsService)

local MovementService = {}

local TICK = 0.5
local pending: { [Player]: number } = {}

function MovementService:Start()
	Players.PlayerRemoving:Connect(function(player)
		pending[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(TICK)
			for _, player in Players:GetPlayers() do
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
					local velocity = root.AssemblyLinearVelocity
					local horizontal = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
					if horizontal >= Movement.MinMovingSpeed then
						local rate = math.min(horizontal / Steps.Stride, Steps.MaxStepsPerSecond)
						local total = (pending[player] or 0) + rate * TICK
						local whole = math.floor(total)
						pending[player] = total - whole
						if whole > 0 then
							StatsService.AddSteps(player, whole)
						end
					end
				end
			end
		end
	end)
end

return MovementService
