--!strict
-- Affiche « Déjà acheté ✅ » sur les invites de l'Armoire du sorcier pour ce joueur.
-- (Changement local à l'écran du joueur ; l'achat reste vérifié par le serveur.)

local Players = game:GetService("Players")

local UpgradeController = {}

local player = Players.LocalPlayer
local prompts: { ProximityPrompt } = {}

local function refresh(prompt: ProximityPrompt)
	local id = prompt:GetAttribute("UpgradeId")
	if type(id) ~= "string" then
		return
	end
	local owned = player:GetAttribute(`Owns_{id}`) == true
	prompt.ActionText = if owned then "Déjà acheté ✅" else "Acheter"
end

local function track(instance: Instance)
	if instance:IsA("ProximityPrompt") and instance:GetAttribute("UpgradeId") ~= nil then
		table.insert(prompts, instance)
		refresh(instance)
	end
end

function UpgradeController:Start()
	workspace.DescendantAdded:Connect(track)
	for _, descendant in workspace:GetDescendants() do
		track(descendant)
	end
	player.AttributeChanged:Connect(function(name: string)
		if string.sub(name, 1, 5) == "Owns_" then
			for _, prompt in prompts do
				refresh(prompt)
			end
		end
	end)
end

return UpgradeController
