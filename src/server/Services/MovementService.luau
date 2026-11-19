--!strict
-- « +1 Vitesse » : chaque seconde passée à courir rapporte de la Vitesse (× multiplicateurs).
-- La vitesse de course elle-même est réglée côté client (avec le limiteur) à partir de
-- l'attribut « MaxWalkSpeed » publié par StatsService.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Movement = require(Shared.Config.Movement)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local MovementService = {}

function MovementService:Start()
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in Players:GetPlayers() do
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
					local velocity = root.AssemblyLinearVelocity
					local horizontal = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
					if horizontal >= Movement.MinMovingSpeed then
						if StatsService.AddSpeed(player, Movement.RunGainPerSecond) > 0 then
							OnboardingService.Advance(player, "Ran")
						end
					end
				end
			end
		end
	end)
end

return MovementService
