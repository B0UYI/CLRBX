--!strict
-- Point d'entrée client : charge et démarre chaque contrôleur de ./Controllers.
-- Le client affiche et demande ; il ne décide jamais de ce qui a de la valeur.

local Controllers = script:WaitForChild("Controllers")

local loaded = {}
for _, module in Controllers:GetChildren() do
	if module:IsA("ModuleScript") then
		loaded[module.Name] = require(module) :: any
	end
end

for _, controller in loaded do
	if type(controller.Init) == "function" then
		controller:Init()
	end
end

for _, controller in loaded do
	if type(controller.Start) == "function" then
		task.spawn(controller.Start, controller)
	end
end
