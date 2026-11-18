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
}

local Recipes: { Recipe } = {
	{
		Id = "geant",
		Name = "Potion de Géant",
		Ingredients = { "racine", "cristal" },
		Color = Color3.fromRGB(170, 120, 220),
		Effect = "Giant",
		Value = 15,
	},
	{
		Id = "mini",
		Name = "Potion Minuscule",
		Ingredients = { "champignon", "oeil" },
		Color = Color3.fromRGB(150, 220, 160),
		Effect = "Mini",
		Value = 15,
	},
	{
		Id = "plume",
		Name = "Potion Plume",
		Ingredients = { "plume", "slime" },
		Color = Color3.fromRGB(230, 240, 255),
		Effect = "Float",
		Value = 15,
	},
	{
		Id = "eclair",
		Name = "Potion Éclair",
		Ingredients = { "plume", "racine" },
		Color = Color3.fromRGB(255, 230, 50),
		Effect = "Speed",
		Value = 15,
	},
	{
		Id = "feu",
		Name = "Potion de Feu",
		Ingredients = { "racine", "slime" },
		Color = Color3.fromRGB(255, 70, 30),
		Effect = "Fire",
		Value = 20,
	},
	{
		Id = "arcenciel",
		Name = "Potion Arc-en-ciel",
		Ingredients = { "champignon", "cristal", "plume" },
		Color = Color3.fromRGB(255, 100, 200),
		Effect = "Rainbow",
		Value = 30,
	},
	{
		Id = "fantome",
		Name = "Potion Fantôme",
		Ingredients = { "cristal", "oeil", "slime" },
		Color = Color3.fromRGB(200, 230, 240),
		Effect = "Ghost",
		Value = 30,
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
