local Players = game:GetService("Players")

-- One capture pad as a sample
local padPosition = Vector3.new(-109, 54, -367)

-- Ground level in safe zone: Y = 54

local capturing = {}

pad.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end
	if capturing[player] then return end

	capturing[player] = true

	-- Pick a random brainrot from the Brainrots folder
	local brainrotsFolder = workspace:FindFirstChild("Brainrots")
	if not brainrotsFolder then capturing[player] = false return end

	local brainrots = brainrotsFolder:GetChildren()
	if #brainrots == 0 then capturing[player] = false return end

	local chosen = brainrots[math.random(1, #brainrots)]:Clone()
	chosen:ScaleTo(0.3)

	-- Attach to player head
	local head = character:FindFirstChild("Head")
	if not head then capturing[player] = false return end

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = chosen.PrimaryPart or chosen:FindFirstChildOfClass("Part")
	weld.Parent = chosen

	if chosen.PrimaryPart then
		chosen.PrimaryPart.CFrame = head.CFrame * CFrame.new(0, 2, 0)
	end

	chosen.Parent = character

	-- Remove when player dies
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			chosen:Destroy()
			capturing[player] = false
		end)
	end
end)
