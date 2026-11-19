--[[
    WorthIt / QuestWorth - UI/QuestOffer.lua
    Evaluates and displays Worth % on selected quest offer/turn-in dialogs
    (QuestFrameDetailPanel / QuestFrameProgressPanel) once live rewards & objectives load.
    Intentionally omits pre-selection Worth % badges from multi-quest NPC lists
    (GossipFrame / QuestFrameGreetingPanel) where full quest payload is not yet available.
]]

local addonName, addon = ...
addon.UI = addon.UI or {}
local UI = addon.UI
local Utils = addon.Utils
local L = addon.L

-- Ensure any legacy pill frame is destroyed/hidden
if _G["WorthIt_QuestOfferPill"] then
    _G["WorthIt_QuestOfferPill"]:Hide()
    _G["WorthIt_QuestOfferPill"]:SetParent(nil)
end

local titleHoverFrame = nil
local function EnsureTitleHoverFrame()
    if titleHoverFrame then return titleHoverFrame end
    if not QuestInfoTitleHeader and not QuestDetailTitleText then return nil end
    local anchor = QuestInfoTitleHeader or QuestDetailTitleText
    local parent = (anchor and anchor.GetParent and anchor:GetParent()) or QuestFrameDetailPanel or QuestFrame
    titleHoverFrame = CreateFrame("Frame", "WorthIt_QuestOfferTitleHover", parent)
    titleHoverFrame:SetAllPoints(anchor)
    titleHoverFrame:EnableMouse(true)
    if titleHoverFrame.SetMouseClickEnabled then
        pcall(titleHoverFrame.SetMouseClickEnabled, titleHoverFrame, false)
    end
    titleHoverFrame:EnableMouseWheel(true)
    titleHoverFrame:SetScript("OnMouseWheel", function(self, delta)
        local scroll = QuestDetailScrollFrame or QuestLogDetailScrollFrame or (QuestFrame and QuestFrame.ScrollFrame)
        if scroll and scroll.GetScript and scroll:GetScript("OnMouseWheel") then
            scroll:GetScript("OnMouseWheel")(scroll, delta)
        end
    end)
    titleHoverFrame:SetFrameLevel((parent:GetFrameLevel() or 1) + 10)
    titleHoverFrame:SetScript("OnEnter", function(self)
        if self.questID and self.questID > 0 and UI.ShowQuestTooltip then
            UI.ShowQuestTooltip(GameTooltip, self.questID, self)
        end
    end)
    titleHoverFrame:SetScript("OnLeave", function(self)
        if GameTooltip then GameTooltip:Hide() end
    end)
    return titleHoverFrame
end

local DESC_START_MARK = "|cfffefffe|r"
local DESC_END_MARK = "|cfffefefe|r\n\n"

local function CleanOfferTitle(raw)
    local stripped = string.gsub(raw or "", "\n|cff.-$", "")
    return Utils.CleanQuestTitle(stripped)
end

local function StripInjectedDescBlock(raw)
    if not raw or raw == "" then return "" end
    local s, e = string.find(raw, DESC_END_MARK, 1, true)
    if s and string.sub(raw, 1, #DESC_START_MARK) == DESC_START_MARK then
        return string.sub(raw, e + 1)
    end
    return raw
end

local function ClearInjectedDescriptions()
    for _, fs in ipairs({ QuestInfoDescriptionText, QuestDetailDescriptionText }) do
        if fs and fs.GetText and fs.SetText then
            local raw = fs:GetText() or ""
            local clean = StripInjectedDescBlock(raw)
            if clean ~= raw then
                fs:SetText(clean)
            end
        end
    end
end

-- Update Quest Detail / Offer dialog (QuestFrameDetailPanel / QuestInfoTitleHeader)
local function UpdateQuestOfferDialog(template, parentFrame)
    if QUEST_TEMPLATE_LOG and template == QUEST_TEMPLATE_LOG then return end
    if QUEST_TEMPLATE_MAP_DETAILS and template == QUEST_TEMPLATE_MAP_DETAILS then return end
    if QUEST_TEMPLATE_MAP_REWARDS and template == QUEST_TEMPLATE_MAP_REWARDS then return end
    if template and QuestInfoFrame and QuestInfoFrame.questLog then return end
    if parentFrame and QuestLogDetailScrollFrame and parentFrame == QuestLogDetailScrollFrame then return end
    if parentFrame and QuestMapFrame and QuestMapFrame.DetailsFrame and QuestMapFrame.DetailsFrame.ScrollFrame
        and (parentFrame == QuestMapFrame.DetailsFrame.ScrollFrame or parentFrame == QuestMapFrame.DetailsFrame.ScrollFrame.ScrollChild) then
        return
    end
    if not (addon.db and addon.db.enabled) then
        addon._activeOfferQuestID = nil
        if titleHoverFrame then titleHoverFrame:Hide() end
        for _, header in ipairs({ QuestInfoTitleHeader, QuestDetailTitleText, QuestProgressTitleText }) do
            if header and header.GetText and header.SetText then
                local raw = header:GetText() or ""
                if raw ~= "" then
                    local clean = CleanOfferTitle(raw)
                    if raw ~= clean then
                        header:SetText(clean)
                    end
                end
            end
        end
        ClearInjectedDescriptions()
        return
    end
    if not QuestFrame or not QuestFrame:IsShown() then
        addon._activeOfferQuestID = nil
        return
    end
    if QuestFrameGreetingPanel and QuestFrameGreetingPanel:IsShown() then
        addon._activeOfferQuestID = nil
        if titleHoverFrame then titleHoverFrame:Hide() end
        return
    end

    local qID = nil
    if GetQuestID then
        local ok, id = pcall(GetQuestID)
        if ok and id and id > 0 then qID = id end
    end

    if not qID and QuestFrame and QuestFrame.questID and QuestFrame.questID > 0 then
        qID = QuestFrame.questID
    end
    if not qID and QuestFrameDetailPanel and QuestFrameDetailPanel.questID and QuestFrameDetailPanel.questID > 0 then
        qID = QuestFrameDetailPanel.questID
    end
    if not qID and QuestInfoFrame and QuestInfoFrame.questLog and QuestInfoFrame.questLog.questID then
        qID = QuestInfoFrame.questLog.questID
    end

    local function ResolveTitleTextForLookup()
        for _, fs in ipairs({ QuestInfoTitleHeader, QuestRewardTitleText, QuestDetailTitleText }) do
            if fs and fs.GetText then
                local raw = fs:GetText()
                if raw and raw ~= "" then return raw end
            end
        end
        if GetTitleText then
            local ok, t = pcall(GetTitleText)
            if ok and type(t) == "string" and t ~= "" then return t end
        end
        return ""
    end

    if not qID then
        local rawTitle = ResolveTitleTextForLookup()
        local clean = CleanOfferTitle(rawTitle)
        local titleNoLevel = string.gsub(clean, "^%s*%[%d+%+?%]%s*", "")
        titleNoLevel = string.gsub(titleNoLevel, "^%s*(.-)%s*$", "%1")
        local lowerTarget = string.lower(titleNoLevel)

        local function matchListByTitle(list)
            if not list or lowerTarget == "" then return nil end
            for _, q in ipairs(list) do
                if q.title then
                    local cleanQ = string.gsub(Utils.CleanQuestTitle(q.title), "^%s*%[%d+%+?%]%s*", "")
                    cleanQ = string.gsub(cleanQ, "^%s*(.-)%s*$", "%1")
                    if string.lower(cleanQ) == lowerTarget then
                        return q.questID
                    end
                end
            end
            for _, q in ipairs(list) do
                if q.title and string.find(string.lower(clean), string.lower(q.title), 1, true) then
                    return q.questID
                end
            end
            return nil
        end

        if C_GossipInfo and lowerTarget ~= "" then
            qID = matchListByTitle(C_GossipInfo.GetAvailableQuests and C_GossipInfo.GetAvailableQuests())
            if not qID then
                qID = matchListByTitle(C_GossipInfo.GetActiveQuests and C_GossipInfo.GetActiveQuests())
            end
        end

        -- Turn-in fallback: match active Quest Log title when GetQuestID() returned nil/0
        if not qID and lowerTarget ~= "" then
            local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                               or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
            for i = 1, numEntries do
                local qTitle, isH, id
                if C_QuestLog and C_QuestLog.GetInfo then
                    local ok, info = pcall(C_QuestLog.GetInfo, i)
                    if ok and info then qTitle, isH, id = info.title, info.isHeader, info.questID end
                elseif GetQuestLogTitle then
                    local ok, t, _, _, h, _, _, _, qid = pcall(GetQuestLogTitle, i)
                    if ok then qTitle, isH, id = t, h, qid end
                end
                if not isH and id and id > 0 and qTitle and qTitle ~= "" then
                    local cleanLog = string.gsub(Utils.CleanQuestTitle(qTitle), "^%s*%[%d+%+?%]%s*", "")
                    cleanLog = string.gsub(cleanLog, "^%s*(.-)%s*$", "%1")
                    if string.lower(cleanLog) == lowerTarget then
                        qID = id
                        break
                    end
                end
            end
        end

        if not qID and addon.lastHoveredQuestID and lowerTarget ~= "" then
            local hoveredTitle = Utils.GetQuestTitle and Utils.GetQuestTitle(addon.lastHoveredQuestID)
            if hoveredTitle and hoveredTitle ~= "" then
                local cleanHovered = string.gsub(Utils.CleanQuestTitle(hoveredTitle), "^%s*%[%d+%+?%]%s*", "")
                cleanHovered = string.gsub(cleanHovered, "^%s*(.-)%s*$", "%1")
                if string.lower(cleanHovered) == lowerTarget then
                    qID = addon.lastHoveredQuestID
                end
            end
        end
    end

    if not qID or qID <= 0 then
        addon._activeOfferQuestID = nil
        if titleHoverFrame then titleHoverFrame:Hide() end
        return
    end

    addon._activeOfferQuestID = qID

    -- Invalidate cached calculation for this quest to ensure live QuestFrame offer rewards & XP are evaluated fresh
    if addon.Engine and addon.Engine.InvalidateCache then
        addon.Engine.InvalidateCache(qID)
    elseif addon.Engine and addon.Engine.Cache then
        addon.Engine.Cache[qID] = nil
    end
    if Utils.ClearTalkToCache then
        Utils.ClearTalkToCache(qID)
    end

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then
        if titleHoverFrame then titleHoverFrame:Hide() end
        return
    end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local isBankable = (breakdown and breakdown.isBankable)
    local isLowValue = (breakdown and breakdown.isLowValue)
    local isMeta = (breakdown and breakdown.isMeta)
    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable, isLowValue, isMeta)

    -- Attach mouseover tooltip only when the corresponding detail title header is visible
    local visibleAnchor = (QuestInfoTitleHeader and ((QuestInfoTitleHeader.IsVisible and QuestInfoTitleHeader:IsVisible()) or (QuestInfoTitleHeader.IsShown and QuestInfoTitleHeader:IsShown())) and QuestInfoTitleHeader)
        or (QuestDetailTitleText and ((QuestDetailTitleText.IsVisible and QuestDetailTitleText:IsVisible()) or (QuestDetailTitleText.IsShown and QuestDetailTitleText:IsShown())) and QuestDetailTitleText)
    if visibleAnchor then
        local hover = EnsureTitleHoverFrame()
        if hover then
            hover:ClearAllPoints()
            hover:SetAllPoints(visibleAnchor)
            local p = (visibleAnchor.GetParent and visibleAnchor:GetParent()) or QuestFrameDetailPanel or QuestFrame
            hover:SetParent(p)
            hover:SetFrameLevel((p:GetFrameLevel() or 1) + 10)
            hover.questID = qID
            hover:Show()
        end
    elseif titleHoverFrame then
        titleHoverFrame:Hide()
    end

    local hintText = L["HOVER_TITLE_HINT"] or "Hover title for Worth details & score breakdown"
    local hintLine = "|cff4a3518<" .. hintText .. ">|r"

    local cleanOfferName = Utils.CleanQuestTitle(
        (QuestInfoTitleHeader and QuestInfoTitleHeader.GetText and QuestInfoTitleHeader:GetText())
        or (QuestDetailTitleText and QuestDetailTitleText.GetText and QuestDetailTitleText:GetText())
        or ""
    )
    local payoff = addon.Data and addon.Data.GetQuestPayoff and addon.Data.GetQuestPayoff(qID, cleanOfferName)
    local guideLines = {}
    if (not addon.db or addon.db.showMetaIndicator ~= false) and breakdown and breakdown.metaInfo then
        local mi = breakdown.metaInfo
        local metaDesc = (mi.reason and mi.reason ~= "") and mi.reason or (mi.tag or "META")
        table.insert(guideLines, string.format("%s |cff662200META [%s]:|r |cff1a1208%s|r",
            Utils.META_ICON or "", tostring(mi.tag or "META"), metaDesc))
    end
    if payoff and payoff.tip and payoff.tip ~= "" then
        table.insert(guideLines, "|cff005a14• " .. (L["PAYOFF_TIP"] or "Tip:") .. "|r |cff1a1208" .. payoff.tip .. "|r")
    elseif payoff and payoff.summary and payoff.summary ~= "" then
        table.insert(guideLines, "|cff5a1807•|r |cff1a1208" .. payoff.summary .. "|r")
    else
        local liveInfo = Utils.GetQuestLiveSummary and Utils.GetQuestLiveSummary(qID)
        local dynParts = {}
        if liveInfo and liveInfo.taskType then
            table.insert(dynParts, liveInfo.taskType)
        end
        local rDetails = breakdown and breakdown.details and breakdown.details.reward
        if rDetails and rDetails.rewardXP and rDetails.rewardXP > 0 then
            table.insert(dynParts, string.format("%d XP", rDetails.rewardXP))
        end
        if rDetails and rDetails.totalMoney and rDetails.totalMoney > 0 and Utils.FormatMoneyCompact then
            local moneyStr = Utils.FormatMoneyCompact(rDetails.totalMoney)
            if moneyStr then table.insert(dynParts, moneyStr) end
        end
        if breakdown and breakdown.f and breakdown.f >= 0.80 then
            table.insert(dynParts, "Gear Upgrade!")
        elseif payoff and payoff.note and payoff.note ~= "" then
            table.insert(dynParts, payoff.note)
        elseif breakdown and breakdown.details and breakdown.details.density and breakdown.details.density.clusterCount and breakdown.details.density.clusterCount >= 2 then
            table.insert(dynParts, string.format("Zone Hub (%dQ)", breakdown.details.density.clusterCount))
        end
        if #dynParts > 0 then
            table.insert(guideLines, "|cff103066•|r |cff1a1208" .. table.concat(dynParts, " • ") .. "|r")
        end
    end

    -- Append structured dependency / prerequisite steps in clean readable ink font
    local guide = addon.Data and addon.Data.GetQuestGuide and addon.Data.GetQuestGuide(qID, cleanOfferName)
    if guide and guide.steps and #guide.steps > 0 then
        local maxOfferSteps = math.min(#guide.steps, 3)
        local isSingleDuplicate = (#guide.steps == 1 and payoff and payoff.tip and payoff.tip == guide.steps[1].text)
        if not isSingleDuplicate then
            table.insert(guideLines, "|cff5a1807• " .. (L["GUIDE_NEED_FIRST"] or "Steps / Need First:") .. "|r")
            for idx = 1, maxOfferSteps do
                local st = guide.steps[idx]
                local bagSuffix = ""
                if addon.Data and addon.Data.GetStepBagProgress and (st.itemID or st.itemName) then
                    local _, _, satisfied = addon.Data.GetStepBagProgress(st)
                    if satisfied then bagSuffix = " |cff005a14[OK]|r" end
                end
                table.insert(guideLines, string.format("|cff103066  %d.|r |cff1a1208%s|r%s", idx, st.text or "", bagSuffix))
            end
            if #guide.steps > maxOfferSteps then
                table.insert(guideLines, string.format("|cff4a3518  ...+%d more (hover title)|r", #guide.steps - maxOfferSteps))
            end
        end
    end

    local guideBlock = hintLine .. ((#guideLines > 0) and ("\n" .. table.concat(guideLines, "\n")) or "")

    -- Place guide block inside clean body font (QuestInfoDescriptionText / QuestDetailDescriptionText) matching Blizzard's black quest text
    local descTarget = nil
    for _, fs in ipairs({ QuestInfoDescriptionText, QuestDetailDescriptionText }) do
        if fs and fs.GetText and fs.SetText and (not fs.IsShown or fs:IsShown()) then
            descTarget = fs
            break
        end
    end

    if descTarget then
        local rawDesc = StripInjectedDescBlock(descTarget:GetText() or "")
        local targetDesc = DESC_START_MARK .. guideBlock .. DESC_END_MARK .. rawDesc
        if (descTarget:GetText() or "") ~= targetDesc then
            descTarget:SetText(targetDesc)
        end
    end

    -- Keep TitleHeaders clean (1 line [XX%] Title) in stylized title font
    if QuestInfoTitleHeader and QuestInfoTitleHeader.GetText and QuestInfoTitleHeader.SetText then
        local rawTitle = QuestInfoTitleHeader:GetText() or ""
        if rawTitle ~= "" then
            local clean = Utils.CleanQuestTitle(rawTitle)
            local targetTitle = badge .. " " .. clean
            if rawTitle ~= targetTitle then
                QuestInfoTitleHeader:SetText(targetTitle)
            end
        end
    end

    -- 2. Badge QuestDetailTitleText (if separate Classic template)
    if QuestDetailTitleText and QuestDetailTitleText.GetText and QuestDetailTitleText.SetText then
        local raw = QuestDetailTitleText:GetText() or ""
        if raw ~= "" then
            local clean = Utils.CleanQuestTitle(raw)
            local target = badge .. " " .. clean
            if raw ~= target then
                QuestDetailTitleText:SetText(target)
            end
        end
    end

    -- 3. Badge QuestProgressTitleText (if turning in)
    if QuestProgressTitleText and QuestProgressTitleText.GetText and QuestProgressTitleText.SetText then
        local raw = QuestProgressTitleText:GetText() or ""
        if raw ~= "" then
            local clean = Utils.CleanQuestTitle(raw)
            local target = badge .. " " .. clean
            if raw ~= target then
                QuestProgressTitleText:SetText(target)
            end
        end
    end
end

local function StripButtonWorthBadge(widget, textRegion)
    if not widget then return end
    local target = textRegion or widget
    if target.GetText and target.SetText then
        local raw = target:GetText() or ""
        if raw ~= "" and (widget._worthItQuestID or string.find(raw, "%[%d+%%%]") or string.find(raw, "%[OK%]")) then
            local clean = Utils.CleanQuestTitle(raw)
            if raw ~= clean then
                target:SetText(clean)
            end
        end
    end
    widget._worthItQuestID = nil
end

-- Clean any stale Worth % badges from GossipFrame (pre-selection NPC quest list)
-- and harvest known quest levels for upcoming QuestFrame detail view
local function UpdateGossipAvailableQuests()
    if not GossipFrame or not GossipFrame:IsShown() then return end

    if Utils.RecordKnownQuestLevel and C_GossipInfo then
        for _, getter in ipairs({ C_GossipInfo.GetAvailableQuests, C_GossipInfo.GetActiveQuests }) do
            if getter then
                local ok, list = pcall(getter)
                if ok and type(list) == "table" then
                    for _, q in ipairs(list) do
                        local qLvl = q.questLevel or q.level
                        if q.questID and qLvl and qLvl > 0 then
                            Utils.RecordKnownQuestLevel(q.questID, q.title, qLvl)
                        end
                    end
                end
            end
        end
    end

    if GossipFrame.GreetingPanel and GossipFrame.GreetingPanel.ScrollBox and GossipFrame.GreetingPanel.ScrollBox.GetView then
        local view = GossipFrame.GreetingPanel.ScrollBox:GetView()
        if view and view.EnumerateFrames then
            for _, frame in view:EnumerateFrames() do
                if frame and frame:IsShown() then
                    local fontString = frame.GreetingText or frame.Text or (frame.GetFontString and frame:GetFontString())
                    StripButtonWorthBadge(frame, fontString)
                end
            end
        end
    end

    for i = 1, 32 do
        local button = _G["GossipTitleButton" .. i]
        if button then
            StripButtonWorthBadge(button)
        end
    end
end

-- Clean any stale Worth % badges from QuestFrameGreetingPanel (pre-selection multi-quest greeting)
-- and harvest known quest levels for upcoming QuestFrame detail view
local function UpdateQuestGreetingPanel()
    addon._activeOfferQuestID = nil
    if titleHoverFrame then titleHoverFrame:Hide() end
    if not QuestFrameGreetingPanel or not QuestFrameGreetingPanel:IsShown() then return end

    if Utils.RecordKnownQuestLevel and GetNumAvailableQuests and GetAvailableLevel and GetAvailableTitle then
        local okN, numAvail = pcall(GetNumAvailableQuests)
        if okN and type(numAvail) == "number" and numAvail > 0 then
            for i = 1, numAvail do
                local okT, availTitle = pcall(GetAvailableTitle, i)
                local okL, availLvl = pcall(GetAvailableLevel, i)
                if okT and okL and availTitle and type(availLvl) == "number" and availLvl > 0 then
                    Utils.RecordKnownQuestLevel(nil, availTitle, availLvl)
                end
            end
        end
    end

    for i = 1, 32 do
        local button = _G["QuestTitleButton" .. i]
        if button then
            StripButtonWorthBadge(button)
        end
    end
end

function UI.InitializeQuestOffer()
    -- Hook QuestInfo_Display (central Blizzard display handler for QuestFrame)
    if QuestInfo_Display then
        hooksecurefunc("QuestInfo_Display", function(template, parentFrame)
            UpdateQuestOfferDialog(template, parentFrame)
        end)
    end

    if QuestFrame and QuestFrame.HookScript then
        pcall(function()
            QuestFrame:HookScript("OnHide", function()
                addon._activeOfferQuestID = nil
                if titleHoverFrame then titleHoverFrame:Hide() end
            end)
        end)
    end

    -- Hook GossipFrame updates
    if GossipFrameSharedMixin and GossipFrameSharedMixin.Update then
        hooksecurefunc(GossipFrameSharedMixin, "Update", function()
            if C_Timer and C_Timer.After then
                C_Timer.After(0.02, UpdateGossipAvailableQuests)
            else
                UpdateGossipAvailableQuests()
            end
        end)
    end

    if GossipFrame and GossipFrame.HookScript then
        pcall(function()
            GossipFrame:HookScript("OnShow", function()
                if C_Timer and C_Timer.After then
                    C_Timer.After(0.05, UpdateGossipAvailableQuests)
                else
                    UpdateGossipAvailableQuests()
                end
            end)
        end)
    end

    if QuestFrameGreetingPanel and QuestFrameGreetingPanel.HookScript then
        pcall(function()
            QuestFrameGreetingPanel:HookScript("OnShow", function()
                if C_Timer and C_Timer.After then
                    C_Timer.After(0.02, UpdateQuestGreetingPanel)
                else
                    UpdateQuestGreetingPanel()
                end
            end)
        end)
    end
end

-- Export update routines
UI.UpdateQuestOfferDialog = UpdateQuestOfferDialog
UI.UpdateGossipAvailableQuests = UpdateGossipAvailableQuests
UI.UpdateQuestGreetingPanel = UpdateQuestGreetingPanel
