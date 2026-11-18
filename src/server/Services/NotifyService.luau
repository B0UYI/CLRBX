--!strict
-- Envoie des messages courts (toasts) à l'écran des joueurs.
-- Sens unique serveur -> client : aucun argument venant du client n'est accepté.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotifyService = {}

local remote: RemoteEvent? = nil

local function getRemote(): RemoteEvent
	if remote then
		return remote
	end
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	local created = Instance.new("RemoteEvent")
	created.Name = "Notify"
	created.Parent = folder
	remote = created
	return created
end

function NotifyService:Init()
	getRemote()
end

-- kind : "info" | "success" | "warning" | "boom"
function NotifyService.Send(player: Player, text: string, kind: string?)
	getRemote():FireClient(player, text, kind or "info")
end

function NotifyService.All(text: string, kind: string?)
	getRemote():FireAllClients(text, kind or "info")
end

return NotifyService
