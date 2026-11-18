--!strict
-- Fabrique les objets tenus en main (panier d'ingrédients, potions),
-- gère les étagères et le fait de boire une potion.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Ingredients = require(Shared.Config.Ingredients)
local Recipes = require(Shared.Config.Recipes)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local EffectService = require(script.Parent.EffectService)
local NotifyService = require(script.Parent.NotifyService)
local PlayerService = require(script.Parent.PlayerService)
local UpgradeService = require(script.Parent.UpgradeService)
local WorldService = require(script.Parent.WorldService)

local ItemService = {}

local ITEM_KIND, ITEM_ID, ITEM_LIST = PlayerService.ItemAttributes()
local shelfCooldown = Cooldown.new(0.15)

local function makeTool(name: string, color: Color3, shape: Enum.PartType, size: Vector3): Tool
	local tool = Instance.new("Tool")
	tool.Name = name
	tool.ToolTip = name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Shape = shape
	handle.Size = size
	handle.Color = color
	handle.Material = Enum.Material.Neon
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	return tool
end

-- Panier contenant 1 à BasketSize ingrédients (couleur = dernier ingrédient ajouté).
function ItemService.MakeBasket(items: { string }): Tool
	assert(#items > 0, "Panier vide")
	local names = {}
	for _, id in items do
		local ingredient = Ingredients.ById[id]
		assert(ingredient, `Ingrédient inconnu : {id}`)
		table.insert(names, ingredient.ShortName)
	end
	local last = Ingredients.ById[items[#items]]
	local tool =
		makeTool(`Panier : {table.concat(names, " + ")}`, last.Color, Enum.PartType.Ball, Vector3.new(1.2, 1.2, 1.2))
	tool:SetAttribute(ITEM_KIND, "Basket")
	tool:SetAttribute(ITEM_LIST, table.concat(items, ","))
	return tool
end

function ItemService.MakePotion(recipeId: string): Tool
	local recipe = Recipes.ById[recipeId]
	assert(recipe, `Recette inconnue : {recipeId}`)
	local tool = makeTool(recipe.Name, recipe.Color, Enum.PartType.Block, Vector3.new(0.8, 1.3, 0.8))
	tool:SetAttribute(ITEM_KIND, "Potion")
	tool:SetAttribute(ITEM_ID, recipeId)

	-- Clic avec la potion en main = la boire.
	local drunk = false
	tool.Activated:Connect(function()
		if drunk then
			return
		end
		local character = tool.Parent
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player or not character or not character:IsA("Model") then
			return
		end
		drunk = true
		tool:Destroy()
		EffectService.Apply(character, recipe.Effect, nil, recipe.Color)
		NotifyService.Send(player, `Glou glou… effet {EffectService.GetName(recipe.Effect)} !`, "success")
	end)
	return tool
end

local function onShelf(player: Player, ingredientId: string)
	if not shelfCooldown:try(player) then
		return
	end
	local held = PlayerService.GetHeld(player)
	if held and held.Kind == "Potion" then
		NotifyService.Send(player, "Tu tiens une potion : sers-la ou bois-la d'abord !", "warning")
		return
	end
	local items = if held and held.Kind == "Basket" then held.Items else {}
	if #items >= UpgradeService.BasketSize(player) then
		NotifyService.Send(player, "Panier plein ! Verse-le dans le chaudron (E)", "warning")
		return
	end
	table.insert(items, ingredientId)
	PlayerService.Give(player, ItemService.MakeBasket(items))
end

function ItemService:Start()
	for _, shelf in WorldService.Shelves do
		shelf.Prompt.Triggered:Connect(function(player: Player)
			onShelf(player, shelf.IngredientId)
		end)
	end
	Players.PlayerRemoving:Connect(function(player)
		shelfCooldown:forget(player)
	end)
end

return ItemService
