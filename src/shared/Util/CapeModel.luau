--!strict
-- Modèle de cape en tissu : col + fermoirs, 5 pans articulés qui s'évasent (dessus + doublure +
-- bordures), emblème, ourlet et pointes. Toutes les pièces sont ancrées et repositionnées par
-- `Pose` (cape animée côté joueurs par CapeController, cape fixe sur les mannequins du magasin).

local Equipment = require(script.Parent.Parent.Config.Equipment)

local CapeModel = {}

export type Piece = {
	Part: BasePart,
	-- Pan auquel la pièce est liée (0 = col) et position locale dans ce pan.
	Segment: number,
	Offset: CFrame,
}

export type Cape = {
	Model: Model,
	Pieces: { Piece },
	Parts: { BasePart },
	Count: number,
}

local SEGMENTS = 5
local SEGMENT_HEIGHT = 0.8
local TOP_WIDTH = 2
local BOTTOM_WIDTH = 3.2
local THICKNESS = 0.1

CapeModel.Segments = SEGMENTS

local function widthOf(segment: number): number
	return TOP_WIDTH + (BOTTOM_WIDTH - TOP_WIDTH) * (segment - 1) / (SEGMENTS - 1)
end

function CapeModel.Build(item: Equipment.Item): Cape
	local model = Instance.new("Model")
	model.Name = "Cape"
	local pieces: { Piece } = {}
	local parts: { BasePart } = {}
	local trimColor = item.Trim or Color3.fromRGB(230, 200, 90)
	local liningColor = item.Lining or item.Color:Lerp(Color3.new(0, 0, 0), 0.5)
	local glowing = item.Sparkles == true

	local function add(segment: number, offset: CFrame, props: { [string]: any }, class: string?): BasePart
		local p = Instance.new(class or "Part") :: BasePart
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.Massless = true
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		for key, value in props do
			(p :: any)[key] = value
		end
		p.Parent = model
		table.insert(pieces, { Part = p, Segment = segment, Offset = offset })
		table.insert(parts, p)
		return p
	end

	-- Col et fermoirs (fixés aux épaules).
	add(0, CFrame.new(0, 0.1, -0.05), {
		Name = "Col",
		Size = Vector3.new(TOP_WIDTH + 0.4, 0.35, 0.45),
		Color = trimColor,
		Material = if glowing then Enum.Material.Neon else Enum.Material.Metal,
	})
	for _, side in { -1, 1 } do
		add(0, CFrame.new(side * (TOP_WIDTH / 2 + 0.05), 0.05, -0.55), {
			Name = "Fermoir",
			Shape = Enum.PartType.Ball,
			Size = Vector3.new(0.5, 0.5, 0.5),
			Color = trimColor,
			Material = Enum.Material.Neon,
		})
	end

	for segment = 1, SEGMENTS do
		local width = widthOf(segment)
		local center = CFrame.new(0, -SEGMENT_HEIGHT / 2, 0)
		local panel = add(segment, center, {
			Name = "Pan",
			Size = Vector3.new(width, SEGMENT_HEIGHT + 0.04, THICKNESS),
			Color = item.Color,
			Material = item.Material or Enum.Material.Fabric,
		})
		add(segment, center * CFrame.new(0, 0, -THICKNESS), {
			Name = "Doublure",
			Size = Vector3.new(width - 0.05, SEGMENT_HEIGHT + 0.04, 0.05),
			Color = liningColor,
			Material = Enum.Material.SmoothPlastic,
			CastShadow = false,
		})
		for _, side in { -1, 1 } do
			add(segment, center * CFrame.new(side * width / 2, 0, 0), {
				Name = "Bordure",
				Size = Vector3.new(0.14, SEGMENT_HEIGHT + 0.04, THICKNESS + 0.06),
				Color = trimColor,
				Material = if glowing then Enum.Material.Neon else Enum.Material.Metal,
				CastShadow = false,
			})
		end
		if glowing and segment == 3 then
			local stars = Instance.new("ParticleEmitter")
			stars.Name = "Etoiles"
			stars.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			stars.Color = ColorSequence.new(trimColor, Color3.new(1, 1, 1))
			stars.LightEmission = 1
			stars.Rate = 14
			stars.Lifetime = NumberRange.new(0.6, 1.2)
			stars.Speed = NumberRange.new(0.5, 1.5)
			stars.SpreadAngle = Vector2.new(180, 180)
			stars.Size = NumberSequence.new(0.35, 0)
			stars.Parent = panel
		end
	end

	-- Emblème sur le 2e pan (côté extérieur).
	local emblemAt = CFrame.new(0, -SEGMENT_HEIGHT / 2, THICKNESS / 2 + 0.03) * CFrame.Angles(0, 0, math.rad(45))
	local emblemProps = {
		Name = "Embleme",
		Size = Vector3.new(0.75, 0.75, 0.05),
		Color = trimColor,
		Material = Enum.Material.Neon,
		CastShadow = false,
	}
	add(2, emblemAt, emblemProps)
	if item.Emblem == "etoile" then
		add(2, emblemAt * CFrame.Angles(0, 0, math.rad(45)), emblemProps)
	end

	-- Ourlet et pointes en bas du dernier pan.
	local bottomWidth = widthOf(SEGMENTS)
	add(SEGMENTS, CFrame.new(0, -SEGMENT_HEIGHT, 0), {
		Name = "Ourlet",
		Size = Vector3.new(bottomWidth + 0.1, 0.16, THICKNESS + 0.06),
		Color = trimColor,
		Material = if glowing then Enum.Material.Neon else Enum.Material.Metal,
		CastShadow = false,
	})
	for i = -1, 1 do
		add(SEGMENTS, CFrame.new(i * bottomWidth / 3, -SEGMENT_HEIGHT, 0) * CFrame.Angles(0, 0, math.rad(45)), {
			Name = "Pointe",
			Size = Vector3.new(0.75, 0.75, THICKNESS),
			Color = item.Color,
			Material = item.Material or Enum.Material.Fabric,
		})
	end

	if glowing then
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = trimColor
		sparkles.Parent = parts[#parts]
	end
	return { Model = model, Pieces = pieces, Parts = parts, Count = SEGMENTS }
end

-- Calcule la place de chaque pièce. `anchor` = haut du dos (Z local = vers l'extérieur du dos),
-- `angles[i]` = pli du pan i vers l'arrière (radians, cumulés de pan en pan).
function CapeModel.Frames(cape: Cape, anchor: CFrame, angles: { number }): { CFrame }
	local segmentFrames: { [number]: CFrame } = { [0] = anchor }
	local current = anchor
	for segment = 1, SEGMENTS do
		current = current * CFrame.Angles(-(angles[segment] or 0), 0, 0)
		segmentFrames[segment] = current
		current = current * CFrame.new(0, -SEGMENT_HEIGHT, 0)
	end
	local frames: { CFrame } = table.create(#cape.Pieces)
	for index, piece in cape.Pieces do
		frames[index] = segmentFrames[piece.Segment] * piece.Offset
	end
	return frames
end

function CapeModel.Pose(cape: Cape, anchor: CFrame, angles: { number })
	workspace:BulkMoveTo(cape.Parts, CapeModel.Frames(cape, anchor, angles), Enum.BulkMoveMode.FireCFrameChanged)
end

return CapeModel
