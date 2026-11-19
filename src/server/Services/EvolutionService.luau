--!strict
-- Évolution du personnage : niveau requis + victoires payées → forme suivante (meilleur multiplicateur).
-- Le client demande via le RemoteEvent « Evolve » (sans argument) ; le serveur vérifie tout.
-- Le look de chaque forme (ailes, halo, orbes…) est construit côté joueurs par FormFxController
-- à partir de l'attribut « Evolution » publié par StatsService.

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
	Players.PlayerRemoving:Connect(function(player)
		evolveCooldown:forget(player)
	end)
end

return EvolutionService
