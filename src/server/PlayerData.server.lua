--[[
	PlayerData.server.lua
	Saves/loads Coins & Gems. Creates leaderstats.
	Other scripts use RemoteEvents to update currency.
]]

local Players          = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dataStore = DataStoreService:GetDataStore("PlayerSaveData_v1")

-- Remotes
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
	Remotes = Instance.new("Folder")
	Remotes.Name = "Remotes"
	Remotes.Parent = ReplicatedStorage
end

local updateCurrency = Instance.new("RemoteEvent")
updateCurrency.Name = "UpdateCurrency"
updateCurrency.Parent = Remotes

-- Server-side data cache
local playerCache = {}

local DEFAULT_DATA = {
	Coins = 0,
	Gems = 0,
	Pets = {},
	EquippedPet = "",
	SpeedLevel = 1,
	StarterPetChosen = false,
}

local function deepCopy(t)
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- ---------------------------------------------------------------
-- LOAD
-- ---------------------------------------------------------------
local function loadData(player)
	local key = "player_" .. player.UserId
	local ok, saved = pcall(function()
		return dataStore:GetAsync(key)
	end)

	local data = deepCopy(DEFAULT_DATA)
	if ok and saved then
		for k, v in pairs(saved) do
			data[k] = v
		end
	end

	playerCache[player.UserId] = data
	return data
end

-- ---------------------------------------------------------------
-- SAVE
-- ---------------------------------------------------------------
local function saveData(player)
	local data = playerCache[player.UserId]
	if not data then return end
	local key = "player_" .. player.UserId
	pcall(function()
		dataStore:SetAsync(key, data)
	end)
end

-- ---------------------------------------------------------------
-- PLAYER ADDED
-- ---------------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
	local data = loadData(player)

	-- Leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = data.Coins
	coins.Parent = leaderstats

	local gems = Instance.new("IntValue")
	gems.Name = "Gems"
	gems.Value = data.Gems
	gems.Parent = leaderstats

	-- Sync changes back to cache
	coins.Changed:Connect(function(val)
		if playerCache[player.UserId] then
			playerCache[player.UserId].Coins = val
			updateCurrency:FireClient(player, "Coins", val)
		end
	end)

	gems.Changed:Connect(function(val)
		if playerCache[player.UserId] then
			playerCache[player.UserId].Gems = val
			updateCurrency:FireClient(player, "Gems", val)
		end
	end)

	-- Send initial values to client
	task.defer(function()
		updateCurrency:FireClient(player, "Coins", data.Coins)
		updateCurrency:FireClient(player, "Gems", data.Gems)
	end)
end)

-- ---------------------------------------------------------------
-- PLAYER REMOVING
-- ---------------------------------------------------------------
Players.PlayerRemoving:Connect(function(player)
	saveData(player)
	playerCache[player.UserId] = nil
end)

-- ---------------------------------------------------------------
-- AUTO-SAVE (every 60 seconds)
-- ---------------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(60)
		for _, player in ipairs(Players:GetPlayers()) do
			saveData(player)
		end
	end
end)

-- ---------------------------------------------------------------
-- BIND TO CLOSE
-- ---------------------------------------------------------------
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		saveData(player)
	end
end)

print("[PlayerData] Ready!")
