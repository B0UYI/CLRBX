--!strict
-- Achats Robux. Les Id se créent sur Roblox APRÈS publication :
-- Creator Hub → ton jeu → Monétisation → Passes / Produits de développeur.
-- Id = 0 : pas encore créé → l'article s'affiche « Bientôt » et ne peut pas être acheté.
-- Price = prix indicatif (le vrai prix est lu sur Roblox quand l'Id existe).

export type Pass = {
	Key: string,
	Id: number,
	Name: string,
	Description: string,
	Price: number,
	Color: Color3,
}

export type Product = {
	Key: string,
	Id: number,
	Name: string,
	Description: string,
	Price: number,
	Color: Color3,
	-- Victoires données (packs de victoires).
	Wins: number?,
}

local GamePasses: { Pass } = {
	{
		Key = "SpeedX2",
		Id = 0,
		Name = "Vitesse ×2",
		Description = "Double tous tes gains de vitesse",
		Price = 199,
		Color = Color3.fromRGB(255, 210, 80),
	},
	{
		Key = "WinsX2",
		Id = 0,
		Name = "Victoires ×2",
		Description = "Double les victoires gagnées en course",
		Price = 299,
		Color = Color3.fromRGB(120, 220, 255),
	},
}

local Products: { Product } = {
	{
		Key = "Turbo",
		Id = 0,
		Name = "Turbo ×3",
		Description = "Gains de vitesse ×3 pendant 10 minutes",
		Price = 49,
		Color = Color3.fromRGB(255, 120, 60),
	},
	{
		Key = "Wins100",
		Id = 0,
		Name = "Sac de victoires",
		Description = "+100 🏆",
		Price = 99,
		Color = Color3.fromRGB(255, 220, 120),
		Wins = 100,
	},
	{
		Key = "Wins1000",
		Id = 0,
		Name = "Coffre de victoires",
		Description = "+1 000 🏆",
		Price = 499,
		Color = Color3.fromRGB(255, 170, 40),
		Wins = 1000,
	},
}

local passById: { [number]: Pass } = {}
local productById: { [number]: Product } = {}
local keys: { [string]: boolean } = {}
for _, pass in GamePasses do
	assert(not keys[pass.Key], `Clé en double : {pass.Key}`)
	keys[pass.Key] = true
	if pass.Id > 0 then
		assert(not passById[pass.Id], `Id de pass en double : {pass.Id}`)
		passById[pass.Id] = pass
	end
end
for _, product in Products do
	assert(not keys[product.Key], `Clé en double : {product.Key}`)
	keys[product.Key] = true
	if product.Id > 0 then
		assert(not productById[product.Id], `Id de produit en double : {product.Id}`)
		productById[product.Id] = product
	end
end

return {
	GamePasses = GamePasses,
	Products = Products,
	PassById = passById,
	ProductById = productById,
	-- Nombre d'achats récents mémorisés par joueur pour éviter les doubles attributions.
	PurchaseIdCacheSize = 50,
}
