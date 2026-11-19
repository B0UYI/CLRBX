--!strict
-- Guide des nouveaux joueurs en 4 étapes (courir → entrer dans un monde → arrivée → équipement).
-- L'étape courante est publiée dans l'attribut joueur « GuideStep » (0 = guide terminé) ;
-- le client affiche la consigne et un rayon lumineux vers la cible (GuideController).
-- Chaque étape est envoyée à l'entonnoir d'accueil de Roblox Analytics.

local Analytics = require(script.Parent.Parent.Util.Analytics)
local DataService = require(script.Parent.DataService)
local FxService = require(script.Parent.FxService)
local NotifyService = require(script.Parent.NotifyService)

local OnboardingService = {}

local STEPS = {
	"Courir",
	"Entrer dans la Prairie",
	"Atteindre l'arrivée",
	"Acheter un équipement",
}

-- Étape atteinte après chaque événement (STEPS + 1 = terminé).
local NEXT_STEP: { [string]: number } = {
	Ran = 2,
	EnteredWorld = 3,
	Finished = 4,
	Bought = 5,
}

local function finish(player: Player)
	player:SetAttribute("GuideStep", 0)
	local data = DataService.Get(player)
	if data then
		data.Onboarded = true
	end
	Analytics.Funnel(player, #STEPS + 1, "Guide terminé")
	NotifyService.Send(
		player,
		"🎓 Bravo, tu es prêt ! Accumule des victoires pour débloquer les mondes suivants 🌍",
		"success"
	)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		FxService.Confetti(root.Position + Vector3.new(0, 4, 0), 150)
	end
end

-- À appeler quand le joueur fait une action du guide. Les étapes ne reculent jamais,
-- et sautent en avant si le joueur va plus vite (ex. il achète avant de finir un parcours).
function OnboardingService.Advance(player: Player, event: string)
	local target = NEXT_STEP[event]
	local current = player:GetAttribute("GuideStep")
	if not target or type(current) ~= "number" or current == 0 or target <= current then
		return
	end
	if target > #STEPS then
		finish(player)
	else
		player:SetAttribute("GuideStep", target)
		Analytics.Funnel(player, target, STEPS[target])
	end
end

function OnboardingService:Start()
	DataService.OnLoaded(function(player: Player, data)
		if data.Onboarded then
			player:SetAttribute("GuideStep", 0)
		else
			player:SetAttribute("GuideStep", 1)
			Analytics.Funnel(player, 1, STEPS[1])
		end
	end)
end

return OnboardingService
