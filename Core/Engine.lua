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

-- Reference dynamic Player Profile Manager (initialized in Core/Utils.lua)
addon.Player = addon.Player or {}
local Player = addon.Player
Player.Update()

-- In-memory cache for computed scores & completions
Engine.Cache = {}
Engine.CacheSize = 0
Engine.CompletionCache = {}
Engine._completionScanned = false
Engine.WorldMapZoneCache = {}
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

-- Invalidate calculation cache (single questID or full wipe)
function Engine.InvalidateCache(questID)
    if questID then
        Engine.Cache[questID] = nil
        Engine.CompletionCache[questID] = nil
        wipe(Engine.WorldMapZoneCache)
        if addon.Scores and addon.Scores.InvalidateRewardCache then
            addon.Scores.InvalidateRewardCache(questID)
        end
        if addon.Utils and addon.Utils.ClearTalkToCache then
            addon.Utils.ClearTalkToCache(questID)
        end
        if addon.Utils and addon.Utils.ClearQuestBasicInfoCache then
            addon.Utils.ClearQuestBasicInfoCache(questID)
        end
        if addon.Data and addon.Data.InvalidatePayoffMemo then
            addon.Data.InvalidatePayoffMemo(questID)
        end
        return
    end

    wipe(Engine.Cache)
    Engine.CacheSize = 0
    wipe(Engine.CompletionCache)
    Engine._completionScanned = false
    wipe(Engine.WorldMapZoneCache)
    if addon.Scores and addon.Scores.InvalidateRewardCache then
        addon.Scores.InvalidateRewardCache()
    end
    if addon.Utils and addon.Utils.ClearTalkToCache then
        addon.Utils.ClearTalkToCache()
    end
    if addon.Utils and addon.Utils.ClearQuestBasicInfoCache then
        addon.Utils.ClearQuestBasicInfoCache()
    end
    if addon.Data and addon.Data.InvalidatePayoffMemo then
        addon.Data.InvalidatePayoffMemo()
    end
    addon.Debug("Evaluation cache invalidated.")
end

-- Single-pass scanner: scans the player's active quest log once per cache generation
local function ScanActiveQuestCompletion()
    if Engine._completionScanned then return end
    Engine._completionScanned = true

    -- 1. Modern API scan
    if C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo then
        local ok, num = pcall(C_QuestLog.GetNumQuestLogEntries)
        if ok and num and num > 0 then
            for idx = 1, num do
                local okInfo, info = pcall(C_QuestLog.GetInfo, idx)
                if okInfo and info and info.questID and not info.isHeader then
                    local qID = info.questID
                    local comp = (info.isComplete == true or info.isComplete == 1 or info.readyForTurnIn == true)
                    if not comp and C_QuestLog.IsComplete then
                        local okC, isC = pcall(C_QuestLog.IsComplete, qID)
                        if okC and isC then comp = true end
                    end
                    if not comp and C_QuestLog.ReadyForTurnIn then
                        local okR, isR = pcall(C_QuestLog.ReadyForTurnIn, qID)
                        if okR and isR then comp = true end
                    end
                    if not comp and C_QuestLog.GetQuestObjectives then
                        local okObj, objectives = pcall(C_QuestLog.GetQuestObjectives, qID)
                        if okObj and type(objectives) == "table" and #objectives > 0 then
                            local allFinished = true
                            for _, obj in ipairs(objectives) do
                                if not obj.finished then
                                    allFinished = false
                                    break
                                end
                            end
                            if allFinished then comp = true end
                        end
                    end
                    Engine.CompletionCache[qID] = comp
                end
            end
            return
        end
    end

    -- 2. Classic Fallback scan
    if GetNumQuestLogEntries and GetQuestLogTitle then
        local ok, num = pcall(GetNumQuestLogEntries)
        if ok and num and num > 0 then
            for idx = 1, num do
                local okTitle, title, _, _, isHeader, _, isCompleteVal, _, qID = pcall(GetQuestLogTitle, idx)
                if okTitle and not isHeader then
                    if (not qID or qID == 0) and C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
                        qID = C_QuestLog.GetQuestIDForLogIndex(idx)
                    end
                    if qID and qID > 0 then
                        local comp = (isCompleteVal == 1 or isCompleteVal == true)
                        if not comp and GetNumQuestLeaderBoards and GetQuestLogLeaderBoard then
                            local okNum, numLB = pcall(GetNumQuestLeaderBoards, idx)
                            if okNum and numLB and numLB > 0 then
                                local allLBFinished = true
                                for lbIdx = 1, numLB do
                                    local okLB, _, _, finished = pcall(GetQuestLogLeaderBoard, lbIdx, idx)
                                    if not (okLB and finished) then
                                        allLBFinished = false
                                        break
                                    end
                                end
                                if allLBFinished then comp = true end
                            end
                        end
                        Engine.CompletionCache[qID] = comp
                    end
                end
            end
        end
    end
end

-- Helper to determine if a quest is complete / ready for turn-in (ultra-fast cached lookup)
function Engine.IsQuestComplete(questID)
    if not Utils.IsValidQuestID(questID) then return false end

    -- Fast path: already known in current cache generation
    if Engine.CompletionCache[questID] ~= nil then
        return Engine.CompletionCache[questID]
    end

    -- Populate cache for all active quests in one single pass
    if not Engine._completionScanned then
        ScanActiveQuestCompletion()
        if Engine.CompletionCache[questID] ~= nil then
            return Engine.CompletionCache[questID]
        end
    end

    -- If quest is not in the active log (e.g. queried from DB or another zone):
    local isComp = false
    if C_QuestLog and C_QuestLog.IsComplete then
        local ok, comp = pcall(C_QuestLog.IsComplete, questID)
        if ok and comp then isComp = true end
    end
    if not isComp and C_QuestLog and C_QuestLog.ReadyForTurnIn then
        local ok, ready = pcall(C_QuestLog.ReadyForTurnIn, questID)
        if ok and ready then isComp = true end
    end

    Engine.CompletionCache[questID] = isComp
    return isComp
end

-- Main entry point: Calculate Worth for a questID
function Engine.CalculateWorth(questID)
    if not Utils.IsValidQuestID(questID) then
        return nil, nil
    end

    local db = addon.db
    if db and not db.enabled then
        return nil, nil
    end

    -- Fast path: Check Cache first (zero-allocation numeric key lookup!)
    local cached = Engine.Cache[questID]
    if cached then
        return cached.worth, cached.breakdown
    end

    -- Rule: If quest is already completed / ready for turn-in, its worth is 100%!
    local isComplete = Engine.IsQuestComplete(questID)
    if isComplete then
        local weights = (db and db.weights) or {}
        local wD, wR, wC, wF, wH = Utils.NormalizeWeights(weights.difficulty, weights.reward, weights.chain, weights.classFit, weights.density)
        local completeBreakdown = {
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
        if Engine.CacheSize >= MAX_CACHE_SIZE then
            wipe(Engine.Cache)
            Engine.CacheSize = 0
        end
        Engine.Cache[questID] = {
            worth = 1.00,
            breakdown = completeBreakdown,
        }
        Engine.CacheSize = Engine.CacheSize + 1
        return 1.00, completeBreakdown
    end

    -- 1. Normalize 5 Weights (Endgame adapts to Gold & Economy priority)
    local playerLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
    local maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion()) or (GetMaxPlayerLevel and GetMaxPlayerLevel()) or 60
    local isMaxLevel = (playerLevel >= maxLevel)
    local weights = (db and db.weights) or {}

    local rawD = weights.difficulty or 0.00
    local rawR = weights.reward or 0.40
    local rawC = weights.chain or 0.25
    local rawF = weights.classFit or 0.25
    local rawH = weights.density or 0.10

    -- Modernize legacy default weights during leveling
    if not isMaxLevel and (
        (_approxEq(rawD, 0.00) and _approxEq(rawR, 0.40) and _approxEq(rawC, 0.30)) or
        (_approxEq(rawD, 0.10) and _approxEq(rawR, 0.35) and _approxEq(rawC, 0.25)) or
        (_approxEq(rawD, 0.05) and _approxEq(rawR, 0.40) and _approxEq(rawC, 0.20))
    ) then
        rawD, rawR, rawC, rawF, rawH = 0.00, 0.40, 0.25, 0.25, 0.10
    end

    -- If player is max level and using default weights, adapt to endgame weights
    if isMaxLevel
        and _approxEq(rawD, 0.00) and _approxEq(rawR, 0.40)
        and _approxEq(rawC, 0.25) and _approxEq(rawF, 0.25)
        and _approxEq(rawH, 0.10) then
        rawD, rawR, rawC, rawF, rawH = 0.00, 0.45, 0.25, 0.20, 0.10
    end

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

    -- 3. Dynamic Weight Redistribution
    local isMajorChain = (cDetails and (cDetails.isClassOrProfession or cDetails.isCap or (cDetails.totalSteps and cDetails.totalSteps >= 3) or (cScore and cScore >= 0.60)))
    local hasNoGear = (okF == false) or (fDetails and fDetails.hasItems == false)
    local isZeroDiff = (rawD <= 0.001)

    local wD, wR, wC, wF, wH
    if hasNoGear and not isMajorChain then
        -- Standalone / XP / Hub quests without gear rewards:
        -- Shift unused ClassFit and excess Chain weight into Reward and Density (and Difficulty if user active)
        local effC = math.min(rawC, 0.06)
        local released = rawF + (rawC - effC)
        local effD = isZeroDiff and 0.00 or (rawD + (released * 0.45))
        local effH = rawH + (released * (isZeroDiff and 0.45 or 0.35))
        local effR = rawR + (released * (isZeroDiff and 0.55 or 0.20))
        local effF = 0.00
        wD, wR, wC, wF, wH = Utils.NormalizeWeights(effD, effR, effC, effF, effH)
    elseif hasNoGear and isMajorChain then
        -- Major chain quest offering no gear rewards (XP/story starter):
        local released = rawF
        local effD = isZeroDiff and 0.00 or (rawD + (released * 0.30))
        local effH = rawH + (released * (isZeroDiff and 0.40 or 0.30))
        local effR = rawR + (released * (isZeroDiff and 0.60 or 0.40))
        wD, wR, wC, wF, wH = Utils.NormalizeWeights(effD, effR, rawC, 0.00, effH)
    elseif not hasNoGear and not isMajorChain and cScore <= 0.20 then
        -- Standalone quest with gear: shift excess Chain weight to ClassFit (gear upgrade) & Reward (or Difficulty if user active)
        local effC = math.min(rawC, 0.05)
        local released = rawC - effC
        local effF = rawF + (released * 0.65)
        local effD = isZeroDiff and 0.00 or (rawD + (released * 0.35))
        local effR = isZeroDiff and (rawR + (released * 0.35)) or rawR
        wD, wR, wC, wF, wH = Utils.NormalizeWeights(effD, effR, effC, effF, rawH)
    else
        wD, wR, wC, wF, wH = Utils.NormalizeWeights(rawD, rawR, rawC, rawF, rawH)
    end

    -- 4. 5-Factor Weighted Average
    local totalWorth = (dScore * wD) + (rScore * wR) + (cScore * wC) + (fScore * wF) + (hScore * wH)

    -- Detect High Future Value ("Bank / Save for Later" quests)
    local hasGearUpgrade = (fScore >= 0.75) or (fDetails and fDetails.reason == "Gear Upgrade")
    local isChainStarter = (cDetails and cDetails.step == 1 and (cDetails.totalSteps or 0) > 1)
    local isHighReward = (rScore >= 0.75) or (rDetails and rDetails.reason == "High XP")
    local isMilestone = (cDetails and (cDetails.isMilestone or cDetails.isClassOrProfession or cDetails.isCap)) or false
    local isHighValue = (hasGearUpgrade or isChainStarter or isHighReward or isMilestone)

    local isTalkTo = (dDetails and dDetails.isTalkTo) or (Utils and Utils.IsTalkToQuest and Utils.IsTalkToQuest(questID)) or false

    local color = dDetails and dDetails.colorName
    local delta = (dDetails and dDetails.levelDelta) or 0
    local isBankable = false
    local isHard = not isTalkTo and (color == "red" or color == "orange" or delta >= 3 or (dDetails and (dDetails.isElite or dDetails.isDungeon == true)))

    -- Gear Upgrade Boost (ensure genuine upgrades reach the 82% - 95% bracket)
    if hasGearUpgrade and fScore >= 0.80 and not (color == "red" or color == "orange" or delta >= 3) then
        totalWorth = math.max(totalWorth, 0.78 + (fScore - 0.75) * 0.60)
    end

    -- Milestone / Prequest / Attunement / Major Reward Boost:
    -- Ensures prequests for Dungeons, Raids, Key Unlocks, Class Quests, and Major Chain Rewards reach 90%+
    if isMilestone and (isTalkTo or not isHard) and color ~= "gray" then
        local milestoneFloor = (cDetails and (cDetails.isClassOrProfession or cDetails.isCap or cDetails.hasUnlock)) and 0.92 or 0.90
        totalWorth = math.max(totalWorth, milestoneFloor)
    end

    -- Viability Damping & Bankable Calibration (only for real combat / challenge quests, not safe talk-to deliveries!)
    if not isTalkTo then
        if color == "red" or delta >= 5 then
            if isHighValue then
                -- High-value red quest: Bank for later (+5 or higher)
                -- Calibrated strictly to 48% - 52% (below Yellow hub clusters)
                totalWorth = math.max(0.48, math.min(0.52, totalWorth * 0.75))
                isBankable = true
            else
                -- Generic red quest: too dangerous, do not attempt
                totalWorth = math.min(0.35, totalWorth * 0.40)
            end
        elseif color == "orange" or delta >= 3 then
            if isHighValue then
                -- High-value orange quest: Bank for later (+3 / +4)
                -- Calibrated strictly to 53% - 60%
                totalWorth = math.max(0.53, math.min(0.60, totalWorth * 0.85))
                isBankable = true
            else
                -- Generic orange quest
                totalWorth = math.min(0.48, totalWorth * 0.60)
            end
        elseif (dDetails and (dDetails.isElite or dDetails.isDungeon)) and delta >= 0 then
            if isMilestone then
                local milestoneFloor = (cDetails and (cDetails.isClassOrProfession or cDetails.isCap or cDetails.hasUnlock)) and 0.92 or 0.90
                totalWorth = math.max(totalWorth, milestoneFloor)
            elseif isHighValue then
                totalWorth = math.max(0.45, math.min(0.55, totalWorth * 0.70))
                isBankable = true
            else
                totalWorth = math.min(0.42, totalWorth * 0.50)
            end
        elseif color == "gray" and not (cDetails and cDetails.isClassOrProfession) and fScore < 0.80 then
            totalWorth = totalWorth * 0.30
        end
    end

    -- For No-Gear, Non-Chain quests ("Do Now" XP hub quests):
    -- Cap strictly at 0.76 so that the 80% - 100% band remains strictly reserved
    -- for Gear Upgrades, Chain Finales, and Class Quests!
    if hasNoGear and not isMajorChain then
        totalWorth = math.min(0.76, totalWorth)
    end

    -- Chain Start Floor:
    -- If quest is the start of a chain (step 1 of >1) and not red, floor at 0.35 to save player from skipping and backtracking
    if cDetails and cDetails.step == 1 and (cDetails.totalSteps or 0) > 1 and color ~= "red" and delta < 5 then
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
        isTalkTo = isTalkTo,
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
        if Engine.CacheSize >= MAX_CACHE_SIZE then
            wipe(Engine.Cache)
            Engine.CacheSize = 0
        end

        Engine.Cache[questID] = {
            worth = totalWorth,
            breakdown = breakdown,
        }
        Engine.CacheSize = Engine.CacheSize + 1
    end

    return totalWorth, breakdown
end

-- Calculate composite Worth for an entire geographical zone
function Engine.CalculateZoneWorth(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then return nil end
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

-- Table mapping player race to starting home continent (1 = Kalimdor, 2 = Eastern Kingdoms)
local RACE_HOME_CONTINENT = {
    -- Eastern Kingdoms (Continent 2)
    ["Human"]       = 2,
    ["Dwarf"]       = 2,
    ["Gnome"]       = 2,
    ["Scourge"]     = 2, -- Classic API Undead
    ["Undead"]      = 2,
    ["BloodElf"]    = 2,
    ["HighElf"]     = 2,
    -- Kalimdor (Continent 1)
    ["NightElf"]    = 1,
    ["Orc"]         = 1,
    ["Tauren"]      = 1,
    ["Troll"]       = 1,
    ["Draenei"]     = 1,
    ["Goblin"]      = 1,
    ["Skyborne"]    = 1, -- WoW Forever custom race
}

-- Returns the player's home continent based on race (supports case-insensitivity & safe fallback)
function Engine.GetHomeContinent(playerRace)
    local race = playerRace or (addon.Player and addon.Player.GetRace and addon.Player.GetRace())
    if not race then return 1 end
    if RACE_HOME_CONTINENT[race] then return RACE_HOME_CONTINENT[race] end
    local lower = string.lower(tostring(race))
    for r, cont in pairs(RACE_HOME_CONTINENT) do
        if string.lower(r) == lower then
            return cont
        end
    end
    return 1 -- Safe default fallback continent
end

-- Resolve faction-specific effective minimum entry level for a zone
function Engine.GetEffectiveMinLevel(zoneInfo, playerFaction)
    if not zoneInfo then return nil end
    local faction = playerFaction or (addon.Player and addon.Player.GetFaction and addon.Player.GetFaction()) or "Alliance"

    if faction == "Alliance" and zoneInfo.allianceMin then
        return zoneInfo.allianceMin
    elseif faction == "Horde" and zoneInfo.hordeMin then
        return zoneInfo.hordeMin
    end

    local eff = zoneInfo.effectiveMin
    if type(eff) == "table" then
        return eff[faction] or eff["Alliance"] or zoneInfo.min
    elseif type(eff) == "number" then
        return eff
    end

    return zoneInfo.min
end

-- Universal Class-Specific Mob & Terrain Modifiers for all 9 classes
function Engine.GetClassZoneModifier(zoneInfo, playerClass, playerLevel, effectiveMin)
    if not zoneInfo then return 0, nil end
    local pClass = playerClass or (addon.Player and addon.Player.GetClass and addon.Player.GetClass()) or "WARRIOR"
    local pLevel = playerLevel or (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or 1
    local effMin = effectiveMin or zoneInfo.min or 1
    local isUnderleveled = (pLevel < (effMin + 2))
    local isBelowMin = (pLevel < effMin)

    local mod = 0
    local reasons = {}

    -- Group 1: Physical Bleed & Poison Classes (ROGUE, WARRIOR, DRUID, HUNTER)
    if pClass == "ROGUE" or pClass == "WARRIOR" or pClass == "DRUID" or pClass == "HUNTER" then
        if isUnderleveled and (zoneInfo.undeadHeavy or zoneInfo.elementalHeavy or zoneInfo.mechanicalHeavy) then
            local penalty = (pClass == "ROGUE") and -0.12 or -0.08
            mod = mod + penalty
            if zoneInfo.undeadHeavy then
                table.insert(reasons, "Undead (Immune to Bleeds/Poisons, High Armor)")
            elseif zoneInfo.elementalHeavy then
                table.insert(reasons, "Elementals (Immune to Bleeds/Poisons, High Armor)")
            elseif zoneInfo.mechanicalHeavy then
                table.insert(reasons, "Mechanicals (Immune to Bleeds/Poisons)")
            end
        elseif (not isBelowMin) and (zoneInfo.humanoidHeavy or zoneInfo.beastHeavy) then
            if pClass == "ROGUE" then
                mod = mod + 0.05
                table.insert(reasons, "Humanoid/Beast Synergy (Pick Pocket & 100% Bleed/Poison)")
            else
                mod = mod + 0.04
                table.insert(reasons, "Humanoid/Beast Synergy (100% Bleed Efficiency)")
            end
        end

    -- Group 2: Anti-Undead & Holy Classes (PALADIN, PRIEST)
    elseif pClass == "PALADIN" or pClass == "PRIEST" then
        if zoneInfo.undeadHeavy then
            mod = mod + 0.06
            if pClass == "PALADIN" then
                table.insert(reasons, "Holy Synergy (Exorcism, Turn Undead & Holy Wrath)")
            else
                table.insert(reasons, "Holy Synergy (Shackle Undead & Holy Damage)")
            end
        elseif (not isBelowMin) and zoneInfo.humanoidHeavy then
            mod = mod + 0.02
            table.insert(reasons, "Humanoid Mob Pacing")
        end

    -- Group 3: AoE & Ranged Kiting Classes (MAGE, WARLOCK)
    elseif pClass == "MAGE" or pClass == "WARLOCK" then
        if (not isBelowMin) and zoneInfo.openTerrain and (zoneInfo.humanoidHeavy or zoneInfo.beastHeavy) then
            mod = mod + 0.05
            table.insert(reasons, "Open Terrain Kiting & AoE Farm")
        elseif (not isBelowMin) and (zoneInfo.humanoidHeavy or zoneInfo.beastHeavy) then
            mod = mod + 0.02
            table.insert(reasons, "Standard Ranged Grinding")
        end
        if isUnderleveled and zoneInfo.denseCaves then
            mod = mod - 0.08
            table.insert(reasons, "Confined Caves (High Line-of-Sight & Add Risk)")
        end

    -- Group 4: SHAMAN
    elseif pClass == "SHAMAN" then
        if isUnderleveled and zoneInfo.elementalHeavy then
            mod = mod - 0.08
            table.insert(reasons, "Elemental Resistance Penalty (Fire/Nature Resists)")
        elseif (not isBelowMin) and (zoneInfo.humanoidHeavy or zoneInfo.beastHeavy) then
            mod = mod + 0.04
            table.insert(reasons, "Melee/Caster Totem Synergy")
        end
    end

    -- Additional check for Hunter open-terrain kiting:
    if (not isBelowMin) and pClass == "HUNTER" and zoneInfo.openTerrain and (zoneInfo.humanoidHeavy or zoneInfo.beastHeavy) then
        mod = mod + 0.03
        table.insert(reasons, "Open Range Kiting Synergy")
    end

    mod = math.max(-0.15, math.min(0.10, mod))
    local reasonStr = (#reasons > 0) and table.concat(reasons, "; ") or nil
    return mod, reasonStr
end

-- Universal Race / Home Continent Travel Friction
-- Applies -8% when playerLevel <= 24 on opposite continent (no flight paths), or -2% above 24 when 0 quests in zone
function Engine.GetTravelFrictionPenalty(zoneContinent, playerRace, playerLevel, activeCount)
    if not zoneContinent then return 0, nil end
    if activeCount and activeCount > 0 then
        return 0, nil
    end

    local pLevel = playerLevel or (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or 1
    local pRace = playerRace or (addon.Player and addon.Player.GetRace and addon.Player.GetRace()) or "Human"
    local homeCont = Engine.GetHomeContinent(pRace)
    if homeCont and zoneContinent ~= homeCont then
        if pLevel <= 24 then
            return 0.08, "Cross-Continent Travel Friction (Low level before complete FP network)"
        else
            return 0.02, "Cross-Continent Travel (Boat / Zeppelin required)"
        end
    end

    return 0, nil
end

-- Calculate comprehensive World Map Zone Worth (sweet-spot level curve, hub density, class fit, travel & log synergy)
function Engine.CalculateWorldMapZoneWorth(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then return nil end

    -- Fast path: cached zone evaluation
    if Engine.WorldMapZoneCache and Engine.WorldMapZoneCache[zoneName] then
        return Engine.WorldMapZoneCache[zoneName]
    end

    local playerLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
    local playerFaction = (addon.Player and addon.Player.GetFaction and addon.Player.GetFaction()) or UnitFactionGroup("player") or "Alliance"
    local playerClass = (addon.Player and addon.Player.GetClass and addon.Player.GetClass())
    if not playerClass then
        local _, c = UnitClass("player")
        playerClass = c or "WARRIOR"
    end
    local playerRace = (addon.Player and addon.Player.GetRace and addon.Player.GetRace())
    if not playerRace then
        local _, r = UnitRace("player")
        playerRace = r or "Human"
    end

    local zoneInfo = addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(zoneName)
    local activeWorth, activeCount = Engine.CalculateZoneWorth(zoneName)

    if not zoneInfo and not activeWorth then
        return nil
    end

    local readyCount = 0
    if activeCount and activeCount > 0 and addon.Scores and addon.Scores.GetQuestsForZone then
        local zQuests = addon.Scores.GetQuestsForZone(zoneName)
        if zQuests then
            for _, qID in ipairs(zQuests) do
                if Engine.IsQuestComplete(qID) then
                    readyCount = readyCount + 1
                end
            end
        end
    end

    local minLevel = zoneInfo and zoneInfo.min or nil
    local maxLevel = zoneInfo and zoneInfo.max or nil
    local effectiveMin = Engine.GetEffectiveMinLevel(zoneInfo, playerFaction) or minLevel
    if effectiveMin and maxLevel and effectiveMin > maxLevel then
        effectiveMin = maxLevel
    end
    local faction = zoneInfo and zoneInfo.faction or "Contested"
    local isCity = zoneInfo and zoneInfo.isCity or false
    local isDungeon = (zoneInfo and zoneInfo.isDungeon) or false
    local reqClass = zoneInfo and zoneInfo.class or nil
    local continent = zoneInfo and zoneInfo.continent or nil
    local densityLabel = (zoneInfo and zoneInfo.density) or "Medium"
    local rawHubMod = (zoneInfo and zoneInfo.hubMod) or 0.00
    local hubName = zoneInfo and (
        (playerFaction == "Alliance" and zoneInfo.allianceHub)
        or (playerFaction == "Horde" and zoneInfo.hordeHub)
        or zoneInfo.hub
        or zoneInfo.allianceHub
        or zoneInfo.hordeHub
    ) or nil
    local zoneSummary = zoneInfo and zoneInfo.summary or nil

    local bracketScore = 0.50
    local status = "Neutral Zone"
    local recommendation = zoneSummary or "Standard questing zone."
    local sweetMin, sweetMax = effectiveMin, maxLevel
    local applyHubMod = false

    if not zoneInfo then
        bracketScore = activeWorth or 0.50
        status = (activeCount and activeCount > 0) and string.format("%d Quests in Log", activeCount) or "Zone"
        recommendation = "Zone has active quests in your Quest Log."
    elseif isCity then
        bracketScore = 0.15
        status = "Capital City"
        recommendation = "Major capital city (bank, auction house, trainers). Not a leveling zone."
    elseif reqClass and reqClass ~= playerClass then
        bracketScore = 0.05
        status = string.format("Class Restricted (%s)", reqClass)
        recommendation = string.format("Dedicated to %s class quests only. No leveling content for %s.", reqClass, playerClass)
    elseif faction ~= "Contested" and faction ~= "Neutral" and faction ~= playerFaction then
        if minLevel and minLevel <= 10 then
            bracketScore = 0.05
            status = "Hostile Territory"
            recommendation = "Enemy starting zone (no friendly quest hubs)."
        else
            bracketScore = 0.15
            status = "Enemy Territory"
            recommendation = "Few or no friendly quests available."
        end
    elseif isDungeon then
        -- Dungeon instance bracket suitability & prequest guidance
        if effectiveMin and playerLevel < effectiveMin then
            local diff = effectiveMin - playerLevel
            if diff <= 2 then
                bracketScore = 0.76 - (diff - 1) * 0.06
                status = string.format("Upcoming Dungeon (%d+)", effectiveMin)
                recommendation = string.format("Prepare dungeon prequests. Recommended for 5-player groups at level %d+.", effectiveMin)
            else
                bracketScore = math.max(0.05, 0.40 - (diff - 2) * 0.10)
                status = string.format("High Level Dungeon (%d+)", effectiveMin)
                recommendation = string.format("Dangerous instance enemies. Gather group & prequests at level %d+.", effectiveMin)
            end
        elseif effectiveMin and maxLevel and playerLevel >= effectiveMin and playerLevel <= maxLevel then
            local mid = math.floor((effectiveMin + maxLevel) * 0.5)
            local dist = math.abs(playerLevel - mid)
            bracketScore = math.max(0.76, 0.87 - dist * 0.02)
            applyHubMod = true
            if activeCount and activeCount > 0 then
                status = "Ready for Dungeon!"
                recommendation = string.format("5-player instance (%d-%d) with %d active quests in log. Form group and clear!", minLevel, maxLevel, activeCount)
            else
                status = "Recommended Dungeon"
                recommendation = string.format("5-player instance (%d-%d). Gather dungeon quests before entering!", minLevel, maxLevel)
            end
        elseif maxLevel and playerLevel <= (maxLevel + 4) then
            bracketScore = 0.40
            status = "Low Level Dungeon"
            recommendation = "Instance outleveled. Good for fast quest clears or helping friends."
        else
            bracketScore = 0.15
            status = "Outleveled Dungeon"
            recommendation = "Trivial content. Instance mobs grant minimal or gray XP."
        end
    else
        -- Granular Outdoor Zone Sweet-Spot Curve
        if effectiveMin and maxLevel and effectiveMin == 1 and maxLevel <= 12 then
            sweetMin, sweetMax = 1, 8
            if playerLevel <= 6 then
                bracketScore = 0.88 - (playerLevel - 1) * 0.005
                status = "Peak Starter Zone"
                applyHubMod = true
                recommendation = zoneSummary or "Fast starter quest chain for levels 1-6."
            elseif playerLevel <= maxLevel then
                bracketScore = math.max(0.72, 0.85 - (playerLevel - 6) * 0.03)
                status = "Optimal Starter Zone"
                applyHubMod = true
                recommendation = zoneSummary or "Great XP finishing starter hub before moving to a 10-20 zone."
            elseif playerLevel <= (maxLevel + 3) then
                bracketScore = math.max(0.32, 0.50 - (playerLevel - maxLevel) * 0.08)
                status = "Low Level"
                recommendation = "Declining XP rewards. Consider moving to a 10-20 leveling zone."
            else
                bracketScore = 0.12
                status = "Outleveled"
                recommendation = "Trivial starter zone. Mobs grant minimal or gray XP."
            end
        elseif effectiveMin and playerLevel < effectiveMin then
            local diff = effectiveMin - playerLevel
            if diff == 1 then
                bracketScore = 0.78
                status = string.format("Upcoming (%d+)", effectiveMin)
                recommendation = string.format("Challenging entry quests now; hits sweet spot at level %d-%d.", effectiveMin, math.min(maxLevel or effectiveMin + 4, effectiveMin + 4))
            elseif diff == 2 then
                bracketScore = 0.66
                status = string.format("Upcoming (%d+)", effectiveMin)
                recommendation = string.format("Only early intro quests viable. Main quest hubs open cleanly at level %d.", effectiveMin)
            elseif diff == 3 then
                bracketScore = 0.42
                status = string.format("High Entry (%d+)", effectiveMin)
                if zoneName == "Hillsbrad Foothills" and playerFaction == "Alliance" then
                    recommendation = "Alliance quests in Southshore start at level 22-24 (Tarren Mill has earlier quests). Return at level 23+."
                else
                    recommendation = string.format("Most quests are red/orange. Recommended level %d+.", effectiveMin)
                end
            else
                bracketScore = math.max(0.05, 0.40 - (diff - 3) * 0.09)
                status = "Too High Level"
                recommendation = string.format("Dangerous enemies. Recommended to return at level %d+.", effectiveMin)
            end
        elseif zoneName == "Redridge Mountains" and (playerLevel == 20 or playerLevel == 21) then
            bracketScore = 0.65
            status = "Mid-Bracket Dip (Elites)"
            recommendation = "Solo Lakeshire quests outleveled. Remaining quests are challenging lvl 21-25 Blackrock & Elite group chains."
        elseif effectiveMin and maxLevel and playerLevel >= effectiveMin and playerLevel <= maxLevel then
            local span = math.max(4, maxLevel - effectiveMin)
            sweetMin = effectiveMin + 1
            local sweetPeak = effectiveMin + math.min(3, math.max(1, math.floor(span * 0.25)))
            sweetMax = effectiveMin + math.max(3, math.floor(span * 0.55))
            applyHubMod = true

            if playerLevel == effectiveMin then
                bracketScore = 0.85
                status = string.format("Early Entry (%d+)", effectiveMin)
                recommendation = zoneSummary or string.format("Good entry level; quests stack rapidly through level %d.", sweetMax)
            elseif playerLevel >= sweetMin and playerLevel <= sweetMax then
                local dist = math.abs(playerLevel - sweetPeak)
                bracketScore = 0.89 - (dist * 0.015)
                status = (dist <= 1) and "Sweet Spot (Peak XP)" or "Optimal Sweet Spot"
                recommendation = zoneSummary or "Prime solo questing level with ideal yellow mobs and fast XP/hour."
            elseif playerLevel <= (maxLevel - 2) then
                local stepsPast = playerLevel - sweetMax
                bracketScore = math.max(0.76, 0.85 - (stepsPast * 0.025))
                status = "Mid-Late Bracket"
                recommendation = zoneSummary or "Still solid XP and dungeon/chain payoffs before transitioning."
            else
                bracketScore = (playerLevel == maxLevel) and 0.70 or 0.74
                status = "Late Bracket (Wrap-Up)"
                recommendation = "Finishing bracket; wrap up high-payoff chains or dungeons, then transition up."
            end
        elseif maxLevel and playerLevel <= (maxLevel + 3) then
            local over = playerLevel - maxLevel
            bracketScore = math.max(0.32, 0.52 - (over - 1) * 0.09)
            status = "Low Level"
            recommendation = "Declining XP rewards; mobs are mostly green. Transition to a higher bracket soon."
        else
            local over = (maxLevel and (playerLevel - maxLevel)) or 5
            bracketScore = math.max(0.10, 0.25 - math.max(0, over - 3) * 0.04)
            status = "Outleveled"
            recommendation = "Trivial content. Quests grant minimal or gray XP."
        end
    end

    -- Zone Hub Density modifier
    local hubMod = 0.00
    if applyHubMod or (rawHubMod < 0 and effectiveMin and playerLevel >= (effectiveMin - 1)) then
        hubMod = rawHubMod
    end

    -- Class mob modifier, friendly territory comfort bonus & continent travel friction
    local classMod, classModReason = Engine.GetClassZoneModifier(zoneInfo, playerClass, playerLevel, effectiveMin)
    if isCity or (reqClass and reqClass ~= playerClass) or (faction ~= "Contested" and faction ~= "Neutral" and faction ~= playerFaction) then
        classMod = 0
        classModReason = nil
    end

    local travelPenalty, travelReason = Engine.GetTravelFrictionPenalty(continent, playerRace, playerLevel, activeCount)
    if bracketScore <= 0.15 then
        travelPenalty = 0
    end

    local territoryBonus = 0
    if zoneInfo and not isCity and not isDungeon and faction == playerFaction and (not maxLevel or playerLevel <= maxLevel) then
        territoryBonus = 0.02
    end

    local baseZoneScore = bracketScore + hubMod + classMod + territoryBonus - travelPenalty
    baseZoneScore = math.max(0.05, math.min(0.98, baseZoneScore))

    -- Active Quest Log Synergy: active quests in an appropriate zone BOOST its worth (never penalize it!)
    local activeBonus = 0
    local finalWorth
    if zoneInfo and activeWorth and activeCount and activeCount > 0 then
        if baseZoneScore >= 0.55 then
            activeBonus = math.min(0.10, (activeCount * 0.022) * (0.50 + 0.50 * activeWorth) + (readyCount * 0.02))
            finalWorth = math.min(1.00, baseZoneScore + activeBonus)
        else
            finalWorth = math.max(baseZoneScore, (0.55 * activeWorth) + (0.45 * baseZoneScore))
            activeBonus = math.max(0, finalWorth - baseZoneScore)
        end
    elseif activeWorth and activeCount and activeCount > 0 then
        finalWorth = activeWorth
    else
        finalWorth = baseZoneScore
    end

    finalWorth = math.max(0.0, math.min(1.0, finalWorth))

    -- Concise 1-line explanation for Zone Advisor sidebar rows
    local shortReason
    if activeCount and activeCount > 0 then
        if readyCount > 0 then
            shortReason = string.format("%d in Log (%d Ready) • %s", activeCount, readyCount, hubName or status)
        else
            shortReason = string.format("%d in Log (%.0f%%) • %s", activeCount, (activeWorth or 0) * 100, hubName or status)
        end
    elseif isDungeon then
        shortReason = string.format("5-Man Instance • %s", hubName or status)
    elseif rawHubMod <= -0.07 then
        shortReason = string.format("%s Quests • %s", densityLabel, hubName or status)
    elseif hubName then
        shortReason = string.format("%s • %s", status, hubName)
    else
        shortReason = string.format("%s • %s Quests", status, densityLabel)
    end

    local result = {
        zoneName = zoneName,
        worth = finalWorth,
        minLevel = minLevel,
        maxLevel = maxLevel,
        effectiveMin = effectiveMin,
        sweetMin = sweetMin,
        sweetMax = sweetMax,
        faction = faction,
        isCity = isCity,
        reqClass = reqClass,
        continent = continent,
        isDungeon = isDungeon,
        status = status,
        shortReason = shortReason,
        recommendation = recommendation,
        zoneSummary = zoneSummary,
        hubName = hubName,
        densityLabel = densityLabel,
        hubMod = hubMod,
        territoryBonus = territoryBonus,
        activeCount = activeCount or 0,
        readyCount = readyCount,
        activeWorth = activeWorth,
        activeBonus = activeBonus,
        bracketScore = bracketScore,
        baseZoneScore = baseZoneScore,
        classModifier = classMod,
        classModifierReason = classModReason,
        travelPenalty = travelPenalty,
        travelReason = travelReason,
    }

    if Engine.WorldMapZoneCache then
        Engine.WorldMapZoneCache[zoneName] = result
    end

    return result
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
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  |cffffff00Total Worth:|r %s|cff%s%.1f%%|r (Weights: R=%.0f%% F=%.0f%% C=%.0f%% H=%.0f%% D=%.0f%%)",
        skullPrefix, scoreColorHex, worth * 100, b.wR * 100, b.wF * 100, b.wC * 100, b.wH * 100, b.wD * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (R): %s |cff888888(Weight: %.0f%%)|r",
        L["REWARD"], Utils.FormatScore(b.r), b.wR * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (F): %s |cff888888(Weight: %.0f%%)|r",
        L["CLASS_FIT"], Utils.FormatScore(b.f), b.wF * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (C): %s |cff888888(Weight: %.0f%%)|r",
        L["CHAIN"], Utils.FormatScore(b.c), b.wC * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (H): %s |cff888888(Weight: %.0f%%)|r",
        L["DENSITY"] or "Hub Density", Utils.FormatScore(b.h), b.wH * 100))
    DEFAULT_CHAT_FRAME:AddMessage(string.format("  * %s (D): %s |cff888888(Weight: %.0f%%)|r",
        L["DIFFICULTY"], Utils.FormatScore(b.d), b.wD * 100))

    local payoff = addon.Data and addon.Data.GetQuestPayoff and addon.Data.GetQuestPayoff(questID, info.title)
    if payoff and (payoff.unlock or payoff.reward or payoff.chain or payoff.note) then
        DEFAULT_CHAT_FRAME:AddMessage("  |cffffd100" .. L["PAYOFF_HEADER"] .. "|r")
        if payoff.unlock then DEFAULT_CHAT_FRAME:AddMessage("    * |cff00ffff" .. L["PAYOFF_UNLOCKS"] .. "|r " .. payoff.unlock) end
        if payoff.reward then DEFAULT_CHAT_FRAME:AddMessage("    * |cffffd100" .. L["PAYOFF_REWARD"] .. "|r " .. payoff.reward) end
        if payoff.chain then DEFAULT_CHAT_FRAME:AddMessage("    * |cff00ccff" .. L["PAYOFF_CHAIN"] .. "|r " .. payoff.chain) end
        if payoff.note then DEFAULT_CHAT_FRAME:AddMessage("    * |cffbbbbbb" .. L["PAYOFF_NOTE"] .. "|r " .. payoff.note) end
    end

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
