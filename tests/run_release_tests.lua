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
assert_true(_G.WorthItDB.highlightQuestObjects == true, "Default setting 'highlightQuestObjects' is true")
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

-- Active quests in an appropriate zone must BOOST worth (not penalize it)
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
assert_true(stv32WithQuests.worth > stv32.worth, string.format("Active quests in STV boost worth (%.0f%% -> %.0f%%)", stv32.worth * 100, stv32WithQuests.worth * 100))
assert_true((stv32WithQuests.activeBonus or 0) > 0, "activeBonus populated when quests are in log")

-- Duplicate zone aliases flagged so Advisor omits duplicate rows
assert_true(addonTable.Data.Zones["Riverglades"].isAlias == true, "Riverglades marked as alias")
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

-- 8. Quest World Object Highlight (3D Glow/Sparkles CVars + GameObject Tooltip Banner, excluding Mobs)
do
local savedLogObj = mockQuestLog
local savedHighlightOpt = addonTable.db.highlightQuestObjects
addonTable.db.highlightQuestObjects = true
addonTable.UI.ApplyQuestObjectHighlight()
assert_eq(mockCVars.Outline, "2", "Quest object highlight enables 3D Outline CVar (2)")
assert_eq(mockCVars.questPOI, "1", "Quest object highlight enables questPOI CVar (1)")
assert_eq(mockCVars.SoftTargetInteract, "3", "Quest object highlight enables SoftTargetInteract for nearby objects (3)")
assert_eq(mockCVars.SoftTargetIconGameObject, "1", "Quest object highlight enables floating SoftTargetIconGameObject (1)")
assert_eq(mockCVars.SoftTargetIconEnemy, "0", "Quest object highlight keeps SoftTargetIconEnemy disabled for mobs (0)")

addonTable.db.highlightQuestObjects = false
addonTable.UI.ApplyQuestObjectHighlight()
assert_eq(mockCVars.Outline, "0", "Disabling quest object highlight restores original Outline CVar (0)")
assert_eq(mockCVars.SoftTargetInteract, "1", "Disabling quest object highlight restores original SoftTargetInteract CVar (1)")
assert_eq(mockCVars.SoftTargetIconGameObject, "0", "Disabling quest object highlight restores original SoftTargetIconGameObject CVar (0)")

addonTable.db.highlightQuestObjects = true
addonTable.UI.ApplyQuestObjectHighlight()
mockQuestLog = {
    { title = "Gnomeregan (2)", isHeader = true, isCollapsed = false },
    { title = "Save Techbot's Brain!", questID = 2922, level = 26, isHeader = false, isComplete = 0 },
    { title = "The Grand Betrayal", questID = 2929, level = 35, isHeader = false, isComplete = 0 },
}
mockQuestDB[2922] = {
    title = "Save Techbot's Brain!",
    level = 26,
    xp = 2100,
    money = 0,
    isDungeon = true,
    objectives = { { text = "0/1 Techbot's Memory Core", type = "object", finished = false } },
}
mockQuestDB[2929] = {
    title = "The Grand Betrayal",
    level = 35,
    xp = 3900,
    money = 0,
    isDungeon = true,
    objectives = { { text = "Mekgineer Thermaplugg slain: 0/1", type = "monster", finished = false } },
}

-- Positive test: world interactable GameObject matching active non-kill objective
GameTooltip:ClearLines()
GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
GameTooltip._worthItAddedQuestID = nil
GameTooltip._worthItAddedItemID = nil
GameTooltip._worthItAddedObjectText = nil
GameTooltip.mockUnit = nil
GameTooltip.mockItemLink = nil
GameTooltip.mockSpellName = nil
GameTooltip:AddLine("Techbot's Memory Core", 1, 1, 1)
if GameTooltip.scripts and GameTooltip.scripts["OnShow"] then
    GameTooltip.scripts["OnShow"](GameTooltip)
else
    addonTable.UI.AddWorldObjectQuestLines(GameTooltip)
end
local objTooltipFound = false
for _, line in ipairs(GameTooltip.lines or {}) do
    if line.left and string.find(line.left, "QUEST OBJECT", 1, true) then
        objTooltipFound = true
    end
end
assert_true(objTooltipFound, "Hovering quest world object injects 'QUEST OBJECT (Interact!)' banner into GameTooltip")

-- Negative test 1: mob-kill objective name must NOT be tagged as Quest Object
GameTooltip:ClearLines()
GameTooltip._worthItAddedQuestID = nil
GameTooltip._worthItAddedItemID = nil
GameTooltip._worthItAddedObjectText = nil
GameTooltip:AddLine("Mekgineer Thermaplugg", 1, 0, 0)
addonTable.UI.AddWorldObjectQuestLines(GameTooltip)
local mobObjTagged = false
for _, line in ipairs(GameTooltip.lines or {}) do
    if line.left and string.find(line.left, "QUEST OBJECT", 1, true) then
        mobObjTagged = true
    end
end
assert_true(mobObjTagged == false, "Mob-kill objective ('Mekgineer Thermaplugg slain') is NOT tagged as a Quest World Object")

-- Negative test 2: tooltip with GetUnit() set is excluded even if name overlaps
GameTooltip:ClearLines()
GameTooltip._worthItAddedQuestID = nil
GameTooltip._worthItAddedItemID = nil
GameTooltip._worthItAddedObjectText = nil
GameTooltip.mockUnit = "Techbot's Memory Core"
GameTooltip:AddLine("Techbot's Memory Core", 1, 1, 1)
addonTable.UI.AddWorldObjectQuestLines(GameTooltip)
local unitTagged = false
for _, line in ipairs(GameTooltip.lines or {}) do
    if line.left and string.find(line.left, "QUEST OBJECT", 1, true) then
        unitTagged = true
    end
end
assert_true(unitTagged == false, "Unit/mob tooltip (GetUnit ~= nil) is excluded from Quest Object highlight")

GameTooltip.mockUnit = nil
GameTooltip:ClearLines()
mockQuestLog = savedLogObj
addonTable.db.highlightQuestObjects = savedHighlightOpt
addonTable.UI.ApplyQuestObjectHighlight()
end

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

-- 2D UI frame owner guard on AddWorldObjectQuestLines
local uiBtn = _G.CreateFrame("Button", "WorthIt_TestUIButton", UIParent)
GameTooltip:ClearLines()
GameTooltip._worthItAddedQuestID = nil
GameTooltip._worthItAddedItemID = nil
GameTooltip._worthItAddedObjectText = nil
GameTooltip:SetOwner(uiBtn, "ANCHOR_RIGHT")
GameTooltip:AddLine("Full Leaden Collection Phial", 1, 1, 1)
addonTable.UI.AddWorldObjectQuestLines(GameTooltip)
local uiFrameTaggedAsWorldObj = false
for _, line in ipairs(GameTooltip.lines or {}) do
    if line.left and string.find(line.left, "QUEST OBJECT", 1, true) then
        uiFrameTaggedAsWorldObj = true
    end
end
assert_true(uiFrameTaggedAsWorldObj == false, "2D UI button tooltip (owner ~= UIParent/WorldFrame) is NOT tagged as a 3D Quest World Object")
GameTooltip:Hide()

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
    { name = "UI.ApplyQuestObjectHighlight", fn = function(v) return addonTable.UI.ApplyQuestObjectHighlight(v) end },
    { name = "UI.AddWorldObjectQuestLines", fn = function(v) return addonTable.UI.AddWorldObjectQuestLines(v) end },
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
