--!strict
-- Envoi protégé des statistiques Roblox (Creator Hub → Analytics).
-- Une erreur d'analytics ne doit jamais casser le jeu : tout passe par pcall.

local AnalyticsService = game:GetService("AnalyticsService")

local Analytics = {}

local CURRENCY = "Victoires"

-- Étape de l'entonnoir d'accueil (1, 2, 3… dans l'ordre).
function Analytics.Funnel(player: Player, step: number, stepName: string)
	local ok, err = pcall(function()
		AnalyticsService:LogOnboardingFunnelStepEvent(player, step, stepName)
	end)
	if not ok then
		warn(`[Analytics] Entonnoir : {err}`)
	end
end

-- Mouvement de victoires. transactionType : "Gameplay", "Shop", "IAP", "TimedReward", "Onboarding"…
function Analytics.Wins(player: Player, amount: number, balance: number, transactionType: string, sku: string?)
	if amount == 0 then
		return
	end
	local flow = if amount > 0 then Enum.AnalyticsEconomyFlowType.Source else Enum.AnalyticsEconomyFlowType.Sink
	local ok, err = pcall(function()
		AnalyticsService:LogEconomyEvent(player, flow, CURRENCY, math.abs(amount), balance, transactionType, sku)
	end)
	if not ok then
		warn(`[Analytics] Économie : {err}`)
	end
end

return Analytics
