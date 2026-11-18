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
		-- Temps pendant lequel le client montre l'effet de la potion avant de partir.
		ReactionSeconds = 4,
	},

	-- Progression partagée de la boutique (tous les joueurs du serveur).
	Progression = {
		-- XP cumulée pour atteindre chaque niveau (index = niveau).
		LevelXp = { 0, 5, 12, 22, 35, 50, 70, 95, 125, 160 },
		XpPerServe = 1,
		XpPerVipServe = 2,
	},

	-- Série de bonnes potions d'affilée : multiplicateur de gains.
	Combo = {
		Tiers = {
			{ Count = 3, Multiplier = 1.5 },
			{ Count = 6, Multiplier = 2 },
			{ Count = 10, Multiplier = 3 },
		},
	},

	-- Clients spéciaux.
	Specials = {
		VipMinLevel = 2,
		VipChance = 0.12,
		VipPatienceSeconds = 75,
		VipPayMultiplier = 3,
		HurryChance = 0.15,
		HurryPatienceSeconds = 25,
		HurryPayMultiplier = 1.5,
	},

	-- Le Grand Chaudron : événement collectif périodique.
	GrandCauldron = {
		FirstDelaySeconds = 90,
		IntervalSeconds = 240,
		DurationSeconds = 60,
		GoalBase = 4,
		GoalPerPlayer = 2,
		RushSpawnIntervalSeconds = 2.5,
		PayMultiplier = 2,
		PartyCoinsPerLevel = 25,
		PartySeconds = 6,
	},

	-- Asperger un autre joueur avec une potion (touche R).
	Splash = {
		MaxDistance = 14,
		ThrowCooldownSeconds = 2,
		-- Un même joueur ne peut pas être aspergé plus souvent que ça (anti-harcèlement).
		TargetCooldownSeconds = 8,
		ToggleCooldownSeconds = 1,
	},

	-- Retour quotidien : cadeau de connexion (série de jours) et défi du jour.
	Daily = {
		-- Pièces données le 1er, 2e, … jour d'affilée (le dernier se répète ensuite).
		LoginRewards = { 50, 75, 100, 125, 150, 200, 300 },
		ServeGoal = 25,
		ServeReward = 250,
		GiftDelaySeconds = 3,
	},

	Discovery = {
		BonusCoins = 50,
	},

	Interaction = {
		MaxDistance = 9,
	},

	Currency = {
		Name = "Pièces",
	},
}
