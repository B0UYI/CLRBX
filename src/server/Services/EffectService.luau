--!strict
-- Applique les effets de potion à n'importe quel modèle avec un Humanoid (joueur ou client PNJ).
-- Un seul effet actif par modèle : un nouvel effet remplace l'ancien.

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Effects = require(Shared.Config.Effects)

local EffectService = {}

-- Fonction de nettoyage de l'effet actif, par modèle.
local active: { [Model]: () -> () } = {}

function EffectService.Clear(model: Model)
	local cleanup = active[model]
	active[model] = nil
	if cleanup then
		cleanup()
	end
end

function EffectService.GetName(effectId: string): string
	local def = (Effects :: any)[effectId]
	return if def then def.Name else effectId
end

-- color : couleur de la potion (nuage d'étincelles visible pendant l'effet).
function EffectService.Apply(model: Model, effectId: string, duration: number?, color: Color3?)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local root = humanoid and (humanoid.RootPart or model:FindFirstChild("HumanoidRootPart"))
	if not humanoid or not root or not root:IsA("BasePart") or humanoid.Health <= 0 then
		warn(`[EffectService] Impossible d'appliquer {effectId} à {model:GetFullName()} (pas de Humanoid/RootPart)`)
		return
	end
	local def = (Effects :: any)[effectId]
	if not def then
		warn(`[EffectService] Effet inconnu : {effectId}`)
		return
	end

	EffectService.Clear(model)

	local cleanups: { () -> () } = {}
	local alive = true

	-- Effet visuel commun : « pouf » à l'application + étincelles pendant toute la durée.
	local sparkleColor = color or Color3.new(1, 1, 1)
	local poofAttachment = Instance.new("Attachment")
	poofAttachment.Name = "PotionPoof"
	poofAttachment.Parent = root
	local poof = Instance.new("ParticleEmitter")
	poof.Color = ColorSequence.new(sparkleColor)
	poof.Lifetime = NumberRange.new(0.5, 0.9)
	poof.Speed = NumberRange.new(8, 14)
	poof.SpreadAngle = Vector2.new(180, 180)
	poof.Size = NumberSequence.new(1.2, 0)
	poof.Enabled = false
	poof.Parent = poofAttachment
	poof:Emit(40)
	local sparkles = Instance.new("Sparkles")
	sparkles.SparkleColor = sparkleColor
	sparkles.Parent = root
	table.insert(cleanups, function()
		sparkles:Destroy()
		poofAttachment:Destroy()
	end)

	if def.Scale then
		local ok, err = pcall(function()
			model:ScaleTo(def.Scale)
		end)
		if ok then
			table.insert(cleanups, function()
				if model.Parent then
					model:ScaleTo(1)
				end
			end)
		else
			warn(`[EffectService] ScaleTo a échoué sur {model:GetFullName()} : {err}`)
		end
	end

	if def.WalkSpeedMultiplier then
		local original = humanoid.WalkSpeed
		humanoid.WalkSpeed = original * def.WalkSpeedMultiplier
		table.insert(cleanups, function()
			-- Revient à la vitesse de base (qui a pu changer, ex. bottes achetées entre-temps).
			local base = humanoid:GetAttribute("BaseWalkSpeed")
			humanoid.WalkSpeed = if type(base) == "number" then base else original
		end)
	end

	if def.GravityCancel then
		local attachment = Instance.new("Attachment")
		attachment.Name = "PotionFloat"
		attachment.Parent = root
		local force = Instance.new("VectorForce")
		force.Name = "PotionFloat"
		force.Attachment0 = attachment
		force.RelativeTo = Enum.ActuatorRelativeTo.World
		force.ApplyAtCenterOfMass = true
		force.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity * def.GravityCancel, 0)
		force.Parent = root
		table.insert(cleanups, function()
			force:Destroy()
			attachment:Destroy()
		end)
	end

	if def.Fire then
		local fire = Instance.new("Fire")
		fire.Size = 6
		fire.Heat = 8
		fire.Parent = root
		table.insert(cleanups, function()
			fire:Destroy()
		end)
	end

	if def.CycleSeconds then
		local highlight = Instance.new("Highlight")
		highlight.FillTransparency = 0.35
		highlight.OutlineTransparency = 0.6
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.Parent = model
		task.spawn(function()
			while alive and highlight.Parent do
				local hue = (os.clock() / def.CycleSeconds) % 1
				highlight.FillColor = Color3.fromHSV(hue, 1, 1)
				task.wait(0.1)
			end
		end)
		table.insert(cleanups, function()
			highlight:Destroy()
		end)
	end

	if def.Transparency then
		local originals: { [Instance]: number } = {}
		for _, descendant in model:GetDescendants() do
			local fades = (descendant:IsA("BasePart") and descendant ~= root) or descendant:IsA("Decal")
			if fades then
				local item = descendant :: any
				originals[descendant] = item.Transparency
				item.Transparency = math.max(item.Transparency, def.Transparency)
			end
		end
		table.insert(cleanups, function()
			for instance, transparency in originals do
				if instance:IsA("BasePart") or instance:IsA("Decal") then
					(instance :: any).Transparency = transparency
				end
			end
		end)
	end

	local function cleanup()
		alive = false
		for _, fn in cleanups do
			local ok, err = pcall(fn)
			if not ok then
				warn(`[EffectService] Nettoyage échoué : {err}`)
			end
		end
	end
	active[model] = cleanup

	-- Fin de l'effet après la durée, sauf s'il a été remplacé entre-temps.
	task.delay(duration or Effects.Duration, function()
		if active[model] == cleanup then
			EffectService.Clear(model)
		end
	end)

	-- Pas de fuite si le personnage meurt ou disparaît.
	humanoid.Died:Once(function()
		if active[model] == cleanup then
			active[model] = nil
			alive = false
		end
	end)
end

function EffectService.RandomFailEffect(): string
	local pool = Effects.FailPool
	return pool[math.random(1, #pool)]
end

return EffectService
