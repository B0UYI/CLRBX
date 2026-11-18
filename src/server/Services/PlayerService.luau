--!strict
-- État des joueurs : pièces (leaderstats) et objet tenu en main.
-- Règle : un joueur tient au plus UN objet (ingrédient ou potion).
-- Semaine 1 : pas encore de sauvegarde (ProfileStore arrive en semaine 2).

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Gameplay = require(Shared.Config.Gameplay)
local NotifyService = require(script.Parent.NotifyService)

local PlayerService = {}

export type HeldItem = { Tool: Tool, Kind: string, Id: string }

local ITEM_KIND = "ItemKind"
local ITEM_ID = "ItemId"

local ONBOARDING = {
	{ 1, "Bienvenue à Potion Panique ! 🧪" },
	{ 4, "1. Prends un ingrédient sur une étagère (E)" },
	{ 8, "2. Verse 2 ou 3 ingrédients dans le chaudron, puis mélange (F)" },
	{ 12, "3. Sers la bonne potion aux clients au comptoir 💰" },
	{ 16, "Astuce : le grimoire au mur donne les recettes. Tu peux aussi BOIRE une potion (clic) !" },
}

local function setupPlayer(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = Gameplay.Currency.Name
	coins.Value = 0
	coins.Parent = leaderstats
	leaderstats.Parent = player

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
	return {
		Tool = tool,
		Kind = tool:GetAttribute(ITEM_KIND) :: string,
		Id = tool:GetAttribute(ITEM_ID) :: string,
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

function PlayerService.ItemAttributes(): (string, string)
	return ITEM_KIND, ITEM_ID
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
