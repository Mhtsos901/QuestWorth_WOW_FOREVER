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
local _needsQuestLogLayout = false

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

-- Verify candidate questID matches rawText when rawText is known (guards against stale recycled frames)
local function DoesQuestIDMatchTitle(questID, rawText)
    if not questID or type(questID) ~= "number" or questID <= 0 then return false end
    local normRaw = NormalizeQuestTitle(rawText)
    if not normRaw or normRaw == "" or #normRaw < 3 then
        return true
    end
    local qTitle = nil
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local okT, t = pcall(C_QuestLog.GetTitleForQuestID, questID)
        if okT and type(t) == "string" and t ~= "" then
            qTitle = t
        end
    end
    if (not qTitle or qTitle == "") and Utils.GetQuestBasicInfo then
        local info = Utils.GetQuestBasicInfo(questID)
        if info and type(info.title) == "string" and info.title ~= "" then
            qTitle = info.title
        end
    end
    if not qTitle or qTitle == "" then
        return true
    end
    local normQ = NormalizeQuestTitle(qTitle)
    if normQ == "" then return true end
    local lRaw = string.lower(normRaw)
    local lQ = string.lower(normQ)
    if lRaw == lQ then return true end
    local ellipsisPrefix = string.match(lRaw, "^(.-)%.%.%.$")
    if ellipsisPrefix and #ellipsisPrefix >= 4 and string.sub(lQ, 1, #ellipsisPrefix) == ellipsisPrefix then
        return true
    end
    return false
end

-- Safely resolves a questID from a Quest Log button across Classic & Modern ScrollBox/Camelot APIs
local function ResolveButtonQuestID(button, rawText)
    if not button then return nil end

    -- Resolve effective text for stale recycled-button verification
    local textToMatch = rawText
    if not textToMatch or textToMatch == "" then
        local fs = button.Text or button.ButtonText or button.LineText or (button.GetFontString and button:GetFontString())
        if fs and fs.GetText then
            textToMatch = fs:GetText()
        end
    end

    -- 1. Direct button properties (verified against visible title when present)
    if button.questID and type(button.questID) == "number" and button.questID > 0 and DoesQuestIDMatchTitle(button.questID, textToMatch) then
        return button.questID
    end
    if button.info and button.info.questID and type(button.info.questID) == "number" and button.info.questID > 0 and DoesQuestIDMatchTitle(button.info.questID, textToMatch) then
        return button.info.questID
    end
    if button.id and type(button.id) == "number" and button.id > 0 and DoesQuestIDMatchTitle(button.id, textToMatch) then
        return button.id
    end
    if button.data and button.data.questID and type(button.data.questID) == "number" and button.data.questID > 0 and DoesQuestIDMatchTitle(button.data.questID, textToMatch) then
        return button.data.questID
    end

    -- 2. Modern ScrollBox ElementData (Dragonflight / Camelot / Midnight / Forever)
    if button.GetElementData then
        local okED, ed = pcall(button.GetElementData, button)
        if okED and ed then
            if type(ed) == "number" and ed > 0 and DoesQuestIDMatchTitle(ed, textToMatch) then
                return ed
            elseif type(ed) == "table" then
                if ed.questID and type(ed.questID) == "number" and ed.questID > 0 and DoesQuestIDMatchTitle(ed.questID, textToMatch) then
                    return ed.questID
                end
                if ed.info and ed.info.questID and type(ed.info.questID) == "number" and ed.info.questID > 0 and DoesQuestIDMatchTitle(ed.info.questID, textToMatch) then
                    return ed.info.questID
                end
                if ed.id and type(ed.id) == "number" and ed.id > 0 and DoesQuestIDMatchTitle(ed.id, textToMatch) then
                    return ed.id
                end
                if ed.data and ed.data.questID and type(ed.data.questID) == "number" and ed.data.questID > 0 and DoesQuestIDMatchTitle(ed.data.questID, textToMatch) then
                    return ed.data.questID
                end
                if ed.questLogIndex then
                    if C_QuestLog and C_QuestLog.GetInfo then
                        local okI, info = pcall(C_QuestLog.GetInfo, ed.questLogIndex)
                        if okI and info and not info.isHeader and info.questID and info.questID > 0 and DoesQuestIDMatchTitle(info.questID, textToMatch) then
                            return info.questID
                        end
                    end
                    if GetQuestLogTitle then
                        local okT, _, _, _, h, _, _, _, qid = pcall(GetQuestLogTitle, ed.questLogIndex)
                        if okT and not h and qid and qid > 0 and DoesQuestIDMatchTitle(qid, textToMatch) then
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
            if okI and info and not info.isHeader and info.questID and info.questID > 0 and DoesQuestIDMatchTitle(info.questID, textToMatch) then
                return info.questID
            end
        end
        if GetQuestLogTitle then
            local okT, _, _, _, h, _, _, _, qid = pcall(GetQuestLogTitle, button.questLogIndex)
            if okT and not h and qid and qid > 0 and DoesQuestIDMatchTitle(qid, textToMatch) then
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
                if okI and info and not info.isHeader and info.questID and info.questID > 0 and DoesQuestIDMatchTitle(info.questID, textToMatch) then
                    return info.questID
                end
            elseif GetQuestLogTitle then
                local okT, t, _, _, h, _, _, _, qid = pcall(GetQuestLogTitle, btnID)
                if okT and not h and qid and qid > 0 and DoesQuestIDMatchTitle(qid, textToMatch) then
                    return qid
                end
            end
        end
    end

    -- 5. Fallback: Match by normalized quest title against active quest log
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

-- Show or append WorthIt lines onto GameTooltip, replacing unrelated world tooltips (e.g. props behind tracker)
local function ShowOrAppendQuestTooltip(widget, questID)
    if not questID or questID <= 0 or not GameTooltip then return end
    addon.lastHoveredQuestID = questID
    if not (addon.db and addon.db.enabled ~= false and addon.db.showInTooltip ~= false) then return end

    local tipShown = GameTooltip.IsShown and GameTooltip:IsShown()
    local line1 = _G["GameTooltipTextLeft1"] and _G["GameTooltipTextLeft1"].GetText and _G["GameTooltipTextLeft1"]:GetText()
    local matchesShownQuest = false

    if tipShown and line1 and line1 ~= "" and DoesQuestIDMatchTitle(questID, line1) then
        matchesShownQuest = true
    end

    if matchesShownQuest and UI.AddWorthLinesToTooltip then
        UI.AddWorthLinesToTooltip(GameTooltip, questID, true)
    elseif UI.ShowQuestTooltip then
        UI.ShowQuestTooltip(GameTooltip, questID, widget)
    elseif UI.AddWorthLinesToTooltip then
        UI.AddWorthLinesToTooltip(GameTooltip, questID, true)
    end
end

local function HookQuestWidgetHover(widget, resolveQuestID)
    if not (widget and widget.HookScript) then return end
    if not widget._worthItHoverHooked then
        widget._worthItHoverHooked = true
        widget:HookScript("OnEnter", function(self)
            if addon.db and addon.db.enabled == false then return end
            local id = resolveQuestID(self)
            if id and id > 0 then
                ShowOrAppendQuestTooltip(self, id)
            end
        end)
    end
    if not widget._worthItLeaveHooked then
        widget._worthItLeaveHooked = true
        widget:HookScript("OnLeave", function(self)
            if GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner() == self and GameTooltip.Hide then
                GameTooltip:Hide()
            end
        end)
    end
end

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
        if InCombatLockdown and InCombatLockdown() then
            addon._questLogCombatDeferred = true
            return
        end
        if not text or text == "" then return end

        -- Fresh Blizzard assignment resets tracked badge height delta
        if button and not (string.find(text, "%[%d+%%%]") or string.find(text, "%[OK%]")) then
            button._qwAddedHeight = 0
        end

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
        local isLowValue = (breakdown and breakdown.isLowValue)
        local isMeta = (breakdown and breakdown.isMeta)
        local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable, isLowValue, isMeta)
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

    -- Hook OnEnter/OnLeave to inject Worth Meter & Meta-Knowledge Payoffs into GameTooltip
    HookQuestWidgetHover(button, function(self)
        local currentText = fontString and fontString.GetText and fontString:GetText()
        local id = ResolveButtonQuestID(self, currentText)
        if not id and self.questID and type(self.questID) == "number" and self.questID > 0 then
            id = self.questID
        end
        return id
    end)

    if not showTag then
        if rawText ~= cleanText then
            fontString._worthItSettingText = true
            fontString:SetText(cleanText)
            fontString._worthItSettingText = false
        end
        if button._qwAddedHeight and button._qwAddedHeight > 0 and button.GetHeight and button.SetHeight then
            button:SetHeight(math.max(12, (button:GetHeight() or 16) - button._qwAddedHeight))
            button._qwAddedHeight = 0
            _needsQuestLogLayout = true
        end
        return
    end

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then return end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local isBankable = (breakdown and breakdown.isBankable)
    local isLowValue = (breakdown and breakdown.isLowValue)
    local isMeta = (breakdown and breakdown.isMeta)
    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable, isLowValue, isMeta)
    local targetText = badge .. " " .. cleanText
    if rawText ~= targetText then
        if not (string.find(rawText, "%[%d+%%%]") or string.find(rawText, "%[OK%]")) then
            button._qwAddedHeight = 0
        end
        local beforeH = fontString.GetStringHeight and fontString:GetStringHeight()
        fontString._worthItSettingText = true
        fontString:SetText(targetText)
        fontString._worthItSettingText = false
        local afterH = fontString.GetStringHeight and fontString:GetStringHeight()
        if beforeH and afterH and button.GetHeight and button.SetHeight then
            local delta = afterH - beforeH
            if math.abs(delta) > 1.5 then
                local newAdded = math.max(0, (button._qwAddedHeight or 0) + delta)
                local actualDelta = newAdded - (button._qwAddedHeight or 0)
                if math.abs(actualDelta) > 1.5 then
                    button:SetHeight(math.max(12, (button:GetHeight() or 16) + actualDelta))
                    button._qwAddedHeight = newAdded
                    _needsQuestLogLayout = true
                end
            end
        end
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
        return
    end
    if frame.GetRegions and frame.GetNumRegions then
        local okN, numRegions = pcall(frame.GetNumRegions, frame)
        if okN and numRegions and numRegions > 0 then
            for r = 1, numRegions do
                local region = select(r, frame:GetRegions())
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
    if QuestInfoObjectivesFrame and (not QuestInfoObjectivesFrame.IsShown or QuestInfoObjectivesFrame:IsShown()) then
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
        if _G["QuestInfoObjective1"] then
            for i = 1, 10 do
                local fs = _G["QuestInfoObjective" .. i]
                if not fs then break end
                if fs.GetText and fs.SetText then
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
    end
    if QuestInfoObjectivesText and QuestInfoObjectivesText.GetText and QuestInfoObjectivesText.SetText
       and ((not QuestInfoObjectivesFrame) or (not QuestInfoObjectivesFrame.IsShown) or QuestInfoObjectivesFrame:IsShown()) then
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
    if (QuestLogDetailScrollFrame and (not QuestLogDetailScrollFrame.IsShown or QuestLogDetailScrollFrame:IsShown()))
       or QuestLogObjectivesText or _G["QuestLogObjective1"] then
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
        if _G["QuestLogObjective1"] then
            for i = 1, 10 do
                local fs = _G["QuestLogObjective" .. i]
                if not fs then break end
                if fs.GetText and fs.SetText then
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
    end
end

-- Master function to update all visible quest entries in Quest Log
function UI.UpdateQuestLog(force)
    if InCombatLockdown and InCombatLockdown() then
        addon._questLogCombatDeferred = true
        return
    end
    if addon.isUpdatingUI then
        if not _questLogUpdatePending and C_Timer and C_Timer.After then
            _questLogUpdatePending = true
            C_Timer.After(0.05, function()
                _questLogUpdatePending = false
                UI.UpdateQuestLog(true)
            end)
        end
        return
    end

    local now = GetTime()
    if not force and (now - _lastQuestLogUpdate) < 0.12 then
        if not _questLogUpdatePending then
            _questLogUpdatePending = true
            if C_Timer and C_Timer.After then
                C_Timer.After(0.12, function()
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
    addon._questLogCombatDeferred = false
    _needsQuestLogLayout = false

    addon.isUpdatingUI = true

    local ok, err = pcall(function()
        local showTag = not addon.db or (addon.db.enabled ~= false and addon.db.showInQuestLog ~= false)

        -- 1. Modern Blizzard & OpenMap QuestScrollFrame / QuestMapFrame
        local scrollBox = (QuestScrollFrame and QuestScrollFrame.ScrollBox)
                          or (QuestMapFrame and QuestMapFrame.QuestsFrame and QuestMapFrame.QuestsFrame.ScrollBox)
        local handledModernFrames = false

        if QuestScrollFrame then
            local pool = QuestScrollFrame.titleFramePool or QuestScrollFrame.TitleFramePool
            if pool and pool.EnumerateActive then
                for button in pool:EnumerateActive() do
                    handledModernFrames = true
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
                handledModernFrames = true

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

        -- Contents frame children fallback (only if pools/ScrollBox yielded no frames)
        if not handledModernFrames then
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
        local handledClassicQuestLog = false
        if QuestLogFrame and QuestLogFrame:IsShown() then
            local numQuests = QUESTS_DISPLAYED or 25
            local scrollOffset = (FauxScrollFrame_GetOffset and QuestLogScrollFrame and FauxScrollFrame_GetOffset(QuestLogScrollFrame)) or 0
            for i = 1, numQuests do
                local button = _G["QuestLogTitle" .. i]
                if button and button:IsShown() then
                    handledClassicQuestLog = true
                    local questIndex = i + scrollOffset
                    local okT, qTitle, _, _, isHeader, _, isComplete, _, qID = pcall(GetQuestLogTitle, questIndex)
                    local fontString = button.normalText or _G[button:GetName() .. "NormalText"] or (button.GetFontString and button:GetFontString()) or button.Text
                    if fontString and fontString.GetText and fontString.SetText then
                        local rawTitle = fontString:GetText() or ""
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
                                        local isLowValue = (breakdown and breakdown.isLowValue)
                                        local isMeta = (breakdown and breakdown.isMeta)
                                        local showMeta = isMeta and (not addon.db or addon.db.showMetaIndicator ~= false)
                                        if not (rawTitle == fontString._qwLastTarget and fontString._qwLastID == id
                                           and fontString._qwLastWorth == worth and fontString._qwLastComp == comp
                                           and fontString._qwLastHard == isHard and fontString._qwLastBankable == isBankable
                                           and fontString._qwLastLowValue == isLowValue and fontString._qwLastMeta == showMeta) then
                                            local cleanTitle = Utils.CleanQuestTitle(rawTitle)
                                            local badge = Utils.FormatBadge(worth, comp, isHard, isBankable, isLowValue, isMeta)
                                            local targetText = badge .. " " .. cleanTitle
                                            fontString._qwLastTarget = targetText
                                            fontString._qwLastID = id
                                            fontString._qwLastWorth = worth
                                            fontString._qwLastComp = comp
                                            fontString._qwLastHard = isHard
                                            fontString._qwLastBankable = isBankable
                                            fontString._qwLastLowValue = isLowValue
                                            fontString._qwLastMeta = showMeta
                                            if rawTitle ~= targetText then
                                                fontString:SetText(targetText)
                                            end
                                        end
                                    end
                                end
                            else
                                local cleanTitle = Utils.CleanQuestTitle(rawTitle)
                                fontString._qwLastTarget = nil
                                if rawTitle ~= cleanTitle then
                                    fontString:SetText(cleanTitle)
                                end
                            end
                        elseif isHeader then
                            fontString._qwLastTarget = nil
                            ProcessHeaderButton(button, showTag)
                        end
                    end
                end
            end
        end

        -- 3. Classic QuestLogListScrollFrame fallback (WotLK / Classic hybrid)
        if not handledClassicQuestLog and QuestLogListScrollFrame and QuestLogListScrollFrame.buttons
           and (not QuestLogListScrollFrame.IsShown or QuestLogListScrollFrame:IsShown()) then
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
                                local isLowValue = (breakdown and breakdown.isLowValue)
                                local isMeta = (breakdown and breakdown.isMeta)
                                local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable, isLowValue, isMeta)
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

        if _needsQuestLogLayout and QuestScrollFrame and QuestScrollFrame.Contents and QuestScrollFrame.Contents.Layout then
            _needsQuestLogLayout = false
            pcall(QuestScrollFrame.Contents.Layout, QuestScrollFrame.Contents)
        end
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

-- Shared scratch state for Objective Tracker updates (zero per-refresh closures/tables)
local _moduleListSeen = {}
local _moduleListOut = {}
local _trackerActiveQuests = {}
local _trackerRawTitles = {}
local _trackerTitleToID = {}
local _trackerTitleIndexBuilt = false
local _trackerProcessedBlocks = {}
local _trackerEnumerated = false
local _trackerContainers = {}
local _trackerCurrentModules = nil

local function EnsureTrackerTitleIndex()
    if _trackerTitleIndexBuilt then
        return _trackerTitleToID
    end
    for qid, qTitle in pairs(_trackerRawTitles) do
        if qTitle and qTitle ~= "" then
            local clean = Utils.CleanQuestTitle(qTitle)
            local noLevel = string.gsub(clean, "^%s*%[%d+%]%s*", "")
            clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
            noLevel = string.gsub(noLevel, "^%s*(.-)%s*$", "%1")
            local norm = NormalizeQuestTitle(qTitle)

            _trackerTitleToID[clean] = qid
            _trackerTitleToID[noLevel] = qid
            if norm ~= "" then
                _trackerTitleToID[norm] = qid
                _trackerTitleToID[string.lower(norm)] = qid
            end
        end
    end
    _trackerTitleIndexBuilt = true
    return _trackerTitleToID
end

-- Helper to safely resolve a questID from an Objective Tracker block or header text
local function ResolveBlockQuestID(block, currentText, activeQuests, titleToID)
    if not block then return nil end

    local text = currentText or ""
    if text == "" then
        local fs = GetBlockHeaderFontString(block)
        if fs and fs.GetText then
            text = fs:GetText() or ""
        end
    end

    -- Fast path: cached on block (verified against title)
    if block._worthItQuestID and block._worthItQuestID > 0 then
        if text ~= "" and block._worthItQuestTitle and block._worthItQuestTitle == text and DoesQuestIDMatchTitle(block._worthItQuestID, text) then
            return block._worthItQuestID
        end
    end

    -- 1. Direct properties on the block (in QuestObjectiveTracker, block.id or block.questID IS the questID)
    if block.questID and type(block.questID) == "number" and block.questID > 0 and DoesQuestIDMatchTitle(block.questID, text) then
        block._worthItQuestID = block.questID
        block._worthItQuestTitle = text
        return block.questID
    end
    if block.id and type(block.id) == "number" and block.id > 0 and DoesQuestIDMatchTitle(block.id, text) then
        block._worthItQuestID = block.id
        block._worthItQuestTitle = text
        return block.id
    end
    if block.GetQuestID then
        local ok, qid = pcall(block.GetQuestID, block)
        if ok and qid and type(qid) == "number" and qid > 0 and DoesQuestIDMatchTitle(qid, text) then
            block._worthItQuestID = qid
            block._worthItQuestTitle = text
            return qid
        end
    end
    if block.Header then
        if block.Header.questID and type(block.Header.questID) == "number" and block.Header.questID > 0 and DoesQuestIDMatchTitle(block.Header.questID, text) then
            block._worthItQuestID = block.Header.questID
            block._worthItQuestTitle = text
            return block.Header.questID
        end
        if block.Header.id and type(block.Header.id) == "number" and block.Header.id > 0 and DoesQuestIDMatchTitle(block.Header.id, text) then
            block._worthItQuestID = block.Header.id
            block._worthItQuestTitle = text
            return block.Header.id
        end
    end

    -- 2. questLogIndex
    if block.questLogIndex and C_QuestLog and C_QuestLog.GetInfo then
        local ok, info = pcall(C_QuestLog.GetInfo, block.questLogIndex)
        if ok and info and not info.isHeader and info.questID and info.questID > 0 and DoesQuestIDMatchTitle(info.questID, text) then
            block._worthItQuestID = info.questID
            block._worthItQuestTitle = text
            return info.questID
        end
    end

    -- 3. Match by Quest Title (table lookup or scan)

    if text and text ~= "" then
        local norm = NormalizeQuestTitle(text)
        local clean = Utils.CleanQuestTitle(text)
        local titleNoLevel = string.gsub(clean, "^%s*%[%d+%]%s*", "")
        clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
        titleNoLevel = string.gsub(titleNoLevel, "^%s*(.-)%s*$", "%1")

        local matchedID = nil
        local lookupTitleToID = titleToID or (next(_trackerRawTitles) and EnsureTrackerTitleIndex() or nil)
        if lookupTitleToID then
            if norm ~= "" and lookupTitleToID[norm] then
                matchedID = lookupTitleToID[norm]
            elseif norm ~= "" and lookupTitleToID[string.lower(norm)] then
                matchedID = lookupTitleToID[string.lower(norm)]
            elseif lookupTitleToID[clean] then
                matchedID = lookupTitleToID[clean]
            elseif lookupTitleToID[titleNoLevel] then
                matchedID = lookupTitleToID[titleNoLevel]
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
        if InCombatLockdown and InCombatLockdown() then
            addon._trackerCombatDeferred = true
            return
        end
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
        local isLowValue = (breakdown and breakdown.isLowValue)
        local isMeta = (breakdown and breakdown.isMeta)
        local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable, isLowValue, isMeta)
        local targetText = badge .. " " .. clean

        if text ~= targetText then
            self._worthItSettingText = true
            self:SetText(targetText)
            self._worthItSettingText = false
        end
    end)
    block._worthItTextHooked = true
end

local function ResolveTrackerBlockHover(self)
    local targetBlock = (self and self._worthItOwnerBlock) or self
    if not targetBlock then return nil end
    local id = targetBlock._worthItActiveQuestID
    if not id or id <= 0 then
        local fs = GetBlockHeaderFontString(targetBlock)
        local txt = fs and fs.GetText and fs:GetText() or ""
        id = ResolveBlockQuestID(targetBlock, Utils.CleanQuestTitle(txt), _trackerActiveQuests, next(_trackerRawTitles) and EnsureTrackerTitleIndex() or nil)
    end
    return id
end

-- Apply badge to a single Objective Tracker block header (leaves objective detail lines 100% untouched)
local function BadgeObjectiveBlock(block, activeQuests, titleToID)
    if not block then return end
    local fontString = GetBlockHeaderFontString(block)
    if not (fontString and fontString.GetText and fontString.SetText) then return end
    if InCombatLockdown and InCombatLockdown() then
        addon._trackerCombatDeferred = true
        return
    end

    local rawText = fontString:GetText() or ""
    if rawText == "" then return end
    local cleanText = Utils.CleanQuestTitle(rawText)

    local showTag = not addon.db or (addon.db.enabled ~= false and addon.db.showInTracker ~= false)
    if not showTag then
        block._worthItActiveQuestID = nil
        if rawText ~= cleanText then
            fontString._worthItSettingText = true
            fontString:SetText(cleanText)
            fontString._worthItSettingText = false
        end
        return
    end

    local qID = ResolveBlockQuestID(block, rawText, activeQuests, titleToID)
    if not qID or qID <= 0 then
        block._worthItActiveQuestID = nil
        return
    end
    block._worthItActiveQuestID = qID

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then return end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local isBankable = (breakdown and breakdown.isBankable)
    local isLowValue = (breakdown and breakdown.isLowValue)
    local isMeta = (breakdown and breakdown.isMeta)
    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable, isLowValue, isMeta)
    local targetText = badge .. " " .. cleanText

    if rawText ~= targetText then
        fontString._worthItSettingText = true
        fontString:SetText(targetText)
        fontString._worthItSettingText = false
    end

    -- Hook OnEnter/OnLeave to inject Worth Meter & Meta-Knowledge into Tracker Tooltips
    if not block._worthItHoverHooked then
        HookQuestWidgetHover(block, ResolveTrackerBlockHover)
    end
    if block.Header then
        block.Header._worthItOwnerBlock = block
        if not block.Header._worthItHoverHooked then
            HookQuestWidgetHover(block.Header, ResolveTrackerBlockHover)
        end
    end
end

-- Dynamic module list getter (QUEST MODULES ONLY across Classic & Modern clients, reusing scratch tables)
local function AddTrackerModule(mod)
    if mod and not _moduleListSeen[mod] then
        _moduleListSeen[mod] = true
        _moduleListOut[#_moduleListOut + 1] = mod
    end
end

local function GetModuleList()
    wipe(_moduleListSeen)
    wipe(_moduleListOut)

    AddTrackerModule(QuestObjectiveTracker)
    AddTrackerModule(CampaignQuestObjectiveTracker)
    AddTrackerModule(WorldQuestObjectiveTracker)
    AddTrackerModule(QUEST_TRACKER_MODULE)
    AddTrackerModule(CAMPAIGN_QUEST_TRACKER_MODULE)
    AddTrackerModule(WORLD_QUEST_TRACKER_MODULE)

    if ObjectiveTrackerManager and ObjectiveTrackerManager.modules then
        for _, mod in ipairs(ObjectiveTrackerManager.modules) do
            if mod == QuestObjectiveTracker or mod == CampaignQuestObjectiveTracker or mod == WorldQuestObjectiveTracker then
                AddTrackerModule(mod)
            elseif mod.isQuestTracker or (mod.GetName and string.find(string.lower(mod:GetName() or ""), "quest")) then
                AddTrackerModule(mod)
            end
        end
    end

    if ObjectiveTrackerFrame and ObjectiveTrackerFrame.MODULES then
        for _, mod in ipairs(ObjectiveTrackerFrame.MODULES) do
            AddTrackerModule(mod)
        end
    end

    return _moduleListOut
end

function UI.InvalidateModuleListCache()
    -- Kept for API compatibility; GetModuleList reuses scratch tables safely on each refresh
end

local _lastTrackerUpdate = 0
local _isUpdatingTracker = false
local _trackerUpdatePending = false

local function ProcessTrackerBlock(block)
    if not block or _trackerProcessedBlocks[block] then return end
    _trackerProcessedBlocks[block] = true
    HookBlockHeaderText(block)
    BadgeObjectiveBlock(block, _trackerActiveQuests, nil)
end

local function RunEnumerateBlocks(mod)
    for block in mod:EnumerateBlocks() do
        ProcessTrackerBlock(block)
        _trackerEnumerated = true
    end
end

local function RunBlockPoolsEnum(pools)
    for block in pools:EnumerateActive() do
        ProcessTrackerBlock(block)
        _trackerEnumerated = true
    end
end

local function RunBlockPoolEnum(pool)
    for block in pool:EnumerateActive() do
        ProcessTrackerBlock(block)
        _trackerEnumerated = true
    end
end

local function GetFrameChildrenPacked(frame)
    return { frame:GetChildren() }
end

local function ScanTrackerContainerTree(frame, depth)
    if not frame or depth > 4 then return end
    if GetBlockHeaderFontString(frame) then
        ProcessTrackerBlock(frame)
    end
    if frame.GetChildren then
        local okC, kids = pcall(GetFrameChildrenPacked, frame)
        if okC and kids then
            for _, child in ipairs(kids) do
                if child and child:IsShown() then
                    ScanTrackerContainerTree(child, depth + 1)
                end
            end
        end
    end
end

local function RunObjectiveTrackerUpdate()
    local modules = GetModuleList()
    _trackerCurrentModules = modules

    -- Ensure any newly loaded tracker modules are hooked (reusing modules list)
    if UI.HookTrackerModules then
        UI.HookTrackerModules(modules)
    end

    wipe(_trackerActiveQuests)
    wipe(_trackerRawTitles)
    wipe(_trackerTitleToID)
    _trackerTitleIndexBuilt = false
    wipe(_trackerProcessedBlocks)

    local getInfo = C_QuestLog and C_QuestLog.GetInfo
    local getNumEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries) or GetNumQuestLogEntries
    local numEntries = (getNumEntries and getNumEntries()) or 0

    for i = 1, numEntries do
        local qTitle, qid, isH
        if getInfo then
            local okI, info = pcall(getInfo, i)
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
            _trackerActiveQuests[qid] = true
            _trackerRawTitles[qid] = qTitle
        end
    end

    -- 1. Enumerate blocks across quest tracker modules
    for _, mod in ipairs(modules) do
        if mod then
            _trackerEnumerated = false

            -- Modern Dragonflight API: mod:EnumerateBlocks()
            if mod.EnumerateBlocks then
                if not pcall(RunEnumerateBlocks, mod) then
                    _trackerEnumerated = false
                end
            end

            -- Modern Dragonflight FramePoolCollection: mod.blockPools
            if not _trackerEnumerated and mod.blockPools and mod.blockPools.EnumerateActive then
                if not pcall(RunBlockPoolsEnum, mod.blockPools) then
                    _trackerEnumerated = false
                end
            end

            -- Legacy pool: mod.blockPool
            if not _trackerEnumerated and mod.blockPool and mod.blockPool.EnumerateActive then
                if not pcall(RunBlockPoolEnum, mod.blockPool) then
                    _trackerEnumerated = false
                end
            end

            -- Handle mod.usedBlocks
            if not _trackerEnumerated and mod.usedBlocks and type(mod.usedBlocks) == "table" then
                for _, v in pairs(mod.usedBlocks) do
                    if type(v) == "table" then
                        if GetBlockHeaderFontString(v) or v.id or v.questID then
                            ProcessTrackerBlock(v)
                        else
                            for _, subBlock in pairs(v) do
                                if type(subBlock) == "table" and (GetBlockHeaderFontString(subBlock) or subBlock.id or subBlock.questID) then
                                    ProcessTrackerBlock(subBlock)
                                end
                            end
                        end
                    end
                end
            end

            -- Query mod:GetExistingBlock(questID) for all active quests
            if mod.GetExistingBlock then
                for qid in pairs(_trackerActiveQuests) do
                    local okB, block = pcall(mod.GetExistingBlock, mod, qid)
                    if okB and block then
                        ProcessTrackerBlock(block)
                    end
                end
            end
        end
    end

    -- 2. Fallback: Recursive container frame scanning (only when module enumeration found no blocks)
    if not next(_trackerProcessedBlocks) then
        _trackerContainers[1] = ObjectiveTrackerBlocksFrame
        _trackerContainers[2] = ObjectiveTrackerFrame and ObjectiveTrackerFrame.BlocksFrame
        _trackerContainers[3] = ObjectiveTrackerFrame
        for i = 1, 3 do
            local container = _trackerContainers[i]
            if container then
                ScanTrackerContainerTree(container, 1)
            end
        end
    end
end

-- Master function to update all visible quest entries in the Objective Tracker
function UI.UpdateObjectiveTracker(force)
    if InCombatLockdown and InCombatLockdown() then
        addon._trackerCombatDeferred = true
        return
    end
    if _isUpdatingTracker then
        if not _trackerUpdatePending and C_Timer and C_Timer.After then
            _trackerUpdatePending = true
            C_Timer.After(0.05, function()
                _trackerUpdatePending = false
                UI.UpdateObjectiveTracker(true)
            end)
        end
        return
    end

    local now = GetTime()
    if not force and (now - _lastTrackerUpdate) < 0.10 then
        if not _trackerUpdatePending then
            _trackerUpdatePending = true
            if C_Timer and C_Timer.After then
                C_Timer.After(0.10, function()
                    _trackerUpdatePending = false
                    UI.UpdateObjectiveTracker(true)
                end)
            else
                _trackerUpdatePending = false
            end
        end
        return
    end
    _lastTrackerUpdate = now
    _trackerUpdatePending = false
    addon._trackerCombatDeferred = false

    _isUpdatingTracker = true

    local ok, err = pcall(RunObjectiveTrackerUpdate)

    _isUpdatingTracker = false
    if not ok and err and addon.Debug then
        addon.Debug("Error in UpdateObjectiveTracker: " .. tostring(err))
    end
end

-- Hook all available Objective Tracker modules and global update functions
local function HookTrackerModules(modules)
    modules = modules or GetModuleList()

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

local function ScheduleQuestLogShowRefresh()
    UI.UpdateQuestLog(true)
    if C_Timer and C_Timer.After then
        C_Timer.After(0.03, function() UI.UpdateQuestLog(true) end)
        C_Timer.After(0.15, function() UI.UpdateQuestLog(true) end)
    end
end

-- =========================================================================
-- Quest Details Inline Dependency & Prerequisite Guide Card
-- Shows "Need Item/Step A before Final Objective B" with live bag checks
-- and [Pin Steps] button directly on QuestMapFrame.DetailsFrame / QuestLogFrame.
-- =========================================================================
local _detailsGuideBox = nil
local _detailsSelectedQuestID = nil

local function GetDetailsAnchorFrame()
    if QuestMapFrame and QuestMapFrame.DetailsFrame and QuestMapFrame.DetailsFrame.IsShown and QuestMapFrame.DetailsFrame:IsShown() then
        return QuestMapFrame.DetailsFrame, true
    end
    if QuestLogFrame and QuestLogFrame.IsShown and QuestLogFrame:IsShown() then
        if QuestLogDetailScrollFrame and (not QuestLogDetailScrollFrame.IsShown or QuestLogDetailScrollFrame:IsShown()) then
            return QuestLogFrame, false
        end
    end
    if QuestLogDetailScrollFrame and QuestLogDetailScrollFrame.IsShown and QuestLogDetailScrollFrame:IsShown() then
        return QuestLogDetailScrollFrame, false
    end
    return nil, false
end

local function ResolveDetailsQuestID(explicitQuestID)
    if explicitQuestID and type(explicitQuestID) == "number" and explicitQuestID > 0 then
        return explicitQuestID
    end
    if QuestMapFrame and QuestMapFrame.DetailsFrame and QuestMapFrame.DetailsFrame.questID and QuestMapFrame.DetailsFrame.questID > 0 then
        return QuestMapFrame.DetailsFrame.questID
    end
    if QuestInfoFrame and QuestInfoFrame.questID and QuestInfoFrame.questID > 0 then
        return QuestInfoFrame.questID
    end
    if C_QuestLog and C_QuestLog.GetSelectedQuest then
        local ok, qid = pcall(C_QuestLog.GetSelectedQuest)
        if ok and qid and qid > 0 then return qid end
    end
    if GetQuestLogSelection and GetQuestLogTitle then
        local idx = GetQuestLogSelection()
        if idx and idx > 0 then
            if C_QuestLog and C_QuestLog.GetInfo then
                local ok, info = pcall(C_QuestLog.GetInfo, idx)
                if ok and info and not info.isHeader and info.questID and info.questID > 0 then
                    return info.questID
                end
            else
                local ok, _, _, _, isH, _, _, _, qid = pcall(GetQuestLogTitle, idx)
                if ok and not isH and qid and qid > 0 then
                    return qid
                end
            end
        end
    end
    return _detailsSelectedQuestID
end

local function EnsureDetailsGuideBox()
    if _detailsGuideBox then return _detailsGuideBox end
    if not CreateFrame or not UIParent then return nil end

    local L = addon.L or {}
    local Theme = addon.UI and addon.UI.Theme
    local f = CreateFrame("Frame", "WorthIt_DetailsGuideBox", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetWidth(300)
    f:SetHeight(80)
    f:SetFrameStrata("HIGH")
    if Theme and Theme.DressParchmentCard then
        Theme.DressParchmentCard(f)
    elseif f.SetBackdrop then
        f:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 14,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        f:SetBackdropColor(0.06, 0.08, 0.12, 0.94)
        f:SetBackdropBorderColor(0.75, 0.60, 0.20, 0.90)
    end
    f:Hide()

    local icon = f:CreateTexture(nil, "OVERLAY")
    icon:SetSize(16, 16)
    icon:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -8)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_08")
    if icon.SetTexCoord then icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
    f.icon = icon

    local hdr = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hdr:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    hdr:SetText("|cffffd100" .. (L["GUIDE_HEADER"] or "Quest Steps & Prerequisites:") .. "|r")
    f.header = hdr

    if Theme and Theme.CreateHeaderRule then
        Theme.CreateHeaderRule(f, 8, -28)
    end

    local pinBtn = CreateFrame("Button", "WorthIt_DetailsPinBtn", f, "UIPanelButtonTemplate")
    pinBtn:SetSize(74, 18)
    pinBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -6)
    pinBtn:SetText(L["GUIDE_PIN_BUTTON"] or "Pin Steps")
    pinBtn:SetScript("OnClick", function()
        if f._questID and UI.PinQuestGuide then
            UI.PinQuestGuide(f._questID, true)
            UI.UpdateQuestDetailsGuide(f._questID)
        end
    end)
    f.pinBtn = pinBtn

    local clearBtn = CreateFrame("Button", "WorthIt_DetailsClearBtn", f, "UIPanelButtonTemplate")
    clearBtn:SetSize(56, 18)
    clearBtn:SetPoint("RIGHT", pinBtn, "LEFT", -4, 0)
    clearBtn:SetText(L["GUIDE_CLEAR_PIN"] or "Clear")
    clearBtn:SetScript("OnClick", function()
        if UI.ClearManualGuidePin then
            UI.ClearManualGuidePin(true)
        end
        if f._questID then
            UI.UpdateQuestDetailsGuide(f._questID)
        end
    end)
    f.clearBtn = clearBtn

    f.lines = {}
    for i = 1, 7 do
        local fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetJustifyH("LEFT")
        fs:SetWordWrap(true)
        fs:Hide()
        f.lines[i] = fs
    end

    _detailsGuideBox = f
    return f
end

function UI.UpdateQuestDetailsGuide(explicitQuestID)
    if explicitQuestID and type(explicitQuestID) == "number" and explicitQuestID > 0 then
        _detailsSelectedQuestID = explicitQuestID
    end

    if not (addon.db and addon.db.enabled ~= false and addon.db.showQuestDetailsGuide ~= false) then
        if _detailsGuideBox then _detailsGuideBox:Hide() end
        return
    end

    local anchor, isWorldMapDetails = GetDetailsAnchorFrame()
    if not anchor then
        if _detailsGuideBox then _detailsGuideBox:Hide() end
        return
    end

    local qid = ResolveDetailsQuestID(explicitQuestID)
    if not qid or qid <= 0 then
        if _detailsGuideBox then _detailsGuideBox:Hide() end
        return
    end

    local guide = addon.Data and addon.Data.GetQuestGuide and addon.Data.GetQuestGuide(qid)
    if not guide or ((not guide.steps or #guide.steps == 0) and (not guide.summary or guide.summary == "") and (not guide.warning or guide.warning == "")) then
        if _detailsGuideBox then _detailsGuideBox:Hide() end
        return
    end

    local box = EnsureDetailsGuideBox()
    if not box then return end
    box._questID = qid

    local L = addon.L or {}
    local targetWidth = math.max(280, math.min(360, (anchor.GetWidth and anchor:GetWidth()) or 300))
    box:SetWidth(targetWidth)
    local textWidth = targetWidth - 20

    local hasCoords = (guide.pins and #guide.pins > 0)
    if not hasCoords and guide.steps then
        for _, st in ipairs(guide.steps) do
            if st.mapID and st.x and st.y then
                hasCoords = true
                break
            end
        end
    end
    if hasCoords then
        box.pinBtn:Show()
        if (UI.GetManualPinnedQuestID and UI.GetManualPinnedQuestID() == qid)
            or (UI.HasVisiblePinsForQuest and UI.HasVisiblePinsForQuest(qid)) then
            box.clearBtn:Show()
        else
            box.clearBtn:Hide()
        end
        box.header:SetWidth(targetWidth - 168)
    else
        box.pinBtn:Hide()
        box.clearBtn:Hide()
        box.header:SetWidth(targetWidth - 40)
    end

    local lineTexts = {}
    if guide.warning and guide.warning ~= "" then
        table.insert(lineTexts, "|cffff6644! Warning:|r |cfff5ebd6" .. guide.warning .. "|r")
    end
    local steps = guide.steps or {}
    if #steps > 0 then
        local maxRows = math.min(#steps, 6)
        for i = 1, maxRows do
            local st = steps[i]
            local bagTag = ""
            if addon.Data and addon.Data.GetStepBagProgress and (st.itemID or st.itemName) then
                local have, need, satisfied = addon.Data.GetStepBagProgress(st)
                if satisfied then
                    bagTag = " |cff44ff77" .. (L["GUIDE_IN_BAGS"] or "[In Bags]") .. "|r"
                elseif have > 0 and need > 1 then
                    bagTag = string.format(" |cffffcc00(%d/%d)|r", have, need)
                end
            end
            local coordTag = (st.mapID and st.x and st.y) and string.format(" |cff9fd0ff(%.1f, %.1f)|r", st.x * 100, st.y * 100) or ""
            table.insert(lineTexts, string.format("|cffffd100%d.|r |cfff5ebd6%s|r%s%s", i, st.text or "", coordTag, bagTag))
        end
        if #steps > maxRows then
            table.insert(lineTexts, string.format("|cffb8a47e...+%d more step(s)|r", #steps - maxRows))
        end
    elseif guide.summary and guide.summary ~= "" then
        table.insert(lineTexts, "|cfff5ebd6" .. guide.summary .. "|r")
    end

    local yOffset = -35
    for idx = 1, 7 do
        local fs = box.lines[idx]
        local str = lineTexts[idx]
        if str then
            fs:ClearAllPoints()
            fs:SetWidth(textWidth)
            fs:SetPoint("TOPLEFT", box, "TOPLEFT", 10, yOffset)
            fs:SetText(str)
            fs:Show()
            local h = (fs.GetStringHeight and fs:GetStringHeight()) or 14
            if h < 12 then h = 14 end
            yOffset = yOffset - h - 4
        else
            fs:SetText("")
            fs:Hide()
        end
    end

    box:SetHeight(math.max(54, (-yOffset) + 6))
    box:ClearAllPoints()
    local anchorBottom = anchor.GetBottom and anchor:GetBottom() or 300
    if isWorldMapDetails and anchorBottom < 140 then
        box:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -6, 0)
    elseif anchorBottom < 120 then
        box:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 6, 0)
    else
        box:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
    end
    box:SetParent(anchor)
    if box.SetFrameLevel and anchor.GetFrameLevel then
        box:SetFrameLevel(math.max(20, (anchor:GetFrameLevel() or 5) + 15))
    end
    box:Show()
end

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

    if QuestMapFrame_ReturnFromQuestDetails and not UI._questReturnDetailsHooked then
        hooksecurefunc("QuestMapFrame_ReturnFromQuestDetails", function()
            if _detailsGuideBox then _detailsGuideBox:Hide() end
            if not addon.isUpdatingUI then
                ScheduleQuestLogShowRefresh()
            end
        end)
        UI._questReturnDetailsHooked = true
    end

    if QuestMapFrame_ShowQuestDetails and not UI._questShowDetailsGuideHooked then
        hooksecurefunc("QuestMapFrame_ShowQuestDetails", function(questID)
            UI.UpdateQuestDetailsGuide(questID)
        end)
        UI._questShowDetailsGuideHooked = true
    end

    if QuestLog_UpdateQuestDetails and not UI._classicDetailsGuideHooked then
        hooksecurefunc("QuestLog_UpdateQuestDetails", function()
            UI.UpdateQuestDetailsGuide()
        end)
        UI._classicDetailsGuideHooked = true
    end

    if SelectQuestLogEntry and not UI._selectLogDetailsHooked then
        hooksecurefunc("SelectQuestLogEntry", function()
            if addon._isInternalQuestSelection then return end
            if C_Timer and C_Timer.After then
                C_Timer.After(0.02, function() UI.UpdateQuestDetailsGuide() end)
            else
                UI.UpdateQuestDetailsGuide()
            end
        end)
        UI._selectLogDetailsHooked = true
    end

    if QuestMapFrame and QuestMapFrame.DetailsFrame and QuestMapFrame.DetailsFrame.HookScript and not QuestMapFrame.DetailsFrame._worthItGuideHideHooked then
        QuestMapFrame.DetailsFrame._worthItGuideHideHooked = true
        pcall(function()
            QuestMapFrame.DetailsFrame:HookScript("OnShow", function() UI.UpdateQuestDetailsGuide() end)
            QuestMapFrame.DetailsFrame:HookScript("OnHide", function() UI.UpdateQuestDetailsGuide() end)
        end)
    end

    if QuestLogFrame and QuestLogFrame.HookScript and not QuestLogFrame._worthItGuideHideHooked then
        QuestLogFrame._worthItGuideHideHooked = true
        pcall(function()
            QuestLogFrame:HookScript("OnHide", function() UI.UpdateQuestDetailsGuide() end)
        end)
    end

    -- Note: Do NOT call UpdateQuestLog inside QuestMapFrame_ShowQuestDetails or SelectQuestLogEntry.
    -- Selecting a quest or viewing details does not change Worth % scores,
    -- and triggering UpdateQuestLog on selection causes redundant UI redraws and map flickering.

    if WorldMapFrame then
        if WorldMapFrame.HookScript and not UI._worldMapOnShowHooked then
            pcall(function()
                WorldMapFrame:HookScript("OnShow", ScheduleQuestLogShowRefresh)
                UI._worldMapOnShowHooked = true
            end)
        end
        WorldMapFrame._qwQLMethods = WorldMapFrame._qwQLMethods or {}
        for _, mName in ipairs({ "HandleUserActionToggleSidePanel", "HandleUserActionOpenSidePanel", "SetDisplayState" }) do
            if WorldMapFrame[mName] and not WorldMapFrame._qwQLMethods[mName] then
                WorldMapFrame._qwQLMethods[mName] = true
                hooksecurefunc(WorldMapFrame, mName, function()
                    if C_Timer and C_Timer.After then
                        C_Timer.After(0.03, function() UI.UpdateQuestLog(true) end)
                        C_Timer.After(0.15, function() UI.UpdateQuestLog(true) end)
                    else
                        UI.UpdateQuestLog(true)
                    end
                end)
            end
        end
        if WorldMapFrame.QuestLog and WorldMapFrame.QuestLog ~= QuestMapFrame and WorldMapFrame.QuestLog.HookScript and not WorldMapFrame.QuestLog._worthItOnShowHooked then
            WorldMapFrame.QuestLog._worthItOnShowHooked = true
            pcall(function()
                WorldMapFrame.QuestLog:HookScript("OnShow", ScheduleQuestLogShowRefresh)
            end)
        end
    end

    if QuestMapFrame then
        if QuestMapFrame.HookScript and not QuestMapFrame._worthItOnShowHooked then
            pcall(function()
                QuestMapFrame:HookScript("OnShow", ScheduleQuestLogShowRefresh)
                QuestMapFrame._worthItOnShowHooked = true
            end)
        end
        if QuestMapFrame.RefreshLayout and not QuestMapFrame._worthItRefreshHooked then
            QuestMapFrame._worthItRefreshHooked = true
            hooksecurefunc(QuestMapFrame, "RefreshLayout", function()
                if not addon.isUpdatingUI then UI.UpdateQuestLog() end
            end)
        end
        if QuestMapFrame.QuestsFrame then
            local qf = QuestMapFrame.QuestsFrame
            if qf.HookScript and not qf._worthItOnShowHooked then
                qf._worthItOnShowHooked = true
                pcall(function()
                    qf:HookScript("OnShow", ScheduleQuestLogShowRefresh)
                end)
            end
            for _, mName in ipairs({ "UpdateAll", "Update", "Refresh" }) do
                if qf[mName] and not qf["_worthIt_" .. mName .. "_Hooked"] then
                    qf["_worthIt_" .. mName .. "_Hooked"] = true
                    hooksecurefunc(qf, mName, function()
                        if not addon.isUpdatingUI then UI.UpdateQuestLog() end
                    end)
                end
            end
        end
    end

    if QuestLogFrame and QuestLogFrame.HookScript and not UI._questLogFrameOnShowHooked then
        pcall(function()
            QuestLogFrame:HookScript("OnShow", ScheduleQuestLogShowRefresh)
            UI._questLogFrameOnShowHooked = true
        end)
    end

    if QuestScrollFrame then
        if QuestScrollFrame.HookScript and not QuestScrollFrame._worthItOnShowHooked then
            pcall(function()
                QuestScrollFrame:HookScript("OnShow", ScheduleQuestLogShowRefresh)
                QuestScrollFrame._worthItOnShowHooked = true
            end)
        end
        if QuestScrollFrame.Update and not QuestScrollFrame._worthItUpdateHooked then
            QuestScrollFrame._worthItUpdateHooked = true
            hooksecurefunc(QuestScrollFrame, "Update", function()
                if not addon.isUpdatingUI then UI.UpdateQuestLog() end
            end)
        end
        if QuestScrollFrame.Contents and QuestScrollFrame.Contents.Layout and not QuestScrollFrame.Contents._worthItLayoutHooked then
            QuestScrollFrame.Contents._worthItLayoutHooked = true
            hooksecurefunc(QuestScrollFrame.Contents, "Layout", function()
                if not addon.isUpdatingUI then UI.UpdateQuestLog() end
            end)
        end
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
            for _, cbEvent in ipairs({ "OnScroll", "OnDataRangeChanged", "OnAcquiredFrame", "OnLayout" }) do
                pcall(function()
                    QuestScrollFrame.ScrollBox:RegisterCallback(cbEvent, function()
                        UI.UpdateQuestLog()
                    end, addonName .. "_" .. cbEvent)
                end)
            end
            UI._scrollBoxHooked = true
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
