--!strict
-- N'affiche l'invite « Asperger 💦 » que sur les AUTRES joueurs, quand on tient une potion
-- et que la cible n'est pas protégée. (Affichage local ; le serveur revérifie tout.)

local Players = game:GetService("Players")

local SplashController = {}

local player = Players.LocalPlayer

local function holdsPotion(): boolean
	for _, container in { player.Character, player:FindFirstChildOfClass("Backpack") } do
		if container then
			for _, child in container:GetChildren() do
				if child:IsA("Tool") and child:GetAttribute("ItemKind") == "Potion" then
					return true
				end
			end
		end
	end
	return false
end

function SplashController:Start()
	local prompts: { [ProximityPrompt]: boolean } = {}
	local function track(instance: Instance)
		if instance:IsA("ProximityPrompt") and instance:GetAttribute("SplashTargetUserId") ~= nil then
			prompts[instance] = true
			instance.Enabled = false
			instance.Destroying:Once(function()
				prompts[instance] = nil
			end)
		end
	end
	workspace.DescendantAdded:Connect(track)
	for _, descendant in workspace:GetDescendants() do
		track(descendant)
	end

	while true do
		local hasPotion = holdsPotion()
		for prompt in prompts do
			local userId = prompt:GetAttribute("SplashTargetUserId")
			local target = if type(userId) == "number" then Players:GetPlayerByUserId(userId) else nil
			prompt.Enabled = hasPotion
				and target ~= nil
				and target ~= player
				and target:GetAttribute("NoSplash") ~= true
		end
		task.wait(0.25)
	end
end

return SplashController
