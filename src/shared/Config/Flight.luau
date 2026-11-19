--!strict
-- Vol façon super-héros : on vole dans la direction de la caméra, corps à l'horizontale,
-- bras tendu en avant. Touche F (ou bouton à l'écran) pour décoller / atterrir.

local LOBBY_BASE = 40
local LOBBY_SCALE = 4
local LOBBY_EXPONENT = 0.35
local LOBBY_MAX = 260

-- Vitesse de vol réelle (studs/s) dans le lobby selon la stat Vitesse (plafonnée pour rester pilotable).
local function lobbySpeedFor(speed: number): number
	return math.min(LOBBY_MAX, LOBBY_BASE + LOBBY_SCALE * math.max(speed, 0) ^ LOBBY_EXPONENT)
end

return {
	ToggleKey = Enum.KeyCode.F,
	LobbySpeedFor = lobbySpeedFor,
	-- Nervosité du vol (plus haut = réagit plus vite).
	Responsiveness = 6,
	-- Vitesse gagnée par seconde en volant (en mouvement), avant multiplicateurs.
	FlyGainPerSecond = 3,
	-- Vitesse minimale (studs/s) pour compter comme « en mouvement ».
	MinMovingSpeed = 8,
	ToggleCooldownSeconds = 0.25,
}
