--!strict
-- Évolutions du personnage : chaque forme multiplie les gains de Vitesse.
-- Pour évoluer : atteindre le niveau demandé ET payer les victoires indiquées.

export type Form = {
	Index: number,
	Name: string,
	Multiplier: number,
	Level: number,
	Wins: number,
	Color: Color3,
	-- Particules autour du personnage à partir de cette forme.
	Particles: boolean,
}

local RAW = {
	{ "Débutant", 1, 1, 0, Color3.fromRGB(255, 255, 255), false },
	{ "Sprinteur", 1.1, 5, 5, Color3.fromRGB(120, 220, 255), false },
	{ "Fusée", 1.25, 12, 30, Color3.fromRGB(255, 140, 60), false },
	{ "Éclair", 1.5, 20, 150, Color3.fromRGB(255, 240, 80), true },
	{ "Comète", 2, 30, 800, Color3.fromRGB(150, 200, 255), true },
	{ "Météore", 3, 45, 5000, Color3.fromRGB(255, 90, 40), true },
	{ "Supernova", 5, 65, 40000, Color3.fromRGB(255, 120, 220), true },
	{ "Légende cosmique", 8, 90, 300000, Color3.fromRGB(170, 90, 255), true },
}

local forms: { Form } = {}
for index, row in RAW do
	table.insert(forms, {
		Index = index,
		Name = row[1] :: string,
		Multiplier = row[2] :: number,
		Level = row[3] :: number,
		Wins = row[4] :: number,
		Color = row[5] :: Color3,
		Particles = row[6] :: boolean,
	})
end

return {
	Forms = forms,
}
