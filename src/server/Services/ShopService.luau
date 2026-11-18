--!strict
-- Progression partagée de la boutique : niveau, série de réussites, recettes secrètes
-- et événement « Grand Chaudron ». L'état est publié dans ReplicatedStorage.GameState
-- (attributs en lecture seule pour les clients).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Recipes = require(Shared.Config.Recipes)
local Effects = require(Shared.Config.Effects)
local Gameplay = require(Shared.Config.Gameplay)
local ChallengeService = require(script.Parent.ChallengeService)
local DataService = require(script.Parent.DataService)
local EffectService = require(script.Parent.EffectService)
local FxService = require(script.Parent.FxService)
local NotifyService = require(script.Parent.NotifyService)
local PlayerService = require(script.Parent.PlayerService)
local WorldService = require(script.Parent.WorldService)

local ShopService = {}

local Progression = Gameplay.Progression
local Event = Gameplay.GrandCauldron

type EventState = "Waiting" | "Active" | "Party"

local xp = 0
local level = 1
local combo = 0
local discovered: { [string]: boolean } = {}
local eventState: EventState = "Waiting"
local eventProgress = 0
local eventGoal = 0
local eventEndsAt = 0
local nextEventAt = 0

local gameState: Configuration

local function xpForLevel(target: number): number
	local list = Progression.LevelXp
	if target <= #list then
		return list[target]
	end
	-- Au-delà du tableau : +40 XP par niveau.
	return list[#list] + (target - #list) * 40
end

local function publish()
	gameState:SetAttribute("Level", level)
	gameState:SetAttribute("Xp", xp - xpForLevel(level))
	gameState:SetAttribute("XpNeeded", xpForLevel(level + 1) - xpForLevel(level))
	gameState:SetAttribute("Combo", combo)
	gameState:SetAttribute("ComboMultiplier", ShopService.ComboMultiplier())
	gameState:SetAttribute("EventState", eventState)
	gameState:SetAttribute("EventProgress", eventProgress)
	gameState:SetAttribute("EventGoal", eventGoal)
	gameState:SetAttribute("EventEndsAt", eventEndsAt)
	gameState:SetAttribute("NextEventAt", nextEventAt)
	local found = 0
	for _ in discovered do
		found += 1
	end
	gameState:SetAttribute("SecretsFound", found)
	gameState:SetAttribute("SecretsTotal", #ShopService.SecretRecipes())
end

local function refreshGrimoire()
	WorldService.RefreshGrimoire(level, discovered)
end

function ShopService.Level(): number
	return level
end

function ShopService.SecretRecipes(): { Recipes.Recipe }
	local list = {}
	for _, recipe in Recipes.List do
		if recipe.Secret then
			table.insert(list, recipe)
		end
	end
	return list
end

-- Recettes que les clients peuvent commander (secrètes découvertes incluses si demandé).
function ShopService.OrderableRecipes(includeSecrets: boolean): { Recipes.Recipe }
	local list = {}
	for _, recipe in Recipes.List do
		if recipe.Secret then
			if includeSecrets and discovered[recipe.Id] then
				table.insert(list, recipe)
			end
		elseif recipe.Level <= level then
			table.insert(list, recipe)
		end
	end
	return list
end

function ShopService.Combo(): number
	return combo
end

function ShopService.ComboMultiplier(): number
	local multiplier = 1
	for _, tier in Gameplay.Combo.Tiers do
		if combo >= tier.Count then
			multiplier = tier.Multiplier
		end
	end
	return multiplier
end

function ShopService.IsRush(): boolean
	return eventState == "Active"
end

function ShopService.EventMultiplier(): number
	return if eventState == "Active" then Event.PayMultiplier else 1
end

local function levelUp()
	local unlocked = {}
	for _, recipe in Recipes.List do
		if not recipe.Secret and recipe.Level == level then
			table.insert(unlocked, recipe.Name)
		end
	end
	local suffix = if #unlocked > 0 then ` Nouvelle recette : {table.concat(unlocked, ", ")} !` else ""
	NotifyService.All(`⭐ La boutique passe niveau {level} !{suffix}`, "success")
	FxService.Confetti(Vector3.new(0, 12, -36), 200)
	refreshGrimoire()
end

local function addXp(amount: number)
	xp += amount
	while xp >= xpForLevel(level + 1) do
		level += 1
		levelUp()
	end
end

local function party()
	eventState = "Party"
	publish()
	local position = WorldService.GrandCauldronTop()
	FxService.Confetti(position, 300)
	task.delay(0.6, FxService.Confetti, position + Vector3.new(0, 6, 0), 200)
	local bonus = Event.PartyCoinsPerLevel * level
	for _, player in Players:GetPlayers() do
		local character = player.Character
		if character then
			local pool = Effects.PartyPool
			local effectId = pool[math.random(1, #pool)]
			EffectService.Apply(character, effectId, nil, Color3.fromHSV(math.random(), 0.8, 1))
		end
		PlayerService.AddCoins(player, bonus, "Gameplay", "FeteDesPotions")
		ChallengeService.Progress(player, "Party")
	end
	NotifyService.All(`🎉 FÊTE DES POTIONS ! Tout le monde gagne +{bonus} pièces !`, "success")
	task.wait(Event.PartySeconds)
end

local function runEvent()
	eventState = "Active"
	eventProgress = 0
	eventGoal = Event.GoalBase + Event.GoalPerPlayer * math.max(#Players:GetPlayers(), 1)
	eventEndsAt = workspace:GetServerTimeNow() + Event.DurationSeconds
	WorldService.SetGrandCauldronFill(0)
	publish()
	NotifyService.All(`🧪 LE GRAND CHAUDRON ! Servez {eventGoal} potions en 1 minute — gains x2 !`, "boom")

	while eventState == "Active" and workspace:GetServerTimeNow() < eventEndsAt do
		if eventProgress >= eventGoal then
			break
		end
		task.wait(0.25)
	end

	if eventProgress >= eventGoal then
		party()
	else
		NotifyService.All("Le Grand Chaudron n'est pas plein… Retentez au prochain !", "warning")
	end
	eventState = "Waiting"
	WorldService.SetGrandCauldronFill(0)
	nextEventAt = workspace:GetServerTimeNow() + Event.IntervalSeconds
	publish()
end

-- Appelé quand un client reçoit la bonne potion.
function ShopService.RecordServe(xpGain: number)
	combo += 1
	if eventState == "Active" then
		eventProgress += 1
		WorldService.SetGrandCauldronFill(math.clamp(eventProgress / math.max(eventGoal, 1), 0, 1))
	end
	addXp(xpGain)
	publish()
end

function ShopService.BreakCombo(reason: string)
	if combo >= Gameplay.Combo.Tiers[1].Count then
		NotifyService.All(`💔 Série perdue ({combo}) : {reason}`, "warning")
	end
	combo = 0
	publish()
end

local function publishPersonalSecrets(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	local count = 0
	for _, recipe in ShopService.SecretRecipes() do
		if data.Secrets[recipe.Id] then
			count += 1
		end
	end
	player:SetAttribute("SecretsFound", count)
end

-- Recette secrète préparée : collection personnelle (sauvegardée, bonus une seule fois par joueur)
-- et annonce au serveur la première fois qu'elle apparaît sur ce serveur.
function ShopService.Discover(recipe: Recipes.Recipe, player: Player?)
	if not recipe.Secret then
		return
	end
	local data = player and DataService.Get(player)
	if player and data and not data.Secrets[recipe.Id] then
		data.Secrets[recipe.Id] = true
		PlayerService.AddCoins(player, Gameplay.Discovery.BonusCoins, "Gameplay", `Secret_{recipe.Id}`)
		NotifyService.Send(
			player,
			`📖 Nouvelle recette dans ta collection ! +{Gameplay.Discovery.BonusCoins} pièces 💰`,
			"success"
		)
		publishPersonalSecrets(player)
	end
	if discovered[recipe.Id] then
		return
	end
	discovered[recipe.Id] = true
	local who = if player then player.DisplayName else "Quelqu'un"
	NotifyService.All(`✨ {who} a découvert une RECETTE SECRÈTE : {recipe.Name} !`, "success")
	FxService.Confetti(WorldService.CauldronTop(), 180)
	refreshGrimoire()
	publish()
end

function ShopService:Init()
	gameState = Instance.new("Configuration")
	gameState.Name = "GameState"
	gameState.Parent = ReplicatedStorage
end

function ShopService:Start()
	nextEventAt = workspace:GetServerTimeNow() + Event.FirstDelaySeconds
	refreshGrimoire()
	publish()
	-- Les secrets connus des joueurs présents apparaissent dans le grimoire de la boutique.
	DataService.OnLoaded(function(player: Player, data)
		local changed = false
		for recipeId in data.Secrets do
			if Recipes.ById[recipeId] and not discovered[recipeId] then
				discovered[recipeId] = true
				changed = true
			end
		end
		publishPersonalSecrets(player)
		if changed then
			refreshGrimoire()
			publish()
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			if workspace:GetServerTimeNow() >= nextEventAt and #Players:GetPlayers() > 0 then
				runEvent()
			end
		end
	end)
end

return ShopService
