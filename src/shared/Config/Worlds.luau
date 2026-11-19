--!strict
-- Mondes : 10 étapes chacun, débloqués par le TOTAL de victoires gagnées.
-- Étape k : vitesse requise = SpeedStart × SpeedGrowth^(k-2) (aucune pour l'étape 1),
-- victoires = StageWins × 1,4^(k-1), obstacles et créatures de plus en plus nombreux.
-- Les parcours sont générés par WorldService (déterministes : toujours le même tracé).

export type World = {
	Id: string,
	Name: string,
	RequiredWins: number,
	-- Longueur d'une étape (studs), victoires de l'étape 1, vitesse requise à l'étape 2 et croissance.
	StageLength: number,
	StageWins: number,
	SpeedStart: number,
	SpeedGrowth: number,
	-- Difficulté de l'étape 1 (0 = facile, 1 = très dur) ; elle monte de +0,3 jusqu'à l'étape 10.
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
		StageLength = 60,
		StageWins = 1,
		SpeedStart = 10,
		SpeedGrowth = 1.8,
		Difficulty = 0.0,
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
		StageLength = 80,
		StageWins = 8,
		SpeedStart = 1500,
		SpeedGrowth = 1.6,
		Difficulty = 0.3,
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
		StageLength = 100,
		StageWins = 60,
		SpeedStart = 80000,
		SpeedGrowth = 1.5,
		Difficulty = 0.45,
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
		StageLength = 120,
		StageWins = 400,
		SpeedStart = 3000000,
		SpeedGrowth = 1.5,
		Difficulty = 0.55,
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
		StageLength = 140,
		StageWins = 2500,
		SpeedStart = 100000000,
		SpeedGrowth = 1.5,
		Difficulty = 0.65,
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

local STAGE_COUNT = 10
local STAGE_WINS_GROWTH = 1.4

-- Vitesse requise pour entrer dans l'étape (0 pour l'étape 1).
local function requiredSpeed(world: World, stage: number): number
	if stage <= 1 then
		return 0
	end
	return math.floor(world.SpeedStart * world.SpeedGrowth ^ (stage - 2))
end

local function stageWins(world: World, stage: number): number
	return math.max(1, math.floor(world.StageWins * STAGE_WINS_GROWTH ^ (stage - 1)))
end

return {
	List = List,
	ById = byId,
	StageCount = STAGE_COUNT,
	RequiredSpeed = requiredSpeed,
	StageWins = stageWins,
}
