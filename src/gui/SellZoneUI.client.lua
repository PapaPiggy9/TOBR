--[[
	SellZoneUI.client.lua
	Opens a GUI when player walks into the sell circle.
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")
local openSell  = Remotes:WaitForChild("OpenSellZone")

openSell.OnClientEvent:Connect(function()
	-- Placeholder — open sell GUI here later
	print("[SellZone] Player entered sell zone!")
end)
