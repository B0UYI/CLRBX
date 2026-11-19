--!strict
-- Capes en tissu animées, vues par ce joueur sur TOUS les personnages équipés (attribut « Cape »
-- publié par le serveur). Les pans flottent avec la vitesse : tombants à l'arrêt, soulevés en
-- courant, ondulant derrière soi en vol. Tout est local (aucun trafic réseau).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Equipment = require(Shared:WaitForChild("Config"):WaitForChild("Equipment"))
local CapeModel = require(Shared:WaitForChild("Util"):WaitForChild("CapeModel"))

local CapeController = {}

-- Au-delà, la cape n'est plus animée (et cachée) pour économiser.
local MAX_DISTANCE = 260
-- Haut du dos, par rapport au centre du torse R15.
local ANCHOR_OFFSET = CFrame.new(0, 0.7, 0.55)
local SPEED_FOR_FULL_RUN = 30
local SPEED_FOR_FULL_FLIGHT = 140

type Entry = {
	Cape: CapeModel.Cape,
	Character: Model,
	Id: string,
	Lift: number,
	Seed: number,
}

local entries: { [Player]: Entry } = {}
local folder: Folder

local function clear(player: Player)
	local entry = entries[player]
	if entry then
		entry.Cape.Model:Destroy()
		entries[player] = nil
	end
end

local function refresh(player: Player)
	local character = player.Character
	local id = player:GetAttribute("Cape")
	local current = entries[player]
	if current and current.Character == character and current.Id == id then
		return
	end
	clear(player)
	if not character or type(id) ~= "string" then
		return
	end
	local item = Equipment.ById[id]
	if not item or item.Slot ~= "Cape" then
		return
	end
	local cape = CapeModel.Build(item)
	cape.Model.Parent = folder
	entries[player] = { Cape = cape, Character = character, Id = id, Lift = 0.1, Seed = math.random() * 10 }
end

local function animate(dt: number)
	local camera = workspace.CurrentCamera
	local now = os.clock()
	local blend = math.min(1, dt * 6)
	for player, entry in entries do
		local torso = entry.Character:FindFirstChild("UpperTorso")
		local root = entry.Character:FindFirstChild("HumanoidRootPart")
		if
			not entry.Character.Parent
			or not torso
			or not torso:IsA("BasePart")
			or not root
			or not root:IsA("BasePart")
		then
			continue
		end
		local near = not camera or (torso.Position - camera.CFrame.Position).Magnitude < MAX_DISTANCE
		entry.Cape.Model.Parent = if near then folder else nil
		if not near then
			continue
		end
		local velocity = root.AssemblyLinearVelocity
		local flying = player:GetAttribute("Flying") == true
		local factor =
			math.clamp(velocity.Magnitude / (if flying then SPEED_FOR_FULL_FLIGHT else SPEED_FOR_FULL_RUN), 0, 1)
		local target
		if flying then
			-- Corps à l'horizontale : la cape suit le corps et ondule.
			target = math.rad(4 + 12 * factor)
		elseif velocity.Y < -25 then
			-- Chute : la cape remonte.
			target = math.rad(70)
		else
			target = math.rad(6 + 55 * factor)
		end
		entry.Lift += (target - entry.Lift) * blend
		local amplitude = math.rad(2 + 11 * factor)
		local frequency = 3 + 10 * factor
		local angles = table.create(CapeModel.Segments)
		for segment = 1, CapeModel.Segments do
			local share = if segment == 1 then 0.5 else 0.5 / (CapeModel.Segments - 1)
			local wave = amplitude
				* math.sin(now * frequency - segment * 0.9 + entry.Seed)
				* segment
				/ CapeModel.Segments
			angles[segment] = entry.Lift * share + wave
		end
		CapeModel.Pose(entry.Cape, torso.CFrame * ANCHOR_OFFSET, angles)
	end
end

function CapeController:Start()
	folder = Instance.new("Folder")
	folder.Name = "CapesLocales"
	folder.Parent = workspace

	local function watch(player: Player)
		player:GetAttributeChangedSignal("Cape"):Connect(function()
			refresh(player)
		end)
		player.CharacterAdded:Connect(function(character)
			character:WaitForChild("UpperTorso", 10)
			refresh(player)
		end)
		player.CharacterRemoving:Connect(function()
			clear(player)
		end)
		if player.Character then
			task.spawn(refresh, player)
		end
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(clear)
	RunService.RenderStepped:Connect(animate)
end

return CapeController
