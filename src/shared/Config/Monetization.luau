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
	-- Pièces données (packs de pièces).
	Coins: number?,
}

local GamePasses: { Pass } = {
	{
		Key = "DoubleCoins",
		Id = 0,
		Name = "Pièces ×2",
		Description = "Double les pièces payées par les clients",
		Price = 249,
		Color = Color3.fromRGB(255, 210, 80),
	},
	{
		Key = "VIP",
		Id = 0,
		Name = "VIP",
		Description = "Titre 👑 VIP + 1 place dans le panier",
		Price = 399,
		Color = Color3.fromRGB(255, 150, 220),
	},
	{
		Key = "ExpressBrew",
		Id = 0,
		Name = "Chaudron express",
		Description = "Tes potions sont prêtes presque instantanément",
		Price = 199,
		Color = Color3.fromRGB(120, 220, 255),
	},
}

local Products: { Product } = {
	{
		Key = "PrankPotion",
		Id = 0,
		Name = "Potion farce",
		Description = "Transforme tout le serveur pendant 30 s ! (sauf les joueurs protégés)",
		Price = 49,
		Color = Color3.fromRGB(200, 120, 255),
	},
	{
		Key = "CoinsS",
		Id = 0,
		Name = "Sac de pièces",
		Description = "+500 pièces",
		Price = 99,
		Color = Color3.fromRGB(255, 220, 120),
		Coins = 500,
	},
	{
		Key = "CoinsM",
		Id = 0,
		Name = "Coffre de pièces",
		Description = "+1 600 pièces",
		Price = 249,
		Color = Color3.fromRGB(255, 200, 80),
		Coins = 1600,
	},
	{
		Key = "CoinsL",
		Id = 0,
		Name = "Trésor de pièces",
		Description = "+6 000 pièces",
		Price = 699,
		Color = Color3.fromRGB(255, 170, 40),
		Coins = 6000,
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
	ExpressBrewSeconds = 0.3,
	PrankDurationSeconds = 30,
	-- Nombre d'achats récents mémorisés par joueur pour éviter les doubles attributions.
	PurchaseIdCacheSize = 50,
}
