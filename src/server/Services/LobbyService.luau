--!strict
-- Lobby (autour du point d'apparition) : grande place centrale.
-- Au nord : le terrain de vol libre (Util/Playground).
-- Les portails des mondes, les tapis et le magasin d'équipement sont ajoutés par leurs services.

local Playground = require(script.Parent.Parent.Util.Playground)

local LobbyService = {
	Folder = nil :: Folder?,
}

local function part(parent: Instance, props: { [string]: any }): Part
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		(p :: any)[key] = value
	end
	p.Parent = parent
	return p
end

function LobbyService:Init()
	local existing = workspace:FindFirstChild("Lobby")
	if existing then
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "Lobby"
	LobbyService.Folder = folder

	part(folder, {
		Name = "Place",
		Size = Vector3.new(160, 0.4, 110),
		Position = Vector3.new(0, 0.2, 0),
		Color = Color3.fromRGB(225, 230, 240),
		Material = Enum.Material.Concrete,
	})

	Playground.Build(folder)
	folder.Parent = workspace
end

return LobbyService
