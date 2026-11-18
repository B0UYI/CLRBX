--!strict
-- Effets visuels et sonores de célébration (confettis, sons).

local Debris = game:GetService("Debris")

local FxService = {}

local SOUNDS = {
	Cash = "rbxasset://sounds/electronicpingshort.wav",
	Whoosh = "rbxasset://sounds/swoosh.wav",
}

local CONFETTI_COLORS = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 220, 60)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 230, 120)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(80, 160, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 100, 255)),
})

-- Explosion de confettis à une position (visible par tous).
function FxService.Confetti(position: Vector3, amount: number?)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = position
	anchor.Parent = workspace
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = CONFETTI_COLORS
	emitter.Lifetime = NumberRange.new(1.5, 3)
	emitter.Speed = NumberRange.new(20, 40)
	emitter.SpreadAngle = Vector2.new(60, 60)
	emitter.Acceleration = Vector3.new(0, -30, 0)
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-200, 200)
	emitter.Size = NumberSequence.new(0.5)
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Enabled = false
	emitter.Parent = anchor
	emitter:Emit(amount or 150)
	Debris:AddItem(anchor, 4)
end

-- Joue un son positionné sur une pièce (entendu par les joueurs proches).
function FxService.Sound(parent: BasePart, name: string, volume: number?)
	local id = (SOUNDS :: any)[name]
	if not id then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = volume or 0.6
	sound.Parent = parent
	sound:Play()
	Debris:AddItem(sound, 3)
end

return FxService
