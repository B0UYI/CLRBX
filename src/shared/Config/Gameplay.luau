--!strict
-- Réglages généraux de « Obby Turbo » (nom provisoire).

return {
	GameName = "Obby Turbo",

	Lobby = {
		Spawn = Vector3.new(0, 5, 0),
		-- Terrain de vol libre au nord du lobby (centre au sol, taille X × hauteur × Z) :
		-- îles flottantes, aiguilles, arches ; on y vole sans consommer d'endurance.
		Playground = {
			Center = Vector3.new(0, 0, -480),
			Size = Vector3.new(760, 420, 760),
		},
	},

	-- Produit Robux « Turbo » : gains de Vitesse multipliés pendant un temps.
	Turbo = {
		Multiplier = 3,
		DurationSeconds = 600,
	},

	-- Retour quotidien : cadeau de connexion (série de jours) et défi du jour (parcours terminés).
	Daily = {
		LoginRewards = { 5, 10, 15, 20, 30, 40, 60 },
		FinishGoal = 5,
		FinishReward = 40,
		GiftDelaySeconds = 3,
	},

	Interaction = {
		MaxDistance = 10,
	},

	Stats = {
		SpeedName = "⚡ Vitesse",
		WinsName = "🏆 Victoires",
	},
}
