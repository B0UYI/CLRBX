--!strict
-- Ambiance propre à chaque monde (couleur du ciel, heure), appliquée seulement chez ce joueur.

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
end

return WorldController
