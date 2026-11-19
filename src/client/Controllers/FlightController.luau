--!strict
-- Vol façon super-héros (côté joueur, pour la réactivité) :
--  • F ou le bouton ✈️ pour décoller / atterrir ;
--  • on vole dans la direction de la caméra (ZQSD / joystick), Espace pour monter, Ctrl pour descendre ;
--  • corps à l'horizontale, tête la première ; debout en vol stationnaire.
-- Pendant une course, le vol est automatique : on suit sa ligne à la vitesse calculée par le serveur.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config")
local Flight = require(Config:WaitForChild("Flight"))
local Race = require(Config:WaitForChild("Race"))

local FlightController = {}

local player = Players.LocalPlayer
-- Distance au-delà de laquelle on se replace directement sur sa ligne de course.
local RACE_SNAP_DISTANCE = 250
local RACE_CORRECTION = 4

type Rig = { Root: BasePart, Attachment: Attachment, Velocity: LinearVelocity, Align: AlignOrientation }

local wantsToFly = false
local rig: Rig? = nil
-- Module de contrôle de Roblox (clavier, manette, joystick mobile).
local controls: any = nil
local currentVelocity = Vector3.zero

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
	if player:GetAttribute("Racing") == true then
		return
	end
	wantsToFly = value
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

local function stepRace(humanoid: Humanoid, root: BasePart)
	local lane = player:GetAttribute("RaceLane")
	local velocity = player:GetAttribute("RaceVelocity")
	local gameState = ReplicatedStorage:FindFirstChild("GameState")
	local startAt = gameState and gameState:GetAttribute("RaceStartAt")
	local durationValue = gameState and gameState:GetAttribute("RaceDuration")
	if typeof(lane) ~= "Vector3" or type(velocity) ~= "number" or type(startAt) ~= "number" then
		return
	end
	local duration = if type(durationValue) == "number" then durationValue else Race.DurationSeconds
	local current = startRig(humanoid, root)
	local now = workspace:GetServerTimeNow()
	local elapsed = math.clamp(now - startAt, 0, duration)
	local expected = lane + Race.Direction * math.min(velocity * elapsed, Race.TrackLength)
	if (expected - root.Position).Magnitude > RACE_SNAP_DISTANCE then
		root.CFrame = CFrame.lookAt(expected, expected + Race.Direction)
	end
	local correction = (expected - root.Position) * RACE_CORRECTION
	local moving = now >= startAt and elapsed < duration
	current.Velocity.VectorVelocity = (if moving then Race.Direction * velocity else Vector3.zero) + correction
	current.Align.CFrame = if moving then horizontal(Race.Direction) else upright(Race.Direction)
end

local function stepFree(humanoid: Humanoid, root: BasePart, dt: number)
	local current = startRig(humanoid, root)
	local direction = inputDirection(humanoid)
	local speedValue = player:GetAttribute("FlySpeed")
	local speed = if type(speedValue) == "number" then speedValue else Flight.LobbySpeedFor(0)
	local alpha = 1 - math.exp(-Flight.Responsiveness * dt)
	currentVelocity = currentVelocity:Lerp(direction * speed, alpha)
	current.Velocity.VectorVelocity = currentVelocity
	local camera = workspace.CurrentCamera
	if currentVelocity.Magnitude > 4 then
		current.Align.CFrame = horizontal(currentVelocity)
	elseif camera then
		current.Align.CFrame = upright(camera.CFrame.LookVector)
	end
end

local function buildButton()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BoutonVol"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local button = Instance.new("TextButton")
	button.AnchorPoint = Vector2.new(1, 1)
	button.Position = UDim2.new(1, -24, 1, -190)
	button.Size = UDim2.fromOffset(120, 52)
	button.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.FredokaOne
	button.Text = "✈️ Voler (F)"
	button.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = button
	button.Activated:Connect(function()
		setWantsToFly(not wantsToFly)
	end)
	return button
end

function FlightController:Start()
	local button = buildButton()
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

	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if not processed and input.KeyCode == Flight.ToggleKey then
			setWantsToFly(not wantsToFly)
		end
	end)
	player:GetAttributeChangedSignal("Racing"):Connect(function()
		if player:GetAttribute("Racing") ~= true then
			-- Fin de course : on atterrit.
			wantsToFly = false
			stopRig()
		end
	end)
	player.CharacterAdded:Connect(function()
		wantsToFly = false
		rig = nil
	end)

	RunService.RenderStepped:Connect(function(dt: number)
		local racing = player:GetAttribute("Racing") == true
		button.Visible = not racing
		button.Text = if wantsToFly then "🛬 Atterrir (F)" else "✈️ Voler (F)"
		local humanoid, root = characterParts()
		if not humanoid or not root or humanoid.Health <= 0 then
			return
		end
		if racing then
			stepRace(humanoid, root)
		elseif wantsToFly then
			stepFree(humanoid, root, dt)
		elseif rig then
			stopRig()
		end
	end)
end

return FlightController
