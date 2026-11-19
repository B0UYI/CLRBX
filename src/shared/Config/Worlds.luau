--!strict
-- Mondes : un parcours d'obstacles chacun, débloqué par le TOTAL de victoires gagnées.
-- Les parcours sont générés par WorldService (déterministes : toujours le même tracé).

export type World = {
	Id: string,
	Name: string,
	RequiredWins: number,
	-- Longueur du parcours (studs) et victoires à l'arrivée.
	Length: number,
	Wins: number,
	-- 0 = facile, 1 = très dur (plus de vides, de lave, de poutres étroites).
	Difficulty: number,
	FloorColor: Color3,
	FloorMaterial: Enum.Material,
	AccentColor: Color3,
	LavaColor: Color3,
	-- Ambiance appliquée côté joueur quand il est dans ce monde.
	SkyColor: Color3,
	ClockTime: number,
}

local List: { World } = {
	{
		Id = "prairie",
		Name = "Prairie",
		RequiredWins = 0,
		Length = 600,
		Wins = 5,
		Difficulty = 0.2,
		FloorColor = Color3.fromRGB(110, 200, 90),
		FloorMaterial = Enum.Material.Grass,
		AccentColor = Color3.fromRGB(255, 230, 90),
		LavaColor = Color3.fromRGB(255, 80, 40),
		SkyColor = Color3.fromRGB(199, 230, 255),
		ClockTime = 14,
	},
	{
		Id = "desert",
		Name = "Désert",
		RequiredWins = 100,
		Length = 1000,
		Wins = 20,
		Difficulty = 0.35,
		FloorColor = Color3.fromRGB(230, 200, 130),
		FloorMaterial = Enum.Material.Sand,
		AccentColor = Color3.fromRGB(220, 120, 60),
		LavaColor = Color3.fromRGB(255, 90, 30),
		SkyColor = Color3.fromRGB(255, 220, 170),
		ClockTime = 16,
	},
	{
		Id = "glace",
		Name = "Royaume de glace",
		RequiredWins = 1000,
		Length = 1500,
		Wins = 80,
		Difficulty = 0.5,
		FloorColor = Color3.fromRGB(200, 230, 255),
		FloorMaterial = Enum.Material.Ice,
		AccentColor = Color3.fromRGB(120, 200, 255),
		LavaColor = Color3.fromRGB(60, 120, 255),
		SkyColor = Color3.fromRGB(220, 240, 255),
		ClockTime = 10,
	},
	{
		Id = "volcan",
		Name = "Volcan",
		RequiredWins = 8000,
		Length = 2200,
		Wins = 300,
		Difficulty = 0.65,
		FloorColor = Color3.fromRGB(70, 60, 60),
		FloorMaterial = Enum.Material.Basalt,
		AccentColor = Color3.fromRGB(255, 120, 40),
		LavaColor = Color3.fromRGB(255, 60, 0),
		SkyColor = Color3.fromRGB(255, 170, 140),
		ClockTime = 18.5,
	},
	{
		Id = "espace",
		Name = "Espace",
		RequiredWins = 50000,
		Length = 3000,
		Wins = 1200,
		Difficulty = 0.8,
		FloorColor = Color3.fromRGB(60, 50, 110),
		FloorMaterial = Enum.Material.Metal,
		AccentColor = Color3.fromRGB(190, 120, 255),
		LavaColor = Color3.fromRGB(255, 60, 200),
		SkyColor = Color3.fromRGB(150, 120, 220),
		ClockTime = 0,
	},
}

local byId: { [string]: World } = {}
for _, world in List do
	assert(byId[world.Id] == nil, `Monde en double : {world.Id}`)
	byId[world.Id] = world
end

return {
	List = List,
	ById = byId,
}
