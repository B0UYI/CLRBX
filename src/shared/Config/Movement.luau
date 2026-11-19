--!strict
-- Vitesse de course : elle augmente avec la Vitesse accumulée (plus doucement que la Vitesse elle-même
-- pour rester jouable), plafonnée. Le limiteur permet de ralentir pour les sauts délicats.

local BASE_WALK_SPEED = 16
local MAX_WALK_SPEED = 1500
local SPEED_EXPONENT = 0.6

local function walkSpeedFor(speed: number): number
	return math.min(MAX_WALK_SPEED, BASE_WALK_SPEED + math.max(speed, 0) ^ SPEED_EXPONENT)
end

return {
	WalkSpeedFor = walkSpeedFor,
	-- Vitesse horizontale minimale (studs/s) pour compter comme « en train de courir ».
	MinMovingSpeed = 4,
	-- Limiteur de vitesse (fractions proposées au joueur, clic pour changer).
	LimiterSteps = { 1, 0.5, 0.25, 0.1 },
	-- Anti-triche : marge sur la distance parcourue entre deux contrôles du serveur.
	TeleportTolerance = 2.5,
}
