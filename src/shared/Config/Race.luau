--!strict
-- Course : toutes les ~45 s, tous les joueurs volent 20 s sur une piste dans le ciel.
-- La distance dépend de la stat Vitesse ; chaque zone franchie rapporte des Victoires.

local DIRECTION = Vector3.new(0, 0, -1)
local VELOCITY_BASE = 40
local VELOCITY_SCALE = 6.3
local VELOCITY_EXPONENT = 0.4
local VELOCITY_MAX = 870

local ZONE_COUNT = 25
local ZONE_BASE = 100
local ZONE_EXPONENT = 1.6
local ZONE_WINS_EXPONENT = 1.3

export type Zone = { Index: number, Distance: number, Wins: number }

-- Zone i : à ZONE_BASE × i^1,6 studs du départ, rapporte ⌊i^1,3⌋ victoires (au moins 1).
local zones: { Zone } = {}
for index = 1, ZONE_COUNT do
	table.insert(zones, {
		Index = index,
		Distance = math.floor(ZONE_BASE * index ^ ZONE_EXPONENT),
		Wins = math.max(1, math.floor(index ^ ZONE_WINS_EXPONENT)),
	})
end

-- Vitesse de course (studs/s) selon la stat Vitesse.
local function velocityFor(speed: number): number
	return math.min(VELOCITY_MAX, VELOCITY_BASE + VELOCITY_SCALE * math.max(speed, 0) ^ VELOCITY_EXPONENT)
end

return {
	FirstIntermissionSeconds = 30,
	IntermissionSeconds = 45,
	CountdownSeconds = 5,
	DurationSeconds = 20,
	ResultsSeconds = 5,
	-- Ligne de départ (dans le ciel, loin du lobby) et direction de la piste.
	Start = Vector3.new(0, 350, -400),
	Direction = DIRECTION,
	LaneSpacing = 8,
	Zones = zones,
	TrackLength = zones[#zones].Distance,
	FinishBonusWins = 50,
	VelocityFor = velocityFor,
}
