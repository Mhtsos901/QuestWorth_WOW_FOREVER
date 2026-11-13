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
            GetParent = function(self) return f end,
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
            GetStringWidth = function(self) return (#self.text or 10) * 7 end,
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
            GetTexture = function(self) return self.tex end,
            SetAtlas = function(self, a) self.atlas = a; self.tex = "Atlas:" .. tostring(a) end,
            GetAtlas = function(self) return self.atlas end,
            SetColorTexture = function(self, ...) end,
            SetAllPoints = function(self, ...) end,
            SetPoint = function(self, ...) end,
            SetSize = function(self, w, h) self.w = w; self.h = h end,
            SetHeight = function(self, h) self.h = h end,
            SetWidth = function(self, w) self.w = w end,
            SetAlpha = function(self, ...) end,
            SetTexCoord = function(self, ...) end,
            Show = function(self) self.shown = true end,
            Hide = function(self) self.shown = false end,
            IsShown = function(self) return self.shown ~= false end,
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

_G.QuestFrame = _G.CreateFrame("Frame", "QuestFrame")
_G.QuestFrameDetailPanel = _G.CreateFrame("Frame", "QuestFrameDetailPanel", _G.QuestFrame)
_G.QuestInfoTitleHeader = _G.QuestFrameDetailPanel:CreateFontString("QuestInfoTitleHeader")
_G.QuestDetailTitleText = _G.QuestFrameDetailPanel:CreateFontString("QuestDetailTitleText")

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
    GetBestMapForUnit = function(unit) return 1431 end, -- Duskwood
    GetMapInfo = function(mapID)
        return { mapID = mapID or 1431, name = "Duskwood", mapType = 3 }
    end
}

-- Quest mock database for tests
local mockQuestDB = {}
local mockQuestLog = {}

_G.C_QuestLog = {
    GetTitleForQuestID = function(qID)
        local q = mockQuestDB[qID] or mockQuestDB[tonumber(qID)]
        return q and q.title
    end,
    GetNumQuestLogEntries = function() return #mockQuestLog end,
    GetInfo = function(index) return mockQuestLog[index] end,
    IsOnQuest = function(qID)
        for _, q in ipairs(mockQuestLog) do
            if not q.isHeader and q.questID == qID then return true end
        end
        return false
    end,
    GetQuestRewardXP = function(qID)
        local q = mockQuestDB[qID] or mockQuestDB[tonumber(qID)]
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
    GetQuestObjectives = function(qID)
        local q = mockQuestDB[qID] or mockQuestDB[tonumber(qID)]
        return q and q.objectives
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

local currentOfferTitle = nil
local currentOfferQuestID = nil
local currentOfferXP = 0
local currentOfferMoney = 0
local currentOfferChoices = {}
local currentOfferRewards = {}

_G.GetQuestID = function() return currentOfferQuestID end
_G.GetTitleText = function() return currentOfferTitle or "" end
_G.GetObjectiveText = function()
    local q = mockQuestDB[currentOfferQuestID]
    return (q and q.objectiveText) or ""
end
_G.GetRewardXP = function() return currentOfferXP or 0 end
_G.GetRewardMoney = function() return currentOfferMoney or 0 end
_G.GetNumQuestChoices = function() return currentOfferChoices and #currentOfferChoices or 0 end
_G.GetNumQuestRewards = function() return currentOfferRewards and #currentOfferRewards or 0 end
_G.GetQuestItemLink = function(typ, idx)
    if typ == "choice" and currentOfferChoices then return currentOfferChoices[idx] end
    if typ == "reward" and currentOfferRewards then return currentOfferRewards[idx] end
    return nil
end
_G.GetItemInfo = function(itemID)
    if itemID == "uncached" or itemID == 999999 then return nil end
    if itemID == "item:40001" or itemID == 40001 then
        -- Level 40 Rare Plate Chest (classID = 4, subClassID = 4)
        return "Scarlet Plate Chest", "item:40001", 3, 45, 40, "Armor", "Plate", 1, "INVTYPE_CHEST", "Interface\\Icons\\INV_Chest_Plate04", 12500, 4, 4
    end
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
    "Data/Tips.lua",
    "Data/Zones.lua",
    "Data/ForeverData.lua",
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
print(string.format("All %d files successfully loaded.\n", #files))

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

-- 3D: Dungeon Detection & Advisor Dungeon Icon
print(" [3D] Classic & WoW Forever Dungeon Zone Detection & Icons:")
local deadmines = addonTable.Engine.CalculateWorldMapZoneWorth("The Deadmines")
assert_not_nil(deadmines, "The Deadmines dungeon recognized in database")
assert_true(deadmines.isDungeon == true, "The Deadmines has isDungeon == true")
assert_eq(deadmines.minLevel, 18, "Deadmines min level is 18")
assert_eq(deadmines.maxLevel, 23, "Deadmines max level is 23")

local wc = addonTable.Engine.CalculateWorldMapZoneWorth("Wailing Caverns")
assert_not_nil(wc, "Wailing Caverns dungeon recognized in database")
assert_true(wc.isDungeon == true, "Wailing Caverns has isDungeon == true")

local customDung = addonTable.Engine.CalculateWorldMapZoneWorth("Hall of Thanes")
assert_not_nil(customDung, "WoW Forever custom dungeon 'Hall of Thanes' recognized")
assert_true(customDung.isDungeon == true, "Hall of Thanes has isDungeon == true")

-- 3E: Cryptic & Item Sourcing Quest Tips
print(" [3E] Cryptic, Hidden Object & Item Sourcing Quest Tips:")
local valorPayoff = addonTable.Data.GetQuestPayoff(226, "The Valor Family")
assert_not_nil(valorPayoff, "Payoff retrieved for The Valor Family")
assert_not_nil(valorPayoff.tip, "The Valor Family has actionable tip")
assert_true(string.find(valorPayoff.tip, "Raven Hill Tome") ~= nil, "The Valor Family tip mentions Raven Hill Tome: " .. tostring(valorPayoff.tip))

local kabobPayoff = addonTable.Data.GetQuestPayoff(93, "Seasoned Wolf Kabobs")
assert_not_nil(kabobPayoff, "Payoff retrieved for Seasoned Wolf Kabobs")
assert_not_nil(kabobPayoff.tip, "Seasoned Wolf Kabobs has actionable tip")
assert_true(string.find(kabobPayoff.tip, "Lean Wolf Flank") ~= nil, "Seasoned Wolf Kabobs tip mentions Lean Wolf Flanks: " .. tostring(kabobPayoff.tip))

local starsTip = addonTable.Data.GetQuestTip(174, "Look to the Stars")
assert_not_nil(starsTip, "Look to the Stars tip found")
assert_true(string.find(starsTip, "Bronze Tube") ~= nil, "Look to the Stars tip mentions Bronze Tube: " .. tostring(starsTip))

local blanchyTip = addonTable.Data.GetQuestTip(151, "Poor Old Blanchy")
assert_not_nil(blanchyTip, "Poor Old Blanchy tip found")
assert_true(string.find(blanchyTip, "Oats") ~= nil, "Blanchy tip mentions Oats: " .. tostring(blanchyTip))

local cluckTip = addonTable.Data.GetQuestTip(106, "Cluck!")
assert_not_nil(cluckTip, "Cluck! chicken quest tip found")
assert_true(string.find(cluckTip, "Chicken Feed") ~= nil, "Cluck! tip mentions chicken feed: " .. tostring(cluckTip))

local itemTip = addonTable.Data.ObjectiveItemTips["soothing spices"]
assert_not_nil(itemTip, "Soothing Spices vendor tip indexed")
assert_true(string.find(itemTip, "Cooking Supplies") ~= nil, "Soothing Spices tip points to cooking vendors")

-- 3F: Logic Edge Cases, Zero-Difficulty Guarantee & Dungeon Guidance
print(" [3F] Deep Logic Audit: Zero-Difficulty Guarantee & Dungeon Advisor Guidance:")
local prevLvl = mockPlayerState.level

-- Test 1: Zero-Difficulty Guarantee (wD == 0.00 even after dynamic weight redistribution)
local noGearWorth, noGearBreak = addonTable.Engine.CalculateWorth(7001)
assert_not_nil(noGearWorth, "Standalone quest 7001 evaluated")
assert_eq(noGearBreak.wD, 0.00, "Difficulty weight remains strictly 0.00 after dynamic redistribution")
assert_true(noGearBreak.wR > 0.40, "Reward weight absorbed released weight (Reward weight: " .. tostring(noGearBreak.wR) .. ")")

-- Test 2: Dungeon status at level 16 (Upcoming Dungeon prequest guidance)
mockPlayerState.level = 16
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
local dm16 = addonTable.Engine.CalculateWorldMapZoneWorth("The Deadmines")
assert_not_nil(dm16, "The Deadmines evaluated for level 16")
assert_true(string.find(dm16.status, "Upcoming Dungeon") ~= nil, "Deadmines at level 16 indicates Upcoming Dungeon: " .. tostring(dm16.status))
assert_true(string.find(dm16.recommendation, "prequests") ~= nil, "Deadmines recommendation guides player to prepare prequests")

-- Test 3: Dungeon status at level 20 (Recommended 5-player instance)
mockPlayerState.level = 20
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
local dm20 = addonTable.Engine.CalculateWorldMapZoneWorth("The Deadmines")
assert_not_nil(dm20, "The Deadmines evaluated for level 20")
assert_true(dm20.status == "Recommended Dungeon" or dm20.status == "Ready for Dungeon!", "Deadmines at level 20 status is Recommended Dungeon: " .. tostring(dm20.status))
assert_true(string.find(dm20.recommendation, "5-player") ~= nil, "Deadmines at level 20 recommendation notes 5-player instance")

-- Test 4: High-XP Quest with 0 vendor copper achieves High XP (>= 0.85)
mockPlayerState.level = 25
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
mockQuestDB[8899] = { xp = 6000, money = 0, uncached = false }
local rScore, rDetails = addonTable.Scores.CalculateReward(8899)
assert_true(rScore >= 0.85, "High XP quest with 0 money achieves High XP score (>= 0.85): " .. tostring(rScore))

mockPlayerState.level = prevLvl
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()

-- 3G: Option A - Pre-Accept Quest Offer Score Accuracy & Parchment Hover Tooltip
print(" [3G] Pre-Accept Quest Offer Score Accuracy & Parchment Hover Tooltip:")
local preLvl = mockPlayerState.level
mockPlayerState.level = 28
mockPlayerState.class = "Warrior"
mockPlayerState.classToken = "WARRIOR"
mockPlayerState.zone = "Duskwood"
addonTable.Player.Update()

-- Existing quest in Duskwood zone (like in user screenshot where 2 quests are in zone)
table.insert(mockQuestLog, {
    title = "Duskwood",
    isHeader = true,
})
table.insert(mockQuestLog, {
    title = "Wolves at Our Heels",
    level = 26,
    isHeader = false,
    isComplete = false,
    questID = 7499,
})

-- Define an unaccepted quest 7500 with gear upgrade and high XP
mockQuestDB[7500] = { xp = 2450, money = 3500, uncached = false }

currentOfferQuestID = 7500
currentOfferTitle = "The Night Watch"
currentOfferXP = 2450
currentOfferMoney = 3500
currentOfferChoices = { "item:20001" }
currentOfferRewards = {}

QuestFrame:Show()
QuestFrameDetailPanel:Show()
QuestInfoTitleHeader:SetText("The Night Watch")

addonTable.UI.UpdateQuestOfferDialog()

local headerText = QuestInfoTitleHeader:GetText()
assert_true(string.find(headerText, "%[%d+%%%]") ~= nil, "Quest offer parchment title includes Worth meter badge")
assert_true(string.find(headerText, "The Night Watch", 1, true) ~= nil, "Quest offer parchment preserves clean quest title")
assert_true(string.find(headerText, addonTable.L["HOVER_TITLE_HINT"] or "Hover title", 1, true) ~= nil, "Quest offer parchment displays hover tooltip hint")

local hoverFrame = _G["WorthIt_QuestOfferTitleHover"]
assert_not_nil(hoverFrame, "Title hover frame created for quest offer dialog")
assert_true(hoverFrame:IsShown(), "Title hover frame is visible on parchment")
assert_eq(hoverFrame.questID, 7500, "Title hover frame bound to active offer questID 7500")

-- Simulate hovering over title
GameTooltip:ClearLines()
local enterScript = hoverFrame:GetScript("OnEnter")
assert_not_nil(enterScript, "Title hover frame has OnEnter handler")
enterScript(hoverFrame)

assert_true(GameTooltip:NumLines() > 0, "Mouseover on title populates GameTooltip")
local tooltipHasTitle = false
local tooltipHasBreakdown = false
local tooltipHasReward = false
local tooltipHasClassFit = false

for _, line in ipairs(GameTooltip.lines or {}) do
    local text = (line.left or "") .. " " .. (line.right or "")
    if string.find(text, "The Night Watch", 1, true) then tooltipHasTitle = true end
    if string.find(text, addonTable.L["BREAKDOWN"] or "Breakdown", 1, true) then tooltipHasBreakdown = true end
    if string.find(text, addonTable.L["REWARD"] or "Reward", 1, true) then tooltipHasReward = true end
    if string.find(text, addonTable.L["CLASS_FIT"] or "Class Fit", 1, true) then tooltipHasClassFit = true end
end

assert_true(tooltipHasTitle, "Hover tooltip displays quest title")
assert_true(tooltipHasBreakdown, "Hover tooltip displays 5-score breakdown section")
assert_true(tooltipHasReward, "Hover tooltip displays Reward Value line")
assert_true(tooltipHasClassFit, "Hover tooltip displays Class Fit line")

-- Verify pre-accept score matches post-accept score
local preAcceptWorth, preBreak = addonTable.Engine.CalculateWorth(7500)
assert_not_nil(preAcceptWorth, "Pre-accept worth score calculated")

-- Now simulate player accepting quest into Quest Log
table.insert(mockQuestLog, {
    title = "The Night Watch",
    level = 28,
    isHeader = false,
    isComplete = false,
    questID = 7500,
})
QuestFrame:Hide()
addonTable.Engine.InvalidateCache(7500)
addonTable.Scores.InvalidateRewardCache()
addonTable.Scores.InvalidateDensityCache()

local postAcceptWorth, postBreak = addonTable.Engine.CalculateWorth(7500)
assert_not_nil(postAcceptWorth, "Post-accept worth score calculated")
local prePct = math.floor(preAcceptWorth * 100 + 0.5)
local postPct = math.floor(postAcceptWorth * 100 + 0.5)
assert_eq(prePct, postPct, "Pre-accept Worth % matches post-accept Worth % (" .. prePct .. "% == " .. postPct .. "%)")

-- Clean up
table.remove(mockQuestLog, #mockQuestLog)
table.remove(mockQuestLog, #mockQuestLog)
table.remove(mockQuestLog, #mockQuestLog)
mockPlayerState.level = preLvl
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
addonTable.Scores.InvalidateDensityCache()

-- 3H: World Map Zone Banner Facelift & Advisor Toggle Symbol Fix
print(" [3H] World Map Zone Banner Facelift & Clean Toggle:")
WorldMapFrame:Show()
addonTable.UI.UpdateWorldMapBanner()
local banner = _G["WorthItWorldMapBanner"]
assert_not_nil(banner, "World map zone worth banner created")
assert_true(banner:IsShown(), "World map zone worth banner is visible")

local bText = banner.Text and banner.Text:GetText() or ""
assert_true(string.find(bText, "%[%d+%%%]") ~= nil, "Zone banner includes Worth score badge")
assert_true(string.find(bText, "Duskwood", 1, true) ~= nil, "Zone banner displays current zone name")
assert_true(string.find(bText, "%[Log:") == nil, "Zone banner omits cluttering Log quest count (only first part shown)")

-- Test toggle button text
addonTable.UI.ToggleZoneAdvisor(false)
local tBtn = _G["WorthItAdvisorToggleButton"]
assert_not_nil(tBtn, "Zone advisor toggle button exists")
local closedText = tBtn:GetText() or (tBtn.Text and tBtn.Text:GetText()) or ""
assert_true(string.find(closedText, "Zones %", 1, true) ~= nil, "Toggle button shows clean [Zones %] when closed")
assert_true(string.find(closedText, "[\128-\255]") == nil, "Toggle button contains zero broken non-ASCII symbols")

addonTable.UI.ToggleZoneAdvisor(true)
local openText = tBtn:GetText() or (tBtn.Text and tBtn.Text:GetText()) or ""
assert_true(string.find(openText, "< Zones", 1, true) ~= nil, "Toggle button shows clean [< Zones] when open")
assert_true(string.find(openText, "[\128-\255]") == nil, "Open toggle button contains zero broken non-ASCII symbols")

addonTable.UI.ToggleZoneAdvisor(false)

-- 3I: Talk-To / Courier / Breadcrumb Quest Non-Combat Logic & Mor'Ladim Archeus Chain Test
print(" [3I] Talk-To / Courier / Breadcrumb Quest Non-Combat Logic & Mor'Ladim Archeus Chain Test:")
local oldPlayerLvl = mockPlayerState.level
mockPlayerState.level = 32
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()

-- Setup Quest 227 ("The Weathered Grave") [Level 35 in Duskwood, player level 32 (delta +3)]
mockQuestDB[227] = {
    title = "The Weathered Grave",
    level = 35,
    xp = 721,
    money = 0,
    objectiveText = "Speak with Sirra Von'Indi in Darkshire.",
    objectives = {
        { text = "Speak with Sirra Von'Indi in Darkshire.", finished = false, numRequired = 1 }
    }
}

-- 1. Metadata & Objective detection
local isTalk = addonTable.Utils.IsTalkToQuest(227)
assert_true(isTalk == true, "Quest 227 recognized as Talk-To / Courier quest")

-- 2. Difficulty score: Non-combat guarantee (Safe, yellow, base 1.00, penalty 0.00, no skull)
local dScore, dBreak = addonTable.Scores.CalculateDifficulty(227)
assert_eq(dScore, 1.00, "Talk-To quest receives 1.00 Difficulty score despite delta +3")
assert_true(dBreak.isTalkTo == true, "Difficulty details marks isTalkTo == true")
assert_eq(dBreak.penalty, 0.00, "Talk-To quest incurs zero difficulty penalty")
assert_eq(dBreak.reason, "Talk-To", "Difficulty reason classified as 'Talk-To'")

-- 3. Reward score: Scaled against talk-to benchmark (721 XP achieves high reward score >= 0.85)
local rScore, rBreak = addonTable.Scores.CalculateReward(227)
assert_true(rScore >= 0.85, "Talk-To breadcrumb 721 XP achieves high reward score (>= 0.85): " .. tostring(rScore))

-- 4. Chain score: Recognized as Step 1 of 4 in Mor'Ladim / Archeus chain
local cScore, cBreak = addonTable.Scores.CalculateChain(227)
assert_true(cScore >= 0.70, "Chain starter in Mor'Ladim Archeus chain scores >= 0.70: " .. tostring(cScore))
assert_eq(cBreak.step, 1, "Chain step is 1")
assert_eq(cBreak.totalSteps, 4, "Total chain steps is 4")

-- 5. Overall Engine Worth: No orange/red damping, isHard == false, worth >= 0.70
local wScore, wBreak = addonTable.Engine.CalculateWorth(227)
assert_true(wBreak.isHard == false, "Talk-To quest is strictly NOT hard (isHard == false, no skull)")
assert_true(wBreak.isBankable == false, "Talk-To quest is NOT bankable (ready to do now)")
assert_true(wScore >= 0.70, "Overall Worth % is high leveling tier (>= 0.70): " .. tostring(wScore))

-- 6. Dynamic Talk-To Quest purely from objective text (custom unlisted quest 9901)
mockQuestDB[9901] = {
    title = "Urgent Delivery to Lakeshire",
    level = 38,
    xp = 650,
    money = 0,
    objectiveText = "Deliver the Sealed Letter to Magistrate Solomon in Lakeshire.",
    objectives = {
        { text = "Deliver the Sealed Letter to Magistrate Solomon in Lakeshire.", finished = false, numRequired = 1 }
    }
}
local isDynTalk = addonTable.Utils.IsTalkToQuest(9901)
assert_true(isDynTalk == true, "Unlisted quest 9901 dynamically detected as Talk-To from objective text")
local dynDScore, dynDBreak = addonTable.Scores.CalculateDifficulty(9901)
assert_eq(dynDScore, 1.00, "Dynamic Talk-To quest receives 1.00 Difficulty score despite delta +6")
assert_true(dynDBreak.isTalkTo == true, "Dynamic Talk-To details marks isTalkTo == true")

-- 7. Tooltip Suitability & Breakdown verification
currentOfferQuestID = 227
currentOfferTitle = "The Weathered Grave"
currentOfferXP = 721
currentOfferMoney = 0
GameTooltip:ClearLines()
addonTable.UI.ShowQuestTooltip(GameTooltip, 227)

local suitLine = nil
local diffLine = nil
local highlightLine = nil
for _, line in ipairs(GameTooltip.lines or {}) do
    local text = (line.left or "") .. " " .. (line.right or "")
    if string.find(text, addonTable.L["SUITABILITY"] or "Suitability", 1, true) then suitLine = text end
    if string.find(text, addonTable.L["DIFFICULTY"] or "Difficulty", 1, true) then diffLine = text end
    if string.find(text, addonTable.L["HIGHLIGHTS"] or "Highlights", 1, true) then highlightLine = text end
end

assert_not_nil(suitLine, "Tooltip contains Suitability line")
assert_true(string.find(suitLine, "Talk to NPC", 1, true) ~= nil, "Suitability guides player: " .. tostring(suitLine))
assert_true(string.find(suitLine, "Bring Group") == nil, "Suitability does NOT tell player to bring group")

assert_not_nil(diffLine, "Tooltip contains Difficulty breakdown line")
assert_true(string.find(diffLine, "Safe", 1, true) ~= nil, "Difficulty breakdown shows Safe: " .. tostring(diffLine))
assert_true(string.find(diffLine, "Hard") == nil, "Difficulty breakdown does NOT say Hard")

assert_not_nil(highlightLine, "Tooltip contains Highlights line")
assert_true(string.find(highlightLine, "Talk to NPC", 1, true) ~= nil, "Highlights includes Talk to NPC")
assert_true(string.find(highlightLine, "Challenging") == nil, "Highlights does NOT say Challenging")

-- Restore state
mockPlayerState.level = oldPlayerLvl
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()

-- 3J: WoW Forever Custom Quests, Dungeons, Hidden Items & Chains Coverage
print(" [3J] WoW Forever Expansion Quest Coverage, Hidden Items & Dungeon Chains:")

-- 1. Custom Forever Dungeons in Data.Zones
local wetlandsExcav = addonTable.Data.Zones["Excavation Site: Wetlands"]
assert_not_nil(wetlandsExcav, "Excavation Site: Wetlands registered in Data.Zones")
assert_true(wetlandsExcav.isDungeon == true, "Excavation Site: Wetlands is marked as dungeon")
assert_eq(wetlandsExcav.min, 26, "Excavation Site: Wetlands min level is 26")
assert_eq(wetlandsExcav.max, 33, "Excavation Site: Wetlands max level is 33")

local drownedCity = addonTable.Data.Zones["The Drowned City"]
assert_not_nil(drownedCity, "The Drowned City registered in Data.Zones")
assert_true(drownedCity.isDungeon == true, "The Drowned City is marked as dungeon")

local dalaranCity = addonTable.Data.Zones["City of Dalaran"]
assert_not_nil(dalaranCity, "City of Dalaran registered in Data.Zones")
assert_true(dalaranCity.isDungeon == true, "City of Dalaran is marked as dungeon")

local kroldok = addonTable.Data.Zones["Krol'dok Stronghold"]
assert_not_nil(kroldok, "Krol'dok Stronghold registered in Data.Zones")
assert_true(kroldok.isDungeon == true, "Krol'dok Stronghold is marked as dungeon")

-- 2. Custom Forever Chains in Data.ChainIndex & Scores.CalculateChain
local q92753Chain = addonTable.Data.ChainIndex[92753]
assert_not_nil(q92753Chain, "Deadmines Toxic Soil finale (92753) indexed in ChainIndex")
assert_true(q92753Chain.isCap == true, "92753 is finale cap of Toxic Soil chain")
local cScore92753 = addonTable.Scores.CalculateChain(92753)
assert_eq(cScore92753, 1.00, "92753 Toxic Soil finale achieves 1.00 chain score")

local q96393Chain = addonTable.Data.ChainIndex[96393]
assert_not_nil(q96393Chain, "Hall of Thanes Old Ironforge Incursion (96393) indexed in ChainIndex")
assert_true(q96393Chain.totalSteps >= 2, "Hall of Thanes Incursion has multi-step prerequisites")

local q95140Chain = addonTable.Data.ChainIndex[95140]
assert_not_nil(q95140Chain, "Horde Paladin Wolfsbane chain (95140) indexed in ChainIndex")
assert_true(q95140Chain.isCap == true, "95140 is finale of Wolfsbane chain")

-- 3. Custom Secret Item Drops in Data.SecretQuestStarters
local titanRelic = addonTable.Data.SecretQuestStarters[270866]
assert_not_nil(titanRelic, "Titan Relic (270866) registered as secret quest starter")
assert_true(titanRelic.questID == 95664 or titanRelic.questID == 95810, "Titan Relic starts quest 95664 (Horde) or 95810 (Alliance)")

local smallScroll = addonTable.Data.SecretQuestStarters[17008]
assert_not_nil(smallScroll, "Small Scroll (17008) registered as secret quest starter")
assert_eq(smallScroll.questID, 6522, "Small Scroll starts quest 6522")

-- 4. Custom Quest Payoffs in Data.QuestPayoffs
local payoff96395 = addonTable.Data.QuestPayoffs[96395]
assert_not_nil(payoff96395, "Hall of Thanes An Ancient Grudge (96395) has payoff data")
assert_true(string.find(payoff96395.reward or "", "Catacomb Cloak", 1, true) ~= nil, "Payoff lists Catacomb Cloak reward")

local payoff95791 = addonTable.Data.QuestPayoffs[95791]
assert_not_nil(payoff95791, "The Drowned City Saltseer Captain (95791) has payoff data")
assert_true(string.find(payoff95791.reward or "", "Mutinous Cuffs", 1, true) ~= nil, "Payoff lists Mutinous Cuffs reward")

-- 5. Custom Quest Tips in Data.QuestTips
local tip96393 = addonTable.Data.QuestTips[96393]
assert_not_nil(tip96393, "Hall of Thanes quest 96393 has actionable tip")
assert_true(string.find(tip96393, "Dark Iron Map", 1, true) ~= nil, "Tip mentions Dark Iron Map drop")

local tip92753 = addonTable.Data.QuestTips[92753]
assert_not_nil(tip92753, "Deadmines Toxic Soil quest 92753 has actionable tip")

-- 3K: Deep Logic Audit Fixes Verification
print(" [3K] Deep Logic Audit Fixes Verification:")

-- 1. Deterministic ChainIndex Priority (longest chain wins over short prerequisite prefix)
local q5515Chain = addonTable.Data.ChainIndex[5515]
assert_not_nil(q5515Chain, "Quest 5515 indexed in ChainIndex")
assert_eq(q5515Chain.totalSteps, 9, "Quest 5515 retains full 9-step Ras Frostwhisper chain instead of 2-step prefix")
assert_true(q5515Chain.isCap == false, "Quest 5515 is step 2/9 (not incorrectly marked as Chain Finale)")

local q166Chain = addonTable.Data.ChainIndex[166]
assert_not_nil(q166Chain, "Quest 166 indexed in ChainIndex")
assert_eq(q166Chain.step, 7, "Defias Brotherhood Finale (166) is step 7")
assert_eq(q166Chain.totalSteps, 7, "Defias Brotherhood chain is 7 steps")
assert_true(q166Chain.isCap == true, "Quest 166 is Defias Brotherhood Finale")
assert_true(addonTable.Utils.IsTalkToQuest(65) == true, "Defias Brotherhood step 1 (65) is recognized as Talk-To")

-- 2. Unaccepted quest without initial objective text does NOT cache false in _talkToCache
mockQuestDB[9955] = {
    title = "Urgent Message to Stormwind",
    level = 30,
    xp = 600,
    money = 0,
    objectives = nil,
    objectiveText = nil,
}
assert_true(addonTable.Utils.IsTalkToQuest(9955) == false, "Quest 9955 initially false when no objective text available")
-- Now player opens QuestFrame and objective text appears
mockQuestDB[9955].objectiveText = "Speak with Bolvar Fordragon in Stormwind Keep."
currentOfferQuestID = 9955
currentOfferTitle = "Urgent Message to Stormwind"
QuestFrame:Show()
assert_true(addonTable.Utils.IsTalkToQuest(9955) == true, "Quest 9955 becomes IsTalkToQuest == true once QuestFrame exposes objective text (cache was not poisoned)")
QuestFrame:Hide()
currentOfferQuestID = nil
currentOfferTitle = nil

-- 3. Level 38 Warrior evaluating Level 40 Plate quest reward gets Gear Upgrade instead of 0.05 Unusable
local savedLvl3K = mockPlayerState.level
local savedClass3K = mockPlayerState.class
local savedToken3K = mockPlayerState.classToken
mockPlayerState.level = 38
mockPlayerState.class = "Warrior"
mockPlayerState.classToken = "WARRIOR"
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
addonTable.ClearSafeGetItemInfoCache()

mockQuestDB[9960] = { title = "Plate Test Quest", level = 40, xp = 3200, money = 0 }
currentOfferQuestID = 9960
currentOfferTitle = "Plate Test Quest"
currentOfferChoices = { "item:40001" }
currentOfferRewards = {}
QuestFrame:Show()
local fit38 = addonTable.Scores.CalculateClassFit(9960)
assert_true(fit38 >= 0.75, "Level 38 Warrior evaluating Level 40 Plate reward scores >= 0.75 (got " .. tostring(fit38) .. ")")
QuestFrame:Hide()
currentOfferQuestID = nil
currentOfferTitle = nil
currentOfferChoices = {}

mockPlayerState.level = savedLvl3K
mockPlayerState.class = savedClass3K
mockPlayerState.classToken = savedToken3K
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()

-- 4. Forever secret item starter linked into Data.ItemQuestMap
assert_eq(addonTable.Data.ItemQuestMap[270866], 95810, "Titan Relic (270866) linked in Data.ItemQuestMap")

-- 5. Tooltip Highlights omits duplicate raw 'Talk-To' when 'Talk to NPC' is shown
mockPlayerState.level = 32
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
GameTooltip:ClearLines()
addonTable.UI.ShowQuestTooltip(GameTooltip, 227)
local hl227 = nil
for _, line in ipairs(GameTooltip.lines or {}) do
    local text = (line.left or "") .. " " .. (line.right or "")
    if string.find(text, addonTable.L["HIGHLIGHTS"] or "Highlights", 1, true) then hl227 = text end
end
assert_not_nil(hl227, "Tooltip for 227 contains Highlights line")
assert_true(string.find(hl227, "Talk to NPC", 1, true) ~= nil, "Highlights for 227 includes Talk to NPC")
assert_true(string.find(hl227, "Talk-To", 1, true) == nil, "Highlights for 227 does NOT duplicate raw 'Talk-To'")
mockPlayerState.level = savedLvl3K
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()

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
