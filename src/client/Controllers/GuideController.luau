--!strict
-- Guide visuel des nouveaux joueurs : consigne en bas de l'écran + rayon lumineux
-- du personnage vers la prochaine cible (étagère, chaudron, client).
-- Tout est local à ce joueur ; l'étape vient de l'attribut « GuideStep » posé par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Ingredients = require(Config:WaitForChild("Ingredients"))
local Recipes = require(Config:WaitForChild("Recipes"))

local GuideController = {}

local player = Players.LocalPlayer
local DEFAULT_INGREDIENT = "racine"

local function heldTool(): Tool?
	for _, container in { player.Character, player:FindFirstChildOfClass("Backpack") } do
		if container then
			for _, child in container:GetChildren() do
				if child:IsA("Tool") and child:GetAttribute("ItemKind") ~= nil then
					return child
				end
			end
		end
	end
	return nil
end

local function customers(shop: Instance): { Model }
	local list = {}
	for _, child in shop:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("OrderId") ~= nil then
			table.insert(list, child)
		end
	end
	return list
end

local function partOf(instance: Instance?): BasePart?
	if instance and instance:IsA("BasePart") then
		return instance
	end
	return nil
end

-- Renvoie la cible et la consigne pour l'étape.
local function guide(step: number, shop: Instance): (BasePart?, string)
	local tool = heldTool()
	if step == 1 then
		local waiting = customers(shop)
		local order = waiting[1] and waiting[1]:GetAttribute("OrderId")
		local recipe = if type(order) == "string" then Recipes.ById[order] else nil
		local basketText = if tool then tool:GetAttribute("Items") else nil
		local basket = if type(basketText) == "string" and basketText ~= "" then string.split(basketText, ",") else {}
		local needed: string? = DEFAULT_INGREDIENT
		if recipe then
			needed = nil
			local remaining = table.clone(basket)
			for _, id in recipe.Ingredients do
				local index = table.find(remaining, id)
				if index then
					table.remove(remaining, index)
				else
					needed = id
					break
				end
			end
		end
		if not needed then
			return partOf(shop:FindFirstChild("Chaudron")), "1/5 · Panier prêt ! Va au chaudron 🧪"
		end
		local name = Ingredients.ById[needed].ShortName
		return partOf(shop:FindFirstChild(`Etagere_{needed}`)), `1/5 · Prends : {name} (touche E sur l'étagère)`
	elseif step == 2 then
		return partOf(shop:FindFirstChild("Chaudron")), "2/5 · Verse ton panier dans le chaudron (E)"
	elseif step == 3 then
		return partOf(shop:FindFirstChild("Chaudron")), "3/5 · Mélange le chaudron (F)"
	elseif step == 4 then
		return partOf(shop:FindFirstChild("Chaudron")), "4/5 · Potion prête : remplis une fiole (F)"
	end
	local potionId = if tool then tool:GetAttribute("ItemId") else nil
	local waiting = customers(shop)
	local chosen = waiting[1]
	for _, customer in waiting do
		if customer:GetAttribute("OrderId") == potionId then
			chosen = customer
			break
		end
	end
	local root = chosen and chosen:FindFirstChild("HumanoidRootPart")
	return partOf(root), "5/5 · Sers la potion au client qui la veut (E)"
end

function GuideController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Guide"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 8
	gui.Parent = player:WaitForChild("PlayerGui")
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 1, -100)
	label.Size = UDim2.new(0.8, 0, 0, 46)
	label.BackgroundColor3 = Color3.fromRGB(255, 215, 80)
	label.TextColor3 = Color3.fromRGB(40, 25, 10)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Visible = false
	label.Parent = gui
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(620, 46)
	limit.Parent = label
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label

	local fromAttachment = Instance.new("Attachment")
	fromAttachment.Name = "GuideDepart"
	local toAttachment = Instance.new("Attachment")
	toAttachment.Name = "GuideCible"
	toAttachment.Position = Vector3.new(0, 3, 0)
	local beam = Instance.new("Beam")
	beam.Name = "GuideRayon"
	beam.Attachment0 = fromAttachment
	beam.Attachment1 = toAttachment
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 230, 90))
	beam.LightEmission = 1
	beam.Width0 = 0.5
	beam.Width1 = 0.5
	beam.FaceCamera = true
	beam.Segments = 12
	beam.CurveSize0 = 4
	beam.Transparency = NumberSequence.new(0.25)
	beam.Enabled = false

	while true do
		local step = player:GetAttribute("GuideStep")
		local shop = workspace:FindFirstChild("PotionShop")
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if type(step) == "number" and step > 0 and shop and root and root:IsA("BasePart") then
			local target, text = guide(step, shop)
			label.Text = text
			label.Visible = true
			if fromAttachment.Parent ~= root then
				fromAttachment.Parent = root
				beam.Parent = root
			end
			if target then
				if toAttachment.Parent ~= target then
					toAttachment.Parent = target
				end
				beam.Enabled = true
			else
				beam.Enabled = false
			end
		else
			label.Visible = false
			beam.Enabled = false
		end
		task.wait(0.2)
	end
end

return GuideController
