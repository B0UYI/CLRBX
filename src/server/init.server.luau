--!strict
-- Point d'entrée serveur : charge et démarre chaque service de ./Services.
-- Règle d'or : le serveur fait autorité sur tout ce qui a de la valeur (monnaie, inventaire, achats).

local Services = script:WaitForChild("Services")

local loaded = {}
for _, module in Services:GetChildren() do
	if module:IsA("ModuleScript") then
		loaded[module.Name] = require(module) :: any
	end
end

for _, service in loaded do
	if type(service.Init) == "function" then
		service:Init()
	end
end

for _, service in loaded do
	if type(service.Start) == "function" then
		task.spawn(service.Start, service)
	end
end

print(`[CLRBX] Serveur démarré ({#Services:GetChildren()} services)`)
