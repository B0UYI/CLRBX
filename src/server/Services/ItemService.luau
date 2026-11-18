--!strict
-- Fabrique les objets tenus en main (ingrédients, potions) et gère les étagères et le fait de boire.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Ingredients = require(Shared.Config.Ingredients)
local Recipes = require(Shared.Config.Recipes)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local EffectService = require(script.Parent.EffectService)
local NotifyService = require(script.Parent.NotifyService)
local PlayerService = require(script.Parent.PlayerService)
local WorldService = require(script.Parent.WorldService)

local ItemService = {}

local ITEM_KIND, ITEM_ID = PlayerService.ItemAttributes()
local shelfCooldown = Cooldown.new(0.3)

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

function ItemService.MakeIngredient(ingredientId: string): Tool
	local ingredient = Ingredients.ById[ingredientId]
	assert(ingredient, `Ingrédient inconnu : {ingredientId}`)
	local tool = makeTool(ingredient.Name, ingredient.Color, Enum.PartType.Ball, Vector3.new(1, 1, 1))
	tool:SetAttribute(ITEM_KIND, "Ingredient")
	tool:SetAttribute(ITEM_ID, ingredientId)
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
		EffectService.Apply(character, recipe.Effect)
		NotifyService.Send(player, `Glou glou… effet {EffectService.GetName(recipe.Effect)} !`, "success")
	end)
	return tool
end

function ItemService:Start()
	for _, shelf in WorldService.Shelves do
		shelf.Prompt.Triggered:Connect(function(player: Player)
			if not shelfCooldown:try(player) then
				return
			end
			PlayerService.Give(player, ItemService.MakeIngredient(shelf.IngredientId))
		end)
	end
	Players.PlayerRemoving:Connect(function(player)
		shelfCooldown:forget(player)
	end)
end

return ItemService
