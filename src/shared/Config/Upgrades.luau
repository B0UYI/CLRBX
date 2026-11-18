--!strict
-- Améliorations achetables avec les pièces dans l'Armoire du sorcier (sauvegardées).

export type Upgrade = {
	Id: string,
	Name: string,
	Description: string,
	Price: number,
	-- "Basket" (taille du panier), "WalkSpeed", "TipBonus" (+x % de pourboire), "Title" (titre au-dessus de la tête)
	Kind: string,
	Value: any,
	Color: Color3,
}

local Upgrades: { Upgrade } = {
	{
		Id = "panierXL",
		Name = "Panier XL",
		Description = "Porte 5 ingrédients",
		Price = 150,
		Kind = "Basket",
		Value = 5,
		Color = Color3.fromRGB(200, 140, 80),
	},
	{
		Id = "bottes",
		Name = "Bottes de vitesse",
		Description = "Cours plus vite",
		Price = 250,
		Kind = "WalkSpeed",
		Value = 26,
		Color = Color3.fromRGB(80, 200, 255),
	},
	{
		Id = "charme",
		Name = "Charme du pourboire",
		Description = "Pourboires +50 %",
		Price = 400,
		Kind = "TipBonus",
		Value = 0.5,
		Color = Color3.fromRGB(255, 215, 90),
	},
	{
		Id = "titreAlchimiste",
		Name = "Titre : Alchimiste",
		Description = "Ton titre au-dessus de ta tête",
		Price = 600,
		Kind = "Title",
		Value = "⚗️ Alchimiste",
		Color = Color3.fromRGB(120, 255, 160),
	},
	{
		Id = "titreSorcier",
		Name = "Titre : Grand Sorcier",
		Description = "Le titre ultime !",
		Price = 2500,
		Kind = "Title",
		Value = "🧙 Grand Sorcier",
		Color = Color3.fromRGB(220, 120, 255),
	},
}

local byId: { [string]: Upgrade } = {}
for _, upgrade in Upgrades do
	assert(byId[upgrade.Id] == nil, `Amélioration en double : {upgrade.Id}`)
	byId[upgrade.Id] = upgrade
end

return {
	List = Upgrades,
	ById = byId,
	-- Titre de base de tous les joueurs.
	DefaultTitle = "🧪 Apprenti",
}
