--!strict
-- Effets de potion appliqués aux avatars (joueurs et clients PNJ).

export type EffectId =
	"Giant"
	| "Mini"
	| "Float"
	| "Speed"
	| "Fire"
	| "Rainbow"
	| "Ghost"
	| "Balloon"
	| "Disco"
	| "TurboGhost"

-- Chaque effet combine librement : Scale, WalkSpeedMultiplier, GravityCancel, Fire, CycleSeconds, Transparency.

return {
	-- Durée d'un effet, en secondes.
	Duration = 20,

	Giant = { Name = "Géant", Scale = 2 },
	Mini = { Name = "Minuscule", Scale = 0.5 },
	-- Part de la gravité annulée (0.85 = on flotte presque).
	Float = { Name = "Plume", GravityCancel = 0.85 },
	Speed = { Name = "Éclair", WalkSpeedMultiplier = 2 },
	Fire = { Name = "Feu", WalkSpeedMultiplier = 1.25, Fire = true },
	Rainbow = { Name = "Arc-en-ciel", CycleSeconds = 2 },
	Ghost = { Name = "Fantôme", Transparency = 0.75 },

	-- Effets des recettes secrètes (combinaisons).
	Balloon = { Name = "Ballon", Scale = 1.6, GravityCancel = 0.97 },
	Disco = { Name = "Disco", Scale = 0.6, CycleSeconds = 0.4 },
	TurboGhost = { Name = "Turbo-Fantôme", Transparency = 0.75, WalkSpeedMultiplier = 2.5 },

	-- Effets tirés au hasard quand une potion est ratée.
	FailPool = { "Giant", "Mini", "Float", "Rainbow", "Ghost" } :: { EffectId },

	-- Effets distribués à tout le monde pendant la Fête des potions.
	PartyPool = { "Giant", "Mini", "Float", "Rainbow", "Balloon", "Disco" } :: { EffectId },
}
