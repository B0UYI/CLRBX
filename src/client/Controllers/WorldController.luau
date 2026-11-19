--!strict
-- Ambiance propre à chaque monde (couleur du ciel, heure), appliquée seulement chez ce joueur,
-- et barrières « vitesse requise » : traversables seulement (chez ce joueur) s'il est assez rapide.
-- Le serveur revérifie au passage de la barrière.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Worlds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Worlds"))

local WorldController = {}

local player = Players.LocalPlayer

type Mood = { ClockTime: number, Color: Color3?, Decay: Color3? }

function WorldController:Start()
	local hubMood: Mood? = nil

	local function atmosphere(): Atmosphere?
		return Lighting:FindFirstChildOfClass("Atmosphere")
	end

	local function apply()
		local worldId = player:GetAttribute("World")
		local world = if type(worldId) == "string" then Worlds.ById[worldId] else nil
		local air = atmosphere()
		if world then
			if not hubMood then
				hubMood = {
					ClockTime = Lighting.ClockTime,
					Color = if air then air.Color else nil,
					Decay = if air then air.Decay else nil,
				}
			end
			Lighting.ClockTime = world.ClockTime
			if air then
				air.Color = world.SkyColor
				air.Decay = world.SkyColor:Lerp(Color3.new(0, 0, 0), 0.4)
			end
		elseif hubMood then
			Lighting.ClockTime = hubMood.ClockTime
			if air and hubMood.Color and hubMood.Decay then
				air.Color = hubMood.Color
				air.Decay = hubMood.Decay
			end
			hubMood = nil
		end
	end

	player:GetAttributeChangedSignal("World"):Connect(apply)
	apply()

	local gates: { BasePart } = {}
	local function track(instance: Instance)
		if instance:IsA("BasePart") and instance:GetAttribute("RequiredSpeed") ~= nil then
			table.insert(gates, instance)
		end
	end
	workspace.DescendantAdded:Connect(track)
	for _, descendant in workspace:GetDescendants() do
		track(descendant)
	end
	while true do
		local speed = player:GetAttribute("Speed")
		local mine = if type(speed) == "number" then speed else 0
		for _, gate in gates do
			local required = gate:GetAttribute("RequiredSpeed")
			local open = type(required) == "number" and mine >= required
			gate.CanCollide = not open
			gate.Color = if open then Color3.fromRGB(80, 255, 120) else Color3.fromRGB(255, 70, 70)
		end
		task.wait(0.5)
	end
end

return WorldController
