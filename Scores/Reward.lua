--[[
    WorthIt / QuestWorth - Scores/Reward.lua
    Score 2: Reward Value (R) in [0.0, 1.0].
]]

local addonName, addon = ...
addon.Scores = addon.Scores or {}
local Scores = addon.Scores
local Utils = addon.Utils

-- Safe helper to fetch XP reward for a quest
local function GetQuestXP(questID)
    if C_QuestLog and C_QuestLog.GetQuestRewardXP then
        local ok, xp = pcall(C_QuestLog.GetQuestRewardXP, questID)
        if ok and xp and xp > 0 then return xp end
    end
    if GetQuestLogRewardXP then
        local xp = Utils.WithSelectedQuest(questID, function()
            return GetQuestLogRewardXP(questID)
        end)
        if xp and xp > 0 then return xp end
    end

    if GetQuestID then
        local okID, currentID = pcall(GetQuestID)
        if okID and currentID and currentID == questID then
            if GetQuestRewardXP then
                local ok, xp = pcall(GetQuestRewardXP)
                if ok and xp and xp > 0 then return xp end
            end
            if QuestInfoFrame and QuestInfoFrame.rewards and QuestInfoFrame.rewards.xp then
                return QuestInfoFrame.rewards.xp
            end
        end
    end

    return 0
end

-- Safe helper to fetch direct Money reward for a quest
local function GetQuestMoney(questID)
    if C_QuestLog and C_QuestLog.GetQuestRewardMoney then
        local ok, money = pcall(C_QuestLog.GetQuestRewardMoney, questID)
        if ok and money and money > 0 then return money end
    end
    if GetQuestLogRewardMoney then
        local money = Utils.WithSelectedQuest(questID, function()
            return GetQuestLogRewardMoney(questID)
        end)
        if money and money > 0 then return money end
    end
    if QuestFrame and QuestFrame:IsShown() and GetQuestID and GetQuestID() == questID and GetRewardMoney then
        local ok, money = pcall(GetRewardMoney)
        if ok and money and money > 0 then return money end
    end
    return 0
end

-- Safe helper to fetch item links and calculate vendor sell values
local function GetQuestVendorPrices(questID)
    local maxChoicePrice = 0
    local fixedPricesSum = 0

    Utils.WithSelectedQuest(questID, function()
        -- 1. Choice Rewards
        local numChoices = (C_QuestLog and C_QuestLog.GetNumQuestLogChoices and C_QuestLog.GetNumQuestLogChoices(questID)) or (GetNumQuestLogChoices and GetNumQuestLogChoices(questID)) or 0
        for i = 1, numChoices do
            local link = (GetQuestLogItemLink and GetQuestLogItemLink("choice", i, questID)) or
                         (C_QuestLog and C_QuestLog.GetQuestRewardItemLink and C_QuestLog.GetQuestRewardItemLink(i, questID))
            if not link and C_QuestLog and C_QuestLog.GetQuestLogRewardInfo then
                local ok, info = pcall(C_QuestLog.GetQuestLogRewardInfo, i, questID)
                if ok and info and info.itemID then
                    link = select(2, addon.SafeGetItemInfo(info.itemID))
                end
            end

            if link then
                local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
                if sellPrice > maxChoicePrice then
                    maxChoicePrice = sellPrice
                end
            end
        end

        -- 2. Fixed Rewards
        local numRewards = (C_QuestLog and C_QuestLog.GetNumQuestLogRewards and C_QuestLog.GetNumQuestLogRewards(questID)) or (GetNumQuestLogRewards and GetNumQuestLogRewards(questID)) or 0
        for i = 1, numRewards do
            local link = (GetQuestLogItemLink and GetQuestLogItemLink("reward", i, questID))
            if link then
                local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
                fixedPricesSum = fixedPricesSum + sellPrice
            end
        end
    end)

    -- 3. Fallback for unaccepted quest currently in QuestFrame
    if maxChoicePrice == 0 and fixedPricesSum == 0 and QuestFrame and QuestFrame:IsShown() and GetQuestID and GetQuestID() == questID then
        local numOfferChoices = (GetNumQuestChoices and GetNumQuestChoices()) or 0
        for i = 1, numOfferChoices do
            local link = GetQuestItemLink and GetQuestItemLink("choice", i)
            if link then
                local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
                if sellPrice > maxChoicePrice then
                    maxChoicePrice = sellPrice
                end
            end
        end

        local numOfferRewards = (GetNumQuestRewards and GetNumQuestRewards()) or 0
        for i = 1, numOfferRewards do
            local link = GetQuestItemLink and GetQuestItemLink("reward", i)
            if link then
                local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
                fixedPricesSum = fixedPricesSum + sellPrice
            end
        end
    end

    return maxChoicePrice + fixedPricesSum
end

function Scores.CalculateReward(questID)
    local playerLevel = UnitLevel("player") or 1
    local maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion()) or (GetMaxPlayerLevel and GetMaxPlayerLevel()) or 60
    local isMaxLevel = (playerLevel >= maxLevel)

    local mobXP = math.max(50, (playerLevel * 5) + 45)
    local mobMultiplier = 8.5 -- Documented 8-9 mob baseline (mobXP * 8.5)
    local benchmarkQuestXP = mobXP * mobMultiplier

    local rewardXP = GetQuestXP(questID)
    local xpScore = 0.0

    if not isMaxLevel and benchmarkQuestXP > 0 then
        if rewardXP > 0 then
            xpScore = math.min(1.0, rewardXP / benchmarkQuestXP)

            local xpMax = UnitXPMax("player") or 1
            local currentXP = UnitXP("player") or 0
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
        finalScore = (xpScore * 0.75) + (moneyScore * 0.25)
    end

    finalScore = math.max(0.05, math.min(1.0, finalScore))

    local reason = nil
    if finalScore < 0.30 then
        reason = "Low XP"
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
        final = finalScore,
        reason = reason,
    }

    if addon.db and addon.db.debug then
        addon.Debug("Reward [Q:%d]: XP=%d (Score=%.2f) TotalGold=%d (Vendor=%d, Score=%.2f) -> Final=%.2f",
            questID, rewardXP, xpScore, totalMoney, vendorResell, moneyScore, finalScore)
    end

    return finalScore, details
end
