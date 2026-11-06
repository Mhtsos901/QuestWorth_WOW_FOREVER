--[[
    WorthIt / QuestWorth - UI/QuestLog.lua
    Enhances Quest Log entries & Objective Tracker with a compact colored Worth % badge [XX%].
    Completed / Turn-In quests display a bright green [OK] badge instead of a percentage.
]]

local addonName, addon = ...
addon.UI = addon.UI or {}
local UI = addon.UI
local Utils = addon.Utils

local isHooked = false
local isTrackerHooked = false
local _lastQuestLogUpdate = 0
local _questLogUpdatePending = false

-- Function to badge ONLY a quest title button in Quest Log (QuestScrollFrame)
local function ProcessQuestButton(button, showTag)
    if not (button and button:IsShown()) then return end

    local fontString = button.Text or button.ButtonText or button.title or button.Title
    if not fontString and button.GetFontString then
        fontString = button:GetFontString()
    end

    if not fontString or not fontString.GetText or not fontString.SetText then return end

    local rawText = fontString:GetText() or ""
    if rawText == "" then return end
    local cleanText = Utils.CleanQuestTitle(rawText)

    -- Guard 1: Objective line filter (lines starting with dash, bullet, or containing lineID)
    if button.lineID or string.find(rawText, "^%s*%-") or string.find(cleanText, "^%s*%-") then
        if rawText ~= cleanText then
            fontString:SetText(cleanText)
        end
        return
    end

    -- Guard 2: Header filter (Zone headers like "Elwynn Forest", "Duskwood")
    -- Do not strip header badges here; handled by ProcessHeaderButton
    if button.isHeader or button.header or (button.info and button.info.isHeader) then
        return
    end

    local cleanTrimmed = string.gsub(cleanText, "^%s*(.-)%s*$", "%1")
    local cleanZoneName = string.gsub(cleanTrimmed, "%s*%(%d+/?%d*%)%s*$", "")
    if (addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(cleanZoneName))
       or (addon.Scores and addon.Scores.IsNonZoneHeader and addon.Scores.IsNonZoneHeader(cleanZoneName)) then
        return
    end

    -- 1. Try to resolve questID directly from button properties
    local qID = button.questID
    if not qID or qID <= 0 then
        if button.id and type(button.id) == "number" and button.id > 0 then
            qID = button.id
        elseif button.info and button.info.questID and button.info.questID > 0 then
            qID = button.info.questID
        elseif button.data and button.data.questID and button.data.questID > 0 then
            qID = button.data.questID
        end
    end

    -- 2. Try button.questLogIndex or button:GetID()
    if (not qID or qID <= 0) and button.questLogIndex and C_QuestLog and C_QuestLog.GetInfo then
        local ok, info = pcall(C_QuestLog.GetInfo, button.questLogIndex)
        if ok and info then
            if info.isHeader then
                return
            end
            if info.questID and info.questID > 0 then
                qID = info.questID
            end
        end
    end

    if (not qID or qID <= 0) and button.GetID then
        local btnID = button:GetID()
        if btnID and btnID > 0 then
            if C_QuestLog and C_QuestLog.GetInfo then
                local ok, info = pcall(C_QuestLog.GetInfo, btnID)
                if ok and info then
                    if info.isHeader then
                        return
                    end
                    if info.questID and info.questID > 0 then
                        qID = info.questID
                    end
                end
            elseif GetQuestLogTitle then
                local ok, t, _, _, isH, _, _, _, id = pcall(GetQuestLogTitle, btnID)
                if ok then
                    if isH then
                        return
                    end
                    if id and id > 0 then
                        qID = id
                    end
                end
            end
        end
    end

    -- 3. Fallback: Match by Quest Title from active quest log
    if not qID or qID <= 0 then
        local titleNoLevel = string.gsub(cleanText, "^%s*%[%d+%]%s*", "")
        titleNoLevel = string.gsub(titleNoLevel, "^%s*(.-)%s*$", "%1")
        local cleanTrim = string.gsub(cleanText, "^%s*(.-)%s*$", "%1")

        local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                           or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
        for i = 1, numEntries do
            local qTitle, candidateID, isH
            if C_QuestLog and C_QuestLog.GetInfo then
                local ok, info = pcall(C_QuestLog.GetInfo, i)
                if ok and info then
                    isH = info.isHeader
                    qTitle = info.title
                    candidateID = info.questID
                end
            elseif GetQuestLogTitle then
                local ok, t, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, i)
                if ok then
                    isH = h
                    qTitle = t
                    candidateID = id
                end
            end

            if not isH and candidateID and candidateID > 0 and qTitle and qTitle ~= "" then
                local ct = Utils.CleanQuestTitle(qTitle)
                ct = string.gsub(ct, "^%s*(.-)%s*$", "%1")
                if ct == cleanTrim or ct == titleNoLevel then
                    qID = candidateID
                    break
                end
            end
        end
    end

    -- If we still cannot identify this as a quest, do not touch it
    if not qID or qID <= 0 then
        return
    end

    if not showTag then
        if rawText ~= cleanText then
            fontString:SetText(cleanText)
        end
        return
    end

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then return end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local badge = Utils.FormatBadge(worth, isComplete, isHard)
    local targetText = badge .. " " .. cleanText
    if rawText ~= targetText then
        fontString:SetText(targetText)
    end
end

-- Process a Quest Log geographical zone header button (keep clean without worth % badge)
local function ProcessHeaderButton(button, showTag)
    if not button then return end
    local fontString = button.ButtonText or button.Text or (button.GetFontString and button:GetFontString()) or button.normalText
    if not (fontString and fontString.GetText and fontString.SetText) then return end

    local rawText = fontString:GetText() or ""
    if rawText == "" then return end
    local cleanText = Utils.CleanQuestTitle(rawText)
    cleanText = string.gsub(cleanText, "^%s*(.-)%s*$", "%1")
    if cleanText == "" then return end

    -- Clean any badge on zone headers so headers remain pristine (e.g. "Westfall", "Redridge Mountains")
    if rawText ~= cleanText then
        fontString:SetText(cleanText)
    end
end

-- Function to clean objective frames so details never show a badge
local function CleanObjectiveFrame(frame)
    if not (frame and frame:IsShown()) then return end
    local fontString = frame.Text or frame.ButtonText or (frame.GetFontString and frame:GetFontString())
    if fontString and fontString.GetText and fontString.SetText then
        local rawText = fontString:GetText() or ""
        local cleanText = Utils.CleanQuestTitle(rawText)
        if rawText ~= cleanText then
            fontString:SetText(cleanText)
        end
    end
end

-- Master function to update all visible quest entries in Quest Log
function UI.UpdateQuestLog(force)
    if not addon.db then return end
    if InCombatLockdown and InCombatLockdown() then return end
    if addon.isUpdatingUI then return end

    local now = GetTime()
    if not force and (now - _lastQuestLogUpdate) < 0.15 then
        if not _questLogUpdatePending then
            _questLogUpdatePending = true
            if C_Timer and C_Timer.After then
                C_Timer.After(0.15, function()
                    _questLogUpdatePending = false
                    UI.UpdateQuestLog(true)
                end)
            else
                _questLogUpdatePending = false
            end
        end
        return
    end
    _lastQuestLogUpdate = now
    _questLogUpdatePending = false

    addon.isUpdatingUI = true

    local showTag = (addon.db and addon.db.enabled and addon.db.showInQuestLog ~= false)

    -- 1. Modern Blizzard & OpenMap QuestScrollFrame
    if QuestScrollFrame then
        local pool = QuestScrollFrame.titleFramePool or QuestScrollFrame.TitleFramePool
        if pool and pool.EnumerateActive then
            for button in pool:EnumerateActive() do
                ProcessQuestButton(button, showTag)
            end
        end

        local headerPool = QuestScrollFrame.headerFramePool or QuestScrollFrame.HeaderFramePool
        if headerPool and headerPool.EnumerateActive then
            for button in headerPool:EnumerateActive() do
                ProcessHeaderButton(button, showTag)
            end
        end

        -- Modern Dragonflight ScrollBox frames
        if QuestScrollFrame.ScrollBox then
            local function handleScrollFrame(button)
                local isHeader = button.isHeader or button.header or (button.info and button.info.isHeader)
                if not isHeader and button.GetID then
                    local btnID = button:GetID()
                    if btnID and btnID > 0 then
                        if C_QuestLog and C_QuestLog.GetInfo then
                            local okInfo, info = pcall(C_QuestLog.GetInfo, btnID)
                            if okInfo and info and info.isHeader then isHeader = true end
                        elseif GetQuestLogTitle then
                            local okTitle, _, _, _, isH = pcall(GetQuestLogTitle, btnID)
                            if okTitle and isH then isHeader = true end
                        end
                    end
                end

                if isHeader then
                    ProcessHeaderButton(button, showTag)
                else
                    ProcessQuestButton(button, showTag)
                end
            end

            if QuestScrollFrame.ScrollBox.ForEachFrame then
                pcall(function()
                    QuestScrollFrame.ScrollBox:ForEachFrame(handleScrollFrame)
                end)
            elseif QuestScrollFrame.ScrollBox.GetFrames then
                local ok, frames = pcall(QuestScrollFrame.ScrollBox.GetFrames, QuestScrollFrame.ScrollBox)
                if ok and frames then
                    for _, button in ipairs(frames) do
                        handleScrollFrame(button)
                    end
                end
            end
        end

        -- Contents frame children
        if QuestScrollFrame.Contents and QuestScrollFrame.Contents.GetChildren then
            local ok, children = pcall(function() return { QuestScrollFrame.Contents:GetChildren() } end)
            if ok and children then
                for _, button in ipairs(children) do
                    local isHeader = button.isHeader or button.header or (button.info and button.info.isHeader)
                    if not isHeader and button.GetID then
                        local btnID = button:GetID()
                        if btnID and btnID > 0 then
                            if C_QuestLog and C_QuestLog.GetInfo then
                                local okInfo, info = pcall(C_QuestLog.GetInfo, btnID)
                                if okInfo and info and info.isHeader then isHeader = true end
                            elseif GetQuestLogTitle then
                                local okTitle, _, _, _, isH = pcall(GetQuestLogTitle, btnID)
                                if okTitle and isH then isHeader = true end
                            end
                        end
                    end

                    if isHeader then
                        ProcessHeaderButton(button, showTag)
                    else
                        ProcessQuestButton(button, showTag)
                    end
                end
            end
        end

        local objPool = QuestScrollFrame.objectiveFramePool or QuestScrollFrame.ObjectiveFramePool
        if objPool and objPool.EnumerateActive then
            for objFrame in objPool:EnumerateActive() do
                CleanObjectiveFrame(objFrame)
            end
        end
    end

    -- 2. Classic QuestLogFrame (QuestLogTitle1..QUESTS_DISPLAYED)
    if QuestLogFrame and QuestLogFrame:IsShown() then
        local numQuests = QUESTS_DISPLAYED or 25
        local scrollOffset = (FauxScrollFrame_GetOffset and QuestLogScrollFrame and FauxScrollFrame_GetOffset(QuestLogScrollFrame)) or 0
        for i = 1, numQuests do
            local button = _G["QuestLogTitle" .. i]
            if button and button:IsShown() then
                local questIndex = i + scrollOffset
                local ok, qTitle, _, _, isHeader, _, isComplete, _, qID = pcall(GetQuestLogTitle, questIndex)
                local fontString = button.normalText or _G[button:GetName() .. "NormalText"] or (button.GetFontString and button:GetFontString()) or button.Text
                if fontString and fontString.GetText and fontString.SetText then
                    local rawTitle = fontString:GetText() or ""
                    local cleanTitle = Utils.CleanQuestTitle(rawTitle)
                    if ok and qTitle and not isHeader then
                        if showTag then
                            local id = qID
                            if not id or id <= 0 then
                                if C_QuestLog and C_QuestLog.GetInfo then
                                    local okInfo, info = pcall(C_QuestLog.GetInfo, questIndex)
                                    if okInfo and info and info.questID and info.questID > 0 then
                                        id = info.questID
                                    end
                                end
                            end
                            if id and id > 0 then
                                local worth, breakdown = addon.Engine.CalculateWorth(id)
                                if worth then
                                    local comp = (breakdown and breakdown.isComplete) or isComplete
                                    local isHard = (breakdown and breakdown.isHard)
                                    local badge = Utils.FormatBadge(worth, comp, isHard)
                                    local targetText = badge .. " " .. cleanTitle
                                    if rawTitle ~= targetText then
                                        fontString:SetText(targetText)
                                    end
                                end
                            end
                        else
                            if rawTitle ~= cleanTitle then
                                fontString:SetText(cleanTitle)
                            end
                        end
                    elseif isHeader then
                        ProcessHeaderButton(button, showTag)
                    end
                end
            end
        end
    end

    -- 3. Classic QuestLogListScrollFrame fallback (WotLK / Classic hybrid)
    if QuestLogListScrollFrame and QuestLogListScrollFrame.buttons then
        local scrollOffset = HybridScrollFrame_GetOffset and HybridScrollFrame_GetOffset(QuestLogListScrollFrame) or 0
        local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries()) or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
        for i, button in ipairs(QuestLogListScrollFrame.buttons) do
            local index = i + scrollOffset
            if button:IsShown() and index <= numEntries then
                local info = C_QuestLog and C_QuestLog.GetInfo and C_QuestLog.GetInfo(index)
                if info and not info.isHeader and info.questID and button.normalText then
                    local rawTitle = info.title or button.normalText:GetText() or ""
                    local cleanTitle = Utils.CleanQuestTitle(rawTitle)
                    if showTag then
                        local worth, breakdown = addon.Engine.CalculateWorth(info.questID)
                        if worth then
                            local isComplete = (breakdown and breakdown.isComplete)
                            local isHard = (breakdown and breakdown.isHard)
                            local badge = Utils.FormatBadge(worth, isComplete, isHard)
                            local targetText = badge .. " " .. cleanTitle
                            if rawTitle ~= targetText then
                                button.normalText:SetText(targetText)
                            end
                        end
                    else
                        if rawTitle ~= cleanTitle then
                            button.normalText:SetText(cleanTitle)
                        end
                    end
                elseif info and info.isHeader and button.normalText then
                    ProcessHeaderButton(button, showTag)
                end
            end
        end
    end

    addon.isUpdatingUI = false
end

-- Helper to locate the header FontString on an Objective Tracker block across Classic & Modern clients
local function GetBlockHeaderFontString(block)
    if not block then return nil end
    if block.HeaderText and block.HeaderText.GetText and block.HeaderText.SetText then
        return block.HeaderText
    end
    if block.Header then
        if block.Header.Text and block.Header.Text.GetText and block.Header.Text.SetText then
            return block.Header.Text
        end
        if block.Header.HeaderText and block.Header.HeaderText.GetText and block.Header.HeaderText.SetText then
            return block.Header.HeaderText
        end
        if block.Header.Title and block.Header.Title.GetText and block.Header.Title.SetText then
            return block.Header.Title
        end
        if block.Header.GetFontString then
            local fs = block.Header:GetFontString()
            if fs and fs.GetText and fs.SetText then
                return fs
            end
        end
        if block.Header.GetText and block.Header.SetText then
            return block.Header
        end
    end
    if block.Title and block.Title.GetText and block.Title.SetText then
        return block.Title
    end
    if block.Text and block.Text.GetText and block.Text.SetText then
        return block.Text
    end
    return nil
end

-- Helper to check if a questID is genuinely in the player's active quest log
local function IsActiveQuestInLog(questID)
    if not questID or type(questID) ~= "number" or questID <= 0 then return false end
    if C_QuestLog and C_QuestLog.IsOnQuest then
        local ok, onQuest = pcall(C_QuestLog.IsOnQuest, questID)
        if ok and onQuest then return true end
    end
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local ok, idx = pcall(C_QuestLog.GetLogIndexForQuestID, questID)
        if ok and idx and idx > 0 then return true end
    end
    return false
end

-- Helper to safely resolve a questID from an Objective Tracker block or header text
local function ResolveBlockQuestID(block, currentText, activeQuests, titleToID)
    if not block then return nil end

    local function isValidQuest(id)
        if not id or type(id) ~= "number" or id <= 0 then return false end
        if activeQuests then
            return activeQuests[id] == true
        end
        return IsActiveQuestInLog(id)
    end

    -- 1. Check direct properties on the block
    if isValidQuest(block.questID) then
        return block.questID
    end
    if isValidQuest(block.id) then
        return block.id
    end
    if block.GetQuestID then
        local ok, qid = pcall(block.GetQuestID, block)
        if ok and isValidQuest(qid) then return qid end
    end
    if block.Header then
        if isValidQuest(block.Header.questID) then
            return block.Header.questID
        end
        if isValidQuest(block.Header.id) then
            return block.Header.id
        end
    end

    -- 2. Check questLogIndex
    if block.questLogIndex and C_QuestLog and C_QuestLog.GetInfo then
        local ok, info = pcall(C_QuestLog.GetInfo, block.questLogIndex)
        if ok and info and not info.isHeader and isValidQuest(info.questID) then
            return info.questID
        end
    end

    -- 3. Match by Quest Title (O(1) table lookup or direct search)
    local text = currentText or ""
    if text == "" then
        local fs = GetBlockHeaderFontString(block)
        if fs and fs.GetText then
            text = fs:GetText() or ""
        end
    end

    if text and text ~= "" then
        local clean = Utils.CleanQuestTitle(text)
        local titleNoLevel = string.gsub(clean, "^%s*%[%d+%]%s*", "")
        clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
        titleNoLevel = string.gsub(titleNoLevel, "^%s*(.-)%s*$", "%1")

        if titleToID then
            if titleToID[clean] then
                return titleToID[clean]
            end
            if titleToID[titleNoLevel] then
                return titleToID[titleNoLevel]
            end
        end

        -- Direct fallback scan if titleToID table was not passed or exact match missed
        local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                           or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
        for i = 1, numEntries do
            local qTitle, qid
            if C_QuestLog and C_QuestLog.GetInfo then
                local ok, info = pcall(C_QuestLog.GetInfo, i)
                if ok and info and not info.isHeader then
                    qTitle = info.title
                    qid = info.questID
                end
            elseif GetQuestLogTitle then
                local ok, t, _, _, isH, _, _, _, id = pcall(GetQuestLogTitle, i)
                if ok and not isH then
                    qTitle = t
                    qid = id
                end
            end

            if qTitle and qid and qid > 0 and isValidQuest(qid) then
                local title = Utils.CleanQuestTitle(qTitle)
                title = string.gsub(title, "^%s*(.-)%s*$", "%1")
                if title == titleNoLevel or title == clean then
                    return qid
                end
                if #title >= 10 and (string.find(clean, title, 1, true) or string.find(titleNoLevel, title, 1, true)) then
                    return qid
                end
            end
        end
    end

    return nil
end

-- Hook fontString:SetText on a block header so Blizzard's text assignments are badged at source
local function HookBlockHeaderText(block)
    if not block or block._worthItTextHooked then return end
    local fs = GetBlockHeaderFontString(block)
    if not (fs and fs.SetText) then return end

    hooksecurefunc(fs, "SetText", function(self, text)
        if self._worthItSettingText then return end
        if not (addon.db and addon.db.enabled and addon.db.showInTracker ~= false) then return end
        if InCombatLockdown and InCombatLockdown() then return end
        if not text or text == "" then return end

        local clean = Utils.CleanQuestTitle(text)
        local qID = ResolveBlockQuestID(block, clean)
        if not qID or qID <= 0 then return end

        local worth, breakdown = addon.Engine.CalculateWorth(qID)
        if not worth then return end

        local isComplete = (breakdown and breakdown.isComplete)
        local isHard = (breakdown and breakdown.isHard)
        local badge = Utils.FormatBadge(worth, isComplete, isHard)
        local targetText = badge .. " " .. clean

        if text ~= targetText then
            self._worthItSettingText = true
            self:SetText(targetText)
            self._worthItSettingText = false
        end
    end)
    block._worthItTextHooked = true
end

-- Apply badge to a single Objective Tracker block header and clean its objective lines
local function BadgeObjectiveBlock(block, activeQuests, titleToID)
    if not block then return end
    local fontString = GetBlockHeaderFontString(block)
    if not (fontString and fontString.GetText and fontString.SetText) then return end
    if not addon.db then return end
    if InCombatLockdown and InCombatLockdown() then return end

    local rawText = fontString:GetText() or ""
    if rawText == "" then return end
    local cleanText = Utils.CleanQuestTitle(rawText)

    local showTag = (addon.db and addon.db.enabled and addon.db.showInTracker ~= false)
    if not showTag then
        if rawText ~= cleanText then
            fontString._worthItSettingText = true
            fontString:SetText(cleanText)
            fontString._worthItSettingText = false
        end
        if block.lines then
            for _, line in pairs(block.lines) do
                if line and line.Text and line.Text.GetText and line.Text.SetText then
                    local t = line.Text:GetText() or ""
                    local ct = Utils.CleanQuestTitle(t)
                    if t ~= ct then
                        line.Text:SetText(ct)
                    end
                end
            end
        end
        return
    end

    local qID = ResolveBlockQuestID(block, rawText, activeQuests, titleToID)
    if not qID or qID <= 0 then return end

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then return end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local badge = Utils.FormatBadge(worth, isComplete, isHard)
    local targetText = badge .. " " .. cleanText

    if rawText ~= targetText then
        fontString._worthItSettingText = true
        fontString:SetText(targetText)
        fontString._worthItSettingText = false
    end

    -- Clean objective detail lines in this block so they never display a badge
    if block.lines then
        for _, line in pairs(block.lines) do
            if line and line.Text and line.Text.GetText and line.Text.SetText then
                local t = line.Text:GetText() or ""
                local ct = Utils.CleanQuestTitle(t)
                if t ~= ct then
                    line.Text:SetText(ct)
                end
            end
        end
    end
end

-- Cached module list (hoisted, deduplicated - QUEST MODULES ONLY)
local _moduleListCache = nil
local function GetModuleList()
    if _moduleListCache then return _moduleListCache end
    local seen, list = {}, {}
    local function add(mod)
        if mod and not seen[mod] then
            seen[mod] = true
            list[#list + 1] = mod
        end
    end
    add(QuestObjectiveTracker)
    add(CampaignQuestObjectiveTracker)
    add(WorldQuestObjectiveTracker)
    add(QUEST_TRACKER_MODULE)
    add(CAMPAIGN_QUEST_TRACKER_MODULE)
    add(WORLD_QUEST_TRACKER_MODULE)

    if ObjectiveTrackerManager and ObjectiveTrackerManager.modules then
        for _, mod in ipairs(ObjectiveTrackerManager.modules) do
            if mod == QuestObjectiveTracker or mod == CampaignQuestObjectiveTracker or mod == WorldQuestObjectiveTracker then
                add(mod)
            elseif mod.isQuestTracker or (mod.GetName and string.find(string.lower(mod:GetName() or ""), "quest")) then
                add(mod)
            end
        end
    end
    _moduleListCache = list
    return list
end

function UI.InvalidateModuleListCache()
    _moduleListCache = nil
end

local _lastTrackerUpdate = 0
local _isUpdatingTracker = false

-- Master function to update all visible quest entries in the Objective Tracker
function UI.UpdateObjectiveTracker(force)
    if not addon.db then return end
    if InCombatLockdown and InCombatLockdown() then return end
    if _isUpdatingTracker then return end

    local now = GetTime()
    if not force and (now - _lastTrackerUpdate) < 0.10 then return end
    _lastTrackerUpdate = now

    _isUpdatingTracker = true

    -- Precompute active quests & fast title lookup table once for this cycle
    local activeQuests = {}
    local titleToID = {}
    local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                       or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0

    for i = 1, numEntries do
        local qTitle, qid, isH
        if C_QuestLog and C_QuestLog.GetInfo then
            local ok, info = pcall(C_QuestLog.GetInfo, i)
            if ok and info then
                isH = info.isHeader
                qTitle = info.title
                qid = info.questID
            end
        elseif GetQuestLogTitle then
            local ok, t, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, i)
            if ok then
                isH = h
                qTitle = t
                qid = id
            end
        end

        if not isH and qid and qid > 0 then
            activeQuests[qid] = true
            if qTitle and qTitle ~= "" then
                local clean = Utils.CleanQuestTitle(qTitle)
                local noLevel = string.gsub(clean, "^%s*%[%d+%]%s*", "")
                clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
                noLevel = string.gsub(noLevel, "^%s*(.-)%s*$", "%1")

                titleToID[clean] = qid
                titleToID[noLevel] = qid
            end
        end
    end

    local processedBlocks = {}
    local function ProcessBlock(block)
        if not block or processedBlocks[block] then return end
        processedBlocks[block] = true
        HookBlockHeaderText(block)
        BadgeObjectiveBlock(block, activeQuests, titleToID)
    end

    local modules = GetModuleList()

    -- 1. Enumerate blocks across quest tracker modules
    for _, mod in ipairs(modules) do
        if mod then
            local enumerated = false

            -- Modern Dragonflight API: mod:EnumerateBlocks()
            if mod.EnumerateBlocks then
                local ok = pcall(function()
                    for block in mod:EnumerateBlocks() do
                        ProcessBlock(block)
                        enumerated = true
                    end
                end)
                if not ok then enumerated = false end
            end

            -- Modern Dragonflight FramePoolCollection: mod.blockPools
            if not enumerated and mod.blockPools and mod.blockPools.EnumerateActive then
                local ok = pcall(function()
                    for block in mod.blockPools:EnumerateActive() do
                        ProcessBlock(block)
                        enumerated = true
                    end
                end)
                if not ok then enumerated = false end
            end

            -- Legacy pool: mod.blockPool
            if not enumerated and mod.blockPool and mod.blockPool.EnumerateActive then
                local ok = pcall(function()
                    for block in mod.blockPool:EnumerateActive() do
                        ProcessBlock(block)
                        enumerated = true
                    end
                end)
                if not ok then enumerated = false end
            end

            -- Handle mod.usedBlocks
            if not enumerated and mod.usedBlocks and type(mod.usedBlocks) == "table" then
                for _, v in pairs(mod.usedBlocks) do
                    if type(v) == "table" then
                        if GetBlockHeaderFontString(v) or v.id or v.questID then
                            ProcessBlock(v)
                        else
                            for _, subBlock in pairs(v) do
                                if type(subBlock) == "table" and (GetBlockHeaderFontString(subBlock) or subBlock.id or subBlock.questID) then
                                    ProcessBlock(subBlock)
                                end
                            end
                        end
                    end
                end
            end

            -- Query mod:GetExistingBlock(questID) for all active quests
            if mod.GetExistingBlock then
                for qid in pairs(activeQuests) do
                    local okB, block = pcall(mod.GetExistingBlock, mod, qid)
                    if okB and block then
                        ProcessBlock(block)
                    end
                end
            end
        end
    end

    -- 2. Fallback: Enumerate blocks in container frames if module enumeration missed them
    local containers = {
        ObjectiveTrackerBlocksFrame,
        ObjectiveTrackerFrame and ObjectiveTrackerFrame.BlocksFrame,
    }

    for _, container in ipairs(containers) do
        if container and container.GetChildren then
            local children = { container:GetChildren() }
            for _, child in ipairs(children) do
                if child and child:IsShown() then
                    if GetBlockHeaderFontString(child) then
                        ProcessBlock(child)
                    elseif child.GetChildren then
                        for _, sub in ipairs({ child:GetChildren() }) do
                            if sub and sub:IsShown() and GetBlockHeaderFontString(sub) then
                                ProcessBlock(sub)
                            end
                        end
                    end
                end
            end
        end
    end

    _isUpdatingTracker = false
end

-- Hook all available Objective Tracker modules and global update functions
local function HookTrackerModules()
    local modules = GetModuleList()

    for _, mod in ipairs(modules) do
        if mod then
            -- Hook LayoutContents (Dragonflight / modern tracker layout)
            if mod.LayoutContents and not mod._worthItLayoutHooked then
                hooksecurefunc(mod, "LayoutContents", function(self)
                    if self.EnumerateBlocks then
                        for block in self:EnumerateBlocks() do
                            HookBlockHeaderText(block)
                            BadgeObjectiveBlock(block)
                        end
                    elseif self.blockPools and self.blockPools.EnumerateActive then
                        for block in self.blockPools:EnumerateActive() do
                            HookBlockHeaderText(block)
                            BadgeObjectiveBlock(block)
                        end
                    end
                end)
                mod._worthItLayoutHooked = true
            end

            -- Hook SetBlockHeader (Blizzard assigns header to block - synchronous badge)
            if mod.SetBlockHeader and not mod._worthItHeaderHooked then
                hooksecurefunc(mod, "SetBlockHeader", function(self, block)
                    if block and not _isUpdatingTracker then
                        BadgeObjectiveBlock(block)
                    end
                end)
                mod._worthItHeaderHooked = true
            end

            -- Hook Update (synchronous, no async timer feedback loop)
            if mod.Update and not mod._worthItUpdateHooked then
                hooksecurefunc(mod, "Update", function()
                    if not _isUpdatingTracker then
                        UI.UpdateObjectiveTracker()
                    end
                end)
                mod._worthItUpdateHooked = true
            end
        end
    end

    -- Hook ObjectiveTrackerFrame.Update
    if ObjectiveTrackerFrame and ObjectiveTrackerFrame.Update and not ObjectiveTrackerFrame._worthItHooked then
        hooksecurefunc(ObjectiveTrackerFrame, "Update", function()
            if not _isUpdatingTracker then
                UI.UpdateObjectiveTracker()
            end
        end)
        ObjectiveTrackerFrame._worthItHooked = true
    end

    -- Hook ObjectiveTracker_Update (legacy global function)
    if ObjectiveTracker_Update and not isTrackerHooked then
        hooksecurefunc("ObjectiveTracker_Update", function()
            if not _isUpdatingTracker then
                UI.UpdateObjectiveTracker()
            end
        end)
        isTrackerHooked = true
    end
end

-- Export HookTrackerModules for late-loading modules
UI.HookTrackerModules = HookTrackerModules

function UI.InitializeQuestLog()
    -- 1. Hook Quest Log functions once
    if QuestLogQuests_Update and not isHooked then
        hooksecurefunc("QuestLogQuests_Update", function()
            if not addon.isUpdatingUI then
                UI.UpdateQuestLog()
            end
        end)
        isHooked = true
        addon.Debug("Hooked QuestLogQuests_Update successfully.")
    end

    if QuestMapFrame_UpdateAll and not UI._questMapUpdateHooked then
        hooksecurefunc("QuestMapFrame_UpdateAll", function()
            if not addon.isUpdatingUI then
                UI.UpdateQuestLog()
            end
        end)
        UI._questMapUpdateHooked = true
    end

    if QuestLog_Update and not UI._questLogUpdateHooked then
        hooksecurefunc("QuestLog_Update", function()
            if not addon.isUpdatingUI then
                UI.UpdateQuestLog()
            end
        end)
        UI._questLogUpdateHooked = true
    end

    if QuestMapFrame_ShowQuestDetails and not UI._showQuestDetailsHooked then
        hooksecurefunc("QuestMapFrame_ShowQuestDetails", function()
            if not addon.isUpdatingUI then
                UI.UpdateQuestLog()
            end
        end)
        UI._showQuestDetailsHooked = true
    end

    if SelectQuestLogEntry and not UI._selectQuestLogEntryHooked then
        hooksecurefunc("SelectQuestLogEntry", function()
            if not addon.isUpdatingUI then
                UI.UpdateQuestLog()
            end
        end)
        UI._selectQuestLogEntryHooked = true
    end

    if WorldMapFrame and WorldMapFrame.HookScript and not UI._worldMapOnShowHooked then
        pcall(function()
            WorldMapFrame:HookScript("OnShow", function()
                UI.UpdateQuestLog(true)
                if C_Timer and C_Timer.After then
                    C_Timer.After(0.10, function() UI.UpdateQuestLog(true) end)
                end
            end)
            UI._worldMapOnShowHooked = true
        end)
    end

    if QuestMapFrame and QuestMapFrame.HookScript and not QuestMapFrame._worthItOnShowHooked then
        pcall(function()
            QuestMapFrame:HookScript("OnShow", function()
                UI.UpdateQuestLog(true)
                if C_Timer and C_Timer.After then
                    C_Timer.After(0.10, function() UI.UpdateQuestLog(true) end)
                end
            end)
            QuestMapFrame._worthItOnShowHooked = true
        end)
    end

    if QuestLogFrame and QuestLogFrame.HookScript and not UI._questLogFrameOnShowHooked then
        pcall(function()
            QuestLogFrame:HookScript("OnShow", function()
                UI.UpdateQuestLog(true)
                if C_Timer and C_Timer.After then
                    C_Timer.After(0.10, function() UI.UpdateQuestLog(true) end)
                end
            end)
            UI._questLogFrameOnShowHooked = true
        end)
    end

    if QuestScrollFrame then
        local scrollBar = QuestScrollFrame.ScrollBar or QuestScrollFrame.scrollBar
        if scrollBar and scrollBar.HookScript and not scrollBar._worthItScrollHooked then
            pcall(function()
                scrollBar:HookScript("OnValueChanged", function()
                    UI.UpdateQuestLog()
                end)
                scrollBar._worthItScrollHooked = true
            end)
        end
        if QuestScrollFrame.ScrollBox and QuestScrollFrame.ScrollBox.RegisterCallback and not UI._scrollBoxHooked then
            pcall(function()
                QuestScrollFrame.ScrollBox:RegisterCallback("OnScroll", function()
                    UI.UpdateQuestLog()
                end, addonName)
                UI._scrollBoxHooked = true
            end)
        end
        if QuestScrollFrame.HookScript and not QuestScrollFrame._worthItWheelHooked then
            pcall(function()
                QuestScrollFrame:HookScript("OnMouseWheel", function()
                    UI.UpdateQuestLog()
                end)
                QuestScrollFrame._worthItWheelHooked = true
            end)
        end
    end

    if QuestLogScrollFrame and QuestLogScrollFrame.HookScript and not UI._classicScrollHooked then
        pcall(function()
            QuestLogScrollFrame:HookScript("OnVerticalScroll", function()
                UI.UpdateQuestLog()
            end)
            QuestLogScrollFrame:HookScript("OnMouseWheel", function()
                UI.UpdateQuestLog()
            end)
            UI._classicScrollHooked = true
        end)
    end

    -- 2. Hook Objective Tracker
    HookTrackerModules()

    -- 3. Initial refresh (force bypasses debounce)
    UI.UpdateQuestLog(true)
    UI.UpdateObjectiveTracker(true)
end
