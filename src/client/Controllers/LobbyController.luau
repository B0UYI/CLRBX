--!strict
-- Détails visuels du lobby, côté joueur :
--  • fait défiler les bandes des tapis de course ;
--  • affiche « Possédée ✅ » sur les capes déjà achetées (l'achat reste vérifié par le serveur).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LobbyController = {}

local player = Players.LocalPlayer
local BELT_SPEED = 0.6

function LobbyController:Start()
	local gradients: { UIGradient } = {}
	local prompts: { ProximityPrompt } = {}

	local function refreshPrompt(prompt: ProximityPrompt)
		local id = prompt:GetAttribute("CapeId")
		if type(id) == "string" then
			local owned = player:GetAttribute(`OwnsCape_{id}`) == true
			prompt.ActionText = if owned then "Possédée ✅" else "Acheter"
		end
	end

	local function track(instance: Instance)
		if instance:IsA("BasePart") and instance:GetAttribute("Belt") == true then
			local gradient = instance:FindFirstChildWhichIsA("UIGradient", true)
			if gradient then
				table.insert(gradients, gradient)
			end
		elseif instance:IsA("ProximityPrompt") and instance:GetAttribute("CapeId") ~= nil then
			table.insert(prompts, instance)
			refreshPrompt(instance)
		end
	end
	workspace.DescendantAdded:Connect(function(instance)
		-- Laisse le temps aux enfants (SurfaceGui, dégradé) d'arriver.
		task.defer(track, instance)
	end)
	for _, descendant in workspace:GetDescendants() do
		track(descendant)
	end

	player.AttributeChanged:Connect(function(name: string)
		if string.sub(name, 1, 9) == "OwnsCape_" then
			for _, prompt in prompts do
				refreshPrompt(prompt)
			end
		end
	end)

	RunService.RenderStepped:Connect(function()
		-- Le motif se répète tous les 2/9 : on le fait glisser dans cet intervalle.
		local offset = (os.clock() * BELT_SPEED) % (2 / 9)
		for _, gradient in gradients do
			gradient.Offset = Vector2.new(0, offset)
		end
	end)
end

return LobbyController
