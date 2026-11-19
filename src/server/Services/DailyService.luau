--!strict
-- Retour quotidien, sauvegardé :
--  • cadeau de connexion en victoires, qui grandit avec la série de jours d'affilée ;
--  • défi du jour : terminer N parcours, remis à zéro chaque jour.
-- Jour = numéro de jour UTC (os.time() // 86400).

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local NotifyService = require(script.Parent.NotifyService)
local StatsService = require(script.Parent.StatsService)

local DailyService = {}

local Config = Gameplay.Daily

local function today(): number
	return os.time() // 86400
end

local function publish(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	local daily = data.Daily
	player:SetAttribute("DailyStreak", daily.Streak)
	player:SetAttribute("DailyFinishes", math.min(daily.Finishes, Config.FinishGoal))
	player:SetAttribute("DailyGoal", Config.FinishGoal)
	player:SetAttribute("DailyReward", Config.FinishReward)
	player:SetAttribute("DailyClaimed", daily.GoalClaimed)
end

local function celebrate(player: Player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		FxService.Confetti(root.Position + Vector3.new(0, 4, 0), 120)
		FxService.Sound(root, "Cash")
	end
end

-- Passe au nouveau jour si besoin : cadeau de connexion + nouveau défi du jour.
local function ensureToday(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	local daily = data.Daily
	local day = today()
	if daily.Day == day then
		return
	end
	daily.Streak = if daily.Day == day - 1 then daily.Streak + 1 else 1
	daily.Day = day
	daily.Finishes = 0
	daily.GoalClaimed = false

	local rewards = Config.LoginRewards
	local reward = rewards[math.min(daily.Streak, #rewards)]
	local nextReward = rewards[math.min(daily.Streak + 1, #rewards)]
	-- Victoires données tout de suite (rien n'est perdu si le joueur part avant le message).
	StatsService.AddWins(player, reward, "TimedReward", `Connexion_{daily.Streak}`, true)
	local streak = daily.Streak
	task.delay(Config.GiftDelaySeconds, function()
		if player.Parent then
			NotifyService.Send(
				player,
				`🎁 Cadeau du jour (série : {streak} j) : +{reward} 🏆 Reviens demain : +{nextReward} !`,
				"success"
			)
			celebrate(player)
		end
	end)
	publish(player)
end

-- Appelé à chaque parcours terminé par le joueur.
function DailyService.RecordFinish(player: Player)
	ensureToday(player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	local daily = data.Daily
	if not daily.GoalClaimed then
		daily.Finishes += 1
		if daily.Finishes >= Config.FinishGoal then
			daily.GoalClaimed = true
			StatsService.AddWins(player, Config.FinishReward, "TimedReward", "DefiDuJour", true)
			NotifyService.Send(
				player,
				`📅 Défi du jour réussi ! +{Config.FinishReward} 🏆 Nouveau défi demain.`,
				"success"
			)
			celebrate(player)
		end
	end
	publish(player)
end

function DailyService:Start()
	DataService.OnLoaded(function(player: Player)
		ensureToday(player)
		publish(player)
	end)
end

return DailyService
