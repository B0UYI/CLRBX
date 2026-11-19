--!strict
-- Magasin Robux : bouton 🛒 et fenêtre listant les game passes et produits.
-- Le client ne fait qu'ouvrir la fenêtre d'achat officielle de Roblox ;
-- l'attribution est faite par le serveur (MonetizationService).

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Monetization =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Monetization"))

local StoreController = {}

local player = Players.LocalPlayer

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function text(parent: Instance, value: string, size: UDim2, position: UDim2, color: Color3?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.FredokaOne
	label.Text = value
	label.Parent = parent
	return label
end

function StoreController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Store"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 5
	gui.Parent = player:WaitForChild("PlayerGui")

	local openButton = Instance.new("TextButton")
	openButton.AnchorPoint = Vector2.new(1, 0.5)
	openButton.Position = UDim2.new(1, -12, 0.5, 0)
	openButton.Size = UDim2.fromOffset(130, 46)
	openButton.BackgroundColor3 = Color3.fromRGB(255, 190, 60)
	openButton.TextColor3 = Color3.fromRGB(40, 25, 10)
	openButton.TextScaled = true
	openButton.Font = Enum.Font.FredokaOne
	openButton.Text = "🛒 Boutique"
	openButton.Parent = gui
	corner(openButton, 12)

	local window = Instance.new("Frame")
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.fromScale(0.5, 0.5)
	window.Size = UDim2.fromScale(0.9, 0.75)
	window.BackgroundColor3 = Color3.fromRGB(30, 22, 48)
	window.Visible = false
	window.Parent = gui
	corner(window, 16)
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(440, 520)
	limit.Parent = window

	text(window, "🛒 Boutique", UDim2.new(1, -70, 0, 36), UDim2.fromOffset(14, 8))
	local close = Instance.new("TextButton")
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -8, 0, 8)
	close.Size = UDim2.fromOffset(40, 36)
	close.BackgroundColor3 = Color3.fromRGB(170, 50, 70)
	close.TextColor3 = Color3.new(1, 1, 1)
	close.TextScaled = true
	close.Font = Enum.Font.FredokaOne
	close.Text = "✕"
	close.Parent = window
	corner(close, 10)

	local list = Instance.new("ScrollingFrame")
	list.Position = UDim2.fromOffset(10, 52)
	list.Size = UDim2.new(1, -20, 1, -62)
	list.BackgroundTransparency = 1
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = window
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	type Entry = { Button: TextButton, IsPass: boolean, Key: string, Id: number, Price: number }
	local entries: { Entry } = {}

	local function refresh()
		for _, entry in entries do
			if entry.Id <= 0 then
				entry.Button.Text = "Bientôt"
				entry.Button.BackgroundColor3 = Color3.fromRGB(90, 85, 100)
			elseif entry.IsPass and player:GetAttribute(`Pass_{entry.Key}`) == true then
				entry.Button.Text = "Acheté ✅"
				entry.Button.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
			else
				entry.Button.Text = `R$ {entry.Price}`
				entry.Button.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
			end
		end
	end

	local order = 0
	local function addSection(title: string)
		order += 1
		local label = text(list, title, UDim2.new(1, 0, 0, 26), UDim2.new(), Color3.fromRGB(255, 220, 120))
		label.LayoutOrder = order
	end

	local function addEntry(isPass: boolean, item: any)
		order += 1
		local row = Instance.new("Frame")
		row.LayoutOrder = order
		row.Size = UDim2.new(1, -8, 0, 70)
		row.BackgroundColor3 = Color3.fromRGB(50, 40, 75)
		row.Parent = list
		corner(row, 12)
		local stripe = Instance.new("Frame")
		stripe.Size = UDim2.new(0, 8, 1, 0)
		stripe.BackgroundColor3 = item.Color
		stripe.Parent = row
		corner(stripe, 12)
		text(row, item.Name, UDim2.new(0.62, -20, 0, 30), UDim2.fromOffset(18, 6))
		text(
			row,
			item.Description,
			UDim2.new(0.62, -20, 0, 26),
			UDim2.fromOffset(18, 38),
			Color3.fromRGB(200, 195, 215)
		)

		local button = Instance.new("TextButton")
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -10, 0.5, 0)
		button.Size = UDim2.new(0.34, 0, 0, 44)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.TextScaled = true
		button.Font = Enum.Font.FredokaOne
		button.Parent = row
		corner(button, 10)

		local entry: Entry = { Button = button, IsPass = isPass, Key = item.Key, Id = item.Id, Price = item.Price }
		table.insert(entries, entry)

		button.Activated:Connect(function()
			if entry.Id <= 0 then
				return
			end
			if entry.IsPass then
				if player:GetAttribute(`Pass_{entry.Key}`) ~= true then
					MarketplaceService:PromptGamePassPurchase(player, entry.Id)
				end
			else
				MarketplaceService:PromptProductPurchase(player, entry.Id)
			end
		end)

		-- Vrai prix lu sur Roblox (si l'article existe).
		if entry.Id > 0 then
			task.spawn(function()
				local ok, info = pcall(function()
					return MarketplaceService:GetProductInfo(
						entry.Id,
						if isPass then Enum.InfoType.GamePass else Enum.InfoType.Product
					)
				end)
				if ok and info and type(info.PriceInRobux) == "number" then
					entry.Price = info.PriceInRobux
					refresh()
				end
			end)
		end
	end

	addSection("✨ Avantages permanents")
	for _, pass in Monetization.GamePasses do
		addEntry(true, pass)
	end
	addSection("🎁 Bonus")
	for _, product in Monetization.Products do
		addEntry(false, product)
	end
	refresh()

	player.AttributeChanged:Connect(function(name: string)
		if string.sub(name, 1, 5) == "Pass_" then
			refresh()
		end
	end)
	openButton.Activated:Connect(function()
		window.Visible = not window.Visible
	end)
	close.Activated:Connect(function()
		window.Visible = false
	end)
end

return StoreController
