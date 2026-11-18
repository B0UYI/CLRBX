--!strict
-- Articles achetables avec les pièces (sauvegardés) : Armoire du sorcier et stand Déco.

export type Upgrade = {
	Id: string,
	Name: string,
	Description: string,
	Price: number,
	-- "Basket" (taille du panier), "WalkSpeed", "TipBonus" (+x % de pourboire), "Title" (titre au-dessus de la tête)
	-- "Basket", "WalkSpeed", "TipBonus", "Title", "Decor" (Value = id de décoration, voir DecorService)
	Kind: string,
	Value: any,
	Color: Color3,
	-- Stand où l'article est vendu : nil = Armoire du sorcier, "Deco" = stand de décoration.
	Station: string?,
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

	-- Décorations : visibles par TOUT le serveur tant que leur propriétaire est présent.
	{
		Id = "decoLanternes",
		Station = "Deco",
		Name = "Lanternes magiques",
		Description = "Des lanternes flottantes",
		Price = 300,
		Kind = "Decor",
		Value = "lanternes",
		Color = Color3.fromRGB(255, 200, 120),
	},
	{
		Id = "decoTapis",
		Station = "Deco",
		Name = "Tapis royal",
		Description = "Un tapis rouge pour les clients",
		Price = 400,
		Kind = "Decor",
		Value = "tapis",
		Color = Color3.fromRGB(200, 40, 60),
	},
	{
		Id = "decoBannieres",
		Station = "Deco",
		Name = "Bannières dorées",
		Description = "La classe au mur du fond",
		Price = 600,
		Kind = "Decor",
		Value = "bannieres",
		Color = Color3.fromRGB(255, 200, 60),
	},
	{
		Id = "decoFontaine",
		Station = "Deco",
		Name = "Fontaine à potions",
		Description = "Une fontaine arc-en-ciel",
		Price = 900,
		Kind = "Decor",
		Value = "fontaine",
		Color = Color3.fromRGB(90, 220, 255),
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
