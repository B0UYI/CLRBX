--!strict
-- Défis personnels de session : 3 objectifs actifs, récompense en pièces, remplacement automatique.
-- Progression publiée en attributs du joueur (Challenge1Text, Challenge1Progress, …) pour le panneau.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Challenges = require(Shared.Config.Challenges)
local Recipes = require(Shared.Config.Recipes)
local FxService = require(script.Parent.FxService)
local NotifyService = require(script.Parent.NotifyService)
local PlayerService = require(script.Parent.PlayerService)

local ChallengeService = {}

type Active = {
	Def: Challenges.ChallengeDef,
	Progress: number,
	RecipeId: string?,
	Text: string,
	Done: boolean,
}

local states: { [Player]: { [number]: Active? } } = {}

-- Niveau de boutique publié par ShopService (lu sans dépendance directe).
local function shopLevel(): number
	local gameState = ReplicatedStorage:FindFirstChild("GameState")
	local level = gameState and gameState:GetAttribute("Level")
	return if type(level) == "number" then level else 1
end

local function publishSlot(player: Player, index: number, active: Active?)
	local prefix = `Challenge{index}`
	player:SetAttribute(prefix .. "Text", if active then active.Text else nil)
	player:SetAttribute(prefix .. "Progress", if active then math.min(active.Progress, active.Def.Goal) else nil)
	player:SetAttribute(prefix .. "Goal", if active then active.Def.Goal else nil)
	player:SetAttribute(prefix .. "Reward", if active then active.Def.Reward else nil)
	player:SetAttribute(prefix .. "Done", if active then active.Done else nil)
end

local function pick(player: Player): Active?
	local taken: { [string]: boolean } = {}
	for _, active in states[player] or {} do
		if active then
			taken[active.Def.Id] = true
		end
	end
	local level = shopLevel()
	local candidates = {}
	for _, def in Challenges.Pool do
		local enoughPlayers = #Players:GetPlayers() >= (def.MinPlayers or 1)
		if not taken[def.Id] and (def.MinLevel or 1) <= level and enoughPlayers then
			table.insert(candidates, def)
		end
	end
	if #candidates == 0 then
		return nil
	end
	local def = candidates[math.random(1, #candidates)]
	local recipeId: string? = nil
	local text = def.Text
	if def.Type == "ServeRecipe" then
		local options = {}
		for _, recipe in Recipes.List do
			if not recipe.Secret and recipe.Level <= level then
				table.insert(options, recipe)
			end
		end
		local recipe = options[math.random(1, #options)]
		recipeId = recipe.Id
		text = (string.gsub(def.Text, "{recipe}", recipe.Name))
	end
	return { Def = def, Progress = 0, RecipeId = recipeId, Text = text, Done = false }
end

local function complete(player: Player, index: number, active: Active)
	active.Done = true
	PlayerService.AddCoins(player, active.Def.Reward)
	NotifyService.Send(player, `🎯 Défi réussi : {active.Text} ! +{active.Def.Reward} 💰`, "success")
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		FxService.Confetti(root.Position + Vector3.new(0, 4, 0), 80)
		FxService.Sound(root, "Cash")
	end
	task.delay(Challenges.ReplaceDelaySeconds, function()
		local list = states[player]
		if list and list[index] == active then
			list[index] = pick(player)
			publishSlot(player, index, list[index])
		end
	end)
end

-- Fait avancer les défis du joueur. Pour "Combo", `amount` est la série actuelle (on garde le max).
-- Pour "ServeRecipe", `recipeId` doit correspondre à la recette du défi.
function ChallengeService.Progress(player: Player?, kind: string, amount: number?, recipeId: string?)
	if not player then
		return
	end
	local list = states[player]
	if not list then
		return
	end
	for index, active in list do
		if active and not active.Done and active.Def.Type == kind then
			if active.RecipeId == nil or active.RecipeId == recipeId then
				if kind == "Combo" then
					active.Progress = math.max(active.Progress, amount or 0)
				else
					active.Progress += amount or 1
				end
				if active.Progress >= active.Def.Goal then
					complete(player, index, active)
				end
				publishSlot(player, index, active)
			end
		end
	end
end

local function setup(player: Player)
	states[player] = {}
	for index = 1, Challenges.ActiveCount do
		local active = pick(player)
		states[player][index] = active
		publishSlot(player, index, active)
	end
end

function ChallengeService:Start()
	Players.PlayerAdded:Connect(setup)
	for _, player in Players:GetPlayers() do
		if not states[player] then
			setup(player)
		end
	end
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
end

return ChallengeService
