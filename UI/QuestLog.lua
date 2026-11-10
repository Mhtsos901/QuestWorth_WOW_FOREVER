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

-- Helper to normalize a quest title for reliable comparison against raw button text
local function NormalizeQuestTitle(str)
    if not str or str == "" then return "" end
    local s = tostring(str)
    -- 1. Strip all WoW color codes and formatting
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "|T.-|t", "")
    -- 2. Strip status icon prefixes like (?), (...), (!)
    s = string.gsub(s, "^%s*%([?.!]+%)%s*", "")
    -- 3. Strip existing badges
    s = string.gsub(s, "%[%d+%%%]", "")
    s = string.gsub(s, "%[OK%]", "")
    s = string.gsub(s, "%[[^%]]*Worth[^%]]*%]", "")
    -- 4. Strip status icon prefixes again in case badge was first
    s = string.gsub(s, "^%s*%([?.!]+%)%s*", "")
    -- 5. Strip level prefixes: [15], [15+], 15., etc.
    s = string.gsub(s, "^%s*%[%d+%+?%]%s*", "")
    s = string.gsub(s, "^%s*%d+%.%s*", "")
    -- 6. Strip status tags and suffixes
    s = string.gsub(s, "%s*%(%s*[Dd]ungeon%s*%)%s*", "")
    s = string.gsub(s, "%s*%(%s*[Ee]lite%s*%)%s*", "")
    s = string.gsub(s, "%s*%(%s*[Gg]roup%s*%)%s*", "")
    s = string.gsub(s, "%s*%(%s*[Rr]aid%s*%)%s*", "")
    s = string.gsub(s, "%s*%(%s*[Cc]omplete%s*%)%s*", "")
    s = string.gsub(s, "%s*%(%s*[Ff]ailed%s*%)%s*", "")
    s = string.gsub(s, "%s*%(%s*[Dd]aily%s*%)%s*", "")
    s = string.gsub(s, "%s*%(%s*[Rr]epeatable%s*%)%s*", "")
    -- 7. Trim whitespace
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")
    return s
end

-- Helper to check if a frame or text is an objective/detail line rather than a quest title button
local function IsObjectiveOrDetailFrame(button, text)
    if not button and not text then return false end

    -- 1. Check frame flags and attributes characteristic of objectives / detail lines
    if button then
        if button.objectiveIndex or button.isObjective or button.lineID then
            return true
        end

        local name = button.GetName and button:GetName()
        if name and (string.find(name, "Objective") or string.find(name, "Detail") or string.find(name, "QuestLogObjective")) then
            return true
        end

        if button.GetElementData then
            local okED, ed = pcall(button.GetElementData, button)
            if okED and ed and type(ed) == "table" then
                if ed.objectiveIndex or ed.isObjective or ed.lineID or ed.objectiveText or ed.type == "objective" then
                    return true
                end
            end
        end

        -- Check if frame belongs to objectiveFramePool
        if QuestScrollFrame then
            local objPool = QuestScrollFrame.objectiveFramePool or QuestScrollFrame.ObjectiveFramePool
            if objPool and objPool.EnumerateActive then
                for objFrame in objPool:EnumerateActive() do
                    if objFrame == button then
                        return true
                    end
                end
            end
        end
    end

    -- 2. Check text patterns characteristic of objectives / progress lines
    local raw = text
    if not raw and button then
        local fs = button.Text or button.ButtonText or button.LineText or (button.GetFontString and button:GetFontString())
        if fs and fs.GetText then
            raw = fs:GetText() or ""
        end
    end

    if raw and raw ~= "" then
        -- Progress numbers: e.g. "0/10", "3/5", "1/1"
        if string.find(raw, "%d+/%d+") then
            return true
        end
        -- Bullet points or leading dashes: e.g. "- 0/10", "• Speak with", "- Find the"
        if string.find(raw, "^%s*[%-%•%*]") then
            return true
        end
        -- Turn-in ready status line under quest
        if string.find(raw, "^%s*[Rr]eady for turn") or string.find(raw, "^%s*[Cc]ompleted") then
            return true
        end
    end

    -- 3. Only if NONE of the objective checks matched:
    -- Check if button has genuine quest info (definitively a Quest Title button)
    if button then
        if button.questID and type(button.questID) == "number" and button.questID > 0 then
            return false
        end
        if button.info and not button.info.isHeader and button.info.title then
            return false
        end
        if button.GetElementData then
            local okED, ed = pcall(button.GetElementData, button)
            if okED and ed then
                if type(ed) == "number" and ed > 0 then
                    return false
                elseif type(ed) == "table" then
                    if ed.questID and type(ed.questID) == "number" and ed.questID > 0 and not ed.isHeader then
                        return false
                    end
                    if ed.info and not ed.info.isHeader and ed.info.title then
                        return false
                    end
                end
            end
        end
    end

    return false
end

-- Safely resolves a questID from a Quest Log button across Classic & Modern ScrollBox/Camelot APIs
local function ResolveButtonQuestID(button, rawText)
    if not button then return nil end

    -- 1. Direct button properties
    if button.questID and type(button.questID) == "number" and button.questID > 0 then
        return button.questID
    end
    if button.info and button.info.questID and type(button.info.questID) == "number" and button.info.questID > 0 then
        return button.info.questID
    end
    if button.id and type(button.id) == "number" and button.id > 0 then
        return button.id
    end
    if button.data and button.data.questID and type(button.data.questID) == "number" and button.data.questID > 0 then
        return button.data.questID
    end

    -- 2. Modern ScrollBox ElementData (Dragonflight / Camelot / Midnight / Forever)
    if button.GetElementData then
        local okED, ed = pcall(button.GetElementData, button)
        if okED and ed then
            if type(ed) == "number" and ed > 0 then
                return ed
            elseif type(ed) == "table" then
                if ed.questID and type(ed.questID) == "number" and ed.questID > 0 then
                    return ed.questID
                end
                if ed.info and ed.info.questID and type(ed.info.questID) == "number" and ed.info.questID > 0 then
                    return ed.info.questID
                end
                if ed.id and type(ed.id) == "number" and ed.id > 0 then
                    return ed.id
                end
                if ed.data and ed.data.questID and type(ed.data.questID) == "number" and ed.data.questID > 0 then
                    return ed.data.questID
                end
                if ed.questLogIndex then
                    if C_QuestLog and C_QuestLog.GetInfo then
                        local okI, info = pcall(C_QuestLog.GetInfo, ed.questLogIndex)
                        if okI and info and not info.isHeader and info.questID and info.questID > 0 then
                            return info.questID
                        end
                    end
                    if GetQuestLogTitle then
                        local okT, _, _, _, h, _, _, _, qid = pcall(GetQuestLogTitle, ed.questLogIndex)
                        if okT and not h and qid and qid > 0 then
                            return qid
                        end
                    end
                end
            end
        end
    end

    -- 3. questLogIndex on button
    if button.questLogIndex then
        if C_QuestLog and C_QuestLog.GetInfo then
            local okI, info = pcall(C_QuestLog.GetInfo, button.questLogIndex)
            if okI and info and not info.isHeader and info.questID and info.questID > 0 then
                return info.questID
            end
        end
        if GetQuestLogTitle then
            local okT, _, _, _, h, _, _, _, qid = pcall(GetQuestLogTitle, button.questLogIndex)
            if okT and not h and qid and qid > 0 then
                return qid
            end
        end
    end

    -- 4. GetID() on button
    if button.GetID then
        local btnID = button:GetID()
        if btnID and btnID > 0 then
            if C_QuestLog and C_QuestLog.GetInfo then
                local okI, info = pcall(C_QuestLog.GetInfo, btnID)
                if okI and info and not info.isHeader and info.questID and info.questID > 0 then
                    return info.questID
                end
            elseif GetQuestLogTitle then
                local okT, t, _, _, h, _, _, _, qid = pcall(GetQuestLogTitle, btnID)
                if okT and not h and qid and qid > 0 then
                    return qid
                end
            end
        end
    end

    -- 5. Fallback: Match by normalized quest title against active quest log
    local textToMatch = rawText
    if not textToMatch or textToMatch == "" then
        local fs = button.Text or button.ButtonText or button.LineText or (button.GetFontString and button:GetFontString())
        if fs and fs.GetText then
            textToMatch = fs:GetText()
        end
    end

    local norm = NormalizeQuestTitle(textToMatch)
    if norm and norm ~= "" then
        local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                           or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
        for i = 1, numEntries do
            local qTitle, candidateID, isH
            if C_QuestLog and C_QuestLog.GetInfo then
                local okI, info = pcall(C_QuestLog.GetInfo, i)
                if okI and info then
                    isH = info.isHeader
                    qTitle = info.title
                    candidateID = info.questID
                end
            elseif GetQuestLogTitle then
                local okT, t, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, i)
                if okT then
                    isH = h
                    qTitle = t
                    candidateID = id
                end
            end

            if not isH and candidateID and candidateID > 0 and qTitle and qTitle ~= "" then
                local title = qTitle
                local normQ = NormalizeQuestTitle(qTitle)
                local clean = Utils.CleanQuestTitle(textToMatch)
                local titleNoLevel = string.gsub(clean, "^%s*%[%d+%]%s*", "")
                if normQ ~= "" and (normQ == norm or string.lower(normQ) == string.lower(norm) or title == titleNoLevel or title == clean) then
                    return candidateID
                elseif #title >= 10 and string.find(norm, normQ, 1, true) then
                    return candidateID
                end
            end
        end
    end

    return nil
end
UI.ResolveButtonQuestID = ResolveButtonQuestID

-- Hook fontString:SetText on a quest log button so Blizzard's text updates retain their badge synchronously
local function HookQuestButtonText(button, fontString)
    if not fontString or fontString._worthItHooked then return end
    -- Never hook objective lines or detail frames: prevents interference with Blizzard map hover highlights
    if IsObjectiveOrDetailFrame(button, fontString.GetText and fontString:GetText()) then
        return
    end
    fontString._worthItHooked = true

    hooksecurefunc(fontString, "SetText", function(self, text)
        if self._worthItSettingText then return end
        if addon.db and (addon.db.enabled == false or addon.db.showInQuestLog == false) then return end
        if InCombatLockdown and InCombatLockdown() then return end
        if not text or text == "" then return end

        -- Check if header: NEVER badge zone headers!
        if button then
            if button.isHeader or button.header or (button.info and button.info.isHeader) then
                local clean = Utils.CleanQuestTitle(text)
                if text ~= clean then
                    self._worthItSettingText = true
                    self:SetText(clean)
                    self._worthItSettingText = false
                end
                return
            end
            if button.GetElementData then
                local okED, ed = pcall(button.GetElementData, button)
                if okED and ed and type(ed) == "table" and (ed.isHeader or (ed.info and ed.info.isHeader)) then
                    local clean = Utils.CleanQuestTitle(text)
                    if text ~= clean then
                        self._worthItSettingText = true
                        self:SetText(clean)
                        self._worthItSettingText = false
                    end
                    return
                end
            end
        end

        -- Check if objective or detail line: NEVER badge details/objectives!
        if IsObjectiveOrDetailFrame(button, text) then
            local clean = Utils.CleanQuestTitle(text)
            if text ~= clean then
                self._worthItSettingText = true
                self:SetText(clean)
                self._worthItSettingText = false
            end
            return
        end

        -- Fast skip if text already has badge
        if string.find(text, "%[%d+%%%]") or string.find(text, "%[OK%]") then
            return
        end

        local clean = Utils.CleanQuestTitle(text)
        local cleanTrimmed = string.gsub(clean, "^%s*(.-)%s*$", "%1")
        local cleanZoneName = string.gsub(cleanTrimmed, "%s*%(%d+/?%d*%)%s*$", "")
        if (addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(cleanZoneName))
           or (addon.Scores and addon.Scores.IsNonZoneHeader and addon.Scores.IsNonZoneHeader(cleanZoneName)) then
            if text ~= clean then
                self._worthItSettingText = true
                self:SetText(clean)
                self._worthItSettingText = false
            end
            return
        end

        local qID = ResolveButtonQuestID(button, text)
        if not qID or qID <= 0 then return end

        local worth, breakdown = addon.Engine.CalculateWorth(qID)
        if not worth then return end

        local isComplete = (breakdown and breakdown.isComplete)
        local isHard = (breakdown and breakdown.isHard)
        local isBankable = (breakdown and breakdown.isBankable)
        local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)
        local targetText = badge .. " " .. clean

        if text ~= targetText then
            self._worthItSettingText = true
            self:SetText(targetText)
            self._worthItSettingText = false
        end
    end)
end

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

    -- Guard 1: Objective & Detail filter (Do NOT badge details/objectives under the quest)
    if IsObjectiveOrDetailFrame(button, rawText) then
        if rawText ~= cleanText then
            fontString._worthItSettingText = true
            fontString:SetText(cleanText)
            fontString._worthItSettingText = false
        end
        return
    end

    -- Guard 2: Header filter (Zone headers like "Elwynn Forest", "Duskwood")
    if button.isHeader or button.header or (button.info and button.info.isHeader) then
        if rawText ~= cleanText then
            fontString._worthItSettingText = true
            fontString:SetText(cleanText)
            fontString._worthItSettingText = false
        end
        return
    end
    if button.GetElementData then
        local okED, ed = pcall(button.GetElementData, button)
        if okED and ed and type(ed) == "table" and (ed.isHeader or (ed.info and ed.info.isHeader)) then
            if rawText ~= cleanText then
                fontString._worthItSettingText = true
                fontString:SetText(cleanText)
                fontString._worthItSettingText = false
            end
            return
        end
    end

    local cleanTrimmed = string.gsub(cleanText, "^%s*(.-)%s*$", "%1")
    local cleanZoneName = string.gsub(cleanTrimmed, "%s*%(%d+/?%d*%)%s*$", "")
    if (addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(cleanZoneName))
       or (addon.Scores and addon.Scores.IsNonZoneHeader and addon.Scores.IsNonZoneHeader(cleanZoneName)) then
        if rawText ~= cleanText then
            fontString._worthItSettingText = true
            fontString:SetText(cleanText)
            fontString._worthItSettingText = false
        end
        return
    end

    -- Resolve questID through universal button resolver
    local qID = ResolveButtonQuestID(button, rawText)
    if not qID or qID <= 0 then
        return
    end

    -- Hook text updates for genuine Quest Title Buttons
    HookQuestButtonText(button, fontString)

    -- Hook OnEnter to inject Worth Meter & Meta-Knowledge Payoffs into GameTooltip
    if not button._worthItHoverHooked and button.HookScript then
        button._worthItHoverHooked = true
        button:HookScript("OnEnter", function(self)
            local currentText = fontString and fontString.GetText and fontString:GetText()
            local id = ResolveButtonQuestID(self, currentText)
            if not id and self.questID and type(self.questID) == "number" and self.questID > 0 then
                id = self.questID
            end
            if id and id > 0 and UI.AddWorthLinesToTooltip then
                addon.lastHoveredQuestID = id
                UI.AddWorthLinesToTooltip(GameTooltip, id, true)
            end
        end)
    end

    if not showTag then
        if rawText ~= cleanText then
            fontString._worthItSettingText = true
            fontString:SetText(cleanText)
            fontString._worthItSettingText = false
        end
        return
    end

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then return end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local isBankable = (breakdown and breakdown.isBankable)
    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)
    local targetText = badge .. " " .. cleanText
    if rawText ~= targetText then
        fontString._worthItSettingText = true
        fontString:SetText(targetText)
        fontString._worthItSettingText = false
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
        fontString._worthItSettingText = true
        fontString:SetText(cleanText)
        fontString._worthItSettingText = false
    end
end

-- Function to clean objective frames so details never show a badge
local function CleanObjectiveFrame(frame)
    if not frame then return end
    local fontString = frame.Text or frame.ButtonText or frame.LineText or (frame.GetFontString and frame:GetFontString())
    if fontString and fontString.GetText and fontString.SetText then
        local rawText = fontString:GetText() or ""
        if rawText ~= "" and (string.find(rawText, "%[%d+%%%]") or string.find(rawText, "%[OK%]")) then
            local cleanText = Utils.CleanQuestTitle(rawText)
            if rawText ~= cleanText then
                fontString._worthItSettingText = true
                fontString:SetText(cleanText)
                fontString._worthItSettingText = false
            end
        end
    end
    if frame.GetRegions then
        local ok, regions = pcall(function() return { frame:GetRegions() } end)
        if ok and regions then
            for _, region in ipairs(regions) do
                if region and region.GetObjectType and region:GetObjectType() == "FontString" and region.GetText and region.SetText then
                    local raw = region:GetText() or ""
                    if raw ~= "" and (string.find(raw, "%[%d+%%%]") or string.find(raw, "%[OK%]")) then
                        local clean = Utils.CleanQuestTitle(raw)
                        if raw ~= clean then
                            region._worthItSettingText = true
                            region:SetText(clean)
                            region._worthItSettingText = false
                        end
                    end
                end
            end
        end
    end
end

-- Clean any detail/objective FontStrings in QuestInfoFrame / QuestLogDetailFrame
local function CleanQuestInfoDetails()
    if QuestInfoObjectivesFrame then
        if QuestInfoObjectivesFrame.Objectives then
            for _, fs in pairs(QuestInfoObjectivesFrame.Objectives) do
                if fs and fs.GetText and fs.SetText then
                    local t = fs:GetText() or ""
                    if string.find(t, "%[%d+%%%]") or string.find(t, "%[OK%]") then
                        local ct = Utils.CleanQuestTitle(t)
                        if t ~= ct then
                            fs._worthItSettingText = true
                            fs:SetText(ct)
                            fs._worthItSettingText = false
                        end
                    end
                end
            end
        end
        for i = 1, 10 do
            local fs = _G["QuestInfoObjective" .. i]
            if fs and fs.GetText and fs.SetText then
                local t = fs:GetText() or ""
                if string.find(t, "%[%d+%%%]") or string.find(t, "%[OK%]") then
                    local ct = Utils.CleanQuestTitle(t)
                    if t ~= ct then
                        fs._worthItSettingText = true
                        fs:SetText(ct)
                        fs._worthItSettingText = false
                    end
                end
            end
        end
    end
    if QuestInfoObjectivesText and QuestInfoObjectivesText.GetText and QuestInfoObjectivesText.SetText then
        local t = QuestInfoObjectivesText:GetText() or ""
        if string.find(t, "%[%d+%%%]") or string.find(t, "%[OK%]") then
            local ct = Utils.CleanQuestTitle(t)
            if t ~= ct then
                QuestInfoObjectivesText._worthItSettingText = true
                QuestInfoObjectivesText:SetText(ct)
                QuestInfoObjectivesText._worthItSettingText = false
            end
        end
    end
    if QuestLogObjectivesText and QuestLogObjectivesText.GetText and QuestLogObjectivesText.SetText then
        local t = QuestLogObjectivesText:GetText() or ""
        if string.find(t, "%[%d+%%%]") or string.find(t, "%[OK%]") then
            local ct = Utils.CleanQuestTitle(t)
            if t ~= ct then
                QuestLogObjectivesText._worthItSettingText = true
                QuestLogObjectivesText:SetText(ct)
                QuestLogObjectivesText._worthItSettingText = false
            end
        end
    end
    for i = 1, 10 do
        local fs = _G["QuestLogObjective" .. i]
        if fs and fs.GetText and fs.SetText then
            local t = fs:GetText() or ""
            if string.find(t, "%[%d+%%%]") or string.find(t, "%[OK%]") then
                local ct = Utils.CleanQuestTitle(t)
                if t ~= ct then
                    fs._worthItSettingText = true
                    fs:SetText(ct)
                    fs._worthItSettingText = false
                end
            end
        end
    end
end

-- Master function to update all visible quest entries in Quest Log
function UI.UpdateQuestLog(force)
    if addon.db and addon.db.enabled == false then return end
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

    local ok, err = pcall(function()
        local showTag = not addon.db or (addon.db.enabled ~= false and addon.db.showInQuestLog ~= false)

        -- 1. Modern Blizzard & OpenMap QuestScrollFrame / QuestMapFrame
        local scrollBox = (QuestScrollFrame and QuestScrollFrame.ScrollBox)
                          or (QuestMapFrame and QuestMapFrame.QuestsFrame and QuestMapFrame.QuestsFrame.ScrollBox)

        if QuestScrollFrame then
            local pool = QuestScrollFrame.titleFramePool or QuestScrollFrame.TitleFramePool
            if pool and pool.EnumerateActive then
                for button in pool:EnumerateActive() do
                    if not IsObjectiveOrDetailFrame(button) then
                        ProcessQuestButton(button, showTag)
                    else
                        CleanObjectiveFrame(button)
                    end
                end
            end

            local headerPool = QuestScrollFrame.headerFramePool or QuestScrollFrame.HeaderFramePool
            if headerPool and headerPool.EnumerateActive then
                for button in headerPool:EnumerateActive() do
                    ProcessHeaderButton(button, showTag)
                end
            end
        end

        -- ScrollBox frames handling (Dragonflight / Camelot / Forever)
        if scrollBox then
            local function handleScrollFrame(button)
                if not button or not button:IsShown() then return end

                local isHeader = button.isHeader or button.header or (button.info and button.info.isHeader)
                if not isHeader and button.GetElementData then
                    local okED, ed = pcall(button.GetElementData, button)
                    if okED and ed and type(ed) == "table" then
                        if ed.isHeader or (ed.info and ed.info.isHeader) then
                            isHeader = true
                        end
                    end
                end

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
                elseif IsObjectiveOrDetailFrame(button) then
                    CleanObjectiveFrame(button)
                else
                    ProcessQuestButton(button, showTag)
                end
            end

            if scrollBox.ForEachFrame then
                pcall(function()
                    scrollBox:ForEachFrame(handleScrollFrame)
                end)
            elseif scrollBox.GetFrames then
                local okF, frames = pcall(scrollBox.GetFrames, scrollBox)
                if okF and frames then
                    for _, button in ipairs(frames) do
                        handleScrollFrame(button)
                    end
                end
            end
        end

        -- Contents frame children fallback
        local contents = (QuestScrollFrame and QuestScrollFrame.Contents)
                         or (QuestMapFrame and QuestMapFrame.QuestsFrame and QuestMapFrame.QuestsFrame.Contents)
        if contents and contents.GetChildren then
            local okC, children = pcall(function() return { contents:GetChildren() } end)
            if okC and children then
                for _, button in ipairs(children) do
                    if button and button:IsShown() then
                        local isHeader = button.isHeader or button.header or (button.info and button.info.isHeader)
                        if not isHeader and button.GetElementData then
                            local okED, ed = pcall(button.GetElementData, button)
                            if okED and ed and type(ed) == "table" then
                                if ed.isHeader or (ed.info and ed.info.isHeader) then
                                    isHeader = true
                                end
                            end
                        end

                        if isHeader then
                            ProcessHeaderButton(button, showTag)
                        elseif IsObjectiveOrDetailFrame(button) then
                            CleanObjectiveFrame(button)
                        else
                            ProcessQuestButton(button, showTag)
                        end
                    end
                end
            end
        end

        if QuestScrollFrame then
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
                    local okT, qTitle, _, _, isHeader, _, isComplete, _, qID = pcall(GetQuestLogTitle, questIndex)
                    local fontString = button.normalText or _G[button:GetName() .. "NormalText"] or (button.GetFontString and button:GetFontString()) or button.Text
                    if fontString and fontString.GetText and fontString.SetText then
                        local rawTitle = fontString:GetText() or ""
                        local cleanTitle = Utils.CleanQuestTitle(rawTitle)
                        if okT and qTitle and not isHeader then
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
                                        local isBankable = (breakdown and breakdown.isBankable)
                                        local badge = Utils.FormatBadge(worth, comp, isHard, isBankable)
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
                                local isBankable = (breakdown and breakdown.isBankable)
                                local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)
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

        -- Clean any detail/objective FontStrings in QuestInfoFrame / QuestLogDetailFrame
        CleanQuestInfoDetails()
    end)

    addon.isUpdatingUI = false
    if not ok and err and addon.Debug then
        addon.Debug("Error in UpdateQuestLog: " .. tostring(err))
    end
end

-- Helper to locate the header FontString on an Objective Tracker block across Classic & Modern clients
local function GetBlockHeaderFontString(block)
    if not block then return nil end
    -- Guard: Never treat line frames or tracker modules as blocks!
    if block.lineIndex or block.isLine then return nil end
    if block == QuestObjectiveTracker or block == CampaignQuestObjectiveTracker or block == WorldQuestObjectiveTracker then
        return nil
    end

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
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo then
        local ok, num = pcall(C_QuestLog.GetNumQuestLogEntries)
        if ok and num and num > 0 then
            for i = 1, num do
                local ok2, info = pcall(C_QuestLog.GetInfo, i)
                if ok2 and info and info.questID == questID then return true end
            end
        end
    end
    if GetNumQuestLogEntries and GetQuestLogTitle then
        local ok, num = pcall(GetNumQuestLogEntries)
        if ok and num and num > 0 then
            for i = 1, num do
                local ok3, _, _, _, isH, _, _, _, id = pcall(GetQuestLogTitle, i)
                if ok3 and not isH and id == questID then return true end
            end
        end
    end
    return false
end

-- Helper to safely resolve a questID from an Objective Tracker block or header text
local function ResolveBlockQuestID(block, currentText, activeQuests, titleToID)
    if not block then return nil end

    -- Fast path: cached on block
    if block._worthItQuestID and block._worthItQuestID > 0 then
        local raw = currentText or ""
        if raw ~= "" and block._worthItQuestTitle and block._worthItQuestTitle == raw then
            return block._worthItQuestID
        end
    end

    -- 1. Direct properties on the block (in QuestObjectiveTracker, block.id or block.questID IS the questID)
    if block.questID and type(block.questID) == "number" and block.questID > 0 then
        block._worthItQuestID = block.questID
        block._worthItQuestTitle = currentText or ""
        return block.questID
    end
    if block.id and type(block.id) == "number" and block.id > 0 then
        block._worthItQuestID = block.id
        block._worthItQuestTitle = currentText or ""
        return block.id
    end
    if block.GetQuestID then
        local ok, qid = pcall(block.GetQuestID, block)
        if ok and qid and type(qid) == "number" and qid > 0 then
            block._worthItQuestID = qid
            block._worthItQuestTitle = currentText or ""
            return qid
        end
    end
    if block.Header then
        if block.Header.questID and type(block.Header.questID) == "number" and block.Header.questID > 0 then
            block._worthItQuestID = block.Header.questID
            block._worthItQuestTitle = currentText or ""
            return block.Header.questID
        end
        if block.Header.id and type(block.Header.id) == "number" and block.Header.id > 0 then
            block._worthItQuestID = block.Header.id
            block._worthItQuestTitle = currentText or ""
            return block.Header.id
        end
    end

    -- 2. questLogIndex
    if block.questLogIndex and C_QuestLog and C_QuestLog.GetInfo then
        local ok, info = pcall(C_QuestLog.GetInfo, block.questLogIndex)
        if ok and info and not info.isHeader and info.questID and info.questID > 0 then
            block._worthItQuestID = info.questID
            block._worthItQuestTitle = currentText or ""
            return info.questID
        end
    end

    -- 3. Match by Quest Title (table lookup or scan)
    local text = currentText or ""
    if text == "" then
        local fs = GetBlockHeaderFontString(block)
        if fs and fs.GetText then
            text = fs:GetText() or ""
        end
    end

    if text and text ~= "" then
        local norm = NormalizeQuestTitle(text)
        local clean = Utils.CleanQuestTitle(text)
        local titleNoLevel = string.gsub(clean, "^%s*%[%d+%]%s*", "")
        clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
        titleNoLevel = string.gsub(titleNoLevel, "^%s*(.-)%s*$", "%1")

        local matchedID = nil
        if titleToID then
            if norm ~= "" and titleToID[norm] then
                matchedID = titleToID[norm]
            elseif norm ~= "" and titleToID[string.lower(norm)] then
                matchedID = titleToID[string.lower(norm)]
            elseif titleToID[clean] then
                matchedID = titleToID[clean]
            elseif titleToID[titleNoLevel] then
                matchedID = titleToID[titleNoLevel]
            end
        end

        -- Direct fallback scan if titleToID missed
        if not matchedID then
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
                    local ok, t, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, i)
                    if ok and not h then
                        qTitle = t
                        qid = id
                    end
                end

                if qTitle and qid and qid > 0 then
                    local normQ = NormalizeQuestTitle(qTitle)
                    if normQ ~= "" and (normQ == norm or string.lower(normQ) == string.lower(norm)) then
                        matchedID = qid
                        break
                    end
                end
            end
        end

        if matchedID and matchedID > 0 then
            block._worthItQuestID = matchedID
            block._worthItQuestTitle = text
            return matchedID
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
        if addon.db and (addon.db.enabled == false or addon.db.showInTracker == false) then return end
        if InCombatLockdown and InCombatLockdown() then return end
        if not text or text == "" then return end

        -- Fast skip if text already has badge
        if string.find(text, "%[%d+%%%]") or string.find(text, "%[OK%]") then
            return
        end

        local clean = Utils.CleanQuestTitle(text)
        local qID = ResolveBlockQuestID(block, clean)
        if not qID or qID <= 0 then return end

        local worth, breakdown = addon.Engine.CalculateWorth(qID)
        if not worth then return end

        local isComplete = (breakdown and breakdown.isComplete)
        local isHard = (breakdown and breakdown.isHard)
        local isBankable = (breakdown and breakdown.isBankable)
        local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)
        local targetText = badge .. " " .. clean

        if text ~= targetText then
            self._worthItSettingText = true
            self:SetText(targetText)
            self._worthItSettingText = false
        end
    end)
    block._worthItTextHooked = true
end

-- Apply badge to a single Objective Tracker block header (leaves objective detail lines 100% untouched)
local function BadgeObjectiveBlock(block, activeQuests, titleToID)
    if not block then return end
    local fontString = GetBlockHeaderFontString(block)
    if not (fontString and fontString.GetText and fontString.SetText) then return end
    if addon.db and addon.db.enabled == false then return end
    if InCombatLockdown and InCombatLockdown() then return end

    local rawText = fontString:GetText() or ""
    if rawText == "" then return end
    local cleanText = Utils.CleanQuestTitle(rawText)

    local showTag = not addon.db or (addon.db.enabled ~= false and addon.db.showInTracker ~= false)
    if not showTag then
        if rawText ~= cleanText then
            fontString._worthItSettingText = true
            fontString:SetText(cleanText)
            fontString._worthItSettingText = false
        end
        return
    end

    local qID = ResolveBlockQuestID(block, rawText, activeQuests, titleToID)
    if not qID or qID <= 0 then return end

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then return end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local isBankable = (breakdown and breakdown.isBankable)
    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)
    local targetText = badge .. " " .. cleanText

    if rawText ~= targetText then
        fontString._worthItSettingText = true
        fontString:SetText(targetText)
        fontString._worthItSettingText = false
    end

    -- Hook OnEnter to inject Worth Meter & Meta-Knowledge into Tracker Tooltips
    if not block._worthItHoverHooked and block.HookScript then
        block._worthItHoverHooked = true
        block:HookScript("OnEnter", function(self)
            local id = qID or ResolveBlockQuestID(self, cleanText, activeQuests, titleToID)
            if id and id > 0 and UI.AddWorthLinesToTooltip then
                addon.lastHoveredQuestID = id
                UI.AddWorthLinesToTooltip(GameTooltip, id, true)
            end
        end)
    end
    if block.Header and not block.Header._worthItHoverHooked and block.Header.HookScript then
        block.Header._worthItHoverHooked = true
        block.Header:HookScript("OnEnter", function(self)
            local id = qID or ResolveBlockQuestID(block, cleanText, activeQuests, titleToID)
            if id and id > 0 and UI.AddWorthLinesToTooltip then
                addon.lastHoveredQuestID = id
                UI.AddWorthLinesToTooltip(GameTooltip, id, true)
            end
        end)
    end
end

-- Dynamic module list getter (QUEST MODULES ONLY across Classic & Modern clients)
local function GetModuleList()
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

    if ObjectiveTrackerFrame and ObjectiveTrackerFrame.MODULES then
        for _, mod in ipairs(ObjectiveTrackerFrame.MODULES) do
            add(mod)
        end
    end

    return list
end

function UI.InvalidateModuleListCache()
    -- Kept for API compatibility; GetModuleList is now always dynamic
end

local _lastTrackerUpdate = 0
local _isUpdatingTracker = false

-- Master function to update all visible quest entries in the Objective Tracker
function UI.UpdateObjectiveTracker(force)
    if addon.db and addon.db.enabled == false then return end
    if InCombatLockdown and InCombatLockdown() then return end
    if _isUpdatingTracker then return end

    local now = GetTime()
    if not force and (now - _lastTrackerUpdate) < 0.10 then return end
    _lastTrackerUpdate = now

    _isUpdatingTracker = true

    local ok, err = pcall(function()
        -- Ensure any newly loaded tracker modules are hooked
        if UI.HookTrackerModules then
            UI.HookTrackerModules()
        end

        -- Precompute active quests & fast title lookup table once for this cycle
        local activeQuests = {}
        local titleToID = {}
        local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                           or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0

        for i = 1, numEntries do
            local qTitle, qid, isH
            if C_QuestLog and C_QuestLog.GetInfo then
                local okI, info = pcall(C_QuestLog.GetInfo, i)
                if okI and info then
                    isH = info.isHeader
                    qTitle = info.title
                    qid = info.questID
                end
            elseif GetQuestLogTitle then
                local okT, t, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, i)
                if okT then
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
                    local norm = NormalizeQuestTitle(qTitle)

                    titleToID[clean] = qid
                    titleToID[noLevel] = qid
                    if norm ~= "" then
                        titleToID[norm] = qid
                        titleToID[string.lower(norm)] = qid
                    end
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
                    local okE = pcall(function()
                        for block in mod:EnumerateBlocks() do
                            ProcessBlock(block)
                            enumerated = true
                        end
                    end)
                    if not okE then enumerated = false end
                end

                -- Modern Dragonflight FramePoolCollection: mod.blockPools
                if not enumerated and mod.blockPools and mod.blockPools.EnumerateActive then
                    local okP = pcall(function()
                        for block in mod.blockPools:EnumerateActive() do
                            ProcessBlock(block)
                            enumerated = true
                        end
                    end)
                    if not okP then enumerated = false end
                end

                -- Legacy pool: mod.blockPool
                if not enumerated and mod.blockPool and mod.blockPool.EnumerateActive then
                    local okP = pcall(function()
                        for block in mod.blockPool:EnumerateActive() do
                            ProcessBlock(block)
                            enumerated = true
                        end
                    end)
                    if not okP then enumerated = false end
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

        -- 2. Fallback: Recursive container frame scanning (handles nested modern tracker structures)
        local containers = {
            ObjectiveTrackerBlocksFrame,
            ObjectiveTrackerFrame and ObjectiveTrackerFrame.BlocksFrame,
            ObjectiveTrackerFrame,
        }

        local function ScanContainerTree(frame, depth)
            if not frame or depth > 4 then return end
            if GetBlockHeaderFontString(frame) then
                ProcessBlock(frame)
            end
            if frame.GetChildren then
                local okC, kids = pcall(function() return { frame:GetChildren() } end)
                if okC and kids then
                    for _, child in ipairs(kids) do
                        if child and child:IsShown() then
                            ScanContainerTree(child, depth + 1)
                        end
                    end
                end
            end
        end

        for _, container in ipairs(containers) do
            if container then
                ScanContainerTree(container, 1)
            end
        end
    end)

    _isUpdatingTracker = false
    if not ok and err and addon.Debug then
        addon.Debug("Error in UpdateObjectiveTracker: " .. tostring(err))
    end
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

    -- Hook ObjectiveTrackerManager.Update (modern Midnight / Dragonflight manager)
    if ObjectiveTrackerManager and ObjectiveTrackerManager.Update and not ObjectiveTrackerManager._worthItHooked then
        hooksecurefunc(ObjectiveTrackerManager, "Update", function()
            if not _isUpdatingTracker then
                UI.UpdateObjectiveTracker()
            end
        end)
        ObjectiveTrackerManager._worthItHooked = true
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

    -- Note: Do NOT hook QuestMapFrame_ShowQuestDetails or SelectQuestLogEntry here.
    -- Selecting a quest or viewing details does not change Worth % scores,
    -- and triggering UpdateQuestLog on selection causes redundant UI redraws and map flickering.

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
