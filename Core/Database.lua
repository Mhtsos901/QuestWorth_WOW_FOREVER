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
    showMetaIndicator = true,
    zoneAdvisorFilter = "ALL",
    completedDungeons = {},
    completedDungeonsByChar = {},
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
        "showMetaIndicator"
    }
    for _, k in ipairs(boolKeys) do
        if type(db[k]) ~= "boolean" then
            db[k] = DEFAULT_SETTINGS[k]
        end
    end
    db.highlightQuestObjects = nil

    -- Verify zoneAdvisorFilter
    if db.zoneAdvisorFilter == "ACTIVE" then
        db.zoneAdvisorFilter = "DUNGEONS"
    elseif type(db.zoneAdvisorFilter) ~= "string" or (db.zoneAdvisorFilter ~= "ALL" and db.zoneAdvisorFilter ~= "DUNGEONS") then
        db.zoneAdvisorFilter = "ALL"
    end

    if type(db.completedDungeons) ~= "table" then
        db.completedDungeons = {}
    end
    if type(db.completedDungeonsByChar) ~= "table" then
        db.completedDungeonsByChar = {}
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

local DUNGEON_KEY_ALIASES = {
    ["temple of atal'hakkar"] = "sunken temple",
    ["stormwind stockade"]    = "stockade",
}

local function NormalizeDungeonToken(zoneName)
    if type(zoneName) ~= "string" then return "" end
    local token = zoneName:lower():match("^%s*(.-)%s*$") or ""
    token = token:gsub("^the%s+", "")
    return DUNGEON_KEY_ALIASES[token] or token
end

local function FindMatchingDungeonKey(tbl, zoneName)
    if type(tbl) ~= "table" or type(zoneName) ~= "string" or zoneName == "" then
        return nil
    end
    if tbl[zoneName] ~= nil then
        return zoneName
    end
    local targetToken = NormalizeDungeonToken(zoneName)
    if targetToken == "" then return nil end
    for k in pairs(tbl) do
        if type(k) == "string" and NormalizeDungeonToken(k) == targetToken then
            return k
        end
    end
    return nil
end

local function GetCharDungeonTable(createIfMissing)
    local db = addon.db or WorthItDB
    if type(db) ~= "table" then return nil end
    if type(db.completedDungeonsByChar) ~= "table" then
        if not createIfMissing then return nil end
        db.completedDungeonsByChar = {}
    end
    local charKey = (addon.Player and addon.Player.GetCharacterKey and addon.Player.GetCharacterKey()) or "Default"
    local charTbl = db.completedDungeonsByChar[charKey]
    if type(charTbl) ~= "table" then
        if not createIfMissing then return nil end
        charTbl = {}
        db.completedDungeonsByChar[charKey] = charTbl
    end
    return charTbl
end

function DB.IsDungeonCompleted(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then
        return false
    end
    local charTbl = GetCharDungeonTable(false)
    if not charTbl then return false end
    local key = FindMatchingDungeonKey(charTbl, zoneName)
    return key ~= nil and charTbl[key] == true
end

function DB.SetDungeonCompleted(zoneName, completed)
    if type(zoneName) ~= "string" or zoneName == "" then
        return false
    end
    local charTbl = GetCharDungeonTable(true)
    if not charTbl then return false end
    local isDone = completed and true or false
    if isDone then
        local existing = FindMatchingDungeonKey(charTbl, zoneName)
        charTbl[existing or zoneName] = true
    else
        local targetToken = NormalizeDungeonToken(zoneName)
        for k in pairs(charTbl) do
            if type(k) == "string" and NormalizeDungeonToken(k) == targetToken then
                charTbl[k] = nil
            end
        end
        charTbl[zoneName] = nil
    end
    if addon.Engine and addon.Engine.InvalidateCache then
        addon.Engine.InvalidateCache()
    end
    return isDone
end

function DB.ToggleDungeonCompleted(zoneName)
    local nextState = not DB.IsDungeonCompleted(zoneName)
    return DB.SetDungeonCompleted(zoneName, nextState)
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
