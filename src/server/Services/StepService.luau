--!strict
-- Améliorations de pas : une rangée de dalles dans le lobby, achetées DANS L'ORDRE avec les Victoires.
-- Chaque palier augmente les points gagnés à chaque pas (+1, +2, +4… par pas).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local Steps = require(Shared.Config.Steps)
local Format = require(Shared.Util.Format)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local LobbyService = require(script.Parent.LobbyService)
local NotifyService = require(script.Parent.NotifyService)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local StepService = {}

local ROW_Z = 46
local SPACING_X = 10
local PLAZA_TOP = 0.4
local buyCooldown = Cooldown.new(0.5)

local function onBuy(player: Player, tier: Steps.Tier, pad: BasePart)
	if not buyCooldown:try(player) then
		return
	end
	local data = DataService.Get(player)
	if not data then
		return
	end
	if data.StepTier >= tier.Index then
		NotifyService.Send(player, "Tu as déjà ce palier ✅", "info")
		return
	end
	if tier.Index ~= data.StepTier + 1 then
		local nextTier = Steps.Tiers[data.StepTier + 1]
		NotifyService.Send(player, `Achète d'abord +{Format.Number(nextTier.Value)} par pas`, "warning")
		return
	end
	local missing = Format.Number(tier.Price - data.Wins)
	if not StatsService.TrySpendWins(player, tier.Price, `Pas_{tier.Value}`) then
		NotifyService.Send(player, `Il te manque {missing} 🏆 : termine des étapes !`, "warning")
		return
	end
	data.StepTier = tier.Index
	StatsService.Sync(player)
	FxService.Confetti(pad.Position + Vector3.new(0, 4, 0), 120)
	FxService.Sound(pad, "Cash")
	NotifyService.Send(player, `👣 Chaque pas vaut maintenant +{Format.Number(tier.Value)} !`, "success")
	OnboardingService.Advance(player, "Bought")
end

function StepService:Start()
	local lobby = LobbyService.Folder
	assert(lobby, "Le lobby n'a pas été construit")
	local folder = Instance.new("Folder")
	folder.Name = "Pas"
	folder.Parent = lobby
	local count = #Steps.Tiers
	for _, tier in Steps.Tiers do
		if tier.Index > 1 then
			local pad = Instance.new("Part")
			pad.Name = `Pas_{tier.Index}`
			pad.Anchored = true
			pad.Size = Vector3.new(7, 0.6, 7)
			pad.Position = Vector3.new((tier.Index - 1 - count / 2) * SPACING_X, PLAZA_TOP + 0.3, ROW_Z)
			pad.Color = Color3.fromHSV((tier.Index / count) * 0.85, 0.75, 1)
			pad.Material = Enum.Material.Neon
			pad.Parent = folder
			local gui = Instance.new("BillboardGui")
			gui.Size = UDim2.new(5, 0, 1.8, 0)
			gui.StudsOffset = Vector3.new(0, 3.5, 0)
			gui.MaxDistance = 45
			gui.Adornee = pad
			gui.Parent = pad
			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1, 1, 1)
			label.TextStrokeTransparency = 0.3
			label.TextScaled = true
			label.Font = Enum.Font.FredokaOne
			label.Text = `+{Format.Number(tier.Value)} / pas\n{Format.Number(tier.Price)} 🏆`
			label.Parent = gui
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Acheter"
			prompt.ObjectText = `+{Format.Number(tier.Value)} par pas`
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.3
			prompt.MaxActivationDistance = Gameplay.Interaction.MaxDistance
			prompt.RequiresLineOfSight = false
			prompt:SetAttribute("StepIndex", tier.Index)
			prompt.Parent = pad
			prompt.Triggered:Connect(function(player: Player)
				onBuy(player, tier, pad)
			end)
		end
	end
	local sign = Instance.new("Part")
	sign.Name = "PanneauPas"
	sign.Anchored = true
	sign.CanCollide = false
	sign.Transparency = 1
	sign.Size = Vector3.new(1, 1, 1)
	sign.Position = Vector3.new(0, 12, ROW_Z)
	sign.Parent = folder
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(16, 0, 2.6, 0)
	gui.MaxDistance = 100
	gui.Adornee = sign
	gui.Parent = sign
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255, 220, 80)
	title.TextStrokeTransparency = 0.2
	title.TextScaled = true
	title.Font = Enum.Font.FredokaOne
	title.Text = "👣 AMÉLIORATIONS DE PAS"
	title.Parent = gui

	Players.PlayerRemoving:Connect(function(player)
		buyCooldown:forget(player)
	end)
end

return StepService
