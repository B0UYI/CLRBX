--!strict
-- Vol façon super-héros + ENDURANCE (la stat clé) + BOOST.
-- Voler vide l'endurance ; elle ne se recharge que posé au sol. Elle grandit avec le niveau :
-- une étape demande un vol continu, il faut donc le niveau suffisant pour la finir.

local FLY_BASE = 40
local FLY_EXPONENT = 0.5
local FLY_MAX = 400

local STAMINA_BASE = 6
local STAMINA_PER_LEVEL = 1

-- Vitesse de vol (studs/s) selon la stat Vitesse.
local function flySpeedFor(speed: number): number
	return math.min(FLY_MAX, FLY_BASE + math.max(speed, 0) ^ FLY_EXPONENT)
end

-- Endurance maximale (secondes de vol) selon le niveau.
local function maxStaminaFor(level: number): number
	return STAMINA_BASE + STAMINA_PER_LEVEL * (math.max(level, 1) - 1)
end

-- Niveau minimal pour tenir `seconds` secondes de vol.
local function levelForStamina(seconds: number): number
	return math.max(1, math.ceil((seconds - STAMINA_BASE) / STAMINA_PER_LEVEL) + 1)
end

return {
	ToggleKey = Enum.KeyCode.F,
	BoostKey = Enum.KeyCode.LeftShift,
	FlySpeedFor = flySpeedFor,
	MaxStaminaFor = maxStaminaFor,
	LevelForStamina = levelForStamina,
	BoostMultiplier = 1.8,
	-- Endurance consommée par seconde (normal / avec boost) et rechargée par seconde au sol.
	Drain = 1,
	BoostDrain = 3,
	Regen = 4,
	-- Endurance minimale pour décoller.
	MinToTakeOff = 1,
	Responsiveness = 5,
	-- Sans commande, on plane sur sa lancée (freinage doux, par seconde).
	GlideDrag = 0.6,
	-- Inclinaison dans les virages (radians max) et sensibilité.
	MaxBank = math.rad(55),
	BankFactor = 0.45,
	-- Caméra : champ de vision au repos / à pleine vitesse, vibration à haute vitesse.
	BaseFov = 70,
	MaxFov = 100,
	FovSpeedForMax = 260,
	ShakeFromSpeed = 180,
	-- Barrières de vent : mur du son + bonus de vitesse temporaire.
	WindBoostMultiplier = 1.5,
	WindBoostSeconds = 2,
	ToggleCooldownSeconds = 0.25,
	MinMovingSpeed = 8,
}
