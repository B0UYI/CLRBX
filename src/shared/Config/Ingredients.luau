--!strict
-- Ingrédients disponibles sur les étagères.
-- Ajouter un ingrédient = ajouter une ligne ici (l'étagère est créée automatiquement).

export type Ingredient = {
	Id: string,
	Name: string,
	Color: Color3,
}

local Ingredients: { Ingredient } = {
	{ Id = "champignon", Name = "Champignon lumineux", Color = Color3.fromRGB(90, 200, 255) },
	{ Id = "plume", Name = "Plume de phénix", Color = Color3.fromRGB(255, 120, 40) },
	{ Id = "oeil", Name = "Œil de crapaud", Color = Color3.fromRGB(240, 210, 60) },
	{ Id = "cristal", Name = "Cristal de lune", Color = Color3.fromRGB(200, 170, 255) },
	{ Id = "racine", Name = "Racine de mandragore", Color = Color3.fromRGB(140, 90, 50) },
	{ Id = "slime", Name = "Bave de slime", Color = Color3.fromRGB(120, 230, 80) },
}

local byId: { [string]: Ingredient } = {}
for _, ingredient in Ingredients do
	assert(byId[ingredient.Id] == nil, `Ingrédient en double : {ingredient.Id}`)
	byId[ingredient.Id] = ingredient
end

return {
	List = Ingredients,
	ById = byId,
}
