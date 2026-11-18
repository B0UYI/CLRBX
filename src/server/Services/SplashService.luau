--!strict
-- Asperger un autre joueur avec la potion qu'on tient (invite « Asperger 💦 », touche R).
-- Protection : chaque joueur peut refuser d'être aspergé (réglage sauvegardé),
-- et un même joueur ne peut pas être visé en boucle.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Recipes = require(Shared.Config.Recipes)
local Gameplay = require(Shared.Config.Gameplay)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local Remotes = require(script.Parent.Parent.Util.Remotes)
local ChallengeService = require(script.Parent.ChallengeService)
local DataService = require(script.Parent.DataService)
local EffectService = require(script.Parent.EffectService)
local NotifyService = require(script.Parent.NotifyService)
local PlayerService = require(script.Parent.PlayerService)

local SplashService = {}

local Config = Gameplay.Splash
local throwCooldown = Cooldown.new(Config.ThrowCooldownSeconds)
local toggleCooldown = Cooldown.new(Config.ToggleCooldownSeconds)
local lastSplashed: { [Player]: number } = {}

local function rootOf(player: Player): BasePart?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if root and root:IsA("BasePart") then root else nil
end

local function setProtected(player: Player, value: boolean)
	player:SetAttribute("NoSplash", value)
	local data = DataService.Get(player)
	if data then
		data.Settings.NoSplash = value
	end
end

local function onSplash(thrower: Player, target: Player)
	if thrower == target or not throwCooldown:try(thrower) then
		return
	end
	local held = PlayerService.GetHeld(thrower)
	if not held or held.Kind ~= "Potion" then
		NotifyService.Send(thrower, "Il te faut une potion pour asperger !", "warning")
		return
	end
	local recipe = Recipes.ById[held.Id]
	if not recipe then
		return
	end
	if target:GetAttribute("NoSplash") == true then
		NotifyService.Send(thrower, `{target.DisplayName} est protégé(e) 🛡️`, "info")
		return
	end
	local now = os.clock()
	local last = lastSplashed[target]
	if last and now - last < Config.TargetCooldownSeconds then
		NotifyService.Send(thrower, `{target.DisplayName} vient d'être aspergé(e), attends un peu !`, "info")
		return
	end
	local fromRoot = rootOf(thrower)
	local toRoot = rootOf(target)
	local targetCharacter = target.Character
	if not fromRoot or not toRoot or not targetCharacter then
		return
	end
	-- Le serveur revérifie la distance (marge pour la latence).
	if (fromRoot.Position - toRoot.Position).Magnitude > Config.MaxDistance + 4 then
		return
	end

	lastSplashed[target] = now
	held.Tool:Destroy()

	-- Fiole qui vole jusqu'à la cible.
	local bottle = Instance.new("Part")
	bottle.Name = "FioleLancee"
	bottle.Anchored = true
	bottle.CanCollide = false
	bottle.CanQuery = false
	bottle.Size = Vector3.new(0.8, 1.2, 0.8)
	bottle.Color = recipe.Color
	bottle.Material = Enum.Material.Neon
	bottle.Position = fromRoot.Position + Vector3.new(0, 2, 0)
	bottle.Parent = workspace
	local tween = TweenService:Create(
		bottle,
		TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = toRoot.Position + Vector3.new(0, 1, 0), Orientation = Vector3.new(0, 0, 360) }
	)
	tween.Completed:Once(function()
		bottle:Destroy()
		if targetCharacter.Parent then
			EffectService.Apply(targetCharacter, recipe.Effect, nil, recipe.Color)
		end
	end)
	tween:Play()

	local effectName = EffectService.GetName(recipe.Effect)
	NotifyService.Send(thrower, `💦 Tu as aspergé {target.DisplayName} : effet {effectName} !`, "success")
	NotifyService.Send(
		target,
		`💦 {thrower.DisplayName} t'a aspergé(e) : effet {effectName} ! (bouton 🛡️ pour te protéger)`,
		"boom"
	)
	ChallengeService.Progress(thrower, "Splash")
end

local function addPrompt(player: Player, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root or not root:IsA("BasePart") then
		return
	end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "SplashPrompt"
	prompt.ActionText = "Asperger 💦"
	prompt.ObjectText = player.DisplayName
	prompt.KeyboardKeyCode = Enum.KeyCode.R
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonY
	prompt.MaxActivationDistance = Config.MaxDistance
	prompt.RequiresLineOfSight = false
	-- Le client de chaque joueur masque cette invite s'il ne tient pas de potion
	-- (et toujours sur son propre personnage).
	prompt:SetAttribute("SplashTargetUserId", player.UserId)
	prompt.Parent = root
	prompt.Triggered:Connect(function(thrower: Player)
		onSplash(thrower, player)
	end)
end

function SplashService:Init()
	local remote = Remotes.Event("SetSplashProtection")
	remote.OnServerEvent:Connect(function(player: Player, value: unknown)
		if type(value) ~= "boolean" or not toggleCooldown:try(player) then
			return
		end
		setProtected(player, value)
		NotifyService.Send(
			player,
			if value
				then "🛡️ Protection activée : personne ne peut t'asperger"
				else "💦 Protection désactivée : bataille de potions !",
			"info"
		)
	end)
end

function SplashService:Start()
	local function watch(player: Player)
		player:SetAttribute("NoSplash", false)
		player.CharacterAdded:Connect(function(character)
			addPrompt(player, character)
		end)
		if player.Character then
			task.spawn(addPrompt, player, player.Character)
		end
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	DataService.OnLoaded(function(player: Player, data)
		player:SetAttribute("NoSplash", data.Settings.NoSplash == true)
	end)
	Players.PlayerRemoving:Connect(function(player)
		lastSplashed[player] = nil
		throwCooldown:forget(player)
		toggleCooldown:forget(player)
	end)
end

return SplashService
