--!strict
-- Clients PNJ : ils entrent, commandent une potion au comptoir, attendent, paient (ou repartent).

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Ingredients = require(Shared.Config.Ingredients)
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

-- Les clients ne se bloquent pas entre eux.
local COLLISION_GROUP = "Customers"
-- Animation de marche R15 par défaut de Roblox.
local WALK_ANIMATION_ID = "rbxassetid://507777826"
-- Distance au-delà de laquelle un client coincé est replacé directement.
local SNAP_DISTANCE = 2.5

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
	if not humanoid.Parent then
		return
	end
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

-- Trajet porte -> point d'approche (dans l'axe de la place) -> place au comptoir.
-- Passer par l'axe de la place évite de couper devant les autres clients.
local function approachPoint(spot: Vector3): Vector3
	return Vector3.new(spot.X, spot.Y, (spot.Z + WorldService.CustomerEntry.Z) / 2)
end

local function playWalk(humanoid: Humanoid): AnimationTrack?
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = WALK_ANIMATION_ID
	local ok, track = pcall(function()
		return (animator :: Animator):LoadAnimation(animation)
	end)
	if ok and track then
		track.Looped = true
		track:Play()
		return track
	end
	return nil
end

local function stopWalk(track: AnimationTrack?)
	if track then
		track:Stop()
	end
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
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.CollisionGroup = COLLISION_GROUP
		end
	end
	model.Parent = WorldService.Folder
	pcall(function()
		root:SetNetworkOwner(nil) -- le serveur pilote le PNJ
	end)

	-- Bulle de commande.
	local bubble = Instance.new("BillboardGui")
	bubble.Size = UDim2.fromOffset(240, if Config.ShowRecipeHint then 90 else 60)
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

	local hintNames = {}
	for _, id in recipe.Ingredients do
		table.insert(hintNames, Ingredients.ById[id].ShortName)
	end
	local recipeHint = table.concat(hintNames, " + ")

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
			local track = playWalk(humanoid)
			walkTo(humanoid, approachPoint(WorldService.CustomerSpots[spotIndex]))
			walkTo(humanoid, WorldService.CustomerEntry)
			stopWalk(track)
			model:Destroy()
		end)
	end

	task.spawn(function()
		local spot = WorldService.CustomerSpots[spotIndex]
		local track = playWalk(humanoid)
		walkTo(humanoid, approachPoint(spot))
		walkTo(humanoid, spot)
		stopWalk(track)
		if not model.Parent then
			occupied[spotIndex] = nil
			return
		end
		-- Coincé en route ? On le replace à sa place, face au comptoir.
		local flat = Vector3.new(spot.X, root.Position.Y, spot.Z)
		local position = if (root.Position - flat).Magnitude > SNAP_DISTANCE then flat else root.Position
		model:PivotTo(CFrame.lookAt(position, Vector3.new(position.X, position.Y, spot.Z - 10)))

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
			if not given then
				return
			end
			-- Le client boit toujours la potion servie : c'est le spectacle !
			EffectService.Apply(model, given.Effect, nil, given.Color)
			local effectName = EffectService.GetName(given.Effect)
			if given.Id == recipe.Id then
				local tip = math.floor(recipe.Value * Config.TipMax * remaining / Config.PatienceSeconds)
				local total = recipe.Value + tip
				PlayerService.AddCoins(player, total)
				NotifyService.Send(player, `+{total} pièces 💰 (pourboire : {tip})`, "success")
				leave(`Glou glou… Parfait ! 😄 ({effectName})`, Config.ReactionSeconds)
			else
				NotifyService.Send(player, `Oups ! Mauvaise potion… le client devient {effectName} 😂`, "boom")
				leave("Hé !! Ce n'est pas ma commande ! 😠", Config.ReactionSeconds)
			end
		end)

		while not served and remaining > 0 and model.Parent do
			label.Text = if Config.ShowRecipeHint
				then `🧪 {recipe.Name}\n{recipeHint}\n⏳ {remaining} s`
				else `🧪 {recipe.Name}\n⏳ {remaining} s`
			task.wait(1)
			remaining -= 1
		end
		if not served then
			leave("Trop lent… 😤", 1.5)
		end
	end)
end

function CustomerService:Init()
	pcall(function()
		PhysicsService:RegisterCollisionGroup(COLLISION_GROUP)
	end)
	PhysicsService:CollisionGroupSetCollidable(COLLISION_GROUP, COLLISION_GROUP, false)
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
