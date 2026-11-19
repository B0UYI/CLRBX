--!strict
-- Pose de vol (bras droit tendu en avant) sur TOUS les personnages qui volent, vue par ce joueur.
-- L'état « Flying » est publié par le serveur ; la pose est appliquée localement par chaque client.

local Players = game:GetService("Players")

local FlightPoseController = {}

-- Épaule → C0 d'origine, pour pouvoir rendre la pose normale à l'atterrissage.
local posed: { [Motor6D]: CFrame } = {}

local function shoulderOf(character: Model): Motor6D?
	local arm = character:FindFirstChild("RightUpperArm")
	local motor = arm and arm:FindFirstChild("RightShoulder")
	return if motor and motor:IsA("Motor6D") then motor else nil
end

local function setPose(character: Model, flying: boolean)
	local motor = shoulderOf(character)
	if not motor then
		return
	end
	if flying and not posed[motor] then
		posed[motor] = motor.C0
		-- Bras levé au-dessus de la tête = vers l'avant quand le corps est à l'horizontale.
		motor.C0 = motor.C0 * CFrame.Angles(math.pi, 0, 0)
	elseif not flying and posed[motor] then
		motor.C0 = posed[motor]
		posed[motor] = nil
	end
end

function FlightPoseController:Start()
	while true do
		for _, other in Players:GetPlayers() do
			local character = other.Character
			if character then
				setPose(character, other:GetAttribute("Flying") == true)
			end
		end
		for motor in posed do
			if not motor.Parent then
				posed[motor] = nil
			end
		end
		task.wait(0.1)
	end
end

return FlightPoseController
