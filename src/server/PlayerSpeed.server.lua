--[[
	PlayerSpeed.server.lua
	Sets player walkspeed faster.
]]

local Players = game:GetService("Players")

local DEFAULT_SPEED = 400  -- default Roblox is 16

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.WalkSpeed = DEFAULT_SPEED
	end)
end)
