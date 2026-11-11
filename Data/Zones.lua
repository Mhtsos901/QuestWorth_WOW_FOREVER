--[[
    WorthIt / QuestWorth - Data/Zones.lua
    Classic & WoW Forever geographical leveling zone database.
    Contains level brackets, faction-specific entry levels, map metadata,
    and mob ecology tags (undead, elemental, mechanical, humanoid, beasts, open terrain, caves).
]]

local addonName, addon = ...
addon.Data = addon.Data or {}

addon.Data.Zones = {
    -- =========================================================================
    -- EASTERN KINGDOMS
    -- =========================================================================
    ["Dun Morogh"]          = { min = 1,  max = 10, faction = "Alliance",  continent = 2, mapID = 1426, beastHeavy = true, humanoidHeavy = true },
    ["Elwynn Forest"]       = { min = 1,  max = 10, faction = "Alliance",  continent = 2, mapID = 1429, humanoidHeavy = true, beastHeavy = true },
    ["Tirisfal Glades"]     = { min = 1,  max = 10, faction = "Horde",     continent = 2, mapID = 1420, undeadHeavy = true, humanoidHeavy = true },
    ["Loch Modan"]          = { min = 10, max = 20, faction = "Alliance",  continent = 2, mapID = 1432, allianceMin = 10, humanoidHeavy = true, beastHeavy = true },
    ["Westfall"]            = { min = 10, max = 20, faction = "Alliance",  continent = 2, mapID = 1436, allianceMin = 10, humanoidHeavy = true, mechanicalHeavy = true, openTerrain = true },
    ["Silverpine Forest"]   = { min = 10, max = 20, faction = "Horde",     continent = 2, mapID = 1421, hordeMin = 10, undeadHeavy = true, beastHeavy = true, humanoidHeavy = true },
    ["Redridge Mountains"]  = { min = 15, max = 25, faction = "Alliance",  continent = 2, mapID = 1433, allianceMin = 15, humanoidHeavy = true, hasMidDip = true },
    ["Duskwood"]            = { min = 18, max = 30, faction = "Alliance",  continent = 2, mapID = 1431, allianceMin = 22, hordeMin = 22, undeadHeavy = true },
    ["Hillsbrad Foothills"] = { min = 20, max = 30, faction = "Contested", continent = 2, mapID = 1424, allianceMin = 23, hordeMin = 20, humanoidHeavy = true, openTerrain = true },
    ["Wetlands"]            = { min = 20, max = 30, faction = "Alliance",  continent = 2, mapID = 1437, allianceMin = 20, humanoidHeavy = true, beastHeavy = true, openTerrain = true },
    ["Alterac Mountains"]   = { min = 30, max = 40, faction = "Contested", continent = 2, mapID = 1416, allianceMin = 30, hordeMin = 30, humanoidHeavy = true, denseCaves = true },
    ["Arathi Highlands"]    = { min = 30, max = 40, faction = "Contested", continent = 2, mapID = 1417, allianceMin = 30, hordeMin = 30, humanoidHeavy = true, elementalHeavy = true, openTerrain = true },
    ["Badlands"]            = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 1418, effectiveMin = 38, allianceMin = 38, hordeMin = 38, elementalHeavy = true, humanoidHeavy = true, openTerrain = true },
    ["Swamp of Sorrows"]    = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 1435, hordeMin = 35, allianceMin = 38, beastHeavy = true, humanoidHeavy = true },
    ["Stranglethorn Vale"]  = { min = 30, max = 45, faction = "Contested", continent = 2, mapID = 1434, effectiveMin = 32, allianceMin = 32, hordeMin = 32, beastHeavy = true, humanoidHeavy = true },
    ["Searing Gorge"]       = { min = 43, max = 50, faction = "Contested", continent = 2, mapID = 1427, effectiveMin = 44, allianceMin = 44, hordeMin = 44, elementalHeavy = true, humanoidHeavy = true, denseCaves = true },
    ["The Hinterlands"]     = { min = 40, max = 50, faction = "Contested", continent = 2, mapID = 1425, allianceMin = 40, hordeMin = 43, humanoidHeavy = true, beastHeavy = true },
    ["Blasted Lands"]       = { min = 45, max = 55, faction = "Contested", continent = 2, mapID = 1419, effectiveMin = 47, allianceMin = 47, hordeMin = 47, beastHeavy = true, elementalHeavy = true },
    ["Burning Steppes"]     = { min = 50, max = 58, faction = "Contested", continent = 2, mapID = 1428, effectiveMin = 50, allianceMin = 50, hordeMin = 50, elementalHeavy = true, humanoidHeavy = true },
    ["Western Plaguelands"] = { min = 51, max = 58, faction = "Contested", continent = 2, mapID = 1422, effectiveMin = 51, allianceMin = 51, hordeMin = 51, undeadHeavy = true, humanoidHeavy = true },
    ["Eastern Plaguelands"] = { min = 53, max = 60, faction = "Contested", continent = 2, mapID = 1423, effectiveMin = 54, allianceMin = 54, hordeMin = 54, undeadHeavy = true },
    ["Deadwind Pass"]       = { min = 55, max = 60, faction = "Contested", continent = 2, mapID = 1430, undeadHeavy = true },
    ["Riverglades"]         = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 2548, beastHeavy = true, humanoidHeavy = true },
    ["Riverlands"]          = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 2548, beastHeavy = true, humanoidHeavy = true },

    -- =========================================================================
    -- KALIMDOR
    -- =========================================================================
    ["Durotar"]             = { min = 1,  max = 10, faction = "Horde",     continent = 1, mapID = 1411, humanoidHeavy = true, beastHeavy = true },
    ["Mulgore"]             = { min = 1,  max = 10, faction = "Horde",     continent = 1, mapID = 1412, humanoidHeavy = true, beastHeavy = true, openTerrain = true },
    ["Teldrassil"]          = { min = 1,  max = 10, faction = "Alliance",  continent = 1, mapID = 1438, beastHeavy = true, humanoidHeavy = true },
    ["Darkshore"]           = { min = 10, max = 20, faction = "Alliance",  continent = 1, mapID = 1439, allianceMin = 10, humanoidHeavy = true, beastHeavy = true },
    ["The Barrens"]         = { min = 10, max = 25, faction = "Horde",     continent = 1, mapID = 1413, hordeMin = 10, humanoidHeavy = true, beastHeavy = true, openTerrain = true },
    ["Ashenvale"]           = { min = 18, max = 30, faction = "Contested", continent = 1, mapID = 1440, allianceMin = 19, hordeMin = 22, humanoidHeavy = true, beastHeavy = true },
    ["Stonetalon Mountains"]= { min = 15, max = 27, faction = "Contested", continent = 1, mapID = 1442, hordeMin = 16, allianceMin = 20, humanoidHeavy = true, mechanicalHeavy = true },
    ["Thousand Needles"]    = { min = 25, max = 35, faction = "Contested", continent = 1, mapID = 1441, hordeMin = 25, allianceMin = 28, humanoidHeavy = true, beastHeavy = true, openTerrain = true },
    ["Desolace"]            = { min = 30, max = 40, faction = "Contested", continent = 1, mapID = 1443, allianceMin = 30, hordeMin = 30, undeadHeavy = true, humanoidHeavy = true, openTerrain = true },
    ["Dustwallow Marsh"]    = { min = 35, max = 45, faction = "Contested", continent = 1, mapID = 1445, hordeMin = 35, allianceMin = 36, beastHeavy = true, humanoidHeavy = true, openTerrain = true },
    ["Feralas"]             = { min = 40, max = 50, faction = "Contested", continent = 1, mapID = 1444, allianceMin = 40, hordeMin = 40, beastHeavy = true, humanoidHeavy = true },
    ["Tanaris"]             = { min = 40, max = 50, faction = "Contested", continent = 1, mapID = 1446, allianceMin = 40, hordeMin = 40, humanoidHeavy = true, beastHeavy = true, openTerrain = true },
    ["Azshara"]             = { min = 45, max = 55, faction = "Contested", continent = 1, mapID = 1447, allianceMin = 45, hordeMin = 45, humanoidHeavy = true, elementalHeavy = true },
    ["Felwood"]             = { min = 48, max = 55, faction = "Contested", continent = 1, mapID = 1448, effectiveMin = 48, allianceMin = 48, hordeMin = 48, elementalHeavy = true, humanoidHeavy = true, beastHeavy = true },
    ["Un'Goro Crater"]      = { min = 48, max = 55, faction = "Contested", continent = 1, mapID = 1449, effectiveMin = 49, allianceMin = 49, hordeMin = 49, beastHeavy = true, elementalHeavy = true },
    ["Silithus"]            = { min = 55, max = 60, faction = "Contested", continent = 1, mapID = 1451, effectiveMin = 55, allianceMin = 55, hordeMin = 55, elementalHeavy = true, beastHeavy = true, openTerrain = true },
    ["Winterspring"]        = { min = 53, max = 60, faction = "Contested", continent = 1, mapID = 1452, effectiveMin = 53, allianceMin = 53, hordeMin = 53, beastHeavy = true, humanoidHeavy = true },
    ["Moonglade"]           = { min = 1,  max = 60, faction = "Neutral",   continent = 1, mapID = 1450, class = "DRUID" },
    ["Zephras Isle"]        = { min = 1,  max = 12, faction = "Contested", continent = 1, mapID = 2521 },
    ["Mount Hyjal"]         = { min = 58, max = 60, faction = "Contested", continent = 1, mapID = 1459, elementalHeavy = true, humanoidHeavy = true },
    ["Hyjal"]               = { min = 58, max = 60, faction = "Contested", continent = 1, mapID = 1459, elementalHeavy = true, humanoidHeavy = true },

    -- =========================================================================
    -- MAJOR CITIES
    -- =========================================================================
    ["Stormwind City"]      = { min = 1,  max = 60, faction = "Alliance",  continent = 2, mapID = 1453, isCity = true },
    ["Ironforge"]           = { min = 1,  max = 60, faction = "Alliance",  continent = 2, mapID = 1455, isCity = true },
    ["Darnassus"]           = { min = 1,  max = 60, faction = "Alliance",  continent = 1, mapID = 1457, isCity = true },
    ["Orgrimmar"]           = { min = 1,  max = 60, faction = "Horde",     continent = 1, mapID = 1454, isCity = true },
    ["Thunder Bluff"]       = { min = 1,  max = 60, faction = "Horde",     continent = 1, mapID = 1456, isCity = true },
    ["Undercity"]           = { min = 1,  max = 60, faction = "Horde",     continent = 2, mapID = 1458, isCity = true },
}

-- Helper function to lookup zone info by name (supports flexible casing and aliases)
function addon.Data.GetZoneInfo(zoneName)
    if not zoneName then return nil end
    local clean = string.gsub(zoneName, "^%s*(.-)%s*$", "%1")
    if addon.Data.Zones[clean] then
        return addon.Data.Zones[clean]
    end

    -- Case-insensitive lookup
    local lower = string.lower(clean)
    for name, info in pairs(addon.Data.Zones) do
        if string.lower(name) == lower then
            return info
        end
    end

    -- Flexible "The " prefix handling (e.g. "The Barrens" <-> "Barrens")
    local noThe = string.gsub(lower, "^the%s+", "")
    for name, info in pairs(addon.Data.Zones) do
        local nameLower = string.lower(name)
        local nameNoThe = string.gsub(nameLower, "^the%s+", "")
        if nameNoThe == noThe then
            return info
        end
    end

    return nil
end
