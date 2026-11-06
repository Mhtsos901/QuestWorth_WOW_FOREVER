--[[
    WorthIt / QuestWorth - Core/Engine.lua
    Central evaluation engine: calculates weighted Worth meter across 5 criteria:
      1. Difficulty (D)
      2. Reward Value (R)
      3. Quest Chain (C)
      4. Class Fit (F)
      5. Hub Density & Clustering (H)
]]

local addonName, addon = ...
addon.Engine = {}
local Engine = addon.Engine
local Utils = addon.Utils
local L = addon.L

-- In-memory cache for computed scores
Engine.Cache = {}
local MAX_CACHE_SIZE = 500

-- Hoisted: created ONCE at load, not per-call
local function _approxEq(a, b)
    return math.abs((tonumber(a) or 0) - (tonumber(b) or 0)) < 0.001
end

-- Helper to get player's current spec identifier safely (cached per session)
local _cachedSpecID = nil

local function GetPlayerSpecID()
    if _cachedSpecID then return _cachedSpecID end

    if GetSpecialization and GetSpecializationInfo then
        local ok, specIndex = pcall(GetSpecialization)
        if ok and specIndex and specIndex > 0 then
            local ok2, specID = pcall(GetSpecializationInfo, specIndex)
            if ok2 and specID then
                _cachedSpecID = specID
                return specID
            end
        end
    end

    if GetNumTalentTabs and GetTalentTabInfo then
        local bestTab, maxPoints = nil, 0
        local numTabs = GetNumTalentTabs() or 0
        for i = 1, numTabs do
            local _, _, pointsSpent = GetTalentTabInfo(i)
            if pointsSpent and pointsSpent > maxPoints then
                maxPoints = pointsSpent
                bestTab = i
            end
        end
        if bestTab then
            _cachedSpecID = "talentTab:" .. bestTab
            return _cachedSpecID
        end
    end

    _cachedSpecID = "defaultSpec"
    return _cachedSpecID
end

function Engine.InvalidateSpecCache()
    _cachedSpecID = nil
end

-- Generate a unique cache key based on player state & active quest count
local function GetCacheKey(questID)
    local playerLevel = UnitLevel("player") or 1
    local specID = GetPlayerSpecID()
    local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                       or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
    return string.format("%d:%d:%s:%d", questID, playerLevel, tostring(specID), numEntries)
end

-- Invalidate calculation cache
function Engine.InvalidateCache()
    wipe(Engine.Cache)
    addon.Debug("Evaluation cache invalidated.")
end

-- Main entry point: Calculate Worth for a questID
function Engine.CalculateWorth(questID)
    if not questID or questID <= 0 then
        return nil, nil
    end

    local db = addon.db
    if db and not db.enabled then
        return nil, nil
    end

    -- Rule: If quest is already completed / ready for turn-in, its worth is 100%!
    local isComplete = false
    if C_QuestLog and C_QuestLog.IsComplete then
        local ok, comp = pcall(C_QuestLog.IsComplete, questID)
        if ok and comp then isComplete = true end
    end
    if not isComplete and C_QuestLog and C_QuestLog.ReadyForTurnIn then
        local ok, ready = pcall(C_QuestLog.ReadyForTurnIn, questID)
        if ok and ready then isComplete = true end
    end
    if not isComplete and C_QuestLog and C_QuestLog.GetLogIndexForQuestID and C_QuestLog.GetInfo then
        local ok, idx = pcall(C_QuestLog.GetLogIndexForQuestID, questID)
        if ok and idx and idx > 0 then
            local ok2, info = pcall(C_QuestLog.GetInfo, idx)
            if ok2 and info and (info.isComplete == true or info.isComplete == 1 or info.readyForTurnIn) then
                isComplete = true
            end
        end
    end
    if not isComplete and GetQuestLogTitle and C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local ok, idx = pcall(C_QuestLog.GetLogIndexForQuestID, questID)
        if ok and idx and idx > 0 then
            local ok3, _, _, _, _, _, comp = pcall(GetQuestLogTitle, idx)
            if ok3 and comp and comp == 1 then
                isComplete = true
            end
        end
    end

    if isComplete then
        local weights = (db and db.weights) or {}
        local wD, wR, wC, wF, wH = Utils.NormalizeWeights(weights.difficulty, weights.reward, weights.chain, weights.classFit, weights.density)
        return 1.00, {
            worth = 1.00,
            d = 1.00,
            r = 1.00,
            c = 1.00,
            f = 1.00,
            h = 1.00,
            wD = wD,
            wR = wR,
            wC = wC,
            wF = wF,
            wH = wH,
            isComplete = true,
            isHard = false,
            details = { note = "Ready for turn-in!" }
        }
    end

    local cacheKey = GetCacheKey(questID)
    if Engine.Cache[cacheKey] then
        local entry = Engine.Cache[cacheKey]
        return entry.worth, entry.breakdown
    end

    -- 1. Normalize 5 Weights (Endgame adapts to Gold & Economy priority)
    local playerLevel = UnitLevel("player") or 1
    local maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion()) or (GetMaxPlayerLevel and GetMaxPlayerLevel()) or 60
    local isMaxLevel = (playerLevel >= maxLevel)
    local weights = (db and db.weights) or {}

    local rawD = weights.difficulty
    local rawR = weights.reward
    local rawC = weights.chain
    local rawF = weights.classFit
    local rawH = weights.density

    -- If player is max level and using default weights, adapt to endgame weights
    if isMaxLevel
        and _approxEq(rawD, 0.00) and _approxEq(rawR, 0.40)
        and _approxEq(rawC, 0.15) and _approxEq(rawF, 0.30)
        and _approxEq(rawH, 0.15) then
        rawD, rawR, rawC, rawF, rawH = 0.00, 0.50, 0.15, 0.25, 0.10
    end

    local wD, wR, wC, wF, wH = Utils.NormalizeWeights(rawD, rawR, rawC, rawF, rawH)

    -- 2. Individual Scores (Safe pcall wrapped)
    local dScore, dDetails = 0.50, {}
    local okD, resD, detailsD = pcall(addon.Scores.CalculateDifficulty, questID)
    if okD and resD then dScore, dDetails = resD, detailsD end

    local rScore, rDetails = 0.50, {}
    local okR, resR, detailsR = pcall(addon.Scores.CalculateReward, questID)
    if okR and resR then rScore, rDetails = resR, detailsR end

    local cScore, cDetails = 0.10, { source = "ErrorFallback", final = 0.10 }
    local okC, resC, detailsC = pcall(addon.Scores.CalculateChain, questID)
    if okC and resC then cScore, cDetails = resC, detailsC end

    local fScore, fDetails = 0.50, {}
    local okF, resF, detailsF = pcall(addon.Scores.CalculateClassFit, questID)
    if okF and resF then fScore, fDetails = resF, detailsF end

    local hScore, hDetails = 0.50, {}
    if addon.Scores.CalculateDensity then
        local okH, resH, detailsH = pcall(addon.Scores.CalculateDensity, questID)
        if okH and resH then hScore, hDetails = resH, detailsH end
    end

    -- Clamp individual scores to [0.0, 1.0]
    dScore = math.max(0.0, math.min(1.0, tonumber(dScore) or 0.5))
    rScore = math.max(0.0, math.min(1.0, tonumber(rScore) or 0.5))
    cScore = math.max(0.0, math.min(1.0, tonumber(cScore) or 0.10))
    fScore = math.max(0.0, math.min(1.0, tonumber(fScore) or 0.5))
    hScore = math.max(0.0, math.min(1.0, tonumber(hScore) or 0.5))

    -- 3. Dynamic Weight Redistribution when ClassFit is unavailable or has no items
    -- Trigger for BOTH "no items" AND "calculation error" cases.
    if (okF == false) or (fDetails and fDetails.hasItems == false) then
        wD, wR, wC, wF, wH = Utils.NormalizeWeights(rawD, rawR, rawC, 0, rawH)
    end

    -- 4. 5-Factor Weighted Average
    local totalWorth = (dScore * wD) + (rScore * wR) + (cScore * wC) + (fScore * wF) + (hScore * wH)

    -- Detect High Future Value ("Bank / Save for Later" quests)
    local hasGearUpgrade = (fScore >= 0.75) or (fDetails and fDetails.reason == "Gear Upgrade")
    local isChainStarter = (cDetails and cDetails.step == 1 and (cDetails.totalSteps or 0) > 1)
    local isHighReward = (rScore >= 0.80) or (rDetails and rDetails.reason == "High XP")
    local isHighValue = (hasGearUpgrade or isChainStarter or isHighReward)

    -- Viability Damping: Red quests or trivial Gray quests shouldn't inflate to 80%+ from rewards/hub alone
    local color = dDetails and dDetails.colorName
    local isBankable = false
    local isHard = (color == "red" or color == "orange" or (dDetails and (dDetails.isElite or dDetails.isDungeon == true)))

    if wD > 0 then
        -- Difficulty weight is enabled: apply full viability damping to difficult quests
        if color == "red" then
            if isHighValue then
                -- High-value red quest (great gear, chain start, or big XP): allow player to bank it (50% - 60%)
                totalWorth = math.max(0.55, totalWorth * 0.75)
                isBankable = true
            else
                totalWorth = totalWorth * 0.40 -- Generic red quest: cap so player waits to level up first
            end
        elseif color == "orange" then
            if isHighValue then
                totalWorth = math.max(0.60, totalWorth * 0.85)
                isBankable = true
            end
        elseif color == "gray" and not (cDetails and cDetails.isClassOrProfession) and fScore < 0.80 then
            totalWorth = totalWorth * 0.30 -- Gray quest with no major gear/bag upgrade or class skill
        elseif dScore <= 0.10 then
            if isHighValue then
                totalWorth = math.max(0.45, totalWorth * 0.70)
                isBankable = true
            else
                totalWorth = totalWorth * 0.50 -- Unsoloable high-level Elite/Dungeon penalty
            end
        end
    else
        -- Difficulty weight is 0 (Decoupled Danger Skull Mode):
        -- Quests are not penalized in worth % for level delta, but marked as Hard with Skull icon
        if isHard then
            isBankable = true
        end
        if color == "gray" and not (cDetails and cDetails.isClassOrProfession) and fScore < 0.80 then
            totalWorth = totalWorth * 0.30 -- Gray quest with no major gear/bag upgrade or class skill
        end
    end

    -- Chain Start Floor:
    -- If quest is the start of a chain (step 1 of >1) and not red, floor at 0.35 to save player from skipping and backtracking
    if cDetails and cDetails.step == 1 and (cDetails.totalSteps or 0) > 1 and color ~= "red" then
        totalWorth = math.max(totalWorth, 0.35)
    end

    totalWorth = math.max(0.0, math.min(1.0, totalWorth))

    local breakdown = {
        worth = totalWorth,
        d = dScore,
        r = rScore,
        c = cScore,
        f = fScore,
        h = hScore,
        wD = wD,
        wR = wR,
        wC = wC,
        wF = wF,
        wH = wH,
        isComplete = false,
        isBankable = isBankable,
        isHard = isHard,
        details = {
            difficulty = dDetails,
            reward = rDetails,
            chain = cDetails,
            classFit = fDetails,
            density = hDetails,
        }
    }

    -- Cache result (only if not waiting on pending item data from server)
    local isPendingItem = fDetails and fDetails.isPending
    if not isPendingItem then
        -- Evict cache if it grows too large
        local count = 0
        for _ in pairs(Engine.Cache) do count = count + 1; if count >= MAX_CACHE_SIZE then break end end
        if count >= MAX_CACHE_SIZE then wipe(Engine.Cache) end

        Engine.Cache[cacheKey] = {
            worth = totalWorth,
            breakdown = breakdown,
        }
    end

    return totalWorth, breakdown
end

-- Calculate composite Worth for an entire geographical zone
function Engine.CalculateZoneWorth(zoneName)
    if not zoneName or zoneName == "" then return nil end
    if addon.Scores and addon.Scores.IsNonZoneHeader and addon.Scores.IsNonZoneHeader(zoneName) then
        return nil
    end

    local quests = addon.Scores and addon.Scores.GetQuestsForZone and addon.Scores.GetQuestsForZone(zoneName)
    if not quests or #quests == 0 then
        return nil
    end

    local sumWorth = 0
    local maxWorth = 0
    local count = 0

    for _, qID in ipairs(quests) do
        local w = Engine.CalculateWorth(qID)
        if w then
            sumWorth = sumWorth + w
            if w > maxWorth then
                maxWorth = w
            end
            count = count + 1
        end
    end

    if count == 0 then return nil end

    local avgWorth = sumWorth / count
    local zoneWorth = (0.60 * avgWorth) + (0.40 * maxWorth)
    zoneWorth = math.max(0.0, math.min(1.0, zoneWorth))

    return zoneWorth, count
end

-- Format and print full debug breakdown for a quest
function Engine.PrintBreakdown(questID)
    local info = Utils.GetQuestBasicInfo(questID)
    if not info then
        addon.Print(L["NO_QUEST_HOVERED"])
        return
    end

    local worth, b = Engine.CalculateWorth(questID)
    if not worth or not b then
        addon.Print("Could not calculate Worth for quest %d.", questID)
        return
    end

    local scoreColorHex = Utils.GetScoreColorHex(worth)
    local skullPrefix = b.isHard and "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:12:12:0:0|t " or ""
    DEFAULT_CHAT_FRAME:AddMessage(string.format(L["DEBUG_BREAKDOWN_HEADER"], questID, info.title))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  |cffffff00Total Worth:|r %s|cff%s%.1f%%|r (Weights: D=%.0f%% R=%.0f%% C=%.0f%% F=%.0f%% H=%.0f%%)",
        skullPrefix, scoreColorHex, worth * 100, b.wD * 100, b.wR * 100, b.wC * 100, b.wF * 100, b.wH * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (D): %s |cff888888(Weight: %.0f%%)|r",
        L["DIFFICULTY"], Utils.FormatScore(b.d), b.wD * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (R): %s |cff888888(Weight: %.0f%%)|r",
        L["REWARD"], Utils.FormatScore(b.r), b.wR * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (C): %s |cff888888(Weight: %.0f%%)|r",
        L["CHAIN"], Utils.FormatScore(b.c), b.wC * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (F): %s |cff888888(Weight: %.0f%%)|r",
        L["CLASS_FIT"], Utils.FormatScore(b.f), b.wF * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (H): %s |cff888888(Weight: %.0f%%)|r",
        L["DENSITY"] or "Hub Density", Utils.FormatScore(b.h), b.wH * 100))
    DEFAULT_CHAT_FRAME:AddMessage(L["DEBUG_BREAKDOWN_FOOTER"])
end

-- Diagnostic Unit-Test Simulator
function Engine.RunDiagnostics()
    local db = addon.db
    local weights = (db and db.weights) or {}
    local wD, wR, wC, wF, wH = Utils.NormalizeWeights(weights.difficulty, weights.reward, weights.chain, weights.classFit, weights.density)

    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff=== WorthIt Diagnostics & 5-Factor Score Tests ===|r")
    DEFAULT_CHAT_FRAME:AddMessage(string.format("Weights in use: D=%.2f, R=%.2f, C=%.2f, F=%.2f, H=%.2f", wD, wR, wC, wF, wH))

    local testCases = {
        { name = "Ideal Quest (Yellow, MobXP*8.5, Cap of Chain, BiS Upgrade, Dense Hub)", d = 1.00, r = 1.00, c = 1.00, f = 1.00, h = 1.00 },
        { name = "Normal Hub Quest (Yellow, Avg XP/Gold, Step 3/5, Neutral Fit, 3 Quests)", d = 1.00, r = 0.65, c = 0.70, f = 0.50, h = 0.85 },
        { name = "Isolated Long Quest (High XP, Step 1/10 Chain, Bad Weapon, 1 Quest)", d = 0.70, r = 0.80, c = 0.45, f = 0.10, h = 0.35 },
        { name = "Trivial Quest (Gray, Low XP, Standalone, No Item, 1 Quest)", d = 0.00, r = 0.15, c = 0.10, f = 0.10, h = 0.35 },
    }

    for idx, tc in ipairs(testCases) do
        local score = (tc.d * wD) + (tc.r * wR) + (tc.c * wC) + (tc.f * wF) + (tc.h * wH)
        DEFAULT_CHAT_FRAME:AddMessage(string.format("Test #%d [%s]:", idx, tc.name))
        DEFAULT_CHAT_FRAME:AddMessage(string.format("   D=%s R=%s C=%s F=%s H=%s ==> |cffffff00Result: %s|r",
            Utils.FormatScore(tc.d), Utils.FormatScore(tc.r), Utils.FormatScore(tc.c), Utils.FormatScore(tc.f), Utils.FormatScore(tc.h), Utils.FormatScore(score)))
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff=======================================================|r")
end
