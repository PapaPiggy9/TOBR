--[[
	ShopZoneUI.client.lua
	Opens a shop GUI when player walks into the shop circle.
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")
local openShop  = Remotes:WaitForChild("OpenShopZone")

openShop.OnClientEvent:Connect(function()
	-- Open the Robux Shop panel from MenuGui
	local menuGui = playerGui:FindFirstChild("MenuGui")
	if not menuGui then return end

	local robuxFrame = menuGui:FindFirstChild("RobuxShopFrame")
	if not robuxFrame then return end

	-- Only open if not already open
	if robuxFrame.Visible then return end

	-- Hide all other panels first
	for _, child in ipairs(menuGui:GetChildren()) do
		if child:IsA("Frame") and child.Name:find("Frame") and child.Name ~= "ButtonGrid" and child.Name ~= "Overlay" then
			child.Visible = false
		end
	end

	robuxFrame.Visible = true
	local overlay = menuGui:FindFirstChild("Overlay")
	if overlay then overlay.Visible = true end

	-- Enable blur
	local Lighting = game:GetService("Lighting")
	local blur = Lighting:FindFirstChild("MenuBlur")
	if blur then
		local TweenService = game:GetService("TweenService")
		blur.Size = 0
		TweenService:Create(blur, TweenInfo.new(0.1), { Size = 20 }):Play()
	end
end)
