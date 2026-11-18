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

-- CVars mock
local mockCVars = {
    questPOI = "0",
    Outline = "0",
    OutlineEngineMode = "0",
    graphicsOutlineMode = "0",
    SoftTargetInteract = "1",
    SoftTargetIconGameObject = "0",
    SoftTargetIconEnemy = "0",
    SoftTargetEnemy = "0",
    SoftTargetFriend = "0",
}
_G.GetCVar = function(name) return mockCVars[name] end
_G.SetCVar = function(name, val) mockCVars[name] = tostring(val) end
_G.C_CVar = {
    GetCVar = _G.GetCVar,
    SetCVar = _G.SetCVar,
}

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
    function f:Hide() self.shown = false; self.owner = nil end
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
            SetVertexColor = function(self, ...) end,
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
    function f:GetOwner() return self.owner end
    function f:ClearLines()
        if self.name and self.lines then
            for idx = 1, #self.lines do
                if _G[self.name .. "TextLeft" .. idx] then
                    _G[self.name .. "TextLeft" .. idx]:SetText("")
                end
            end
        end
        self.lines = {}
    end
    function f:AddLine(text, r, g, b)
        self.lines = self.lines or {}
        table.insert(self.lines, {left = text, r = r, g = g, b = b})
        if self.name then
            local key = self.name .. "TextLeft" .. #self.lines
            if not _G[key] then _G[key] = self:CreateFontString(key) end
            _G[key]:SetText(text)
        end
    end
    function f:AddDoubleLine(l, r, lr, lg, lb, rr, rg, rb)
        self.lines = self.lines or {}
        table.insert(self.lines, {left = l, right = r})
        if self.name then
            local key = self.name .. "TextLeft" .. #self.lines
            if not _G[key] then _G[key] = self:CreateFontString(key) end
            _G[key]:SetText(l)
        end
    end
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
_G.GameTooltip.GetUnit = function(self) return self.mockUnit end
_G.GameTooltip.GetItem = function(self) return self.mockItemName, self.mockItemLink end
_G.GameTooltip.GetSpell = function(self) return self.mockSpellName end
_G.GameTooltip.SetQuestItem = function(self, kind, index) self:ClearLines() end
_G.GameTooltip.SetQuestLogItem = function(self, kind, index, qid) self:ClearLines() end
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
assert_true(_G.WorthItDB.highlightQuestObjects == nil, "Removed setting 'highlightQuestObjects' is not initialized")
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
    highlightQuestObjects = true, -- legacy removed option
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
assert_true(_G.WorthItDB.highlightQuestObjects == nil, "Legacy 'highlightQuestObjects' removed by DB sanitization")
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
;(function()
    local valorPayoff = addonTable.Data.GetQuestPayoff(nil, "The Valor Family")
    assert_not_nil(valorPayoff, "Payoff retrieved for The Valor Family")
    assert_not_nil(valorPayoff.tip, "The Valor Family has actionable tip")
    assert_true(string.find(valorPayoff.tip, "Raven Hill Tome") ~= nil, "The Valor Family tip mentions Raven Hill Tome: " .. tostring(valorPayoff.tip))

    local morladimPayoff = addonTable.Data.GetQuestPayoff(228, "Mor'Ladim")
    assert_not_nil(morladimPayoff, "Payoff retrieved for Mor'Ladim (228)")
    assert_true(morladimPayoff.isTalkTo ~= true, "Mor'Ladim (228) is not misflagged as Talk-To")

    local kabobPayoff = addonTable.Data.GetQuestPayoff(90, "Seasoned Wolf Kabobs")
    assert_not_nil(kabobPayoff, "Payoff retrieved for Seasoned Wolf Kabobs (90)")
    assert_not_nil(kabobPayoff.tip, "Seasoned Wolf Kabobs has actionable tip")
    assert_true(string.find(kabobPayoff.tip, "Lean Wolf Flank") ~= nil, "Seasoned Wolf Kabobs tip mentions Lean Wolf Flanks: " .. tostring(kabobPayoff.tip))

    local crabPayoff = addonTable.Data.GetQuestPayoff(93, "Dusky Crab Cakes")
    assert_not_nil(crabPayoff, "Payoff retrieved for Dusky Crab Cakes (93)")
    assert_not_nil(crabPayoff.tip, "Dusky Crab Cakes has actionable tip")
    assert_true(string.find(crabPayoff.tip, "Gooey Spider Legs") ~= nil, "Dusky Crab Cakes tip mentions Gooey Spider Legs: " .. tostring(crabPayoff.tip))

    local starsTip = addonTable.Data.GetQuestTip(174, "Look to the Stars")
    assert_not_nil(starsTip, "Look to the Stars tip found")
    assert_true(string.find(starsTip, "Bronze Tube") ~= nil, "Look to the Stars tip mentions Bronze Tube: " .. tostring(starsTip))

    local blanchyTip = addonTable.Data.GetQuestTip(151, "Poor Old Blanchy")
    assert_not_nil(blanchyTip, "Poor Old Blanchy tip found")
    assert_true(string.find(blanchyTip, "Oats") ~= nil, "Blanchy tip mentions Oats: " .. tostring(blanchyTip))

    local cluckTip = addonTable.Data.GetQuestTip(3861, "CLUCK!")
    assert_not_nil(cluckTip, "CLUCK! (3861) chicken quest tip found")
    assert_true(string.find(cluckTip, "Chicken Feed") ~= nil, "CLUCK! tip mentions chicken feed: " .. tostring(cluckTip))

    local loversTip = addonTable.Data.GetQuestTip(106, "Young Lovers")
    assert_not_nil(loversTip, "Young Lovers (106) tip found")
    assert_true(string.find(loversTip, "Maybell") ~= nil or string.find(loversTip, "Tommy Joe") ~= nil, "Young Lovers tip mentions Maybell/Tommy Joe: " .. tostring(loversTip))

    local itemTip = addonTable.Data.ObjectiveItemTips["soothing spices"]
    assert_not_nil(itemTip, "Soothing Spices vendor tip indexed")
    assert_true(string.find(itemTip, "Cooking Supplies") ~= nil, "Soothing Spices tip points to cooking vendors")
end)()

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

-- 4. Chain score: Recognized as Step 2 of 5 in Mor'Ladim / Archeus chain
local cScore, cBreak = addonTable.Scores.CalculateChain(227)
assert_true(cScore >= 0.70, "Chain starter in Mor'Ladim Archeus chain scores >= 0.70: " .. tostring(cScore))
assert_eq(cBreak.step, 2, "Chain step is 2")
assert_eq(cBreak.totalSteps, 5, "Total chain steps is 5")

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

-- 3L: Zone Advisor Differentiation, Active Quest Synergy & Breakdown Verification
print(" [3L] Zone Advisor Differentiation, Active Quest Synergy & Breakdown Verification:")
local savedLvl3L = mockPlayerState.level
local savedRace3L = mockPlayerState.race
local savedRaceToken3L = mockPlayerState.raceToken
local savedFaction3L = mockPlayerState.faction
local savedClass3L = mockPlayerState.class
local savedClassToken3L = mockPlayerState.classToken
local savedLog3L = mockQuestLog

mockPlayerState.level = 32
mockPlayerState.race = "Human"
mockPlayerState.raceToken = "Human"
mockPlayerState.faction = "Alliance"
mockPlayerState.class = "Warrior"
mockPlayerState.classToken = "WARRIOR"
mockQuestLog = {}
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
addonTable.Engine.WorldMapZoneCache = {}
addonTable.Scores.InvalidateDensityCache()

local stv32 = addonTable.Engine.CalculateWorldMapZoneWorth("Stranglethorn Vale")
local arathi32 = addonTable.Engine.CalculateWorldMapZoneWorth("Arathi Highlands")
local needles32 = addonTable.Engine.CalculateWorldMapZoneWorth("Thousand Needles")
local desolace32 = addonTable.Engine.CalculateWorldMapZoneWorth("Desolace")
local alterac32 = addonTable.Engine.CalculateWorldMapZoneWorth("Alterac Mountains")

assert_not_nil(stv32, "Stranglethorn Vale evaluated for lvl 32")
assert_not_nil(arathi32, "Arathi Highlands evaluated for lvl 32")
assert_not_nil(needles32, "Thousand Needles evaluated for lvl 32")
assert_not_nil(desolace32, "Desolace evaluated for lvl 32")
assert_not_nil(alterac32, "Alterac Mountains evaluated for lvl 32")

local allTieAt100 = (stv32.worth >= 0.995 and arathi32.worth >= 0.995 and needles32.worth >= 0.995 and desolace32.worth >= 0.995 and alterac32.worth >= 0.995)
assert_true(not allTieAt100, string.format("Zones do NOT flat-tie at 100%% (STV=%.0f%%, Arathi=%.0f%%, Needles=%.0f%%, Desolace=%.0f%%, Alterac=%.0f%%)",
    stv32.worth * 100, arathi32.worth * 100, needles32.worth * 100, desolace32.worth * 100, alterac32.worth * 100))
assert_true(stv32.worth > alterac32.worth, "Rich Stranglethorn Vale scores strictly higher than sparse Alterac Mountains")
assert_true(arathi32.worth > alterac32.worth, "Standard Arathi Highlands scores strictly higher than sparse Alterac Mountains")
assert_not_nil(stv32.shortReason, "Zone result provides concise 1-line shortReason")
assert_not_nil(stv32.hubName, "Zone result provides faction-specific hubName")
assert_eq(stv32.densityLabel, "Very High", "Stranglethorn Vale density tier is Very High")
assert_not_nil(stv32.zoneSummary, "Zone result provides curated zoneSummary")

-- Zone Advisor does NOT count quests already picked up in the Quest Log
mockQuestLog = {
    { title = "Stranglethorn Vale (2)", isHeader = true, isCollapsed = false },
    { title = "Welcome to the Jungle", questID = 583, level = 30, isHeader = false, isComplete = 1 },
    { title = "Raptor Mastery", questID = 194, level = 34, isHeader = false, isComplete = 0 },
}
mockQuestDB[583] = { title = "Welcome to the Jungle", level = 30, xp = 1200, money = 0 }
mockQuestDB[194] = { title = "Raptor Mastery", level = 34, xp = 2550, money = 0 }
addonTable.Scores.InvalidateDensityCache()
addonTable.Engine.InvalidateCache()
addonTable.Engine.WorldMapZoneCache = {}

local stv32WithQuests = addonTable.Engine.CalculateWorldMapZoneWorth("Stranglethorn Vale")
assert_eq(stv32WithQuests.worth, stv32.worth, "Zone Worth is purely efficiency-based and independent of quests already in log")
assert_eq(stv32WithQuests.activeCount, 0, "activeCount is 0 in Zone Advisor evaluation")
assert_true(not string.find(stv32WithQuests.shortReason or "", "in Log"), "shortReason never displays 'in Log'")

-- Class-Aware Dungeon Loot + XP Evaluation vs World Questing
mockPlayerState.level = 34
mockPlayerState.class = "Rogue"
mockPlayerState.classToken = "ROGUE"
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
addonTable.Engine.WorldMapZoneCache = {}
local gnomeRogue = addonTable.Engine.CalculateWorldMapZoneWorth("Gnomeregan")
assert_not_nil(gnomeRogue, "Gnomeregan evaluated for Level 34 Rogue")
assert_true(string.find(gnomeRogue.dungeonLoot or "", "Triprunner Dungarees") ~= nil, "Gnomeregan highlights BiS Triprunner Dungarees for Rogue")

mockPlayerState.class = "Warrior"
mockPlayerState.classToken = "WARRIOR"
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
addonTable.Engine.WorldMapZoneCache = {}
local gnomeWarrior = addonTable.Engine.CalculateWorldMapZoneWorth("Gnomeregan")
assert_true(gnomeRogue.worth > gnomeWarrior.worth, string.format("Gnomeregan scores higher for Rogue (%.0f%%) than Warrior (%.0f%%) due to BiS Agi legs", gnomeRogue.worth * 100, gnomeWarrior.worth * 100))

mockPlayerState.level = 36
mockPlayerState.class = "Rogue"
mockPlayerState.classToken = "ROGUE"
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
addonTable.Engine.WorldMapZoneCache = {}
local drowned36 = addonTable.Engine.CalculateWorldMapZoneWorth("The Drowned City")
local sm36 = addonTable.Engine.CalculateWorldMapZoneWorth("Scarlet Monastery")
local rfk36 = addonTable.Engine.CalculateWorldMapZoneWorth("Razorfen Kraul")
local rfd36 = addonTable.Engine.CalculateWorldMapZoneWorth("Razorfen Downs")
assert_true(drowned36.worth >= 0.85, "The Drowned City is highly recommended at Lvl 36 (score: " .. tostring(drowned36.worth) .. ")")
assert_true(sm36.worth >= 0.85, "Scarlet Monastery is highly recommended at Lvl 36 (score: " .. tostring(sm36.worth) .. ")")
assert_true(rfk36.worth < 0.70, "Razorfen Kraul at Lvl 36 (past 30-35 sweet spot) scores < 70%: " .. tostring(rfk36.worth))
assert_true(rfd36.worth < 0.70, "Razorfen Downs at Lvl 36 (upcoming 37+) scores < 70%: " .. tostring(rfd36.worth))
assert_not_nil(drowned36.vsWorldQuesting, "Dungeon evaluation includes vsWorldQuesting comparison")

-- Verify Zone Advisor hides < 70% dungeons in 'ALL' view and shows them in 'DUNGEONS' view
if WorldMapFrame and WorldMapFrame.Show then WorldMapFrame:Show() end
addonTable.UI.ToggleZoneAdvisor(true)
addonTable.db.zoneAdvisorFilter = "ALL"
addonTable.UI.UpdateZoneAdvisor()
local foundLowDungInAll = false
for i = 1, 30 do
    local r = _G["WorthItAdvisorRow" .. i]
    if r and r:IsShown() and r.isDungeon and r.data and r.data.worth < 0.70 then
        foundLowDungInAll = true
    end
end
assert_true(not foundLowDungInAll, "Zone Advisor 'ALL' filter hides dungeons with Worth < 70%")

addonTable.db.zoneAdvisorFilter = "DUNGEONS"
addonTable.UI.UpdateZoneAdvisor()
local foundLowDungInDungeonsTab = false
for i = 1, 30 do
    local r = _G["WorthItAdvisorRow" .. i]
    if r and r:IsShown() and r.isDungeon and r.data and r.data.worth < 0.70 then
        foundLowDungInDungeonsTab = true
    end
end
assert_true(foundLowDungInDungeonsTab, "Zone Advisor 'DUNGEONS' filter displays < 70% dungeons for inspection")
addonTable.db.zoneAdvisorFilter = "ALL"
addonTable.UI.UpdateZoneAdvisor()

-- Verify Dungeon Completed button state, persistence, filtering, sorting, tooltip, and unmark toggle
do
local function findAdvisorRow(targetName, expectDungeonFlag)
    for r = 1, 100 do
        local row = _G["WorthItAdvisorRow" .. r]
        if not row or not row:IsShown() then break end
        if targetName and row.data and row.data.zoneName == targetName then
            return row
        end
        if not targetName and expectDungeonFlag ~= nil and (row.isDungeon == expectDungeonFlag) then
            return row
        end
    end
    return nil
end

assert_true(not addonTable.DB.IsDungeonCompleted("The Drowned City"), "Dungeon starts uncompleted")
local regularRow = findAdvisorRow(nil, false)
assert_not_nil(regularRow, "Zone Advisor 'ALL' view shows regular zone rows")
assert_true(not regularRow.DoneBtn:IsShown(), "Regular zone row hides DoneBtn")

local allDungRow = findAdvisorRow(nil, true)
assert_not_nil(allDungRow, "Zone Advisor 'ALL' view shows at least one recommended dungeon row")
assert_true(allDungRow.DoneBtn and allDungRow.DoneBtn:IsShown(), "Recommended dungeon row shows DoneBtn")
assert_true(not allDungRow.DoneBtn.Check:IsShown(), "Uncompleted dungeon DoneBtn check starts hidden")

local clickedDungName = allDungRow.DoneBtn.zoneName
allDungRow.DoneBtn:GetScript("OnClick")(allDungRow.DoneBtn)
assert_true(addonTable.DB.IsDungeonCompleted(clickedDungName), "Clicking DoneBtn marks dungeon completed in SavedVariables")
assert_true(addonTable.DB.IsDungeonCompleted(clickedDungName:lower():gsub("^the%s+", "")), "IsDungeonCompleted normalizes case and leading 'The '")

local evalCompleted = addonTable.Engine.CalculateWorldMapZoneWorth(clickedDungName)
assert_true(evalCompleted and evalCompleted.isCompletedDungeon == true, "Engine flags completed dungeon evaluation")
assert_eq(evalCompleted.status, "Completed Dungeon", "Completed dungeon sets Completed status")
assert_true(not evalCompleted.isLowValue, "Completed dungeon is not flagged as Low Value")

assert_true(findAdvisorRow(clickedDungName, nil) == nil, "Completed dungeon is hidden from 'ALL' view")

addonTable.db.zoneAdvisorFilter = "DUNGEONS"
addonTable.UI.UpdateZoneAdvisor()
local completedDungRow = findAdvisorRow(clickedDungName, nil)
assert_not_nil(completedDungRow, "Completed dungeon remains visible in 'DUNGEONS' view so user can unmark it")
assert_true(completedDungRow.DoneBtn:IsShown() and completedDungRow.DoneBtn.Check:IsShown(), "Completed dungeon DoneBtn check texture is visible in 'DUNGEONS' view")
assert_true(completedDungRow.Badge:GetText():find("Done") ~= nil, "Completed dungeon badge shows [Done]")

-- Verify tooltip displays completion info
completedDungRow:GetScript("OnEnter")(completedDungRow)
local foundCompletedTooltipLine = false
for _, ln in ipairs(GameTooltip.lines or {}) do
    if ln.left and ln.left:find("Completion:") and ln.right and ln.right:find("Completed by Player") then
        foundCompletedTooltipLine = true
    end
end
assert_true(foundCompletedTooltipLine, "Completed dungeon tooltip displays completion status")
GameTooltip:Hide()

-- Verify completed dungeon sorts after incomplete dungeons in 'DUNGEONS' view
local seenCompleted = false
local sortedDoneAfterIncomplete = true
for r = 1, 100 do
    local row = _G["WorthItAdvisorRow" .. r]
    if not row or not row:IsShown() then break end
    if row.data and row.data.isCompletedDungeon then
        seenCompleted = true
    elseif seenCompleted then
        sortedDoneAfterIncomplete = false
    end
end
assert_true(sortedDoneAfterIncomplete, "Completed dungeons sort after incomplete dungeons in 'DUNGEONS' view")

-- Unmark via clicking DoneBtn again and verify it returns to 'ALL' view
completedDungRow.DoneBtn:GetScript("OnClick")(completedDungRow.DoneBtn)
assert_true(not addonTable.DB.IsDungeonCompleted(clickedDungName), "Second click on DoneBtn unmarks completed dungeon")
addonTable.db.zoneAdvisorFilter = "ALL"
addonTable.UI.UpdateZoneAdvisor()
local restoredRow = findAdvisorRow(clickedDungName, nil)
assert_not_nil(restoredRow, "Unmarked recommended dungeon reappears in 'ALL' view")
assert_true(not restoredRow.DoneBtn.Check:IsShown(), "Unmarked dungeon DoneBtn check texture is hidden")
end

-- Duplicate zone aliases flagged so Advisor shows primary 'Riverglades' and omits alias 'Riverlands'
assert_true(addonTable.Data.Zones["Riverglades"].isAlias == nil, "Riverglades is primary zone (not alias)")
assert_true(addonTable.Data.Zones["Riverlands"].isAlias == true, "Riverlands marked as alias")
assert_true(addonTable.Data.Zones["Hyjal"].isAlias == true, "Hyjal marked as alias")
assert_true(addonTable.Data.Zones["The Temple of Atal'Hakkar"].isAlias == true, "The Temple of Atal'Hakkar marked as alias")

-- ============================================================================
-- 3M. UI BUG REGRESSION CHECKS (Cleanup on Disable, Dungeon Banner, Scroll Reset)
-- ============================================================================
print("\n--- [3M] UI Bug Regression Checks ---")

-- 1. Toggle addon disabled strips Quest Log badges instead of early-returning
local savedEnabled3M = addonTable.db.enabled
local savedShowQL3M = addonTable.db.showInQuestLog
local savedQLShown3M = QuestLogFrame:IsShown()
mockQuestLog = {
    { title = "Elwynn Forest (1)", isHeader = true, isCollapsed = false },
    { title = "A Threat Within", questID = 783, level = 1, isHeader = false, isComplete = 0 },
}
mockQuestDB[783] = { title = "A Threat Within", level = 1, xp = 40, money = 0 }
QuestLogFrame:Show()
QuestLogTitle1:Show()
QuestLogTitle2:Show()
addonTable.db.enabled = true
addonTable.db.showInQuestLog = true
addonTable.UI.UpdateQuestLog(true)
local btnQLTextAfterEnable = QuestLogTitle2.normalText:GetText() or ""
assert_true(string.find(btnQLTextAfterEnable, "%[") ~= nil, "QuestLogTitle2 badged when addon enabled: " .. tostring(btnQLTextAfterEnable))

addonTable.db.enabled = false
addonTable.UI.UpdateQuestLog(true)
local btnQLTextAfterDisable = QuestLogTitle2.normalText:GetText() or ""
assert_true(string.find(btnQLTextAfterDisable, "%[%d+%%%]") == nil, "QuestLogTitle2 badge stripped when addon disabled: " .. tostring(btnQLTextAfterDisable))

-- Restore QuestLog state
addonTable.db.enabled = savedEnabled3M
addonTable.db.showInQuestLog = savedShowQL3M
if not savedQLShown3M then QuestLogFrame:Hide() end

-- 2. WorldMap banner sets isDungeon cleanly between dungeon & outdoor zones
local savedMapShown3M = WorldMapFrame:IsShown()
WorldMapFrame:Show()
_G.WorldMapFrame.GetMapID = function() return 291 end -- The Deadmines
if _G.C_Map and _G.C_Map.GetMapInfo then
    local origGetMapInfo = _G.C_Map.GetMapInfo
    _G.C_Map.GetMapInfo = function(id)
        if id == 291 then return { name = "The Deadmines", mapID = 291 } end
        return origGetMapInfo(id)
    end
    addonTable.UI.UpdateWorldMapBanner()
    assert_true(_G["WorthItWorldMapBanner"] and _G["WorthItWorldMapBanner"].isDungeon == true, "WorldMapBanner marks The Deadmines as isDungeon = true")
    _G.C_Map.GetMapInfo = function(id)
        if id == 1429 then return { name = "Elwynn Forest", mapID = 1429 } end
        return origGetMapInfo(id)
    end
    _G.WorldMapFrame.GetMapID = function() return 1429 end
    addonTable.UI.UpdateWorldMapBanner()
    assert_true(_G["WorthItWorldMapBanner"] and _G["WorthItWorldMapBanner"].isDungeon == false, "WorldMapBanner resets isDungeon = false for outdoor zone")
    _G.C_Map.GetMapInfo = origGetMapInfo
end
if not savedMapShown3M then WorldMapFrame:Hide() end

-- 2B. Dynamic System-Wide Integration Checks (Auto Context Invalidation, Alias Sync, Advisor <-> Banner Live Sync)
do
    local savedLvl = mockPlayerState.level
    local savedCls = mockPlayerState.classToken
    local savedFac = mockPlayerState.faction
    local savedRace = mockPlayerState.raceToken
    local savedGetMapID = _G.WorldMapFrame.GetMapID
    local savedGetMapInfo = _G.C_Map.GetMapInfo
    local savedFilter = addonTable.db.zoneAdvisorFilter

    -- a) Auto context cache invalidation without explicit Engine.InvalidateCache()
    mockPlayerState.level = 1
    mockPlayerState.classToken = "WARRIOR"
    mockPlayerState.faction = "Alliance"
    mockPlayerState.raceToken = "Human"
    addonTable.Player.Update()
    local elwynn1 = addonTable.Engine.CalculateWorldMapZoneWorth("Elwynn Forest")
    assert_true(elwynn1 and elwynn1.worth >= 0.90, "Elwynn Forest is optimal at level 1")

    -- Change player level without manually calling Engine.InvalidateCache()
    mockPlayerState.level = 45
    addonTable.Player.Update()
    local elwynn45 = addonTable.Engine.CalculateWorldMapZoneWorth("Elwynn Forest")
    assert_true(elwynn45 and elwynn45.worth <= 0.35 and elwynn45.status == "Outleveled",
        "Engine automatically invalidates stale zone cache when Player level changes")

    -- Same for quest cache on class/level transition
    addonTable.Engine.CalculateWorth(5211)
    assert_true(addonTable.Engine.Cache[5211] ~= nil, "Quest 5211 cached at L45 Warrior")
    mockPlayerState.classToken = "MAGE"
    addonTable.Player.Update()
    addonTable.Engine.CalculateWorth(5211)
    assert_true(addonTable.Engine._ctxClass == "MAGE", "Engine updates tracked player context to MAGE dynamically")

    -- b) Dungeon alias synchronization across Data.GetDungeonProfile & Database completion state
    local stProf = addonTable.Data.GetDungeonProfile("Sunken Temple", "DRUID", "Alliance")
    local atalProf = addonTable.Data.GetDungeonProfile("The Temple of Atal'Hakkar", "DRUID", "Alliance")
    assert_not_nil(atalProf, "Alias 'The Temple of Atal'Hakkar' resolves DungeonProfile cleanly")
    assert_eq(atalProf and atalProf.questCount, stProf and stProf.questCount, "Alias profile questCount matches primary Sunken Temple")

    addonTable.DB.SetDungeonCompleted("Sunken Temple", true)
    assert_true(addonTable.DB.IsDungeonCompleted("The Temple of Atal'Hakkar"),
        "Marking 'Sunken Temple' done propagates to alias 'The Temple of Atal'Hakkar'")
    local atalEval = addonTable.Engine.CalculateWorldMapZoneWorth("The Temple of Atal'Hakkar")
    assert_true(atalEval and atalEval.isCompletedDungeon == true, "Engine flags alias dungeon completed too")
    addonTable.DB.SetDungeonCompleted("The Temple of Atal'Hakkar", false)
    assert_true(not addonTable.DB.IsDungeonCompleted("Sunken Temple"),
        "Unmarking alias cleanly clears primary dungeon completion")

    -- c) Live sync between DoneBtn click, WorldMapBanner, and persistent visibility in DUNGEONS at Lvl 60
    mockPlayerState.level = 20
    mockPlayerState.classToken = "WARRIOR"
    addonTable.Player.Update()
    WorldMapFrame:Show()
    addonTable.db.showZoneAdvisor = true
    addonTable.db.zoneAdvisorFilter = "DUNGEONS"
    _G.WorldMapFrame.GetMapID = function() return 291 end
    _G.C_Map.GetMapInfo = function(id)
        if id == 291 then return { name = "The Deadmines", mapID = 291 } end
        return savedGetMapInfo(id)
    end
    addonTable.UI.ToggleZoneAdvisor(true)
    addonTable.UI.UpdateWorldMapBanner()

    local dmRow = nil
    for r = 1, 100 do
        local row = _G["WorthItAdvisorRow" .. r]
        if not row or not row:IsShown() then break end
        if row.data and row.data.zoneName == "The Deadmines" then dmRow = row; break end
    end
    assert_not_nil(dmRow, "The Deadmines appears in 'DUNGEONS' filter at level 20")
    dmRow.DoneBtn:GetScript("OnClick")(dmRow.DoneBtn)
    local banner = _G["WorthItWorldMapBanner"]
    assert_true(banner and banner.data and banner.data.isCompletedDungeon == true and (banner.Text:GetText():find("Done") ~= nil),
        "Clicking DoneBtn immediately updates WorldMapBanner to [Done]")

    -- Level up to 60 (past Deadmines max+6 = 29): completed dungeon stays visible in 'DUNGEONS' tab to allow unmarking
    mockPlayerState.level = 60
    addonTable.Player.Update()
    addonTable.UI.UpdateZoneAdvisor()
    local dmRow60 = nil
    for r = 1, 100 do
        local row = _G["WorthItAdvisorRow" .. r]
        if not row or not row:IsShown() then break end
        if row.data and row.data.zoneName == "The Deadmines" then dmRow60 = row; break end
    end
    assert_not_nil(dmRow60, "Completed Deadmines stays visible in 'DUNGEONS' tab even at level 60")

    -- Clicking DoneBtn again restores uncompleted state on both Advisor and WorldMapBanner
    dmRow60.DoneBtn:GetScript("OnClick")(dmRow60.DoneBtn)
    assert_true(not addonTable.DB.IsDungeonCompleted("The Deadmines"), "Unmarking at level 60 clears completion")
    assert_true(banner and banner.data and not banner.data.isCompletedDungeon and (banner.Text:GetText():find("Done") == nil),
        "Unmarking immediately restores WorldMapBanner away from [Done]")

    -- Restore test state
    _G.WorldMapFrame.GetMapID = savedGetMapID
    _G.C_Map.GetMapInfo = savedGetMapInfo
    if not savedMapShown3M then WorldMapFrame:Hide() end
    addonTable.db.zoneAdvisorFilter = savedFilter
    mockPlayerState.level = savedLvl
    mockPlayerState.classToken = savedCls
    mockPlayerState.faction = savedFac
    mockPlayerState.raceToken = savedRace
    addonTable.Player.Update()
    addonTable.Engine.InvalidateCache()
end

-- 2C. High-Contrast Parchment/Tooltip Colors & Rich Dynamic Quest Summary
do
    local savedLvl = mockPlayerState.level
    local savedOfferQID = currentOfferQuestID
    local savedOfferTitle = currentOfferTitle
    local savedOfferXP = currentOfferXP
    local savedOfferMoney = currentOfferMoney
    local savedQFShown = QuestFrame:IsShown()
    local savedDPShown = QuestFrameDetailPanel:IsShown()

    assert_eq(addonTable.Utils.FormatMoneyCompact(12540), "1g 25s", "FormatMoneyCompact formats gold+silver cleanly")
    assert_eq(addonTable.Utils.FormatMoneyCompact(4200), "42s", "FormatMoneyCompact formats silver cleanly")
    assert_eq(addonTable.Utils.FormatMoneyCompact(4285), "42s 85c", "FormatMoneyCompact formats silver+copper cleanly")
    assert_eq(addonTable.Utils.FormatMoneyCompact(85), "85c", "FormatMoneyCompact formats copper cleanly")

    mockPlayerState.level = 38
    addonTable.Player.Update()
    mockQuestDB[99994] = {
        title = "Foreman's Plight",
        level = 38,
        xp = 2214,
        money = 3500,
        objectiveText = "Collect Foreman's Tools: 0/5",
        objectives = { { text = "Collect Foreman's Tools: 0/5", finished = false } },
    }
    currentOfferQuestID = 99994
    currentOfferTitle = "Foreman's Plight"
    currentOfferXP = 2214
    currentOfferMoney = 3500
    QuestFrame:Show()
    QuestFrameDetailPanel:Show()
    QuestInfoTitleHeader:SetText("Foreman's Plight")

    addonTable.UI.UpdateQuestOfferDialog()
    local offerTxt = QuestInfoTitleHeader:GetText() or ""
    assert_true(string.find(offerTxt, "|cff331a00", 1, true) ~= nil, "Quest Offer uses high-contrast dark espresso ink on parchment")
    assert_true(string.find(offerTxt, "|cff888888", 1, true) == nil, "Quest Offer omits illegible dim gray |cff888888")
    assert_true(string.find(offerTxt, "2214 XP", 1, true) ~= nil, "Unlisted custom quest Offer displays live XP payout")
    assert_true(string.find(offerTxt, "Collection", 1, true) ~= nil, "Unlisted custom quest Offer displays dynamic task classification")

    local liveSummary = addonTable.Utils.GetQuestLiveSummary(99994)
    assert_not_nil(liveSummary, "GetQuestLiveSummary resolves custom quest 99994")
    assert_eq(liveSummary.taskType, "Item / Object Collection", "Classifies collection objective accurately")
    assert_eq(liveSummary.objectiveSummary, "Collect Foreman's Tools: 0/5", "Extracts live objective preview")

    addonTable.UI.ShowQuestTooltip(GameTooltip, 99994)
    local allTipText = {}
    for _, line in ipairs(GameTooltip.lines or {}) do
        table.insert(allTipText, (line.left or "") .. " " .. (line.right or ""))
    end
    local joinedTip = table.concat(allTipText, "\n")
    assert_true(string.find(joinedTip, "Task:", 1, true) ~= nil, "Tooltip displays Task classification for custom quest")
    assert_true(string.find(joinedTip, "Objective:", 1, true) ~= nil, "Tooltip displays live Objective line")
    assert_true(string.find(joinedTip, "Payout:", 1, true) ~= nil and string.find(joinedTip, "2214 XP", 1, true) ~= nil,
        "Tooltip displays Payout with XP and Mob Kills context")
    assert_true(string.find(joinedTip, "|cff888888", 1, true) == nil and string.find(joinedTip, "|cffa0a0a0", 1, true) == nil,
        "Tooltip eliminates dim |cff888888 and |cffa0a0a0 gray codes")
    GameTooltip:Hide()

    mockQuestDB[99994] = nil
    currentOfferQuestID = savedOfferQID
    currentOfferTitle = savedOfferTitle
    currentOfferXP = savedOfferXP
    currentOfferMoney = savedOfferMoney
    if not savedQFShown then QuestFrame:Hide() end
    if not savedDPShown then QuestFrameDetailPanel:Hide() end
    mockPlayerState.level = savedLvl
    addonTable.Player.Update()
    addonTable.Engine.InvalidateCache()
end

-- 3. Objective Tracker recycled block updates _worthItActiveQuestID & uses live quest ID on OnEnter
local savedShowTracker3M = addonTable.db.showInTracker
addonTable.db.enabled = true
addonTable.db.showInTracker = true
local mockHeaderFS = QuestLogFrame:CreateFontString("WorthIt_TestTrackerFS")
mockHeaderFS:SetText("A Threat Within")
local mockBlock = _G.CreateFrame("Frame", "WorthIt_TestTrackerBlock", UIParent)
mockBlock.HeaderText = mockHeaderFS
mockBlock.questID = 783
mockBlock.SetPoint = function() end
_G.QuestObjectiveTracker = {
    ContentsFrame = mockBlock,
    EnumerateBlocks = function()
        local done = false
        return function()
            if not done then done = true; return mockBlock end
        end
    end
}
addonTable.UI.UpdateObjectiveTracker(true)
assert_true(mockBlock._worthItActiveQuestID == 783, "Recycled tracker block stores active questID 783")
mockQuestDB[194] = { title = "Raptor Mastery", level = 34, xp = 2550, money = 0 }
mockQuestLog = {
    { title = "Stranglethorn Vale (1)", isHeader = true, isCollapsed = false },
    { title = "Raptor Mastery", questID = 194, level = 34, isHeader = false, isComplete = 0 },
}
mockHeaderFS:SetText("Raptor Mastery")
mockBlock.questID = 194
addonTable.UI.UpdateObjectiveTracker(true)
assert_true(mockBlock._worthItActiveQuestID == 194, "Recycled tracker block updates active questID to 194")
if mockBlock.scripts and mockBlock.scripts["OnEnter"] then
    addonTable.lastHoveredQuestID = nil
    mockBlock.scripts["OnEnter"](mockBlock)
    assert_true(addonTable.lastHoveredQuestID == 194, "Recycled tracker block OnEnter resolves live questID 194 instead of stale 783")
end
_G.QuestObjectiveTracker = nil
addonTable.db.showInTracker = savedShowTracker3M

-- 4. Level-scaled XP benchmark differentiates Lvl 32 Foothills (1500 XP) vs Arathi (2500 XP)
local savedLvl3M = mockPlayerState.level
mockPlayerState.level = 32
addonTable.Player.Update()
addonTable.Scores.InvalidateRewardCache()
mockQuestDB[9301] = { title = "Foothills Kill Quest", level = 26, xp = 1500, money = 0 }
mockQuestDB[9302] = { title = "Arathi Kill Quest", level = 32, xp = 2500, money = 0 }
local rFoothills, dFoothills = addonTable.Scores.CalculateReward(9301)
local rArathi, dArathi = addonTable.Scores.CalculateReward(9302)
assert_true(rArathi >= 0.85, "Level 32 Arathi 2500 XP quest achieves High XP reward score (>= 0.85): " .. tostring(rArathi))
assert_true(rFoothills <= 0.65, "Level 32 Foothills 1500 XP quest scores moderate reward (<= 0.65): " .. tostring(rFoothills))
assert_true((rArathi - rFoothills) >= 0.30, string.format("Clear reward gap between 2500 XP (%.0f%%) and 1500 XP (%.0f%%)", rArathi * 100, rFoothills * 100))
mockPlayerState.level = savedLvl3M
addonTable.Player.Update()

-- 5. Dungeon/Raid prequests, attunements & major reward chains boost to 90%+
local savedLvlPreq = mockPlayerState.level
mockPlayerState.level = 18
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
mockQuestDB[65] = { title = "The Defias Brotherhood", level = 18, xp = 675, money = 0 }
local c65 = addonTable.Scores.CalculateChain(65)
local w65 = addonTable.Engine.CalculateWorth(65)
assert_true(c65 >= 0.90, "Deadmines prequest 65 Chain score >= 0.90: " .. tostring(c65))
assert_true(w65 >= 0.90, "Deadmines prequest 65 overall Worth >= 0.90 (90%+): " .. tostring(w65))

mockPlayerState.level = 32
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
local c227 = addonTable.Scores.CalculateChain(227)
local w227 = addonTable.Engine.CalculateWorth(227)
assert_true(c227 >= 0.90, "Mor'Ladim Archeus prequest 227 Chain score >= 0.90: " .. tostring(c227))
assert_true(w227 >= 0.90, "Mor'Ladim Archeus prequest 227 overall Worth >= 0.90 (90%+): " .. tostring(w227))

mockPlayerState.level = 58
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
mockQuestDB[7848] = { title = "Attunement to the Core", level = 60, xp = 5000, money = 0, isDungeon = true }
local c7848 = addonTable.Scores.CalculateChain(7848)
local w7848 = addonTable.Engine.CalculateWorth(7848)
assert_true(c7848 >= 0.90, "Molten Core attunement 7848 Chain score >= 0.90: " .. tostring(c7848))
assert_true(w7848 >= 0.90, "Molten Core attunement 7848 overall Worth >= 0.90 (90%+): " .. tostring(w7848))
mockPlayerState.level = savedLvlPreq
addonTable.Player.Update()

-- 6. Classic greenRange scales by level so Lvl 26-27 Gnomeregan quests at Lvl 33 aren't crushed as gray
local savedLvlGnome = mockPlayerState.level
local savedLogGnome = mockQuestLog
mockPlayerState.level = 33
addonTable.Player.Update()
mockQuestLog = {
    { title = "Gnomeregan (2)", isHeader = true, isCollapsed = false },
    { title = "Save Techbot's Brain!", questID = 2922, level = 26, isHeader = false, isComplete = 0 },
    { title = "Gnogaine", questID = 2926, level = 27, isHeader = false, isComplete = 0 },
}
mockQuestDB[2922] = { title = "Save Techbot's Brain!", level = 26, xp = 2100, money = 0, isDungeon = true }
mockQuestDB[2926] = { title = "Gnogaine", level = 27, xp = 3150, money = 0, isDungeon = true }
addonTable.Engine.InvalidateCache()
addonTable.Scores.InvalidateDensityCache()
local w2922, b2922 = addonTable.Engine.CalculateWorth(2922)
local w2926, b2926 = addonTable.Engine.CalculateWorth(2926)
assert_true(b2922 and b2922.details and b2922.details.difficulty.levelDelta == -7, "Save Techbot's Brain! (2922) evaluated at delta -7")
assert_true(b2922 and b2922.details and b2922.details.difficulty.colorName == "deep_green", "Lvl 26 quest at Lvl 33 is deep_green (NOT gray): " .. tostring(b2922 and b2922.details.difficulty.colorName))
assert_true(b2926 and b2926.details and b2926.details.difficulty.colorName == "deep_green", "Lvl 27 quest at Lvl 33 is deep_green (NOT gray): " .. tostring(b2926 and b2926.details.difficulty.colorName))
assert_true(w2922 >= 0.90, "Save Techbot's Brain! (2922) at Lvl 33 scores >= 0.90: " .. tostring(w2922))
assert_true(w2926 >= 0.90, "Gnogaine (2926) at Lvl 33 scores >= 0.90: " .. tostring(w2926))
mockPlayerState.level = savedLvlGnome
mockQuestLog = savedLogGnome
addonTable.Player.Update()

-- 7. Unaccepted QuestFrame breadcrumb (Friend of the Kirin Tor [33], 270 XP) ignores selected QuestLog leaderboards
local savedLvlKirin = mockPlayerState.level
local savedLogKirin = mockQuestLog
local savedGetNumLB = _G.GetNumQuestLeaderBoards
local savedGetLB = _G.GetQuestLogLeaderBoard
local savedGetQuestText = _G.GetQuestText
mockPlayerState.level = 33
addonTable.Player.Update()
mockQuestLog = {
    { title = "Gnomeregan (1)", isHeader = true, isCollapsed = false },
    { title = "Gyrodrillmatic Excavationators", questID = 2928, level = 30, isHeader = false, isComplete = 0 },
}
mockQuestDB[9303] = {
    title = "Friend of the Kirin Tor",
    level = 33,
    xp = 270,
    money = 0,
    objectiveText = "Find Archmage Ansirem Runeweaver.",
}
_G.GetNumQuestLeaderBoards = function() return 1 end
_G.GetQuestLogLeaderBoard = function() return "0/24 Robo-mechanical Guts", "item", false end
_G.GetQuestText = function() return "I think it's only fair you deliver the good news! Take this note to Archmage Modera." end
currentOfferQuestID = 9303
currentOfferTitle = "Friend of the Kirin Tor"
currentOfferXP = 270
currentOfferMoney = 0
QuestFrame:Show()
addonTable.Utils.ClearTalkToCache(9303)
addonTable.Scores.InvalidateRewardCache(9303)
addonTable.Engine.InvalidateCache()
addonTable.Scores.InvalidateDensityCache()
local isKirinTalk = addonTable.Utils.IsTalkToQuest(9303)
local rKirin = addonTable.Scores.CalculateReward(9303)
local wKirin = addonTable.Engine.CalculateWorth(9303)
assert_true(isKirinTalk == true, "Unaccepted Friend of the Kirin Tor recognized as Talk-To despite active QuestLog combat leaderboards")
assert_true(rKirin >= 0.85, "Friend of the Kirin Tor (270 XP at Lvl 33) scores >= 0.85 Reward as Talk-To: " .. tostring(rKirin))
assert_true(wKirin >= 0.80, "Friend of the Kirin Tor scores >= 0.80 overall Worth instead of 25%: " .. tostring(wKirin))
QuestFrame:Hide()
currentOfferQuestID = nil
currentOfferTitle = nil
currentOfferXP = 0
_G.GetNumQuestLeaderBoards = savedGetNumLB
_G.GetQuestLogLeaderBoard = savedGetLB
_G.GetQuestText = savedGetQuestText
mockPlayerState.level = savedLvlKirin
mockQuestLog = savedLogKirin
addonTable.Player.Update()

-- 8. Verify Quest Object Highlight & CVar mutation are completely removed
assert_true(addonTable.UI.ApplyQuestObjectHighlight == nil, "UI.ApplyQuestObjectHighlight is removed")
assert_true(addonTable.UI.UpdateSoftTargetQuestObjectIcon == nil, "UI.UpdateSoftTargetQuestObjectIcon is removed")
assert_true(addonTable.UI.AddWorldObjectQuestLines == nil, "UI.AddWorldObjectQuestLines is removed")
assert_eq(mockCVars.Outline, "0", "Outline CVar remains untouched (0)")
assert_eq(mockCVars.graphicsOutlineMode, "0", "graphicsOutlineMode CVar remains untouched (0)")
assert_eq(mockCVars.SoftTargetInteract, "1", "SoftTargetInteract CVar remains untouched (1)")

-- 9. Multi-quest NPC Gossip/Greeting lists do NOT show inaccurate pre-selection Worth % badges
do
local savedGossipFrame = _G.GossipFrame
local savedGreetingPanel = _G.QuestFrameGreetingPanel
local savedCGossipInfo = _G.C_GossipInfo
local savedGossipBtn1, savedGossipBtn2 = _G.GossipTitleButton1, _G.GossipTitleButton2
local savedQuestBtn1, savedQuestBtn2 = _G.QuestTitleButton1, _G.QuestTitleButton2

_G.GossipFrame = _G.CreateFrame("Frame", "GossipFrame")
_G.GossipTitleButton1 = _G.CreateFrame("Button", "GossipTitleButton1", _G.GossipFrame)
_G.GossipTitleButton2 = _G.CreateFrame("Button", "GossipTitleButton2", _G.GossipFrame)
_G.GossipTitleButton1:SetText("The Price of Shoes")
_G.GossipTitleButton2:SetText("|cff00ff00[95%]|r Return to MacKinley")
_G.GossipTitleButton2._worthItQuestID = 609

_G.QuestFrameGreetingPanel = _G.CreateFrame("Frame", "QuestFrameGreetingPanel", QuestFrame)
_G.QuestTitleButton1 = _G.CreateFrame("Button", "QuestTitleButton1", _G.QuestFrameGreetingPanel)
_G.QuestTitleButton2 = _G.CreateFrame("Button", "QuestTitleButton2", _G.QuestFrameGreetingPanel)
_G.QuestTitleButton1:SetText("The Price of Shoes")
_G.QuestTitleButton2:SetText("|cffff3333[25%]|r Return to MacKinley")
_G.QuestTitleButton2._worthItQuestID = 609

_G.C_GossipInfo = {
    GetAvailableQuests = function()
        return {
            { questID = 608, title = "The Price of Shoes", questLevel = 32 },
            { questID = 609, title = "Return to MacKinley", questLevel = 33 },
        }
    end
}
mockQuestDB[608] = { title = "The Price of Shoes", level = 32, xp = 2400, money = 0 }
mockQuestDB[609] = { title = "Return to MacKinley", level = 33, xp = 600, money = 0 }

GossipFrame:Show()
addonTable.UI.UpdateGossipAvailableQuests()
local gb1 = _G.GossipTitleButton1:GetText() or ""
local gb2 = _G.GossipTitleButton2:GetText() or ""
assert_true(string.find(gb1, "%[%d+%%%]") == nil, "Gossip multi-quest list omits pre-selection Worth % badge on quest 1")
assert_true(string.find(gb2, "%[%d+%%%]") == nil and gb2 == "Return to MacKinley", "Gossip multi-quest list strips any stale Worth % badge on quest 2")
assert_true(_G.GossipTitleButton2._worthItQuestID == nil, "Gossip button clears _worthItQuestID")

GossipFrame:Hide()
QuestFrame:Show()
QuestFrameGreetingPanel:Show()
addonTable.UI.UpdateQuestOfferDialog()
addonTable.UI.UpdateQuestGreetingPanel()
local qb1 = _G.QuestTitleButton1:GetText() or ""
local qb2 = _G.QuestTitleButton2:GetText() or ""
assert_true(string.find(qb1, "%[%d+%%%]") == nil, "QuestGreeting multi-quest list omits pre-selection Worth % badge on quest 1")
assert_true(string.find(qb2, "%[%d+%%%]") == nil and qb2 == "Return to MacKinley", "QuestGreeting multi-quest list strips any stale Worth % badge on quest 2")
local greetingHover = _G["WorthIt_QuestOfferTitleHover"]
assert_true(not greetingHover or not greetingHover:IsShown(), "Title hover frame remains hidden while QuestFrameGreetingPanel is shown")

-- Selecting a quest afterwards into QuestFrameDetailPanel DOES show accurate Worth %
QuestFrameGreetingPanel:Hide()
QuestFrameDetailPanel:Show()
currentOfferQuestID = 608
currentOfferTitle = "The Price of Shoes"
currentOfferXP = 2400
currentOfferMoney = 0
QuestInfoTitleHeader:SetText("The Price of Shoes")
addonTable.UI.UpdateQuestOfferDialog()
local selectedHeader = QuestInfoTitleHeader:GetText() or ""
assert_true(string.find(selectedHeader, "%[%d+%%%]") ~= nil, "Selected quest offer in QuestFrameDetailPanel displays accurate Worth % badge")
QuestFrame:Hide()
currentOfferQuestID = nil
currentOfferTitle = nil
currentOfferXP = 0

_G.GossipFrame = savedGossipFrame
_G.QuestFrameGreetingPanel = savedGreetingPanel
_G.C_GossipInfo = savedCGossipInfo
_G.GossipTitleButton1, _G.GossipTitleButton2 = savedGossipBtn1, savedGossipBtn2
_G.QuestTitleButton1, _G.QuestTitleButton2 = savedQuestBtn1, savedQuestBtn2
end

-- 10. Cross-mechanic compatibility: GetQuestTitle/Level, 0/1 item non-TalkTo, Dungeon Suitability, and 2D UI Tooltip Owner guard
do
local savedLvl10 = mockPlayerState.level
local savedLog10 = mockQuestLog
mockQuestDB[2926] = {
    title = "Gnogaine",
    level = 27,
    xp = 3150,
    money = 0,
    isDungeon = true,
    objectiveText = "0/1 Full Leaden Collection Phial",
    objectives = { { text = "0/1 Full Leaden Collection Phial", type = "item", finished = false } },
}
mockQuestLog = {
    { title = "Gnomeregan (1)", isHeader = true, isCollapsed = false },
    { title = "Gnogaine", questID = 2926, level = 27, isHeader = false, isComplete = 0 },
}
addonTable.Utils.ClearQuestBasicInfoCache(2926)
assert_eq(addonTable.Utils.GetQuestTitle(2926), "Gnogaine", "Utils.GetQuestTitle resolves quest title")
assert_eq(addonTable.Utils.GetQuestLevel(2926), 27, "Utils.GetQuestLevel resolves quest level")

local savedGetQuestText10 = _G.GetQuestText
_G.GetQuestText = function()
    return "Use the Empty Leaden Collection Phial on Irradiated Invaders. Once it is full, take it back to Ozzie Togglevolt in Kharanos."
end
currentOfferQuestID = 2926
currentOfferTitle = "Gnogaine"
QuestFrame:Show()
addonTable.Utils.ClearTalkToCache(2926)
assert_true(addonTable.Utils.IsTalkToQuest(2926) == false, "0/1 item objective ('0/1 Full Leaden Collection Phial') is NOT misclassified as Talk-To despite 'take it back to' description")
QuestFrame:Hide()
currentOfferQuestID = nil
currentOfferTitle = nil
_G.GetQuestText = savedGetQuestText10

mockPlayerState.level = 30
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
GameTooltip:ClearLines()
addonTable.UI.ShowQuestTooltip(GameTooltip, 2926)
local foundDungeonSuitability = false
for _, line in ipairs(GameTooltip.lines or {}) do
    local txt = (line.left or "") .. " " .. (line.right or "")
    if string.find(txt, "Do Now (Dungeon Group)", 1, true) then
        foundDungeonSuitability = true
    end
end
assert_true(foundDungeonSuitability, "High-worth Dungeon quest displays 'Do Now (Dungeon Group)' in Tooltip Suitability")

mockPlayerState.level = savedLvl10
mockQuestLog = savedLog10
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
end

-- 11. Stranglethorn Vale Level 34 Sub-Zone Guidance & Exploration Quest Scoring
do
local savedLvl11 = mockPlayerState.level
local savedFaction11 = mockPlayerState.faction
local savedLog11 = mockQuestLog
mockPlayerState.level = 34
mockPlayerState.faction = "Alliance"
addonTable.Player.Update()

mockQuestLog = {
    { title = "Stranglethorn Vale (2)", isHeader = true, isCollapsed = false },
    { title = "The Stone of the Tides", questID = 578, level = 37, isHeader = false, isComplete = 0 },
    { title = "Investigate the Camp", questID = 201, level = 32, isHeader = false, isComplete = 0 },
}
mockQuestDB[578] = {
    title = "The Stone of the Tides",
    level = 37,
    xp = 2700,
    money = 0,
    objectives = { { text = "Locate the haunted island", type = "object", finished = false } },
}
mockQuestDB[201] = {
    title = "Investigate the Camp",
    level = 32,
    xp = 1350,
    money = 0,
    objectives = { { text = "Locate the hunters' camp", type = "object", finished = false } },
}

addonTable.Utils.ClearTalkToCache(578)
addonTable.Utils.ClearTalkToCache(201)
addonTable.Engine.InvalidateCache()
addonTable.Engine.WorldMapZoneCache = {}

local is578Talk = addonTable.Utils.IsTalkToQuest(578)
local w578, b578 = addonTable.Engine.CalculateWorth(578)
assert_true(is578Talk == false, "The Stone of the Tides [37] ('Locate the haunted island') is NOT misclassified as Talk-To")
assert_true(b578 and b578.isHard == true, "The Stone of the Tides [37] at Lvl 34 is flagged isHard = true")
assert_true(b578 and b578.isBankable == true, "The Stone of the Tides [37] high-XP orange quest is Bankable")
assert_true(w578 >= 0.53 and w578 <= 0.60, "The Stone of the Tides [37] at Lvl 34 scores in Bankable Orange range [0.53, 0.60]: " .. tostring(w578))

local is201Talk = addonTable.Utils.IsTalkToQuest(201)
local w201 = addonTable.Engine.CalculateWorth(201)
assert_true(is201Talk == false, "Investigate the Camp [32] ('Locate the hunters' camp') is NOT misclassified as Talk-To")
assert_true(w201 <= 0.76, "Investigate the Camp [32] standalone exploration quest stays capped <= 0.76: " .. tostring(w201))

local stvTip = addonTable.Data.GetQuestTip(578, "The Stone of the Tides")
assert_true(stvTip and string.find(string.lower(stvTip), "haunted island", 1, true) ~= nil, "Tip for 578 describes haunted island (not Akiris reeds)")

local stvZone = addonTable.Engine.CalculateWorldMapZoneWorth("Stranglethorn Vale")
assert_eq(stvZone and stvZone.hubName, "North STV: Rebel Camp & Nesingwary (30-36)", "STV at Lvl 34 highlights North STV hubs (30-36)")
assert_true(stvZone and stvZone.recommendation and string.find(stvZone.recommendation, "NORTH", 1, true) ~= nil and string.find(stvZone.recommendation, "30-36", 1, true) ~= nil, "STV at Lvl 34 recommends North STV (30-36) and warns about Booty Bay south mobs")

mockPlayerState.level = savedLvl11
mockPlayerState.faction = savedFaction11
mockQuestLog = savedLog11
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
addonTable.Engine.WorldMapZoneCache = {}
end

-- 12. Deep Audit Mechanics Connection & Cache Coherency
do
-- 12A: Engine.CacheSize decrements accurately on single-quest Engine.InvalidateCache(qID)
addonTable.Engine.InvalidateCache()
assert_eq(addonTable.Engine.CacheSize, 0, "Engine.CacheSize starts at 0 after full wipe")
addonTable.Engine.CalculateWorth(5211)
assert_eq(addonTable.Engine.CacheSize, 1, "Engine.CacheSize increments to 1 after evaluating quest 5211")
addonTable.Engine.InvalidateCache(5211)
assert_eq(addonTable.Engine.CacheSize, 0, "Engine.CacheSize decrements back to 0 after Engine.InvalidateCache(5211)")

-- 12B: Uncached item reward does not poison _questRewardsCache with 0 vendor price
local savedGetItemInfo12 = _G.GetItemInfo
local itemServerReady = false
_G.GetItemInfo = function(item)
    if tostring(item):find("99901") then
        if not itemServerReady then
            return nil
        end
        return "Delayed Reward Sword", "|cff0070dd|Hitem:99901::::::::35:::::::|h[Delayed Reward Sword]|h|r", 3, 40, 35, "Weapon", "One-Handed Swords", 1, "INVTYPE_WEAPON", 135342, 24500
    end
    return savedGetItemInfo12(item)
end
mockQuestDB[9991] = {
    title = "Delayed Server Item Quest",
    level = 35,
    xp = 2400,
    money = 0,
}
currentOfferQuestID = 9991
currentOfferTitle = "Delayed Server Item Quest"
currentOfferChoices = { "|cff0070dd|Hitem:99901::::::::35:::::::|h[Delayed Reward Sword]|h|r" }
currentOfferRewards = {}
QuestFrame:Show()
addonTable.ClearSafeGetItemInfoCache()
addonTable.Engine.InvalidateCache(9991)
local _, _, priceBefore = addonTable.Utils.GetQuestRewardData(9991)
assert_eq(priceBefore, 0, "Uncached server item initially reports 0 vendor price without poisoning cache")

-- Server now delivers GET_ITEM_INFO_RECEIVED
itemServerReady = true
addonTable.ClearSafeGetItemInfoCache()
local _, _, priceAfter = addonTable.Utils.GetQuestRewardData(9991)
assert_eq(priceAfter, 24500, "Utils.GetQuestRewardData resolves 24500 copper immediately once server item info arrives")
QuestFrame:Hide()
currentOfferQuestID = nil
currentOfferTitle = nil
currentOfferChoices = {}
_G.GetItemInfo = savedGetItemInfo12
mockQuestDB[9991] = nil
end

-- 13. Low-Level & Small-Reward Standalone Quest Down-Arrow & Steep Worth Penalty
do
local savedLvl13 = mockPlayerState.level
local savedLog13 = mockQuestLog
mockPlayerState.level = 34
addonTable.Player.Update()

mockQuestDB[9992] = {
    title = "Old Low-Level Task",
    level = 27,
    xp = 1350,
    money = 500,
    objectives = { { text = "0/10 Wolf Pelts", type = "item", finished = false } },
}
mockQuestDB[9993] = {
    title = "Minimal Reward Errand",
    level = 34,
    xp = 350,
    money = 0,
    objectives = { { text = "0/8 River Scales", type = "item", finished = false } },
}
mockQuestLog = {
    { title = "Stranglethorn Vale (2)", isHeader = true, isCollapsed = false },
    { title = "Old Low-Level Task", questID = 9992, level = 27, isHeader = false, isComplete = 0 },
    { title = "Minimal Reward Errand", questID = 9993, level = 34, isHeader = false, isComplete = 0 },
}
addonTable.Utils.ClearTalkToCache(9992)
addonTable.Utils.ClearTalkToCache(9993)
addonTable.Utils.ClearQuestBasicInfoCache(9992)
addonTable.Utils.ClearQuestBasicInfoCache(9993)
addonTable.Engine.InvalidateCache()
addonTable.Scores.InvalidateDensityCache()

local wLowLvl, bLowLvl = addonTable.Engine.CalculateWorth(9992)
assert_true(bLowLvl and bLowLvl.isLowValue == true, "Low-level standalone quest (delta -7, no chain) flagged isLowValue = true")
assert_true(wLowLvl <= 0.22, "Low-level standalone quest steeply penalized (worth <= 0.22): " .. tostring(wLowLvl))
local badgeLowLvl = addonTable.Utils.FormatBadge(wLowLvl, bLowLvl.isComplete, bLowLvl.isHard, bLowLvl.isBankable, bLowLvl.isLowValue)
assert_true(string.find(badgeLowLvl, "UI%-MicroStream%-Red") ~= nil, "Low-level standalone badge includes red down-arrow icon")
assert_eq(addonTable.Utils.CleanQuestTitle(badgeLowLvl .. " Old Low-Level Task"), "Old Low-Level Task", "Utils.CleanQuestTitle strips down-arrow badge cleanly")

local wSmallRew, bSmallRew = addonTable.Engine.CalculateWorth(9993)
assert_true(bSmallRew and bSmallRew.isLowValue == true, "Small-reward standalone quest (no chain) flagged isLowValue = true")
assert_true(wSmallRew <= 0.28, "Small-reward standalone quest steeply penalized (worth <= 0.28): " .. tostring(wSmallRew))
local badgeSmallRew = addonTable.Utils.FormatBadge(wSmallRew, bSmallRew.isComplete, bSmallRew.isHard, bSmallRew.isBankable, bSmallRew.isLowValue)
assert_true(string.find(badgeSmallRew, "UI%-MicroStream%-Red") ~= nil, "Small-reward standalone badge includes red down-arrow icon")

-- Chain quest at low level (e.g. Gnomeregan prequest 2922 at Lvl 34) is NOT flagged isLowValue
mockQuestDB[2922] = { title = "Save Techbot's Brain!", level = 26, xp = 2100, money = 0, isDungeon = true }
addonTable.Engine.InvalidateCache(2922)
local wChainLow, bChainLow = addonTable.Engine.CalculateWorth(2922)
assert_true(bChainLow and bChainLow.isLowValue == false, "Low-level chain/dungeon quest 2922 is NOT flagged isLowValue")
assert_true(wChainLow >= 0.90, "Low-level chain/dungeon quest 2922 retains >= 0.90 Worth: " .. tostring(wChainLow))

-- Nesingwary Safari Tips & Chain Mapping (Tiger Mastery 185 vs Green Hills 338/340)
local tip185 = addonTable.Data.GetQuestTip(185, "Tiger Mastery")
assert_true(tip185 and string.find(tip185, "Young Stranglethorn Tigers", 1, true) ~= nil, "Tip for 185 Tiger Mastery mentions Young Stranglethorn Tigers")
assert_true(tip185 and string.find(tip185, "Chapter pages", 1, true) == nil, "Tip for 185 Tiger Mastery does NOT confuse it with Green Hills pages")

local tip338 = addonTable.Data.GetQuestTip(338, "The Green Hills of Stranglethorn")
assert_true(tip338 and string.find(tip338, "Chapter pages 1-27", 1, true) ~= nil and string.find(tip338, "Auction House", 1, true) ~= nil, "Tip for 338 Green Hills mentions Chapter pages 1-27 & AH")

local tip340 = addonTable.Data.GetQuestTip(340, "Chapter II")
assert_true(tip340 and string.find(tip340, "pages 10, 11, 14, 16", 1, true) ~= nil, "Tip for 340 Chapter II lists pages 10, 11, 14, 16")

local c185 = addonTable.Scores.CalculateChain(185)
assert_true(c185 >= 0.70, "Tiger Mastery (185) recognized as Nesingwary Safari Chain (Chain >= 0.70): " .. tostring(c185))

mockQuestDB[9992] = nil
mockQuestDB[9993] = nil
mockPlayerState.level = savedLvl13
mockQuestLog = savedLog13
addonTable.Player.Update()
addonTable.Engine.InvalidateCache()
addonTable.Scores.InvalidateDensityCache()
end

-- Restore state before Scenario 4
mockPlayerState.level = savedLvl3L
mockPlayerState.race = savedRace3L
mockPlayerState.raceToken = savedRaceToken3L
mockPlayerState.faction = savedFaction3L
mockPlayerState.class = savedClass3L
mockPlayerState.classToken = savedClassToken3L
mockQuestLog = savedLog3L
addonTable.Player.Update()
addonTable.Scores.InvalidateDensityCache()
addonTable.Engine.InvalidateCache()
addonTable.Engine.WorldMapZoneCache = {}

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
-- SCENARIO 5: PERFORMANCE & ERROR RESILIENCE SUITE
-- ============================================================================
print("\n--- SCENARIO 5: Performance & Error Resilience Suite ---")

-- 5A: Hostile Input & Error Resilience Fuzz Test
print(" [5A] Hostile Input & Error Resilience Fuzz Test:")
local nanVal = 0 / 0
local hostileInputs = {
    { name = "nil", val = nil },
    { name = "zero", val = 0 },
    { name = "negative", val = -999 },
    { name = "string", val = "not_a_number" },
    { name = "nan", val = nanVal },
    { name = "huge", val = math.huge },
    { name = "table", val = {} },
}

local fuzzTargets = {
    { name = "Engine.CalculateWorth", fn = function(v) return addonTable.Engine.CalculateWorth(v) end },
    { name = "Engine.CalculateZoneWorth", fn = function(v) return addonTable.Engine.CalculateZoneWorth(v) end },
    { name = "Engine.CalculateWorldMapZoneWorth", fn = function(v) return addonTable.Engine.CalculateWorldMapZoneWorth(v) end },
    { name = "Scores.CalculateDifficulty", fn = function(v) return addonTable.Scores.CalculateDifficulty(v) end },
    { name = "Scores.CalculateReward", fn = function(v) return addonTable.Scores.CalculateReward(v) end },
    { name = "Scores.CalculateChain", fn = function(v) return addonTable.Scores.CalculateChain(v) end },
    { name = "Scores.CalculateClassFit", fn = function(v) return addonTable.Scores.CalculateClassFit(v) end },
    { name = "Scores.CalculateDensity", fn = function(v) return addonTable.Scores.CalculateDensity(v) end },
    { name = "Utils.GetQuestBasicInfo", fn = function(v) return addonTable.Utils.GetQuestBasicInfo(v) end },
    { name = "Utils.IsTalkToQuest", fn = function(v) return addonTable.Utils.IsTalkToQuest(v) end },
    { name = "Utils.FormatScore", fn = function(v) return addonTable.Utils.FormatScore(v) end },
    { name = "Utils.FormatBadge", fn = function(v) return addonTable.Utils.FormatBadge(v) end },
    { name = "Utils.CleanQuestTitle", fn = function(v) return addonTable.Utils.CleanQuestTitle(v) end },
    { name = "Data.GetQuestPayoff", fn = function(v) return addonTable.Data.GetQuestPayoff(v, v) end },
    { name = "Data.GetQuestTip", fn = function(v) return addonTable.Data.GetQuestTip(v, v) end },
    { name = "UI.ShowQuestTooltip", fn = function(v) return addonTable.UI.ShowQuestTooltip(GameTooltip, v) end },
    { name = "UI.UpdateQuestLog", fn = function(v) return addonTable.UI.UpdateQuestLog(v) end },
    { name = "UI.UpdateObjectiveTracker", fn = function(v) return addonTable.UI.UpdateObjectiveTracker(v) end },
    { name = "UI.UpdateWorldMapBanner", fn = function(v) return addonTable.UI.UpdateWorldMapBanner(v) end },
    { name = "UI.UpdateZoneAdvisor", fn = function(v) return addonTable.UI.UpdateZoneAdvisor(v) end },
    { name = "UI.UpdateGossipAvailableQuests", fn = function(v) return addonTable.UI.UpdateGossipAvailableQuests(v) end },
    { name = "UI.UpdateQuestGreetingPanel", fn = function(v) return addonTable.UI.UpdateQuestGreetingPanel(v) end },
}

local fuzzErrors = 0
local fuzzCalls = 0
for _, target in ipairs(fuzzTargets) do
    for _, inp in ipairs(hostileInputs) do
        fuzzCalls = fuzzCalls + 1
        local ok, err = pcall(target.fn, inp.val)
        if not ok then
            fuzzErrors = fuzzErrors + 1
            fail(string.format("Fuzz %s(%s)", target.name, inp.name), err)
        end
    end
end
assert_eq(fuzzErrors, 0, string.format("Hostile input fuzz suite: %d/%d calls succeeded with zero Lua errors", fuzzCalls - fuzzErrors, fuzzCalls))

-- 5B: Throughput & Latency Benchmarks (os.clock())
print(" [5B] Performance & Latency Benchmarks:")
addonTable.Engine.InvalidateCache()
addonTable.Scores.InvalidateDensityCache()

-- Ensure quest 227 is warmed up cleanly before cached benchmark
mockQuestDB[227] = mockQuestDB[227] or { title = "The Weathered Grave", level = 35, xp = 721, money = 0, objectiveText = "Speak with Sirra Von'Indi in Darkshire." }
addonTable.Engine.CalculateWorth(227)

-- 1. 10,000 Cached Engine.CalculateWorth lookups
local t0 = os.clock()
for i = 1, 10000 do
    addonTable.Engine.CalculateWorth(227)
end
local cachedElapsed = os.clock() - t0
local cachedOps = math.floor(10000 / math.max(0.0001, cachedElapsed))
print(string.format("  10,000 Cached CalculateWorth lookups: %.4fs (%d ops/sec)", cachedElapsed, cachedOps))
assert_true(cachedElapsed < 0.050, string.format("10,000 cached CalculateWorth calls completed in %.4fs (< 0.050s)", cachedElapsed))

-- 2. 1,000 Uncached Full 5-Factor Engine.CalculateWorth calculations
local t1 = os.clock()
for i = 1, 1000 do
    local qid = 5211 + (i % 5)
    addonTable.Engine.InvalidateCache(qid)
    addonTable.Engine.CalculateWorth(qid)
end
local uncachedElapsed = os.clock() - t1
local uncachedOps = math.floor(1000 / math.max(0.0001, uncachedElapsed))
print(string.format("  1,000 Uncached Full 5-Factor CalculateWorth: %.4fs (%d ops/sec)", uncachedElapsed, uncachedOps))
assert_true(uncachedElapsed < 0.200, string.format("1,000 uncached CalculateWorth calls completed in %.4fs (< 0.200s)", uncachedElapsed))

-- 3. 200 Full World Map Zone Advisor refreshes across all ~68 zones
WorldMapFrame:Show()
addonTable.UI.ToggleZoneAdvisor(true)
local t2 = os.clock()
for i = 1, 200 do
    addonTable.Engine.WorldMapZoneCache = {}
    addonTable.UI.UpdateZoneAdvisor()
end
local advisorElapsed = os.clock() - t2
local advisorOps = math.floor(200 / math.max(0.0001, advisorElapsed))
print(string.format("  200 Full World Map Zone Advisor refreshes (all zones): %.4fs (%d refreshes/sec)", advisorElapsed, advisorOps))
assert_true(advisorElapsed < 0.250, string.format("200 Zone Advisor refreshes completed in %.4fs (< 0.250s)", advisorElapsed))

-- 4. 1,000 Full UI Refresh Cycles + GC Memory Delta
collectgarbage("collect")
local uiMemBefore = collectgarbage("count")
local t3 = os.clock()
for i = 1, 1000 do
    addonTable.UI.UpdateQuestLog(true)
    addonTable.UI.UpdateObjectiveTracker(true)
    addonTable.UI.UpdateWorldMapBanner()
end
local uiElapsed = os.clock() - t3
collectgarbage("collect")
local uiMemAfter = collectgarbage("count")
local uiMemDelta = uiMemAfter - uiMemBefore
print(string.format("  1,000 Full UI Refresh Cycles: %.4fs, Mem Delta: %.2f KB", uiElapsed, uiMemDelta))
assert_true(uiElapsed < 0.250, string.format("1,000 full UI refresh cycles completed in %.4fs (< 0.250s)", uiElapsed))
assert_true(uiMemDelta < 100, string.format("UI refresh loop net memory growth %.2f KB is healthy (< 100 KB)", uiMemDelta))
addonTable.UI.ToggleZoneAdvisor(false)
WorldMapFrame:Hide()

;(function()
    print("\n [4] Classic & WoW Forever Quest Audit Regression Tests:")
    local Data = addonTable.Data
    local Utils = addonTable.Utils
    local Scores = addonTable.Scores

    -- 4A: Zero truncated scraper / beta placeholder strings across tips and payoffs
    local badSubstrings = {
        "Optional introductory quest:",
        "later offers:",
        "recorded in the beta",
        "not known yet",
        "not confirmed yet",
    }
    local badCount = 0
    for qid, tip in pairs(Data.QuestTips or {}) do
        for _, bad in ipairs(badSubstrings) do
            if type(tip) == "string" and string.find(tip, bad, 1, true) then
                badCount = badCount + 1
                print("  BAD TIP [" .. tostring(qid) .. "]: " .. tip)
            end
        end
    end
    for qid, p in pairs(Data.QuestPayoffs or {}) do
        if type(p) == "table" then
            for _, field in ipairs({ "tip", "note", "summary", "reward" }) do
                local val = p[field]
                if type(val) == "string" then
                    for _, bad in ipairs(badSubstrings) do
                        if string.find(val, bad, 1, true) then
                            badCount = badCount + 1
                            print("  BAD PAYOFF [" .. tostring(qid) .. "." .. field .. "]: " .. val)
                        end
                    end
                end
            end
        end
    end
    assert_eq(badCount, 0, "Zero truncated scraper or beta placeholder strings in QuestTips and QuestPayoffs")

    -- 4B: Classic Quest IDs, Talk-To flags, and Chain mappings
    assert_true(Utils.IsTalkToQuest(228) == false, "Mor'Ladim (228) is not misflagged as Talk-To")
    assert_true(Utils.IsTalkToQuest(226) == false, "Wolves at Our Heels (226) is not misflagged as Talk-To")
    assert_true(Utils.IsTalkToQuest(227) == true, "Morgan Ladimore (227) is Talk-To")

    local p627 = Data.GetQuestPayoff(627)
    assert_true(not (p627 and p627.unlock and string.find(p627.unlock, "Cortello", 1, true)), "Favor for Krazek (627) does not claim Cortello's Riddle unlock")
    local c624 = Data.ChainIndex and Data.ChainIndex[624]
    assert_not_nil(c624, "Cortello's Riddle 624 indexed in chain")
    local p903 = Data.GetQuestPayoff(903)
    assert_true(not (p903 and p903.unlock and string.find(p903.unlock, "Wailing Caverns", 1, true)), "Prowlers of the Barrens (903) does not claim Wailing Caverns unlock")
    local c914 = Data.ChainIndex and Data.ChainIndex[914]
    assert_not_nil(c914, "Leaders of the Fang (914) indexed in Wailing Caverns chain")

    local p55 = Data.GetQuestPayoff(55)
    local p101 = Data.GetQuestPayoff(101)
    assert_not_nil(p55, "Morbent Fel (55) has payoff")
    assert_not_nil(p101, "The Totem of Infliction (101) has payoff")

    -- 4C: WoW Forever Custom & Dungeon Quest Tips, Payoffs, and Talk-To Accuracy
    assert_not_nil(Data.GetQuestPayoff(95943), "Foreman's Plight (95943) has payoff")
    assert_not_nil(Data.GetQuestTip(95943), "Foreman's Plight (95943) has tip")
    assert_true(Utils.IsTalkToQuest(95943) == false, "Foreman's Plight (95943) is NOT Talk-To")

    assert_true(Utils.IsTalkToQuest(98230) == true, "Howin Kindfeather breadcrumb (98230) is Talk-To")
    assert_true(Utils.IsTalkToQuest(98189) == true, "Menethil Statuette step 1 (98189) is Talk-To")
    assert_true(Utils.IsTalkToQuest(94613) == true, "A Grim Discovery (94613) is Talk-To")
    assert_true(Utils.IsTalkToQuest(93443) == true, "Powderfuse Port (93443) is Talk-To")

    for _, qid in ipairs({ 94877, 95991, 98216, 92456, 92489, 96395, 95928, 95250, 79976, -97100 }) do
        assert_not_nil(Data.GetQuestTip(qid), "Forever quest tip present for " .. tostring(qid))
        assert_not_nil(Data.GetQuestPayoff(qid), "Forever quest payoff present for " .. tostring(qid))
    end

    -- 4D: QuestXPFallback Lookup in Scores.CalculateReward
    assert_not_nil(Data.QuestXPFallback, "Data.QuestXPFallback exported")
    assert_eq(Data.QuestXPFallback[92456], 3950, "City of Dalaran quest 92456 fallback XP is 3950")
    assert_eq(Data.QuestXPFallback[95928], 17650, "Shaper's Terrace quest 95928 fallback XP is 17650")

    local savedLvl = mockPlayerState.level
    mockPlayerState.level = 55
    addonTable.Player.Update()
    addonTable.Scores.InvalidateRewardCache(95928)
    addonTable.Engine.InvalidateCache(95928)
    mockQuestDB[95928] = { xp = 0, money = 0 }
    local rwScore, rwDetails = Scores.CalculateReward(95928)
    assert_true(rwScore >= 0.85, "CalculateReward uses QuestXPFallback for 95928 (>= 0.85): " .. tostring(rwScore))
    assert_eq(rwDetails.rewardXP, 17650, "CalculateReward details expose exact fallback XP 17650 for 95928")
    mockQuestDB[95928] = nil
    mockPlayerState.level = savedLvl
    addonTable.Player.Update()

    -- 4E: Minor Recipe: payoff does not trigger 0.90 Chain Finale override
    local c90, c90Details = Scores.CalculateChain(90)
    assert_true(c90 < 0.90, "Minor Recipe quest Seasoned Wolf Kabobs (90) does not get 0.90 Chain Finale boost: " .. tostring(c90))
    assert_true(not (c90Details and c90Details.isMilestone), "Minor Recipe quest (90) is not flagged as isMilestone")

    -- 4F: UI Layering, Quest Log Recycling/Wrapping & Combat Responsiveness Regressions
    local savedStrata4F = WorldMapFrame:GetFrameStrata()
    local savedLevel4F = WorldMapFrame:GetFrameLevel()
    local savedMapShown4F = WorldMapFrame:IsShown()
    local savedInCombat4F = mockPlayerState.inCombat
    local savedAdvisorOpt4F = addonTable.db.showZoneAdvisor

    local mockSC = _G.CreateFrame("Frame", "WorthIt_TestScrollContainer", WorldMapFrame)
    mockSC:SetFrameStrata("FULLSCREEN")
    mockSC:SetFrameLevel(500)
    WorldMapFrame.ScrollContainer = mockSC
    WorldMapFrame:SetFrameStrata("FULLSCREEN")
    WorldMapFrame:SetFrameLevel(2)
    WorldMapFrame:Show()
    mockPlayerState.inCombat = true
    addonTable.db.showZoneAdvisor = true
    addonTable.UI.ToggleZoneAdvisor(true)
    addonTable.UI.UpdateWorldMapBanner()

    local banner4F = _G["WorthItWorldMapBanner"]
    local toggle4F = _G["WorthItAdvisorToggleButton"]
    local panel4F = _G["WorthItZoneAdvisorPanel"]
    assert_not_nil(banner4F, "WorldMapBanner created under ScrollContainer + FULLSCREEN combat")
    assert_true(banner4F:IsShown(), "WorldMapBanner renders during InCombatLockdown when WorldMap is open")
    assert_eq(banner4F:GetFrameStrata(), "FULLSCREEN", "WorldMapBanner syncs FrameStrata to FULLSCREEN map")
    assert_true(banner4F:GetFrameLevel() >= 9000, "WorldMapBanner FrameLevel sits above OpenMap/FDJ overlays: " .. tostring(banner4F:GetFrameLevel()))
    assert_eq(toggle4F:GetParent(), WorldMapFrame, "Advisor toggle button parented to WorldMapFrame instead of clipped ScrollContainer")
    assert_eq(toggle4F:GetFrameStrata(), "FULLSCREEN", "Advisor toggle syncs FrameStrata to FULLSCREEN map")
    assert_eq(panel4F:GetParent(), WorldMapFrame, "Advisor panel parented to WorldMapFrame instead of clipped ScrollContainer")
    assert_true(panel4F:IsShown(), "Advisor panel opens during InCombatLockdown without blocking")

    mockPlayerState.inCombat = false
    WorldMapFrame.ScrollContainer = nil
    WorldMapFrame:SetFrameStrata(savedStrata4F)
    WorldMapFrame:SetFrameLevel(savedLevel4F)
    addonTable.UI.ToggleZoneAdvisor(savedAdvisorOpt4F)
    if not savedMapShown4F then WorldMapFrame:Hide() end

    -- Stale recycled button questID check & wrapped line-height delta in QuestScrollFrame
    local savedLog4F = mockQuestLog
    local savedShowQL4F = addonTable.db.showInQuestLog
    mockQuestLog = {
        { title = "Elwynn Forest", isHeader = true, isCollapsed = false },
        { title = "A Threat Within", questID = 783, level = 1, isHeader = false, isComplete = 0 },
        { title = "Raptor Mastery", questID = 194, level = 34, isHeader = false, isComplete = 0 },
    }
    mockQuestDB[783] = { title = "A Threat Within", level = 1, xp = 40, money = 0 }
    mockQuestDB[194] = { title = "Raptor Mastery", level = 34, xp = 2550, money = 0 }
    addonTable.db.showInQuestLog = true

    local mockBtn4F = _G.CreateFrame("Button", "WorthIt_TestRecycledQLBtn", UIParent)
    mockBtn4F:SetHeight(16)
    mockBtn4F.questID = 783 -- STALE recycled ID from previous quest
    local btnFS4F = mockBtn4F:CreateFontString()
    btnFS4F:SetText("Raptor Mastery")
    btnFS4F.GetStringHeight = function(self)
        local txt = self:GetText() or ""
        return (string.find(txt, "%[") and 28) or 14
    end
    mockBtn4F.Text = btnFS4F
    assert_eq(addonTable.UI.ResolveButtonQuestID(mockBtn4F, "Raptor Mastery"), 194, "ResolveButtonQuestID ignores stale recycled button.questID (783) when visible text is 'Raptor Mastery' (194)")

    local layoutCalls4F = 0
    local mockContents4F = _G.CreateFrame("Frame", "WorthIt_TestQLContents", UIParent)
    mockContents4F.Layout = function() layoutCalls4F = layoutCalls4F + 1 end
    local mockQScroll = _G.CreateFrame("Frame", "WorthIt_TestQuestScroll", UIParent)
    mockQScroll.Contents = mockContents4F
    mockQScroll.titleFramePool = {
        EnumerateActive = function()
            local done = false
            return function()
                if not done then done = true; return mockBtn4F end
            end
        end
    }
    local savedQuestScroll = _G.QuestScrollFrame
    _G.QuestScrollFrame = mockQScroll
    addonTable.UI.InitializeQuestLog()
    assert_true(string.find(btnFS4F:GetText() or "", "%[%d+%%%]") ~= nil, "QuestScrollFrame button badged cleanly")
    assert_eq(mockBtn4F:GetHeight(), 30, "QuestScrollFrame button expands height (+14px) when badged title wraps onto 2 lines")
    assert_true(layoutCalls4F >= 1, "QuestScrollFrame.Contents:Layout() triggered when wrapped row height grew")

    -- Repeating UpdateQuestLog must NOT drift button height
    addonTable.UI.UpdateQuestLog(true)
    assert_eq(mockBtn4F:GetHeight(), 30, "Repeated UpdateQuestLog calls do not drift button height above 30")

    -- Restoring disabled state shrinks height back cleanly
    addonTable.db.showInQuestLog = false
    addonTable.UI.UpdateQuestLog(true)
    assert_eq(mockBtn4F:GetHeight(), 16, "Disabling Quest Log badges restores button base height (16)")

    _G.QuestScrollFrame = savedQuestScroll
    addonTable.db.showInQuestLog = savedShowQL4F
    mockQuestLog = savedLog4F
    mockPlayerState.inCombat = savedInCombat4F
    addonTable.UI.UpdateQuestLog(true)
end)()

-- 4G: Focused vs Unfocused, Pre-Accept vs Post-Accept (Riverlands/Riverglades), and Unfocused Tooltip Isolation
print("\n[Phase 4G] Focused/Unfocused Parity, Pre/Post Accept Parity, and Unfocused Tooltip Guard:")
;(function()
    local savedLvl4G = mockPlayerState.level
    local savedZone4G = mockPlayerState.zone
    local savedSubZone4G = mockPlayerState.subZone
    local savedLog4G = mockQuestLog
    local savedQ783 = mockQuestDB[783]
    local savedQ194 = mockQuestDB[194]
    local savedQ99801 = mockQuestDB[99801]
    local savedQ99802 = mockQuestDB[99802]
    local savedGetSelectedQuest = _G.C_QuestLog.GetSelectedQuest
    local savedSetSelectedQuest = _G.C_QuestLog.SetSelectedQuest
    local savedGetQuestRewardXP = _G.C_QuestLog.GetQuestRewardXP
    local savedGetQuestRewardMoney = _G.C_QuestLog.GetQuestRewardMoney
    local savedGetDifficulty = _G.C_QuestLog.GetQuestDifficultyLevel
    local savedGetQLSelection = _G.GetQuestLogSelection
    local savedSelectQLEntry = _G.SelectQuestLogEntry
    local savedGetQLRewardXP = _G.GetQuestLogRewardXP
    local savedGetQLRewardMoney = _G.GetQuestLogRewardMoney
    local savedGetNumQLChoices = _G.GetNumQuestLogChoices
    local savedGetQLChoiceInfo = _G.GetQuestLogChoiceInfo
    local savedGetNumQLRewards = _G.GetNumQuestLogRewards
    local savedGetQLRewardInfo = _G.GetQuestLogRewardInfo
    local savedGetQLItemLink = _G.GetQuestLogItemLink
    local savedGetQuestID = _G.GetQuestID
    local savedGetTitleText = _G.GetTitleText
    local savedGetObjectiveText = _G.GetObjectiveText
    local savedGetRewardXP = _G.GetRewardXP
    local savedGetRewardMoney = _G.GetRewardMoney
    local savedGetNumChoices = _G.GetNumQuestChoices
    local savedGetNumRewards = _G.GetNumQuestRewards
    local savedGetQuestItemLink = _G.GetQuestItemLink
    local savedBestMap = _G.C_Map.GetBestMapForUnit
    local savedGetMapInfo = _G.C_Map.GetMapInfo
    local savedCGossipInfo = _G.C_GossipInfo
    local savedGossipFrame = _G.GossipFrame
    local savedGreetingPanel = _G.QuestFrameGreetingPanel
    local savedTooltipGetQuest = _G.GameTooltip.GetQuest
    local savedShowTooltips = addonTable.db.showTooltips
    local savedMapShown = WorldMapFrame:IsShown()
    local savedQFShown = QuestFrame:IsShown()
    local savedDPShown = QuestFrameDetailPanel:IsShown()

    -- Test 1: Unfocused vs Focused Quest in Quest Log (WorldMap shown and hidden)
    mockPlayerState.level = 40
    addonTable.Player.Update()
    mockQuestDB[783] = { title = "A Threat Within", level = 1, xp = 40, money = 0 }
    mockQuestDB[194] = { title = "Raptor Mastery", level = 40, xp = 2550, money = 500 }
    mockQuestLog = {
        { title = "Stranglethorn Vale", isHeader = true, isCollapsed = false },
        { title = "A Threat Within", questID = 783, level = 1, isHeader = false, isComplete = 0 },
        { title = "Raptor Mastery", questID = 194, level = 40, isHeader = false, isComplete = 0 },
    }

    local selectedQID4G = 783
    local selectedIdx4G = 2
    _G.C_QuestLog.GetSelectedQuest = function() return selectedQID4G end
    _G.C_QuestLog.SetSelectedQuest = function(qID) selectedQID4G = qID end
    _G.GetQuestLogSelection = function() return selectedIdx4G end
    _G.SelectQuestLogEntry = function(idx) selectedIdx4G = idx end

    local questAwareXP = function(qID)
        if qID == 194 then return 2550 end
        if qID == 99801 then return 2214 end
        if qID == 99802 then return 2214 end
        return 40 -- Calling without questID falls back to focused quest A (783)
    end
    local questAwareMoney = function(qID)
        if qID == 194 then return 500 end
        if qID == 99801 or qID == 99802 then return 1500 end
        return 0
    end
    _G.GetQuestLogRewardXP = questAwareXP
    _G.C_QuestLog.GetQuestRewardXP = questAwareXP
    _G.GetQuestLogRewardMoney = questAwareMoney
    _G.C_QuestLog.GetQuestRewardMoney = questAwareMoney
    _G.GetNumQuestLogChoices = function(qID) return (qID == 194) and 1 or 0 end
    _G.GetQuestLogChoiceInfo = function(i, qID)
        if qID == 194 and i == 1 then
            return "Scarlet Plate Chest", "Interface\\Icons\\INV_Chest_Plate04", 1, 3, true, nil, 40001
        end
        return nil
    end
    _G.GetQuestLogItemLink = function(kind, i, qID)
        if kind == "choice" and qID == 194 and i == 1 then return "item:40001" end
        return nil
    end
    _G.GetNumQuestLogRewards = function(qID) return 0 end
    _G.GetQuestLogRewardInfo = function(i, qID) return nil end

    -- 1a. WorldMapFrame shown while Quest 783 is focused
    WorldMapFrame:Show()
    selectedQID4G = 783
    selectedIdx4G = 2
    addonTable.Engine.InvalidateCache()
    addonTable.Utils.ClearQuestRewardsCache()
    addonTable.Scores.InvalidateRewardCache()
    addonTable.Scores.InvalidateDensityCache()
    local wUnfocusedMap = addonTable.Engine.CalculateWorth(194)
    assert_eq(selectedQID4G, 783, "Map-shown unfocused calculation preserves selected quest 783")

    -- 1b. WorldMapFrame hidden while Quest 783 is focused
    WorldMapFrame:Hide()
    addonTable.Engine.InvalidateCache()
    addonTable.Utils.ClearQuestRewardsCache()
    addonTable.Scores.InvalidateRewardCache()
    addonTable.Scores.InvalidateDensityCache()
    local wUnfocusedLog = addonTable.Engine.CalculateWorth(194)
    assert_eq(selectedQID4G, 783, "Log unfocused calculation restores selected quest 783")
    assert_eq(selectedIdx4G, 2, "Log unfocused calculation restores selected log index 2")

    -- 1c. Quest 194 IS focused
    selectedQID4G = 194
    selectedIdx4G = 3
    addonTable.Engine.InvalidateCache()
    addonTable.Utils.ClearQuestRewardsCache()
    addonTable.Scores.InvalidateRewardCache()
    addonTable.Scores.InvalidateDensityCache()
    local wFocused = addonTable.Engine.CalculateWorth(194)

    local pctUnfocusedMap = math.floor((wUnfocusedMap or 0) * 100 + 0.5)
    local pctUnfocusedLog = math.floor((wUnfocusedLog or 0) * 100 + 0.5)
    local pctFocused = math.floor((wFocused or 0) * 100 + 0.5)
    assert_eq(pctUnfocusedMap, pctFocused, "Unfocused Quest 194 Worth % with WorldMap shown equals focused Worth %")
    assert_eq(pctUnfocusedLog, pctFocused, "Unfocused Quest 194 Worth % with WorldMap hidden equals focused Worth %")

    -- 1d. Hybrid out-of-sync selection (GetSelectedQuest=783 vs GetQuestLogSelection=3) does NOT falsely run callback with map open
    WorldMapFrame:Show()
    selectedQID4G = 783
    selectedIdx4G = 3
    local ranWrongSync = false
    local syncRes = addonTable.Utils.WithSelectedQuest(194, function() ranWrongSync = true; return 1 end)
    assert_true(not ranWrongSync and syncRes == nil, "WithSelectedQuest blocks out-of-sync hybrid selection when WorldMap is shown")
    WorldMapFrame:Hide()

    -- Test 2: Before accepting (QuestFrame in Riverlands) vs After accepting (QUEST_ACCEPTED in Riverglades)
    mockPlayerState.level = 38
    mockPlayerState.zone = "Riverlands"
    mockPlayerState.subZone = "Bertrand's Camp"
    addonTable.Player.Update()
    _G.C_Map.GetBestMapForUnit = function() return 2548 end
    _G.C_Map.GetMapInfo = function() return { mapID = 2548, name = "Riverlands", mapType = 3 } end

    mockQuestDB[99802] = { title = "Freshwater Fiends", level = 38, xp = 2214, money = 1500 }
    mockQuestDB[99801] = nil
    mockQuestLog = {
        { title = "Riverglades", isHeader = true, isCollapsed = false },
        { title = "Freshwater Fiends", questID = 99802, level = 38, isHeader = false, isComplete = 0 },
    }

    _G.GossipFrame = _G.CreateFrame("Frame", "GossipFrame")
    _G.QuestFrameGreetingPanel = _G.CreateFrame("Frame", "QuestFrameGreetingPanel", QuestFrame)
    _G.QuestFrameGreetingPanel:Hide()
    _G.C_GossipInfo = {
        GetAvailableQuests = function()
            return {
                { questID = 99801, title = "Foreman's Plight", questLevel = 38 },
            }
        end
    }
    -- Simulate missing C_QuestLog difficulty API on offer screen (level relies on RecordKnownQuestLevel)
    _G.C_QuestLog.GetQuestDifficultyLevel = function(qID) return nil end

    _G.GetQuestID = function() return 99801 end
    _G.GetTitleText = function() return "Foreman's Plight" end
    _G.GetObjectiveText = function() return "Recover Foreman's Crate." end
    _G.GetRewardXP = function() return 2214 end
    _G.GetRewardMoney = function() return 1500 end
    _G.GetNumQuestChoices = function() return 0 end
    _G.GetNumQuestRewards = function() return 0 end
    _G.GetQuestItemLink = function() return nil end

    addonTable.Engine.InvalidateCache()
    addonTable.Utils.ClearQuestRewardsCache()
    addonTable.Scores.InvalidateRewardCache()
    addonTable.Scores.InvalidateDensityCache()

    _G.GossipFrame:Show()
    addonTable.UI.UpdateGossipAvailableQuests()
    _G.GossipFrame:Hide()
    QuestFrame:Show()
    QuestFrameDetailPanel:Show()
    QuestInfoTitleHeader:SetText("Foreman's Plight")
    addonTable.UI.UpdateQuestOfferDialog()

    local preWorth = addonTable.Engine.CalculateWorth(99801)
    local prePct = math.floor((preWorth or 0) * 100 + 0.5)

    -- Player accepts quest -> QuestFrame hides, quest lands in Riverglades log header, QUEST_ACCEPTED fires
    QuestFrame:Hide()
    QuestFrameDetailPanel:Hide()
    if QuestFrame.scripts and QuestFrame.scripts["OnHide"] then
        QuestFrame.scripts["OnHide"](QuestFrame)
    end
    _G.C_GossipInfo = { GetAvailableQuests = function() return {} end }
    _G.GetQuestID = function() return nil end
    _G.GetTitleText = function() return "" end
    _G.GetRewardXP = function() return 0 end
    _G.GetRewardMoney = function() return 0 end
    mockQuestDB[99801] = { title = "Foreman's Plight", level = 38, xp = 2214, money = 1500 }
    table.insert(mockQuestLog, { title = "Foreman's Plight", questID = 99801, level = 38, isHeader = false, isComplete = 0 })

    onEvent(eventFrame, "QUEST_ACCEPTED", 3, 99801)
    onEvent(eventFrame, "QUEST_LOG_UPDATE")
    local postWorth = addonTable.Engine.CalculateWorth(99801)
    local postPct = math.floor((postWorth or 0) * 100 + 0.5)
    assert_eq(prePct, postPct, "Pre-accept Worth % in Riverlands matches post-accept Worth % in Riverglades even after QUEST_LOG_UPDATE")

    -- Test 3: GameTooltip:OnTooltipSetQuest unfocused hover does not bleed focused quest 783
    mockPlayerState.level = 40
    addonTable.Player.Update()
    mockQuestLog = {
        { title = "Stranglethorn Vale", isHeader = true, isCollapsed = false },
        { title = "A Threat Within", questID = 783, level = 1, isHeader = false, isComplete = 0 },
        { title = "Raptor Mastery", questID = 194, level = 40, isHeader = false, isComplete = 0 },
    }
    selectedQID4G = 783
    addonTable.db.showTooltips = true
    addonTable.lastHoveredQuestID = nil
    GameTooltip:ClearLines()
    GameTooltip.GetQuest = function() return nil end
    GameTooltip:AddLine("Raptor Mastery")
    if GameTooltip.scripts and GameTooltip.scripts["OnTooltipSetQuest"] then
        GameTooltip.scripts["OnTooltipSetQuest"](GameTooltip)
    end
    assert_eq(addonTable.lastHoveredQuestID, 194, "GameTooltip OnTooltipSetQuest resolves hovered 'Raptor Mastery' (194) even when Quest 783 is focused")
    local leaked783 = false
    for _, line in ipairs(GameTooltip.lines or {}) do
        if line.left and string.find(tostring(line.left), "40 XP") then
            leaked783 = true
        end
    end
    assert_true(not leaked783, "GameTooltip OnTooltipSetQuest does not bleed focused Quest 783's 40 XP into hovered Quest 194")

    -- Restore all globals and mocks cleanly
    GameTooltip:ClearLines()
    GameTooltip.GetQuest = savedTooltipGetQuest
    addonTable.db.showTooltips = savedShowTooltips
    addonTable.lastHoveredQuestID = nil
    _G.GossipFrame = savedGossipFrame
    _G.QuestFrameGreetingPanel = savedGreetingPanel
    _G.C_GossipInfo = savedCGossipInfo
    _G.C_Map.GetBestMapForUnit = savedBestMap
    _G.C_Map.GetMapInfo = savedGetMapInfo
    _G.GetQuestID = savedGetQuestID
    _G.GetTitleText = savedGetTitleText
    _G.GetObjectiveText = savedGetObjectiveText
    _G.GetRewardXP = savedGetRewardXP
    _G.GetRewardMoney = savedGetRewardMoney
    _G.GetNumQuestChoices = savedGetNumChoices
    _G.GetNumQuestRewards = savedGetNumRewards
    _G.GetQuestItemLink = savedGetQuestItemLink
    _G.GetQuestLogItemLink = savedGetQLItemLink
    _G.GetQuestLogRewardInfo = savedGetQLRewardInfo
    _G.GetNumQuestLogRewards = savedGetNumQLRewards
    _G.GetQuestLogChoiceInfo = savedGetQLChoiceInfo
    _G.GetNumQuestLogChoices = savedGetNumQLChoices
    _G.GetQuestLogRewardMoney = savedGetQLRewardMoney
    _G.GetQuestLogRewardXP = savedGetQLRewardXP
    _G.SelectQuestLogEntry = savedSelectQLEntry
    _G.GetQuestLogSelection = savedGetQLSelection
    _G.C_QuestLog.GetQuestDifficultyLevel = savedGetDifficulty
    _G.C_QuestLog.GetQuestRewardMoney = savedGetQuestRewardMoney
    _G.C_QuestLog.GetQuestRewardXP = savedGetQuestRewardXP
    _G.C_QuestLog.SetSelectedQuest = savedSetSelectedQuest
    _G.C_QuestLog.GetSelectedQuest = savedGetSelectedQuest
    mockQuestDB[783] = savedQ783
    mockQuestDB[194] = savedQ194
    mockQuestDB[99801] = savedQ99801
    mockQuestDB[99802] = savedQ99802
    mockQuestLog = savedLog4G
    mockPlayerState.level = savedLvl4G
    mockPlayerState.zone = savedZone4G
    mockPlayerState.subZone = savedSubZone4G
    addonTable.Player.Update()
    if savedMapShown then WorldMapFrame:Show() else WorldMapFrame:Hide() end
    if savedQFShown then QuestFrame:Show() else QuestFrame:Hide() end
    if savedDPShown then QuestFrameDetailPanel:Show() else QuestFrameDetailPanel:Hide() end
    addonTable.Engine.InvalidateCache()
    addonTable.Utils.ClearQuestRewardsCache()
    addonTable.Scores.InvalidateRewardCache()
    addonTable.Scores.InvalidateDensityCache()
end)()

-- 4H: Up to Snuff (587), Favor for Krazek (627), Standalone Green -4 Calibration, and Objective Tracker Prop-Tooltip Guard
print("\n[Phase 4H] Multi-Item Talk-To Guard (587), Green -4 Calibration (627), and Prop-Tooltip Isolation:")
;(function()
    local savedLvl4H = mockPlayerState.level
    local savedClass4H = mockPlayerState.class
    local savedClassTok4H = mockPlayerState.classToken
    local savedZone4H = mockPlayerState.zone
    local savedLog4H = mockQuestLog
    local savedQ587 = mockQuestDB[587]
    local savedQ627 = mockQuestDB[627]
    local savedQ99805 = mockQuestDB[99805]
    local savedGetQuestID = _G.GetQuestID
    local savedGetTitleText = _G.GetTitleText
    local savedGetObjectiveText = _G.GetObjectiveText
    local savedGetQuestText = _G.GetQuestText
    local savedGetRewardXP = _G.GetRewardXP
    local savedGetRewardMoney = _G.GetRewardMoney
    local savedGetNumChoices = _G.GetNumQuestChoices
    local savedGetNumRewards = _G.GetNumQuestRewards
    local savedGetQuestItemLink = _G.GetQuestItemLink
    local savedGetNumQLRewards = _G.GetNumQuestLogRewards
    local savedGetNumQLChoices = _G.GetNumQuestLogChoices
    local savedBestMap = _G.C_Map.GetBestMapForUnit
    local savedGetMapInfo = _G.C_Map.GetMapInfo
    local savedQFShown = QuestFrame:IsShown()
    local savedDPShown = QuestFrameDetailPanel:IsShown()
    local savedTracker = _G.QuestObjectiveTracker
    local savedShowTracker = addonTable.db.showInTracker
    local savedShowTooltip = addonTable.db.showInTooltip

    -- Setup Lvl 41 Melee Rogue in Stranglethorn Vale with active 8-quest hub
    mockPlayerState.level = 41
    mockPlayerState.class = "Rogue"
    mockPlayerState.classToken = "ROGUE"
    mockPlayerState.zone = "Stranglethorn Vale"
    addonTable.Player.Update()
    addonTable.Engine.InvalidateSpecCache()
    addonTable.Scores.InvalidateMeleeCache()
    addonTable.Scores.InvalidateClassFitCache()
    _G.C_Map.GetBestMapForUnit = function() return 1434 end
    _G.C_Map.GetMapInfo = function() return { mapID = 1434, name = "Stranglethorn Vale", mapType = 3 } end

    mockQuestLog = {
        { title = "Stranglethorn Vale", isHeader = true, isCollapsed = false },
        { title = "STV Hub Q1", questID = 99811, level = 41, isHeader = false, isComplete = 0 },
        { title = "STV Hub Q2", questID = 99812, level = 41, isHeader = false, isComplete = 0 },
        { title = "STV Hub Q3", questID = 99813, level = 41, isHeader = false, isComplete = 0 },
        { title = "STV Hub Q4", questID = 99814, level = 41, isHeader = false, isComplete = 0 },
        { title = "STV Hub Q5", questID = 99815, level = 41, isHeader = false, isComplete = 0 },
        { title = "STV Hub Q6", questID = 99816, level = 41, isHeader = false, isComplete = 0 },
        { title = "STV Hub Q7", questID = 99817, level = 41, isHeader = false, isComplete = 0 },
    }

    -- 1. Up to Snuff (587): "bring him 15 shares of Snuff" + "find me" lore must NOT misflag IsTalkToQuest
    mockQuestDB[587] = { title = "Up to Snuff", level = 41, xp = 1650, money = 0 }
    _G.GetQuestID = function() return 587 end
    _G.GetTitleText = function() return "Up to Snuff" end
    _G.GetObjectiveText = function() return "Deeg in Booty Bay wants you to bring him 15 shares of Snuff." end
    _G.GetQuestText = function() return "Ah, the sea life. When I get into port I like to find me a pinch of snuff." end
    _G.GetRewardXP = function() return 1650 end
    _G.GetRewardMoney = function() return 0 end
    _G.GetNumQuestChoices = function() return 0 end
    _G.GetNumQuestRewards = function() return 0 end
    _G.GetQuestItemLink = function() return nil end
    _G.GetNumQuestLogRewards = function() return 0 end
    _G.GetNumQuestLogChoices = function() return 0 end

    QuestFrame:Show()
    QuestFrameDetailPanel:Show()
    QuestInfoTitleHeader:SetText("Up to Snuff")
    addonTable.Utils.ClearTalkToCache(587)
    addonTable.Engine.InvalidateCache()
    addonTable.Scores.InvalidateDensityCache()
    assert_true(addonTable.Utils.IsTalkToQuest(587) == false, "Up to Snuff (587) offer ('15 shares') is NOT misclassified as Talk-To")
    local w587Pre, b587Pre = addonTable.Engine.CalculateWorth(587)
    local pct587Pre = math.floor((w587Pre or 0) * 100 + 0.5)
    assert_true(b587Pre and b587Pre.r and b587Pre.r < 0.80, "Up to Snuff (587) pre-accept does not inflate 1650 XP to 100% Talk-To reward")

    -- Accept 587 into quest log with leaderboard "0/15 Snuff" -> pre-accept & post-accept % must match
    QuestFrame:Hide()
    QuestFrameDetailPanel:Hide()
    mockQuestDB[587].objectives = { { text = "Snuff: 0/15", type = "item", finished = false } }
    table.insert(mockQuestLog, { title = "Up to Snuff", questID = 587, level = 41, isHeader = false, isComplete = 0 })
    onEvent(eventFrame, "QUEST_ACCEPTED", 9, 587)
    local w587Post = addonTable.Engine.CalculateWorth(587)
    local pct587Post = math.floor((w587Post or 0) * 100 + 0.5)
    assert_eq(pct587Pre, pct587Post, "Up to Snuff (587) Worth % matches before and after accepting")

    -- 2. Favor for Krazek (627, L37 at L41 Rogue) & standalone green -4 (99805, L37 at L41 Rogue)
    mockQuestDB[627] = { title = "Favor for Krazek", level = 37, xp = 2100, money = 3000, objectives = { { text = "0/4 Lesser Bloodstone Ore", type = "item", finished = false } } }
    mockQuestDB[99805] = { title = "Booty Bay Green Hub Task", level = 37, xp = 2100, money = 3000, objectives = { { text = "0/8 Coast Pelts", type = "item", finished = false } } }
    table.insert(mockQuestLog, { title = "Favor for Krazek", questID = 627, level = 37, isHeader = false, isComplete = 0 })
    table.insert(mockQuestLog, { title = "Booty Bay Green Hub Task", questID = 99805, level = 37, isHeader = false, isComplete = 0 })

    addonTable.Engine.InvalidateCache()
    addonTable.Scores.InvalidateDensityCache()
    local w627, b627 = addonTable.Engine.CalculateWorth(627)
    assert_true(b627 and not b627.isLowValue, "Favor for Krazek (627) at L41 Rogue is NOT crushed as Low Value")
    assert_true(w627 >= 0.55, "Favor for Krazek (627) retains healthy Hub/Chain Worth >= 55%: " .. tostring(w627))
    assert_true(addonTable.Data.ChainIndex and addonTable.Data.ChainIndex[627] ~= nil, "Favor for Krazek (627) is indexed in Krazek's Cookery chain")

    local wStandaloneMinus4, bStandaloneMinus4 = addonTable.Engine.CalculateWorth(99805)
    assert_true(bStandaloneMinus4 and bStandaloneMinus4.details and bStandaloneMinus4.details.difficulty and bStandaloneMinus4.details.difficulty.colorName == "green", "Melee Rogue at delta -4 gets 'green' difficulty instead of 'deep_green'")
    assert_true(bStandaloneMinus4 and not bStandaloneMinus4.isLowValue, "Standalone green -4 quest with 49% XP in active hub is NOT crushed as Low Value")
    assert_true(wStandaloneMinus4 >= 0.50, "Standalone green -4 quest scores naturally >= 50% instead of 22% cap: " .. tostring(wStandaloneMinus4))

    -- 3. Objective Tracker Hover replaces lingering 3D world tooltip ('Wooden Chair') instead of mixing lines
    addonTable.db.showInTracker = true
    addonTable.db.showInTooltip = true
    local mockPropBlock = _G.CreateFrame("Frame", "WorthIt_TestPropBlock", UIParent)
    mockPropBlock.questID = 627
    local mockPropFS = mockPropBlock:CreateFontString()
    mockPropFS:SetText("Favor for Krazek")
    mockPropBlock.HeaderText = mockPropFS
    _G.QuestObjectiveTracker = {
        ContentsFrame = mockPropBlock,
        EnumerateBlocks = function()
            local done = false
            return function()
                if not done then done = true; return mockPropBlock end
            end
        end
    }
    addonTable.UI.UpdateObjectiveTracker(true)
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    GameTooltip:AddLine("Wooden Chair", 1, 0.82, 0)
    GameTooltip:Show()
    assert_not_nil(mockPropBlock.scripts["OnEnter"], "Objective Tracker block hooked OnEnter")
    mockPropBlock.scripts["OnEnter"](mockPropBlock)
    local tipLine1After = _G["GameTooltipTextLeft1"] and _G["GameTooltipTextLeft1"]:GetText() or ""
    assert_true(string.find(tipLine1After, "Favor for Krazek", 1, true) ~= nil, "Hovering tracker block replaces unrelated 'Wooden Chair' world tooltip with 'Favor for Krazek'")

    -- Restore globals cleanly
    GameTooltip:ClearLines()
    _G.QuestObjectiveTracker = savedTracker
    addonTable.db.showInTracker = savedShowTracker
    addonTable.db.showInTooltip = savedShowTooltip
    _G.C_Map.GetBestMapForUnit = savedBestMap
    _G.C_Map.GetMapInfo = savedGetMapInfo
    _G.GetNumQuestLogChoices = savedGetNumQLChoices
    _G.GetNumQuestLogRewards = savedGetNumQLRewards
    _G.GetQuestItemLink = savedGetQuestItemLink
    _G.GetNumQuestRewards = savedGetNumRewards
    _G.GetNumQuestChoices = savedGetNumChoices
    _G.GetRewardMoney = savedGetRewardMoney
    _G.GetRewardXP = savedGetRewardXP
    _G.GetQuestText = savedGetQuestText
    _G.GetObjectiveText = savedGetObjectiveText
    _G.GetTitleText = savedGetTitleText
    _G.GetQuestID = savedGetQuestID
    mockQuestDB[587] = savedQ587
    mockQuestDB[627] = savedQ627
    mockQuestDB[99805] = savedQ99805
    mockQuestLog = savedLog4H
    mockPlayerState.level = savedLvl4H
    mockPlayerState.class = savedClass4H
    mockPlayerState.classToken = savedClassTok4H
    mockPlayerState.zone = savedZone4H
    addonTable.Player.Update()
    addonTable.Engine.InvalidateSpecCache()
    addonTable.Scores.InvalidateMeleeCache()
    addonTable.Scores.InvalidateClassFitCache()
    if savedQFShown then QuestFrame:Show() else QuestFrame:Hide() end
    if savedDPShown then QuestFrameDetailPanel:Show() else QuestFrameDetailPanel:Hide() end
    addonTable.Engine.InvalidateCache()
    addonTable.Utils.ClearTalkToCache()
    addonTable.Scores.InvalidateRewardCache()
    addonTable.Scores.InvalidateDensityCache()
end)()

-- 4I: Complete Wowhead Forever Catalog & Custom Zones Coverage
print("\n[Phase 4I] Full Wowhead Forever Catalog (>= 2,200 Quests) & Missing Zones:")
;(function()
    local Data = addonTable.Data
    local Utils = addonTable.Utils

    local catCount = 0
    for _ in pairs(Data.ForeverCatalog or {}) do catCount = catCount + 1 end
    assert_true(catCount >= 2200, "Data.ForeverCatalog loaded >= 2200 Forever New & Updated quests: " .. tostring(catCount))

    local xpCount = 0
    for _ in pairs(Data.QuestXPFallback or {}) do xpCount = xpCount + 1 end
    assert_true(xpCount >= 2000, "Data.QuestXPFallback covers >= 2000 Forever XP entries: " .. tostring(xpCount))

    -- Missing zones added cleanly (Shen'dralas primary, subzones aliases, Darkspear Islands PvP BG)
    local shenZone = Data.GetZoneInfo("Shen'dralas")
    assert_not_nil(shenZone, "Shen'dralas added to Data.Zones")
    assert_true(shenZone and not shenZone.isAlias and shenZone.min == 38 and shenZone.max == 45, "Shen'dralas configured as 38-45 Kalimdor zone")
    assert_true(Data.Zones["Stonewrought Dam"] and Data.Zones["Stonewrought Dam"].isAlias == true, "Stonewrought Dam marked as alias")
    assert_true(Data.Zones["Thoradin's Wall"] and Data.Zones["Thoradin's Wall"].isAlias == true, "Thoradin's Wall marked as alias")
    assert_true(Data.Zones["Elderwild"] and Data.Zones["Elderwild"].isAlias == true, "Elderwild marked as alias")
    assert_true(Data.Zones["South Seas"] and Data.Zones["South Seas"].isAlias == true, "South Seas marked as alias")
    assert_true(Data.Zones["Darkspear Islands"] and Data.Zones["Darkspear Islands"].isCity == true, "Darkspear Islands PvP BG excluded from leveling advisor")

    -- Previously missing quests across Riverglades, Shen'dralas, Mount Hyjal, Zephras Isle, Dungeons & South Seas
    assert_eq(Data.QuestXPFallback[95982], 2850, "Riverglades 95982 (Not My Circus) fallback XP is 2850")
    assert_eq(Data.QuestXPFallback[93574], 4850, "Shen'dralas 93574 (Corpsefeeder's Carapace) fallback XP is 4850")
    assert_eq(Data.QuestXPFallback[96322], 7750, "Mount Hyjal 96322 (A Revenge Now Bitter) fallback XP is 7750")
    assert_eq(Data.QuestXPFallback[92550], 700, "Zephras Isle 92550 (Havoc in the Highlands) fallback XP is 700")
    assert_eq(Data.QuestXPFallback[95737], 630, "Excavation Site 95737 (Seeking Caitlin) fallback XP is 630")
    assert_eq(Data.QuestXPFallback[95056], 3450, "Krol'dok 95056 (Krol'dok No More!) fallback XP is 3450")
    assert_eq(Data.QuestXPFallback[96376], 6550, "Alcaz Prison 96376 (State Secrets) fallback XP is 6550")
    assert_eq(Data.QuestXPFallback[96603], 8300, "City of Dalaran 96603 (Unstable Magic) fallback XP is 8300")
    assert_eq(Data.QuestXPFallback[84213], 10550, "South Seas 84213 (Rift Away) fallback XP is 10550")

    local pay93574 = Data.GetQuestPayoff(93574)
    assert_true(pay93574 and pay93574.origin and string.find(pay93574.origin, "Shen'dralas", 1, true) ~= nil, "GetQuestPayoff resolves Shen'dralas origin for 93574")
    assert_true(pay93574 and pay93574.reward and string.find(pay93574.reward, "Pick one", 1, true) ~= nil, "GetQuestPayoff resolves item rewards for 93574")

    -- Utils.GetQuestBasicInfo fallback level & Elite tag from ForeverCatalog when client has no cached level
    Utils.ClearQuestBasicInfoCache(84213)
    local savedGetTitle4I = _G.C_QuestLog.GetTitleForQuestID
    local savedGetDiff4I = _G.C_QuestLog.GetQuestDifficultyLevel
    _G.C_QuestLog.GetTitleForQuestID = function(qid) return (qid == 84213) and "Rift Away" or savedGetTitle4I(qid) end
    _G.C_QuestLog.GetQuestDifficultyLevel = function() return nil end
    local info84213 = Utils.GetQuestBasicInfo(84213)
    assert_eq(info84213 and info84213.level, 62, "GetQuestBasicInfo resolves catalog level 62 for 84213 when uncached")
    assert_true(info84213 and info84213.isLevelFallback == false and info84213.isElite == true, "GetQuestBasicInfo marks catalog level reliable & Elite for 84213")
    _G.C_QuestLog.GetTitleForQuestID = savedGetTitle4I
    _G.C_QuestLog.GetQuestDifficultyLevel = savedGetDiff4I
    Utils.ClearQuestBasicInfoCache(84213)

    -- 4I-extra: Post-audit hygiene checks across ForeverCatalog, NON_ZONE_HEADERS, subhub aliases, and QuestOffer fallback guard
    local catBadRew = 0
    local catZeroLvl = 0
    for _, entry in pairs(Data.ForeverCatalog or {}) do
        if (entry[2] or 0) <= 0 then catZeroLvl = catZeroLvl + 1 end
        local rew = entry[6]
        if type(rew) == "string" and (string.find(rew, "Item #", 1, true) or string.find(rew, "^%d") or string.find(rew, "zzOLD", 1, true) or string.find(rew, "Pick one:%s*$") or string.find(rew, "Also get:%s*$")) then
            catBadRew = catBadRew + 1
        end
    end
    assert_eq(catBadRew, 0, "Zero malformed reward stubs across all ForeverCatalog entries")
    assert_eq(catZeroLvl, 0, "Zero lvl<=0 placeholder quests across all ForeverCatalog entries")

    for _, nonZone in ipairs({ "Camping", "Crafting", "Darkmoon Faire", "Lunar Festival", "Warrior", "Paladin", "Nightmare Incursions" }) do
        assert_true(addonTable.Scores.IsNonZoneHeader(nonZone) == true, "NON_ZONE_HEADERS includes '" .. nonZone .. "'")
    end

    -- Stale lastHoveredQuestID must NOT hijack an unrelated NPC offer title
    local savedQF4I = QuestFrame:IsShown()
    local savedDP4I = QuestFrameDetailPanel:IsShown()
    local savedTitleFunc4I = _G.GetQuestID
    addonTable.lastHoveredQuestID = 783
    _G.GetQuestID = function() return nil end
    QuestFrame:Show()
    QuestFrameDetailPanel:Show()
    QuestInfoTitleHeader:SetText("Completely Unrelated Unknown Quest")
    addonTable.UI.UpdateQuestOfferDialog()
    assert_true(addonTable._activeOfferQuestID == nil, "UpdateQuestOfferDialog does not hijack unrelated offer with stale lastHoveredQuestID 783")
    _G.GetQuestID = savedTitleFunc4I
    addonTable.lastHoveredQuestID = nil
    if not savedQF4I then QuestFrame:Hide() end
    if not savedDP4I then QuestFrameDetailPanel:Hide() end
end)()

-- 4J: Deep Logic Audit Regressions (Tags, ProgressPanel, Viability Monotonicity, Weights, Reward, Quiver/Relic, Density Rescan)
print("\n[Phase 4J] Deep Logic Audit Regressions & Boundary Invariants:")
;(function()
    local Utils = addonTable.Utils
    local Engine = addonTable.Engine
    local Scores = addonTable.Scores

    -- Save shared mocks cleanly
    local origPlayerLvl = UnitLevel("player")
    local _, origPlayerCls = UnitClass("player")
    local origUnitLevel = _G.UnitLevel
    local origUnitClass = _G.UnitClass
    local origGetTitle = _G.C_QuestLog.GetTitleForQuestID
    local origGetDiff = _G.C_QuestLog.GetQuestDifficultyLevel
    local origGetTag = _G.C_QuestLog.GetQuestTagInfo
    local origGetNumEntries = _G.GetNumQuestLogEntries
    local origGetQLogTitle = _G.GetQuestLogTitle
    local origGetQLogIdx = _G.GetQuestLogIndexByID
    local origCGetQLogIdx = _G.C_QuestLog.GetLogIndexForQuestID
    local origGetInfo = _G.C_QuestLog.GetInfo
    local origGetXP = _G.GetQuestLogRewardXP
    local origCGetXP = _G.C_QuestLog.GetQuestRewardXP
    local origGetMoney = _G.GetQuestLogRewardMoney
    local origCGetMoney = _G.C_QuestLog.GetQuestRewardMoney
    local origCGetObjs = _G.C_QuestLog.GetQuestObjectives
    local origGetNumChoices = _G.GetNumQuestLogChoices
    local origGetChoiceInfo = _G.GetQuestLogChoiceInfo
    local origGetItemLink = _G.GetQuestLogItemLink
    local origGetNumRewards = _G.GetNumQuestLogRewards
    local origGetNumLB = _G.GetNumQuestLeaderBoards
    local origGetLB = _G.GetQuestLogLeaderBoard
    local origIsOnQuest = _G.IsOnQuest
    local origCIsOnQuest = _G.C_QuestLog.IsOnQuest
    local origGetItemInfo = _G.GetItemInfo
    local origGetItemStats = _G.GetItemStats
    local origGetInvLink = _G.GetInventoryItemLink
    local origGetContSlots = _G.GetContainerNumSlots
    local origCContSlots = _G.C_Container and _G.C_Container.GetContainerNumSlots
    local origGetTime = _G.GetTime
    local origQFShown = QuestFrame:IsShown()
    local origGPShown = QuestFrameGreetingPanel and QuestFrameGreetingPanel:IsShown()
    local origPP = _G.QuestFrameProgressPanel

    local function resync()
        addonTable.Player.Update()
        Scores.InvalidateClassFitCache()
        Scores.InvalidateEquippedStatsCache()
        Scores.InvalidateRewardCache()
        Scores.InvalidateDensityCache()
        Engine.InvalidateCache()
    end

    -- 1. Bug 1: Catalog Elite/Dungeon tag persistence even when level is already cached / known + QuestLog tags when title/level already known
    _G.C_QuestLog.GetTitleForQuestID = function(qid)
        if qid == 95991 then return "Catalog Elite Probe"
        elseif qid == 95646 then return "Catalog Dungeon Probe"
        elseif qid == 990101 then return "Log Elite Probe"
        elseif qid == 990102 then return "Tag Group Probe" end
        return origGetTitle and origGetTitle(qid) or nil
    end
    _G.C_QuestLog.GetQuestDifficultyLevel = function(qid)
        if qid == 95991 then return 42
        elseif qid == 95646 then return 31
        elseif qid == 990101 or qid == 990102 then return 41 end
        return nil
    end
    _G.C_QuestLog.GetQuestTagInfo = function(qid)
        if qid == 990102 then return { tagID = 1, tagName = "Group" } end
        return nil
    end
    Utils.RecordKnownQuestLevel(95991, "Catalog Elite Probe", 42)
    Utils.RecordKnownQuestLevel(95646, "Catalog Dungeon Probe", 31)
    Utils.ClearQuestBasicInfoCache()
    local bElite = Utils.GetQuestBasicInfo(95991)
    local bDung = Utils.GetQuestBasicInfo(95646)
    assert_true(bElite and bElite.isElite == true, "GetQuestBasicInfo preserves ForeverCatalog Elite tag when level is known")
    assert_true(bDung and bDung.isDungeon == true, "GetQuestBasicInfo preserves ForeverCatalog Dungeon tag when level is known")

    local mockLog4J = {
        { title = "Stranglethorn Vale", level = 0, isHeader = true },
        { title = "Log Elite Probe", level = 41, tag = "Elite", questID = 990101 },
    }
    _G.GetNumQuestLogEntries = function() return #mockLog4J, #mockLog4J end
    _G.GetQuestLogTitle = function(idx)
        local q = mockLog4J[idx]
        if not q then return nil end
        return q.title, q.level, q.tag, q.isHeader, false, false, false, q.questID
    end
    _G.GetQuestLogIndexByID = function(qid)
        for i, q in ipairs(mockLog4J) do if q.questID == qid then return i end end
        return 0
    end
    _G.C_QuestLog.GetLogIndexForQuestID = _G.GetQuestLogIndexByID
    _G.C_QuestLog.GetInfo = function(idx)
        local q = mockLog4J[idx]
        if not q then return nil end
        return { title = q.title, level = q.level, isHeader = q.isHeader, questID = q.questID, questTag = q.tag, isElite = (q.tag == "Elite") }
    end
    Utils.ClearQuestBasicInfoCache()
    local bLogElite = Utils.GetQuestBasicInfo(990101)
    local bTagGroup = Utils.GetQuestBasicInfo(990102)
    assert_true(bLogElite and bLogElite.isElite == true, "GetQuestBasicInfo scans QuestLog Elite tag even when title & level are known")
    assert_true(bTagGroup and bTagGroup.isGroup == true, "GetQuestBasicInfo resolves Group tag from C_QuestLog.GetQuestTagInfo")

    -- 2. Bug 2: QuestFrameProgressPanel must block IsActiveOfferQuest
    if not _G.QuestFrameProgressPanel then
        local shown = false
        _G.QuestFrameProgressPanel = { Show = function() shown = true end, Hide = function() shown = false end, IsShown = function() return shown end }
    end
    local savedProgShown = _G.QuestFrameProgressPanel:IsShown()
    QuestFrame:Show()
    _G.QuestFrameProgressPanel:Show()
    assert_true(Utils.IsActiveOfferQuest(990101, "Log Elite Probe") == false, "IsActiveOfferQuest returns false while QuestFrameProgressPanel is open")
    if not savedProgShown then _G.QuestFrameProgressPanel:Hide() end
    if not origQFShown then QuestFrame:Hide() end

    -- 3. Bug 3: Dungeon/Elite/Group monotonic curve (+5 <= +3 <= +0 <= -1) and Gray Standalone Dungeon penalty
    _G.UnitLevel = function() return 41 end
    _G.UnitClass = function() return "ROGUE", "ROGUE" end
    local qCurXP, qCurMoney, qCurLvl, qCurTag = 6600, 5000, 41, nil
    _G.GetQuestLogRewardXP = function() return qCurXP end
    _G.C_QuestLog.GetQuestRewardXP = function() return qCurXP end
    _G.GetQuestLogRewardMoney = function() return qCurMoney end
    _G.C_QuestLog.GetQuestRewardMoney = function() return qCurMoney end
    _G.C_QuestLog.GetQuestObjectives = function() return { { text = "0/1 Boss slain", type = "monster", finished = false } } end
    _G.GetNumQuestLogChoices = function() return 0 end
    _G.GetNumQuestLogRewards = function() return 0 end
    _G.GetNumQuestLeaderBoards = function() return 1 end
    _G.GetQuestLogLeaderBoard = function() return "0/1 Boss", "monster", false end
    _G.C_QuestLog.GetQuestDifficultyLevel = function() return qCurLvl end
    _G.C_QuestLog.GetQuestTagInfo = function() return qCurTag end
    _G.IsOnQuest = function(qid)
        for _, q in ipairs(mockLog4J) do if q.questID == qid then return true end end
        return false
    end
    _G.C_QuestLog.IsOnQuest = _G.IsOnQuest

    local function evalDelta(tagTbl, tagText, xp, delta)
        local qid = 990500 + delta + 20
        qCurLvl = 41 + delta
        qCurXP = xp
        qCurTag = tagTbl
        mockLog4J = {
            { title = "Stranglethorn Vale", level = 0, isHeader = true },
            { title = "Curve Quest " .. delta, level = qCurLvl, tag = tagText, questID = qid },
        }
        resync()
        return Engine.CalculateWorth(qid)
    end

    local dRed, dRedB   = evalDelta({ tagID = 81, tagName = "Dungeon" }, "Dungeon", 6600, 5)
    local dOrg, dOrgB   = evalDelta({ tagID = 81, tagName = "Dungeon" }, "Dungeon", 6600, 3)
    local dYel, dYelB   = evalDelta({ tagID = 81, tagName = "Dungeon" }, "Dungeon", 6600, 0)
    local dGrn, dGrnB   = evalDelta({ tagID = 81, tagName = "Dungeon" }, "Dungeon", 6600, -1)
    local dGray, dGrayB = evalDelta({ tagID = 81, tagName = "Dungeon" }, "Dungeon", 6600, -10)
    assert_true(dRed <= dOrg and dOrg <= dYel and dYel <= dGrn,
        string.format("Dungeon worth monotonically eases as level delta drops: red=%.2f <= org=%.2f <= yel=%.2f <= grn=%.2f", dRed, dOrg, dYel, dGrn))
    assert_true(dGray <= 0.15 and dGrayB.isLowValue == true and dGrayB.isHard == false,
        string.format("Gray standalone dungeon quest penalized as Low Value (worth=%.2f, isLow=%s, isHard=%s)", dGray, tostring(dGrayB.isLowValue), tostring(dGrayB.isHard)))

    local gYel, gYelB = evalDelta({ tagID = 1, tagName = "Group" }, "Group", 4500, 0)
    local gOrg        = evalDelta({ tagID = 1, tagName = "Group" }, "Group", 4500, 3)
    assert_true(gYelB.isHard == true and gYelB.isBankable == true and gOrg <= gYel,
        string.format("Group quest marked Hard/Bankable at delta 0 and non-inverted at +3 (org=%.2f <= yel=%.2f)", gOrg, gYel))

    -- 4. Bug 4: Custom v8 user weights are preserved instead of silently overwritten
    local savedWeights4J = {
        difficulty = addonTable.db.weights.difficulty, reward = addonTable.db.weights.reward,
        chain = addonTable.db.weights.chain, classFit = addonTable.db.weights.classFit, density = addonTable.db.weights.density,
    }
    addonTable.db.version = 8
    addonTable.db.weights = { difficulty = 0.10, reward = 0.35, chain = 0.25, classFit = 0.20, density = 0.10 }
    local gearLink = "|cff1eff00|Hitem:99001::::::::41|h[Test Belt]|h|r"
    _G.GetItemInfo = function(l)
        if l == gearLink then return "Test Belt", l, 2, 41, 41, "Armor", "Leather", 1, "INVTYPE_WAIST", 134400, 5000, 4, 2 end
        return origGetItemInfo(l)
    end
    _G.GetItemStats = function(l)
        if l == gearLink then return { ITEM_MOD_AGILITY_SHORT = 10 } end
        return origGetItemStats and origGetItemStats(l) or {}
    end
    _G.GetInventoryItemLink = function() return nil end
    _G.GetNumQuestLogChoices = function() return 1 end
    _G.GetQuestLogChoiceInfo = function() return "Test Belt", 134400, 1, 2, true, gearLink end
    _G.GetQuestLogItemLink = function(kind) if kind == "choice" then return gearLink end return nil end
    qCurLvl = 41; qCurXP = 2100; qCurTag = nil
    mockLog4J = { { title = "Stranglethorn Vale", level = 0, isHeader = true }, { title = "Weight Probe", level = 41, questID = 990601 } }
    resync()
    local _, bCustomW = Engine.CalculateWorth(990601)
    assert_true(bCustomW.wD > 0.05, "Custom v8 user Difficulty weight (0.10) is preserved instead of reset: wD=" .. tostring(bCustomW.wD))
    addonTable.db.weights = savedWeights4J
    _G.GetNumQuestLogChoices = origGetNumChoices
    _G.GetQuestLogChoiceInfo = origGetChoiceInfo
    _G.GetQuestLogItemLink = origGetItemLink
    _G.GetItemInfo = origGetItemInfo
    _G.GetItemStats = origGetItemStats
    _G.GetInventoryItemLink = origGetInvLink

    -- 5. Bug 5: Reward monotonic across benchmark cliff + L60 Low Gold label
    local minDrop = 0
    local prevRew = nil
    qCurMoney = 80000; qCurLvl = 41; qCurTag = nil
    mockLog4J = { { title = "Stranglethorn Vale", level = 0, isHeader = true }, { title = "Reward Cliff", level = 41, questID = 990701 } }
    for xp = 500, 3200, 50 do
        qCurXP = xp
        resync()
        local r = Scores.CalculateReward(990701)
        if prevRew and r < prevRew - 0.0001 then
            minDrop = minDrop + 1
        end
        prevRew = r
    end
    assert_eq(minDrop, 0, "CalculateReward never decreases as XP increases across the 0.70..1.00 benchmark zone")

    _G.UnitLevel = function() return 60 end
    qCurXP = 0; qCurMoney = 100
    resync()
    local r60, det60 = Scores.CalculateReward(990701)
    assert_true(r60 < 0.30 and det60.reason == "Low Gold", "Level 60 low-money reward reports reason 'Low Gold' instead of 'Low XP': " .. tostring(det60.reason))

    -- 6. Bug 6: ClassFit Quiver & Relic class checks
    _G.UnitLevel = function() return 40 end
    local quiverLink = "|cffffffff|Hitem:99010::::::::40|h[Heavy Quiver]|h|r"
    local libramLink = "|cff0070dd|Hitem:99011::::::::55|h[Libram of Hope]|h|r"
    local idolLink   = "|cff0070dd|Hitem:99012::::::::55|h[Idol of Ferocity]|h|r"
    _G.GetItemInfo = function(l)
        if l == quiverLink then return "Heavy Quiver", l, 2, 40, 1, "Quiver", "Quiver", 1, "INVTYPE_QUIVER", 134400, 100, 11, 2
        elseif l == libramLink then return "Libram of Hope", l, 3, 60, 55, "Armor", "Librams", 1, "INVTYPE_RELIC", 134400, 1000, 4, 7
        elseif l == idolLink then return "Idol of Ferocity", l, 3, 60, 55, "Armor", "Idols", 1, "INVTYPE_RELIC", 134400, 1000, 4, 8 end
        return origGetItemInfo(l)
    end
    _G.GetContainerNumSlots = function() return 8 end
    if _G.C_Container then _G.C_Container.GetContainerNumSlots = function() return 8 end end
    _G.GetInventoryItemLink = function() return nil end
    local chosenLink = quiverLink
    _G.GetNumQuestLogChoices = function() return 1 end
    _G.GetQuestLogChoiceInfo = function() return "Item", 134400, 1, 2, true, chosenLink end
    _G.GetQuestLogItemLink = function(kind) if kind == "choice" then return chosenLink end return nil end
    mockLog4J = { { title = "Stranglethorn Vale", level = 0, isHeader = true }, { title = "Class Item", level = 40, questID = 990801 } }

    _G.UnitClass = function() return "MAGE", "MAGE" end; resync()
    local fMageQuiver = Scores.CalculateClassFit(990801)
    assert_true(fMageQuiver <= 0.06, "Non-Hunter (Mage) rejects Quiver as unusable: " .. tostring(fMageQuiver))

    _G.UnitClass = function() return "HUNTER", "HUNTER" end; resync()
    local fHunterQuiver = Scores.CalculateClassFit(990801)
    assert_true(fHunterQuiver >= 0.85, "Hunter evaluates Quiver as bag upgrade: " .. tostring(fHunterQuiver))

    _G.UnitClass = function() return "WARRIOR", "WARRIOR" end; chosenLink = libramLink; resync()
    local fWarLibram = Scores.CalculateClassFit(990801)
    chosenLink = idolLink; resync()
    local fWarIdol = Scores.CalculateClassFit(990801)
    assert_true(fWarLibram <= 0.06 and fWarIdol <= 0.06, "Warrior rejects Paladin Libram and Druid Idol: " .. tostring(fWarLibram) .. "/" .. tostring(fWarIdol))

    _G.UnitClass = function() return "PALADIN", "PALADIN" end; chosenLink = libramLink; resync()
    local fPalLibram = Scores.CalculateClassFit(990801)
    assert_true(fPalLibram >= 0.50, "Paladin retains positive fit for Libram: " .. tostring(fPalLibram))

    -- 7. Bug 7 & Solution C: InvalidateDensityCache rescans immediately at GetTime() < 5.0
    -- and counts the zone's available good quests (not just the player's Quest Log) without penalizing 1-quest starts
    _G.GetTime = function() return 0.05 end
    mockLog4J = {
        { title = "Stranglethorn Vale", level = 0, isHeader = true },
        { title = "Q1", level = 40, questID = 990901 },
    }
    Scores.InvalidateDensityCache()
    local dOne, dOneDet = Scores.CalculateDensity(990901)
    mockLog4J = {
        { title = "Stranglethorn Vale", level = 0, isHeader = true },
        { title = "Q1", level = 40, questID = 990901 },
        { title = "Q2", level = 40, questID = 990902 },
        { title = "Q3", level = 40, questID = 990903 },
    }
    Scores.InvalidateDensityCache()
    local dThree, dThreeDet = Scores.CalculateDensity(990901)
    assert_true(dOne >= 0.85 and dOneDet.inLogCount == 1 and (dOneDet.zoneGoodCount or 0) >= 6 and dThree >= 0.85 and dThreeDet.inLogCount == 3,
        string.format("InvalidateDensityCache rescans immediately at GetTime()<5 & counts zone good quests: 1Q=%.2f (inLog=%s, zoneGood=%s) -> 3Q=%.2f (inLog=%s)",
            dOne, tostring(dOneDet.inLogCount), tostring(dOneDet.zoneGoodCount), dThree, tostring(dThreeDet.inLogCount)))

    -- Restore globals cleanly
    _G.UnitLevel = origUnitLevel
    _G.UnitClass = origUnitClass
    _G.C_QuestLog.GetTitleForQuestID = origGetTitle
    _G.C_QuestLog.GetQuestDifficultyLevel = origGetDiff
    _G.C_QuestLog.GetQuestTagInfo = origGetTag
    _G.GetNumQuestLogEntries = origGetNumEntries
    _G.GetQuestLogTitle = origGetQLogTitle
    _G.GetQuestLogIndexByID = origGetQLogIdx
    _G.C_QuestLog.GetLogIndexForQuestID = origCGetQLogIdx
    _G.C_QuestLog.GetInfo = origGetInfo
    _G.GetQuestLogRewardXP = origGetXP
    _G.C_QuestLog.GetQuestRewardXP = origCGetXP
    _G.GetQuestLogRewardMoney = origGetMoney
    _G.C_QuestLog.GetQuestRewardMoney = origCGetMoney
    _G.C_QuestLog.GetQuestObjectives = origCGetObjs
    _G.GetNumQuestLogChoices = origGetNumChoices
    _G.GetQuestLogChoiceInfo = origGetChoiceInfo
    _G.GetQuestLogItemLink = origGetItemLink
    _G.GetNumQuestLogRewards = origGetNumRewards
    _G.GetNumQuestLeaderBoards = origGetNumLB
    _G.GetQuestLogLeaderBoard = origGetLB
    _G.IsOnQuest = origIsOnQuest
    _G.C_QuestLog.IsOnQuest = origCIsOnQuest
    _G.GetItemInfo = origGetItemInfo
    _G.GetItemStats = origGetItemStats
    _G.GetInventoryItemLink = origGetInvLink
    _G.GetContainerNumSlots = origGetContSlots
    if _G.C_Container then _G.C_Container.GetContainerNumSlots = origCContSlots end
    _G.GetTime = origGetTime
    _G.QuestFrameProgressPanel = origPP
    if not origGPShown and QuestFrameGreetingPanel then QuestFrameGreetingPanel:Hide() end
    resync()
end)()

-- ----------------------------------------------------------------------------
-- Phase 4K: Meta Quest Indicator & Wowhead Catalog Regressions
-- ----------------------------------------------------------------------------
print("\n[Phase 4K] Meta Quest Indicator, Chain Inheritance & Zone Tracking:")
;(function()
    local Data = addonTable.Data
    local Engine = addonTable.Engine
    local Utils = addonTable.Utils
    local UI = addonTable.UI
    local origLvl = mockPlayerState.level
    local origFaction = mockPlayerState.faction
    local origClass = mockPlayerState.class
    local origShowMeta = addonTable.db and addonTable.db.showMetaIndicator
    local origCompleted = _G.C_QuestLog.IsQuestFlaggedCompleted
    local origQuestDB6502 = mockQuestDB[6502]
    local origQuestDB778 = mockQuestDB[778]
    local origQuestDB99911 = mockQuestDB[99911]
    local origOfferID = currentOfferQuestID
    local origOfferTitle = currentOfferTitle
    local origOfferXP = currentOfferXP
    local origOfferMoney = currentOfferMoney
    local origMapShown = WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown()
    local origMapID = WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()

    local function restoreState()
        mockPlayerState.level = origLvl
        mockPlayerState.faction = origFaction
        mockPlayerState.class = origClass
        if addonTable.db then addonTable.db.showMetaIndicator = (origShowMeta ~= false) end
        _G.C_QuestLog.IsQuestFlaggedCompleted = origCompleted
        mockQuestDB[6502] = origQuestDB6502
        mockQuestDB[778] = origQuestDB778
        mockQuestDB[99911] = origQuestDB99911
        currentOfferQuestID = origOfferID
        currentOfferTitle = origOfferTitle
        currentOfferXP = origOfferXP
        currentOfferMoney = origOfferMoney
        if WorldMapFrame then
            if origMapID and WorldMapFrame.SetMapID then WorldMapFrame:SetMapID(origMapID) end
            if origMapShown then WorldMapFrame:Show() else WorldMapFrame:Hide() end
        end
        addonTable.Player.Update()
        Engine.InvalidateCache()
        Data.InvalidateMetaMemo()
    end

    -- 1. Direct Classic & WoW Forever Meta Catalog checks
    local mc = Data.GetMetaQuestInfo(7848)
    assert_not_nil(mc, "MC Attunement (7848) resolved as Meta Quest")
    assert_eq(mc.tag, "KEY", "MC Attunement (7848) tagged KEY")
    assert_true(mc.perm == true, "MC Attunement marked permanent")

    local bwl = Data.GetMetaQuestInfo(7761)
    assert_not_nil(bwl, "BWL Attunement (7761) resolved as Meta Quest")
    assert_eq(bwl.tag, "KEY", "BWL Attunement tagged KEY")

    local naxx = Data.GetMetaQuestInfo(9121)
    assert_not_nil(naxx, "Naxxramas Attunement (9121) resolved as Meta Quest")
    assert_eq(naxx.tag, "KEY", "Naxxramas Attunement tagged KEY")

    local ony = Data.GetMetaQuestInfo(6502)
    assert_not_nil(ony, "Onyxia Drakefire Amulet (6502) resolved as Meta Quest")
    assert_eq(ony.tag, "KEY", "Drakefire Amulet upgraded to KEY (not mere BIS)")

    local dmHun = Data.GetMetaQuestInfo(7503)
    assert_not_nil(dmHun, "Dire Maul Hunter class book (7503) resolved as Meta Quest")
    assert_eq(dmHun.reqClass, "HUNTER", "7503 restricted to HUNTER class")

    local mountQ = Data.GetMetaQuestInfo(99210)
    assert_not_nil(mountQ, "WoW Forever epic mount quest (99210) resolved")
    assert_eq(mountQ.tag, "MOUNT", "99210 tagged MOUNT")

    local bagQ = Data.GetMetaQuestInfo(79192)
    assert_not_nil(bagQ, "Sturdy Lunchbox (79192) resolved")
    assert_eq(bagQ.tag, "BAG", "79192 tagged BAG")

    local dmCustom = Data.GetMetaQuestInfo(92753)
    assert_not_nil(dmCustom, "Forever Destruction in Deadmines (92753) resolved")
    assert_eq(dmCustom.zone, "The Deadmines", "92753 mapped to The Deadmines")

    -- Anti-noise exclusions: consumable/false keys and non-class reagent/prof spells must NOT be directly Meta-listed
    assert_eq(Data.MetaQuests[2969], nil, "Bamboo Cage Key (2969) excluded from Data.MetaQuests")
    assert_eq(Data.MetaQuests[3825], nil, "Gor'tesh Head (3825) excluded from Data.MetaQuests")
    assert_eq(Data.MetaQuests[93680], nil, "Alterac Key to the City (93680) excluded from direct Data.MetaQuests")
    assert_eq(Data.MetaQuests[2203], nil, "Badlands Reagent Run II (2203) excluded (not a Class Spell)")
    local mageSpell = Data.GetMetaQuestInfo(7463)
    assert_true(mageSpell and mageSpell.tag == "CLASS" and mageSpell.reqClass == "MAGE", "Arcane Refreshment (7463) properly scoped to MAGE")

    -- 2. Chain inheritance from KnownChains downstream Meta finales
    local defias1 = Data.GetMetaQuestInfo(65)
    assert_not_nil(defias1, "Defias Brotherhood Step 1 (65) inherits Meta status from finale")
    assert_true(defias1.isChainStep == true, "Quest 65 marked isChainStep = true")
    assert_eq(defias1.leadsTo, 166, "Quest 65 inherits from finale 166")

    local ww1 = Data.GetMetaQuestInfo(1711)
    assert_not_nil(ww1, "Whirlwind Weapon Step 1 (1711) inherits Meta status from 1715")
    assert_true(ww1.isChainStep == true, "Quest 1711 marked isChainStep = true")

    local fStep1 = Data.GetMetaQuestInfo(92742)
    assert_not_nil(fStep1, "Forever Toxic Soil Step 1 (92742) inherits Meta status from 92753")
    assert_eq(fStep1.leadsTo, 92753, "Quest 92742 inherits from Destruction in Deadmines (92753)")

    -- 3. Engine protection at Level 60 + Utils.FormatBadge toggle + CleanQuestTitle round-trip
    mockPlayerState.level = 60
    addonTable.Player.Update()
    mockQuestDB[778] = { title = "This Is Going to Be Hard", level = 45, xp = 3900, money = 5000 }
    mockQuestDB[99911] = { title = "Standalone Outleveled Errand", level = 45, xp = 1200, money = 1000 }
    Engine.InvalidateCache()

    local mWorth, mBreak = Engine.CalculateWorth(778)
    local nWorth, nBreak = Engine.CalculateWorth(99911)
    assert_true(mBreak and mBreak.isMeta == true, "Engine CalculateWorth exposes breakdown.isMeta = true for 778")
    assert_true(mBreak.isLowValue == false, "Gray permanent Meta quest Nifty Stopwatch (778) is NOT marked Low Value")
    assert_true(mWorth >= 0.40, "Protected Meta quest retains meaningful worth (" .. tostring(mWorth) .. " >= 0.40)")
    assert_true(nBreak and nBreak.isLowValue == true and nWorth <= 0.20, "Non-Meta outleveled standalone quest still gets Low Value crush")

    addonTable.db.showMetaIndicator = false
    local hiddenMetaWorth, hiddenMetaBreak = Engine.CalculateWorth(778)
    assert_true(hiddenMetaBreak.isMeta == true, "Cached Engine breakdown preserves isMeta=true even when badge hidden")
    local badgeHidden = Utils.FormatBadge(hiddenMetaWorth, false, false, false, false, true)
    assert_true(string.find(badgeHidden, "UI-RaidTargetingIcon_1", 1, true) == nil, "FormatBadge hides star icon when showMetaIndicator == false")

    addonTable.db.showMetaIndicator = true
    local badgeShown = Utils.FormatBadge(mWorth, false, false, false, false, true)
    assert_true(string.find(badgeShown, "UI-RaidTargetingIcon_1", 1, true) ~= nil, "FormatBadge prefixes gold star texture when showMetaIndicator == true")
    local cleanRoundTrip = Utils.CleanQuestTitle(badgeShown .. " This Is Going to Be Hard")
    assert_eq(cleanRoundTrip, "This Is Going to Be Hard", "CleanQuestTitle strips both Meta Star icon and Worth percentage cleanly")

    -- 4. Zone Meta Summary filtering (Faction, Class, Live Completed Check) & UI Surfaces
    local hUbrs = Data.GetZoneMetaQuests("Upper Blackrock Spire", "Horde", "WARRIOR")
    local aUbrs = Data.GetZoneMetaQuests("Upper Blackrock Spire", "Alliance", "WARRIOR")
    assert_true(hUbrs and hUbrs.total >= 4, "Horde UBRS has >= 4 eligible Meta quests: " .. tostring(hUbrs and hUbrs.total))
    local found6502InHorde, found6602InHorde = false, false
    for _, m in ipairs(hUbrs.items) do
        if m.questID == 6502 then found6502InHorde = true end
        if m.questID == 6602 then found6602InHorde = true end
    end
    assert_true(not found6502InHorde and found6602InHorde, "UBRS Horde filter includes 6602 and excludes Alliance 6502")
    assert_true(aUbrs and aUbrs.total >= 4, "Alliance UBRS resolves cleanly")

    local mageDm = Data.GetZoneMetaQuests("Dire Maul", "Alliance", "MAGE")
    local has7500, has7503 = false, false
    for _, m in ipairs(mageDm.items) do
        if m.questID == 7500 then has7500 = true end
        if m.questID == 7503 then has7503 = true end
    end
    assert_true(has7500 and not has7503, "Dire Maul Mage filter includes 7500 Mage Book and excludes 7503 Hunter Book")

    -- Live completion deduction test
    _G.C_QuestLog.IsQuestFlaggedCompleted = function(qID) return qID == 7761 end
    local afterDone = Data.GetZoneMetaQuests("Upper Blackrock Spire", "Horde", "WARRIOR")
    assert_eq(afterDone.done, 1, "Marking 7761 completed increments zone Meta done count to 1")
    assert_eq(afterDone.remaining, hUbrs.remaining - 1, "Marking 7761 completed reduces remaining count by 1")

    -- World Map Banner + Zone Tooltip + Quest Tooltip + /qw meta command smoke check
    _G.C_QuestLog.IsQuestFlaggedCompleted = origCompleted
    mockPlayerState.faction = "Horde"
    mockPlayerState.class = "WARRIOR"
    addonTable.Player.Update()
    if WorldMapFrame then
        WorldMapFrame:Show()
        local badlandsInfo = Data.GetZoneInfo and Data.GetZoneInfo("Badlands")
        if badlandsInfo and badlandsInfo.mapID and WorldMapFrame.SetMapID then
            WorldMapFrame:SetMapID(badlandsInfo.mapID)
        end
        UI.UpdateWorldMapBanner()
        local bFrame = _G["WorthItWorldMapBanner"]
        if bFrame and bFrame.Text and bFrame.data then
            local bText = bFrame.Text:GetText() or ""
            assert_true(string.find(bText, "Meta", 1, true) ~= nil, "WorldMap banner shows Meta count for Badlands (Nifty Stopwatch)")
            local onEnter = bFrame:GetScript("OnEnter")
            if onEnter then
                GameTooltip:ClearLines()
                onEnter(bFrame)
                local foundMetaLeft = false
                for _, line in ipairs(GameTooltip.lines or {}) do
                    if string.find(line.left or "", addonTable.L["META_LEFT_IN_ZONE"] or "Meta Quests Left", 1, true) then
                        foundMetaLeft = true
                    end
                end
                assert_true(foundMetaLeft, "WorldMap banner tooltip displays Meta Quests Left section")
            end
        end
    end

    GameTooltip:ClearLines()
    UI.ShowQuestTooltip(GameTooltip, 778)
    local foundMetaTip = false
    for _, line in ipairs(GameTooltip.lines or {}) do
        if string.find(line.left or "", addonTable.L["META_QUEST_LABEL"] or "Meta Quest", 1, true) then
            foundMetaTip = true
        end
    end
    assert_true(foundMetaTip, "Quest GameTooltip renders curated Meta Quest label & reason for 778")

    local slashFn = _G.SlashCmdList and (_G.SlashCmdList["QUESTWORTH"] or _G.SlashCmdList["WORTHIT"])
    assert_not_nil(slashFn, "Slash command handler available for /qw meta")
    local okMetaCmd = pcall(slashFn, "meta Badlands")
    local okToggleCmd = pcall(slashFn, "meta toggle")
    local okToggleBack = pcall(slashFn, "meta toggle")
    assert_true(okMetaCmd and okToggleCmd and okToggleBack, "/qw meta [zone|toggle] executes cleanly without errors")

    restoreState()
end)()

-- ----------------------------------------------------------------------------
-- Phase 4L: Dynamic Multi-Character / Multi-Level / Multi-Race Regressions
-- ----------------------------------------------------------------------------
print("\n[Phase 4L] Dynamic Multi-Alt Context, Level 3 Progression, Tie-Breaking & Icon Reset:")
;(function()
    local Engine = addonTable.Engine
    local Player = addonTable.Player
    local UI = addonTable.UI
    local DB = addonTable.DB

    local origLvl = mockPlayerState.level
    local origCls = mockPlayerState.class
    local origClsTok = mockPlayerState.classToken
    local origRace = mockPlayerState.race
    local origRaceTok = mockPlayerState.raceToken
    local origFac = mockPlayerState.faction
    local origFilter = addonTable.db and addonTable.db.zoneAdvisorFilter
    local origAdvShown = addonTable.db and addonTable.db.showZoneAdvisor
    local origMapShown = WorldMapFrame and WorldMapFrame:IsShown()
    local origGetBestMap = _G.C_Map.GetBestMapForUnit
    local origGetMapInfo = _G.C_Map.GetMapInfo
    local origUnitName = _G.UnitName
    local origGetRealmName = _G.GetRealmName

    local function restoreAll()
        mockPlayerState.level = origLvl
        mockPlayerState.class = origCls
        mockPlayerState.classToken = origClsTok
        mockPlayerState.race = origRace
        mockPlayerState.raceToken = origRaceTok
        mockPlayerState.faction = origFac
        _G.UnitName = origUnitName
        _G.GetRealmName = origGetRealmName
        _G.C_Map.GetBestMapForUnit = origGetBestMap
        _G.C_Map.GetMapInfo = origGetMapInfo
        if addonTable.db then
            addonTable.db.zoneAdvisorFilter = origFilter
            addonTable.db.showZoneAdvisor = origAdvShown
        end
        if WorldMapFrame then
            if origMapShown then WorldMapFrame:Show() else WorldMapFrame:Hide() end
        end
        Player._pendingMinLevel = nil
        Player.Update()
        Engine.InvalidateCache()
    end

    -- 1. Level 3 Human Paladin in Elwynn Forest (reproducing exact screenshot scenario)
    local curName, curRealm = "LowbieAlt", "Forever"
    _G.UnitName = function(u) return curName end
    _G.GetRealmName = function() return curRealm end
    _G.C_Map.GetBestMapForUnit = function() return 1429 end -- Elwynn Forest
    _G.C_Map.GetMapInfo = function(id)
        if id == 1429 then return { mapID = 1429, name = "Elwynn Forest", mapType = 3 } end
        return origGetMapInfo(id)
    end

    mockPlayerState.level = 3
    mockPlayerState.class = "Paladin"
    mockPlayerState.classToken = "PALADIN"
    mockPlayerState.race = "Human"
    mockPlayerState.raceToken = "Human"
    mockPlayerState.faction = "Alliance"
    -- Test auto-resync WITHOUT manually calling Player.Update()
    assert_eq(Player.GetLevel(), 3, "Player.GetLevel dynamically detects level 3 alt without manual Update()")
    assert_eq(Player.GetClass(), "PALADIN", "Player.GetClass dynamically detects PALADIN")

    local wf3 = Engine.CalculateWorldMapZoneWorth("Westfall")
    local rr3 = Engine.CalculateWorldMapZoneWorth("Redridge Mountains")
    local dw3 = Engine.CalculateWorldMapZoneWorth("Duskwood")
    local wpl3 = Engine.CalculateWorldMapZoneWorth("Western Plaguelands")
    local epl3 = Engine.CalculateWorldMapZoneWorth("Eastern Plaguelands")
    local dp3 = Engine.CalculateWorldMapZoneWorth("Deadwind Pass")
    assert_true(wf3.worth > rr3.worth, string.format("L3 Paladin Westfall (%.0f%%) strictly outranks Redridge (%.0f%%)", wf3.worth * 100, rr3.worth * 100))
    assert_true(rr3.worth > dw3.worth, string.format("L3 Paladin Redridge (%.0f%%) strictly outranks Duskwood (%.0f%%)", rr3.worth * 100, dw3.worth * 100))
    assert_true(dw3.worth > wpl3.worth, string.format("L3 Paladin Duskwood (%.0f%%) strictly outranks WPL 51-58 (%.0f%%)", dw3.worth * 100, wpl3.worth * 100))
    assert_true(wf3.worth > epl3.worth and wf3.worth > dp3.worth, "L3 Paladin 10-20 Westfall strictly beats 53-60 EPL and Deadwind Pass")
    assert_eq(wpl3.classModifier, 0, "Paladin receives 0 undead synergy in WPL while 48 levels underleveled")

    -- 2. Stale Dungeon Swirl Atlas reset test (Dungeons tab -> All tab) + #1 Elwynn Forest tie-break
    WorldMapFrame:Show()
    addonTable.db.showZoneAdvisor = true
    mockPlayerState.level = 22 -- Populate rows 1..N on Dungeons tab first
    Player.Update()
    addonTable.db.zoneAdvisorFilter = "DUNGEONS"
    UI.ToggleZoneAdvisor(true)
    UI.UpdateZoneAdvisor()
    local dungRow1 = _G["WorthItAdvisorRow1"]
    assert_true(dungRow1 and dungRow1:IsShown() and dungRow1.isDungeon, "Dungeons tab populates row 1 with a dungeon")

    -- Switch character down to L3 Human Paladin in Elwynn Forest & switch back to ALL tab
    mockPlayerState.level = 3
    addonTable.db.zoneAdvisorFilter = "ALL"
    UI.UpdateZoneAdvisor()
    local row1 = _G["WorthItAdvisorRow1"]
    local row2 = _G["WorthItAdvisorRow2"]
    assert_not_nil(row1 and row1.data, "Advisor row 1 rendered for L3 Human Paladin")
    assert_eq(row1.data.zoneName, "Elwynn Forest", "#1 zone for L3 Human in Elwynn Forest is Elwynn Forest (not alphabetical Dun Morogh)")
    assert_eq(row1.ContinentIcon and row1.ContinentIcon:GetTexture(), "Interface\\TargetingFrame\\UI-PVP-Alliance", "Row 1 ContinentIcon cleanly resets away from stale Dungeon atlas to EK Alliance Crest")
    assert_eq(row1.ContinentIcon and row1.ContinentIcon:GetAtlas(), nil, "Row 1 ContinentIcon cleared active Atlas completely")
    assert_not_nil(row2 and row2.data, "Advisor row 2 rendered cleanly")

    -- Verify Horde Undead L3 Priest in Tirisfal Glades dynamically gets #1 Tirisfal Glades & clean progression
    curName = "HordeAlt"
    mockPlayerState.class = "Priest"
    mockPlayerState.classToken = "PRIEST"
    mockPlayerState.race = "Scourge"
    mockPlayerState.raceToken = "Scourge"
    mockPlayerState.faction = "Horde"
    _G.C_Map.GetBestMapForUnit = function() return 1420 end -- Tirisfal Glades
    _G.C_Map.GetMapInfo = function(id)
        if id == 1420 then return { mapID = 1420, name = "Tirisfal Glades", mapType = 3 } end
        return origGetMapInfo(id)
    end
    UI.UpdateZoneAdvisor()
    local hRow1 = _G["WorthItAdvisorRow1"]
    assert_eq(hRow1 and hRow1.data and hRow1.data.zoneName, "Tirisfal Glades", "L3 Undead Priest in Tirisfal dynamically gets #1 Tirisfal Glades")
    assert_eq(hRow1.ContinentIcon and hRow1.ContinentIcon:GetTexture(), "Interface\\TargetingFrame\\UI-PVP-Alliance", "Tirisfal (EK) shows EK crest")
    local sf3 = Engine.CalculateWorldMapZoneWorth("Silverpine Forest")
    local eplH3 = Engine.CalculateWorldMapZoneWorth("Eastern Plaguelands")
    assert_true(sf3.worth > eplH3.worth, "L3 Undead Priest 10-20 Silverpine strictly beats 53-60 EPL")

    -- Verify Tauren Druid L3 in Mulgore gets Kalimdor crest & #1 Mulgore
    mockPlayerState.class = "Druid"
    mockPlayerState.classToken = "DRUID"
    mockPlayerState.race = "Tauren"
    mockPlayerState.raceToken = "Tauren"
    _G.C_Map.GetBestMapForUnit = function() return 1412 end -- Mulgore
    _G.C_Map.GetMapInfo = function(id)
        if id == 1412 then return { mapID = 1412, name = "Mulgore", mapType = 3 } end
        return origGetMapInfo(id)
    end
    UI.UpdateZoneAdvisor()
    local tRow1 = _G["WorthItAdvisorRow1"]
    assert_eq(tRow1 and tRow1.data and tRow1.data.zoneName, "Mulgore", "L3 Tauren in Mulgore gets #1 Mulgore")
    assert_eq(tRow1.ContinentIcon and tRow1.ContinentIcon:GetTexture(), "Interface\\TargetingFrame\\UI-PVP-Horde", "Mulgore (Kalimdor) displays Kalimdor crest cleanly")

    -- 3. Per-character completedDungeons isolation across Main vs Alt
    curName = "MainSixty"
    mockPlayerState.level = 60
    mockPlayerState.faction = "Alliance"
    mockPlayerState.race = "Human"
    mockPlayerState.raceToken = "Human"
    mockPlayerState.classToken = "WARRIOR"
    DB.SetDungeonCompleted("The Deadmines", true)
    assert_true(DB.IsDungeonCompleted("The Deadmines"), "Main character sees The Deadmines marked completed")

    curName = "BrandNewAlt"
    mockPlayerState.level = 19
    assert_true(not DB.IsDungeonCompleted("The Deadmines"), "Brand new Alt on same account does NOT inherit Main's completed dungeons")
    local dmAlt = Engine.CalculateWorldMapZoneWorth("The Deadmines")
    assert_true(dmAlt and not dmAlt.isCompletedDungeon, "Alt evaluates The Deadmines dynamically as fresh/incomplete")

    curName = "MainSixty"
    DB.SetDungeonCompleted("The Deadmines", false) -- cleanup

    -- 4. PLAYER_LEVEL_UP(arg1) immediate update even before UnitLevel() increments
    curName = "LevelingAlt"
    mockPlayerState.level = 3
    Player.Update()
    onEvent(eventFrame, "PLAYER_LEVEL_UP", 4)
    assert_eq(Player.GetLevel(), 4, "PLAYER_LEVEL_UP(4) updates Player.level to 4 immediately even if UnitLevel lags at 3")
    mockPlayerState.level = 4
    assert_eq(Player.GetLevel(), 4, "Player.GetLevel remains stable at 4 once UnitLevel catches up")

    -- 5. Full 270-combination Matrix (10 Races x 9 Classes x Levels 1,3,5) Zone Bracket Monotonicity
    local allClasses = { "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }
    local raceMatrix = {
        { race = "Human",    fac = "Alliance", start = "Elwynn Forest",   z10 = "Westfall",          z15 = "Redridge Mountains", z20 = "Duskwood",            z30 = "Stranglethorn Vale", z50 = "Western Plaguelands" },
        { race = "Dwarf",    fac = "Alliance", start = "Dun Morogh",      z10 = "Loch Modan",        z15 = "Redridge Mountains", z20 = "Wetlands",            z30 = "Arathi Highlands",   z50 = "Western Plaguelands" },
        { race = "Gnome",    fac = "Alliance", start = "Dun Morogh",      z10 = "Loch Modan",        z15 = "Redridge Mountains", z20 = "Wetlands",            z30 = "Arathi Highlands",   z50 = "Eastern Plaguelands" },
        { race = "NightElf", fac = "Alliance", start = "Teldrassil",      z10 = "Darkshore",         z15 = "Ashenvale",          z20 = "Ashenvale",           z30 = "Desolace",           z50 = "Winterspring" },
        { race = "HighElf",  fac = "Alliance", start = "Elwynn Forest",   z10 = "Westfall",          z15 = "Redridge Mountains", z20 = "Duskwood",            z30 = "Stranglethorn Vale", z50 = "Western Plaguelands" },
        { race = "Orc",      fac = "Horde",    start = "Durotar",         z10 = "The Barrens",       z15 = "Stonetalon Mountains", z20 = "Hillsbrad Foothills", z30 = "Stranglethorn Vale", z50 = "Western Plaguelands" },
        { race = "Troll",    fac = "Horde",    start = "Durotar",         z10 = "The Barrens",       z15 = "Stonetalon Mountains", z20 = "Hillsbrad Foothills", z30 = "Arathi Highlands",   z50 = "Western Plaguelands" },
        { race = "Tauren",   fac = "Horde",    start = "Mulgore",         z10 = "The Barrens",       z15 = "Stonetalon Mountains", z20 = "Thousand Needles",   z30 = "Desolace",           z50 = "Winterspring" },
        { race = "Scourge",  fac = "Horde",    start = "Tirisfal Glades", z10 = "Silverpine Forest", z15 = "Hillsbrad Foothills", z20 = "Hillsbrad Foothills", z30 = "Arathi Highlands",   z50 = "Western Plaguelands" },
        { race = "Skyborne", fac = "Alliance", start = "Zephras Isle",    z10 = "Darkshore",         z15 = "Ashenvale",          z20 = "Ashenvale",           z30 = "Desolace",           z50 = "Winterspring" },
    }
    local orderViolations = 0
    for _, rs in ipairs(raceMatrix) do
        for _, cls in ipairs(allClasses) do
            for _, tLvl in ipairs({ 1, 3, 5 }) do
                mockPlayerState.level = tLvl
                mockPlayerState.class = cls
                mockPlayerState.classToken = cls
                mockPlayerState.race = rs.race
                mockPlayerState.raceToken = rs.race
                mockPlayerState.faction = rs.fac
                local wS = Engine.CalculateWorldMapZoneWorth(rs.start).worth
                local w10 = Engine.CalculateWorldMapZoneWorth(rs.z10).worth
                local w15 = Engine.CalculateWorldMapZoneWorth(rs.z15).worth
                local w20 = Engine.CalculateWorldMapZoneWorth(rs.z20).worth
                local w30 = Engine.CalculateWorldMapZoneWorth(rs.z30).worth
                local w50 = Engine.CalculateWorldMapZoneWorth(rs.z50).worth
                if not (wS >= 0.80 and wS > w10 and w10 >= w15 and w15 >= w20 and w20 > w30 and w30 > w50) then
                    orderViolations = orderViolations + 1
                end
            end
        end
    end
    assert_eq(orderViolations, 0, "All 270 Race x Class x Low-Level (1,3,5) profiles maintain strict monotonic zone progression")

    -- 6. Non-permanent Wanted/Chain milestones decay properly when Gray at Level 60
    local orig176 = mockQuestDB[176]
    mockQuestDB[176] = { title = "Wanted: \"Hogger\"", level = 11, xp = 850, money = 200 }
    mockPlayerState.level = 11
    local hogger11 = Engine.CalculateWorth(176)
    mockPlayerState.level = 60
    local hogger60 = Engine.CalculateWorth(176)
    mockQuestDB[176] = orig176
    assert_true(hogger11 >= 0.85 and hogger60 <= 0.30, string.format("Wanted: Hogger (176) is high priority at L11 (%.2f) and decays when gray at L60 (%.2f)", hogger11, hogger60))

    -- 7. Hostile input fuzzing on new Meta & Starter APIs + MetaQuests schema validation
    local fuzzVals = { nil, 0, -999, "bad", 0/0, math.huge, {}, true, false }
    local newFuzzFails = 0
    for _, fv in ipairs(fuzzVals) do
        local ok1 = pcall(addonTable.Data.GetMetaQuestInfo, fv)
        local ok2 = pcall(addonTable.Data.GetZoneMetaQuests, fv, fv, fv, fv)
        local ok3 = pcall(addonTable.Utils.GetMetaTagBadge, fv)
        local ok4 = pcall(addonTable.Utils.GetZoneMetaSummary, fv, fv)
        local ok5 = pcall(Engine.GetStarterZone, fv)
        local ok6 = pcall(addonTable.Utils.GetScoreColor, fv)
        local ok7 = pcall(addonTable.Utils.GetScoreColorHex, fv)
        if not (ok1 and ok2 and ok3 and ok4 and ok5 and ok6 and ok7) then newFuzzFails = newFuzzFails + 1 end
    end
    assert_eq(newFuzzFails, 0, "All new Meta, StarterZone & ColorHex APIs survive hostile input fuzzing (incl. NaN/Inf) with 0 errors")

    -- 8. Solution C: Hub Density counts the zone's available good quests (not just player log) and never penalizes a good quest
    mockPlayerState.level = 38
    mockPlayerState.faction = "Alliance"
    mockPlayerState.classToken = "WARRIOR"
    mockPlayerState.zone = "Riverglades"
    Player.Update()
    local rgTotalGood, rgCatalogGood = addonTable.Scores.GetZoneGoodQuestCount("Riverglades", 38, "Alliance", "WARRIOR")
    assert_true(rgTotalGood >= 10 and rgCatalogGood >= 10, string.format("Riverglades at L38 counts >= 10 available good quests from catalog (got %d)", rgTotalGood))

    -- Even with 0 quests in Quest Log, a good quest in Riverglades (95982) gets full 1.00 Zone Hub density
    local savedLog4L = mockQuestLog
    mockQuestLog = {}
    addonTable.Scores.InvalidateDensityCache()
    Engine.InvalidateCache()
    local d95982, det95982 = addonTable.Scores.CalculateDensity(95982)
    assert_eq(d95982, 1.00, "First quest in a rich zone (0 in log) receives 1.00 Density from the zone's good quests")
    assert_true((det95982.zoneGoodCount or 0) >= 10, "Density details reports zoneGoodCount >= 10 even with 0 quests in log")
    mockQuestLog = savedLog4L
    addonTable.Scores.InvalidateDensityCache()

    restoreAll()
end)()

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
