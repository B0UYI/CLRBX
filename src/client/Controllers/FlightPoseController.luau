--!strict
-- Posture de super-héros (vue par ce joueur sur TOUS les personnages qui volent) :
-- bras droit tendu en avant (poing), bras gauche plaqué le long du corps, genou gauche plié.
-- L'état « Flying » est publié par le serveur ; la pose est appliquée localement par chaque client.

local Players = game:GetService("Players")

local FlightPoseController = {}

-- Articulation R15 → rotation appliquée à son C0 pendant le vol.
local POSE: { { Part: string, Joint: string, Rotation: CFrame } } = {
	-- Bras levé au-dessus de la tête = vers l'avant quand le corps est à l'horizontale.
	{ Part = "RightUpperArm", Joint = "RightShoulder", Rotation = CFrame.Angles(math.pi, 0, math.rad(-8)) },
	{ Part = "RightLowerArm", Joint = "RightElbow", Rotation = CFrame.Angles(math.rad(5), 0, 0) },
	-- Bras gauche le long du corps, légèrement en arrière.
	{ Part = "LeftUpperArm", Joint = "LeftShoulder", Rotation = CFrame.Angles(math.rad(-20), 0, math.rad(8)) },
	-- Jambe gauche un peu pliée (silhouette dynamique), jambe droite tendue.
	{ Part = "LeftUpperLeg", Joint = "LeftHip", Rotation = CFrame.Angles(math.rad(12), 0, 0) },
	{ Part = "LeftLowerLeg", Joint = "LeftKnee", Rotation = CFrame.Angles(math.rad(-40), 0, 0) },
	{ Part = "RightUpperLeg", Joint = "RightHip", Rotation = CFrame.Angles(math.rad(-4), 0, 0) },
}

-- Articulation → C0 d'origine, pour rendre la pose normale à l'atterrissage.
local posed: { [Motor6D]: CFrame } = {}

local function setPose(character: Model, flying: boolean)
	for _, joint in POSE do
		local limb = character:FindFirstChild(joint.Part)
		local motor = limb and limb:FindFirstChild(joint.Joint)
		if motor and motor:IsA("Motor6D") then
			if flying and not posed[motor] then
				posed[motor] = motor.C0
				motor.C0 = motor.C0 * joint.Rotation
			elseif not flying and posed[motor] then
				motor.C0 = posed[motor]
				posed[motor] = nil
			end
		end
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
