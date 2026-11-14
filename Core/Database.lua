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
    highlightQuestObjects = true,
    zoneAdvisorFilter = "ALL",
    weights = {
        reward = 0.40,
        classFit = 0.25,
        chain = 0.25,
        density = 0.10,
        difficulty = 0.00,
    },
    version = 8,
}

local function CopyDefaults(src, dest)
    if type(src) ~= "table" then return dest end
    if type(dest) ~= "table" then dest = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dest[k]) ~= "table" then
                dest[k] = {}
            end
            dest[k] = CopyDefaults(v, dest[k])
        elseif dest[k] == nil or type(dest[k]) ~= type(v) then
            dest[k] = v
        end
    end
    return dest
end

local function SanitizeSettings(db)
    if type(db) ~= "table" then return CopyDefaults(DEFAULT_SETTINGS, {}) end

    -- Verify boolean settings
    local boolKeys = {
        "enabled", "debug", "showInTooltip", "showBreakdown",
        "showInQuestLog", "showInTracker", "showInWorldMap", "showZoneAdvisor",
        "highlightQuestObjects"
    }
    for _, k in ipairs(boolKeys) do
        if type(db[k]) ~= "boolean" then
            db[k] = DEFAULT_SETTINGS[k]
        end
    end

    -- Verify zoneAdvisorFilter
    if type(db.zoneAdvisorFilter) ~= "string" or (db.zoneAdvisorFilter ~= "ALL" and db.zoneAdvisorFilter ~= "OPTIMAL" and db.zoneAdvisorFilter ~= "ACTIVE") then
        db.zoneAdvisorFilter = "ALL"
    end

    -- Verify weights table and values
    if type(db.weights) ~= "table" then
        db.weights = CopyDefaults(DEFAULT_SETTINGS.weights, {})
    else
        local weightSum = 0
        for k, defVal in pairs(DEFAULT_SETTINGS.weights) do
            local w = db.weights[k]
            if type(w) ~= "number" or w < 0 or w > 1 then
                db.weights[k] = defVal
            end
            weightSum = weightSum + db.weights[k]
        end
        -- If all weights were set to 0 or corrupted so sum is near 0, restore defaults
        if weightSum <= 0.001 then
            db.weights = CopyDefaults(DEFAULT_SETTINGS.weights, {})
        end
    end

    return db
end

function DB.Initialize()
    if type(WorthItDB) ~= "table" then
        if type(QuestWorthDB) == "table" then
            WorthItDB = QuestWorthDB
        else
            WorthItDB = {}
        end
    end

    if not WorthItDB.version or type(WorthItDB.version) ~= "number" or WorthItDB.version < 8 then
        WorthItDB.weights = CopyDefaults(DEFAULT_SETTINGS.weights, {})
        WorthItDB.version = 8
    end

    WorthItDB = CopyDefaults(DEFAULT_SETTINGS, WorthItDB)
    WorthItDB = SanitizeSettings(WorthItDB)
    QuestWorthDB = WorthItDB

    addon.db = WorthItDB
end

function DB.Reset()
    if type(WorthItDB) == "table" and wipe then
        wipe(WorthItDB)
    else
        WorthItDB = {}
    end
    WorthItDB = CopyDefaults(DEFAULT_SETTINGS, WorthItDB)
    WorthItDB = SanitizeSettings(WorthItDB)
    QuestWorthDB = WorthItDB
    addon.db = WorthItDB

    if addon.Engine and addon.Engine.InvalidateCache then
        addon.Engine.InvalidateCache()
    end
end
