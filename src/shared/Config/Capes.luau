--!strict
-- Capes achetées avec les Victoires : elles multiplient TOUS les gains de Vitesse.
-- La meilleure cape possédée est portée automatiquement.

export type Cape = {
	Id: string,
	Name: string,
	Multiplier: number,
	Price: number,
	Color: Color3,
	Material: Enum.Material,
	-- Couleurs qui défilent (cape arc-en-ciel).
	Rainbow: boolean?,
	-- Étincelles autour de la cape.
	Sparkles: boolean?,
}

local List: { Cape } = {
	{
		Id = "rouge",
		Name = "Cape rouge",
		Multiplier = 1.5,
		Price = 25,
		Color = Color3.fromRGB(220, 40, 40),
		Material = Enum.Material.Fabric,
	},
	{
		Id = "bleue",
		Name = "Cape bleue",
		Multiplier = 2,
		Price = 100,
		Color = Color3.fromRGB(40, 110, 230),
		Material = Enum.Material.Fabric,
	},
	{
		Id = "verte",
		Name = "Cape verte",
		Multiplier = 3,
		Price = 400,
		Color = Color3.fromRGB(40, 190, 90),
		Material = Enum.Material.Fabric,
	},
	{
		Id = "or",
		Name = "Cape d'or",
		Multiplier = 5,
		Price = 1500,
		Color = Color3.fromRGB(255, 200, 50),
		Material = Enum.Material.Foil,
	},
	{
		Id = "arcenciel",
		Name = "Cape arc-en-ciel",
		Multiplier = 8,
		Price = 6000,
		Color = Color3.fromRGB(255, 120, 200),
		Material = Enum.Material.Neon,
		Rainbow = true,
	},
	{
		Id = "cosmique",
		Name = "Cape cosmique",
		Multiplier = 15,
		Price = 25000,
		Color = Color3.fromRGB(140, 60, 255),
		Material = Enum.Material.Neon,
		Sparkles = true,
	},
}

local byId: { [string]: Cape } = {}
for _, cape in List do
	assert(byId[cape.Id] == nil, `Cape en double : {cape.Id}`)
	byId[cape.Id] = cape
end

return {
	List = List,
	ById = byId,
}
