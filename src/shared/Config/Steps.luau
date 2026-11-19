--!strict
-- Points gagnés à chaque PAS (« steps ») : la valeur d'un pas s'améliore en achetant des paliers
-- avec les Victoires (dans l'ordre). Les points s'ajoutent à la Vitesse et remplissent le Niveau.

export type Tier = { Index: number, Value: number, Price: number }

local VALUES = { 1, 2, 4, 8, 16, 32, 64, 125, 250, 500, 1000, 2000 }
local PRICES = { 0, 5, 20, 80, 350, 1200, 4000, 12000, 40000, 120000, 350000, 1000000 }

local tiers: { Tier } = {}
for index, value in VALUES do
	table.insert(tiers, { Index = index, Value = value, Price = PRICES[index] })
end

-- Points nécessaires pour passer du niveau n au niveau n + 1.
local LEVEL_BASE = 10
local LEVEL_GROWTH = 1.12

local function xpForNextLevel(level: number): number
	return LEVEL_BASE * LEVEL_GROWTH ^ (level - 1)
end

-- Niveau atteint avec une Vitesse totale, et progression dans ce niveau.
local function levelFor(speed: number): (number, number, number)
	local level = 1
	local remaining = math.max(speed, 0)
	while remaining >= xpForNextLevel(level) and level < 500 do
		remaining -= xpForNextLevel(level)
		level += 1
	end
	return level, remaining, xpForNextLevel(level)
end

return {
	Tiers = tiers,
	-- Longueur d'un pas (studs) et pas comptés au maximum par seconde (évite l'emballement).
	Stride = 4,
	MaxStepsPerSecond = 8,
	LevelFor = levelFor,
}
