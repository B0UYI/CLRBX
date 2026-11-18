--!strict
-- Réglages d'équilibrage du prototype (semaine 1).

return {
	Cauldron = {
		MinIngredients = 2,
		MaxIngredients = 3,
		BrewSeconds = 3,
		-- Rayon (studs) touché par l'explosion d'une potion ratée.
		FailBlastRadius = 14,
	},

	Customers = {
		MaxWaiting = 3,
		SpawnIntervalSeconds = 8,
		PatienceSeconds = 60,
		-- Pourboire max (en part de la valeur) si servi instantanément.
		TipMax = 0.5,
		WalkTimeoutSeconds = 8,
	},

	Interaction = {
		MaxDistance = 9,
	},

	Currency = {
		Name = "Pièces",
	},
}
