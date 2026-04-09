--[[
	DangerZoneError.client.lua
	Shows red error message when player tries to pick up
	more than 1 brainrot in the danger zone.
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")
local dangerError = Remotes:WaitForChild("DangerZoneError")

-- Screen GUI
local gui              = Instance.new("ScreenGui")
gui.Name               = "DangerErrorGui"
gui.ResetOnSpawn       = false
gui.IgnoreGuiInset     = false
gui.Parent             = playerGui

-- Error label
local errorLabel                  = Instance.new("TextLabel")
errorLabel.Name                   = "ErrorLabel"
errorLabel.Size                   = UDim2.new(0.7, 0, 0, 70)
errorLabel.AnchorPoint            = Vector2.new(0.5, 0)
errorLabel.Position               = UDim2.new(0.5, 0, 0.05, 0)
errorLabel.BackgroundTransparency = 1
errorLabel.Text                   = "Danger Zone Limit! You can only carry 1 item here. Return to the safe zone to pick up more."
errorLabel.TextColor3             = Color3.fromRGB(255, 30, 30)
errorLabel.Font                   = Enum.Font.FredokaOne
errorLabel.TextSize               = 24
errorLabel.TextWrapped            = true
errorLabel.Visible                = false
errorLabel.ZIndex                 = 20
errorLabel.Parent                 = gui

local errorStroke     = Instance.new("UIStroke")
errorStroke.Color     = Color3.fromRGB(0, 0, 0)
errorStroke.Thickness = 2
errorStroke.Parent    = errorLabel


-- Error sound
local errorSound = Instance.new("Sound")
errorSound.SoundId = "rbxassetid://81595760528483"
errorSound.Volume = 1
errorSound.Parent = game:GetService("SoundService")

-- Show error then fade out
dangerError.OnClientEvent:Connect(function()
	errorLabel.Visible = true
	errorLabel.TextTransparency = 0
	errorLabel.BackgroundTransparency = 1
	errorSound:Play()

	task.delay(4, function()
		local fadeOut = TweenService:Create(errorLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TextTransparency = 1,
		})
		TweenService:Create(errorStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Transparency = 1,
		}):Play()
		fadeOut:Play()
		fadeOut.Completed:Connect(function()
			errorLabel.Visible = false
			errorStroke.Transparency = 0
		end)
	end)
end)
