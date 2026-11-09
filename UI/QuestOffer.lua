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

    if not qID or qID <= 0 then return end

    local worth, breakdown = addon.Engine.CalculateWorth(qID)
    if not worth then return end

    local isComplete = (breakdown and breakdown.isComplete)
    local isHard = (breakdown and breakdown.isHard)
    local isBankable = (breakdown and breakdown.isBankable)
    local badge = Utils.FormatBadge(worth, isComplete, isHard, isBankable)

    -- 1. Badge QuestInfoTitleHeader at the top of the quest offer parchment
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
