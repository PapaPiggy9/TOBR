--[[
	PickupSound.client.lua
	Plays pickup sound when collecting a brainrot.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local pickupSound = Remotes:WaitForChild("PlayPickupSound")

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://133066564466188"
sound.Volume = 1
sound.Parent = SoundService

pickupSound.OnClientEvent:Connect(function()
	sound:Play()
end)
