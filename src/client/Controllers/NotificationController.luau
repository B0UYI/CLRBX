--!strict
-- Affiche les messages du serveur sous forme de bulles en haut de l'écran.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local NotificationController = {}

local MAX_TOASTS = 3
local VISIBLE_SECONDS = 2.8

local COLORS: { [string]: Color3 } = {
	info = Color3.fromRGB(45, 35, 70),
	success = Color3.fromRGB(30, 120, 70),
	warning = Color3.fromRGB(160, 100, 20),
	boom = Color3.fromRGB(170, 40, 60),
}

local container: Frame

local function buildGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Notifications"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.DisplayOrder = 10
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 62) -- sous le bandeau de course
	frame.Size = UDim2.new(0.9, 0, 0.5, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = gui

	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(420, math.huge)
	constraint.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = frame

	container = frame
end

local order = 0

local function show(text: string, kind: string)
	-- Trop de bulles : on retire la plus ancienne.
	local toasts = {}
	for _, child in container:GetChildren() do
		if child:IsA("TextLabel") then
			table.insert(toasts, child)
		end
	end
	if #toasts >= MAX_TOASTS then
		table.sort(toasts, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		toasts[1]:Destroy()
	end

	order += 1
	local label = Instance.new("TextLabel")
	label.LayoutOrder = order
	label.Size = UDim2.new(1, 0, 0, 30)
	label.BackgroundColor3 = COLORS[kind] or COLORS.info
	label.BackgroundTransparency = 0.1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.Text = text
	label.Parent = container

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = label
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label

	task.delay(VISIBLE_SECONDS, function()
		if not label.Parent then
			return
		end
		local tween =
			TweenService:Create(label, TweenInfo.new(0.4), { BackgroundTransparency = 1, TextTransparency = 1 })
		tween:Play()
		tween.Completed:Wait()
		label:Destroy()
	end)
end

function NotificationController:Start()
	buildGui()
	local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Notify") :: RemoteEvent
	remote.OnClientEvent:Connect(function(text: unknown, kind: unknown)
		if type(text) == "string" then
			show(text, if type(kind) == "string" then kind else "info")
		end
	end)
end

return NotificationController
