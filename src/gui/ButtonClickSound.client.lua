--[[
	ButtonClickSound.client.lua
	Plays a click sound whenever ANY TextButton or ImageButton is pressed.
	Works for all current and future GUI buttons.
]]

local Players      = game:GetService("Players")
local SoundService = game:GetService("SoundService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create the sound once
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://119782848981313"
clickSound.Volume = 0.4
clickSound.Parent = SoundService

-- Listen for any button added anywhere in PlayerGui
local function connectButton(btn)
	if btn:IsA("TextButton") or btn:IsA("ImageButton") then
		-- Skip close/X buttons and overlay buttons
		if btn.Name == "CloseBtn" or btn.Text == "X" or btn.BackgroundTransparency >= 0.9 then return end
		btn.MouseButton1Click:Connect(function()
			clickSound:Play()
		end)
	end
end

-- Connect all existing buttons
for _, v in ipairs(playerGui:GetDescendants()) do
	connectButton(v)
end

-- Connect any future buttons
playerGui.DescendantAdded:Connect(function(v)
	connectButton(v)
end)
