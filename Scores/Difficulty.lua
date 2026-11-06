--[[
    WorthIt / QuestWorth - Scores/Difficulty.lua
    Score 1: Difficulty (D) in [0.0, 1.0].
    
    Refined Mechanics:
    - Removed Double Penalty: Eliminated redundant delta>3 penalty (base score already handles it).
    - Melee-Aware Difficulty Scaling: Rogues, Warriors, and Paladins suffer high glancing/dodge
      penalties on +1/+2 mobs causing eating/bandage downtime.
      Even/slightly lower level quests (-3 to 0) yield significantly higher real XP/hour for melee!
]]

local addonName, addon = ...
addon.Scores = addon.Scores or {}
local Scores = addon.Scores
local Utils = addon.Utils

-- Known tag IDs across WoW client builds (locale-independent)
local DUNGEON_TAGS = { [81] = true, [62] = true, [23] = true, [26] = true }
local RAID_TAGS = { [83] = true, [85] = true, [88] = true }
local GROUP_TAGS = { [1] = true }

-- Detect if active class / spec is Melee-focused
local function IsMeleePlayer()
    local _, playerClass = UnitClass("player")
    playerClass = playerClass or "WARRIOR"

    if playerClass == "WARRIOR" or playerClass == "ROGUE" or playerClass == "DEATHKNIGHT" or playerClass == "DEMONHUNTER" then
        return true
    elseif playerClass == "PALADIN" then
        if GetNumTalentTabs and GetTalentTabInfo then
            local _, _, holyPoints = GetTalentTabInfo(1) -- Tab 1 = Holy
            if holyPoints and holyPoints > 5 then return false end
        end
        return true -- Most leveling paladins are Ret/Prot
    elseif playerClass == "DRUID" then
        -- Check if Feral
        if GetNumTalentTabs and GetTalentTabInfo then
            local _, _, feralPoints = GetTalentTabInfo(2)
            if feralPoints and feralPoints > 5 then return true end
        end
    elseif playerClass == "SHAMAN" then
        -- Check if Enhancement
        if GetNumTalentTabs and GetTalentTabInfo then
            local _, _, enhPoints = GetTalentTabInfo(2)
            if enhPoints and enhPoints > 5 then return true end
        end
    end
    return false
end

-- Difficulty color & delta evaluation
local function CalculateBaseDifficulty(questLevel, playerLevel, isMelee)
    local delta = questLevel - playerLevel

    local greenRange = 5
    if GetQuestGreenRange then
        local okRange, range = pcall(GetQuestGreenRange)
        if okRange and tonumber(range) then
            greenRange = tonumber(range)
        end
    end

    -- Gray: Trivial quest, yields 0 to near-zero XP
    if delta < -greenRange then
        return "gray", 0.00
    end

    -- Red: Severe miss/resist chance
    if delta >= 5 then
        return "red", 0.10
    end

    -- Orange: High difficulty, heavy downtime
    if delta >= 3 then
        return "orange", 0.35
    end

    -- Melee-tuned curve for Yellow/Green bracket
    if isMelee then
        if delta >= -3 and delta <= 0 then
            return "yellow_sweetspot", 1.00
        elseif delta == 1 then
            return "yellow_high", 0.85
        elseif delta == 2 then
            return "yellow_peak", 0.70
        elseif delta >= -greenRange then
            return "deep_green", 0.50
        else
            return "gray", 0.00
        end
    else
        if delta >= -2 and delta <= 2 then
            return "yellow", 1.00
        elseif delta >= -4 and delta <= -3 then
            return "green", 0.85
        elseif delta >= -greenRange then
            return "deep_green", 0.55
        else
            return "gray", 0.00
        end
    end
end

function Scores.CalculateDifficulty(questID)
    local playerLevel = UnitLevel("player") or 1
    local info = Utils.GetQuestBasicInfo(questID)
    local questLevel = (info and info.level) or playerLevel
    local isElite = (info and info.isElite) or false
    local isDungeon = false
    local isGroup = false
    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local ok, tag = pcall(C_QuestLog.GetQuestTagInfo, questID)
        if ok and tag then
            local tagID = tag.tagID or tag.worldStateID
            local tagName = tag.tagName or ""
            if tag.isElite == true or (tagName ~= "" and (string.find(tagName, "Elite", 1, true) or (ELITE and string.find(tagName, ELITE, 1, true)))) then
                isElite = true
            end
            if (tagID and (DUNGEON_TAGS[tagID] or RAID_TAGS[tagID])) or
               string.find(tagName, "Dungeon") or string.find(tagName, "Raid") or
               string.find(tagName, "Verlies") or string.find(tagName, "Donjon") or
               string.find(tagName, "Подземелье") then
                isDungeon = true
            elseif (tagID and GROUP_TAGS[tagID]) or
                   string.find(tagName, "Group") or string.find(tagName, "Gruppe") or
                   string.find(tagName, "Groupe") or string.find(tagName, "Группа") then
                isGroup = true
            end
        end
    end

    local isMelee = IsMeleePlayer()

    local colorName, baseScore = CalculateBaseDifficulty(questLevel, playerLevel, isMelee)
    local penalty = 0.0
    local levelDelta = questLevel - playerLevel

    -- Penalty: Dungeon / Group / Elite Quest solo overhead (No double-penalty on delta)
    if isDungeon then
        penalty = 0.35 -- Requires full 5-man instance group + travel
    elseif isElite or isGroup then
        if levelDelta >= 0 then
            penalty = 0.30
        elseif levelDelta >= -3 then
            penalty = 0.15
        else
            penalty = 0.05 -- Player significantly outlevels elite
        end
    end

    local finalScore = math.max(0.0, math.min(1.0, baseScore - penalty))

    local reason = nil
    if colorName == "red" or colorName == "orange" then
        reason = "High Level"
    elseif isElite then
        reason = "Elite Mob"
    elseif isDungeon then
        reason = "Dungeon"
    elseif colorName == "gray" then
        reason = "Trivial"
    elseif finalScore >= 0.85 then
        reason = "Optimal Level"
    elseif finalScore <= 0.20 then
        reason = "Hard Mob"
    end

    local details = {
        questLevel = questLevel,
        playerLevel = playerLevel,
        levelDelta = levelDelta,
        colorName = colorName,
        baseScore = baseScore,
        penalty = penalty,
        isElite = isElite,
        isMelee = isMelee,
        final = finalScore,
        reason = reason,
    }

    if addon.db and addon.db.debug then
        addon.Debug("Difficulty [Q:%d]: Lvl %d (Player %d, Delta %d, Melee=%s) Color=%s Base=%.2f Penalty=%.2f -> Final=%.2f",
            questID, questLevel, playerLevel, levelDelta, tostring(isMelee), colorName, baseScore, penalty, finalScore)
    end

    return finalScore, details
end
