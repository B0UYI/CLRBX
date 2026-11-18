--!strict
-- Clients PNJ : ils entrent, commandent une potion au comptoir, attendent, paient (ou repartent).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Recipes = require(Shared.Config.Recipes)
local Gameplay = require(Shared.Config.Gameplay)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local EffectService = require(script.Parent.EffectService)
local NotifyService = require(script.Parent.NotifyService)
local PlayerService = require(script.Parent.PlayerService)
local WorldService = require(script.Parent.WorldService)

local CustomerService = {}

local Config = Gameplay.Customers
local occupied: { [number]: boolean } = {}
local serveCooldown = Cooldown.new(0.3)

local SKIN_TONES = {
	Color3.fromRGB(255, 220, 177),
	Color3.fromRGB(234, 192, 134),
	Color3.fromRGB(198, 134, 66),
	Color3.fromRGB(141, 85, 36),
	Color3.fromRGB(92, 58, 33),
}

local function randomColor(): Color3
	return Color3.fromHSV(math.random(), 0.6, 0.9)
end

local function createModel(): Model?
	local description = Instance.new("HumanoidDescription")
	local skin = SKIN_TONES[math.random(1, #SKIN_TONES)]
	description.HeadColor = skin
	description.LeftArmColor = skin
	description.RightArmColor = skin
	description.TorsoColor = randomColor()
	description.LeftLegColor = randomColor()
	description.RightLegColor = description.LeftLegColor
	local ok, result = pcall(function()
		return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	if not ok then
		warn(`[CustomerService] Création du PNJ impossible : {result}`)
		return nil
	end
	return result
end

local function walkTo(humanoid: Humanoid, target: Vector3)
	local arrived = false
	local connection = humanoid.MoveToFinished:Connect(function()
		arrived = true
	end)
	humanoid:MoveTo(target)
	local elapsed = 0
	while not arrived and elapsed < Config.WalkTimeoutSeconds and humanoid.Parent do
		elapsed += task.wait(0.1)
	end
	connection:Disconnect()
end

local function freeSpot(): number?
	for index in WorldService.CustomerSpots do
		if not occupied[index] then
			return index
		end
	end
	return nil
end

local function spawnCustomer(spotIndex: number)
	local recipe = Recipes.List[math.random(1, #Recipes.List)]
	occupied[spotIndex] = true -- réservé avant la création (qui peut prendre du temps)
	local model = createModel()
	if not model then
		occupied[spotIndex] = nil
		return
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid") :: Humanoid
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart
	local head = model:FindFirstChild("Head") :: BasePart
	model.Name = "Client"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	model:PivotTo(CFrame.new(WorldService.CustomerEntry))
	model.Parent = WorldService.Folder
	pcall(function()
		root:SetNetworkOwner(nil) -- le serveur pilote le PNJ
	end)

	-- Bulle de commande.
	local bubble = Instance.new("BillboardGui")
	bubble.Size = UDim2.fromOffset(230, 60)
	bubble.StudsOffset = Vector3.new(0, 3, 0)
	bubble.MaxDistance = 70
	bubble.Adornee = head
	bubble.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.new(1, 1, 1)
	label.TextColor3 = Color3.fromRGB(30, 20, 40)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Text = "…"
	label.Parent = bubble
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label
	local stroke = Instance.new("UIStroke")
	stroke.Color = recipe.Color
	stroke.Thickness = 3
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = label

	local served = false
	local leaving = false
	local remaining = Config.PatienceSeconds
	local prompt: ProximityPrompt? = nil

	local function leave(message: string, delaySeconds: number)
		if leaving then
			return
		end
		leaving = true
		served = true
		if prompt then
			prompt:Destroy()
		end
		label.Text = message
		task.delay(delaySeconds, function()
			occupied[spotIndex] = nil
			if humanoid.Parent then
				walkTo(humanoid, WorldService.CustomerEntry)
			end
			model:Destroy()
		end)
	end

	task.spawn(function()
		walkTo(humanoid, WorldService.CustomerSpots[spotIndex])
		if not model.Parent then
			occupied[spotIndex] = nil
			return
		end
		local spot = WorldService.CustomerSpots[spotIndex]
		model:PivotTo(CFrame.lookAt(root.Position, Vector3.new(root.Position.X, root.Position.Y, spot.Z - 10)))

		local newPrompt = Instance.new("ProximityPrompt")
		newPrompt.ActionText = "Servir"
		newPrompt.ObjectText = recipe.Name
		newPrompt.KeyboardKeyCode = Enum.KeyCode.E
		newPrompt.MaxActivationDistance = Gameplay.Interaction.MaxDistance
		newPrompt.RequiresLineOfSight = false
		newPrompt.Parent = root
		prompt = newPrompt

		newPrompt.Triggered:Connect(function(player: Player)
			if served or not serveCooldown:try(player) then
				return
			end
			local held = PlayerService.GetHeld(player)
			if not held or held.Kind ~= "Potion" then
				NotifyService.Send(player, `Ce client veut une {recipe.Name}. Prépare-la au chaudron !`, "warning")
				return
			end
			local given = Recipes.ById[held.Id]
			held.Tool:Destroy()
			if given and given.Id == recipe.Id then
				local tip = math.floor(recipe.Value * Config.TipMax * remaining / Config.PatienceSeconds)
				local total = recipe.Value + tip
				PlayerService.AddCoins(player, total)
				NotifyService.Send(player, `+{total} pièces 💰 (pourboire : {tip})`, "success")
				leave("Merci ! 😄", 1.5)
			else
				if given then
					EffectService.Apply(model, given.Effect)
					NotifyService.Send(
						player,
						`Oups ! Mauvaise potion… le client devient {EffectService.GetName(given.Effect)} 😂`,
						"boom"
					)
				end
				leave("Hé !! Ce n'est pas ma commande ! 😠", 3)
			end
		end)

		while not served and remaining > 0 and model.Parent do
			label.Text = `🧪 {recipe.Name}\n⏳ {remaining} s`
			task.wait(1)
			remaining -= 1
		end
		if not served then
			leave("Trop lent… 😤", 1.5)
		end
	end)
end

function CustomerService:Start()
	Players.PlayerRemoving:Connect(function(player)
		serveCooldown:forget(player)
	end)
	task.spawn(function()
		while true do
			task.wait(Config.SpawnIntervalSeconds)
			if #Players:GetPlayers() > 0 then
				local waiting = 0
				for _ in occupied do
					waiting += 1
				end
				local spot = freeSpot()
				if spot and waiting < Config.MaxWaiting then
					task.spawn(spawnCustomer, spot)
				end
			end
		end
	end)
end

return CustomerService
