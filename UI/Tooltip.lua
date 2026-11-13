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

    -- 1. Class Fit (Gear Upgrades first!)
    local fDetails = b.details.classFit
    local fReason = fDetails and fDetails.reason
    if not fReason and b.f and fDetails and fDetails.hasItems then
        if b.f >= 0.80 then fReason = "Gear Upgrade"
        elseif b.f <= 0.20 then fReason = "Unusable Items"
        end
    end
    if fReason then
        if fReason == "Gear Upgrade" then
            table.insert(reasons, "|cff1aff4dGear Upgrade!|r")
        elseif fReason == "Unusable Items" then
            table.insert(reasons, "|cff888888No Gear Upgrades|r")
        else
            table.insert(reasons, fReason)
        end
    end

    -- 2. Chain Reason
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
    if cReason then
        if cReason == "Chain Finale" then
            table.insert(reasons, "|cff1aff4dChain Finale|r")
        elseif cReason == "Chain Start" then
            table.insert(reasons, "|cffffd100Chain Start|r")
        elseif cReason == "Class Quest" then
            table.insert(reasons, "|cff00ffffClass Quest|r")
        else
            table.insert(reasons, cReason)
        end
    end

    -- 3. Reward Reason
    local rDetails = b.details.reward
    local rReason = rDetails and rDetails.reason
    if not rReason and b.r then
        if b.r < 0.30 then rReason = "Low XP"
        elseif b.r >= 0.85 then rReason = "High XP"
        end
    end
    if rReason then
        if rReason == "High XP" or (rReason == "Talk-To" and b.r and b.r >= 0.85) then
            table.insert(reasons, "|cff00ff00High XP|r")
        elseif rReason == "Good Gold" then
            table.insert(reasons, "|cffffcc00Good Gold|r")
        elseif rReason == "Low XP" then
            table.insert(reasons, "|cffaaaaaaLow XP|r")
        elseif rReason ~= "Talk-To" then
            table.insert(reasons, rReason)
        end
    end

    -- 4. Hub Density Reason
    local hDetails = b.details.density
    local hReason = hDetails and hDetails.reason
    if not hReason and b.h then
        if b.h <= 0.35 then hReason = "Isolated"
        elseif b.h >= 0.85 then hReason = "Quest Hub"
        elseif hDetails and hDetails.isUnaccepted then hReason = "NPC Hub"
        end
    end
    if hReason then
        if hReason == "Quest Hub" then
            local cnt = (hDetails and hDetails.clusterCount) or 4
            table.insert(reasons, string.format("|cff00ccffQuest Hub (%dQ)|r", cnt))
        elseif hReason == "NPC Hub" then
            table.insert(reasons, "|cff00ccffNPC Hub|r")
        elseif hReason == "Isolated" then
            table.insert(reasons, "|cffffaa00Isolated Solo|r")
        else
            table.insert(reasons, hReason)
        end
    end

    -- 5. Difficulty Reason
    local dDetails = b.details.difficulty
    local dReason = dDetails and dDetails.reason
    if not dReason and b.d then
        if dDetails and (dDetails.isTalkTo or dDetails.reason == "Talk-To") then dReason = "Talk to NPC"
        elseif dDetails and (dDetails.colorName == "red" or dDetails.colorName == "orange") then dReason = "High Level"
        elseif dDetails and dDetails.isElite then dReason = "Elite Mob"
        elseif dDetails and dDetails.isDungeon then dReason = "Dungeon"
        elseif dDetails and dDetails.colorName == "gray" then dReason = "Trivial"
        elseif b.d <= 0.20 then dReason = "Hard Mob"
        end
    end
    if dReason then
        if dReason == "Talk to NPC" or dReason == "Talk-To" or (dDetails and dDetails.isTalkTo) or b.isTalkTo then
            table.insert(reasons, "|cff00ff00" .. (L["TALK_TO_HIGHLIGHT"] or "Talk to NPC") .. "|r")
        elseif dReason == "Elite Mob" then
            table.insert(reasons, "|cffff9900Elite Mob|r")
        elseif dReason == "Dungeon" then
            table.insert(reasons, "|cff00ccffDungeon|r")
        elseif dReason == "High Level" or dReason == "Hard Mob" then
            table.insert(reasons, "|cffff4444Challenging|r")
        elseif dReason == "Trivial" then
            table.insert(reasons, "|cffaaaaaaTrivial (Gray)|r")
        else
            table.insert(reasons, dReason)
        end
    end

    -- 6. Future Value / Bank for Later
    if b.isBankable then
        table.insert(reasons, "|cffff9900Save for Later|r")
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
    local badge = Utils.FormatBadge(worth, b.isComplete, b.isHard, isBankable)

    tooltip:AddLine(" ")

    -- 1. Main Header: Quest Worth [XX%] + Descriptive Status Tag (Matching Zone Advisor)
    local statusDesc
    if b.isComplete then
        statusDesc = "|cff1aff4dReady to Turn In!|r"
    elseif isBankable then
        statusDesc = "|cffff9900Bank for Later|r"
    elseif worth >= 0.82 then
        statusDesc = (b.details and b.details.classFit and b.details.classFit.reason == "Gear Upgrade") and "|cff1aff4dGear Upgrade!|r" or "|cff1aff4dTop Priority|r"
    elseif worth >= 0.70 then
        statusDesc = "|cff00ff00Optimal Leveling|r"
    elseif worth >= 0.50 then
        statusDesc = "|cffffff00Good Quest|r"
    else
        statusDesc = "|cffaaaaaaLow Value|r"
    end

    tooltip:AddDoubleLine(
        "|cffffd100" .. L["WORTH_METER"] .. ":|r",
        badge .. " " .. statusDesc,
        1, 1, 1,
        1, 1, 1
    )

    -- 2. Suitability / Recommendation (Theme matching Zone Advisor)
    local adviceText
    if b.isComplete then
        adviceText = "|cff1aff4dClaim XP & Rewards!|r"
    elseif isBankable then
        adviceText = "|cffffcc00Do in +1-2 Levels (Save in Log)|r"
    elseif b.isTalkTo or (b.details and b.details.difficulty and b.details.difficulty.isTalkTo) then
        local cDetails = b.details and b.details.chain
        if cDetails and cDetails.step == 1 and (cDetails.totalSteps or 1) > 1 then
            adviceText = "|cff00ff00" .. (L["TALK_TO_CHAIN_START"] or "Do Now (Talk to NPC • Chain Start)") .. "|r"
        else
            adviceText = "|cff00ff00" .. (L["TALK_TO_SUITABILITY"] or "Do Now (Talk to NPC)") .. "|r"
        end
    elseif worth >= 0.70 then
        local clusterNote = (b.details and b.details.density and b.details.density.clusterCount and b.details.density.clusterCount >= 3) and "Quest Hub" or "High XP"
        adviceText = string.format("|cff00ff00Do Now (%s)|r", clusterNote)
    elseif b.isHard then
        adviceText = "|cffff5533Bring Group / Elite Mob|r"
    elseif worth < 0.35 then
        local dColor = b.details and b.details.difficulty and b.details.difficulty.colorName
        local dDelta = b.details and b.details.difficulty and b.details.difficulty.levelDelta
        if dColor == "red" or (dDelta and dDelta >= 4) then
            adviceText = "|cffff3333Too High Level (Skip for Now)|r"
        else
            adviceText = "|cff888888Skip or Abandon (Outleveled)|r"
        end
    else
        adviceText = "|cffffcc00Standard Leveling|r"
    end

    tooltip:AddDoubleLine(
        "|cff00ccff" .. (L["SUITABILITY"] or "Suitability") .. ":|r",
        adviceText,
        0.9, 0.9, 0.9,
        1, 1, 1
    )

    -- 3. Standout Highlights (Fastest Read in 0.1s!)
    if not b.isComplete then
        local reasons = GetReasonSummary(b)
        if reasons and #reasons > 0 then
            tooltip:AddDoubleLine(
                "|cff00ccff" .. (L["HIGHLIGHTS"] or "Highlights") .. ":|r",
                table.concat(reasons, " |cff666666•|r "),
                0.9, 0.9, 0.9,
                1, 1, 1
            )
        end
    end

    -- 4. Meta-Knowledge: Key Unlock, Quest Tip & Payoff details (Displayed right after Verdict!)
    local payoff = addon.Data and addon.Data.GetQuestPayoff and addon.Data.GetQuestPayoff(questID)
    local questTip = addon.Data and addon.Data.GetQuestTip and addon.Data.GetQuestTip(questID)
    local tipText = (payoff and payoff.tip) or questTip

    if (payoff and (payoff.unlock or payoff.reward or payoff.chain or payoff.note or payoff.origin or payoff.tip)) or (tipText and tipText ~= "") then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffffd100" .. L["PAYOFF_HEADER"] .. "|r")

        -- 1. Quest Tip / Objective Guide (Prominent & immediately visible!)
        if tipText and tipText ~= "" then
            tooltip:AddLine("  |cff1aff4d★ " .. (L["PAYOFF_TIP"] or "Tip:") .. "|r |cffffffff" .. tipText .. "|r", 0.9, 0.9, 0.9, true)
        end

        -- 2. Chain details
        if payoff and payoff.chain then
            tooltip:AddLine("  |cff00ccff" .. L["PAYOFF_CHAIN"] .. "|r |cffffffff" .. payoff.chain .. "|r")
        end

        -- 3. Key / Dungeon Unlocks
        if payoff and payoff.unlock then
            tooltip:AddLine("  |cff00ffff" .. L["PAYOFF_UNLOCKS"] .. "|r |cffffffff" .. payoff.unlock .. "|r")
        end

        -- 4. Top Reward
        if payoff and payoff.reward then
            tooltip:AddLine("  |cffffd100" .. L["PAYOFF_REWARD"] .. "|r |cffffffff" .. payoff.reward .. "|r")
        end

        -- 5. Quest Origin / Type
        if payoff and payoff.origin then
            tooltip:AddLine("  |cffffaa00" .. (L["PAYOFF_TYPE"] or "Type:") .. "|r |cffffffff" .. payoff.origin .. "|r")
        end

        -- 6. Lore / Notes
        if payoff and payoff.note and payoff.note ~= tipText then
            tooltip:AddLine("  |cffcccccc" .. payoff.note .. "|r", 0.85, 0.85, 0.85, true)
        end
    end

    -- 5. 5-Factor Score Breakdown (Clean, muted labels with prominent values)
    if not b.isComplete and addon.db.showBreakdown then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff888888" .. L["BREAKDOWN"] .. ":|r")

        local rNote = ""
        if b.details and b.details.reward and b.details.reward.rewardXP and b.details.reward.rewardXP > 0 then
            rNote = string.format(" |cff888888(%d XP)|r", b.details.reward.rewardXP)
        end

        local fNote = ""
        if b.details and b.details.classFit and b.details.classFit.hasItems then
            fNote = (b.f >= 0.80) and " |cff1aff4d(Upgrade)|r" or " |cff888888(Vendor)|r"
        else
            fNote = " |cff888888(No Gear)|r"
        end

        local cNote = ""
        if b.details and b.details.chain then
            if b.details.chain.isClassOrProfession then
                cNote = " |cff00ffff(Class)|r"
            elseif b.details.chain.totalSteps and b.details.chain.totalSteps > 1 then
                cNote = string.format(" |cff888888(Step %d/%d)|r", b.details.chain.step or 1, b.details.chain.totalSteps)
            end
        end

        local hNote = ""
        if b.details and b.details.density and b.details.density.clusterCount then
            hNote = string.format(" |cff888888(%d in zone)|r", b.details.density.clusterCount)
        end

        local diffText
        if b.isTalkTo or (b.details and b.details.difficulty and b.details.difficulty.isTalkTo) then
            diffText = "|cff00ff00" .. (L["SAFE_TALK_TO"] or "Safe (Talk to NPC)") .. "|r"
        elseif b.wD and b.wD <= 0.001 then
            diffText = b.isHard and "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:11:11:0:0|t |cffff3333Hard|r" or "|cff00ff00Normal|r"
        else
            local deltaStr = (b.details and b.details.difficulty and b.details.difficulty.levelDelta) and string.format(" (%+d)", b.details.difficulty.levelDelta) or ""
            diffText = Utils.FormatScore(b.d) .. "|cff888888" .. deltaStr .. "|r"
        end

        tooltip:AddDoubleLine(
            "  |cffa0a0a0" .. L["REWARD"] .. ":|r",
            Utils.FormatScore(b.r) .. rNote,
            0.85, 0.85, 0.85, 1, 1, 1
        )
        tooltip:AddDoubleLine(
            "  |cffa0a0a0" .. L["CLASS_FIT"] .. ":|r",
            Utils.FormatScore(b.f) .. fNote,
            0.85, 0.85, 0.85, 1, 1, 1
        )
        tooltip:AddDoubleLine(
            "  |cffa0a0a0" .. L["CHAIN"] .. ":|r",
            Utils.FormatScore(b.c) .. cNote,
            0.85, 0.85, 0.85, 1, 1, 1
        )
        tooltip:AddDoubleLine(
            "  |cffa0a0a0" .. (L["DENSITY"] or "Hub Density") .. ":|r",
            Utils.FormatScore(b.h or 0.5) .. hNote,
            0.85, 0.85, 0.85, 1, 1, 1
        )
        if (b.wD and b.wD > 0.001) or b.isHard or b.isTalkTo or (b.details and b.details.difficulty and b.details.difficulty.isTalkTo) then
            tooltip:AddDoubleLine(
                "  |cffa0a0a0" .. L["DIFFICULTY"] .. ":|r",
                diffText,
                0.85, 0.85, 0.85, 1, 1, 1
            )
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

    local starter = addon.Data and addon.Data.SecretQuestStarters and addon.Data.SecretQuestStarters[itemID]
    local qID = (starter and starter.questID) or (addon.Data and addon.Data.ItemQuestMap and addon.Data.ItemQuestMap[itemID])
    local isStarter = (qID ~= nil) or (starter ~= nil)

    if not isStarter then
        local _, _, _, _, _, itemType, _, _, _, _, _, _, classID = addon.Utils.SafeGetItemInfo(link)
        if classID == 12 or itemType == "Quest" then
            isStarter = TooltipHasQuestStarterText(tooltip)
        end
    end

    if isStarter then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffffd100★ " .. L["ITEM_QUEST_STARTER"] .. "|r")
        if qID then
            local info = addon.Utils.GetQuestBasicInfo(qID)
            local payoff = addon.Data.GetQuestPayoff(qID)
            if info and info.title then
                tooltip:AddLine("  |cff00ccff" .. L["ITEM_STARTS_QUEST"] .. "|r |cffffffff" .. info.title .. "|r")
            end
            if payoff and payoff.tip then
                tooltip:AddLine("  |cff1aff4d★ " .. (L["PAYOFF_TIP"] or "Tip:") .. "|r |cffffffff" .. payoff.tip .. "|r", 0.9, 0.9, 0.9, true)
            elseif payoff and payoff.summary then
                tooltip:AddLine("  |cffffd100" .. L["PAYOFF_REWARD"] .. "|r |cffffffff" .. payoff.summary .. "|r")
            end
        end
        if starter and starter.drop and starter.drop ~= "" then
            tooltip:AddLine("  |cffcccccc• " .. starter.drop .. "|r", 0.85, 0.85, 0.85, true)
        end
        tooltip:AddLine("  |cff1aff4d" .. L["ITEM_CLICK_TO_START"] .. "|r")
        tooltip._worthItAddedItemID = itemID
        if tooltip.Show then tooltip:Show() end
    end
end

-- Programmatic Tooltip display for NPC dialogs, gossip, or custom frames
function UI.ShowQuestTooltip(tooltip, questID, owner)
    if not tooltip or type(tooltip) ~= "table" or not Utils.IsValidQuestID(questID) then return end
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
    if GameTooltip and hooksecurefunc then
        pcall(hooksecurefunc, GameTooltip, "ClearLines", OnTooltipCleared)
    end
    if ItemRefTooltip and hooksecurefunc then
        pcall(hooksecurefunc, ItemRefTooltip, "ClearLines", OnTooltipCleared)
    end
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
            local qID = UI.ResolveButtonQuestID and UI.ResolveButtonQuestID(button)
            if not qID and button then
                qID = button.questID or (button.GetElementData and button:GetElementData() and ((button:GetElementData().info and button:GetElementData().info.questID) or button:GetElementData().questID))
            end
            if not qID and button and button.questLogIndex then
                if C_QuestLog and C_QuestLog.GetInfo then
                    local ok, info = pcall(C_QuestLog.GetInfo, button.questLogIndex)
                    if ok and info then qID = info.questID end
                elseif GetQuestLogTitle then
                    local ok, _, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, button.questLogIndex)
                    if ok and not h and id and id > 0 then qID = id end
                end
            end
            if not qID and button and button.GetID then
                local idx = button:GetID()
                if idx and idx > 0 and C_QuestLog and C_QuestLog.GetInfo then
                    local ok, info = pcall(C_QuestLog.GetInfo, idx)
                    if ok and info then qID = info.questID end
                elseif GetQuestLogTitle then
                    local ok, _, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, idx)
                    if ok and not h and id and id > 0 then qID = id end
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
            local qID = UI.ResolveButtonQuestID and UI.ResolveButtonQuestID(button)
            if not qID and button then
                qID = button.questID
            end
            if not qID and button and button.questLogIndex then
                if C_QuestLog and C_QuestLog.GetInfo then
                    local ok, info = pcall(C_QuestLog.GetInfo, button.questLogIndex)
                    if ok and info then qID = info.questID end
                elseif GetQuestLogTitle then
                    local ok, _, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, button.questLogIndex)
                    if ok and not h and id and id > 0 then qID = id end
                end
            end
            if not qID and button and button.GetID then
                local idx = button:GetID()
                if idx and idx > 0 and C_QuestLog and C_QuestLog.GetInfo then
                    local ok, info = pcall(C_QuestLog.GetInfo, idx)
                    if ok and info then qID = info.questID end
                elseif GetQuestLogTitle then
                    local ok, _, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, idx)
                    if ok and not h and id and id > 0 then qID = id end
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
