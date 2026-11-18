--!strict
-- Effets de potion appliqués aux avatars (joueurs et clients PNJ).

export type EffectId = "Giant" | "Mini" | "Float" | "Speed" | "Fire" | "Rainbow" | "Ghost"

return {
	-- Durée d'un effet, en secondes.
	Duration = 20,

	Giant = { Name = "Géant", Scale = 2 },
	Mini = { Name = "Minuscule", Scale = 0.5 },
	-- Part de la gravité annulée (0.85 = on flotte presque).
	Float = { Name = "Plume", GravityCancel = 0.85 },
	Speed = { Name = "Éclair", WalkSpeedMultiplier = 2 },
	Fire = { Name = "Feu", WalkSpeedMultiplier = 1.25 },
	Rainbow = { Name = "Arc-en-ciel", CycleSeconds = 2 },
	Ghost = { Name = "Fantôme", Transparency = 0.75 },

	-- Effets tirés au hasard quand une potion est ratée.
	FailPool = { "Giant", "Mini", "Float", "Rainbow", "Ghost" } :: { EffectId },
}
