--!strict
-- Au-dessus de chaque joueur : son nom, sa Vitesse, son niveau et sa forme (pour se montrer).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Format = require(Shared.Util.Format)
local StatsService = require(script.Parent.StatsService)

local OverheadService = {}

local labels: { [Player]: TextLabel } = {}

local function build(player: Player, character: Model)
	local head = character:WaitForChild("Head", 10)
	if not head or not head:IsA("BasePart") then
		return
	end
	local gui = Instance.new("BillboardGui")
	gui.Name = "InfosJoueur"
	gui.Size = UDim2.new(5, 0, 1.4, 0)
	gui.StudsOffset = Vector3.new(0, 3.2, 0)
	gui.MaxDistance = 50
	gui.Adornee = head
	gui.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 230, 90)
	label.TextStrokeTransparency = 0.3
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Parent = gui
	labels[player] = label
end

function OverheadService:Start()
	local function watch(player: Player)
		player.CharacterAdded:Connect(function(character)
			build(player, character)
		end)
		if player.Character then
			task.spawn(build, player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		labels[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			for player, label in labels do
				if label.Parent then
					local speedValue = player:GetAttribute("Speed")
					local levelValue = player:GetAttribute("Level")
					local speed = Format.Number(if type(speedValue) == "number" then speedValue else 0)
					local level = if type(levelValue) == "number" then levelValue else 1
					local form = StatsService.Form(player).Name
					label.Text = `{player.DisplayName}\n⚡ {speed} · Niv. {level} · {form}`
				end
			end
		end
	end)
end

return OverheadService
