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
    if not Utils.IsValidQuestID(questID) then return end

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
        if b.isHard then
            local dDetails = b.details and b.details.difficulty
            if dDetails and dDetails.isDungeon then
                adviceText = "|cff00ccffDo Now (Dungeon Group)|r"
            else
                adviceText = "|cffff9900Do Now (Group / Elite)|r"
            end
        else
            local clusterNote = (b.details and b.details.density and b.details.density.clusterCount and b.details.density.clusterCount >= 3) and "Quest Hub" or "High XP"
            adviceText = string.format("|cff00ff00Do Now (%s)|r", clusterNote)
        end
    elseif b.isHard then
        adviceText = "|cffff5533Bring Group / Elite Mob|r"
    elseif worth < 0.35 then
        local dColor = b.details and b.details.difficulty and b.details.difficulty.colorName
        local dDelta = b.details and b.details.difficulty and b.details.difficulty.levelDelta
        if dColor == "red" or (dDelta and dDelta >= 4) then
            adviceText = "|cffff3333Too High Level (Skip for Now)|r"
        elseif dColor == "gray" then
            adviceText = "|cff888888Skip or Abandon (Outleveled)|r"
        else
            adviceText = "|cffaaaaaaLow Reward (Optional)|r"
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
            tooltip:AddLine("  |cff00ccff" .. L["PAYOFF_CHAIN"] .. "|r |cffffffff" .. payoff.chain .. "|r", 1, 1, 1, true)
        end

        -- 3. Key / Dungeon Unlocks
        if payoff and payoff.unlock then
            tooltip:AddLine("  |cff00ffff" .. L["PAYOFF_UNLOCKS"] .. "|r |cffffffff" .. payoff.unlock .. "|r", 1, 1, 1, true)
        end

        -- 4. Top Reward
        if payoff and payoff.reward then
            tooltip:AddLine("  |cffffd100" .. L["PAYOFF_REWARD"] .. "|r |cffffffff" .. payoff.reward .. "|r", 1, 1, 1, true)
        end

        -- 5. Quest Origin / Type
        if payoff and payoff.origin then
            tooltip:AddLine("  |cffffaa00" .. (L["PAYOFF_TYPE"] or "Type:") .. "|r |cffffffff" .. payoff.origin .. "|r", 1, 1, 1, true)
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
                tooltip:AddLine("  |cff00ccff" .. L["ITEM_STARTS_QUEST"] .. "|r |cffffffff" .. info.title .. "|r", 1, 1, 1, true)
            end
            if payoff and payoff.tip then
                tooltip:AddLine("  |cff1aff4d★ " .. (L["PAYOFF_TIP"] or "Tip:") .. "|r |cffffffff" .. payoff.tip .. "|r", 0.9, 0.9, 0.9, true)
            elseif payoff and payoff.summary then
                tooltip:AddLine("  |cffffd100" .. L["PAYOFF_REWARD"] .. "|r |cffffffff" .. payoff.summary .. "|r", 1, 1, 1, true)
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
local _softTargetIconActive = false

local function OnTooltipCleared(tooltip)
    tooltip._worthItAddedQuestID = nil
    tooltip._worthItAddedItemID = nil
    tooltip._worthItAddedObjectText = nil
    if tooltip == GameTooltip and not tooltip._worthItInObjectCheck and _softTargetIconActive and UI.UpdateSoftTargetQuestObjectIcon then
        UI.UpdateSoftTargetQuestObjectIcon(false)
    end
end

-- =========================================================================
-- Quest World Object Highlight (3D Glow, Sparkles, Soft-Target Icon & Tooltip)
-- Specifically highlights interactable Quest GameObjects (NOT mobs/items).
-- =========================================================================
local OBJECT_HIGHLIGHT_CVARS = {
    questPOI = "1",
    Outline = "2",
    OutlineEngineMode = "2",
    graphicsOutlineMode = "2",
    SoftTargetInteract = "3",
    SoftTargetIconQuest = "1",
    SoftTargetIconGameObject = "1",
    SoftTargetIconEnemy = "0",
    SoftTargetEnemy = "0",
    SoftTargetFriend = "0",
}

local OBJECT_HIGHLIGHT_FALLBACK_OFF = {
    Outline = "0",
    SoftTargetInteract = "1",
    SoftTargetIconGameObject = "0",
}

local function SafeGetCVar(name)
    if C_CVar and C_CVar.GetCVar then
        local ok, val = pcall(C_CVar.GetCVar, name)
        if ok then return val end
    end
    if GetCVar then
        local ok, val = pcall(GetCVar, name)
        if ok then return val end
    end
    return nil
end

local function SafeSetCVar(name, value)
    local strVal = tostring(value)
    local current = SafeGetCVar(name)
    if current ~= nil and tostring(current) == strVal then
        return true
    end
    if C_CVar and C_CVar.SetCVar then
        local ok = pcall(C_CVar.SetCVar, name, strVal)
        if ok then return true end
    end
    if SetCVar then
        local ok = pcall(SetCVar, name, strVal)
        if ok then return true end
    end
    return false
end

function UI.ApplyQuestObjectHighlight()
    if InCombatLockdown and InCombatLockdown() then
        addon._objectHighlightDeferred = true
        return false
    end
    addon._objectHighlightDeferred = false

    local shouldEnable = addon.db and addon.db.enabled ~= false and addon.db.highlightQuestObjects ~= false

    if shouldEnable then
        if not addon._savedObjectCVars then
            addon._savedObjectCVars = {}
            for k in pairs(OBJECT_HIGHLIGHT_CVARS) do
                addon._savedObjectCVars[k] = SafeGetCVar(k)
            end
        end
        for k, v in pairs(OBJECT_HIGHLIGHT_CVARS) do
            SafeSetCVar(k, v)
        end
        _softTargetIconActive = true
        return true
    else
        if addon._savedObjectCVars then
            for k in pairs(OBJECT_HIGHLIGHT_CVARS) do
                local orig = addon._savedObjectCVars[k]
                if orig ~= nil then
                    SafeSetCVar(k, orig)
                elseif OBJECT_HIGHLIGHT_FALLBACK_OFF[k] ~= nil then
                    SafeSetCVar(k, OBJECT_HIGHLIGHT_FALLBACK_OFF[k])
                end
            end
        else
            for k, v in pairs(OBJECT_HIGHLIGHT_FALLBACK_OFF) do
                SafeSetCVar(k, v)
            end
        end
        SafeSetCVar("SoftTargetIconGameObject", "0")
        return false
    end
end

local function StripTooltipFormatting(str)
    if type(str) ~= "string" then return "" end
    local s = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "|T.-|t", "")
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")
    return s
end

local function IsMonsterKillObjective(objType, lowerText)
    if objType == "monster" then return true end
    if string.find(lowerText, " slain", 1, true) or
       string.find(lowerText, "^kill ") or
       string.find(lowerText, "^slay ") or
       string.find(lowerText, "^defeat ") or
       string.find(lowerText, "σκοτώστε", 1, true) or
       string.find(lowerText, "νικήστε", 1, true) then
        return true
    end
    return false
end

local function IsObjectiveFinished(obj)
    if not obj then return false end
    if obj.finished == true then return true end
    local txt = obj.text
    if type(txt) == "string" then
        local cur, req = string.match(txt, "(%d+)%s*/%s*(%d+)")
        if cur and req and tonumber(cur) and tonumber(req) and tonumber(req) > 0 and tonumber(cur) >= tonumber(req) then
            return true
        end
    end
    return false
end

local OBJECTIVE_VERB_PREFIXES = {
    "interact with ",
    "open ",
    "search ",
    "use ",
    "examine ",
    "collect ",
    "gather ",
    "find ",
    "retrieve ",
    "read ",
    "place ",
    "plant ",
    "activate ",
    "click ",
    "loot ",
}

local function ExtractObjectiveObjectName(objText)
    if type(objText) ~= "string" then return "" end
    local s = StripTooltipFormatting(objText)
    -- Strip suffix counts like ": 0/1" or "(0/1)" or "0/1"
    s = string.gsub(s, "%s*%(?%s*%d+%s*/%s*%d+%s*%)?%s*$", "")
    s = string.gsub(s, "%s*%(?[Cc]omplete%)?%s*$", "")
    s = string.gsub(s, "[:%-]+%s*$", "")
    -- Strip prefix counts like "0/1 " or "0/1: "
    s = string.gsub(s, "^%d+%s*/%s*%d+[:%-]*%s*", "")
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")

    local lower = string.lower(s)
    for _, verb in ipairs(OBJECTIVE_VERB_PREFIXES) do
        if string.sub(lower, 1, #verb) == verb then
            s = string.sub(s, #verb + 1)
            s = string.gsub(s, "^%s*(.-)%s*$", "%1")
            break
        end
    end
    return s
end

local function GetQuestNonKillObjectives(questID)
    local results = {}
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        local ok, objs = pcall(C_QuestLog.GetQuestObjectives, questID)
        if ok and type(objs) == "table" and #objs > 0 then
            for _, obj in ipairs(objs) do
                if obj and obj.text and obj.text ~= "" and not IsObjectiveFinished(obj) then
                    local lower = string.lower(obj.text)
                    if not IsMonsterKillObjective(obj.type, lower) then
                        table.insert(results, obj.text)
                    end
                end
            end
            return results
        end
    end

    if GetNumQuestLeaderBoards and GetQuestLogLeaderBoard and Utils.WithSelectedQuest then
        Utils.WithSelectedQuest(questID, function()
            local numLB = GetNumQuestLeaderBoards() or 0
            for i = 1, numLB do
                local desc, objType, finished = GetQuestLogLeaderBoard(i)
                if desc and desc ~= "" and not finished then
                    local lower = string.lower(desc)
                    if not IsMonsterKillObjective(objType, lower) then
                        local cur, req = string.match(desc, "(%d+)%s*/%s*(%d+)")
                        if not (cur and req and tonumber(cur) and tonumber(req) and tonumber(req) > 0 and tonumber(cur) >= tonumber(req)) then
                            table.insert(results, desc)
                        end
                    end
                end
            end
        end)
    end
    return results
end

local function ReadTooltipLineText(tooltip, index)
    if type(tooltip) ~= "table" then return nil end
    local name = tooltip.GetName and tooltip:GetName()
    if name then
        local fs = _G[name .. "TextLeft" .. index]
        if fs and fs.GetText then
            local txt = fs:GetText()
            if txt and txt ~= "" then return txt end
        end
    end
    if tooltip.lines and tooltip.lines[index] and tooltip.lines[index].left then
        return tooltip.lines[index].left
    end
    return nil
end

local _objectTargetsCache = nil

function UI.InvalidateObjectTargetsCache()
    _objectTargetsCache = nil
end

local function GetActiveQuestObjectTargets()
    if _objectTargetsCache then
        return _objectTargetsCache
    end

    local entries = {}
    local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
        or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0

    for i = 1, numEntries do
        local qID, qTitle, isHeader
        if C_QuestLog and C_QuestLog.GetInfo then
            local ok, info = pcall(C_QuestLog.GetInfo, i)
            if ok and info then
                qID = info.questID
                qTitle = info.title
                isHeader = info.isHeader
            end
        elseif GetQuestLogTitle then
            local ok, t, _, _, isH, _, _, _, id = pcall(GetQuestLogTitle, i)
            if ok then
                qTitle = t
                isHeader = isH
                qID = id
            end
        end

        if not isHeader and Utils.IsValidQuestID(qID) then
            local nonKillObjs = GetQuestNonKillObjectives(qID)
            if #nonKillObjs > 0 then
                local cleanQTitle = Utils.CleanQuestTitle and Utils.CleanQuestTitle(qTitle or "") or (qTitle or "")
                local displayTitle = cleanQTitle ~= "" and cleanQTitle or ("Quest #" .. qID)
                local lowerQTitle = string.lower(cleanQTitle)
                local parsedObjs = {}
                for _, objText in ipairs(nonKillObjs) do
                    local targetName = ExtractObjectiveObjectName(objText)
                    table.insert(parsedObjs, {
                        cleanText = StripTooltipFormatting(objText),
                        lowerTarget = string.lower(targetName),
                    })
                end
                table.insert(entries, {
                    questID = qID,
                    displayTitle = displayTitle,
                    lowerTitle = lowerQTitle,
                    firstObjText = parsedObjs[1].cleanText,
                    objectives = parsedObjs,
                })
            end
        end
    end

    _objectTargetsCache = entries
    return entries
end

function UI.MatchWorldObjectToActiveQuest(rawObjName, extraLinesLower)
    local cleanObjName = StripTooltipFormatting(rawObjName)
    if #cleanObjName < 3 then return nil end

    local activeTargets = GetActiveQuestObjectTargets()
    if #activeTargets == 0 then return nil end

    local lowerObjName = string.lower(cleanObjName)
    local matchedQuestID, matchedQuestTitle, matchedObjText = nil, nil, nil

    for _, qEntry in ipairs(activeTargets) do
        -- Pass 1: Match GameObject title against non-kill objective target names
        for _, obj in ipairs(qEntry.objectives) do
            local lowerTarget = obj.lowerTarget
            if #lowerTarget >= 4 then
                if lowerObjName == lowerTarget or
                   (#lowerObjName >= 4 and (string.find(lowerObjName, lowerTarget, 1, true) or string.find(lowerTarget, lowerObjName, 1, true))) then
                    matchedQuestID = qEntry.questID
                    matchedQuestTitle = qEntry.displayTitle
                    matchedObjText = obj.cleanText
                    break
                end
            end
        end

        -- Pass 2: Fallback check on existing tooltip lines 2..N (e.g. modern quest object tooltips)
        if not matchedQuestID and extraLinesLower and #extraLinesLower > 0 then
            local lowerQTitle = qEntry.lowerTitle
            for _, extraLine in ipairs(extraLinesLower) do
                if lowerQTitle ~= "" and #lowerQTitle >= 4 and string.find(extraLine, lowerQTitle, 1, true) then
                    matchedQuestID = qEntry.questID
                    matchedQuestTitle = qEntry.displayTitle
                    matchedObjText = qEntry.firstObjText
                    break
                end
                for _, obj in ipairs(qEntry.objectives) do
                    local lowerTarget = obj.lowerTarget
                    if #lowerTarget >= 4 and string.find(extraLine, lowerTarget, 1, true) then
                        matchedQuestID = qEntry.questID
                        matchedQuestTitle = qEntry.displayTitle
                        matchedObjText = obj.cleanText
                        break
                    end
                end
                if matchedQuestID then break end
            end
        end

        if matchedQuestID then break end
    end

    if not matchedQuestID then return nil end
    return matchedQuestID, matchedQuestTitle, matchedObjText, cleanObjName
end

function UI.UpdateSoftTargetQuestObjectIcon(hoveredMatched)
    if InCombatLockdown and InCombatLockdown() then return false end

    if not (addon.db and addon.db.enabled ~= false and addon.db.highlightQuestObjects ~= false) then
        _softTargetIconActive = false
        SafeSetCVar("SoftTargetIconGameObject", "0")
        return false
    end

    _softTargetIconActive = true
    SafeSetCVar("SoftTargetIconGameObject", "1")
    return true
end

function UI.AddWorldObjectQuestLines(tooltip)
    if not (addon.db and addon.db.enabled and addon.db.highlightQuestObjects ~= false) then return end
    if not tooltip or type(tooltip) ~= "table" or not tooltip.NumLines then return end
    if tooltip._worthItInObjectCheck then return end
    if tooltip._worthItAddedQuestID or tooltip._worthItAddedItemID or tooltip._worthItAddedObjectText then return end

    -- Exclude 2D UI widget tooltips (buttons, map pins, frames) and units/items/spells strictly
    local owner = tooltip.GetOwner and tooltip:GetOwner()
    if owner and owner ~= UIParent and owner ~= WorldFrame then return end
    if tooltip.GetUnit and select(1, tooltip:GetUnit()) then return end
    if tooltip.GetItem and select(2, tooltip:GetItem()) then return end
    if tooltip.GetSpell and select(1, tooltip:GetSpell()) then return end

    local numLines = tooltip:NumLines() or 0
    if numLines < 1 then return end

    local rawLine1 = ReadTooltipLineText(tooltip, 1)
    local extraLinesLower = {}
    for i = 2, numLines do
        local lineTxt = StripTooltipFormatting(ReadTooltipLineText(tooltip, i))
        if lineTxt ~= "" then
            table.insert(extraLinesLower, string.lower(lineTxt))
        end
    end

    local matchedQuestID, matchedQuestTitle, matchedObjText, cleanObjName = UI.MatchWorldObjectToActiveQuest(rawLine1, extraLinesLower)
    if not matchedQuestID then
        if tooltip == GameTooltip then
            UI.UpdateSoftTargetQuestObjectIcon(false)
        end
        return false
    end

    UI.UpdateSoftTargetQuestObjectIcon(true)

    tooltip._worthItInObjectCheck = true
    tooltip._worthItAddedObjectText = cleanObjName

    local worth, b = addon.Engine and addon.Engine.CalculateWorth and addon.Engine.CalculateWorth(matchedQuestID)
    local badge = worth and Utils.FormatBadge(worth, b and b.isComplete, b and b.isHard, b and b.isBankable) or ""
    local titleDisplay = badge ~= "" and string.format("%s |cffffffff%s|r", badge, matchedQuestTitle) or ("|cffffffff" .. matchedQuestTitle .. "|r")

    tooltip:AddLine(" ")
    tooltip:AddLine("|TInterface\\GossipFrame\\VendorGossipIcon:14:14:0:0|t |cffffd100★ " .. (L["QUEST_OBJECT_HEADER"] or "QUEST OBJECT (Interact!)") .. "|r")
    tooltip:AddLine("  " .. titleDisplay, 1, 1, 1, true)
    if matchedObjText and matchedObjText ~= "" then
        tooltip:AddLine("  |cff1aff4d• " .. matchedObjText .. "|r", 0.9, 0.9, 0.9, true)
    end

    if tooltip.Show then tooltip:Show() end
    tooltip._worthItInObjectCheck = nil
    return true
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
        if Enum.TooltipDataType.Object then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Object, function(tooltip, data)
                UI.AddWorldObjectQuestLines(tooltip)
            end)
        end
        hooked = true
        addon.Debug("Hooked TooltipDataProcessor for Quest, Item, and Object tooltips.")
    end

    -- Hook GameTooltip Clear, SetText & Hide
    if GameTooltip and hooksecurefunc then
        pcall(hooksecurefunc, GameTooltip, "ClearLines", OnTooltipCleared)
        pcall(hooksecurefunc, GameTooltip, "SetText", function(self)
            UI.AddWorldObjectQuestLines(self)
        end)
    end
    if ItemRefTooltip and hooksecurefunc then
        pcall(hooksecurefunc, ItemRefTooltip, "ClearLines", OnTooltipCleared)
    end
    if GameTooltip and GameTooltip.HookScript then
        pcall(function()
            GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
            GameTooltip:HookScript("OnHide", OnTooltipCleared)
            GameTooltip:HookScript("OnShow", UI.AddWorldObjectQuestLines)
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
