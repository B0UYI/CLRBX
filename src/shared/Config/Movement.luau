--!strict
-- « +1 Vitesse » : chaque seconde de course rapporte de la Vitesse (× multiplicateurs),
-- et la Vitesse EST la vitesse de course : vitesse de marche = 16 + Vitesse (plafonnée).

local BASE_WALK_SPEED = 16
local MAX_WALK_SPEED = 1500

local function walkSpeedFor(speed: number): number
	return math.min(MAX_WALK_SPEED, BASE_WALK_SPEED + math.max(speed, 0))
end

return {
	WalkSpeedFor = walkSpeedFor,
	-- Vitesse gagnée par seconde de course (avant multiplicateurs).
	RunGainPerSecond = 1,
	-- Vitesse horizontale minimale (studs/s) pour compter comme « en train de courir ».
	MinMovingSpeed = 4,
	-- Limiteur de vitesse (fractions proposées au joueur, clic pour changer).
	LimiterSteps = { 1, 0.5, 0.25, 0.1 },
	-- Anti-triche : marge sur la distance parcourue entre deux contrôles du serveur.
	TeleportTolerance = 2.5,
}
