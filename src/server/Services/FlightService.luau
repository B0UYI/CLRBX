--!strict
-- Vol : le client pilote son personnage (réactivité) ; le serveur valide la demande de vol,
-- publie l'état « Flying » (pour la pose des autres joueurs) et donne la Vitesse gagnée en volant.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Flight = require(Shared.Config.Flight)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local Remotes = require(script.Parent.Parent.Util.Remotes)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local FlightService = {}

local toggleCooldown = Cooldown.new(Flight.ToggleCooldownSeconds)

local function rootOf(player: Player): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

function FlightService:Init()
	local remote = Remotes.Event("SetFlying")
	remote.OnServerEvent:Connect(function(player: Player, value: unknown)
		if type(value) ~= "boolean" or not toggleCooldown:try(player) then
			return
		end
		-- Pendant une course, c'est RaceService qui décide.
		if player:GetAttribute("Racing") == true then
			return
		end
		player:SetAttribute("Flying", value)
	end)
end

function FlightService:Start()
	local function watch(player: Player)
		player:SetAttribute("Flying", false)
		player.CharacterAdded:Connect(function()
			if player:GetAttribute("Racing") ~= true then
				player:SetAttribute("Flying", false)
			end
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		toggleCooldown:forget(player)
	end)

	-- Chaque seconde : Vitesse gagnée par les joueurs qui volent ET bougent.
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in Players:GetPlayers() do
				if player:GetAttribute("Flying") == true and player:GetAttribute("Racing") ~= true then
					local root = rootOf(player)
					if root and root.AssemblyLinearVelocity.Magnitude >= Flight.MinMovingSpeed then
						if StatsService.AddSpeed(player, Flight.FlyGainPerSecond) > 0 then
							OnboardingService.Advance(player, "Flew")
						end
					end
				end
			end
		end
	end)
end

return FlightService
