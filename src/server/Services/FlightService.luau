--!strict
-- Vol : le client pilote son personnage (réactivité), le SERVEUR gère l'endurance.
--  • « SetFlying » (bool) / « SetBoost » (bool) : demandes du client, validées et limitées.
--  • En vol, l'endurance baisse (plus vite en boost et selon l'atmosphère du monde) ;
--    à 0, le serveur coupe le vol (Flying = false) et le joueur tombe.
--  • Posé au sol (hors vol), elle remonte.
-- Attributs publiés : Flying, Boosting, Stamina, MaxStamina (depuis StatsService), FlySpeed.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Flight = require(Shared.Config.Flight)
local Worlds = require(Shared.Config.Worlds)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local Remotes = require(script.Parent.Parent.Util.Remotes)
local NotifyService = require(script.Parent.NotifyService)
local OnboardingService = require(script.Parent.OnboardingService)

local FlightService = {}

local TICK = 0.1
local toggleCooldown = Cooldown.new(Flight.ToggleCooldownSeconds)
local boostCooldown = Cooldown.new(0.1)
local stamina: { [Player]: number } = {}

local function maxStamina(player: Player): number
	local value = player:GetAttribute("MaxStamina")
	return if type(value) == "number" then value else Flight.MaxStaminaFor(1)
end

local function drainMultiplier(player: Player): number
	local worldId = player:GetAttribute("World")
	local world = if type(worldId) == "string" then Worlds.ById[worldId] else nil
	return if world then world.StaminaDrain else 1
end

local function setFlying(player: Player, value: boolean)
	player:SetAttribute("Flying", value)
	if not value then
		player:SetAttribute("Boosting", false)
	end
end

-- Remet l'endurance au maximum (réapparition, plateformes d'étape).
function FlightService.Refill(player: Player)
	stamina[player] = maxStamina(player)
	player:SetAttribute("Stamina", stamina[player])
end

function FlightService.Land(player: Player)
	setFlying(player, false)
end

function FlightService:Init()
	Remotes.Event("SetFlying").OnServerEvent:Connect(function(player: Player, value: unknown)
		if type(value) ~= "boolean" or not toggleCooldown:try(player) then
			return
		end
		if value and (stamina[player] or 0) < Flight.MinToTakeOff then
			NotifyService.Send(player, "😮‍💨 Plus d'endurance : pose-toi pour récupérer", "warning")
			return
		end
		setFlying(player, value)
	end)
	Remotes.Event("SetBoost").OnServerEvent:Connect(function(player: Player, value: unknown)
		if type(value) ~= "boolean" or not boostCooldown:try(player) then
			return
		end
		player:SetAttribute("Boosting", value and player:GetAttribute("Flying") == true)
	end)
end

function FlightService:Start()
	local function watch(player: Player)
		setFlying(player, false)
		player.CharacterAdded:Connect(function()
			setFlying(player, false)
			FlightService.Refill(player)
		end)
		task.defer(FlightService.Refill, player)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		stamina[player] = nil
		toggleCooldown:forget(player)
		boostCooldown:forget(player)
	end)

	task.spawn(function()
		local sinceGain = 0
		while true do
			sinceGain += task.wait(TICK)
			for _, player in Players:GetPlayers() do
				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if humanoid and root and root:IsA("BasePart") then
					local current = stamina[player] or maxStamina(player)
					local limit = maxStamina(player)
					if player:GetAttribute("Flying") == true then
						local rate = if player:GetAttribute("Boosting") == true then Flight.BoostDrain else Flight.Drain
						current -= rate * drainMultiplier(player) * TICK
						if current <= 0 then
							current = 0
							setFlying(player, false)
							NotifyService.Send(
								player,
								"😮‍💨 Plus d'endurance ! Monte ton niveau pour voler plus longtemps",
								"warning"
							)
						elseif sinceGain >= 1 and root.AssemblyLinearVelocity.Magnitude >= Flight.MinMovingSpeed then
							OnboardingService.Advance(player, "Flew")
						end
					elseif humanoid.FloorMaterial ~= Enum.Material.Air then
						current = math.min(limit, current + Flight.Regen * TICK)
					end
					stamina[player] = math.min(current, limit)
					player:SetAttribute("Stamina", math.floor(stamina[player] * 10) / 10)
				end
			end
			if sinceGain >= 1 then
				sinceGain = 0
			end
		end
	end)
end

return FlightService
