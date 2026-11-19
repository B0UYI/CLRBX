--!strict
-- Tapis de course : rester dessus fait des pas automatiquement chaque seconde (passif).
-- Chaque tapis se débloque avec un TOTAL de victoires gagnées.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Treadmills = require(Shared.Config.Treadmills)
local Format = require(Shared.Util.Format)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local LobbyService = require(script.Parent.LobbyService)
local NotifyService = require(script.Parent.NotifyService)
local StatsService = require(script.Parent.StatsService)

local TreadmillService = {}

local FIRST_X = 35
local SPACING_X = 13
local ROW_Z = 15
local PLAZA_TOP = 0.4
local BASE_SIZE = Vector3.new(10, 1, 18)
local BELT_SIZE = Vector3.new(8, 0.2, 16)
local LOCK_WARNING_SECONDS = 5

type Built = { Def: Treadmills.Treadmill, Center: Vector3 }
local built: { Built } = {}
local lastLockWarning: { [Player]: number } = {}

local function part(parent: Instance, props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	p.Parent = parent
	return p
end

-- Bande rayée sur le dessus du tapis ; le client la fait défiler (TreadmillController).
local function decorateBelt(belt: BasePart)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top
	gui.Parent = belt
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	local keypoints = {}
	for index = 0, 9 do
		local color = if index % 2 == 0 then Color3.fromRGB(40, 40, 48) else Color3.fromRGB(90, 90, 105)
		table.insert(keypoints, ColorSequenceKeypoint.new(index / 9, color))
	end
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(keypoints)
	gradient.Rotation = 90
	gradient.Parent = frame
	belt:SetAttribute("Belt", true)
end

local function build(folder: Instance)
	for index, def in Treadmills.List do
		local center = Vector3.new(FIRST_X + (index - 1) * SPACING_X, PLAZA_TOP, ROW_Z)
		local base = part(folder, {
			Name = `Tapis_{def.Id}`,
			Size = BASE_SIZE,
			Position = center + Vector3.new(0, BASE_SIZE.Y / 2, 0),
			Color = def.Color,
			Material = Enum.Material.Metal,
		})
		local beltTop = PLAZA_TOP + BASE_SIZE.Y + BELT_SIZE.Y
		local belt = part(folder, {
			Name = "Bande",
			Size = BELT_SIZE,
			Position = Vector3.new(center.X, beltTop - BELT_SIZE.Y / 2, center.Z),
			Color = Color3.fromRGB(50, 50, 60),
			Material = Enum.Material.Rubber,
		})
		decorateBelt(belt)
		for _, side in { -1, 1 } do
			part(folder, {
				Name = "Rambarde",
				Size = Vector3.new(0.4, 0.8, BASE_SIZE.Z),
				Position = Vector3.new(center.X + side * 4.8, beltTop + 0.4, center.Z),
				Color = def.Color,
				Material = Enum.Material.Neon,
				CanCollide = false,
			})
		end
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(200, 70)
		gui.StudsOffset = Vector3.new(0, 5, 0)
		gui.MaxDistance = 90
		gui.Adornee = base
		gui.Parent = base
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
		label.BackgroundTransparency = 0.2
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextScaled = true
		label.Font = Enum.Font.FredokaOne
		local lock = if def.RequiredWins > 0
			then `🔒 {Format.Number(def.RequiredWins)} 🏆 au total`
			else "✅ Pour tous"
		label.Text = `{def.Name}\n{def.StepsPerSecond} pas/s automatiques\n{lock}`
		label.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = label
		table.insert(built, { Def = def, Center = Vector3.new(center.X, beltTop, center.Z) })
	end
end

local function treadmillUnder(root: BasePart): Built?
	for _, treadmill in built do
		local offset = root.Position - treadmill.Center
		if
			math.abs(offset.X) <= BELT_SIZE.X / 2
			and math.abs(offset.Z) <= BELT_SIZE.Z / 2
			and offset.Y >= 0
			and offset.Y <= 7
		then
			return treadmill
		end
	end
	return nil
end

function TreadmillService:Start()
	local lobby = LobbyService.Folder
	assert(lobby, "Le lobby n'a pas été construit")
	local folder = Instance.new("Folder")
	folder.Name = "Tapis"
	folder.Parent = lobby
	build(folder)

	Players.PlayerRemoving:Connect(function(player)
		lastLockWarning[player] = nil
	end)

	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in Players:GetPlayers() do
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local data = DataService.Get(player)
				if player:GetAttribute("Racing") ~= true and data and root and root:IsA("BasePart") then
					local treadmill = treadmillUnder(root)
					if treadmill then
						if data.TotalWins >= treadmill.Def.RequiredWins then
							local gained = StatsService.AddSteps(player, treadmill.Def.StepsPerSecond)
							FxService.Popup(root.Position + Vector3.new(0, 4, 0), `+{Format.Number(gained)} ⚡`)
						elseif os.clock() - (lastLockWarning[player] or 0) >= LOCK_WARNING_SECONDS then
							lastLockWarning[player] = os.clock()
							NotifyService.Send(
								player,
								`🔒 {treadmill.Def.Name} : il faut {Format.Number(treadmill.Def.RequiredWins)} 🏆 au total`,
								"warning"
							)
						end
					end
				end
			end
		end
	end)
end

return TreadmillService
