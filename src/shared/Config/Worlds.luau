--!strict
-- Mondes aériens : 10 étapes chacun (vol continu d'une plateforme à la suivante),
-- débloqués par le TOTAL de victoires gagnées.
-- Étape k : longueur = StageLength × LengthGrowth^(k-1) (plus d'endurance nécessaire),
-- victoires = StageWins × 1,4^(k-1), obstacles de plus en plus serrés.
-- Les parcours sont générés par WorldService (déterministes : toujours le même tracé).

export type World = {
	Id: string,
	Name: string,
	-- Décor et obstacles du parcours aérien : "ciel", "ville", "glace", "volcan", "espace".
	Biome: string,
	RequiredWins: number,
	-- Longueur de vol de l'étape 1 (studs) et croissance par étape (chaque étape demande plus d'endurance).
	StageLength: number,
	LengthGrowth: number,
	-- Vitesse de vol de référence pour estimer l'endurance conseillée.
	ReferenceFlySpeed: number,
	-- Atmosphère : multiplicateur de consommation d'endurance dans ce monde.
	StaminaDrain: number,
	-- Barrières de vent (mur du son + élan) : mécanique réservée à de futurs mondes.
	WindRings: boolean?,
	-- Victoires de l'étape 1.
	StageWins: number,
	-- Difficulté de l'étape 1 (0 à 1) ; elle monte de +0,3 jusqu'à l'étape 10.
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
		Name = "Ciel",
		Biome = "ciel",
		RequiredWins = 0,
		StageLength = 100,
		LengthGrowth = 1.18,
		ReferenceFlySpeed = 45,
		StaminaDrain = 1,
		StageWins = 1,
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
		Name = "Ville",
		Biome = "ville",
		RequiredWins = 100,
		StageLength = 200,
		LengthGrowth = 1.13,
		ReferenceFlySpeed = 70,
		StaminaDrain = 3,
		StageWins = 8,
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
		Name = "Glacier",
		Biome = "glace",
		RequiredWins = 1000,
		StageLength = 300,
		LengthGrowth = 1.11,
		ReferenceFlySpeed = 100,
		StaminaDrain = 6,
		StageWins = 60,
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
		Biome = "volcan",
		RequiredWins = 8000,
		StageLength = 350,
		LengthGrowth = 1.1,
		ReferenceFlySpeed = 140,
		StaminaDrain = 13,
		StageWins = 400,
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
		Biome = "espace",
		RequiredWins = 50000,
		StageLength = 400,
		LengthGrowth = 1.1,
		ReferenceFlySpeed = 190,
		StaminaDrain = 28,
		StageWins = 2500,
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

local function stageLength(world: World, stage: number): number
	return math.floor(world.StageLength * world.LengthGrowth ^ (stage - 1))
end

-- Endurance conseillée pour l'étape (atmosphère comprise), avec une marge de 30 % pour les détours.
local function recommendedStamina(world: World, stage: number): number
	return math.ceil(stageLength(world, stage) / world.ReferenceFlySpeed * 1.3 * world.StaminaDrain)
end

local function stageWins(world: World, stage: number): number
	return math.max(1, math.floor(world.StageWins * STAGE_WINS_GROWTH ^ (stage - 1)))
end

return {
	List = List,
	ById = byId,
	StageCount = STAGE_COUNT,
	StageLength = stageLength,
	RecommendedStamina = recommendedStamina,
	StageWins = stageWins,
}
