--!strict
-- Crée (ou retrouve) un RemoteEvent dans ReplicatedStorage.Remotes.
-- Tout argument reçu du client doit être validé (type, bornes, cadence) par le service qui écoute.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

function Remotes.Event(name: string): RemoteEvent
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	local existing = folder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote
end

return Remotes
