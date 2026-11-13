--[[
    WorthIt / QuestWorth - UI/QuestOffer.lua
    Evaluates and displays Worth % on new, unaccepted quests BEFORE the player accepts them.
    
    Covers:
    1. Gossip NPC Dialogue (GossipFrame / ScrollBox / GossipTitleButtons):
       Badges available quests with exclamation marks [!] right in the NPC's quest list.
    2. Quest Greeting Panel (QuestFrameGreetingPanel / QuestTitleButtons):
       Badges available quests in multi-quest greeting dialogs.
    3. Quest Detail & Offer Panel (QuestFrame / QuestFrameDetailPanel):
       - Badges QuestInfoTitleHeader cleanly with the colored Worth % [XX%] at the top of the parchment.
       - NO floating buttons or overlays over Accept / Decline buttons!
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

local function HookHoverTooltip(widget, getQuestIDFunc)
    if not widget or widget._worthItHooked then return end
    widget._worthItHooked = true
    local function onEnter(self)
        local id = getQuestIDFunc(self)
        if id and id > 0 and UI.ShowQuestTooltip then
            UI.ShowQuestTooltip(GameTooltip, id, self)
        end
    end
    local function onLeave()
        if GameTooltip then GameTooltip:Hide() end
    end
    if widget.HookScript then
        widget:HookScript("OnEnter", onEnter)
        widget:HookScript("OnLeave", onLeave)
    elseif widget.SetScript then
        local origEnter = widget.GetScript and widget:GetScript("OnEnter")
        widget:SetScript("OnEnter", function(self, ...)
            if origEnter then origEnter(self, ...) end
            onEnter(self)
        end)
        local origLeave = widget.GetScript and widget:GetScript("OnLeave")
        widget:SetScript("OnLeave", function(self, ...)
            if origLeave then origLeave(self, ...) end
            onLeave(self)
        end)
    end
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

-- Update Quest Detail / Offer dialog (QuestFrameDetailPanel / QuestInfoTitleHeader)
local function UpdateQuestOfferDialog()
    if not (addon.db and addon.db.enabled) then return end
    if not QuestFrame or not QuestFrame:IsShown() then return end

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
    if addon.Scores and addon.Scores.InvalidateRewardCache then
        addon.Scores.InvalidateRewardCache()
    end

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then return end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local isBankable = (breakdown and breakdown.isBankable)
    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)

    -- Attach mouseover tooltip on QuestInfoTitleHeader / QuestDetailTitleText
    local hover = EnsureTitleHoverFrame()
    if hover then
        local anchor = (QuestInfoTitleHeader and ((QuestInfoTitleHeader.IsVisible and QuestInfoTitleHeader:IsVisible()) or (QuestInfoTitleHeader.IsShown and QuestInfoTitleHeader:IsShown())) and QuestInfoTitleHeader)
            or (QuestDetailTitleText and ((QuestDetailTitleText.IsVisible and QuestDetailTitleText:IsVisible()) or (QuestDetailTitleText.IsShown and QuestDetailTitleText:IsShown())) and QuestDetailTitleText)
            or QuestInfoTitleHeader or QuestDetailTitleText
        if anchor then
            hover:ClearAllPoints()
            hover:SetAllPoints(anchor)
            local p = (anchor and anchor.GetParent and anchor:GetParent()) or QuestFrameDetailPanel or QuestFrame
            hover:SetParent(p)
            hover:SetFrameLevel((p:GetFrameLevel() or 1) + 10)
        end
        hover.questID = qID
        hover:Show()
    end

    local hintText = L["HOVER_TITLE_HINT"] or "Hover title for Worth details & score breakdown"
    local hintLine = "\n|cff888888<" .. hintText .. ">|r"

    -- 1. Badge QuestInfoTitleHeader at the top of the quest offer parchment
    if QuestInfoTitleHeader and QuestInfoTitleHeader.GetText and QuestInfoTitleHeader.SetText then
        local rawTitle = QuestInfoTitleHeader:GetText() or ""
        if rawTitle ~= "" then
            local clean = Utils.CleanQuestTitle(rawTitle)
            local payoff = addon.Data and addon.Data.GetQuestPayoff and addon.Data.GetQuestPayoff(qID, clean)
            local payoffLine = ""
            if payoff and payoff.tip and payoff.tip ~= "" then
                payoffLine = "\n|cff1aff4d• Tip: " .. payoff.tip .. "|r"
            elseif payoff and payoff.summary and payoff.summary ~= "" then
                payoffLine = "\n|cffffd100• " .. payoff.summary .. "|r"
            end
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
            local payoff = addon.Data and addon.Data.GetQuestPayoff and addon.Data.GetQuestPayoff(qID, clean)
            local payoffLine = ""
            if payoff and payoff.tip and payoff.tip ~= "" then
                payoffLine = "\n|cff1aff4d• Tip: " .. payoff.tip .. "|r"
            elseif payoff and payoff.summary and payoff.summary ~= "" then
                payoffLine = "\n|cffffd100• " .. payoff.summary .. "|r"
            end
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

-- Update available quests in GossipFrame (NPC dialog with exclamation marks)
local function UpdateGossipAvailableQuests()
    if not (addon.db and addon.db.enabled) then return end
    if not GossipFrame or not GossipFrame:IsShown() then return end

    -- 1. Modern ScrollBox Framework (Dragonflight / 11.x / Interface 16001)
    if GossipFrame.GreetingPanel and GossipFrame.GreetingPanel.ScrollBox and GossipFrame.GreetingPanel.ScrollBox.GetView then
        local view = GossipFrame.GreetingPanel.ScrollBox:GetView()
        if view and view.EnumerateFrames then
            for _, frame in view:EnumerateFrames() do
                if frame and frame:IsShown() then
                    local data = frame.GetElementData and frame:GetElementData()
                    local qID = data and ((data.info and data.info.questID) or data.questID)
                    local fontString = frame.GreetingText or frame.Text or (frame.GetFontString and frame:GetFontString())

                    if qID and qID > 0 and fontString and fontString.GetText and fontString.SetText then
                        local worth, breakdown = addon.Engine.CalculateWorth(qID)
                        if worth then
                            local isComplete = (breakdown and breakdown.isComplete)
                            local isHard = (breakdown and breakdown.isHard)
                            local isBankable = (breakdown and breakdown.isBankable)
                            local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)
                            local raw = fontString:GetText() or ""
                            local clean = Utils.CleanQuestTitle(raw)
                            local target = badge .. " " .. clean
                            if raw ~= target then
                                fontString:SetText(target)
                            end

                            -- Hook frame tooltip to show Worth breakdown and payoffs on hover
                            HookHoverTooltip(frame, function(f)
                                local d = f.GetElementData and f:GetElementData()
                                return d and ((d.info and d.info.questID) or d.questID)
                            end)
                        end
                    end
                end
            end
        end
    end

    -- 2. Classic GossipTitleButton fallback (GossipTitleButton1 to 32)
    local availableQuests = C_GossipInfo and C_GossipInfo.GetAvailableQuests and C_GossipInfo.GetAvailableQuests()
    if availableQuests and #availableQuests > 0 then
        for i, qInfo in ipairs(availableQuests) do
            local button = _G["GossipTitleButton" .. i]
            if button and button:IsShown() and qInfo.questID then
                local worth, breakdown = addon.Engine.CalculateWorth(qInfo.questID)
                if worth then
                    local isComplete = (breakdown and breakdown.isComplete)
                    local isHard = (breakdown and breakdown.isHard)
                    local isBankable = (breakdown and breakdown.isBankable)
                    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)
                    local raw = button:GetText() or ""
                    local clean = Utils.CleanQuestTitle(raw)
                    local target = badge .. " " .. clean
                    if raw ~= target then
                        button:SetText(target)
                    end

                    button._worthItQuestID = qInfo.questID
                    HookHoverTooltip(button, function(b) return b._worthItQuestID end)
                end
            end
        end
    end
end

-- Update available quests in QuestFrameGreetingPanel (Classic multiple quest offer)
local function UpdateQuestGreetingPanel()
    if not (addon.db and addon.db.enabled) then return end
    if not QuestFrameGreetingPanel or not QuestFrameGreetingPanel:IsShown() then return end

    local numAvailable = (GetNumAvailableQuests and GetNumAvailableQuests()) or 0
    if numAvailable > 0 then
        for i = 1, numAvailable do
            local button = _G["QuestTitleButton" .. i]
            local title = GetAvailableTitle and GetAvailableTitle(i)
            if button and button:IsShown() and title then
                -- Match questID by title from C_GossipInfo
                local qID = nil
                local availableQuests = C_GossipInfo and C_GossipInfo.GetAvailableQuests and C_GossipInfo.GetAvailableQuests()
                if availableQuests then
                    for _, q in ipairs(availableQuests) do
                        if q.title == title then qID = q.questID; break end
                    end
                end

                if qID and qID > 0 then
                    local worth, breakdown = addon.Engine.CalculateWorth(qID)
                    if worth then
                        local isComplete = (breakdown and breakdown.isComplete)
                        local isHard = (breakdown and breakdown.isHard)
                        local isBankable = (breakdown and breakdown.isBankable)
                        local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)
                        local raw = button:GetText() or ""
                        local clean = Utils.CleanQuestTitle(raw)
                        local target = badge .. " " .. clean
                        if raw ~= target then
                            button:SetText(target)
                        end

                        button._worthItQuestID = qID
                        HookHoverTooltip(button, function(b) return b._worthItQuestID end)
                    end
                end
            end
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
end

-- Export update routines
UI.UpdateQuestOfferDialog = UpdateQuestOfferDialog
UI.UpdateGossipAvailableQuests = UpdateGossipAvailableQuests
UI.UpdateQuestGreetingPanel = UpdateQuestGreetingPanel
