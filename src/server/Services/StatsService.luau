--!strict
-- Stats du joueur (source unique : DataService) : Vitesse, Victoires, multiplicateurs.
-- Publie aussi les valeurs en attributs du joueur pour l'interface (lecture seule côté client)
-- et dans le classement (leaderstats).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Equipment = require(Shared.Config.Equipment)
local Gameplay = require(Shared.Config.Gameplay)
local Movement = require(Shared.Config.Movement)
local Format = require(Shared.Util.Format)
local Analytics = require(script.Parent.Parent.Util.Analytics)
local DataService = require(script.Parent.DataService)

local StatsService = {}

-- Vitesse gagnée pendant la seconde en cours (affichée « +X/s »).
local gainThisSecond: { [Player]: number } = {}

local function setLeaderstat(player: Player, name: string, text: string)
	local folder = player:FindFirstChild("leaderstats")
	local value = folder and folder:FindFirstChild(name)
	if value and value:IsA("StringValue") then
		value.Value = text
	end
end

-- Meilleure pièce possédée pour un emplacement (ou nil).
function StatsService.BestInSlot(player: Player, slot: string): Equipment.Item?
	local data = DataService.Get(player)
	local best: Equipment.Item? = nil
	if data then
		for _, item in Equipment.List do
			if item.Slot == slot and data.Equipment[item.Id] and (not best or item.Multiplier > best.Multiplier) then
				best = item
			end
		end
	end
	return best
end

-- Produit des multiplicateurs de la meilleure pièce de chaque emplacement.
function StatsService.EquipmentMultiplier(player: Player): number
	local multiplier = 1
	for _, slot in Equipment.Slots do
		local best = StatsService.BestInSlot(player, slot.Slot)
		if best then
			multiplier *= best.Multiplier
		end
	end
	return multiplier
end

-- Multiplicateur total des gains de Vitesse : équipement × pass Vitesse ×2 × Turbo.
function StatsService.Multiplier(player: Player): number
	local multiplier = StatsService.EquipmentMultiplier(player)
	if player:GetAttribute("Pass_SpeedX2") == true then
		multiplier *= 2
	end
	local data = DataService.Get(player)
	if data and data.BoostUntil > os.time() then
		multiplier *= Gameplay.Turbo.Multiplier
	end
	return multiplier
end

-- Republie stats, multiplicateur et vitesse de course (après un achat, un gain, etc.).
function StatsService.Sync(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	player:SetAttribute("Speed", data.Speed)
	player:SetAttribute("Wins", data.Wins)
	player:SetAttribute("TotalWins", data.TotalWins)
	player:SetAttribute("Multiplier", StatsService.Multiplier(player))
	-- Le client règle sa vitesse de marche dessus (avec son limiteur).
	player:SetAttribute("MaxWalkSpeed", math.floor(Movement.WalkSpeedFor(data.Speed)))
	player:SetAttribute("BoostUntil", data.BoostUntil)
	setLeaderstat(player, Gameplay.Stats.SpeedName, Format.Number(data.Speed))
	setLeaderstat(player, Gameplay.Stats.WinsName, Format.Number(data.Wins))
end

-- Ajoute de la Vitesse (multiplicateurs appliqués). Renvoie le gain réel.
function StatsService.AddSpeed(player: Player, base: number): number
	local data = DataService.Get(player)
	if not data or base <= 0 then
		return 0
	end
	local gained = base * StatsService.Multiplier(player)
	data.Speed += gained
	gainThisSecond[player] = (gainThisSecond[player] or 0) + gained
	StatsService.Sync(player)
	return gained
end

-- Ajoute des Victoires (doublées par le pass Victoires ×2 sauf si noBonus). Renvoie le gain réel.
function StatsService.AddWins(player: Player, amount: number, reason: string, sku: string?, noBonus: boolean?): number
	local data = DataService.Get(player)
	if not data or amount <= 0 then
		return 0
	end
	local gained = math.floor(amount)
	if not noBonus and player:GetAttribute("Pass_WinsX2") == true then
		gained *= 2
	end
	data.Wins += gained
	data.TotalWins += gained
	StatsService.Sync(player)
	Analytics.Wins(player, gained, data.Wins, reason, sku)
	return gained
end

-- Retire des Victoires si le joueur en a assez. Renvoie true si payé.
function StatsService.TrySpendWins(player: Player, amount: number, sku: string?): boolean
	local data = DataService.Get(player)
	if not data or amount <= 0 or data.Wins < amount then
		return false
	end
	data.Wins -= amount
	StatsService.Sync(player)
	Analytics.Wins(player, -amount, data.Wins, "Shop", sku)
	return true
end

local function setupPlayer(player: Player)
	if player:FindFirstChild("leaderstats") then
		return
	end
	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"
	for _, name in { Gameplay.Stats.SpeedName, Gameplay.Stats.WinsName } do
		local value = Instance.new("StringValue")
		value.Name = name
		value.Value = "0"
		value.Parent = folder
	end
	folder.Parent = player
	StatsService.Sync(player)
end

function StatsService:Start()
	Players.PlayerAdded:Connect(setupPlayer)
	for _, player in Players:GetPlayers() do
		setupPlayer(player)
	end
	DataService.OnLoaded(function(player: Player)
		StatsService.Sync(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		gainThisSecond[player] = nil
	end)
	-- Chaque seconde : gain/s affiché et fin éventuelle du Turbo.
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in Players:GetPlayers() do
				player:SetAttribute("SpeedPerSecond", math.floor(gainThisSecond[player] or 0))
				gainThisSecond[player] = 0
				player:SetAttribute("Multiplier", StatsService.Multiplier(player))
			end
		end
	end)
end

return StatsService
