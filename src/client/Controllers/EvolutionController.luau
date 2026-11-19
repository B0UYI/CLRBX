--!strict
-- Fenêtre « Évoluer » : forme actuelle → forme suivante, multiplicateurs, niveau et victoires requis.
-- Le bouton envoie le RemoteEvent « Evolve » ; le serveur vérifie et applique.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Evolutions = require(Shared:WaitForChild("Config"):WaitForChild("Evolutions"))
local Format = require(Shared:WaitForChild("Util"):WaitForChild("Format"))

local EvolutionController = {}

local player = Players.LocalPlayer

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local function label(parent: Instance, size: UDim2, position: UDim2, color: Color3?): TextLabel
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = position
	l.BackgroundTransparency = 1
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.TextScaled = true
	l.Font = Enum.Font.FredokaOne
	l.Parent = parent
	return l
end

local function button(parent: Instance, textValue: string, color: Color3): TextButton
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextScaled = true
	b.Font = Enum.Font.FredokaOne
	b.Text = textValue
	b.Parent = parent
	corner(b, 12)
	return b
end

function EvolutionController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Evolution"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 6
	gui.Parent = player:WaitForChild("PlayerGui")

	local open = button(gui, "🧬 Évoluer", Color3.fromRGB(60, 170, 90))
	open.AnchorPoint = Vector2.new(1, 0.5)
	open.Position = UDim2.new(1, -12, 0.5, 60)
	open.Size = UDim2.fromOffset(130, 46)

	local window = Instance.new("Frame")
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.fromScale(0.5, 0.5)
	window.Size = UDim2.fromOffset(440, 300)
	window.BackgroundColor3 = Color3.fromRGB(25, 45, 30)
	window.Visible = false
	window.Parent = gui
	corner(window, 16)
	label(window, UDim2.new(1, -60, 0, 40), UDim2.fromOffset(16, 8)).Text = "🧬 Évoluer"
	local close = button(window, "✕", Color3.fromRGB(170, 50, 70))
	close.AnchorPoint = Vector2.new(1, 0)
	close.Position = UDim2.new(1, -8, 0, 8)
	close.Size = UDim2.fromOffset(40, 36)

	local before = label(window, UDim2.new(0.4, 0, 0, 70), UDim2.new(0.05, 0, 0, 60))
	label(window, UDim2.new(0.1, 0, 0, 50), UDim2.new(0.45, 0, 0, 70)).Text = "➡️"
	local after = label(window, UDim2.new(0.4, 0, 0, 70), UDim2.new(0.55, 0, 0, 60), Color3.fromRGB(255, 230, 90))
	local levelNeed = label(window, UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 145))
	local winsNeed = label(window, UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 0, 180), Color3.fromRGB(255, 200, 60))
	local evolve = button(window, "Évoluer", Color3.fromRGB(60, 170, 90))
	evolve.Position = UDim2.new(0.25, 0, 0, 230)
	evolve.Size = UDim2.new(0.5, 0, 0, 50)

	local function refresh()
		local index = math.clamp(player:GetAttribute("Evolution") :: number? or 1, 1, #Evolutions.Forms)
		local current = Evolutions.Forms[index]
		local nextForm = Evolutions.Forms[index + 1]
		before.Text = `{current.Name}\n×{current.Multiplier} Vitesse`
		local level = player:GetAttribute("Level")
		local wins = player:GetAttribute("Wins")
		local myLevel = if type(level) == "number" then level else 1
		local myWins = if type(wins) == "number" then wins else 0
		if nextForm then
			after.Text = `{nextForm.Name}\n×{nextForm.Multiplier} Vitesse`
			levelNeed.Text = `Niveau {myLevel}/{nextForm.Level}`
			winsNeed.Text = `{Format.Number(myWins)}/{Format.Number(nextForm.Wins)} victoires requises`
			local ready = myLevel >= nextForm.Level and myWins >= nextForm.Wins
			evolve.Text = "Évoluer"
			evolve.BackgroundColor3 = if ready then Color3.fromRGB(60, 170, 90) else Color3.fromRGB(90, 95, 100)
			open.Text = if ready then "🧬 Évoluer !" else "🧬 Évoluer"
		else
			after.Text = "Forme ultime 🌟"
			levelNeed.Text = ""
			winsNeed.Text = ""
			evolve.Text = "Max"
			evolve.BackgroundColor3 = Color3.fromRGB(90, 95, 100)
		end
	end

	open.Activated:Connect(function()
		window.Visible = not window.Visible
		refresh()
	end)
	close.Activated:Connect(function()
		window.Visible = false
	end)
	evolve.Activated:Connect(function()
		local remotes = ReplicatedStorage:FindFirstChild("Remotes")
		local remote = remotes and remotes:FindFirstChild("Evolve")
		if remote and remote:IsA("RemoteEvent") then
			remote:FireServer()
		end
	end)
	player.AttributeChanged:Connect(function(name: string)
		if name == "Evolution" or name == "Level" or name == "Wins" then
			refresh()
		end
	end)
	refresh()
end

return EvolutionController
