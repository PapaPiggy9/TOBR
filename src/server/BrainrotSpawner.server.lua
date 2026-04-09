--[[
	BrainrotSpawner.server.lua
	Spawns brainrots along the danger zone path.
	Touch to collect. Respawns after collected.
]]

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local SharedScripts = ReplicatedStorage:WaitForChild("SharedScripts")
local BrainrotCatalog = require(SharedScripts:WaitForChild("BrainrotCatalog"))

-- ---------------------------------------------------------------
-- DANGER ZONE BOUNDS
-- ---------------------------------------------------------------
local ZONE_X_MIN = -218
local ZONE_X_MAX = 7
local ZONE_Y     = 52.59
local FLOAT_HEIGHT = 0

-- ---------------------------------------------------------------
-- SPAWN CONFIG
-- ---------------------------------------------------------------
local MIN_DISTANCE = 20
local RESPAWN_TIME = 8

local SPAWNS_BY_TIER = {
	Common    = {1, 2},
	Rare      = {1, 2},
	Epic      = {1, 2},
	Legendary = {1, 2},
	Mythic    = {1, 2},
	Divine    = {1, 1},
	Secret    = {1, 1},
	Godly     = {0, 1},
}

-- ---------------------------------------------------------------
-- PLAYER INVENTORIES
-- ---------------------------------------------------------------
local inventories = {}
local carryingInDanger = {}  -- tracks if player is carrying an item in danger zone

Players.PlayerAdded:Connect(function(player)
	inventories[player.UserId] = {}
	carryingInDanger[player.UserId] = false
end)

Players.PlayerRemoving:Connect(function(player)
	inventories[player.UserId] = nil
	carryingInDanger[player.UserId] = nil
end)

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end

local inventoryUpdate = Remotes:FindFirstChild("InventoryUpdate")
if not inventoryUpdate then
	inventoryUpdate = Instance.new("RemoteEvent")
	inventoryUpdate.Name = "InventoryUpdate"
	inventoryUpdate.Parent = Remotes
end

local dangerError = Remotes:FindFirstChild("DangerZoneError")
if not dangerError then
	dangerError = Instance.new("RemoteEvent")
	dangerError.Name = "DangerZoneError"
	dangerError.Parent = Remotes
end

-- Safe zone check: Z < -322 means player is back in safe zone
local SAFE_ZONE_Z = -322

-- Monitor players returning to safe zone
RunService.Heartbeat:Connect(function()
	for _, plr in ipairs(Players:GetPlayers()) do
		if carryingInDanger[plr.UserId] then
			local char = plr.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				if root and root.Position.Z < SAFE_ZONE_Z then
					carryingInDanger[plr.UserId] = false
				end
			end
		end
	end
end)

-- ---------------------------------------------------------------
-- CLEAN UP — destroy ALL old brainrots
-- ---------------------------------------------------------------
for _, child in ipairs(workspace:GetChildren()) do
	if child.Name == "Brainrots" then
		child:Destroy()
	end
end

local brainrotFolder = Instance.new("Folder")
brainrotFolder.Name = "Brainrots"
brainrotFolder.Parent = workspace

-- ---------------------------------------------------------------
-- TRACK POSITIONS
-- ---------------------------------------------------------------
local allPositions = {}

local function isTooClose(pos)
	for _, p in ipairs(allPositions) do
		if (pos - p).Magnitude < MIN_DISTANCE then
			return true
		end
	end
	-- Check bunker positions — no spawning inside bunkers + 30 stud padding
	for _, bunker in ipairs(BrainrotCatalog.Bunkers) do
		if math.abs(pos.Z - bunker.z) < (bunker.halfZ + 30) then
			return true
		end
	end
	return false
end

-- ---------------------------------------------------------------
-- CREATE ONE BRAINROT
-- ---------------------------------------------------------------
local function spawnOne(brainrotData, rarity, rarityColor, pos)
	local template = ReplicatedStorage:FindFirstChild(brainrotData.name)
	local mainPart, model

	if template then
		model = template:Clone()
		model.Name = brainrotData.name

		-- Clean everything: anchor parts, remove scripts/forces/animations
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				p.Anchored = true
				p.CanCollide = false
				p.Velocity = Vector3.new(0, 0, 0)
				p.RotVelocity = Vector3.new(0, 0, 0)
			end
			if p:IsA("Script") or p:IsA("ModuleScript") or p:IsA("LocalScript")
				or p:IsA("BodyVelocity") or p:IsA("BodyAngularVelocity") or p:IsA("BodyForce")
				or p:IsA("BodyGyro") or p:IsA("BodyPosition") or p:IsA("LinearVelocity")
				or p:IsA("AnimationController") or p:IsA("Animator") then
				p:Destroy()
			end
		end

		-- Place model in world, keep upright rotation
		model.Parent = brainrotFolder

		local originalPivot = model:GetPivot()
		local originalRotation = originalPivot - originalPivot.Position
		local randomYRotation = CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
		model:PivotTo(CFrame.new(pos.X, pos.Y, pos.Z) * originalRotation * randomYRotation)

		-- Only raise if underground, never push down
		local lowestY = math.huge
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				local bottom = p.Position.Y - (p.Size.Y / 2)
				if bottom < lowestY then lowestY = bottom end
			end
		end
		if lowestY < pos.Y then
			local raise = pos.Y - lowestY
			model:PivotTo(CFrame.new(pos.X, pos.Y + raise, pos.Z) * originalRotation * randomYRotation)
		end

		mainPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

		if mainPart then mainPart.CanTouch = true end
	else
		mainPart = Instance.new("Part")
		mainPart.Name = brainrotData.name
		mainPart.Size = Vector3.new(3, 3, 3)
		mainPart.Position = Vector3.new(pos.X, pos.Y + 1.5, pos.Z)
		mainPart.Anchored = true
		mainPart.CanCollide = false
		mainPart.CanTouch = true
		mainPart.Shape = Enum.PartType.Ball
		mainPart.Color = brainrotData.color
		mainPart.Material = Enum.Material.SmoothPlastic
		mainPart.Parent = brainrotFolder
	end

	-- Whirlpool effect under the brainrot matching rarity color
	local whirlPart = Instance.new("Part")
	whirlPart.Name = "WhirlBase"
	whirlPart.Size = Vector3.new(10, 0.2, 10)
	whirlPart.Position = Vector3.new(mainPart.Position.X, ZONE_Y + 0.15, mainPart.Position.Z)
	whirlPart.Anchored = true
	whirlPart.CanCollide = false
	whirlPart.CanTouch = false
	whirlPart.Transparency = 1
	whirlPart.Parent = model or brainrotFolder

	local whirl = Instance.new("ParticleEmitter")
	whirl.Name = "Whirlpool"
	whirl.Color = ColorSequence.new(rarityColor)
	whirl.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 2),
		NumberSequenceKeypoint.new(1, 0),
	})
	whirl.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.7, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	whirl.Lifetime = NumberRange.new(1.5, 2.5)
	whirl.Rate = 30
	whirl.Speed = NumberRange.new(3, 6)
	whirl.SpreadAngle = Vector2.new(360, 0)
	whirl.RotSpeed = NumberRange.new(200, 400)
	whirl.Rotation = NumberRange.new(0, 360)
	whirl.LightEmission = 0.8
	whirl.Texture = "rbxassetid://6490035152"
	whirl.EmissionDirection = Enum.NormalId.Top
	whirl.Parent = whirlPart

	-- Glow light matching rarity
	local glow = Instance.new("PointLight")
	glow.Color = rarityColor
	glow.Brightness = 1.5
	glow.Range = 14
	glow.Parent = whirlPart

	-- Billboard — attach to center of model, above the highest point
	local billboardPart = mainPart
	local billboardOffset = 4
	if model then
		local cf, size = model:GetBoundingBox()
		local highestY = -math.huge
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") then
				local top = p.Position.Y + (p.Size.Y / 2)
				if top > highestY then highestY = top end
			end
		end

		-- Create invisible part at model center for billboard
		local centerPart = Instance.new("Part")
		centerPart.Size = Vector3.new(1, 1, 1)
		centerPart.Position = Vector3.new(cf.X, cf.Y, cf.Z)
		centerPart.Anchored = true
		centerPart.CanCollide = false
		centerPart.CanTouch = false
		centerPart.Transparency = 1
		centerPart.Parent = model
		billboardPart = centerPart
		billboardOffset = (highestY - cf.Y) + 2
	end
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 140, 0, 55)
	bb.StudsOffset = Vector3.new(0, billboardOffset, 0)
	bb.AlwaysOnTop = false
	bb.MaxDistance = 45
	bb.Parent = billboardPart

	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.new(1, 0, 0.4, 0)
	nameL.BackgroundTransparency = 1
	nameL.Text = brainrotData.name
	nameL.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameL.Font = Enum.Font.FredokaOne
	nameL.TextScaled = true
	nameL.Parent = bb
	local ns = Instance.new("UIStroke") ns.Color = Color3.fromRGB(0,0,0) ns.Thickness = 2 ns.Parent = nameL

	local rarL = Instance.new("TextLabel")
	rarL.Size = UDim2.new(1, 0, 0.3, 0)
	rarL.Position = UDim2.new(0, 0, 0.4, 0)
	rarL.BackgroundTransparency = 1
	rarL.Text = "[ " .. rarity .. " ]"
	rarL.TextColor3 = rarityColor
	rarL.Font = Enum.Font.FredokaOne
	rarL.TextScaled = true
	rarL.Parent = bb
	local rs = Instance.new("UIStroke") rs.Color = Color3.fromRGB(0,0,0) rs.Thickness = 1.5 rs.Parent = rarL

	local valL = Instance.new("TextLabel")
	valL.Size = UDim2.new(1, 0, 0.3, 0)
	valL.Position = UDim2.new(0, 0, 0.7, 0)
	valL.BackgroundTransparency = 1
	valL.Text = "$" .. tostring(brainrotData.value)
	valL.TextColor3 = Color3.fromRGB(255, 230, 80)
	valL.Font = Enum.Font.FredokaOne
	valL.TextScaled = true
	valL.Parent = bb
	local vs = Instance.new("UIStroke") vs.Color = Color3.fromRGB(0,0,0) vs.Thickness = 1.5 vs.Parent = valL

	-- ProximityPrompt — hold for 1 second to pick up
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Take " .. brainrotData.name
	prompt.ObjectText = ""
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Style = Enum.ProximityPromptStyle.Default
	prompt.Parent = mainPart

	prompt.Triggered:Connect(function(plr)
		if not inventories[plr.UserId] then return end

		-- Check if already carrying in danger zone
		if carryingInDanger[plr.UserId] then
			dangerError:FireClient(plr)
			return
		end

		carryingInDanger[plr.UserId] = true

		table.insert(inventories[plr.UserId], {
			name = brainrotData.name, value = brainrotData.value, rarity = rarity,
		})
		inventoryUpdate:FireClient(plr, inventories[plr.UserId])

		-- Play pickup sound on client
		local pickupSound = Remotes:FindFirstChild("PlayPickupSound")
		if not pickupSound then
			pickupSound = Instance.new("RemoteEvent")
			pickupSound.Name = "PlayPickupSound"
			pickupSound.Parent = Remotes
		end
		pickupSound:FireClient(plr)

		-- Destroy the brainrot completely
		if model then
			model:Destroy()
		else
			mainPart:Destroy()
		end
		if whirlPart then whirlPart:Destroy() end

		-- Respawn as a new random brainrot from the same section at a different location
		local savedPos = pos
		task.delay(RESPAWN_TIME, function()
			-- Find the section that contains the original position
			local thisTier
			for _, t in ipairs(BrainrotCatalog.Tiers) do
				if savedPos.Z >= t.zMin and savedPos.Z <= t.zMax then
					thisTier = t
					break
				end
			end
			if not thisTier then return end

			local newData = thisTier.brainrots[math.random(1, #thisTier.brainrots)]
			local newRarity = newData.rarity or thisTier.rarity
			local newRarityColor = BrainrotCatalog.RarityColors[newRarity]

			local newPos
			for attempt = 1, 30 do
				local x = math.random(ZONE_X_MIN, ZONE_X_MAX)
				local z = math.random(thisTier.zMin, thisTier.zMax)
				newPos = Vector3.new(x, ZONE_Y, z)
				if not isTooClose(newPos) then
					break
				end
			end

			if newPos then
				pcall(function()
					spawnOne(newData, newRarity, newRarityColor, newPos)
					table.insert(allPositions, newPos)
				end)
			end
		end)
	end)

	-- No animation — feet planted on the ground
end

-- ---------------------------------------------------------------
-- SPAWN ALL
-- ---------------------------------------------------------------
task.wait(3)

local total = 0
for _, tier in ipairs(BrainrotCatalog.Tiers) do
	for _, brainrotData in ipairs(tier.brainrots) do
		local actualRarity = brainrotData.rarity or tier.rarity
		local rarityColor = BrainrotCatalog.RarityColors[actualRarity]
		local range = SPAWNS_BY_TIER[actualRarity] or {1, 1}
		local count = math.random(range[1], range[2])
		local spawned = 0
		local attempts = 0

		while spawned < count and attempts < 30 do
			attempts = attempts + 1
			local x = math.random(ZONE_X_MIN, ZONE_X_MAX)
			local z = math.random(tier.zMin, tier.zMax)
			local pos = Vector3.new(x, ZONE_Y + FLOAT_HEIGHT, z)

			if not isTooClose(pos) then
				local ok, err = pcall(function()
					spawnOne(brainrotData, actualRarity, rarityColor, pos)
				end)
				if ok then
					table.insert(allPositions, pos)
					spawned = spawned + 1
					total = total + 1
				else
					warn("[BrainrotSpawner] FAILED:", brainrotData.name, "—", err)
				end
				task.wait(0.1)
			end
		end
		if spawned == 0 then
			warn("[BrainrotSpawner] Could NOT spawn:", brainrotData.name, "after", attempts, "attempts")
		else
			print("[BrainrotSpawner] Spawned", spawned, "of", brainrotData.name)
		end
	end
end

print("[BrainrotSpawner] Done! Total spawned:", total)

-- ---------------------------------------------------------------
-- PUBLIC: inventory access for sell system
-- ---------------------------------------------------------------
local SSS = game:GetService("ServerScriptService")

local getInv = SSS:FindFirstChild("GetPlayerInventory")
if not getInv then
	getInv = Instance.new("BindableFunction")
	getInv.Name = "GetPlayerInventory"
	getInv.Parent = SSS
end
getInv.OnInvoke = function(player)
	return inventories[player.UserId] or {}
end

local clearInv = SSS:FindFirstChild("ClearPlayerInventory")
if not clearInv then
	clearInv = Instance.new("BindableEvent")
	clearInv.Name = "ClearPlayerInventory"
	clearInv.Parent = SSS
end
clearInv.Event:Connect(function(player)
	if inventories[player.UserId] then
		inventories[player.UserId] = {}
		inventoryUpdate:FireClient(player, {})
	end
end)
