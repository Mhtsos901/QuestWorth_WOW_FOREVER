--[[
    WorthIt / QuestWorth - Scores/Reward.lua
    Score 2: Reward Value (R) in [0.0, 1.0].
]]

local addonName, addon = ...
addon.Scores = addon.Scores or {}
local Scores = addon.Scores
local Utils = addon.Utils

local _xpCache = {}
local _moneyCache = {}

function Scores.InvalidateRewardCache(questID)
    if questID then
        _xpCache[questID] = nil
        _moneyCache[questID] = nil
    else
        wipe(_xpCache)
        wipe(_moneyCache)
    end
end
addon.InvalidateRewardCache = Scores.InvalidateRewardCache

-- Safe helper to fetch XP reward for a quest
local function GetQuestXP(questID)
    if not Utils.IsValidQuestID(questID) then return 0 end
    if _xpCache[questID] and _xpCache[questID] > 0 then
        return _xpCache[questID]
    end

    local xp = 0
    if C_QuestLog and C_QuestLog.GetQuestRewardXP then
        local ok, val = pcall(C_QuestLog.GetQuestRewardXP, questID)
        if ok and val and val > 0 then xp = val end
    end
    if xp == 0 and GetQuestLogRewardXP then
        local val = Utils.WithSelectedQuest(questID, function()
            return GetQuestLogRewardXP(questID)
        end)
        if val and val > 0 then xp = val end
    end

    if xp == 0 and QuestFrame and QuestFrame:IsShown() then
        local matchesOffer = false
        if GetQuestID then
            local okID, currentID = pcall(GetQuestID)
            if okID and currentID and currentID == questID then
                matchesOffer = true
            end
        end
        if not matchesOffer and GetTitleText then
            local qTitle = Utils.GetQuestTitle and Utils.GetQuestTitle(questID)
            local frameTitle = GetTitleText()
            if qTitle and frameTitle and qTitle == frameTitle then
                matchesOffer = true
            end
        end
        if matchesOffer then
            if GetRewardXP then
                local ok, val = pcall(GetRewardXP)
                if ok and val and val > 0 then xp = val end
            end
            if xp == 0 and GetQuestRewardXP then
                local ok, val = pcall(GetQuestRewardXP)
                if ok and val and val > 0 then xp = val end
            end
            if xp == 0 and QuestInfoFrame and QuestInfoFrame.rewards and QuestInfoFrame.rewards.xp then
                xp = QuestInfoFrame.rewards.xp or 0
            end
        end
    end

    if xp > 0 then
        _xpCache[questID] = xp
        return xp
    end

    -- Fallback for unaccepted quests not currently open in QuestFrame (e.g. Gossip listing):
    -- Estimate baseline standard XP based on quest level so reward score doesn't artificially crash to 0.05.
    -- DO NOT memoize in _xpCache so live XP replaces it immediately once dialog or log opens.
    local playerLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
    local qLevel = (Utils and Utils.GetQuestLevel and Utils.GetQuestLevel(questID)) or playerLevel
    local effectiveLevel = (qLevel and qLevel > 0) and qLevel or playerLevel
    local qMobXP = math.max(50, (effectiveLevel * 5) + 45)
    local isTalkTo = (Utils and Utils.IsTalkToQuest and Utils.IsTalkToQuest(questID)) or false
    local mult = isTalkTo and 3.5 or 8.5
    local delta = effectiveLevel - playerLevel
    local levelFactor = 1.0
    if delta < -5 then
        levelFactor = math.max(0.10, 1.0 + (delta + 5) * 0.20)
    end
    local estimatedXP = math.floor(qMobXP * mult * levelFactor)
    return estimatedXP
end

-- Safe helper to fetch direct Money reward for a quest
local function GetQuestMoney(questID)
    if not Utils.IsValidQuestID(questID) then return 0 end
    if _moneyCache[questID] and _moneyCache[questID] > 0 then
        return _moneyCache[questID]
    end

    local money = 0
    if C_QuestLog and C_QuestLog.GetQuestRewardMoney then
        local ok, val = pcall(C_QuestLog.GetQuestRewardMoney, questID)
        if ok and val and val > 0 then money = val end
    end
    if money == 0 and GetQuestLogRewardMoney then
        local val = Utils.WithSelectedQuest(questID, function()
            return GetQuestLogRewardMoney(questID)
        end)
        if val and val > 0 then money = val end
    end
    if money == 0 and QuestFrame and QuestFrame:IsShown() then
        local matchesOffer = false
        if GetQuestID then
            local okID, currentID = pcall(GetQuestID)
            if okID and currentID and currentID == questID then
                matchesOffer = true
            end
        end
        if not matchesOffer and GetTitleText then
            local qTitle = Utils.GetQuestTitle and Utils.GetQuestTitle(questID)
            local frameTitle = GetTitleText()
            if qTitle and frameTitle and qTitle == frameTitle then
                matchesOffer = true
            end
        end
        if matchesOffer and GetRewardMoney then
            local ok, val = pcall(GetRewardMoney)
            if ok and val and val > 0 then money = val end
        end
    end

    if money > 0 then
        _moneyCache[questID] = money
    end
    return money
end

-- Safe helper to fetch item links and calculate vendor sell values (uses addon.SafeGetItemInfo via GetQuestRewardData)
local function GetQuestVendorPrices(questID)
    if Utils and Utils.GetQuestRewardData then
        local _, _, maxChoicePrice, fixedPricesSum = Utils.GetQuestRewardData(questID)
        return (maxChoicePrice or 0) + (fixedPricesSum or 0)
    end
    -- Fallback: Uses addon.SafeGetItemInfo directly
    return 0
end

function Scores.CalculateReward(questID)
    if not Utils.IsValidQuestID(questID) then
        return 0.30, { source = "InvalidID", xp = 0, money = 0, itemCopper = 0, final = 0.30 }
    end
    local playerLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
    local maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion()) or (GetMaxPlayerLevel and GetMaxPlayerLevel()) or 60
    local isMaxLevel = (playerLevel >= maxLevel)
    local isTalkTo = (Utils and Utils.IsTalkToQuest and Utils.IsTalkToQuest(questID)) or false

    local mobXP = math.max(50, (playerLevel * 5) + 45)
    local mobMultiplier = isTalkTo and 3.5 or 8.5 -- Talk-to breadcrumbs award ~40% XP with zero combat
    local benchmarkQuestXP = mobXP * mobMultiplier

    local rewardXP = GetQuestXP(questID)
    local xpScore = 0.0

    if not isMaxLevel and benchmarkQuestXP > 0 then
        if rewardXP > 0 then
            xpScore = math.min(1.0, rewardXP / benchmarkQuestXP)

            local xpMax = UnitXPMax("player")
            if not xpMax or xpMax <= 0 then xpMax = 1 end
            local currentXP = UnitXP("player") or 0
            if currentXP < 0 then currentXP = 0 end
            local xpNeeded = math.max(1, xpMax - currentXP)
            if rewardXP >= xpNeeded then
                xpScore = math.min(1.0, xpScore + 0.05)
            end
        end
    else
        xpScore = 0.50
    end

    local directMoney = GetQuestMoney(questID)
    local vendorResell = GetQuestVendorPrices(questID)
    local totalMoney = directMoney + vendorResell

    if isMaxLevel and rewardXP > 0 then
        totalMoney = totalMoney + (rewardXP * 6)
    end

    local expectedCopper = math.max(150, (playerLevel ^ 1.80) * 25)
    local moneyRatio = totalMoney / expectedCopper
    local moneyScore = math.min(1.0, moneyRatio * 0.85)

    local finalScore
    if isMaxLevel then
        finalScore = moneyScore
    else
        -- Leveling priority: If quest offers exceptional XP, ensure lack of vendor copper doesn't suppress it
        if xpScore >= 0.85 or (benchmarkQuestXP > 0 and rewardXP >= benchmarkQuestXP) then
            finalScore = (xpScore * 0.88) + (moneyScore * 0.12)
            if benchmarkQuestXP > 0 and rewardXP > benchmarkQuestXP then
                local bonus = math.min(0.12, ((rewardXP - benchmarkQuestXP) / benchmarkQuestXP) * 0.20)
                finalScore = math.min(1.0, finalScore + bonus)
            end
        else
            finalScore = (xpScore * 0.75) + (moneyScore * 0.25)
        end
    end

    finalScore = math.max(0.05, math.min(1.0, finalScore))

    local reason = nil
    if finalScore < 0.30 then
        reason = "Low XP"
    elseif isTalkTo and finalScore >= 0.70 then
        reason = "Talk-To"
    elseif finalScore >= 0.85 then
        reason = "High XP"
    elseif totalMoney >= (expectedCopper * 1.5) then
        reason = "Good Gold"
    end

    local details = {
        rewardXP = rewardXP,
        xpScore = xpScore,
        moneyScore = moneyScore,
        totalMoney = totalMoney,
        vendorResell = vendorResell,
        isMaxLevel = isMaxLevel,
        isTalkTo = isTalkTo,
        final = finalScore,
        reason = reason,
    }

    if addon.db and addon.db.debug then
        addon.Debug("Reward [Q:%d]: XP=%d (Score=%.2f) TotalGold=%d (Vendor=%d, Score=%.2f) -> Final=%.2f",
            questID, rewardXP, xpScore, totalMoney, vendorResell, moneyScore, finalScore)
    end

    return finalScore, details
end
