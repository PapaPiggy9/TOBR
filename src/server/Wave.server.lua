local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Configuration
local WAVE_SPAWN_Z = 3800
local WAVE_TARGET_Z = -321
local WAVE_X = -104
local WAVE_Y = 78
local WAVE_WIDTH = 400
local WAVE_HEIGHT = 50
local WAVE_THICKNESS = 80

local distance = math.abs(WAVE_SPAWN_Z - WAVE_TARGET_Z)

local levels = {
	{ color = BrickColor.new("Hot pink"),       speed = 150,  label = "Level 1",     emoji = "🌊" },
	{ color = BrickColor.new("Bright green"),   speed = 200,  label = "Level 2",     emoji = "⚡" },
	{ color = BrickColor.new("Bright yellow"),  speed = 260,  label = "Level 3",     emoji = "🔥" },
	{ color = BrickColor.new("Bright orange"),  speed = 330,  label = "Level 4",     emoji = "💀" },
	{ color = BrickColor.new("Bright red"),     speed = 420,  label = "Level 5",     emoji = "☠️" },
}

local suddenDeath = { color = BrickColor.new("Really black"), speed = 375, label = "SUDDEN DEATH", emoji = "👹" }

local function killPlayer(part)
	local character = part.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end
end

local function spawnWave(levelData)
	local travelTime = distance / levelData.speed

	-- Main wave wall
	local wave = Instance.new("Part")
	wave.Size = Vector3.new(WAVE_WIDTH, WAVE_HEIGHT, WAVE_THICKNESS)
	wave.CFrame = CFrame.new(WAVE_X, WAVE_Y, WAVE_SPAWN_Z)
	wave.Anchored = true
	wave.CanCollide = false
	wave.BrickColor = levelData.color
	wave.Material = Enum.Material.Water
	wave.Transparency = 0.3
	wave.Parent = workspace

	-- Foam top
	local foam = Instance.new("Part")
	foam.Size = Vector3.new(WAVE_WIDTH, 20, WAVE_THICKNESS)
	foam.CFrame = CFrame.new(WAVE_X, WAVE_Y + WAVE_HEIGHT / 2 + 10, WAVE_SPAWN_Z)
	foam.Anchored = true
	foam.CanCollide = false
	foam.BrickColor = BrickColor.new("White")
	foam.Material = Enum.Material.SmoothPlastic
	foam.Transparency = 0.5
	foam.Parent = workspace

	-- Level label on the wave
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 80, 0, 40)
	billboard.AlwaysOnTop = true
	billboard.Parent = wave

	-- Emoji on top
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Size = UDim2.new(1, 0, 0.5, 0)
	emojiLabel.Position = UDim2.new(0, 0, 0, 0)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Text = levelData.emoji
	emojiLabel.TextScaled = true
	emojiLabel.Parent = billboard

	-- Level text below
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0.5, 0)
	label.Position = UDim2.new(0, 0, 0.5, 0)
	label.BackgroundTransparency = 1
	label.Text = levelData.label
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Parent = billboard

	wave.Touched:Connect(killPlayer)
	foam.Touched:Connect(killPlayer)

	local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

	local waveTween = TweenService:Create(wave, tweenInfo, {
		CFrame = CFrame.new(WAVE_X, WAVE_Y, WAVE_TARGET_Z)
	})
	local foamTween = TweenService:Create(foam, tweenInfo, {
		CFrame = CFrame.new(WAVE_X, WAVE_Y + WAVE_HEIGHT / 2 + 10, WAVE_TARGET_Z)
	})

	waveTween:Play()
	foamTween:Play()

	waveTween.Completed:Connect(function()
		wave:Destroy()
		foam:Destroy()
	end)

	task.wait(9)
end

-- Loop waves continuously
while true do
	for i, levelData in ipairs(levels) do
		spawnWave(levelData)
		-- Random chance to trigger sudden death after any wave
		if math.random(1, 3) == 1 then
			spawnWave(suddenDeath)
		end
	end
end
