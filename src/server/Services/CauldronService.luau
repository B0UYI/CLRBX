--!strict
-- Le chaudron partagé : verser des ingrédients, mélanger, récupérer la potion… ou exploser.
-- Le serveur décide de tout ; le joueur ne fait qu'appuyer sur des invites (ProximityPrompt).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Ingredients = require(Shared.Config.Ingredients)
local Recipes = require(Shared.Config.Recipes)
local Gameplay = require(Shared.Config.Gameplay)
local Monetization = require(Shared.Config.Monetization)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local ChallengeService = require(script.Parent.ChallengeService)
local EffectService = require(script.Parent.EffectService)
local ItemService = require(script.Parent.ItemService)
local NotifyService = require(script.Parent.NotifyService)
local PlayerService = require(script.Parent.PlayerService)
local ShopService = require(script.Parent.ShopService)
local WorldService = require(script.Parent.WorldService)

local CauldronService = {}

local Config = Gameplay.Cauldron
local WATER_COLOR = Color3.fromRGB(60, 80, 120)

type Status = "Idle" | "Brewing" | "Ready"

local status: Status = "Idle"
local contents: { string } = {}
local readyRecipeId: string? = nil
local promptCooldown = Cooldown.new(0.3)

local function averageColor(): Color3
	if #contents == 0 then
		return WATER_COLOR
	end
	local r, g, b = 0, 0, 0
	for _, id in contents do
		local color = Ingredients.ById[id].Color
		r += color.R
		g += color.G
		b += color.B
	end
	local n = #contents
	return Color3.new(r / n, g / n, b / n)
end

local function refresh()
	local cauldron = WorldService.Cauldron
	if not cauldron then
		return
	end
	if status == "Idle" then
		cauldron.Liquid.Color = averageColor()
		cauldron.Bubbles.Enabled = false
		cauldron.BrewPrompt.Enabled = true
		cauldron.BrewPrompt.ActionText = "Mélanger"
		cauldron.PourPrompt.Enabled = #contents < Config.MaxIngredients
		if #contents == 0 then
			cauldron.Label.Text = "Chaudron vide\nVerse 2 ou 3 ingrédients"
		else
			local names = {}
			for _, id in contents do
				table.insert(names, Ingredients.ById[id].ShortName)
			end
			cauldron.Label.Text = `{table.concat(names, " + ")}\n({#contents}/{Config.MaxIngredients})`
		end
	elseif status == "Brewing" then
		cauldron.Bubbles.Enabled = true
		cauldron.BrewPrompt.Enabled = false
		cauldron.PourPrompt.Enabled = false
		cauldron.Label.Text = "Ça mijote… 🫧"
	elseif status == "Ready" then
		local recipe = readyRecipeId and Recipes.ById[readyRecipeId]
		cauldron.Bubbles.Enabled = false
		cauldron.PourPrompt.Enabled = false
		cauldron.BrewPrompt.Enabled = true
		cauldron.BrewPrompt.ActionText = "Remplir une fiole"
		if recipe then
			cauldron.Liquid.Color = recipe.Color
			cauldron.Label.Text = `Prête : {recipe.Name} ✨`
		end
	end
end

local function reset()
	status = "Idle"
	table.clear(contents)
	readyRecipeId = nil
	refresh()
end

local function explode(brewer: Player?)
	local cauldron = WorldService.Cauldron
	if not cauldron then
		return
	end
	local center = cauldron.Liquid.Position
	local blast = Instance.new("Explosion")
	blast.Position = center
	blast.BlastRadius = Config.FailBlastRadius
	blast.BlastPressure = 0 -- aucun recul
	blast.DestroyJointRadiusPercent = 0 -- aucun dégât
	blast.Parent = workspace

	for _, player in Players:GetPlayers() do
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if character and root and root:IsA("BasePart") then
			if (root.Position - center).Magnitude <= Config.FailBlastRadius then
				local effectId = EffectService.RandomFailEffect()
				EffectService.Apply(character, effectId)
				NotifyService.Send(
					player,
					`💥 BOUM ! Potion ratée… tu deviens {EffectService.GetName(effectId)} !`,
					"boom"
				)
			end
		end
	end
	ChallengeService.Progress(brewer, "Explode")
	reset()
end

local function onPour(player: Player)
	if not promptCooldown:try(player) then
		return
	end
	if status ~= "Idle" then
		NotifyService.Send(player, "Attends, le chaudron est occupé !", "warning")
		return
	end
	local held = PlayerService.GetHeld(player)
	if not held or held.Kind ~= "Basket" or #held.Items == 0 then
		NotifyService.Send(player, "Remplis d'abord ton panier aux étagères (E)", "warning")
		return
	end
	local space = Config.MaxIngredients - #contents
	if space <= 0 then
		NotifyService.Send(player, "Le chaudron est plein : mélange-le (F) !", "warning")
		return
	end

	-- Verse ce qui rentre ; le reste reste dans le panier.
	local leftover = {}
	for _, id in held.Items do
		if Ingredients.ById[id] then
			if #contents < Config.MaxIngredients then
				table.insert(contents, id)
			else
				table.insert(leftover, id)
			end
		end
	end
	if #leftover > 0 then
		PlayerService.Give(player, ItemService.MakeBasket(leftover))
	else
		held.Tool:Destroy()
	end
	refresh()
	if #contents >= Config.MinIngredients then
		NotifyService.Send(player, "Mélange (F) !", "info")
	end
end

local function onBrew(player: Player)
	if not promptCooldown:try(player) then
		return
	end
	if status == "Ready" then
		local recipeId = readyRecipeId
		if recipeId then
			PlayerService.Give(player, ItemService.MakePotion(recipeId))
			NotifyService.Send(player, `Tu as une {Recipes.ById[recipeId].Name} ! Sers-la ou bois-la.`, "success")
		end
		reset()
		return
	end
	if status ~= "Idle" then
		return
	end
	if #contents < Config.MinIngredients then
		NotifyService.Send(player, `Il faut au moins {Config.MinIngredients} ingrédients`, "warning")
		return
	end

	status = "Brewing"
	refresh()
	local recipe = Recipes.Find(contents)
	local brewer = player
	-- Pass « Chaudron express » : potion presque instantanée.
	local brewSeconds = if player:GetAttribute("Pass_ExpressBrew") == true
		then Monetization.ExpressBrewSeconds
		else Config.BrewSeconds
	task.delay(brewSeconds, function()
		if status ~= "Brewing" then
			return
		end
		if recipe then
			status = "Ready"
			readyRecipeId = recipe.Id
			refresh()
			if recipe.Secret then
				ShopService.Discover(recipe, if brewer.Parent then brewer else nil)
			end
		else
			explode(if brewer.Parent then brewer else nil)
		end
	end)
end

function CauldronService:Start()
	local cauldron = WorldService.Cauldron
	assert(cauldron, "Le chaudron n'a pas été construit")
	cauldron.PourPrompt.Triggered:Connect(onPour)
	cauldron.BrewPrompt.Triggered:Connect(onBrew)
	Players.PlayerRemoving:Connect(function(player)
		promptCooldown:forget(player)
	end)
	reset()
end

return CauldronService
