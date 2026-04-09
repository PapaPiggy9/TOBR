--[[
	MenuButtons.client.lua
	6 menu buttons in a 2-column grid — matching reference.
]]

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui              = Instance.new("ScreenGui")
gui.Name               = "MenuGui"
gui.ResetOnSpawn       = false
gui.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset     = false
gui.Parent             = playerGui

local BUTTONS = {
	{ name = "Trade",       icon = "rbxassetid://113730804734433", frame = "TradeFrame",      col = 1, row = 1 },
	{ name = "Robux Shop",  icon = "rbxassetid://123679072141071", frame = "RobuxShopFrame",  col = 2, row = 1 },
	{ name = "Gamepasses",  icon = "rbxassetid://94110193876448",  frame = "GamepassesFrame", col = 1, row = 2 },
	{ name = "Pets",        icon = "rbxassetid://70457106774375",  frame = "PetsFrame",       col = 2, row = 2 },
	{ name = "VIP",         icon = "rbxassetid://103548507218685", frame = "VIPFrame",        col = 1, row = 3 },
	{ name = "Friends",     icon = "rbxassetid://85667690485011",  frame = "FriendsFrame",    col = 2, row = 3 },
}

local CELL_W = 100
local CELL_H = 75
local GAP    = 18
local COLS   = 2
local ROWS   = 3
local GRID_W = COLS * CELL_W + (COLS - 1) * GAP
local GRID_H = ROWS * CELL_H + (ROWS - 1) * GAP
local BAR_H  = 34
local BAR_GAP = 10

local gridFrame                    = Instance.new("Frame")
gridFrame.Name                     = "ButtonGrid"
gridFrame.Size                     = UDim2.new(0, GRID_W, 0, GRID_H)
gridFrame.Position                 = UDim2.new(0, 10, 0.5, -(GRID_H / 2))
gridFrame.BackgroundTransparency   = 1
gridFrame.ZIndex                   = 5
gridFrame.Parent                   = gui

-- Overlay
local overlay                    = Instance.new("Frame")
overlay.Name                     = "Overlay"
overlay.Size                     = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3         = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency   = 1
overlay.BorderSizePixel          = 0
overlay.ZIndex                   = 6
overlay.Visible                  = false
overlay.Parent                   = gui

local overlayBtn = Instance.new("TextButton")
overlayBtn.Size = UDim2.new(1, 0, 1, 0)
overlayBtn.BackgroundTransparency = 1
overlayBtn.Text = ""
overlayBtn.ZIndex = 6
overlayBtn.Parent = overlay

-- Panels
local allFrames = {}
local hideAll -- forward declaration

local function createPanel(data)
	local panel                    = Instance.new("Frame")
	panel.Name                     = data.frame
	panel.Size                     = UDim2.new(0.55, 0, 0.7, 0)
	panel.Position                 = UDim2.new(0.225, 0, 0.15, 0)
	panel.BackgroundColor3         = Color3.fromRGB(245, 245, 250)
	panel.BorderSizePixel          = 0
	panel.Visible                  = false
	panel.ZIndex                   = 7
	panel.Parent                   = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent       = panel

	local topBar                    = Instance.new("Frame")
	topBar.Size                     = UDim2.new(1, 0, 0, 50)
	topBar.BackgroundColor3         = Color3.fromRGB(40, 40, 50)
	topBar.BorderSizePixel          = 0
	topBar.ZIndex                   = 8
	topBar.Parent                   = panel

	local topCorner = Instance.new("UICorner")
	topCorner.CornerRadius = UDim.new(0, 16)
	topCorner.Parent       = topBar

	local topFill = Instance.new("Frame")
	topFill.Size = UDim2.new(1, 0, 0, 16)
	topFill.Position = UDim2.new(0, 0, 1, -16)
	topFill.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	topFill.BorderSizePixel = 0
	topFill.ZIndex = 8
	topFill.Parent = topBar

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = data.name
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 22
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 9
	title.Parent = topBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 36, 0, 36)
	closeBtn.Position = UDim2.new(1, -44, 0, 7)
	closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.FredokaOne
	closeBtn.TextSize = 18
	closeBtn.BorderSizePixel = 0
	closeBtn.ZIndex = 10
	closeBtn.Parent = topBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeBtn

	local content = Instance.new("TextLabel")
	content.Size = UDim2.new(1, -32, 1, -82)
	content.Position = UDim2.new(0, 16, 0, 66)
	content.BackgroundTransparency = 1
	content.Text = "Coming soon..."
	content.TextColor3 = Color3.fromRGB(120, 120, 140)
	content.Font = Enum.Font.FredokaOne
	content.TextSize = 18
	content.ZIndex = 8
	content.Parent = panel

	closeBtn.MouseButton1Click:Connect(function()
		hideAll()
	end)

	table.insert(allFrames, panel)
	return panel
end

local frameLookup = {}
for _, data in ipairs(BUTTONS) do
	frameLookup[data.frame] = createPanel(data)
end

-- Background blur when GUI is open
local Lighting = game:GetService("Lighting")
local blur = Instance.new("BlurEffect")
blur.Name = "MenuBlur"
blur.Size = 0
blur.Parent = Lighting

local function showBlur()
	blur.Size = 0
	TweenService:Create(blur, TweenInfo.new(0.1), { Size = 20 }):Play()
end

local function hideBlur()
	TweenService:Create(blur, TweenInfo.new(0.05), { Size = 0 }):Play()
end

hideAll = function()
	for _, frame in ipairs(allFrames) do
		frame.Visible = false
	end
	overlay.Visible = false
	hideBlur()
end

-- ---------------------------------------------------------------
-- CREATE BUTTONS
-- ---------------------------------------------------------------
for _, data in ipairs(BUTTONS) do
	local xPos = (data.col - 1) * (CELL_W + GAP)
	local yPos = (data.row - 1) * (CELL_H + GAP)

	local btn                        = Instance.new("TextButton")
	btn.Name                         = data.name .. "Btn"
	btn.Size                         = UDim2.new(0, CELL_W, 0, CELL_H)
	btn.Position                     = UDim2.new(0, xPos, 0, yPos)
	btn.BackgroundColor3             = Color3.fromRGB(0, 0, 0)
	btn.BackgroundTransparency       = 0.35
	btn.BorderSizePixel              = 0
	btn.Text                         = ""
	btn.AutoButtonColor              = false
	btn.ZIndex                       = 5
	btn.ClipsDescendants             = false
	btn.Parent                       = gridFrame

	-- No rounded corners — sharp rectangle

	-- Green outline
	local btnStroke     = Instance.new("UIStroke")
	btnStroke.Color     = Color3.fromRGB(40, 160, 60)
	btnStroke.Thickness = 3
	btnStroke.Parent    = btn

	local iconImage                  = Instance.new("ImageLabel")
	iconImage.Name                   = "Icon"
	iconImage.Size                   = UDim2.new(0.65, 0, 0.65, 0)
	iconImage.AnchorPoint            = Vector2.new(0.5, 0.5)
	iconImage.Position               = UDim2.new(0.5, 0, 0.45, 0)
	iconImage.BackgroundTransparency = 1
	iconImage.Image                  = data.icon
	iconImage.ScaleType              = Enum.ScaleType.Fit
	iconImage.ZIndex                 = 6
	iconImage.Parent                 = btn

	-- Drop shadow — offset down-right so hovering fills it exactly
	local shadow                     = Instance.new("Frame")
	shadow.Name                      = "Shadow"
	shadow.Size                      = UDim2.new(0, CELL_W, 0, CELL_H)
	shadow.Position                  = UDim2.new(0, xPos + 4, 0, yPos + 4)
	shadow.BackgroundColor3          = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency    = 0.65
	shadow.BorderSizePixel           = 0
	shadow.ZIndex                    = 4
	shadow.Parent                    = gridFrame

	-- Text overlapping bottom edge (half in, half out like reference)
	local label                      = Instance.new("TextLabel")
	label.Name                       = "Label"
	label.Size                       = UDim2.new(1, 0, 0, 30)
	label.AnchorPoint                = Vector2.new(0.5, 0.5)
	label.Position                   = UDim2.new(0.5, 0, 1, 0)
	label.BackgroundTransparency     = 1
	label.Text                       = data.name
	label.TextColor3                 = Color3.fromRGB(255, 255, 255)
	label.Font                       = Enum.Font.FredokaOne
	label.TextScaled                 = true
	label.TextXAlignment             = Enum.TextXAlignment.Center
	label.ZIndex                     = 8
	label.Parent                     = btn

	local textStroke     = Instance.new("UIStroke")
	textStroke.Color     = Color3.fromRGB(0, 0, 0)
	textStroke.Thickness = 2.5
	textStroke.Parent    = label

	-- Hover — grow to fill the shadow
	local tweenIn  = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenOut = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local normalSize = btn.Size
	local normalPos  = btn.Position
	-- Hover moves button to exactly cover the shadow
	local hoverPos   = UDim2.new(0, xPos + 4, 0, yPos + 4)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, tweenIn, { Position = hoverPos, BackgroundTransparency = 0.25 }):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, tweenOut, { Position = normalPos, BackgroundTransparency = 0.35 }):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		local targetFrame = frameLookup[data.frame]
		if targetFrame.Visible then
			hideAll()
		else
			hideAll()
			targetFrame.Visible = true
			overlay.Visible = true
			showBlur()
		end
	end)
end

overlayBtn.MouseButton1Click:Connect(function()
	hideAll()
end)

-- ---------------------------------------------------------------
-- CURRENCY BARS (Coins & Gems — inside grid, below buttons)
-- ---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes   = ReplicatedStorage:WaitForChild("Remotes")
local updateCurrency = Remotes:WaitForChild("UpdateCurrency")

local CURRENCIES = {
	{ name = "Coins", icon = "rbxassetid://74432069305708", barColor = Color3.fromRGB(255, 255, 255),
		textGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 230, 100)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 50)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 150, 30)),
		})
	},
	{ name = "Gems", icon = "rbxassetid://118050032441586", barColor = Color3.fromRGB(255, 255, 255),
		textGradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 140, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 80, 220)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 50, 180)),
		})
	},
}

local CURRENCY_BOTTOM_PADDING = 30
local valueLabels = {}

local function formatNumber(n)
	local s = tostring(math.floor(n))
	local result = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if result:sub(1, 1) == "," then result = result:sub(2) end
	return result
end

for i, data in ipairs(CURRENCIES) do
	-- 2 bars total, count from bottom up: bar 2 (Gems) is at bottom, bar 1 (Coins) above it
	local fromBottom = (2 - i) * (BAR_H + BAR_GAP) + CURRENCY_BOTTOM_PADDING

	-- Container
	local bar                        = Instance.new("Frame")
	bar.Name                         = data.name .. "Bar"
	bar.Size                         = UDim2.new(0, 280, 0, 46)
	bar.Position                     = UDim2.new(0, 10, 1, -fromBottom - 46)
	bar.BackgroundTransparency       = 1
	bar.BorderSizePixel              = 0
	bar.ZIndex                       = 10
	bar.Parent                       = gui

	-- Fading transparent bar behind (left to right fade)
	local fadeBar                    = Instance.new("Frame")
	fadeBar.Name                     = "FadeBar"
	fadeBar.Size                     = UDim2.new(1, 0, 1, 0)
	fadeBar.BackgroundColor3         = Color3.fromRGB(0, 0, 0)
	fadeBar.BackgroundTransparency   = 0
	fadeBar.BorderSizePixel          = 0
	fadeBar.ZIndex                   = 10
	fadeBar.Parent                   = bar

	local fadeGrad = Instance.new("UIGradient")
	fadeGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.7, 0.8),
		NumberSequenceKeypoint.new(1, 1),
	})
	fadeGrad.Rotation = 0
	fadeGrad.Parent   = fadeBar

	-- Icon
	local icon                       = Instance.new("ImageLabel")
	icon.Name                        = "Icon"
	icon.Size                        = UDim2.new(0, 40, 0, 40)
	icon.Position                    = UDim2.new(0, 4, 0.5, -20)
	icon.BackgroundTransparency      = 1
	icon.Image                       = data.icon
	icon.ScaleType                   = Enum.ScaleType.Fit
	icon.ZIndex                      = 12
	icon.Parent                      = bar

	-- Number
	local amount                     = Instance.new("TextLabel")
	amount.Name                      = "Amount"
	amount.Size                      = UDim2.new(0, 100, 1, 0)
	amount.Position                  = UDim2.new(0, 48, 0, 0)
	amount.BackgroundTransparency    = 1
	amount.Text                      = "0"
	amount.TextColor3                = Color3.fromRGB(255, 255, 255)
	amount.Font                      = Enum.Font.FredokaOne
	amount.TextSize                  = 32
	amount.TextXAlignment            = Enum.TextXAlignment.Left
	amount.ZIndex                    = 12
	amount.Parent                    = bar

	local amountStroke     = Instance.new("UIStroke")
	amountStroke.Color     = Color3.fromRGB(0, 0, 0)
	amountStroke.Thickness = 2
	amountStroke.Parent    = amount

	-- Text gradient matching the icon colors
	local textGrad      = Instance.new("UIGradient")
	textGrad.Color      = data.textGradient
	textGrad.Rotation   = 90
	textGrad.Parent     = amount

	valueLabels[data.name] = amount

	-- Plus button (right end of fade bar)
	local plusBtn                     = Instance.new("TextButton")
	plusBtn.Name                      = "PlusBtn"
	plusBtn.Size                      = UDim2.new(0, 38, 0, 38)
	plusBtn.Position                  = UDim2.new(1, -42, 0.5, -19)
	plusBtn.BackgroundColor3          = Color3.fromRGB(0, 0, 0)
	plusBtn.BackgroundTransparency    = 0.4
	plusBtn.Text                      = "+"
	plusBtn.TextColor3                = Color3.fromRGB(255, 255, 255)
	plusBtn.Font                      = Enum.Font.FredokaOne
	plusBtn.TextSize                  = 24
	plusBtn.BorderSizePixel           = 0
	plusBtn.AutoButtonColor           = false
	plusBtn.ZIndex                    = 12
	plusBtn.Parent                    = bar

	local plusCorner = Instance.new("UICorner")
	plusCorner.CornerRadius = UDim.new(0, 6)
	plusCorner.Parent       = plusBtn

	local plusStroke     = Instance.new("UIStroke")
	plusStroke.Color     = Color3.fromRGB(0, 0, 0)
	plusStroke.Thickness = 2
	plusStroke.Parent    = plusBtn

	plusBtn.MouseEnter:Connect(function()
		TweenService:Create(plusBtn, TweenInfo.new(0.1), { BackgroundTransparency = 0.2 }):Play()
	end)

	plusBtn.MouseLeave:Connect(function()
		TweenService:Create(plusBtn, TweenInfo.new(0.12), { BackgroundTransparency = 0.4 }):Play()
	end)

	plusBtn.MouseButton1Click:Connect(function()
		local robuxFrame = gui:FindFirstChild("RobuxShopFrame")
		if not robuxFrame then return end
		local isOpen = robuxFrame.Visible
		hideAll()
		if not isOpen then
			robuxFrame.Visible = true
			overlay.Visible = true
			showBlur()
		end
	end)
end

-- Listen for currency updates from server
updateCurrency.OnClientEvent:Connect(function(currencyName, value)
	if valueLabels[currencyName] then
		valueLabels[currencyName].Text = formatNumber(value)
	end
end)

-- Read leaderstats on start
task.defer(function()
	local leaderstats = player:WaitForChild("leaderstats", 10)
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		local gems  = leaderstats:FindFirstChild("Gems")
		if coins and valueLabels["Coins"] then
			valueLabels["Coins"].Text = formatNumber(coins.Value)
		end
		if gems and valueLabels["Gems"] then
			valueLabels["Gems"].Text = formatNumber(gems.Value)
		end
	end
end)
