--!strict
-- Vol façon super-héros (côté joueur, pour la réactivité) :
--  • F ou le bouton ✈️ pour décoller / atterrir ; Maj (ou 🚀) pour le BOOST (×1,8, vide l'endurance) ;
--  • on vole dans la direction de la caméra, Espace pour monter, Ctrl pour descendre ;
--  • corps à l'horizontale, tête la première ; debout en vol stationnaire.
-- Le serveur gère l'endurance : quand il coupe le vol (« Flying » = false), on retombe.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Flight = require(Config:WaitForChild("Flight"))

local FlightController = {}

local player = Players.LocalPlayer

type Rig = { Root: BasePart, Attachment: Attachment, Velocity: LinearVelocity, Align: AlignOrientation }

local wantsToFly = false
local wantsBoost = false
local rig: Rig? = nil
-- Module de contrôle de Roblox (clavier, manette, joystick mobile).
local controls: any = nil
local currentVelocity = Vector3.zero
local bank = 0
local lastHeading: Vector3? = nil
-- Bonus des barrières de vent (mur du son) jusqu'à cet instant (os.clock()).
local windBoostUntil = 0
-- Le mur du son se déclenche une fois par boost, quand on atteint la vitesse max.
local boomReady = true
local justTookOff = false
local handTrails: { Trail } = {}

local function characterParts(): (Humanoid?, BasePart?)
	local character = player.Character
	if not character then
		return nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	return humanoid, if root and root:IsA("BasePart") then root else nil
end

local function stopRig()
	for _, trail in handTrails do
		trail:Destroy()
	end
	table.clear(handTrails)
	if rig then
		rig.Velocity:Destroy()
		rig.Align:Destroy()
		rig.Attachment:Destroy()
		rig = nil
	end
	local humanoid = characterParts()
	if humanoid and humanoid.PlatformStand then
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
end

local function shockwave(position: Vector3, direction: Vector3, color: Color3, finalSize: number)
	local ring = Instance.new("Part")
	ring.Name = "OndeDeChoc"
	ring.Anchored = true
	ring.CanCollide = false
	ring.CanQuery = false
	ring.CanTouch = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.ForceField
	ring.Color = color
	ring.Size = Vector3.new(0.6, 4, 4)
	ring.CFrame = CFrame.lookAt(position, position + direction) * CFrame.Angles(0, math.pi / 2, 0)
	ring.Parent = workspace.CurrentCamera
	TweenService:Create(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.6, finalSize, finalSize),
		Transparency = 1,
	}):Play()
	Debris:AddItem(ring, 0.5)
end

local function startRig(humanoid: Humanoid, root: BasePart): Rig
	local existing = rig
	if existing and existing.Root == root and existing.Velocity.Parent == root then
		return existing
	end
	stopRig()
	local attachment = Instance.new("Attachment")
	attachment.Name = "VolAttache"
	attachment.Parent = root
	local velocity = Instance.new("LinearVelocity")
	velocity.Name = "VolVitesse"
	velocity.Attachment0 = attachment
	velocity.MaxForce = math.huge
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VectorVelocity = Vector3.zero
	velocity.Parent = root
	local align = Instance.new("AlignOrientation")
	align.Name = "VolOrientation"
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0 = attachment
	align.MaxTorque = math.huge
	align.Responsiveness = 30
	align.CFrame = root.CFrame.Rotation
	align.Parent = root
	-- PlatformStand : le personnage ne marche plus et ses animations s'arrêtent (pose figée).
	humanoid.PlatformStand = true
	currentVelocity = root.AssemblyLinearVelocity
	-- Traînées d'air au bout des mains (vues par ce joueur).
	table.clear(handTrails)
	local character = root.Parent
	for _, handName in { "RightHand", "LeftHand" } do
		local hand = character and character:FindFirstChild(handName)
		if hand and hand:IsA("BasePart") then
			local a0 = Instance.new("Attachment")
			a0.Name = "VolTraineeA"
			a0.Position = Vector3.new(0, 0.3, 0)
			a0.Parent = hand
			local a1 = Instance.new("Attachment")
			a1.Name = "VolTraineeB"
			a1.Position = Vector3.new(0, -0.3, 0)
			a1.Parent = hand
			local trail = Instance.new("Trail")
			trail.Name = "VolTrainee"
			trail.Attachment0 = a0
			trail.Attachment1 = a1
			trail.Lifetime = 0.35
			trail.LightEmission = 0.8
			trail.Transparency = NumberSequence.new(0.3, 1)
			trail.Color = ColorSequence.new(Color3.fromRGB(220, 245, 255))
			trail.Enabled = false
			trail.Parent = hand
			table.insert(handTrails, trail)
		end
	end
	if justTookOff then
		-- Décollage : élan vers le haut + onde de poussière au sol.
		justTookOff = false
		currentVelocity = Vector3.yAxis * 45 + currentVelocity
		shockwave(root.Position - Vector3.new(0, 3, 0), Vector3.yAxis, Color3.fromRGB(230, 220, 200), 22)
	end
	local newRig = { Root = root, Attachment = attachment, Velocity = velocity, Align = align }
	rig = newRig
	return newRig
end

-- Corps à l'horizontale, tête dans la direction du vol, ventre vers le sol.
local function horizontal(direction: Vector3): CFrame
	local unit = direction.Unit
	local up = if math.abs(unit.Y) > 0.95 then Vector3.zAxis else Vector3.yAxis
	return CFrame.lookAt(Vector3.zero, unit, up) * CFrame.Angles(-math.pi / 2, 0, 0)
end

-- Debout, tourné vers l'horizon de la caméra (vol stationnaire, compte à rebours).
local function upright(look: Vector3): CFrame
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 1e-3 then
		flat = Vector3.new(0, 0, -1)
	end
	return CFrame.lookAt(Vector3.zero, flat)
end

local function setWantsToFly(value: boolean)
	wantsToFly = value
	if value then
		justTookOff = true
		boomReady = true
	end
	local remote = ReplicatedStorage:FindFirstChild("Remotes")
	local setFlying = remote and remote:FindFirstChild("SetFlying")
	if setFlying and setFlying:IsA("RemoteEvent") then
		setFlying:FireServer(value)
	end
	if not value then
		stopRig()
	end
end

-- Direction voulue : avant/arrière suivant la caméra (y compris vers le haut/bas), plus Espace/Ctrl.
local function inputDirection(humanoid: Humanoid): Vector3
	local camera = workspace.CurrentCamera
	local direction = Vector3.zero
	-- 1) Vecteur brut des commandes (x = droite, z = -avant), fiable même en vol.
	local ok, moveVector = pcall(function()
		return if controls then controls:GetMoveVector() else nil
	end)
	if camera and ok and typeof(moveVector) == "Vector3" and moveVector.Magnitude > 0.05 then
		direction = camera.CFrame.LookVector * -moveVector.Z + camera.CFrame.RightVector * moveVector.X
	end
	-- 2) Secours : direction de marche du Humanoid.
	local move = humanoid.MoveDirection
	if camera and direction.Magnitude < 0.05 and move.Magnitude > 0.05 then
		local look = camera.CFrame.LookVector
		local right = camera.CFrame.RightVector
		local flatLook = Vector3.new(look.X, 0, look.Z)
		local flatRight = Vector3.new(right.X, 0, right.Z)
		if flatLook.Magnitude > 1e-3 and flatRight.Magnitude > 1e-3 then
			local forwardAmount = move:Dot(flatLook.Unit)
			local rightAmount = move:Dot(flatRight.Unit)
			direction = look * forwardAmount + right * rightAmount
		end
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		direction += Vector3.yAxis
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then
		direction -= Vector3.yAxis
	end
	if direction.Magnitude > 1 then
		direction = direction.Unit
	end
	return direction
end

local function fire(name: string, value: boolean)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local remote = remotes and remotes:FindFirstChild(name)
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(value)
	end
end

local function setBoost(value: boolean)
	if wantsBoost ~= value then
		wantsBoost = value
		fire("SetBoost", value)
	end
end

-- Mur du son : onde de choc, son, et bonus de vitesse temporaire.

local fovKick = 0

local function sonicBoom(root: BasePart, giveBoost: boolean)
	if giveBoost then
		windBoostUntil = os.clock() + Flight.WindBoostSeconds
	end
	fovKick = 14
	local direction = if currentVelocity.Magnitude > 1 then currentVelocity.Unit else root.CFrame.LookVector
	shockwave(root.Position, direction, Color3.fromRGB(200, 240, 255), 50)
	task.delay(0.08, shockwave, root.Position - direction * 6, direction, Color3.new(1, 1, 1), 30)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/swoosh.wav"
	sound.Volume = 1
	sound.PlaybackSpeed = 0.7
	sound.Parent = root
	sound:Play()
	Debris:AddItem(sound, 2)
end

local function stepFree(humanoid: Humanoid, root: BasePart, dt: number)
	local current = startRig(humanoid, root)
	local direction = inputDirection(humanoid)
	local speedValue = player:GetAttribute("FlySpeed")
	local base = if type(speedValue) == "number" then speedValue else Flight.FlySpeedFor(0)
	local speed = if player:GetAttribute("Boosting") == true then base * Flight.BoostMultiplier else base
	if os.clock() < windBoostUntil then
		speed *= Flight.WindBoostMultiplier
	end
	if direction.Magnitude > 0.05 then
		local alpha = 1 - math.exp(-Flight.Responsiveness * dt)
		currentVelocity = currentVelocity:Lerp(direction * speed, alpha)
	else
		-- Pas de commande : on plane sur sa lancée.
		currentVelocity *= math.exp(-Flight.GlideDrag * dt)
	end
	current.Velocity.VectorVelocity = currentVelocity
	local boosting = player:GetAttribute("Boosting") == true
	if boosting and boomReady and currentVelocity.Magnitude >= speed * 0.95 then
		boomReady = false
		sonicBoom(root, false)
	elseif not boosting then
		boomReady = true
	end
	for _, trail in handTrails do
		trail.Enabled = currentVelocity.Magnitude > 60
	end

	-- Inclinaison dans les virages, selon la vitesse de rotation du cap.
	local flat = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
	local targetBank = 0
	if flat.Magnitude > 8 then
		local heading = flat.Unit
		if lastHeading and dt > 0 then
			local turn = lastHeading:Cross(heading).Y
			targetBank = math.clamp(-turn / dt * Flight.BankFactor, -Flight.MaxBank, Flight.MaxBank)
		end
		lastHeading = heading
	else
		lastHeading = nil
	end
	bank += (targetBank - bank) * math.min(1, dt * 6)

	local camera = workspace.CurrentCamera
	if currentVelocity.Magnitude > 4 then
		current.Align.CFrame = horizontal(currentVelocity) * CFrame.Angles(0, bank, 0)
	elseif camera then
		current.Align.CFrame = upright(camera.CFrame.LookVector)
	end
end

local function makeButton(parent: Instance, position: UDim2, color: Color3): TextButton
	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = position
	button.Size = UDim2.fromOffset(130, 52)
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.FredokaOne
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = button
	return button
end

function FlightController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BoutonsVol"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local flyButton = makeButton(gui, UDim2.new(1, -24, 1, -190), Color3.fromRGB(60, 140, 255))
	local boostButton = makeButton(gui, UDim2.new(1, -24, 1, -250), Color3.fromRGB(255, 120, 40))
	boostButton.Text = "🚀 Boost (Maj)"

	task.spawn(function()
		local scripts = player:WaitForChild("PlayerScripts", 10)
		local module = scripts and scripts:WaitForChild("PlayerModule", 10)
		if module and module:IsA("ModuleScript") then
			local ok, result = pcall(function()
				return (require(module) :: any):GetControls()
			end)
			if ok then
				controls = result
			else
				warn(`[FlightController] Commandes Roblox indisponibles : {result}`)
			end
		end
	end)

	flyButton.Activated:Connect(function()
		setWantsToFly(not wantsToFly)
	end)
	boostButton.MouseButton1Down:Connect(function()
		setBoost(true)
	end)
	boostButton.MouseButton1Up:Connect(function()
		setBoost(false)
	end)
	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed then
			return
		end
		if input.KeyCode == Flight.ToggleKey then
			setWantsToFly(not wantsToFly)
		elseif input.KeyCode == Flight.BoostKey then
			setBoost(true)
		end
	end)
	UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.KeyCode == Flight.BoostKey then
			setBoost(false)
		end
	end)
	-- Le serveur coupe le vol (plus d'endurance, réapparition) : on retombe.
	player:GetAttributeChangedSignal("Flying"):Connect(function()
		if player:GetAttribute("Flying") ~= true and wantsToFly then
			wantsToFly = false
			setBoost(false)
			stopRig()
		end
	end)
	player.CharacterAdded:Connect(function()
		wantsToFly = false
		rig = nil
	end)

	-- Lignes de vitesse : un volume invisible devant la caméra émet des traits vers elle.
	local streaks = Instance.new("Part")
	streaks.Name = "LignesDeVitesse"
	streaks.Anchored = true
	streaks.CanCollide = false
	streaks.CanQuery = false
	streaks.CanTouch = false
	streaks.Transparency = 1
	streaks.Size = Vector3.new(40, 26, 1)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Shape = Enum.ParticleEmitterShape.Box
	emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	emitter.EmissionDirection = Enum.NormalId.Back
	emitter.Orientation = Enum.ParticleOrientation.VelocityParallel
	emitter.Speed = NumberRange.new(90, 130)
	emitter.Lifetime = NumberRange.new(0.25, 0.35)
	emitter.Size = NumberSequence.new(0.08)
	emitter.Squash = NumberSequence.new(-3)
	emitter.LightEmission = 1
	emitter.Transparency = NumberSequence.new(0.35, 1)
	emitter.Rate = 0
	emitter.Parent = streaks

	-- Barrières de vent (disques marqués « Vent » = rayon), traversées détectées ici.
	local winds: { BasePart } = {}
	local sides: { [BasePart]: number } = {}
	local function trackWind(instance: Instance)
		if instance:IsA("BasePart") and instance:GetAttribute("Vent") ~= nil then
			table.insert(winds, instance)
		end
	end
	workspace.DescendantAdded:Connect(trackWind)
	for _, descendant in workspace:GetDescendants() do
		trackWind(descendant)
	end

	local blur = Instance.new("BlurEffect")
	blur.Name = "VolFlou"
	blur.Size = 0
	blur.Parent = Lighting
	local grading = Instance.new("ColorCorrectionEffect")
	grading.Name = "VolCouleur"
	grading.Parent = Lighting
	local windSound = Instance.new("Sound")
	windSound.Name = "VentDeVol"
	windSound.SoundId = "rbxasset://sounds/swoosh.wav"
	windSound.Looped = true
	windSound.Volume = 0
	windSound.Parent = gui
	windSound:Play()

	local shakeTime = 0
	RunService:BindToRenderStep("VolCamera", Enum.RenderPriority.Camera.Value + 1, function(dt: number)
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		streaks.Parent = camera
		local speed = if rig then currentVelocity.Magnitude else 0
		local ratio = math.clamp(speed / Flight.FovSpeedForMax, 0, 1)
		fovKick = math.max(0, fovKick - dt * 30)
		local boostingNow = player:GetAttribute("Boosting") == true and rig ~= nil
		local targetFov = Flight.BaseFov + (Flight.MaxFov - Flight.BaseFov) * ratio + fovKick
		camera.FieldOfView += (targetFov - camera.FieldOfView) * math.min(1, dt * 5)
		-- Roulis de la caméra avec les virages : on « sent » l'inclinaison.
		if rig then
			camera.CFrame *= CFrame.Angles(0, 0, bank * 0.3)
		end
		blur.Size += ((if boostingNow then 3 + ratio * 3 else 0) - blur.Size) * math.min(1, dt * 6)
		grading.Saturation = 0.25 * ratio
		grading.Contrast = 0.1 * ratio
		windSound.Volume = 0.7 * ratio
		windSound.PlaybackSpeed = 0.6 + ratio * 0.8
		streaks.CFrame = camera.CFrame * CFrame.new(0, 0, -28)
		emitter.Rate = if speed > 60 then math.min(160, (speed - 60) * 0.8) else 0
		if speed > Flight.ShakeFromSpeed then
			shakeTime += dt
			local amount = math.min(1, (speed - Flight.ShakeFromSpeed) / 200) * 0.004
			camera.CFrame *= CFrame.Angles(math.sin(shakeTime * 40) * amount, math.cos(shakeTime * 33) * amount, 0)
		end
	end)

	RunService.RenderStepped:Connect(function(dt: number)
		local _, windRoot = characterParts()
		if wantsToFly and windRoot then
			for _, wind in winds do
				if wind.Parent then
					local offset = windRoot.Position - wind.Position
					local side = offset:Dot(wind.CFrame.RightVector) -- axe du disque (X)
					local radius = wind:GetAttribute("Vent")
					local previous = sides[wind]
					sides[wind] = side
					if previous and math.sign(previous) ~= math.sign(side) and type(radius) == "number" then
						local lateral = offset - wind.CFrame.RightVector * side
						if lateral.Magnitude <= radius then
							sonicBoom(windRoot, true)
						end
					end
				end
			end
		end
		flyButton.Text = if wantsToFly then "🛬 Atterrir (F)" else "✈️ Voler (F)"
		boostButton.Visible = wantsToFly
		local humanoid, root = characterParts()
		if not humanoid or not root or humanoid.Health <= 0 then
			return
		end
		if wantsToFly then
			stepFree(humanoid, root, dt)
		elseif rig then
			stopRig()
		end
	end)
end

return FlightController
