--!strict
-- Décorations de la boutique, construites en blocs simples.
-- Une décoration est visible par tout le serveur dès qu'un joueur PRÉSENT la possède.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Upgrades = require(Shared.Config.Upgrades)
local DataService = require(script.Parent.DataService)
local WorldService = require(script.Parent.WorldService)

local DecorService = {}

local FLOOR_TOP = 1
local models: { [string]: Model } = {}

local function part(model: Model, props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	p.Parent = model
	return p
end

local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 90, 90)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 230, 80)),
	ColorSequenceKeypoint.new(0.66, Color3.fromRGB(90, 220, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 110, 255)),
})

local builders: { [string]: (Model) -> () } = {
	lanternes = function(model)
		for _, x in { -20, -7, 7, 20 } do
			for _, z in { -44, -20 } do
				local lantern = part(model, {
					Name = "Lanterne",
					Shape = Enum.PartType.Ball,
					Size = Vector3.new(1.6, 1.6, 1.6),
					Position = Vector3.new(x, FLOOR_TOP + 12, z),
					Color = Color3.fromRGB(255, 200, 120),
					Material = Enum.Material.Neon,
					CanCollide = false,
					CanQuery = false,
				})
				local light = Instance.new("PointLight")
				light.Range = 18
				light.Brightness = 1.5
				light.Color = Color3.fromRGB(255, 200, 140)
				light.Parent = lantern
				TweenService:Create(
					lantern,
					TweenInfo.new(2 + math.random(), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{ Position = lantern.Position + Vector3.new(0, 0.8, 0) }
				):Play()
			end
		end
	end,

	tapis = function(model)
		part(model, {
			Name = "Tapis",
			Size = Vector3.new(6, 0.1, 17),
			Position = Vector3.new(0, FLOOR_TOP + 0.05, -18.5),
			Color = Color3.fromRGB(170, 30, 50),
			Material = Enum.Material.Fabric,
			CanCollide = false,
			CanQuery = false,
		})
		for _, x in { -3.15, 3.15 } do
			part(model, {
				Name = "Bordure",
				Size = Vector3.new(0.3, 0.12, 17),
				Position = Vector3.new(x, FLOOR_TOP + 0.06, -18.5),
				Color = Color3.fromRGB(255, 200, 60),
				Material = Enum.Material.Neon,
				CanCollide = false,
				CanQuery = false,
			})
		end
	end,

	bannieres = function(model)
		for _, x in { -13.5, 13.5 } do
			part(model, {
				Name = "Banniere",
				Size = Vector3.new(2.6, 9, 0.2),
				Position = Vector3.new(x, FLOOR_TOP + 8, -50.8),
				Color = Color3.fromRGB(255, 200, 60),
				Material = Enum.Material.SmoothPlastic,
			})
			local inner = part(model, {
				Name = "BanniereMotif",
				Size = Vector3.new(2, 8, 0.2),
				Position = Vector3.new(x, FLOOR_TOP + 8, -50.65),
				Color = Color3.fromRGB(110, 50, 150),
				Material = Enum.Material.Fabric,
			})
			local gui = Instance.new("SurfaceGui")
			gui.Face = Enum.NormalId.Back -- tournée vers la boutique (+Z)
			gui.Parent = inner
			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.TextScaled = true
			label.Text = "🧪"
			label.Parent = gui
		end
	end,

	fontaine = function(model)
		local center = Vector3.new(-16, FLOOR_TOP, -13)
		local upright = CFrame.Angles(0, 0, math.rad(90))
		part(model, {
			Name = "Bassin",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(1.5, 6, 6),
			CFrame = CFrame.new(center + Vector3.new(0, 0.75, 0)) * upright,
			Color = Color3.fromRGB(150, 150, 165),
			Material = Enum.Material.Marble,
		})
		part(model, {
			Name = "Eau",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.2, 5.4, 5.4),
			CFrame = CFrame.new(center + Vector3.new(0, 1.45, 0)) * upright,
			Color = Color3.fromRGB(90, 220, 255),
			Material = Enum.Material.Neon,
			CanCollide = false,
		})
		local pillar = part(model, {
			Name = "Colonne",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(3, 1, 1),
			CFrame = CFrame.new(center + Vector3.new(0, 3, 0)) * upright,
			Color = Color3.fromRGB(150, 150, 165),
			Material = Enum.Material.Marble,
		})
		local attachment = Instance.new("Attachment")
		attachment.Position = Vector3.new(1.5, 0, 0) -- sommet (axe X du cylindre = vertical)
		attachment.Parent = pillar
		local jet = Instance.new("ParticleEmitter")
		jet.Color = RAINBOW
		jet.Rate = 40
		jet.Lifetime = NumberRange.new(1, 1.4)
		jet.Speed = NumberRange.new(10, 14)
		jet.SpreadAngle = Vector2.new(15, 15)
		jet.Acceleration = Vector3.new(0, -25, 0)
		jet.Size = NumberSequence.new(0.4)
		jet.EmissionDirection = Enum.NormalId.Right -- +X local = vers le haut
		jet.Parent = attachment
		local light = Instance.new("PointLight")
		light.Range = 14
		light.Color = Color3.fromRGB(120, 220, 255)
		light.Parent = pillar
	end,
}

-- Met à jour les décorations visibles. `leaving` : joueur en train de partir (ignoré).
function DecorService.Refresh(leaving: Player?)
	local owned: { [string]: boolean } = {}
	for _, player in Players:GetPlayers() do
		local data = if player ~= leaving then DataService.Get(player) else nil
		if data then
			for _, upgrade in Upgrades.List do
				if upgrade.Kind == "Decor" and data.Upgrades[upgrade.Id] then
					owned[upgrade.Value] = true
				end
			end
		end
	end
	for decorId, model in models do
		model.Parent = if owned[decorId] then WorldService.Folder else nil
	end
end

function DecorService:Start()
	for _, upgrade in Upgrades.List do
		if upgrade.Kind == "Decor" then
			local build = builders[upgrade.Value]
			if build then
				local model = Instance.new("Model")
				model.Name = `Deco_{upgrade.Value}`
				build(model)
				models[upgrade.Value] = model
			else
				warn(`[DecorService] Pas de construction pour la décoration {upgrade.Value}`)
			end
		end
	end
	DataService.OnLoaded(function()
		DecorService.Refresh()
	end)
	Players.PlayerRemoving:Connect(function(player)
		DecorService.Refresh(player)
	end)
end

return DecorService
