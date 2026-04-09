--[[
	SpawnFacing.server.lua
	Makes players face the danger zone when they spawn.
]]

local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local rootPart = character:WaitForChild("HumanoidRootPart")
		-- Face toward negative Z (toward the danger zone entrance)
		task.wait(0.1)
		rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + Vector3.new(0, 0, 1))
	end)
end)
