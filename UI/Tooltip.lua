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

    tooltip._worthItAddedQuestID = questID

    if isLegacy and tooltip.Show then
        tooltip:Show()
    end
end

-- Clear the deduplication token when tooltip is cleared
local function OnTooltipCleared(tooltip)
    tooltip._worthItAddedQuestID = nil
end

function UI.InitializeTooltips()
    local hooked = false

    -- Method 1: Modern TooltipDataProcessor (Interface 16001 / Modern Mainline engine)
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Quest then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, function(tooltip, data)
            local qID = data and (data.id or data.questID)
            if qID and qID > 0 then
                AddWorthLinesToTooltip(tooltip, qID, false)
            end
        end)
        hooked = true
        addon.Debug("Hooked TooltipDataProcessor for Quest tooltips.")
    end

    -- Hook GameTooltip Clear
    if GameTooltip and GameTooltip.HookScript then
        pcall(function()
            GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
        end)
    end
    if ItemRefTooltip and ItemRefTooltip.HookScript then
        pcall(function()
            ItemRefTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
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

    -- Method 4: Hook QuestMapLogTitleButton_OnEnter
    if QuestMapLogTitleButton_OnEnter then
        hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(button)
            if button and button.questID then
                addon.lastHoveredQuestID = button.questID
            end
        end)
    end
end
