--[[
    WorthIt / QuestWorth - Scores/Chain.lua
    Score 3: Quest Chain Value (C) in [0.0, 1.0].
    
    Refined Mechanics:
    - Step Progression Curve: Sunk cost vs Big Payoff.
        Early steps (e.g. 1/10) get ~0.45 (long investment ahead).
        Late steps (e.g. 4/5) get ~0.80 (one step before major payout!).
        Final cap / completion (e.g. 5/5) gets 1.00.
    - Standalone Quests: Receive a balanced baseline of 0.10 so independent quests aren't overly penalized.
    - Class / Profession Quests: Automatically 1.00 (critical abilities/milestones).
]]

local addonName, addon = ...
addon.Scores = addon.Scores or {}
local Scores = addon.Scores
local Data = addon.Data
local Utils = addon.Utils

-- Check if quest is marked as Class or Profession quest
local function IsClassOrProfessionQuest(questID)
    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local ok, tagInfo = pcall(C_QuestLog.GetQuestTagInfo, questID)
        if ok and tagInfo then
            -- Tag ID 21 is the constant ID for Class Quests across all locales
            if tagInfo.tagID == 21 or tagInfo.worldStateID == 21 then
                return true
            end
            if tagInfo.tagName then
                local tag = string.lower(tagInfo.tagName)
                if string.find(tag, "class") or string.find(tag, "profession") or string.find(tag, "trade") then
                    return true
                end
            end
        end
    end
    return false
end

-- Check C_QuestLine API
local function CheckCQuestLineAPI(questID)
    if not (C_QuestLine and C_QuestLine.GetQuestLineInfo) then
        return nil
    end

    if Data and Data.APIQuestLineMap and Data.APIQuestLineMap[questID] then
        local qLineID = Data.APIQuestLineMap[questID]
        local ok, quests = pcall(C_QuestLine.GetQuestLineQuests, qLineID)
        if ok and quests and type(quests) == "table" then
            local total = #quests
            if total <= 1 then
                return true, 0.10, false, 1, 1 -- Single-step standalone quest baseline
            end

            local step = nil
            for idx, id in ipairs(quests) do
                if id == questID then
                    step = idx
                    break
                end
            end

            if not step then
                if addon.db and addon.db.debug then
                    addon.Debug("Chain [Q:%d]: In APIQuestLineMap but not in GetQuestLineQuests - API lag?", questID)
                end
                return nil
            end

            local isCap = (step == total)
            local score = isCap and 1.00 or (0.40 + 0.50 * (step / total))
            return true, score, isCap, step, total
        end
    end

    return nil
end

function Scores.CalculateChain(questID)
    local numID = tonumber(questID)
    if not Utils.IsValidQuestID(numID) then
        return 0.10, { source = "InvalidID", final = 0.10 }
    end
    local targetID = numID

    -- Priority 1: Class or Profession quest -> 1.00
    if IsClassOrProfessionQuest(targetID) then
        return 1.00, {
            isClassOrProfession = true,
            inChain = true,
            isCap = true,
            isMilestone = true,
            final = 1.00,
            reason = "Class Quest",
        }
    end

    local payoff = Data and Data.GetQuestPayoff and Data.GetQuestPayoff(targetID)

    -- Priority 2: Data.ChainIndex (Internal High-Fidelity DB)
    if Data and Data.ChainIndex and Data.ChainIndex[targetID] then
        local chainInfo = Data.ChainIndex[targetID]
        local isCap = chainInfo.isCap
        local step = chainInfo.step or 1
        local total = chainInfo.totalSteps or 1

        local hasUnlock = chainInfo.hasUnlock or (payoff and (payoff.unlock ~= nil or payoff.isKeyUnlock == true)) or false
        local hasMajorReward = chainInfo.hasMajorReward or (payoff and payoff.reward ~= nil) or false
        local isMilestone = (chainInfo.isImportant == true) or isCap or hasUnlock or hasMajorReward

        -- Dynamic Step Progression Curve:
        local score
        if isMilestone then
            score = isCap and 1.00 or math.min(0.96, 0.90 + 0.06 * (step / math.max(1, total)))
        elseif step == 1 and total > 1 then
            score = 0.65 -- Chain starter boost (early investment)
        else
            score = isCap and 1.00 or (0.40 + 0.50 * (step / math.max(1, total)))
        end

        local reason = (step == 1 and total > 1) and "Chain Start" or (isCap and "Chain Finale" or nil)

        local details = {
            source = "LocalDB",
            chainID = chainInfo.chainID,
            step = step,
            totalSteps = total,
            isCap = isCap,
            isMilestone = isMilestone,
            hasUnlock = hasUnlock,
            hasMajorReward = hasMajorReward,
            final = score,
            reason = reason,
        }

        if addon.db and addon.db.debug then
            addon.Debug("Chain [Q:%d]: Found in LocalDB (Step %d/%d, Cap=%s, Milestone=%s) -> Score=%.2f",
                targetID, step, total, tostring(isCap), tostring(isMilestone), score)
        end

        return score, details
    end

    -- Priority 3: Modern C_QuestLine API detection
    local found, apiScore, isLast, step, total = CheckCQuestLineAPI(targetID)
    if found then
        if step == 1 and (total or 1) > 1 then
            apiScore = math.max(0.65, apiScore)
        end
        local details = {
            source = "C_QuestLine",
            isCap = isLast,
            step = step,
            totalSteps = total,
            final = apiScore,
            reason = (step == 1 and (total or 1) > 1) and "Chain Start" or (isLast and "Chain Finale" or nil),
        }
        return apiScore, details
    end

    -- Priority 4: Fallback KnownChains scan (only if ChainIndex was not built yet)
    if Data and Data.KnownChains and (not Data.ChainIndex or next(Data.ChainIndex) == nil) then
        local bestMatch = nil
        for chainID, chainData in pairs(Data.KnownChains) do
            local quests = chainData.quests or {}
            local total = #quests
            for step, id in ipairs(quests) do
                if id == targetID or tonumber(id) == targetID then
                    if not bestMatch or total > bestMatch.total or (total == bestMatch.total and type(chainID) == "number" and chainID < 3000 and (type(bestMatch.chainID) ~= "number" or bestMatch.chainID >= 3000)) then
                        bestMatch = {
                            chainID = chainID,
                            chainData = chainData,
                            step = step,
                            total = total,
                        }
                    end
                    break
                end
            end
        end

        if bestMatch then
            local step = bestMatch.step
            local total = bestMatch.total
            local isCap = (step == total)
            local isMilestone = (bestMatch.chainData.isImportant == true) or isCap
            local score
            if isMilestone then
                score = isCap and 1.00 or math.min(0.96, 0.90 + 0.06 * (step / math.max(1, total)))
            elseif step == 1 and total > 1 then
                score = 0.65 -- Chain starter boost
            else
                score = isCap and 1.00 or (0.40 + 0.50 * (step / math.max(1, total)))
            end
            local details = {
                source = "KnownChainsFallback",
                chainID = bestMatch.chainID,
                step = step,
                totalSteps = total,
                isCap = isCap,
                isMilestone = isMilestone,
                final = score,
                reason = (step == 1 and total > 1) and "Chain Start" or (isCap and "Chain Finale" or nil),
            }
            if addon.db and addon.db.debug then
                addon.Debug("Chain [Q:%d]: Found in KnownChains (Step %d/%d) -> Score=%.2f",
                    targetID, step, total, score)
            end
            return score, details
        end
    end

    -- Priority 5: Curated single-step Unlock / Attunement / Key / Major Reward
    if payoff and (payoff.unlock or payoff.isKeyUnlock or payoff.reward) then
        local hasUnlock = (payoff.unlock ~= nil or payoff.isKeyUnlock == true)
        local score = hasUnlock and 0.95 or 0.90
        return score, {
            source = "PayoffDB",
            inChain = true,
            isCap = true,
            isMilestone = true,
            hasUnlock = hasUnlock,
            hasMajorReward = (payoff.reward ~= nil),
            final = score,
            reason = "Chain Finale",
        }
    end

    -- Fallback: Standalone / Unchained quest baseline
    -- Standalone quests receive a balanced 0.10 baseline so independent quests aren't overly penalized
    local defaultScore = 0.10
    local details = {
        source = "Standalone",
        inChain = false,
        isCap = false,
        final = defaultScore,
        note = "Standalone quest (0.10 baseline)",
    }

    if addon.db and addon.db.debug then
        addon.Debug("Chain [Q:%d]: Standalone quest -> Score=%.2f", targetID, defaultScore)
    end

    return defaultScore, details
end
