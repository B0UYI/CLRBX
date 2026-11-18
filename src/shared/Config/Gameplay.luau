--!strict
-- Réglages d'équilibrage du prototype (semaine 1).

return {
	Cauldron = {
		MinIngredients = 2,
		MaxIngredients = 3,
		BrewSeconds = 1.5,
		-- Rayon (studs) touché par l'explosion d'une potion ratée.
		FailBlastRadius = 14,
	},

	Player = {
		-- Vitesse de marche (Roblox par défaut : 16).
		WalkSpeed = 20,
		-- Ingrédients transportables à la fois dans le panier.
		BasketSize = 3,
	},

	Customers = {
		-- Afficher les ingrédients de la commande dans la bulle du client.
		ShowRecipeHint = true,
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
