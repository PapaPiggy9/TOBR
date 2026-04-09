--[[
	PlayerDataService.lua (ModuleScript)
	Shared helper functions for reading/modifying player currency.
	Used by other server scripts to add/spend coins and gems.
]]

local Players = game:GetService("Players")

local PlayerDataService = {}

-- ---------------------------------------------------------------
-- GET LEADERSTATS VALUES
-- ---------------------------------------------------------------
local function getLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return nil, nil end
	return leaderstats:FindFirstChild("Coins"), leaderstats:FindFirstChild("Gems")
end

-- ---------------------------------------------------------------
-- GET DATA (returns current coins and gems)
-- ---------------------------------------------------------------
function PlayerDataService.getData(player)
	local coins, gems = getLeaderstats(player)
	return {
		Coins = coins and coins.Value or 0,
		Gems = gems and gems.Value or 0,
	}
end

-- ---------------------------------------------------------------
-- ADD COINS
-- ---------------------------------------------------------------
function PlayerDataService.addCoins(player, amount)
	local coins = select(1, getLeaderstats(player))
	if coins then
		coins.Value = coins.Value + amount
		return true
	end
	return false
end

-- ---------------------------------------------------------------
-- ADD GEMS
-- ---------------------------------------------------------------
function PlayerDataService.addGems(player, amount)
	local _, gems = getLeaderstats(player)
	if gems then
		gems.Value = gems.Value + amount
		return true
	end
	return false
end

-- ---------------------------------------------------------------
-- SPEND COINS (returns true if successful, false if not enough)
-- ---------------------------------------------------------------
function PlayerDataService.spendCoins(player, amount)
	local coins = select(1, getLeaderstats(player))
	if coins and coins.Value >= amount then
		coins.Value = coins.Value - amount
		return true
	end
	return false
end

-- ---------------------------------------------------------------
-- SPEND GEMS (returns true if successful, false if not enough)
-- ---------------------------------------------------------------
function PlayerDataService.spendGems(player, amount)
	local _, gems = getLeaderstats(player)
	if gems and gems.Value >= amount then
		gems.Value = gems.Value - amount
		return true
	end
	return false
end

return PlayerDataService
