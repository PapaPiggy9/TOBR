--[[
	ShopZone.server.lua
	Detects when player walks into the shop circle and fires a remote to open the shop GUI.
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZONES = {
	{ center = Vector3.new(-119.218, 53.532, -343.311), remote = "OpenShopZone" },
	{ center = Vector3.new(-78.672, 53.532, -343.311),  remote = "OpenSellZone" },
}
local ZONE_RADIUS = 7

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end

-- Create remotes for each zone
for _, zone in ipairs(ZONES) do
	if not Remotes:FindFirstChild(zone.remote) then
		local r = Instance.new("RemoteEvent")
		r.Name = zone.remote
		r.Parent = Remotes
	end
end

local playerInZone = {}

RunService.Heartbeat:Connect(function()
	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				for i, zone in ipairs(ZONES) do
					local key = plr.UserId .. "_" .. i
					local dist = (Vector3.new(root.Position.X, zone.center.Y, root.Position.Z) - zone.center).Magnitude
					if dist <= ZONE_RADIUS then
						if not playerInZone[key] then
							playerInZone[key] = true
							Remotes[zone.remote]:FireClient(plr)
						end
					else
						playerInZone[key] = false
					end
				end
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	playerInZone[plr.UserId] = nil
end)
