--!strict
-- Réglages généraux de « Course Céleste » (nom provisoire).

return {
	GameName = "Course Céleste",

	Lobby = {
		Spawn = Vector3.new(0, 5, 0),
	},

	-- Orbes de vitesse qui flottent dans le ciel du lobby : on les attrape en volant.
	Orbs = {
		Count = 30,
		Gain = 20,
		RespawnSeconds = 8,
		CollectRadius = 7,
		AreaMin = Vector3.new(-160, 15, -160),
		AreaMax = Vector3.new(160, 90, 160),
	},

	-- Produit Robux « Turbo » : gains de Vitesse multipliés pendant un temps.
	Turbo = {
		Multiplier = 3,
		DurationSeconds = 600,
	},

	-- Retour quotidien : cadeau de connexion (série de jours) et défi du jour (courses).
	Daily = {
		LoginRewards = { 5, 10, 15, 20, 30, 40, 60 },
		RaceGoal = 5,
		RaceReward = 50,
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
