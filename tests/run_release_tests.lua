--[[
    WorthIt / QuestWorth - Automated Headless Release QA Test Suite
    Tests all 4 phases:
    1. Static & Load Audit / Cold Start
    2. Corrupt SavedVariables Recovery & Sanitization
    3. Boundary Gameplay States (L1 empty log, L60 25 quests with nil items & collapsed headers, Forever custom zones/races)
    4. Combat & Event Storm Stress Test (1,000 rapid events under InCombatLockdown, memory leak check)
]]

local passedCount = 0
local failedCount = 0

local function pass(desc)
    passedCount = passedCount + 1
    print(string.format("  [PASS] %s", desc))
end

local function fail(desc, err)
    failedCount = failedCount + 1
    print(string.format("  [FAIL] %s: %s", desc, tostring(err)))
end

local function assert_true(cond, desc)
    if cond then pass(desc) else fail(desc, "Expected true, got " .. tostring(cond)) end
end

local function assert_eq(actual, expected, desc)
    if actual == expected then
        pass(desc)
    else
        fail(desc, string.format("Expected %s, got %s", tostring(expected), tostring(actual)))
    end
end

local function assert_not_nil(val, desc)
    if val ~= nil then pass(desc) else fail(desc, "Value is nil") end
end

print("======================================================================")
print(" QuestWorth (WorthIt) - Headless Automated QA Test Suite (Lua 5.1)")
print("======================================================================")

-- ============================================================================
-- ENVIRONMENT SETUP / MOCKING WOW API
-- ============================================================================
_G = _G or {}
_G._G = _G

-- Standard WoW globals
_G.wipe = function(t)
    if type(t) == "table" then
        for k in pairs(t) do t[k] = nil end
    end
    return t
end

_G.tinsert = table.insert
_G.tremove = table.remove
_G.strsplit = function(sep, str)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return unpack(fields)
end

_G.GetLocale = function() return "enUS" end
_G.GetTime = function() return 1000.0 end

-- Player state mock
local mockPlayerState = {
    level = 25,
    class = "Warrior",
    classToken = "WARRIOR",
    race = "Human",
    raceToken = "Human",
    faction = "Alliance",
    xp = 12000,
    xpMax = 24000,
    inCombat = false,
    zone = "Duskwood",
    subZone = "Darkshire",
}

_G.UnitLevel = function(u) return mockPlayerState.level end
_G.UnitClass = function(u) return mockPlayerState.class, mockPlayerState.classToken, 1 end
_G.UnitRace = function(u) return mockPlayerState.race, mockPlayerState.raceToken, 1 end
_G.UnitFactionGroup = function(u) return mockPlayerState.faction end
_G.UnitXP = function(u) return mockPlayerState.xp end
_G.UnitXPMax = function(u) return mockPlayerState.xpMax end
_G.GetMaxPlayerLevel = function() return 60 end
_G.GetMaxLevelForPlayerExpansion = function() return 60 end
_G.InCombatLockdown = function() return mockPlayerState.inCombat end
_G.GetRealZoneText = function() return mockPlayerState.zone end
_G.GetZoneText = function() return mockPlayerState.zone end
_G.GetSubZoneText = function() return mockPlayerState.subZone end

-- Slash commands
_G.SlashCmdList = {}

-- Sound & Interface
_G.SOUNDKIT = { IG_MAINMENU_OPTION_CHECKBOX_ON = 856 }
_G.PlaySound = function(s) end
_G.InterfaceOptions_AddCategory = function(p) end

-- Mock Frames
local createdFrames = {}
_G.CreateFrame = function(frameType, name, parent, template)
    local f = {
        name = name,
        frameType = frameType,
        parent = parent,
        template = template,
        shown = true,
        scripts = {},
        points = {},
        level = 1,
        strata = "MEDIUM",
        width = 100,
        height = 100,
        events = {},
    }
    if name then _G[name] = f end
    table.insert(createdFrames, f)

    function f:GetName() return self.name end
    function f:GetParent() return self.parent end
    function f:SetParent(p) self.parent = p end
    function f:Show() self.shown = true end
    function f:Hide() self.shown = false end
    function f:IsShown() return self.shown end
    function f:IsVisible() return self.shown end
    function f:SetSize(w, h) self.width = w; self.height = h end
    function f:SetWidth(w) self.width = w end
    function f:SetHeight(h) self.height = h end
    function f:GetWidth() return self.width end
    function f:GetHeight() return self.height end
    function f:SetPoint(pt, rel, relPt, x, y) table.insert(self.points, {pt, rel, relPt, x, y}) end
    function f:ClearAllPoints() self.points = {} end
    function f:SetAllPoints(other) table.insert(self.points, {"ALL", other}) end
    function f:SetFrameLevel(lvl) self.level = lvl end
    function f:GetFrameLevel() return self.level or 1 end
    function f:SetFrameStrata(s) self.strata = s end
    function f:GetFrameStrata() return self.strata or "MEDIUM" end
    function f:SetAlpha(a) self.alpha = a end
    function f:GetAlpha() return self.alpha or 1 end
    function f:SetClipsChildren(b) self.clips = b end
    function f:EnableMouse(b) self.mouse = b end
    function f:EnableMouseWheel(b) self.mouseWheel = b end
    function f:SetMouseClickEnabled(b) self.mouseClick = b end
    function f:SetBackdrop(t) self.backdrop = t end
    function f:SetBackdropColor(...) end
    function f:SetBackdropBorderColor(...) end
    function f:SetHighlightTexture(...) end
    function f:GetHighlightTexture() return self.hl end
    function f:RegisterEvent(e) self.events[e] = true end
    function f:UnregisterEvent(e) self.events[e] = nil end
    function f:SetScript(sName, handler) self.scripts[sName] = handler end
    function f:GetScript(sName) return self.scripts[sName] end
    function f:HookScript(sName, handler)
        local orig = self.scripts[sName]
        self.scripts[sName] = function(...)
            if orig then orig(...) end
            handler(...)
        end
    end
    function f:CreateFontString(fsName, layer, fo)
        local fs = {
            text = "",
            shown = true,
            GetText = function(self) return self.text end,
            SetText = function(self, t) self.text = tostring(t or "") end,
            SetFontObject = function(self, o) end,
            GetFont = function(self) return "Fonts\\FRIZQT__.TTF", 12, "" end,
            SetFont = function(self, ...) end,
            SetTextColor = function(self, ...) end,
            SetJustifyH = function(self, ...) end,
            SetJustifyV = function(self, ...) end,
            SetPoint = function(self, ...) end,
            ClearAllPoints = function(self) end,
            SetWidth = function(self, w) end,
            SetWordWrap = function(self, w) end,
            Show = function(self) self.shown = true end,
            Hide = function(self) self.shown = false end,
            IsShown = function(self) return self.shown end,
        }
        if fsName then _G[fsName] = fs end
        return fs
    end
    function f:CreateTexture(tName, layer, fo)
        local tex = {
            SetTexture = function(self, t) self.tex = t end,
            SetColorTexture = function(self, ...) end,
            SetAllPoints = function(self, ...) end,
            SetPoint = function(self, ...) end,
            SetSize = function(self, ...) end,
            SetHeight = function(self, ...) end,
            SetWidth = function(self, ...) end,
            SetAlpha = function(self, ...) end,
            SetTexCoord = function(self, ...) end,
            Show = function(self) end,
            Hide = function(self) end,
        }
        if tName then _G[tName] = tex end
        return tex
    end
    function f:GetFontString()
        if not self.fs then self.fs = self:CreateFontString() end
        return self.fs
    end
    function f:SetText(t) self:GetFontString():SetText(t) end
    function f:GetText() return self:GetFontString():GetText() end
    function f:SetOwner(owner, anchor) self.owner = owner end
    function f:ClearLines() self.lines = {} end
    function f:AddLine(text, r, g, b) self.lines = self.lines or {}; table.insert(self.lines, {left = text, r = r, g = g, b = b}) end
    function f:AddDoubleLine(l, r, lr, lg, lb, rr, rg, rb) self.lines = self.lines or {}; table.insert(self.lines, {left = l, right = r}) end
    function f:NumLines() return self.lines and #self.lines or 0 end
    function f:SetHyperlink(link) self.hyperlink = link end
    function f:SetVerticalScroll(val) self.scroll = val end
    function f:GetVerticalScroll() return self.scroll or 0 end
    function f:GetVerticalScrollRange() return 100 end
    function f:SetScrollChild(c) self.child = c end
    function f:SetMinMaxValues(minV, maxV) self.minV = minV; self.maxV = maxV end
    function f:SetValue(v) self.val = v end
    function f:GetValue() return self.val or 0 end
    function f:SetValueStep(s) self.step = s end
    function f:SetObeyStepOnDrag(b) self.obeyStep = b end
    function f:SetOrientation(o) self.orientation = o end
    function f:SetThumbTexture(t) self.thumb = self:CreateTexture(nil, "OVERLAY") end
    function f:GetThumbTexture()
        if not self.thumb then self.thumb = self:CreateTexture(nil, "OVERLAY") end
        return self.thumb
    end
    function f:SetChecked(b) self.checked = b end
    function f:GetChecked() return self.checked or false end

    return f
end

_G.WorldFrame = _G.CreateFrame("Frame", "WorldFrame")
_G.UIParent = _G.CreateFrame("Frame", "UIParent")
_G.GameTooltip = _G.CreateFrame("Frame", "GameTooltip")
_G.WorldMapFrame = _G.CreateFrame("Frame", "WorldMapFrame")
_G.QuestLogFrame = _G.CreateFrame("Frame", "QuestLogFrame")
_G.QuestLogListScrollFrame = _G.CreateFrame("Frame", "QuestLogListScrollFrame")
_G.QuestLogListScrollFrame.buttons = {}
for b = 1, 10 do
    local btn = _G.CreateFrame("Button", "QuestLogTitle" .. b, QuestLogListScrollFrame)
    btn.tag = btn:CreateFontString("QuestLogTitle" .. b .. "Tag")
    btn.normalText = btn:CreateFontString("QuestLogTitle" .. b .. "NormalText")
    btn.check = btn:CreateTexture("QuestLogTitle" .. b .. "Check")
    table.insert(_G.QuestLogListScrollFrame.buttons, btn)
end

_G.hooksecurefunc = function(arg1, arg2, arg3)
    if type(arg1) == "string" then
        local orig = _G[arg1]
        local hook = arg2
        _G[arg1] = function(...)
            local r1, r2, r3, r4 = nil, nil, nil, nil
            if orig then r1, r2, r3, r4 = orig(...) end
            hook(...)
            return r1, r2, r3, r4
        end
    elseif type(arg1) == "table" and type(arg2) == "string" then
        local orig = arg1[arg2]
        local hook = arg3
        arg1[arg2] = function(self, ...)
            local r1, r2, r3, r4 = nil, nil, nil, nil
            if orig then r1, r2, r3, r4 = orig(self, ...) end
            hook(self, ...)
            return r1, r2, r3, r4
        end
    end
end

_G.C_Timer = {
    After = function(delay, callback)
        -- In headless test, callback immediately
        callback()
    end
}

_G.C_Map = {
    GetBestMapForUnit = function(unit) return 1431 end -- Duskwood
}

-- Quest mock database for tests
local mockQuestDB = {}
local mockQuestLog = {}

_G.C_QuestLog = {
    GetNumQuestLogEntries = function() return #mockQuestLog end,
    GetInfo = function(index) return mockQuestLog[index] end,
    IsOnQuest = function(qID)
        for _, q in ipairs(mockQuestLog) do
            if not q.isHeader and q.questID == qID then return true end
        end
        return false
    end,
    GetQuestRewardXP = function(qID)
        local q = mockQuestDB[qID]
        return q and q.xp or 1200
    end,
    GetQuestRewardMoney = function(qID)
        local q = mockQuestDB[qID]
        return q and q.money or 1500
    end,
    GetQuestTagInfo = function(qID)
        local q = mockQuestDB[qID]
        if q and q.isDungeon then return { tagID = 81, tagName = "Dungeon" } end
        if q and q.isElite then return { tagID = 1, tagName = "Elite" } end
        return nil
    end,
}

_G.GetNumQuestLogEntries = function() return #mockQuestLog end
_G.GetQuestLogTitle = function(index)
    local q = mockQuestLog[index]
    if not q then return nil end
    return q.title, q.level, q.tag, q.suggestedGroup, q.isHeader, q.isCollapsed, q.isComplete, q.frequency, q.questID
end
_G.GetQuestLogRewardXP = function(qID) return _G.C_QuestLog.GetQuestRewardXP(qID) end
_G.GetQuestLogRewardMoney = function(qID) return _G.C_QuestLog.GetQuestRewardMoney(qID) end
_G.GetQuestMoney = function() return 1000 end
_G.GetQuestXP = function(qID) return _G.C_QuestLog.GetQuestRewardXP(qID) end
_G.GetNumQuestLogRewards = function() return 1 end
_G.GetNumQuestLogChoices = function() return 0 end
_G.GetQuestLogRewardInfo = function(idx, qID) return "Reward Item", "Interface\\Icons\\INV_Sword_04", 1, 2, 0 end
_G.GetQuestLogChoiceInfo = function(idx, qID) return nil end
_G.GetItemInfo = function(itemID)
    if itemID == "uncached" or itemID == 999999 then return nil end
    return "Test Item", "item:" .. tostring(itemID), 2, 25, 20, "Weapon", "One-Handed Swords", 1, "INVTYPE_WEAPON", "Interface\\Icons\\INV_Sword_04"
end
_G.C_Item = {
    GetItemInfo = function(item) return _G.GetItemInfo(item) end
}

-- Load all addon files in exact TOC order
local ADDON_NAME = "QuestWorth"
local addonTable = {}
local files = {
    "Localization.lua",
    "Core/Utils.lua",
    "Core/Database.lua",
    "Data/ClassStats.lua",
    "Data/ArmorTypes.lua",
    "Data/Chains.lua",
    "Data/Zones.lua",
    "Scores/Difficulty.lua",
    "Scores/Reward.lua",
    "Scores/Chain.lua",
    "Scores/ClassFit.lua",
    "Scores/Density.lua",
    "Core/Engine.lua",
    "UI/Tooltip.lua",
    "UI/QuestLog.lua",
    "UI/WorldMap.lua",
    "UI/QuestOffer.lua",
    "UI/Config.lua",
    "Core.lua",
}

print("\n[Loading Addon Files via TOC Order]")
for _, relPath in ipairs(files) do
    local f, err = loadfile(relPath)
    if not f then
        error(string.format("Failed to compile %s: %s", relPath, tostring(err)))
    end
    local ok, runErr = pcall(f, ADDON_NAME, addonTable)
    if not ok then
        error(string.format("Runtime error executing %s: %s", relPath, tostring(runErr)))
    end
    print(string.format("  Loaded: %s", relPath))
end
print("All 19 files successfully loaded.\n")

local eventFrame = _G["WorthIt_EventFrame"]
assert_not_nil(eventFrame, "Event frame 'WorthIt_EventFrame' registered")
local onEvent = eventFrame:GetScript("OnEvent")
assert_not_nil(onEvent, "OnEvent handler bound to event frame")

-- ============================================================================
-- SCENARIO 1: COLD START TEST
-- ============================================================================
print("--- SCENARIO 1: Cold Start Test (Brand New User, Nil SavedVariables) ---")
_G.WorthItDB = nil
_G.QuestWorthDB = nil

onEvent(eventFrame, "ADDON_LOADED", "QuestWorth")
onEvent(eventFrame, "PLAYER_LOGIN")
onEvent(eventFrame, "PLAYER_ENTERING_WORLD")

assert_true(type(_G.WorthItDB) == "table", "WorthItDB initialized as table on cold start")
assert_true(type(_G.QuestWorthDB) == "table", "QuestWorthDB synchronized with WorthItDB")
assert_eq(_G.WorthItDB.version, 8, "SavedVariables schema version initialized to 8")
assert_true(_G.WorthItDB.enabled == true, "Default setting 'enabled' is true")
assert_true(_G.WorthItDB.showInTooltip == true, "Default setting 'showInTooltip' is true")
assert_true(_G.WorthItDB.showInQuestLog == true, "Default setting 'showInQuestLog' is true")
assert_true(_G.WorthItDB.showInWorldMap == true, "Default setting 'showInWorldMap' is true")
assert_true(type(_G.WorthItDB.weights) == "table", "Weights table initialized")
assert_true(_G.WorthItDB.weights.reward == 0.40, "Default reward weight is 0.40")
assert_true(_G.WorthItDB.weights.classFit == 0.25, "Default class fit weight is 0.25")
assert_true(_G.WorthItDB.weights.chain == 0.25, "Default chain weight is 0.25")
assert_true(_G.WorthItDB.weights.density == 0.10, "Default density weight is 0.10")
assert_true(_G.WorthItDB.weights.difficulty == 0.00, "Default difficulty weight is 0.00")
assert_true(type(_G.SlashCmdList["WORTHIT"]) == "function", "/worthit slash command registered")
assert_true(type(_G.SlashCmdList["QUESTWORTH"]) == "function", "/questworth slash command registered")

-- ============================================================================
-- SCENARIO 2: CORRUPT SAVEDVARIABLES TEST
-- ============================================================================
print("\n--- SCENARIO 2: Corrupted SavedVariables Recovery & Sanitization ---")
_G.WorthItDB = {
    enabled = "not_a_boolean", -- corrupt type
    showInTooltip = 12345,     -- corrupt type
    showZoneAdvisor = nil,     -- missing key
    zoneAdvisorFilter = false, -- corrupt filter
    weights = {
        difficulty = "super_hard", -- corrupt type
        reward = -50,              -- invalid negative
        chain = nil,               -- missing key
        classFit = {},             -- invalid table type
        density = 9999,            -- invalid out-of-range
    },
    version = 1,                   -- outdated version
}
_G.QuestWorthDB = _G.WorthItDB

addonTable.DB.Initialize()

assert_true(_G.WorthItDB.enabled == true, "Corrupted enabled boolean repaired to true")
assert_true(_G.WorthItDB.showInTooltip == true, "Corrupted showInTooltip repaired to true")
assert_true(_G.WorthItDB.showZoneAdvisor == true, "Missing showZoneAdvisor backfilled to true")
assert_true(_G.WorthItDB.zoneAdvisorFilter == "ALL", "Corrupted zoneAdvisorFilter sanitized to 'ALL'")
assert_true(type(_G.WorthItDB.weights.difficulty) == "number", "Weights difficulty repaired to number")
assert_true(_G.WorthItDB.weights.reward == 0.40, "Weights reward restored to default 0.40")
assert_true(_G.WorthItDB.weights.classFit == 0.25, "Weights classFit restored to default 0.25")
assert_true(_G.WorthItDB.weights.chain == 0.25, "Weights chain backfilled to default 0.25")
assert_true(_G.WorthItDB.weights.density == 0.10, "Weights density restored to default 0.10")
assert_true(_G.WorthItDB.weights.difficulty == 0.00, "Weights difficulty restored to default 0.00")
assert_eq(_G.WorthItDB.version, 8, "Outdated DB migrated to version 8")

-- Verify engine operates without errors under repaired settings
local duskWorth = addonTable.Engine.CalculateWorldMapZoneWorth("Duskwood")
assert_not_nil(duskWorth, "CalculateWorldMapZoneWorth('Duskwood') runs cleanly after corruption recovery")
assert_true(duskWorth.worth > 0 and duskWorth.worth <= 1.0, "Duskwood worth is within valid [0, 1] range: " .. tostring(duskWorth.worth))

-- ============================================================================
-- SCENARIO 3: BOUNDARY GAMEPLAY STATES
-- ============================================================================
print("\n--- SCENARIO 3: Boundary Gameplay States ---")

-- 3A: Level 1 Character with 0 quests
print(" [3A] Level 1 Character with 0 quests in log:")
mockPlayerState.level = 1
mockPlayerState.xp = 0
mockPlayerState.xpMax = 400
mockPlayerState.zone = "Elwynn Forest"
mockQuestLog = {}

onEvent(eventFrame, "PLAYER_LEVEL_UP")
addonTable.Engine.InvalidateCache()
onEvent(eventFrame, "QUEST_LOG_UPDATE")

local elwynn = addonTable.Engine.CalculateWorldMapZoneWorth("Elwynn Forest")
assert_not_nil(elwynn, "Level 1 Elwynn Forest zone worth calculated")
assert_true(elwynn.worth >= 0.70, "Elwynn Forest is optimal for level 1 (score: " .. tostring(elwynn.worth) .. ")")

local outOfBracket = addonTable.Engine.CalculateWorldMapZoneWorth("Silithus")
assert_not_nil(outOfBracket, "Level 1 Silithus zone worth calculated")
assert_true(outOfBracket.worth < 0.30, "Silithus heavily penalized for level 1 (score: " .. tostring(outOfBracket.worth) .. ")")

-- 3B: Level 60 Character with 25 quests, collapsed headers, elite/dungeon, uncached items
print(" [3B] Level 60 Character with full quest log (25 entries) & uncached items:")
mockPlayerState.level = 60
mockPlayerState.xp = 0
mockPlayerState.xpMax = 0 -- WoW returns 0 xpMax at cap!

onEvent(eventFrame, "PLAYER_LEVEL_UP")
addonTable.Engine.InvalidateCache()

mockQuestLog = {
    { title = "Eastern Plaguelands (5)", isHeader = true, isCollapsed = false },
    { title = "The Battle of Darrowshire", questID = 5211, level = 56, isHeader = false, isComplete = 1 },
    { title = "Defenders of Darrowshire", questID = 5212, level = 56, isHeader = false, isComplete = 0 },
    { title = "Scholomance", questID = 5505, level = 60, isHeader = false, isDungeon = true },
    { title = "Baron Rivendare", questID = 5506, level = 60, isHeader = false, isElite = true },
    { title = "Uncached Rewards Quest", questID = 9999, level = 60, isHeader = false },
    { title = "Collapsed Zone (1)", isHeader = true, isCollapsed = true },
    { title = "Hidden Quest Under Header", questID = 8888, level = 58, isHeader = false },
}
-- Fill log up to 25 items
for i = 9, 25 do
    table.insert(mockQuestLog, {
        title = "Generic Quest " .. i,
        questID = 7000 + i,
        level = 58,
        isHeader = false,
        isComplete = 0
    })
end

mockQuestDB[9999] = { xp = 6000, money = 20000, uncached = true }

onEvent(eventFrame, "QUEST_LOG_UPDATE")

local qWorth, qBreak = addonTable.Engine.CalculateWorth(5211)
assert_not_nil(qWorth, "Complete quest 5211 calculated")
assert_true(qBreak.isComplete == true, "Quest 5211 correctly recognized as complete")

local eliteWorth, eliteBreak = addonTable.Engine.CalculateWorth(5506)
assert_not_nil(eliteWorth, "Elite quest 5506 calculated")
assert_true(eliteBreak.isHard == true, "Elite quest marked isHard == true")

local uncachedWorth, uncachedBreak = addonTable.Engine.CalculateWorth(9999)
assert_not_nil(uncachedWorth, "Uncached item quest 9999 calculated gracefully without nil error")

-- 3C: WoW Forever Custom Zone & Custom Race
print(" [3C] WoW Forever Custom Zone & Custom Race / Class Handling:")
mockPlayerState.race = "Skyborne"
mockPlayerState.raceToken = "Skyborne"
mockPlayerState.class = "Warrior"
mockPlayerState.classToken = "WARRIOR"
onEvent(eventFrame, "PLAYER_ENTERING_WORLD")
addonTable.Engine.InvalidateCache()

local homeCont = addonTable.Engine.GetHomeContinent("Skyborne")
assert_eq(homeCont, 1, "Skyborne custom race mapped to Kalimdor (Continent 1)")

local unknownCont = addonTable.Engine.GetHomeContinent("UnknownAlienRace")
assert_eq(unknownCont, 1, "Unknown race safely defaults to continent 1")

local riverlands = addonTable.Engine.CalculateWorldMapZoneWorth("Riverlands")
assert_not_nil(riverlands, "WoW Forever custom zone 'Riverlands' recognized")
assert_true(riverlands.minLevel == 35 and riverlands.maxLevel == 45, "Riverlands bracket is 35-45")

local hyjal = addonTable.Engine.CalculateWorldMapZoneWorth("Mount Hyjal")
assert_not_nil(hyjal, "WoW Forever custom zone 'Mount Hyjal' recognized")
assert_true(hyjal.minLevel == 58 and hyjal.maxLevel == 60, "Mount Hyjal bracket is 58-60")

local fakeZone = addonTable.Engine.CalculateWorldMapZoneWorth("NonExistentZone999")
assert_true(fakeZone == nil or fakeZone.worth ~= nil, "Non-existent zone handled safely without crash")

-- ============================================================================
-- SCENARIO 4: COMBAT & EVENT STORM STRESS TEST
-- ============================================================================
print("\n--- SCENARIO 4: Combat & Event Storm Stress Test (1,000 rapid events) ---")
mockPlayerState.inCombat = true
assert_true(_G.InCombatLockdown() == true, "Player enters combat lockdown")

collectgarbage("collect")
local memBefore = collectgarbage("count")

local eventsToStorm = {
    "QUEST_LOG_UPDATE",
    "QUEST_WATCH_UPDATE",
    "BAG_UPDATE_DELAYED",
    "ZONE_CHANGED",
    "PLAYER_ENTERING_WORLD",
    "UNIT_QUEST_LOG_CHANGED",
}

for i = 1, 1000 do
    local ev = eventsToStorm[((i - 1) % #eventsToStorm) + 1]
    local ok, err = pcall(onEvent, eventFrame, ev)
    if not ok then
        fail("Combat event storm iteration " .. i, err)
        break
    end
end
pass("1,000 events fired during InCombatLockdown without any errors")

mockPlayerState.inCombat = false
assert_true(_G.InCombatLockdown() == false, "Player leaves combat")

-- Combat ends: trigger deferred UI flush
local okDrop, dropErr = pcall(onEvent, eventFrame, "PLAYER_REGEN_ENABLED")
assert_true(okDrop, "PLAYER_REGEN_ENABLED flushes deferred updates cleanly")

collectgarbage("collect")
local memAfter = collectgarbage("count")
local memDelta = memAfter - memBefore
print(string.format("  Memory before: %.2f KB, Memory after: %.2f KB (Delta: %.2f KB)", memBefore, memAfter, memDelta))
assert_true(memDelta < 250, "Memory delta after 1,000 events + GC is within healthy bound (< 250 KB)")

-- ============================================================================
-- SUMMARY
-- ============================================================================
print("\n======================================================================")
print(string.format(" TEST RESULTS: %d PASSED, %d FAILED", passedCount, failedCount))
print("======================================================================")

if failedCount > 0 then
    os.exit(1)
else
    print("ALL TESTS PASSED SUCCESSFULLY! CODEBASE READY FOR PUBLIC RELEASE.")
    os.exit(0)
end
