--[[
    WorthIt / QuestWorth - UI/Tooltip.lua
    Safe tooltip hooks (Modern TooltipDataProcessor + Legacy OnTooltipSetQuest fallback).
    
    Guards:
    - Deduplication: Prevents double-injecting lines on multi-pass tooltip refreshes.
    - Safe Show(): Avoids recursive Show() loops in modern TooltipDataProcessor.
]]

local addonName, addon = ...
addon.UI = addon.UI or {}
local UI = addon.UI
local Utils = addon.Utils
local L = addon.L

addon.lastHoveredQuestID = nil

local function GetReasonSummary(b)
    if not b or not b.details then return nil end
    local reasons = {}

    -- 1. Difficulty Reason
    local dDetails = b.details.difficulty
    local dReason = dDetails and dDetails.reason
    if not dReason and b.d then
        if dDetails and (dDetails.colorName == "red" or dDetails.colorName == "orange") then dReason = "High Level"
        elseif dDetails and dDetails.isElite then dReason = "Elite Mob"
        elseif dDetails and dDetails.isDungeon then dReason = "Dungeon"
        elseif dDetails and dDetails.colorName == "gray" then dReason = "Trivial"
        elseif b.d <= 0.20 then dReason = "Hard Mob"
        end
    end
    if dReason then table.insert(reasons, dReason) end

    -- 2. Reward Reason
    local rDetails = b.details.reward
    local rReason = rDetails and rDetails.reason
    if not rReason and b.r then
        if b.r < 0.30 then rReason = "Low XP"
        elseif b.r >= 0.85 then rReason = "High XP"
        end
    end
    if rReason then table.insert(reasons, rReason) end

    -- 3. Chain Reason
    local cDetails = b.details.chain
    local cReason = cDetails and cDetails.reason
    if not cReason and cDetails then
        if cDetails.step == 1 and (cDetails.totalSteps or 1) > 1 then
            cReason = "Chain Start"
        elseif cDetails.isCap and (cDetails.totalSteps or 1) > 1 then
            cReason = "Chain Finale"
        elseif cDetails.isClassOrProfession then
            cReason = "Class Quest"
        end
    end
    if cReason then table.insert(reasons, cReason) end

    -- 4. Class Fit Reason
    local fDetails = b.details.classFit
    local fReason = fDetails and fDetails.reason
    if not fReason and b.f and fDetails and fDetails.hasItems then
        if b.f >= 0.80 then fReason = "Gear Upgrade"
        elseif b.f <= 0.20 then fReason = "Unusable Items"
        end
    end
    if fReason then table.insert(reasons, fReason) end

    -- 5. Density Reason
    local hDetails = b.details.density
    local hReason = hDetails and hDetails.reason
    if not hReason and b.h then
        if b.h <= 0.35 then hReason = "Isolated"
        elseif b.h >= 0.85 then hReason = "Quest Hub"
        elseif hDetails and hDetails.isUnaccepted then hReason = "NPC Hub"
        end
    end
    if hReason then table.insert(reasons, hReason) end

    -- 6. Future Value / Bank for Later
    if b.isBankable then
        table.insert(reasons, "Save for Later")
    end

    return reasons
end

local function AddWorthLinesToTooltip(tooltip, questID, isLegacy)
    if not questID or questID <= 0 then return end

    addon.lastHoveredQuestID = questID

    if not (addon.db and addon.db.enabled and addon.db.showInTooltip) then return end

    -- Deduplication guard: don't append twice if tooltip didn't clear
    if tooltip._worthItAddedQuestID == questID then return end

    local worth, b = addon.Engine.CalculateWorth(questID)
    if not worth or not b then return end

    local isBankable = b.isBankable
    local colorHex = isBankable and "ff9900" or Utils.GetScoreColorHex(worth)
    local r, g, bColor
    if isBankable then
        r, g, bColor = 1.0, 0.60, 0.0
    else
        r, g, bColor = Utils.GetScoreColor(worth)
    end

    tooltip:AddLine(" ")
    if b.isComplete then
        tooltip:AddDoubleLine(
            "|cff00ccff" .. L["WORTH_METER"] .. ":|r",
            "|cff1aff4d[OK - Ready to Turn In!]|r",
            1, 1, 1,
            0.1, 1.0, 0.3
        )
    else
        local skullPrefix = b.isHard and "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:14:14:0:0|t " or ""
        tooltip:AddDoubleLine(
            "|cff00ccff" .. L["WORTH_METER"] .. ":|r",
            skullPrefix .. string.format("|cff%s%.0f%%|r", colorHex, worth * 100),
            1, 1, 1,
            r, g, bColor
        )

        if addon.db.showBreakdown then
            local diffText
            if b.wD and b.wD <= 0.001 then
                diffText = b.isHard and "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:11:11:0:0|t |cffff3333Hard|r" or "|cff00ff00Normal|r"
            else
                diffText = Utils.FormatScore(b.d)
            end
            tooltip:AddDoubleLine(
                string.format("  %s: %s", L["DIFFICULTY"], diffText),
                string.format("%s: %s", L["REWARD"], Utils.FormatScore(b.r)),
                0.8, 0.8, 0.8,
                0.8, 0.8, 0.8
            )
            tooltip:AddDoubleLine(
                string.format("  %s: %s", L["CHAIN"], Utils.FormatScore(b.c)),
                string.format("%s: %s", L["CLASS_FIT"], Utils.FormatScore(b.f)),
                0.8, 0.8, 0.8,
                0.8, 0.8, 0.8
            )
            tooltip:AddDoubleLine(
                string.format("  %s: %s", L["DENSITY"] or "Hub Density", Utils.FormatScore(b.h or 0.5)),
                "",
                0.8, 0.8, 0.8,
                0.8, 0.8, 0.8
            )
        end

        local reasons = GetReasonSummary(b)
        if reasons and #reasons > 0 then
            tooltip:AddLine("  |cff9d9d9d" .. table.concat(reasons, " • ") .. "|r")
        end

        if b.isBankable then
            tooltip:AddDoubleLine(
                "  |cffff9900Advice:|r",
                "|cffffcc00Bank for Later (Do in +1-2 Levels)|r",
                1, 1, 1,
                1.0, 0.8, 0.0
            )
        end
    end

    -- Meta-Knowledge: Key Unlock & Payoff details
    local payoff = addon.Data and addon.Data.GetQuestPayoff and addon.Data.GetQuestPayoff(questID)
    if payoff and (payoff.unlock or payoff.reward or payoff.chain or payoff.note or payoff.origin) then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffffd100" .. L["PAYOFF_HEADER"] .. "|r")
        if payoff.origin then
            tooltip:AddDoubleLine("  |cffffaa00" .. (L["PAYOFF_TYPE"] or "Type:") .. "|r", "|cffffffff" .. payoff.origin .. "|r", 0.9, 0.9, 0.9, 1, 1, 1)
        end
        if payoff.unlock then
            tooltip:AddDoubleLine("  |cff00ffff" .. L["PAYOFF_UNLOCKS"] .. "|r", "|cffffffff" .. payoff.unlock .. "|r", 0.9, 0.9, 0.9, 1, 1, 1)
        end
        if payoff.reward then
            tooltip:AddDoubleLine("  |cffffd100" .. L["PAYOFF_REWARD"] .. "|r", "|cffffffff" .. payoff.reward .. "|r", 0.9, 0.9, 0.9, 1, 1, 1)
        end
        if payoff.chain then
            tooltip:AddDoubleLine("  |cff00ccff" .. L["PAYOFF_CHAIN"] .. "|r", "|cffffffff" .. payoff.chain .. "|r", 0.9, 0.9, 0.9, 1, 1, 1)
        end
        if payoff.note then
            tooltip:AddLine("  |cffbbbbbb" .. payoff.note .. "|r")
        end
    end

    tooltip._worthItAddedQuestID = questID

    if isLegacy and tooltip.Show then
        tooltip:Show()
    end
end

-- Check if an item tooltip text indicates it begins a quest
local function TooltipHasQuestStarterText(tooltip)
    if not tooltip or not tooltip.NumLines then return false end
    local numLines = tooltip:NumLines() or 0
    local name = tooltip:GetName()
    if not name then return false end
    for i = 1, numLines do
        local line = _G[name .. "TextLeft" .. i]
        if line and line.GetText then
            local text = line:GetText()
            if text and (string.find(text, "Begins a Quest", 1, true) or
                         string.find(text, "starts a quest", 1, true) or
                         (ITEM_STARTS_QUEST and string.find(text, ITEM_STARTS_QUEST, 1, true))) then
                return true
            end
        end
    end
    return false
end

-- Inject Hidden / Item Quest Starter notification when hovering items in inventory
local function AddItemQuestStarterLines(tooltip)
    if not (addon.db and addon.db.enabled) then return end
    if not tooltip or not tooltip.GetItem then return end

    local name, link = tooltip:GetItem()
    if not link then return end

    local itemID = tonumber(string.match(link, "item:(%d+)"))
    if not itemID or itemID <= 0 then return end

    if tooltip._worthItAddedItemID == itemID then return end

    local qID = addon.Data and addon.Data.ItemQuestMap and addon.Data.ItemQuestMap[itemID]
    local isStarter = (qID ~= nil)

    if not isStarter then
        local _, _, _, _, _, itemType, _, _, _, _, _, _, classID = addon.Utils.SafeGetItemInfo(link)
        if classID == 12 or itemType == "Quest" then
            isStarter = TooltipHasQuestStarterText(tooltip)
        end
    end

    if isStarter then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffffd100" .. (L["ITEM_QUEST_STARTER"] or "★ Hidden / Item Quest Starter:") .. "|r")
        if qID then
            local info = addon.Utils.GetQuestBasicInfo(qID)
            local payoff = addon.Data.GetQuestPayoff(qID)
            if info and info.title then
                tooltip:AddDoubleLine("  |cff00ffff" .. (L["ITEM_STARTS_QUEST"] or "Starts Quest:") .. "|r", "|cffffffff" .. info.title .. "|r", 0.9, 0.9, 0.9, 1, 1, 1)
            end
            if payoff and payoff.summary then
                tooltip:AddDoubleLine("  |cffffd100" .. (L["PAYOFF_REWARD"] or "Payoff:") .. "|r", "|cffffffff" .. payoff.summary .. "|r", 0.9, 0.9, 0.9, 1, 1, 1)
            end
        end
        tooltip:AddLine("  |cff00ff00" .. (L["ITEM_CLICK_TO_START"] or "Right-click in inventory to start quest!") .. "|r")
        tooltip._worthItAddedItemID = itemID
        if tooltip.Show then tooltip:Show() end
    end
end

-- Programmatic Tooltip display for NPC dialogs, gossip, or custom frames
function UI.ShowQuestTooltip(tooltip, questID, owner)
    if not tooltip or not questID or questID <= 0 then return end
    if owner then
        tooltip:SetOwner(owner, "ANCHOR_RIGHT")
    end
    tooltip:ClearLines()
    local info = Utils.GetQuestBasicInfo(questID)
    local title = info and info.title or ("Quest #" .. questID)
    local level = info and info.level
    local levelStr = (level and level > 0) and (" [" .. level .. "]") or ""
    tooltip:AddLine(title .. levelStr, 1, 0.82, 0)
    AddWorthLinesToTooltip(tooltip, questID, true)
    if tooltip.Show then tooltip:Show() end
end

-- Clear the deduplication token when tooltip is cleared
local function OnTooltipCleared(tooltip)
    tooltip._worthItAddedQuestID = nil
    tooltip._worthItAddedItemID = nil
end

function UI.InitializeTooltips()
    local hooked = false

    -- Method 1: Modern TooltipDataProcessor (Interface 16001 / Modern Mainline engine)
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        if Enum.TooltipDataType.Quest then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, function(tooltip, data)
                local qID = data and (data.id or data.questID)
                if qID and qID > 0 then
                    AddWorthLinesToTooltip(tooltip, qID, false)
                end
            end)
        end
        if Enum.TooltipDataType.Item then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
                AddItemQuestStarterLines(tooltip)
            end)
        end
        hooked = true
        addon.Debug("Hooked TooltipDataProcessor for Quest and Item tooltips.")
    end

    -- Hook GameTooltip Clear & Hide
    if GameTooltip and GameTooltip.HookScript then
        pcall(function()
            GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
            GameTooltip:HookScript("OnHide", OnTooltipCleared)
        end)
    end
    if ItemRefTooltip and ItemRefTooltip.HookScript then
        pcall(function()
            ItemRefTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
            ItemRefTooltip:HookScript("OnHide", OnTooltipCleared)
        end)
    end

    -- Hook Item tooltips for Legacy / Classic client
    if GameTooltip and GameTooltip.HookScript then
        pcall(function()
            GameTooltip:HookScript("OnTooltipSetItem", AddItemQuestStarterLines)
        end)
    end
    if ItemRefTooltip and ItemRefTooltip.HookScript then
        pcall(function()
            ItemRefTooltip:HookScript("OnTooltipSetItem", AddItemQuestStarterLines)
        end)
    end

    -- Method 2: Classic / Legacy GameTooltip HookScript OnTooltipSetQuest
    if GameTooltip and GameTooltip.HookScript then
        pcall(function()
            GameTooltip:HookScript("OnTooltipSetQuest", function(self)
                local questID
                if self.GetQuest then
                    local ok, _, qid = pcall(self.GetQuest, self)
                    if ok and qid and qid > 0 then questID = qid end
                end
                if not questID and C_QuestLog and C_QuestLog.GetSelectedQuest then
                    local ok, qid = pcall(C_QuestLog.GetSelectedQuest)
                    if ok and qid and qid > 0 then questID = qid end
                end
                if not questID and GetQuestLogSelection then
                    local index = GetQuestLogSelection()
                    if index and index > 0 and C_QuestLog and C_QuestLog.GetInfo then
                        local info = C_QuestLog.GetInfo(index)
                        if info then questID = info.questID end
                    end
                end
                if questID then
                    AddWorthLinesToTooltip(self, questID, true)
                end
            end)
            hooked = true
            addon.Debug("Hooked GameTooltip:OnTooltipSetQuest.")
        end)
    end

    -- Method 3: Hook Chat Quest Links (SetItemRef)
    if SetItemRef then
        hooksecurefunc("SetItemRef", function(link)
            if link and string.find(link, "^quest:") then
                local questID = tonumber(string.match(link, "quest:(%d+)"))
                if questID and ItemRefTooltip then
                    AddWorthLinesToTooltip(ItemRefTooltip, questID, true)
                end
            end
        end)
    end

    -- Method 4: Hook QuestMapLogTitleButton_OnEnter & QuestLogTitleButton_OnEnter
    if QuestMapLogTitleButton_OnEnter then
        hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(button)
            local qID = button and (button.questID or (button.GetElementData and button:GetElementData() and ((button:GetElementData().info and button:GetElementData().info.questID) or button:GetElementData().questID)))
            if not qID and button and button.GetID then
                local idx = button:GetID()
                if idx and idx > 0 and C_QuestLog and C_QuestLog.GetInfo then
                    local ok, info = pcall(C_QuestLog.GetInfo, idx)
                    if ok and info then qID = info.questID end
                end
            end
            if qID and qID > 0 then
                addon.lastHoveredQuestID = qID
                AddWorthLinesToTooltip(GameTooltip, qID, true)
            end
        end)
    end

    if QuestLogTitleButton_OnEnter then
        hooksecurefunc("QuestLogTitleButton_OnEnter", function(button)
            local qID = button and button.questID
            if not qID and button and button.GetID then
                local idx = button:GetID()
                if idx and idx > 0 and C_QuestLog and C_QuestLog.GetInfo then
                    local ok, info = pcall(C_QuestLog.GetInfo, idx)
                    if ok and info then qID = info.questID end
                end
            end
            if qID and qID > 0 then
                addon.lastHoveredQuestID = qID
                AddWorthLinesToTooltip(GameTooltip, qID, true)
            end
        end)
    end
end

-- Export routines
UI.AddWorthLinesToTooltip = AddWorthLinesToTooltip
