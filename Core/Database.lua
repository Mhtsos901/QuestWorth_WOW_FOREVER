--[[
    WorthIt / QuestWorth - Core/Database.lua
    SavedVariables management and default configuration.
]]

local addonName, addon = ...
addon.DB = {}
local DB = addon.DB

local DEFAULT_SETTINGS = {
    enabled = true,
    debug = false,
    showInTooltip = true,
    showBreakdown = true,
    showInQuestLog = true,
    showInTracker = true,
    showInWorldMap = true,
    showZoneAdvisor = true,
    zoneAdvisorFilter = "ALL",
    weights = {
        difficulty = 0.10,
        reward = 0.35,
        chain = 0.25,
        classFit = 0.15,
        density = 0.15,
    },
    version = 6,
}

local function CopyDefaults(src, dest)
    if type(src) ~= "table" then return dest end
    if type(dest) ~= "table" then dest = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dest[k] = CopyDefaults(v, dest[k])
        elseif dest[k] == nil then
            dest[k] = v
        end
    end
    return dest
end

function DB.Initialize()
    if type(WorthItDB) ~= "table" then
        if type(QuestWorthDB) == "table" then
            WorthItDB = QuestWorthDB
        else
            WorthItDB = {}
        end
    end

    if not WorthItDB.version or WorthItDB.version < 6 then
        WorthItDB.weights = {
            difficulty = 0.10,
            reward = 0.35,
            chain = 0.25,
            classFit = 0.15,
            density = 0.15,
        }
        WorthItDB.version = 6
    end

    WorthItDB = CopyDefaults(DEFAULT_SETTINGS, WorthItDB)
    QuestWorthDB = WorthItDB

    addon.db = WorthItDB
end

function DB.Reset()
    if WorthItDB then
        wipe(WorthItDB)
    else
        WorthItDB = {}
    end
    WorthItDB = CopyDefaults(DEFAULT_SETTINGS, WorthItDB)
    QuestWorthDB = WorthItDB
    addon.db = WorthItDB

    if addon.Engine and addon.Engine.InvalidateCache then
        addon.Engine.InvalidateCache()
    end
end
