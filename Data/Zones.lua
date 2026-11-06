--[[
    WorthIt / QuestWorth - Data/Zones.lua
    Classic & WoW Forever geographical leveling zone database.
    Contains level brackets, faction alignments, and map metadata.
]]

local addonName, addon = ...
addon.Data = addon.Data or {}

addon.Data.Zones = {
    -- =========================================================================
    -- EASTERN KINGDOMS
    -- =========================================================================
    ["Dun Morogh"]          = { min = 1,  max = 10, faction = "Alliance",  continent = 2 },
    ["Elwynn Forest"]       = { min = 1,  max = 10, faction = "Alliance",  continent = 2 },
    ["Tirisfal Glades"]     = { min = 1,  max = 10, faction = "Horde",     continent = 2 },
    ["Loch Modan"]          = { min = 10, max = 20, faction = "Alliance",  continent = 2 },
    ["Westfall"]            = { min = 10, max = 20, faction = "Alliance",  continent = 2 },
    ["Silverpine Forest"]   = { min = 10, max = 20, faction = "Horde",     continent = 2 },
    ["Redridge Mountains"]  = { min = 15, max = 25, faction = "Alliance",  continent = 2 },
    ["Duskwood"]            = { min = 18, max = 30, faction = "Alliance",  continent = 2 },
    ["Hillsbrad Foothills"] = { min = 20, max = 30, faction = "Contested", continent = 2 },
    ["Wetlands"]            = { min = 20, max = 30, faction = "Alliance",  continent = 2 },
    ["Alterac Mountains"]   = { min = 30, max = 40, faction = "Contested", continent = 2 },
    ["Arathi Highlands"]    = { min = 30, max = 40, faction = "Contested", continent = 2 },
    ["Badlands"]            = { min = 35, max = 45, faction = "Contested", continent = 2 },
    ["Swamp of Sorrows"]    = { min = 35, max = 45, faction = "Contested", continent = 2 },
    ["Stranglethorn Vale"]  = { min = 30, max = 45, faction = "Contested", continent = 2 },
    ["Searing Gorge"]       = { min = 43, max = 50, faction = "Contested", continent = 2 },
    ["The Hinterlands"]     = { min = 40, max = 50, faction = "Contested", continent = 2 },
    ["Blasted Lands"]       = { min = 45, max = 55, faction = "Contested", continent = 2 },
    ["Burning Steppes"]     = { min = 50, max = 58, faction = "Contested", continent = 2 },
    ["Western Plaguelands"] = { min = 51, max = 58, faction = "Contested", continent = 2 },
    ["Eastern Plaguelands"] = { min = 53, max = 60, faction = "Contested", continent = 2 },
    ["Deadwind Pass"]       = { min = 55, max = 60, faction = "Contested", continent = 2 },

    -- =========================================================================
    -- KALIMDOR
    -- =========================================================================
    ["Durotar"]             = { min = 1,  max = 10, faction = "Horde",     continent = 1 },
    ["Mulgore"]             = { min = 1,  max = 10, faction = "Horde",     continent = 1 },
    ["Teldrassil"]          = { min = 1,  max = 10, faction = "Alliance",  continent = 1 },
    ["Darkshore"]           = { min = 10, max = 20, faction = "Alliance",  continent = 1 },
    ["The Barrens"]         = { min = 10, max = 25, faction = "Horde",     continent = 1 },
    ["Ashenvale"]           = { min = 18, max = 30, faction = "Contested", continent = 1 },
    ["Stonetalon Mountains"]= { min = 15, max = 27, faction = "Contested", continent = 1 },
    ["Thousand Needles"]    = { min = 25, max = 35, faction = "Contested", continent = 1 },
    ["Desolace"]            = { min = 30, max = 40, faction = "Contested", continent = 1 },
    ["Dustwallow Marsh"]    = { min = 35, max = 45, faction = "Contested", continent = 1 },
    ["Feralas"]             = { min = 40, max = 50, faction = "Contested", continent = 1 },
    ["Tanaris"]             = { min = 40, max = 50, faction = "Contested", continent = 1 },
    ["Azshara"]             = { min = 45, max = 55, faction = "Contested", continent = 1 },
    ["Felwood"]             = { min = 48, max = 55, faction = "Contested", continent = 1 },
    ["Un'Goro Crater"]      = { min = 48, max = 55, faction = "Contested", continent = 1 },
    ["Silithus"]            = { min = 55, max = 60, faction = "Contested", continent = 1 },
    ["Winterspring"]        = { min = 53, max = 60, faction = "Contested", continent = 1 },
    ["Moonglade"]           = { min = 1,  max = 60, faction = "Neutral",   continent = 1 },
}

-- Helper function to lookup zone info by name
function addon.Data.GetZoneInfo(zoneName)
    if not zoneName then return nil end
    local clean = string.gsub(zoneName, "^%s*(.-)%s*$", "%1")
    return addon.Data.Zones[clean]
end
