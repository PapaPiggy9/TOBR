--[[
	HideSpawnDecals.server.lua
	Removes the default Roblox circle decal from all SpawnLocations
	so they look clean, while still functioning as spawn points.
]]

local function hideDecal(spawn)
	-- The decal sometimes takes a frame to appear
	task.defer(function()
		for _, child in ipairs(spawn:GetChildren()) do
			if child:IsA("Decal") then
				child:Destroy()
			end
		end
	end)
end

-- Handle existing spawns
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("SpawnLocation") then
		hideDecal(obj)
	end
end

-- Handle any spawns added later
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("SpawnLocation") then
		hideDecal(obj)
	end
end)
