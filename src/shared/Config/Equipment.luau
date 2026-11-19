--!strict
-- Équipement acheté avec les Victoires : 3 emplacements (traînée, cape, aura).
-- La meilleure pièce de chaque emplacement est portée automatiquement ;
-- les multiplicateurs des 3 emplacements se MULTIPLIENT entre eux (ex. ×1,5 × ×2 × ×2 = ×6).

export type Slot = "Trail" | "Cape" | "Aura"

export type Item = {
	Id: string,
	Slot: Slot,
	Name: string,
	Multiplier: number,
	Price: number,
	Color: Color3,
	-- Couleurs arc-en-ciel.
	Rainbow: boolean?,
	-- Étincelles (capes).
	Sparkles: boolean?,
}

local Slots: { { Slot: Slot, Name: string } } = {
	{ Slot = "Trail", Name = "✨ Traînées" },
	{ Slot = "Cape", Name = "🦸 Capes" },
	{ Slot = "Aura", Name = "🌟 Auras" },
}

local List: { Item } = {
	-- Traînées
	{
		Id = "trail_bleue",
		Slot = "Trail",
		Name = "Traînée bleue",
		Multiplier = 1.25,
		Price = 15,
		Color = Color3.fromRGB(80, 170, 255),
	},
	{
		Id = "trail_feu",
		Slot = "Trail",
		Name = "Traînée de feu",
		Multiplier = 1.5,
		Price = 60,
		Color = Color3.fromRGB(255, 120, 40),
	},
	{
		Id = "trail_arcenciel",
		Slot = "Trail",
		Name = "Traînée arc-en-ciel",
		Multiplier = 2,
		Price = 250,
		Color = Color3.fromRGB(255, 120, 200),
		Rainbow = true,
	},
	{
		Id = "trail_eclair",
		Slot = "Trail",
		Name = "Traînée éclair",
		Multiplier = 3,
		Price = 3000,
		Color = Color3.fromRGB(255, 240, 80),
	},
	-- Capes
	{
		Id = "cape_rouge",
		Slot = "Cape",
		Name = "Cape rouge",
		Multiplier = 1.5,
		Price = 40,
		Color = Color3.fromRGB(220, 40, 40),
	},
	{
		Id = "cape_bleue",
		Slot = "Cape",
		Name = "Cape bleue",
		Multiplier = 2,
		Price = 150,
		Color = Color3.fromRGB(40, 110, 230),
	},
	{
		Id = "cape_or",
		Slot = "Cape",
		Name = "Cape d'or",
		Multiplier = 3,
		Price = 1500,
		Color = Color3.fromRGB(255, 200, 50),
	},
	{
		Id = "cape_cosmique",
		Slot = "Cape",
		Name = "Cape cosmique",
		Multiplier = 5,
		Price = 15000,
		Color = Color3.fromRGB(140, 60, 255),
		Sparkles = true,
	},
	-- Auras
	{
		Id = "aura_etoiles",
		Slot = "Aura",
		Name = "Aura étoilée",
		Multiplier = 2,
		Price = 300,
		Color = Color3.fromRGB(255, 255, 200),
	},
	{
		Id = "aura_feu",
		Slot = "Aura",
		Name = "Aura de feu",
		Multiplier = 3,
		Price = 5000,
		Color = Color3.fromRGB(255, 110, 30),
	},
	{
		Id = "aura_cosmique",
		Slot = "Aura",
		Name = "Aura cosmique",
		Multiplier = 5,
		Price = 40000,
		Color = Color3.fromRGB(170, 90, 255),
		Rainbow = true,
	},
}

local byId: { [string]: Item } = {}
for _, item in List do
	assert(byId[item.Id] == nil, `Équipement en double : {item.Id}`)
	byId[item.Id] = item
end

return {
	Slots = Slots,
	List = List,
	ById = byId,
}
