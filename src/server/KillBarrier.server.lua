--[[
	KillBarrier.server.lua
	Kills players who fall below the map.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local KILL_Y = 5  -- if player falls below this Y, they die

RunService.Heartbeat:Connect(function()
	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			local humanoid = char:FindFirstChildWhichIsA("Humanoid")
			if root and humanoid and humanoid.Health > 0 then
				if root.Position.Y < KILL_Y then
					humanoid.Health = 0
				end
			end
		end
	end
end)
