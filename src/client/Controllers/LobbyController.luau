--!strict
-- Détails visuels du lobby, côté joueur :
--  • fait défiler les bandes des tapis de course ;
--  • affiche « Possédé ✅ » sur l'équipement déjà acheté et « 🔒 » sur les portails verrouillés
--    (simple affichage : le serveur revérifie tout).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Worlds = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Worlds"))

local LobbyController = {}

local player = Players.LocalPlayer
local BELT_SPEED = 0.6

function LobbyController:Start()
	local gradients: { UIGradient } = {}
	local prompts: { ProximityPrompt } = {}

	local function refreshPrompt(prompt: ProximityPrompt)
		local stepIndex = prompt:GetAttribute("StepIndex")
		if type(stepIndex) == "number" then
			local tier = player:GetAttribute("StepTier")
			local owned = type(tier) == "number" and tier >= stepIndex
			prompt.ActionText = if owned
				then "Possédé ✅"
				elseif type(tier) == "number" and stepIndex == tier + 1 then "Acheter"
				else "🔒 Palier précédent d'abord"
			return
		end
		local equipId = prompt:GetAttribute("EquipId")
		local worldId = prompt:GetAttribute("WorldId")
		if type(equipId) == "string" then
			local owned = player:GetAttribute(`OwnsEquip_{equipId}`) == true
			prompt.ActionText = if owned then "Possédé ✅" else "Acheter"
		elseif type(worldId) == "string" then
			local world = Worlds.ById[worldId]
			local total = player:GetAttribute("TotalWins")
			local unlocked = world ~= nil and type(total) == "number" and total >= world.RequiredWins
			prompt.ActionText = if unlocked then "Entrer" else "🔒 Verrouillé"
		end
	end

	local function track(instance: Instance)
		if instance:IsA("BasePart") and instance:GetAttribute("Belt") == true then
			local gradient = instance:FindFirstChildWhichIsA("UIGradient", true)
			if gradient then
				table.insert(gradients, gradient)
			end
		elseif
			instance:IsA("ProximityPrompt")
			and (
				instance:GetAttribute("EquipId") ~= nil
				or instance:GetAttribute("WorldId") ~= nil
				or instance:GetAttribute("StepIndex") ~= nil
			)
		then
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
		if string.sub(name, 1, 10) == "OwnsEquip_" or name == "TotalWins" or name == "StepTier" then
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
