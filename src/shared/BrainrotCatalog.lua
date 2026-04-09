--[[
	BrainrotCatalog.lua (ModuleScript)
	Defines all brainrot tiers, names, values, and rarity colors.
]]

local BrainrotCatalog = {}

-- Rarity colors
BrainrotCatalog.RarityColors = {
	Common    = Color3.fromRGB(180, 180, 180),   -- ⚪
	Rare      = Color3.fromRGB(60, 140, 255),    -- 🔵
	Epic      = Color3.fromRGB(180, 60, 255),    -- 🟣
	Legendary = Color3.fromRGB(255, 200, 40),    -- 🟡
	Mythic    = Color3.fromRGB(220, 0, 0),       -- 🔴
	Divine    = Color3.fromRGB(255, 100, 255),    -- 🌈
	Secret    = Color3.fromRGB(100, 100, 100),    -- 💀
	Godly     = Color3.fromRGB(255, 215, 0),     -- 👑
}

-- Bunkers: {Z position, half Z size} — no brainrots spawn inside these
BrainrotCatalog.Bunkers = {
	{ z = -95.383,   halfZ = 13.312 / 2 },
	{ z = 41.546,    halfZ = 13.311 / 2 },
	{ z = 245.035,   halfZ = 13.312 / 2 },
	{ z = 547.325,   halfZ = 13.313 / 2 },
	{ z = 1004.688,  halfZ = 18.313 / 2 },
	{ z = 1668.3,    halfZ = 38.036 / 2 },
	{ z = 2338.442,  halfZ = 41.036 / 2 },
	{ z = 2675.442,  halfZ = 51.925 / 2 },
	{ z = 3013.547,  halfZ = 51.925 / 2 },
	{ z = 3354.918,  halfZ = 52.295 / 2 },
}

-- Brainrot data
local COMMON = {
	{ name = "Svinina Bombardino", value = 1,    color = Color3.fromRGB(200, 200, 200), rarity = "Common" },
	{ name = "Cono Freddo",        value = 3,    color = Color3.fromRGB(200, 220, 255), rarity = "Common" },
	{ name = "Boneca Ambalabu",    value = 4,    color = Color3.fromRGB(255, 180, 200), rarity = "Common" },
	{ name = "Talpa Di Fero",      value = 5,    color = Color3.fromRGB(180, 140, 100), rarity = "Common" },
}

local RARE = {
	{ name = "Tung Tung Sahur",       value = 20,   color = Color3.fromRGB(200, 160, 60), rarity = "Rare" },
	{ name = "Gangster Footera",      value = 25,   color = Color3.fromRGB(80, 80, 80), rarity = "Rare" },
	{ name = "Mano Stanca",           value = 30,   color = Color3.fromRGB(180, 140, 120), rarity = "Rare" },
	{ name = "Trulimero Trulicina",   value = 28,   color = Color3.fromRGB(255, 120, 180), rarity = "Rare" },
	{ name = "Sigma Girl",            value = 35,   color = Color3.fromRGB(255, 100, 200), rarity = "Rare" },
}

local EPIC = {
	{ name = "Cappuccino Assassino",  value = 75,   color = Color3.fromRGB(140, 90, 60), rarity = "Epic" },
	{ name = "Brr Brr Patapim",       value = 100,  color = Color3.fromRGB(80, 200, 255), rarity = "Epic" },
	{ name = "Avocadini Guffo",       value = 130,  color = Color3.fromRGB(120, 200, 80), rarity = "Epic" },
	{ name = "Brri Brri Bicus Dicus Bombicus", value = 140, color = Color3.fromRGB(255, 100, 100), rarity = "Epic" },
}

local LEGENDARY = {
	{ name = "Chef Crabracadabra",    value = 400,  color = Color3.fromRGB(255, 100, 60), rarity = "Legendary" },
	{ name = "Disco Vivo",            value = 450,  color = Color3.fromRGB(200, 60, 255), rarity = "Legendary" },
	{ name = "Bannanita Dolphinita",  value = 500,  color = Color3.fromRGB(255, 220, 80), rarity = "Legendary" },
	{ name = "Dug dug dug",           value = 520,  color = Color3.fromRGB(160, 120, 80), rarity = "Legendary" },
}

local MYTHIC = {
	{ name = "Bombardiro Crocodilo",  value = 1000, color = Color3.fromRGB(60, 180, 60), rarity = "Mythic" },
	{ name = "Orangutini Ananassini", value = 1200, color = Color3.fromRGB(255, 160, 40), rarity = "Mythic" },
	{ name = "Agarrini la Palini",    value = 1400, color = Color3.fromRGB(100, 200, 100), rarity = "Mythic" },
	{ name = "Radiomax",              value = 1100, color = Color3.fromRGB(220, 180, 60), rarity = "Mythic" },
}

local DIVINE = {
	{ name = "Tralalero Tralala",   value = 3500, color = Color3.fromRGB(60, 120, 255), rarity = "Divine" },
	{ name = "Froggino",            value = 3000, color = Color3.fromRGB(60, 200, 60), rarity = "Divine" },
	{ name = "Burrito Furioso",     value = 4000, color = Color3.fromRGB(255, 140, 40), rarity = "Divine" },
	{ name = "Esok Sekolah",        value = 4500, color = Color3.fromRGB(200, 100, 200), rarity = "Divine" },
	{ name = "Trollo Smilo",        value = 3800, color = Color3.fromRGB(255, 180, 60), rarity = "Divine" },
}

local SECRET = {
	{ name = "La Vacca Staturno Saturnita", value = 8000,  color = Color3.fromRGB(60, 60, 60), rarity = "Secret" },
	{ name = "Los Matteos",                  value = 9000,  color = Color3.fromRGB(80, 80, 80), rarity = "Secret" },
	{ name = "Cervo Sedia",                  value = 11000, color = Color3.fromRGB(140, 100, 60), rarity = "Secret" },
	{ name = "La Supreme Combinasion",       value = 12000, color = Color3.fromRGB(255, 215, 0), rarity = "Secret" },
	{ name = "Elefanto Frigo",               value = 10000, color = Color3.fromRGB(100, 180, 220), rarity = "Secret" },
}

local GODLY = {
	{ name = "Meowl",                value = 25000, color = Color3.fromRGB(255, 200, 150), rarity = "Godly" },
	{ name = "Skibidi Toilet",       value = 50000, color = Color3.fromRGB(255, 255, 200), rarity = "Godly" },
	{ name = "TV MAN",               value = 75000, color = Color3.fromRGB(180, 180, 255), rarity = "Godly" },
}

local function merge(a, b)
	local result = {}
	for _, v in ipairs(a) do table.insert(result, v) end
	for _, v in ipairs(b) do table.insert(result, v) end
	return result
end

BrainrotCatalog.Tiers = {
	-- 1: Common
	{ rarity = "Common",    zMin = -306, zMax = -102, brainrots = COMMON },
	-- 2: Rare + Common
	{ rarity = "Rare",      zMin = -89,  zMax = 35,   brainrots = merge(RARE, COMMON) },
	-- 3: Rare
	{ rarity = "Rare",      zMin = 48,   zMax = 238,  brainrots = RARE },
	-- 4: Rare + Epic
	{ rarity = "Epic",      zMin = 252,  zMax = 540,  brainrots = merge(RARE, EPIC) },
	-- 5: Epic + Rare
	{ rarity = "Epic",      zMin = 554,  zMax = 995,  brainrots = merge(EPIC, RARE) },
	-- 6: Epic + Legendary
	{ rarity = "Legendary", zMin = 1014, zMax = 1648, brainrots = merge(EPIC, LEGENDARY) },
	-- 7: Legendary
	{ rarity = "Legendary", zMin = 1688, zMax = 2317, brainrots = LEGENDARY },
	-- 8: Legendary + Mythic
	{ rarity = "Mythic",    zMin = 2359, zMax = 2649, brainrots = merge(LEGENDARY, MYTHIC) },
	-- 9: Mythic + Divine
	{ rarity = "Divine",    zMin = 2702, zMax = 2987, brainrots = merge(MYTHIC, DIVINE) },
	-- 10: Secret
	{ rarity = "Secret",    zMin = 3040, zMax = 3328, brainrots = SECRET },
	-- 11: Godly
	{ rarity = "Godly",     zMin = 3381, zMax = 3631, brainrots = GODLY },
}

return BrainrotCatalog
