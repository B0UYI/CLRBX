--!strict
-- Défis personnels : chaque joueur en a toujours 3 actifs ; un défi réussi est remplacé.
-- Type : "Serve", "ServeVip", "ServeRecipe" (recette tirée au hasard, {recipe} dans le texte),
-- "Explode", "Drink", "Combo" (atteindre une série), "Party" (vivre une Fête des potions).

export type ChallengeDef = {
	Id: string,
	Type: string,
	Goal: number,
	Reward: number,
	Text: string,
	MinLevel: number?,
}

local Pool: { ChallengeDef } = {
	{ Id = "serve5", Type = "Serve", Goal = 5, Reward = 40, Text = "Sers 5 potions" },
	{ Id = "serve12", Type = "Serve", Goal = 12, Reward = 100, Text = "Sers 12 potions" },
	{ Id = "vip", Type = "ServeVip", Goal = 1, Reward = 60, Text = "Sers un client VIP 👑", MinLevel = 2 },
	{ Id = "recipe", Type = "ServeRecipe", Goal = 2, Reward = 45, Text = "Sers 2 × {recipe}" },
	{ Id = "boom", Type = "Explode", Goal = 1, Reward = 25, Text = "Fais exploser le chaudron 💥" },
	{ Id = "drink", Type = "Drink", Goal = 2, Reward = 30, Text = "Bois 2 potions 🧪" },
	{ Id = "combo5", Type = "Combo", Goal = 5, Reward = 60, Text = "Atteins une série de 5 🔥" },
	{ Id = "party", Type = "Party", Goal = 1, Reward = 75, Text = "Vis une Fête des potions 🎉" },
}

local seen: { [string]: boolean } = {}
for _, def in Pool do
	assert(not seen[def.Id], `Défi en double : {def.Id}`)
	seen[def.Id] = true
end

return {
	ActiveCount = 3,
	ReplaceDelaySeconds = 2,
	Pool = Pool,
}
