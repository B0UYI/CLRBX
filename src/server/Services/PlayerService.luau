--!strict
-- État des joueurs : pièces (leaderstats) et objet tenu en main.
-- Règle : un joueur tient au plus UN objet : un panier d'ingrédients OU une potion.
-- Semaine 1 : pas encore de sauvegarde (ProfileStore arrive en semaine 2).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local NotifyService = require(script.Parent.NotifyService)

local PlayerService = {}

-- Kind = "Basket" (Items = ingrédients) ou "Potion" (Id = recette).
export type HeldItem = { Tool: Tool, Kind: string, Id: string, Items: { string } }

local ITEM_KIND = "ItemKind"
local ITEM_ID = "ItemId"
local ITEM_LIST = "Items"

local ONBOARDING = {
	{ 1, "Bienvenue à Potion Panique ! 🧪" },
	{ 4, "1. Regarde la commande d'un client : elle indique les ingrédients" },
	{ 8, "2. Remplis ton panier aux étagères (E), jusqu'à 3 ingrédients" },
	{ 12, "3. Verse le panier dans le chaudron (E), puis mélange (F)" },
	{ 16, "4. Sers la potion au client 💰 — ou bois-la (clic) pour rire !" },
}

local function setupPlayer(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = Gameplay.Currency.Name
	coins.Value = 0
	coins.Parent = leaderstats
	leaderstats.Parent = player

	local function onCharacter(character: Model)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid and humanoid:IsA("Humanoid") then
			humanoid.WalkSpeed = Gameplay.Player.WalkSpeed
		end
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		task.spawn(onCharacter, player.Character)
	end

	for _, step in ONBOARDING do
		task.delay(step[1], function()
			if player.Parent then
				NotifyService.Send(player, step[2], "info")
			end
		end)
	end
end

local function itemTools(player: Player): { Tool }
	local found = {}
	for _, container in { player.Character, player:FindFirstChildOfClass("Backpack") } do
		if container then
			for _, child in container:GetChildren() do
				if child:IsA("Tool") and child:GetAttribute(ITEM_KIND) then
					table.insert(found, child)
				end
			end
		end
	end
	return found
end

function PlayerService.GetHeld(player: Player): HeldItem?
	local tool = itemTools(player)[1]
	if not tool then
		return nil
	end
	local list = tool:GetAttribute(ITEM_LIST)
	return {
		Tool = tool,
		Kind = tool:GetAttribute(ITEM_KIND) :: string,
		Id = (tool:GetAttribute(ITEM_ID) or "") :: string,
		Items = if type(list) == "string" and list ~= "" then string.split(list, ",") else {},
	}
end

function PlayerService.ClearHeld(player: Player)
	for _, tool in itemTools(player) do
		tool:Destroy()
	end
end

-- Donne un objet au joueur (remplace celui qu'il tenait) et le met en main.
function PlayerService.Give(player: Player, tool: Tool)
	PlayerService.ClearHeld(player)
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then
		tool:Destroy()
		return
	end
	tool.Parent = backpack
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid:EquipTool(tool)
	end
end

function PlayerService.AddCoins(player: Player, amount: number)
	assert(amount >= 0 and amount == math.floor(amount), "Montant invalide")
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild(Gameplay.Currency.Name)
	if coins and coins:IsA("IntValue") then
		coins.Value += amount
	end
end

function PlayerService.ItemAttributes(): (string, string, string)
	return ITEM_KIND, ITEM_ID, ITEM_LIST
end

function PlayerService:Start()
	Players.PlayerAdded:Connect(setupPlayer)
	-- En test Studio, le joueur peut arriver avant le démarrage des scripts.
	for _, player in Players:GetPlayers() do
		if not player:FindFirstChild("leaderstats") then
			setupPlayer(player)
		end
	end
end

return PlayerService
