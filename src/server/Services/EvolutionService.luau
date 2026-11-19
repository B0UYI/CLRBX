--!strict
-- Évolution du personnage : niveau requis + victoires payées → forme suivante (meilleur multiplicateur).
-- Le client demande via le RemoteEvent « Evolve » (sans argument) ; le serveur vérifie tout.
-- La forme se voit par une couleur (Highlight) et, dès « Éclair », des particules.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Evolutions = require(Shared.Config.Evolutions)
local Steps = require(Shared.Config.Steps)
local Format = require(Shared.Util.Format)
local Cooldown = require(script.Parent.Parent.Util.Cooldown)
local Remotes = require(script.Parent.Parent.Util.Remotes)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local NotifyService = require(script.Parent.NotifyService)
local StatsService = require(script.Parent.StatsService)

local EvolutionService = {}

local evolveCooldown = Cooldown.new(1)

local function dress(player: Player, character: Model)
	for _, name in { "FormeEvolution", "FormeParticules" } do
		local old = character:FindFirstChild(name, true)
		if old then
			old:Destroy()
		end
	end
	local form = StatsService.Form(player)
	if form.Index <= 1 then
		return
	end
	local highlight = Instance.new("Highlight")
	highlight.Name = "FormeEvolution"
	highlight.FillColor = form.Color
	highlight.FillTransparency = 0.7
	highlight.OutlineColor = form.Color
	highlight.OutlineTransparency = 0.2
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.Parent = character
	if form.Particles then
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root then
			local emitter = Instance.new("ParticleEmitter")
			emitter.Name = "FormeParticules"
			emitter.Color = ColorSequence.new(form.Color)
			emitter.LightEmission = 1
			emitter.Rate = 12 + form.Index * 3
			emitter.Lifetime = NumberRange.new(0.6, 1)
			emitter.Speed = NumberRange.new(2, 4)
			emitter.SpreadAngle = Vector2.new(180, 180)
			emitter.Size = NumberSequence.new(0.35, 0)
			emitter.Parent = root
		end
	end
end

local function evolve(player: Player)
	if not evolveCooldown:try(player) then
		return
	end
	local data = DataService.Get(player)
	if not data then
		return
	end
	local nextForm = Evolutions.Forms[data.Evolution + 1]
	if not nextForm then
		NotifyService.Send(player, "Tu es déjà à la forme ultime 🌟", "info")
		return
	end
	local level = Steps.LevelFor(data.Speed)
	if level < nextForm.Level then
		NotifyService.Send(player, `Il faut le niveau {nextForm.Level} (tu es niveau {level})`, "warning")
		return
	end
	if nextForm.Wins > 0 and not StatsService.TrySpendWins(player, nextForm.Wins, `Evolution_{nextForm.Index}`) then
		NotifyService.Send(player, `Il faut {Format.Number(nextForm.Wins)} 🏆 pour évoluer`, "warning")
		return
	end
	data.Evolution = nextForm.Index
	StatsService.Sync(player)
	if player.Character then
		task.spawn(dress, player, player.Character)
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		FxService.Confetti(root.Position + Vector3.new(0, 4, 0), 250)
		FxService.Sound(root, "Cash")
	end
	NotifyService.Send(player, `🧬 Évolution : {nextForm.Name} ! Vitesse ×{nextForm.Multiplier}`, "boom")
end

function EvolutionService:Init()
	Remotes.Event("Evolve").OnServerEvent:Connect(evolve)
end

function EvolutionService:Start()
	DataService.OnLoaded(function(player: Player)
		if player.Character then
			task.spawn(dress, player, player.Character)
		end
	end)
	local function watch(player: Player)
		player.CharacterAdded:Connect(function(character)
			dress(player, character)
		end)
	end
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		evolveCooldown:forget(player)
	end)
end

return EvolutionService
