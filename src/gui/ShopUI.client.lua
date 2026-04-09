--[[
	ShopUI.client.lua
	Polished simulator-style "Exclusive Shop!" UI.
	Press E near the shop or click a button to toggle.
]]

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ---------------------------------------------------------------
-- CONSTANTS
-- ---------------------------------------------------------------
local ROBUX_ICON = "rbxassetid://4915400460"

-- ---------------------------------------------------------------
-- SCREEN GUI
-- ---------------------------------------------------------------
local gui              = Instance.new("ScreenGui")
gui.Name               = "ShopGui"
gui.ResetOnSpawn       = false
gui.ZIndexBehavior     = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset     = true
gui.Parent             = playerGui

-- ---------------------------------------------------------------
-- DARK OVERLAY
-- ---------------------------------------------------------------
local overlay                    = Instance.new("Frame")
overlay.Name                     = "Overlay"
overlay.Size                     = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3         = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency   = 0.5
overlay.BorderSizePixel          = 0
overlay.ZIndex                   = 1
overlay.Parent                   = gui

-- ---------------------------------------------------------------
-- MAIN PANEL
-- ---------------------------------------------------------------
local mainFrame                    = Instance.new("Frame")
mainFrame.Name                     = "MainFrame"
mainFrame.Size                     = UDim2.new(0.7, 0, 0.8, 0)
mainFrame.Position                 = UDim2.new(0.15, 0, 0.1, 0)
mainFrame.BackgroundColor3         = Color3.fromRGB(245, 245, 250)
mainFrame.BorderSizePixel          = 0
mainFrame.ZIndex                   = 2
mainFrame.Parent                   = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent       = mainFrame

-- Drop shadow
local shadow                    = Instance.new("ImageLabel")
shadow.Name                     = "Shadow"
shadow.Size                     = UDim2.new(1, 30, 1, 30)
shadow.Position                 = UDim2.new(0, -15, 0, -10)
shadow.BackgroundTransparency   = 1
shadow.Image                    = "rbxassetid://5554236805"
shadow.ImageColor3              = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency        = 0.6
shadow.ScaleType                = Enum.ScaleType.Slice
shadow.SliceCenter              = Rect.new(23, 23, 277, 277)
shadow.ZIndex                   = 1
shadow.Parent                   = mainFrame

-- ---------------------------------------------------------------
-- TOP BAR
-- ---------------------------------------------------------------
local topBar                    = Instance.new("Frame")
topBar.Name                     = "TopBar"
topBar.Size                     = UDim2.new(1, 0, 0, 56)
topBar.BackgroundColor3         = Color3.fromRGB(60, 130, 255)
topBar.BorderSizePixel          = 0
topBar.ZIndex                   = 3
topBar.Parent                   = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 20)
topCorner.Parent       = topBar

-- Fill bottom corners of top bar
local topBarFill                  = Instance.new("Frame")
topBarFill.Name                   = "Fill"
topBarFill.Size                   = UDim2.new(1, 0, 0, 20)
topBarFill.Position               = UDim2.new(0, 0, 1, -20)
topBarFill.BackgroundColor3       = Color3.fromRGB(60, 130, 255)
topBarFill.BorderSizePixel        = 0
topBarFill.ZIndex                 = 3
topBarFill.Parent                 = topBar

local topGradient = Instance.new("UIGradient")
topGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 150, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 220)),
})
topGradient.Rotation = 90
topGradient.Parent   = topBar

-- Title
local titleLabel                  = Instance.new("TextLabel")
titleLabel.Name                   = "Title"
titleLabel.Size                   = UDim2.new(1, -60, 1, 0)
titleLabel.Position               = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text                   = "Exclusive Shop!"
titleLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
titleLabel.Font                   = Enum.Font.FredokaOne
titleLabel.TextSize               = 26
titleLabel.TextXAlignment         = Enum.TextXAlignment.Left
titleLabel.ZIndex                 = 4
titleLabel.Parent                 = topBar

local titleStroke = Instance.new("UIStroke")
titleStroke.Color       = Color3.fromRGB(30, 70, 150)
titleStroke.Thickness   = 1.5
titleStroke.Parent      = titleLabel

-- Close button
local closeBtn                    = Instance.new("TextButton")
closeBtn.Name                     = "CloseBtn"
closeBtn.Size                     = UDim2.new(0, 40, 0, 40)
closeBtn.Position                 = UDim2.new(1, -48, 0, 8)
closeBtn.BackgroundColor3         = Color3.fromRGB(220, 50, 50)
closeBtn.Text                     = "X"
closeBtn.TextColor3               = Color3.fromRGB(255, 255, 255)
closeBtn.Font                     = Enum.Font.FredokaOne
closeBtn.TextSize                 = 20
closeBtn.BorderSizePixel          = 0
closeBtn.AutoButtonColor          = true
closeBtn.ZIndex                   = 5
closeBtn.Parent                   = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent       = closeBtn

local closeStroke     = Instance.new("UIStroke")
closeStroke.Color     = Color3.fromRGB(150, 20, 20)
closeStroke.Thickness = 2
closeStroke.Parent    = closeBtn

-- ---------------------------------------------------------------
-- SCROLLING CONTENT AREA
-- ---------------------------------------------------------------
local content                    = Instance.new("ScrollingFrame")
content.Name                     = "Content"
content.Size                     = UDim2.new(1, -24, 1, -68)
content.Position                 = UDim2.new(0, 12, 0, 62)
content.BackgroundTransparency   = 1
content.BorderSizePixel          = 0
content.ScrollBarThickness       = 4
content.ScrollBarImageColor3     = Color3.fromRGB(60, 130, 255)
content.CanvasSize               = UDim2.new(0, 0, 0, 620)
content.ZIndex                   = 3
content.Parent                   = mainFrame

-- ---------------------------------------------------------------
-- HELPER: create price tag with Robux icon
-- ---------------------------------------------------------------
local function createPriceTag(parent, price, zIndex)
	local container                  = Instance.new("Frame")
	container.Name                   = "PriceTag"
	container.Size                   = UDim2.new(0, 110, 0, 32)
	container.Position               = UDim2.new(0.5, -55, 1, -42)
	container.BackgroundColor3       = Color3.fromRGB(30, 30, 40)
	container.BackgroundTransparency = 0.15
	container.BorderSizePixel        = 0
	container.ZIndex                 = zIndex
	container.Parent                 = parent

	local priceCorner = Instance.new("UICorner")
	priceCorner.CornerRadius = UDim.new(0, 10)
	priceCorner.Parent       = container

	local icon                  = Instance.new("ImageLabel")
	icon.Name                   = "RobuxIcon"
	icon.Size                   = UDim2.new(0, 20, 0, 20)
	icon.Position               = UDim2.new(0, 10, 0.5, -10)
	icon.BackgroundTransparency = 1
	icon.Image                  = ROBUX_ICON
	icon.ZIndex                 = zIndex + 1
	icon.Parent                 = container

	local priceLabel                  = Instance.new("TextLabel")
	priceLabel.Name                   = "Price"
	priceLabel.Size                   = UDim2.new(1, -38, 1, 0)
	priceLabel.Position               = UDim2.new(0, 34, 0, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text                   = tostring(price)
	priceLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
	priceLabel.Font                   = Enum.Font.FredokaOne
	priceLabel.TextSize               = 16
	priceLabel.TextXAlignment         = Enum.TextXAlignment.Left
	priceLabel.ZIndex                 = zIndex + 1
	priceLabel.Parent                 = container

	return container
end

-- ---------------------------------------------------------------
-- HELPER: create a large featured card
-- ---------------------------------------------------------------
local function createFeaturedCard(parent, data)
	local card                    = Instance.new("Frame")
	card.Name                     = data.name .. "Card"
	card.Size                     = UDim2.new(0.48, 0, 0, 200)
	card.Position                 = data.position
	card.BackgroundColor3         = Color3.fromRGB(255, 255, 255)
	card.BorderSizePixel          = 0
	card.ZIndex                   = 4
	card.Parent                   = parent

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 16)
	cardCorner.Parent       = card

	local gradient = Instance.new("UIGradient")
	gradient.Color    = data.gradient
	gradient.Rotation = data.gradientRotation or 45
	gradient.Parent   = card

	local cardStroke     = Instance.new("UIStroke")
	cardStroke.Color     = data.strokeColor
	cardStroke.Thickness = 2
	cardStroke.Transparency = 0.3
	cardStroke.Parent    = card

	-- Icon
	local iconLabel                  = Instance.new("TextLabel")
	iconLabel.Name                   = "Icon"
	iconLabel.Size                   = UDim2.new(0, 50, 0, 50)
	iconLabel.Position               = UDim2.new(0, 14, 0, 14)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text                   = data.icon
	iconLabel.TextScaled             = true
	iconLabel.Font                   = Enum.Font.FredokaOne
	iconLabel.ZIndex                 = 5
	iconLabel.Parent                 = card

	-- Title
	local title                  = Instance.new("TextLabel")
	title.Name                   = "Title"
	title.Size                   = UDim2.new(1, -80, 0, 36)
	title.Position               = UDim2.new(0, 70, 0, 12)
	title.BackgroundTransparency = 1
	title.Text                   = data.title
	title.TextColor3             = Color3.fromRGB(255, 255, 255)
	title.Font                   = Enum.Font.FredokaOne
	title.TextSize               = 24
	title.TextXAlignment         = Enum.TextXAlignment.Left
	title.ZIndex                 = 5
	title.Parent                 = card

	local titleStroke2     = Instance.new("UIStroke")
	titleStroke2.Color     = Color3.fromRGB(0, 0, 0)
	titleStroke2.Thickness = 1
	titleStroke2.Transparency = 0.5
	titleStroke2.Parent    = title

	-- Description
	local desc                  = Instance.new("TextLabel")
	desc.Name                   = "Description"
	desc.Size                   = UDim2.new(1, -28, 0, 60)
	desc.Position               = UDim2.new(0, 14, 0, 70)
	desc.BackgroundTransparency = 1
	desc.Text                   = data.description
	desc.TextColor3             = Color3.fromRGB(255, 255, 255)
	desc.Font                   = Enum.Font.FredokaOne
	desc.TextSize               = 14
	desc.TextWrapped            = true
	desc.TextXAlignment         = Enum.TextXAlignment.Left
	desc.TextYAlignment         = Enum.TextYAlignment.Top
	desc.ZIndex                 = 5
	desc.Parent                 = card

	local descStroke     = Instance.new("UIStroke")
	descStroke.Color     = Color3.fromRGB(0, 0, 0)
	descStroke.Thickness = 0.5
	descStroke.Transparency = 0.7
	descStroke.Parent    = desc

	-- Price
	createPriceTag(card, data.price, 5)

	return card
end

-- ---------------------------------------------------------------
-- HELPER: create a small grid card
-- ---------------------------------------------------------------
local function createGridCard(parent, data)
	local card                    = Instance.new("Frame")
	card.Name                     = data.name .. "Card"
	card.Size                     = UDim2.new(0.313, -8, 0, 180)
	card.BackgroundColor3         = Color3.fromRGB(255, 255, 255)
	card.BorderSizePixel          = 0
	card.ZIndex                   = 4
	card.LayoutOrder              = data.order or 0
	card.Parent                   = parent

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 14)
	cardCorner.Parent       = card

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 150, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 220)),
	})
	gradient.Rotation = 135
	gradient.Parent   = card

	local cardStroke     = Instance.new("UIStroke")
	cardStroke.Color     = Color3.fromRGB(30, 80, 180)
	cardStroke.Thickness = 2
	cardStroke.Transparency = 0.4
	cardStroke.Parent    = card

	-- Icon
	local iconLabel                  = Instance.new("TextLabel")
	iconLabel.Name                   = "Icon"
	iconLabel.Size                   = UDim2.new(0, 44, 0, 44)
	iconLabel.Position               = UDim2.new(0.5, -22, 0, 12)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text                   = data.icon
	iconLabel.TextScaled             = true
	iconLabel.Font                   = Enum.Font.FredokaOne
	iconLabel.ZIndex                 = 5
	iconLabel.Parent                 = card

	-- Title
	local title                  = Instance.new("TextLabel")
	title.Name                   = "Title"
	title.Size                   = UDim2.new(1, -10, 0, 24)
	title.Position               = UDim2.new(0, 5, 0, 60)
	title.BackgroundTransparency = 1
	title.Text                   = data.title
	title.TextColor3             = Color3.fromRGB(255, 255, 255)
	title.Font                   = Enum.Font.FredokaOne
	title.TextSize               = 16
	title.ZIndex                 = 5
	title.Parent                 = card

	local titleStroke3     = Instance.new("UIStroke")
	titleStroke3.Color     = Color3.fromRGB(0, 0, 0)
	titleStroke3.Thickness = 0.8
	titleStroke3.Transparency = 0.5
	titleStroke3.Parent    = title

	-- Description
	local desc                  = Instance.new("TextLabel")
	desc.Name                   = "Desc"
	desc.Size                   = UDim2.new(1, -16, 0, 36)
	desc.Position               = UDim2.new(0, 8, 0, 88)
	desc.BackgroundTransparency = 1
	desc.Text                   = data.description
	desc.TextColor3             = Color3.fromRGB(220, 230, 255)
	desc.Font                   = Enum.Font.FredokaOne
	desc.TextSize               = 12
	desc.TextWrapped            = true
	desc.ZIndex                 = 5
	desc.Parent                 = card

	-- Price
	createPriceTag(card, data.price, 5)

	return card
end

-- ---------------------------------------------------------------
-- BUILD: FEATURED CARDS (top row)
-- ---------------------------------------------------------------
local featuredRow                    = Instance.new("Frame")
featuredRow.Name                     = "FeaturedRow"
featuredRow.Size                     = UDim2.new(1, 0, 0, 210)
featuredRow.Position                 = UDim2.new(0, 0, 0, 4)
featuredRow.BackgroundTransparency   = 1
featuredRow.ZIndex                   = 3
featuredRow.Parent                   = content

-- VIP Card
createFeaturedCard(featuredRow, {
	name        = "VIP",
	title       = "VIP!",
	icon        = "👑",
	description = "VIP area, daily rewards, chat tag, and DOUBLE Rank XP!",
	price       = "400",
	position    = UDim2.new(0, 0, 0, 0),
	gradient    = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 130, 0)),
	}),
	gradientRotation = 45,
	strokeColor = Color3.fromRGB(200, 120, 0),
})

-- Shiny Hunter Card
createFeaturedCard(featuredRow, {
	name        = "ShinyHunter",
	title       = "Shiny Hunter!",
	icon        = "🥚",
	description = "Significantly higher chance to hatch a Shiny Pet!",
	price       = "1,299",
	position    = UDim2.new(0.52, 0, 0, 0),
	gradient    = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 60, 220)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 80, 180)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 180, 255)),
	}),
	gradientRotation = 30,
	strokeColor = Color3.fromRGB(130, 40, 180),
})

-- ---------------------------------------------------------------
-- BUILD: GRID CARDS (bottom section)
-- ---------------------------------------------------------------
local gridContainer                    = Instance.new("Frame")
gridContainer.Name                     = "GridContainer"
gridContainer.Size                     = UDim2.new(1, 0, 0, 380)
gridContainer.Position                 = UDim2.new(0, 0, 0, 220)
gridContainer.BackgroundTransparency   = 1
gridContainer.ZIndex                   = 3
gridContainer.Parent                   = content

local gridLayout           = Instance.new("UIGridLayout")
gridLayout.CellSize        = UDim2.new(0.313, -4, 0, 180)
gridLayout.CellPadding     = UDim2.new(0.01, 4, 0, 10)
gridLayout.SortOrder       = Enum.SortOrder.LayoutOrder
gridLayout.FillDirection    = Enum.FillDirection.Horizontal
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.Parent          = gridContainer

local gridCards = {
	{ name = "Lucky",      icon = "🍀", title = "Lucky!",            description = "Better Luck With Eggs!",    price = "400",  order = 1 },
	{ name = "AutoHatch",  icon = "🤖", title = "Auto Hatch!",       description = "AFK Open Eggs!",            price = "150",  order = 2 },
	{ name = "Hoverboard", icon = "🛹", title = "Hoverboard!",       description = "Get around much faster!",   price = "250",  order = 3 },
	{ name = "Teleporter", icon = "🌀", title = "Teleporter!",       description = "Teleport anywhere!",        price = "199",  order = 4 },
	{ name = "EggSkip",    icon = "⚡", title = "Egg Opening Skip!", description = "Open eggs instantly!",      price = "349",  order = 5 },
	{ name = "PetStorage", icon = "📦", title = "Pet Storage!",      description = "+100 Pet Storage!",         price = "299",  order = 6 },
}

for _, data in ipairs(gridCards) do
	createGridCard(gridContainer, data)
end

-- Update canvas size to fit all content
content.CanvasSize = UDim2.new(0, 0, 0, 620)

-- ---------------------------------------------------------------
-- TOGGLE SHOP
-- ---------------------------------------------------------------
local shopOpen = true

local function setShopVisible(visible)
	shopOpen = visible
	gui.Enabled = visible
end

-- Close button
closeBtn.MouseButton1Click:Connect(function()
	setShopVisible(false)
end)

-- Click overlay to close
overlay.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		setShopVisible(false)
	end
end)

-- Start hidden — other scripts can show it
setShopVisible(false)

-- ---------------------------------------------------------------
-- PUBLIC: other scripts can open the shop via this BindableEvent
-- ---------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if Remotes then
	local openShopRemote = Remotes:FindFirstChild("RequestShopOpen")
	if openShopRemote then
		openShopRemote.OnClientEvent:Connect(function()
			setShopVisible(true)
		end)
	end
end

-- Also allow toggling with keyboard (M key)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.M then
		setShopVisible(not shopOpen)
	end
end)

print("[ShopUI] Ready! Press M to toggle shop.")
