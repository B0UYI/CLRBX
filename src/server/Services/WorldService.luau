--!strict
-- Construit la boutique du prototype en blocs simples, au démarrage du serveur.
-- (Les vrais décors seront faits dans Studio plus tard ; ici tout est généré par le code.)

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Ingredients = require(Shared.Config.Ingredients)
local Recipes = require(Shared.Config.Recipes)
local Gameplay = require(Shared.Config.Gameplay)

export type Shelf = { IngredientId: string, Part: BasePart, Prompt: ProximityPrompt }
export type Cauldron = {
	Body: BasePart,
	Liquid: BasePart,
	Bubbles: ParticleEmitter,
	Label: TextLabel,
	PourPrompt: ProximityPrompt,
	BrewPrompt: ProximityPrompt,
}

local WorldService = {
	Folder = nil :: Folder?,
	Shelves = {} :: { Shelf },
	Cauldron = nil :: Cauldron?,
	-- Positions où les clients attendent devant le comptoir.
	CustomerSpots = {} :: { Vector3 },
	CustomerEntry = Vector3.new(0, 4, -10),
}

-- Plan de la boutique (en studs). Le sol du Baseplate est à y = 0.
local FLOOR_TOP = 1
local SHOP_CENTER_Z = -30
local CAULDRON_POS = Vector3.new(0, FLOOR_TOP, -40)

local WOOD = Color3.fromRGB(120, 80, 50)
local STONE = Color3.fromRGB(90, 90, 105)
local CAULDRON_IRON = Color3.fromRGB(40, 40, 45)

local function makePart(props: { [string]: any }): Part
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(part :: any)[key] = value
	end
	return part
end

local function makePrompt(
	parent: Instance,
	action: string,
	object: string,
	key: Enum.KeyCode,
	hold: number?
): ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = action
	prompt.ObjectText = object
	prompt.KeyboardKeyCode = key
	prompt.HoldDuration = hold or 0
	prompt.MaxActivationDistance = Gameplay.Interaction.MaxDistance
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent
	return prompt
end

local function makeBillboard(adornee: BasePart, offsetY: number, text: string, size: UDim2?): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Size = size or UDim2.fromOffset(220, 50)
	gui.StudsOffset = Vector3.new(0, offsetY, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 60
	gui.Adornee = adornee
	gui.Parent = adornee
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.3
	label.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Text = text
	label.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
	return label
end

local grimoireGui: SurfaceGui? = nil

local function buildRecipeBoard(folder: Folder)
	local board = makePart({
		Name = "Grimoire",
		Size = Vector3.new(22, 13.5, 0.4),
		Position = Vector3.new(0, FLOOR_TOP + 7.25, -50.7),
		Color = Color3.fromRGB(60, 40, 30),
		Parent = folder,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back -- face tournée vers la boutique (+Z)
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.Parent = board
	grimoireGui = gui
	WorldService.RefreshGrimoire(1, {})
end

-- Réécrit le grimoire : recettes débloquées, verrouillées (niveau requis) et secrètes.
function WorldService.RefreshGrimoire(level: number, discovered: { [string]: boolean })
	local gui = grimoireGui
	if not gui then
		return
	end
	gui:ClearAllChildren()

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = gui
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.Parent = gui

	local function line(text: string, height: number, color: Color3, order: number)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -40, 0, height)
		label.BackgroundTransparency = 1
		label.TextColor3 = color
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		label.Text = text
		label.LayoutOrder = order
		label.Parent = gui
	end

	local function ingredientList(recipe: Recipes.Recipe): string
		local names = {}
		for _, id in recipe.Ingredients do
			table.insert(names, Ingredients.ById[id].ShortName)
		end
		return table.concat(names, " + ")
	end

	line(`📖 GRIMOIRE — Boutique niveau {level}`, 50, Color3.fromRGB(255, 220, 120), 0)
	local order = 1
	for _, recipe in Recipes.List do
		if recipe.Secret then
			if discovered[recipe.Id] then
				line(`✨ {recipe.Name} = {ingredientList(recipe)}`, 34, recipe.Color, 100 + order)
			else
				line(
					"❓ Recette secrète… (indice : parfois, il faut insister)",
					34,
					Color3.fromRGB(160, 150, 170),
					100 + order
				)
			end
		elseif recipe.Level <= level then
			line(`{recipe.Name} = {ingredientList(recipe)}`, 34, recipe.Color, order)
		else
			line(`🔒 {recipe.Name} — niveau {recipe.Level}`, 34, Color3.fromRGB(130, 120, 140), order)
		end
		order += 1
	end
	line("Autre mélange = 💥 BOUM !", 34, Color3.fromRGB(255, 120, 120), 999)
end

-- Grand Chaudron (événement collectif) : cuve en verre qui se remplit.
local GRAND_POS = Vector3.new(22, FLOOR_TOP, -18)
local GRAND_HEIGHT = 7
local grandLiquid: Part? = nil

local function buildGrandCauldron(folder: Folder)
	local body = makePart({
		Name = "GrandChaudron",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(GRAND_HEIGHT, 10, 10),
		CFrame = CFrame.new(GRAND_POS + Vector3.new(0, GRAND_HEIGHT / 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(200, 230, 255),
		Material = Enum.Material.Glass,
		Transparency = 0.55,
		Parent = folder,
	})
	grandLiquid = makePart({
		Name = "GrandLiquide",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.2, 9.2, 9.2),
		Color = Color3.fromRGB(255, 200, 60),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = body,
	})
	makeBillboard(body, GRAND_HEIGHT / 2 + 3, "🏆 GRAND CHAUDRON", UDim2.fromOffset(260, 50))
	WorldService.SetGrandCauldronFill(0)
end

function WorldService.SetGrandCauldronFill(fraction: number)
	local liquid = grandLiquid
	if not liquid then
		return
	end
	local height = math.max(0.2, (GRAND_HEIGHT - 0.4) * math.clamp(fraction, 0, 1))
	liquid.Size = Vector3.new(height, 9.2, 9.2)
	liquid.CFrame = CFrame.new(GRAND_POS + Vector3.new(0, 0.2 + height / 2, 0)) * CFrame.Angles(0, 0, math.rad(90))
	liquid.Transparency = if fraction <= 0 then 1 else 0
end

function WorldService.GrandCauldronTop(): Vector3
	return GRAND_POS + Vector3.new(0, GRAND_HEIGHT + 1, 0)
end

function WorldService.CauldronTop(): Vector3
	return CAULDRON_POS + Vector3.new(0, 5, 0)
end

local function buildShelves(folder: Folder)
	-- Étagères réparties à gauche et à droite du grimoire, contre le mur du fond.
	local count = #Ingredients.List
	local half = math.ceil(count / 2)
	for index, ingredient in Ingredients.List do
		local side = if index <= half then -1 else 1
		local slot = if index <= half then index else index - half
		local x = side * (11 + slot * 5)
		local shelf = makePart({
			Name = `Etagere_{ingredient.Id}`,
			Size = Vector3.new(4, 5, 2),
			Position = Vector3.new(x, FLOOR_TOP + 2.5, -48),
			Color = WOOD,
			Parent = folder,
		})
		local display = makePart({
			Name = "Ingredient",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(1.8, 1.8, 1.8),
			Position = shelf.Position + Vector3.new(0, 3.4, 0),
			Color = ingredient.Color,
			Material = Enum.Material.Neon,
			CanCollide = false,
			Parent = shelf,
		})
		makeBillboard(display, 2, ingredient.Name, UDim2.fromOffset(180, 36))
		local prompt = makePrompt(shelf, "Prendre", ingredient.Name, Enum.KeyCode.E)
		table.insert(WorldService.Shelves, { IngredientId = ingredient.Id, Part = shelf, Prompt = prompt })
	end
end

local function buildCauldron(folder: Folder)
	-- Cylindre debout : l'axe d'un cylindre Roblox est X, on le tourne de 90° sur Z.
	local body = makePart({
		Name = "Chaudron",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(4, 6, 6),
		CFrame = CFrame.new(CAULDRON_POS + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = CAULDRON_IRON,
		Material = Enum.Material.Metal,
		Parent = folder,
	})
	local liquid = makePart({
		Name = "Liquide",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.3, 5.2, 5.2),
		CFrame = CFrame.new(CAULDRON_POS + Vector3.new(0, 4.05, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(60, 80, 120),
		Material = Enum.Material.Neon,
		CanCollide = false,
		Parent = body,
	})
	local attachment = Instance.new("Attachment")
	attachment.Parent = liquid
	local bubbles = Instance.new("ParticleEmitter")
	bubbles.Rate = 25
	bubbles.Lifetime = NumberRange.new(0.8, 1.4)
	bubbles.Speed = NumberRange.new(3, 6)
	bubbles.SpreadAngle = Vector2.new(25, 25)
	bubbles.EmissionDirection = Enum.NormalId.Top
	bubbles.Size = NumberSequence.new(0.6, 0)
	bubbles.Enabled = false
	bubbles.Parent = attachment

	local label = makeBillboard(liquid, 4.5, "Chaudron vide", UDim2.fromOffset(260, 60))
	local pour = makePrompt(body, "Verser le panier", "Chaudron", Enum.KeyCode.E)
	local brew = makePrompt(body, "Mélanger", "Chaudron", Enum.KeyCode.F)
	brew.UIOffset = Vector2.new(0, 80) -- évite que les deux invites se superposent

	WorldService.Cauldron = {
		Body = body,
		Liquid = liquid,
		Bubbles = bubbles,
		Label = label,
		PourPrompt = pour,
		BrewPrompt = brew,
	}
end

function WorldService:Init()
	local existing = workspace:FindFirstChild("PotionShop")
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "PotionShop"
	WorldService.Folder = folder

	-- Sol, mur du fond, comptoir, porte.
	makePart({
		Name = "Sol",
		Size = Vector3.new(60, 1, 44),
		Position = Vector3.new(0, FLOOR_TOP - 0.5, SHOP_CENTER_Z),
		Color = STONE,
		Material = Enum.Material.Slate,
		Parent = folder,
	})
	makePart({
		Name = "MurFond",
		Size = Vector3.new(60, 14, 1),
		Position = Vector3.new(0, FLOOR_TOP + 7, -51.5),
		Color = Color3.fromRGB(110, 70, 120),
		Material = Enum.Material.Brick,
		Parent = folder,
	})
	makePart({
		Name = "Comptoir",
		Size = Vector3.new(32, 4, 3),
		Position = Vector3.new(0, FLOOR_TOP + 2, -30),
		Color = WOOD,
		Material = Enum.Material.Wood,
		Parent = folder,
	})
	for _, x in { -6, 6 } do
		makePart({
			Name = "PortePilier",
			Size = Vector3.new(1, 10, 1),
			Position = Vector3.new(x, FLOOR_TOP + 5, -9),
			Color = WOOD,
			Parent = folder,
		})
	end
	local lintel = makePart({
		Name = "PorteLinteau",
		Size = Vector3.new(13, 2, 1),
		Position = Vector3.new(0, FLOOR_TOP + 11, -9),
		Color = WOOD,
		Parent = folder,
	})
	makeBillboard(lintel, 2.5, "🧪 POTION PANIQUE 🧪", UDim2.fromOffset(320, 60))

	for _, x in { -10, 0, 10 } do
		table.insert(WorldService.CustomerSpots, Vector3.new(x, FLOOR_TOP + 3, -26))
	end

	buildRecipeBoard(folder)
	buildShelves(folder)
	buildCauldron(folder)
	buildGrandCauldron(folder)

	folder.Parent = workspace
end

return WorldService
