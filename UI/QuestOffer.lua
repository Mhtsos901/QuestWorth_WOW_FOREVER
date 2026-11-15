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

local function CleanOfferTitle(raw)
    local stripped = string.gsub(raw or "", "\n|cff.-$", "")
    return Utils.CleanQuestTitle(stripped)
end

-- Update Quest Detail / Offer dialog (QuestFrameDetailPanel / QuestInfoTitleHeader)
local function UpdateQuestOfferDialog()
    if not (addon.db and addon.db.enabled) then
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
        return
    end
    if not QuestFrame or not QuestFrame:IsShown() then return end
    if QuestFrameGreetingPanel and QuestFrameGreetingPanel:IsShown() then
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

    if not qID and QuestInfoTitleHeader and QuestInfoTitleHeader.GetText then
        local rawTitle = QuestInfoTitleHeader:GetText() or ""
        local clean = Utils.CleanQuestTitle(rawTitle)
        local titleNoLevel = string.gsub(clean, "^%s*%[%d+%]%s*", "")
        titleNoLevel = string.gsub(titleNoLevel, "^%s*", "")
        titleNoLevel = string.gsub(titleNoLevel, "%s*$", "")

        local availableQuests = C_GossipInfo and C_GossipInfo.GetAvailableQuests and C_GossipInfo.GetAvailableQuests()
        if availableQuests then
            for _, q in ipairs(availableQuests) do
                if q.title == titleNoLevel or q.title == clean or string.find(clean, q.title, 1, true) then
                    qID = q.questID
                    break
                end
            end
        end

        if not qID and addon.lastHoveredQuestID then
            qID = addon.lastHoveredQuestID
        end
    end

    if not qID or qID <= 0 then
        if titleHoverFrame then titleHoverFrame:Hide() end
        return
    end

    -- Invalidate cached calculation for this quest to ensure live QuestFrame offer rewards & XP are evaluated fresh
    if addon.Engine and addon.Engine.InvalidateCache then
        addon.Engine.InvalidateCache(qID)
    elseif addon.Engine and addon.Engine.Cache then
        addon.Engine.Cache[qID] = nil
    end
    if Utils.ClearQuestRewardsCache then
        Utils.ClearQuestRewardsCache(qID)
    end
    if Utils.ClearTalkToCache then
        Utils.ClearTalkToCache(qID)
    end
    if addon.Data and addon.Data.InvalidatePayoffMemo then
        addon.Data.InvalidatePayoffMemo(qID)
    end
    if addon.Scores and addon.Scores.InvalidateRewardCache then
        addon.Scores.InvalidateRewardCache(qID)
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
    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable, isLowValue)

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
    local hintLine = "\n|cff331a00<" .. hintText .. ">|r"

    local cleanOfferName = Utils.CleanQuestTitle(
        (QuestInfoTitleHeader and QuestInfoTitleHeader.GetText and QuestInfoTitleHeader:GetText())
        or (QuestDetailTitleText and QuestDetailTitleText.GetText and QuestDetailTitleText:GetText())
        or ""
    )
    local payoff = addon.Data and addon.Data.GetQuestPayoff and addon.Data.GetQuestPayoff(qID, cleanOfferName)
    local payoffLine = ""
    if payoff and payoff.tip and payoff.tip ~= "" then
        payoffLine = "\n|cff004d14• Tip: " .. payoff.tip .. "|r"
    elseif payoff and payoff.summary and payoff.summary ~= "" then
        payoffLine = "\n|cff5a1807• " .. payoff.summary .. "|r"
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
            payoffLine = "\n|cff103055• " .. table.concat(dynParts, " • ") .. "|r"
        end
    end

    -- 1. Badge QuestInfoTitleHeader at the top of the quest offer parchment
    if QuestInfoTitleHeader and QuestInfoTitleHeader.GetText and QuestInfoTitleHeader.SetText then
        local rawTitle = QuestInfoTitleHeader:GetText() or ""
        if rawTitle ~= "" then
            local clean = Utils.CleanQuestTitle(rawTitle)
            local targetTitle = badge .. " " .. clean .. hintLine .. payoffLine
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
            local target = badge .. " " .. clean .. hintLine .. payoffLine
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
local function UpdateGossipAvailableQuests()
    if not GossipFrame or not GossipFrame:IsShown() then return end

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
local function UpdateQuestGreetingPanel()
    if titleHoverFrame then titleHoverFrame:Hide() end
    if not QuestFrameGreetingPanel or not QuestFrameGreetingPanel:IsShown() then return end

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
        hooksecurefunc("QuestInfo_Display", function()
            UpdateQuestOfferDialog()
        end)
    end

    if QuestFrame and QuestFrame.HookScript then
        pcall(function()
            QuestFrame:HookScript("OnHide", function()
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
