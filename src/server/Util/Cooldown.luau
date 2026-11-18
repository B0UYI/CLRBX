--!strict
-- Anti-spam simple : autorise une action par joueur au plus toutes les `seconds` secondes.

local Cooldown = {}
Cooldown.__index = Cooldown

export type Cooldown = typeof(setmetatable({} :: { seconds: number, last: { [Player]: number } }, Cooldown))

function Cooldown.new(seconds: number): Cooldown
	return setmetatable({ seconds = seconds, last = {} }, Cooldown)
end

-- Renvoie true si l'action est autorisée (et enregistre l'instant).
function Cooldown.try(self: Cooldown, player: Player): boolean
	local now = os.clock()
	local previous = self.last[player]
	if previous and now - previous < self.seconds then
		return false
	end
	self.last[player] = now
	return true
end

-- Nettoyage quand le joueur part.
function Cooldown.forget(self: Cooldown, player: Player)
	self.last[player] = nil
end

return Cooldown
