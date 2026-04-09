--[[
	RemoveMusic.server.lua
	Stops and removes all Sound objects immediately.
]]

local function removeSounds(parent)
	for _, v in ipairs(parent:GetDescendants()) do
		if v:IsA("Sound") then
			v:Stop()
			v:Destroy()
		end
	end
end

-- Kill sounds immediately, no waiting
removeSounds(workspace)
removeSounds(game:GetService("SoundService"))
removeSounds(game:GetService("Lighting"))

-- Catch any sounds added later
local function onDescendantAdded(v)
	if v:IsA("Sound") then
		v:Stop()
		v:Destroy()
	end
end

workspace.DescendantAdded:Connect(onDescendantAdded)
game:GetService("SoundService").DescendantAdded:Connect(onDescendantAdded)
game:GetService("Lighting").DescendantAdded:Connect(onDescendantAdded)
