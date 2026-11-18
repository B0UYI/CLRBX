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

	-- Rayon lumineux. Les points d'accroche sont recréés quand le personnage ou la cible change :
	-- un objet détruit (personnage réapparu, client parti) ne peut pas être réutilisé.
	local beam: Beam? = nil
	local fromAttachment: Attachment? = nil
	local toAttachment: Attachment? = nil
	local currentRoot: BasePart? = nil
	local currentTarget: BasePart? = nil

	local function clearTarget()
		if toAttachment then
			toAttachment:Destroy()
			toAttachment = nil
		end
		currentTarget = nil
	end

	local function clearAll()
		clearTarget()
		if beam then
			beam:Destroy()
			beam = nil
		end
		if fromAttachment then
			fromAttachment:Destroy()
			fromAttachment = nil
		end
		currentRoot = nil
	end

	local function attachRoot(root: BasePart)
		clearAll()
		local from = Instance.new("Attachment")
		from.Name = "GuideDepart"
		from.Parent = root
		local newBeam = Instance.new("Beam")
		newBeam.Name = "GuideRayon"
		newBeam.Attachment0 = from
		newBeam.Color = ColorSequence.new(Color3.fromRGB(255, 230, 90))
		newBeam.LightEmission = 1
		newBeam.Width0 = 0.5
		newBeam.Width1 = 0.5
		newBeam.FaceCamera = true
		newBeam.Segments = 12
		newBeam.CurveSize0 = 4
		newBeam.Transparency = NumberSequence.new(0.25)
		newBeam.Enabled = false
		newBeam.Parent = root
		fromAttachment = from
		beam = newBeam
		currentRoot = root
	end

	local function attachTarget(target: BasePart)
		clearTarget()
		local to = Instance.new("Attachment")
		to.Name = "GuideCible"
		to.Position = Vector3.new(0, 3, 0)
		to.Parent = target
		toAttachment = to
		currentTarget = target
		if beam then
			beam.Attachment1 = to
		end
	end

	while true do
		local step = player:GetAttribute("GuideStep")
		local shop = workspace:FindFirstChild("PotionShop")
		local character = player.Character
		local rootInstance = character and character:FindFirstChild("HumanoidRootPart")
		local root = if rootInstance and rootInstance:IsA("BasePart") then rootInstance else nil
		if type(step) == "number" and step > 0 and shop and root then
			local target, text = guide(step, shop)
			label.Text = text
			label.Visible = true
			if root ~= currentRoot or not (fromAttachment and fromAttachment:IsDescendantOf(workspace)) then
				attachRoot(root)
			end
			if target and target:IsDescendantOf(workspace) then
				if target ~= currentTarget or not (toAttachment and toAttachment:IsDescendantOf(workspace)) then
					attachTarget(target)
				end
				if beam then
					beam.Enabled = true
				end
			else
				clearTarget()
				if beam then
					beam.Enabled = false
				end
			end
		else
			label.Visible = false
			if beam then
				beam.Enabled = false
			end
			if type(step) == "number" and step == 0 and currentRoot then
				clearAll() -- guide terminé : on nettoie
			end
		end
		task.wait(0.2)
	end
end

return GuideController
