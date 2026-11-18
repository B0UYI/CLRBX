--!strict
-- Recettes : une combinaison d'ingrédients (l'ordre ne compte pas) donne une potion.
-- Toute combinaison absente de cette liste donne une potion ratée (explosion !).

local Ingredients = require(script.Parent.Ingredients)

export type Recipe = {
	Id: string,
	Name: string,
	Ingredients: { string },
	Color: Color3,
	Effect: string,
	-- Pièces payées par un client satisfait (hors pourboire).
	Value: number,
	-- Niveau de boutique requis pour que les clients la commandent.
	Level: number,
	-- Recette secrète : absente du grimoire tant qu'elle n'a pas été découverte.
	Secret: boolean?,
}

local Recipes: { Recipe } = {
	{
		Id = "geant",
		Level = 1,
		Name = "Potion de Géant",
		Ingredients = { "racine", "cristal" },
		Color = Color3.fromRGB(170, 120, 220),
		Effect = "Giant",
		Value = 15,
	},
	{
		Id = "mini",
		Level = 1,
		Name = "Potion Minuscule",
		Ingredients = { "champignon", "oeil" },
		Color = Color3.fromRGB(150, 220, 160),
		Effect = "Mini",
		Value = 15,
	},
	{
		Id = "plume",
		Level = 1,
		Name = "Potion Plume",
		Ingredients = { "plume", "slime" },
		Color = Color3.fromRGB(230, 240, 255),
		Effect = "Float",
		Value = 15,
	},
	{
		Id = "eclair",
		Level = 2,
		Name = "Potion Éclair",
		Ingredients = { "plume", "racine" },
		Color = Color3.fromRGB(255, 230, 50),
		Effect = "Speed",
		Value = 15,
	},
	{
		Id = "feu",
		Level = 3,
		Name = "Potion de Feu",
		Ingredients = { "racine", "slime" },
		Color = Color3.fromRGB(255, 70, 30),
		Effect = "Fire",
		Value = 20,
	},
	{
		Id = "arcenciel",
		Level = 4,
		Name = "Potion Arc-en-ciel",
		Ingredients = { "champignon", "cristal", "plume" },
		Color = Color3.fromRGB(255, 100, 200),
		Effect = "Rainbow",
		Value = 30,
	},
	{
		Id = "fantome",
		Level = 5,
		Name = "Potion Fantôme",
		Ingredients = { "cristal", "oeil", "slime" },
		Color = Color3.fromRGB(200, 230, 240),
		Effect = "Ghost",
		Value = 30,
	},

	-- Recettes secrètes : à découvrir en expérimentant (indice : « insister »).
	{
		Id = "ballon",
		Name = "Potion Ballon",
		Level = 1,
		Secret = true,
		Ingredients = { "plume", "plume", "plume" },
		Color = Color3.fromRGB(255, 160, 220),
		Effect = "Balloon",
		Value = 40,
	},
	{
		Id = "disco",
		Name = "Potion Disco",
		Level = 1,
		Secret = true,
		Ingredients = { "champignon", "champignon", "champignon" },
		Color = Color3.fromRGB(120, 255, 255),
		Effect = "Disco",
		Value = 40,
	},
	{
		Id = "turbofantome",
		Name = "Potion Turbo-Fantôme",
		Level = 1,
		Secret = true,
		Ingredients = { "slime", "slime", "slime" },
		Color = Color3.fromRGB(180, 255, 200),
		Effect = "TurboGhost",
		Value = 40,
	},
}

-- Clé unique d'une combinaison : ids triés, joints par "+".
local function keyOf(ingredientIds: { string }): string
	local sorted = table.clone(ingredientIds)
	table.sort(sorted)
	return table.concat(sorted, "+")
end

local byKey: { [string]: Recipe } = {}
local byId: { [string]: Recipe } = {}
for _, recipe in Recipes do
	for _, ingredientId in recipe.Ingredients do
		assert(Ingredients.ById[ingredientId], `Recette {recipe.Id} : ingrédient inconnu {ingredientId}`)
	end
	local key = keyOf(recipe.Ingredients)
	assert(byKey[key] == nil, `Deux recettes ont la même combinaison : {key}`)
	assert(byId[recipe.Id] == nil, `Recette en double : {recipe.Id}`)
	byKey[key] = recipe
	byId[recipe.Id] = recipe
end

return {
	List = Recipes,
	ById = byId,
	-- Renvoie la recette correspondant aux ingrédients, ou nil (potion ratée).
	Find = function(ingredientIds: { string }): Recipe?
		return byKey[keyOf(ingredientIds)]
	end,
}
