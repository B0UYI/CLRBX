--!strict
-- Déplacement à pied : vitesse FIXE (celle de Roblox). Seul le vol profite de la progression.

local BASE_WALK_SPEED = 16

return {
	BaseWalkSpeed = BASE_WALK_SPEED,
	-- Gardé pour l'anti-triche : la vitesse au sol ne dépend pas de la Vitesse.
	WalkSpeedFor = function(_speed: number): number
		return BASE_WALK_SPEED
	end,
	-- Vitesse horizontale minimale (studs/s) pour compter comme « en mouvement ».
	MinMovingSpeed = 4,
	-- Anti-triche : marge sur la distance parcourue entre deux contrôles du serveur.
	TeleportTolerance = 2.5,
}
