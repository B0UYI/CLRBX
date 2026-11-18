--!strict
-- Données joueur persistantes via ProfileStore : sauvegarde automatique et verrou de session
-- (empêche la duplication si le joueur rejoint un autre serveur).
-- En Studio sans accès aux API (jeu non publié), ProfileStore passe en mode simulé :
-- tout fonctionne mais rien n'est sauvegardé (message « data will not be saved » dans la Sortie).

local Players = game:GetService("Players")

local ProfileStore = require(script.Parent.Parent.Packages.ProfileStore) :: any

export type PlayerData = {
	Coins: number,
	-- Articles achetés en pièces (améliorations, titres, décorations) : [upgradeId] = true
	Upgrades: { [string]: boolean },
	-- Recettes secrètes découvertes par CE joueur : [recipeId] = true
	Secrets: { [string]: boolean },
	Served: number,
	Settings: { NoSplash: boolean },
	-- Récompense de connexion et défi du jour (Day = numéro du jour UTC).
	Daily: { Day: number, Streak: number, Served: number, GoalClaimed: boolean },
	-- Derniers achats Robux traités (anti double-attribution).
	PurchaseIds: { string },
	-- Guide des nouveaux joueurs terminé.
	Onboarded: boolean,
}

local TEMPLATE: PlayerData = {
	Coins = 0,
	Upgrades = {},
	Secrets = {},
	Served = 0,
	Settings = { NoSplash = false },
	Daily = { Day = 0, Streak = 0, Served = 0, GoalClaimed = false },
	PurchaseIds = {},
	Onboarded = false,
}

local DataService = {}

local store = ProfileStore.New("PlayerData_v1", TEMPLATE)
local profiles: { [Player]: any } = {}
local loading: { [Player]: boolean } = {}
local loadedCallbacks: { (Player, PlayerData) -> () } = {}

-- Données du joueur, ou nil si elles ne sont pas encore chargées.
function DataService.Get(player: Player): PlayerData?
	local profile = profiles[player]
	return if profile then profile.Data else nil
end

-- Profil ProfileStore complet (pour les achats Robux qui doivent attendre la sauvegarde).
function DataService.GetProfile(player: Player): any
	return profiles[player]
end

-- Appelle `callback` pour chaque joueur dont les données sont chargées (déjà ou plus tard).
function DataService.OnLoaded(callback: (Player, PlayerData) -> ())
	table.insert(loadedCallbacks, callback)
	for player, profile in profiles do
		task.spawn(callback, player, profile.Data)
	end
end

local function loadPlayer(player: Player)
	if loading[player] or profiles[player] then
		return
	end
	loading[player] = true
	local profile = store:StartSessionAsync(`Player_{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})
	loading[player] = nil
	if profile == nil then
		if player.Parent == Players then
			player:Kick("Impossible de charger tes données. Réessaie dans un instant !")
		end
		return
	end
	profile:AddUserId(player.UserId)
	profile:Reconcile()
	profile.OnSessionEnd:Connect(function()
		profiles[player] = nil
		if player.Parent == Players then
			player:Kick("Ta partie a été ouverte sur un autre serveur. Reviens !")
		end
	end)
	if player.Parent ~= Players then
		profile:EndSession()
		return
	end
	profiles[player] = profile
	for _, callback in loadedCallbacks do
		task.spawn(callback, player, profile.Data)
	end
end

function DataService:Start()
	Players.PlayerAdded:Connect(loadPlayer)
	for _, player in Players:GetPlayers() do
		task.spawn(loadPlayer, player)
	end
	Players.PlayerRemoving:Connect(function(player)
		local profile = profiles[player]
		if profile then
			profile:EndSession()
		end
	end)
end

return DataService
