--[[
	Lighting.server.lua
	Polished simulator-style lighting to match bright, clean look.
]]

local Lighting = game:GetService("Lighting")

-- ---------------------------------------------------------------
-- BASE LIGHTING
-- ---------------------------------------------------------------
Lighting.Brightness        = 2.1
Lighting.ClockTime         = 14          -- early afternoon sun
Lighting.Ambient           = Color3.fromRGB(140, 140, 140)   -- bright ambient, soft shadows
Lighting.OutdoorAmbient    = Color3.fromRGB(150, 150, 155)
Lighting.ColorShift_Top    = Color3.fromRGB(0, 0, 0)
Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
Lighting.GlobalShadows     = false
Lighting.ShadowSoftness    = 0.3
Lighting.EnvironmentDiffuseScale  = 1
Lighting.EnvironmentSpecularScale = 0.5

-- ---------------------------------------------------------------
-- CLEAN UP existing effects so we don't duplicate
-- ---------------------------------------------------------------
for _, child in ipairs(Lighting:GetChildren()) do
	if child:IsA("BloomEffect")
		or child:IsA("ColorCorrectionEffect")
		or child:IsA("Atmosphere")
		or child:IsA("SunRaysEffect")
		or child:IsA("DepthOfFieldEffect")
	then
		child:Destroy()
	end
end

-- ---------------------------------------------------------------
-- BLOOM — soft glow on bright surfaces
-- ---------------------------------------------------------------
local bloom       = Instance.new("BloomEffect")
bloom.Intensity   = 0.35
bloom.Size         = 24
bloom.Threshold   = 0.8
bloom.Parent      = Lighting

-- ---------------------------------------------------------------
-- COLOR CORRECTION — boosted saturation and contrast
-- ---------------------------------------------------------------
local cc           = Instance.new("ColorCorrectionEffect")
cc.Brightness      = 0.05
cc.Contrast        = 0.1
cc.Saturation      = 0.18
cc.TintColor       = Color3.fromRGB(255, 252, 245)  -- very slight warm tint
cc.Parent          = Lighting

-- ---------------------------------------------------------------
-- ATMOSPHERE — slight haze for depth
-- ---------------------------------------------------------------
local atmo         = Instance.new("Atmosphere")
atmo.Density       = 0.2
atmo.Offset        = 0.5
atmo.Color         = Color3.fromRGB(200, 220, 255)  -- soft blue haze
atmo.Decay         = Color3.fromRGB(120, 140, 180)
atmo.Glare         = 0.2
atmo.Haze          = 1.5
atmo.Parent        = Lighting

-- ---------------------------------------------------------------
-- SUN RAYS — subtle god rays
-- ---------------------------------------------------------------
local rays         = Instance.new("SunRaysEffect")
rays.Intensity     = 0.04
rays.Spread        = 0.6
rays.Parent        = Lighting

print("[Lighting] Simulator-style lighting applied!")
