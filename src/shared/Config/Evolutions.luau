--!strict
-- Évolutions du personnage : chaque forme multiplie les gains de Vitesse.
-- Pour évoluer : atteindre le niveau demandé ET payer les victoires indiquées.
-- Chaque forme a son LOOK (effets construits côté joueurs par FormFxController) :
--   Glow    : lueur colorée autour du corps
--   Wind    : filets de vent qui fouettent le corps
--   Jets    : réacteurs de flammes aux pieds (plus forts en vol)
--   Sparks  : arcs électriques qui crépitent autour du corps
--   Orbs    : nombre de sphères en orbite (avec traînée)
--   Halo    : anneau lumineux au-dessus de la tête (Crown = couronne d'étoiles)
--   Tail    : longue queue de comète derrière soi
--   Wings   : ailes d'énergie dans le dos (taille)
--   Stars   : poussière d'étoiles

export type Look = {
	Glow: boolean?,
	Wind: boolean?,
	Jets: boolean?,
	Sparks: boolean?,
	Orbs: number?,
	Halo: boolean?,
	Crown: boolean?,
	Tail: boolean?,
	Wings: number?,
	Stars: boolean?,
}

export type Form = {
	Index: number,
	Name: string,
	Multiplier: number,
	Level: number,
	Wins: number,
	Color: Color3,
	-- Seconde couleur des effets (dégradés).
	Accent: Color3,
	-- Résumé du look affiché dans la fenêtre « Évoluer ».
	LookText: string,
	Look: Look,
}

local forms: { Form } = {
	{
		Index = 1,
		Name = "Débutant",
		Multiplier = 1,
		Level = 1,
		Wins = 0,
		Color = Color3.fromRGB(255, 255, 255),
		Accent = Color3.fromRGB(255, 255, 255),
		LookText = "Aucun effet",
		Look = {},
	},
	{
		Index = 2,
		Name = "Sprinteur",
		Multiplier = 1.1,
		Level = 5,
		Wins = 5,
		Color = Color3.fromRGB(120, 220, 255),
		Accent = Color3.fromRGB(230, 250, 255),
		LookText = "Filets de vent",
		Look = { Glow = true, Wind = true },
	},
	{
		Index = 3,
		Name = "Fusée",
		Multiplier = 1.25,
		Level = 12,
		Wins = 30,
		Color = Color3.fromRGB(255, 140, 60),
		Accent = Color3.fromRGB(255, 230, 120),
		LookText = "Réacteurs de flammes aux pieds",
		Look = { Glow = true, Wind = true, Jets = true },
	},
	{
		Index = 4,
		Name = "Éclair",
		Multiplier = 1.5,
		Level = 20,
		Wins = 150,
		Color = Color3.fromRGB(255, 240, 80),
		Accent = Color3.fromRGB(140, 220, 255),
		LookText = "Arcs électriques + 2 orbes",
		Look = { Glow = true, Sparks = true, Orbs = 2 },
	},
	{
		Index = 5,
		Name = "Comète",
		Multiplier = 2,
		Level = 30,
		Wins = 800,
		Color = Color3.fromRGB(150, 200, 255),
		Accent = Color3.fromRGB(255, 255, 255),
		LookText = "Queue de comète, halo, 3 orbes",
		Look = { Glow = true, Tail = true, Halo = true, Orbs = 3 },
	},
	{
		Index = 6,
		Name = "Météore",
		Multiplier = 3,
		Level = 45,
		Wins = 5000,
		Color = Color3.fromRGB(255, 90, 40),
		Accent = Color3.fromRGB(255, 210, 80),
		LookText = "Corps en feu, réacteurs, 4 roches en orbite",
		Look = { Glow = true, Jets = true, Tail = true, Halo = true, Orbs = 4 },
	},
	{
		Index = 7,
		Name = "Supernova",
		Multiplier = 5,
		Level = 65,
		Wins = 40000,
		Color = Color3.fromRGB(255, 120, 220),
		Accent = Color3.fromRGB(255, 240, 160),
		LookText = "Ailes d'énergie, poussière d'étoiles, 5 orbes",
		Look = { Glow = true, Wings = 1, Halo = true, Orbs = 5, Stars = true, Sparks = true },
	},
	{
		Index = 8,
		Name = "Légende cosmique",
		Multiplier = 8,
		Level = 90,
		Wins = 300000,
		Color = Color3.fromRGB(170, 90, 255),
		Accent = Color3.fromRGB(90, 220, 255),
		LookText = "Grandes ailes, couronne d'étoiles, galaxie en orbite",
		Look = {
			Glow = true,
			Wings = 1.5,
			Crown = true,
			Orbs = 6,
			Stars = true,
			Sparks = true,
			Tail = true,
		},
	},
}

return {
	Forms = forms,
}
