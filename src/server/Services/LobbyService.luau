--!strict
-- Lobby (autour du point d'apparition) : place centrale et grand tableau de la prochaine course.
-- Les tapis, le magasin de capes et les orbes sont ajoutés par leurs services dans ce dossier.

local LobbyService = {
	Folder = nil :: Folder?,
}

local boardLabel: TextLabel? = nil

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

-- Texte du grand tableau (ex. « 🏁 PROCHAINE COURSE\n0:32 »).
function LobbyService.SetBoardText(text: string)
	if boardLabel then
		boardLabel.Text = text
	end
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

	local board = part(folder, {
		Name = "TableauCourse",
		Size = Vector3.new(26, 11, 1),
		Position = Vector3.new(0, 10, -45),
		Color = Color3.fromRGB(30, 35, 60),
	})
	for _, x in { -11, 11 } do
		part(folder, {
			Name = "PiedTableau",
			Size = Vector3.new(1, 5, 1),
			Position = Vector3.new(x, 2.5, -45),
			Color = Color3.fromRGB(30, 35, 60),
		})
	end
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Back -- tournée vers le point d'apparition (+Z)
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 230, 90)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Text = "🏁 PROCHAINE COURSE"
	label.Parent = gui
	boardLabel = label

	folder.Parent = workspace
end

return LobbyService
