--!strict
-- Guide visuel des nouveaux joueurs : consigne en bas de l'écran + rayon lumineux
-- du personnage vers la prochaine cible (portail, arrivée, équipement).
-- Tout est local à ce joueur ; l'étape vient de l'attribut « GuideStep » posé par le serveur.

local Players = game:GetService("Players")

local GuideController = {}

local player = Players.LocalPlayer

local function partOf(instance: Instance?): BasePart?
	if instance and instance:IsA("BasePart") then
		return instance
	end
	return nil
end

-- Renvoie la cible et la consigne pour l'étape.
local function guide(step: number, lobby: Instance, _root: BasePart): (BasePart?, string)
	if step == 1 then
		return nil, "1/4 · Envole-toi : touche F ou bouton ✈️, puis avance !"
	elseif step == 2 then
		local portals = lobby:FindFirstChild("Portails")
		return partOf(portals and portals:FindFirstChild("Portail_prairie")), "2/4 · Entre dans le portail Ciel 🌍"
	elseif step == 3 then
		local worldId = player:GetAttribute("World")
		local worlds = workspace:FindFirstChild("Mondes")
		local world = if worlds and type(worldId) == "string" then worlds:FindFirstChild(worldId) else nil
		return partOf(world and world:FindFirstChild("FinEtape_1")),
			"3/4 · Vole jusqu'à la plateforme de l'étape 1 (surveille ton 🔋)"
	end
	local steps = lobby:FindFirstChild("Pas")
	return partOf(steps and steps:FindFirstChild("Pas_2")), "4/4 · Achète +2 par pas (5 🏆) dans le lobby 👣"
end

function GuideController:Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "Guide"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 8
	gui.Parent = player:WaitForChild("PlayerGui")
	local label = Instance.new("TextLabel")
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.new(0.5, 0, 1, -100)
	label.Size = UDim2.new(0.8, 0, 0, 46)
	label.BackgroundColor3 = Color3.fromRGB(255, 215, 80)
	label.TextColor3 = Color3.fromRGB(40, 25, 10)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Visible = false
	label.Parent = gui
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(620, 46)
	limit.Parent = label
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label

	-- Rayon lumineux. Les points d'accroche sont recréés quand le personnage ou la cible change :
	-- un objet détruit (personnage réapparu, client parti) ne peut pas être réutilisé.
	local beam: Beam? = nil
	local fromAttachment: Attachment? = nil
	local toAttachment: Attachment? = nil
	local currentRoot: BasePart? = nil
	local currentTarget: BasePart? = nil

	local function clearTarget()
		if toAttachment then
			toAttachment:Destroy()
			toAttachment = nil
		end
		currentTarget = nil
	end

	local function clearAll()
		clearTarget()
		if beam then
			beam:Destroy()
			beam = nil
		end
		if fromAttachment then
			fromAttachment:Destroy()
			fromAttachment = nil
		end
		currentRoot = nil
	end

	local function attachRoot(root: BasePart)
		clearAll()
		local from = Instance.new("Attachment")
		from.Name = "GuideDepart"
		from.Parent = root
		local newBeam = Instance.new("Beam")
		newBeam.Name = "GuideRayon"
		newBeam.Attachment0 = from
		newBeam.Color = ColorSequence.new(Color3.fromRGB(255, 230, 90))
		newBeam.LightEmission = 1
		newBeam.Width0 = 0.5
		newBeam.Width1 = 0.5
		newBeam.FaceCamera = true
		newBeam.Segments = 12
		newBeam.CurveSize0 = 4
		newBeam.Transparency = NumberSequence.new(0.25)
		newBeam.Enabled = false
		newBeam.Parent = root
		fromAttachment = from
		beam = newBeam
		currentRoot = root
	end

	local function attachTarget(target: BasePart)
		clearTarget()
		local to = Instance.new("Attachment")
		to.Name = "GuideCible"
		to.Position = Vector3.new(0, 3, 0)
		to.Parent = target
		toAttachment = to
		currentTarget = target
		if beam then
			beam.Attachment1 = to
		end
	end

	while true do
		local step = player:GetAttribute("GuideStep")
		local lobby = workspace:FindFirstChild("Lobby")
		local character = player.Character
		local rootInstance = character and character:FindFirstChild("HumanoidRootPart")
		local root = if rootInstance and rootInstance:IsA("BasePart") then rootInstance else nil
		if type(step) == "number" and step > 0 and lobby and root then
			local target, text = guide(step, lobby, root)
			label.Text = text
			label.Visible = true
			if root ~= currentRoot or not (fromAttachment and fromAttachment:IsDescendantOf(workspace)) then
				attachRoot(root)
			end
			if target and target:IsDescendantOf(workspace) then
				if target ~= currentTarget or not (toAttachment and toAttachment:IsDescendantOf(workspace)) then
					attachTarget(target)
				end
				if beam then
					beam.Enabled = true
				end
			else
				clearTarget()
				if beam then
					beam.Enabled = false
				end
			end
		else
			label.Visible = false
			if beam then
				beam.Enabled = false
			end
			if type(step) == "number" and step == 0 and currentRoot then
				clearAll() -- guide terminé : on nettoie
			end
		end
		task.wait(0.2)
	end
end

return GuideController
