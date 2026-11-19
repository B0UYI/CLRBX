--!strict
-- Orbes de vitesse qui flottent dans le ciel du lobby : on les attrape en volant.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local Format = require(Shared.Util.Format)
local FxService = require(script.Parent.FxService)
local LobbyService = require(script.Parent.LobbyService)
local OnboardingService = require(script.Parent.OnboardingService)
local StatsService = require(script.Parent.StatsService)

local OrbService = {}

local Config = Gameplay.Orbs
local ORB_COLOR = Color3.fromRGB(120, 230, 255)

type Orb = { Part: Part, Light: PointLight, Active: boolean }
local orbs: { Orb } = {}
local random = Random.new()

local function randomPosition(): Vector3
	return Vector3.new(
		random:NextNumber(Config.AreaMin.X, Config.AreaMax.X),
		random:NextNumber(Config.AreaMin.Y, Config.AreaMax.Y),
		random:NextNumber(Config.AreaMin.Z, Config.AreaMax.Z)
	)
end

local function setActive(orb: Orb, active: boolean)
	orb.Active = active
	orb.Part.Transparency = if active then 0 else 1
	orb.Light.Enabled = active
	orb.Part:SetAttribute("Active", active)
end

local function makeOrb(folder: Instance): Orb
	local part = Instance.new("Part")
	part.Name = "Orbe"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(3, 3, 3)
	part.Color = ORB_COLOR
	part.Material = Enum.Material.Neon
	part.Position = randomPosition()
	local light = Instance.new("PointLight")
	light.Color = ORB_COLOR
	light.Range = 10
	light.Brightness = 1.5
	light.Parent = part
	part.Parent = folder
	local orb = { Part = part, Light = light, Active = true }
	setActive(orb, true)
	return orb
end

local function collect(orb: Orb, player: Player)
	setActive(orb, false)
	local gained = StatsService.AddSpeed(player, Config.Gain)
	FxService.Popup(orb.Part.Position, `+{Format.Number(gained)} ⚡`, ORB_COLOR)
	OnboardingService.Advance(player, "Orb")
	task.delay(Config.RespawnSeconds, function()
		orb.Part.Position = randomPosition()
		setActive(orb, true)
	end)
end

function OrbService:Start()
	local lobby = LobbyService.Folder
	assert(lobby, "Le lobby n'a pas été construit")
	local folder = Instance.new("Folder")
	folder.Name = "Orbes"
	folder.Parent = lobby
	for _ = 1, Config.Count do
		table.insert(orbs, makeOrb(folder))
	end

	task.spawn(function()
		while true do
			task.wait(0.15)
			for _, player in Players:GetPlayers() do
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if player:GetAttribute("Racing") ~= true and root and root:IsA("BasePart") then
					for _, orb in orbs do
						if orb.Active and (root.Position - orb.Part.Position).Magnitude <= Config.CollectRadius then
							collect(orb, player)
						end
					end
				end
			end
		end
	end)
end

return OrbService
