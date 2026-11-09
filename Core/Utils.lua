--[[
    WorthIt / QuestWorth - Core/Utils.lua
    Utility functions, safe API callers (pcall), logging & formatting.
    Features a smooth, continuous Red-to-Green chromatic gradient for Worth scores.
]]

local addonName, addon = ...
addon.Utils = {}
local Utils = addon.Utils

-- Safe call wrapper
function Utils.SafeCall(func, ...)
    if type(func) ~= "function" then
        return false, "Not a function"
    end
    return pcall(func, ...)
end

-- Helper: Temporarily selects questID so legacy/hybrid functions
-- (GetQuestLogItemLink, GetQuestLogRewardXP, GetQuestLogRewardMoney) read the right quest.
-- CRITICAL SAFETY: Never change C_QuestLog.SetSelectedQuest if the QuestMap is open!
-- Changing map selection programmatically causes map pins and details to constantly flicker!
function Utils.WithSelectedQuest(questID, callback)
    if not questID or questID <= 0 then
        return callback()
    end

    local currID = C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetSelectedQuest()
    if currID == questID then
        return callback()
    end

    -- If the map or quest details is currently open, DO NOT alter the player's active map selection
    local mapShown = (QuestMapFrame and QuestMapFrame:IsShown()) or (WorldMapFrame and WorldMapFrame:IsShown())
    if mapShown then
        return callback()
    end

    local prevIndex = nil
    local changed = false

    if GetQuestLogSelection and SelectQuestLogEntry and C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local ok, currIdx = pcall(GetQuestLogSelection)
        if ok then prevIndex = currIdx end
        local okIdx, idx = pcall(C_QuestLog.GetLogIndexForQuestID, questID)
        if okIdx and idx and idx > 0 and idx ~= prevIndex then
            pcall(SelectQuestLogEntry, idx)
            changed = true
        end
    end

    local okCall, res1, res2, res3 = pcall(callback)

    if changed and prevIndex and SelectQuestLogEntry then
        pcall(SelectQuestLogEntry, prevIndex)
    end

    if okCall then
        return res1, res2, res3
    end
    return nil
end

-- Safe item info getter: prefers C_Item.GetItemInfo (modern/Forever), falls back to legacy (memoized)
local _iic = {}

function Utils.SafeGetItemInfo(item)
    if not item then return nil end
    if _iic[item] then
        local c = _iic[item]
        return c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9],
               c[10], c[11], c[12], c[13], c[14], c[15], c[16], c[17], c[18]
    end
    local fn = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    if not fn then return nil end
    local ok, name, link, quality, itemLevel, minLevel, itemType, itemSubType,
          maxStack, equipLoc, icon, sellPrice, classID, subClassID,
          bindType, expansionID, setID, isCraftingReagent = pcall(fn, item)
    if not ok or not name then return nil end

    local size = 0
    for _ in pairs(_iic) do size = size + 1; if size >= 200 then break end end
    if size >= 200 then wipe(_iic) end

    _iic[item] = {
        name, link, quality, itemLevel, minLevel, itemType, itemSubType,
        maxStack, equipLoc, icon, sellPrice, classID, subClassID,
        bindType, expansionID, setID, isCraftingReagent
    }
    return name, link, quality, itemLevel, minLevel, itemType, itemSubType,
           maxStack, equipLoc, icon, sellPrice, classID, subClassID,
           bindType, expansionID, setID, isCraftingReagent
end
addon.SafeGetItemInfo = Utils.SafeGetItemInfo

function addon.ClearSafeGetItemInfoCache()
    wipe(_iic)
end

-- Persistent quest rewards cache (item links & vendor values)
local _questRewardsCache = {}

function Utils.GetQuestRewardData(questID)
    if not questID or questID <= 0 then
        return {}, {}, 0, 0
    end

    if _questRewardsCache[questID] then
        local c = _questRewardsCache[questID]
        return c.choices, c.rewards, c.maxChoicePrice, c.fixedPricesSum
    end

    local choices = {}
    local rewards = {}
    local maxChoicePrice = 0
    local fixedPricesSum = 0

    -- Modern C_QuestLog resolution (independent of player's UI selection!)
    local numChoices = (C_QuestLog and C_QuestLog.GetNumQuestLogChoices and C_QuestLog.GetNumQuestLogChoices(questID)) or 0
    for i = 1, numChoices do
        local link = nil
        if C_QuestLog and C_QuestLog.GetQuestRewardItemLink then
            local ok, l = pcall(C_QuestLog.GetQuestRewardItemLink, i, questID)
            if ok and l then link = l end
            if not link then
                local ok2, l2 = pcall(C_QuestLog.GetQuestRewardItemLink, questID, i)
                if ok2 and l2 then link = l2 end
            end
        end
        if not link and C_QuestLog and C_QuestLog.GetQuestLogRewardInfo then
            local ok, info = pcall(C_QuestLog.GetQuestLogRewardInfo, i, questID)
            local itemID = (type(info) == "table" and info.itemID) or (type(info) == "number" and info)
            if ok and itemID then
                link = select(2, addon.SafeGetItemInfo(itemID))
            end
        end
        if link then
            table.insert(choices, link)
            local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
            if sellPrice > maxChoicePrice then
                maxChoicePrice = sellPrice
            end
        end
    end

    local numRewards = (C_QuestLog and C_QuestLog.GetNumQuestLogRewards and C_QuestLog.GetNumQuestLogRewards(questID)) or 0
    for i = 1, numRewards do
        local link = nil
        if C_QuestLog and C_QuestLog.GetQuestRewardItemLink then
            local ok, l = pcall(C_QuestLog.GetQuestRewardItemLink, i, questID)
            if ok and l then link = l end
            if not link then
                local ok2, l2 = pcall(C_QuestLog.GetQuestRewardItemLink, questID, i)
                if ok2 and l2 then link = l2 end
            end
        end
        if not link and C_QuestLog and C_QuestLog.GetQuestLogRewardInfo then
            local ok, info = pcall(C_QuestLog.GetQuestLogRewardInfo, i, questID)
            local itemID = (type(info) == "table" and info.itemID) or (type(info) == "number" and info)
            if ok and itemID then
                link = select(2, addon.SafeGetItemInfo(itemID))
            end
        end
        if link then
            table.insert(rewards, link)
            local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
            fixedPricesSum = fixedPricesSum + sellPrice
        end
    end

    -- Fallback: If modern APIs returned nothing, try with selected quest (only if map is not open)
    if #choices == 0 and #rewards == 0 then
        Utils.WithSelectedQuest(questID, function()
            local nC = (GetNumQuestLogChoices and GetNumQuestLogChoices(questID)) or 0
            for i = 1, nC do
                local link = GetQuestLogItemLink and GetQuestLogItemLink("choice", i)
                if link then
                    table.insert(choices, link)
                    local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
                    if sellPrice > maxChoicePrice then maxChoicePrice = sellPrice end
                end
            end
            local nR = (GetNumQuestLogRewards and GetNumQuestLogRewards(questID)) or 0
            for i = 1, nR do
                local link = GetQuestLogItemLink and GetQuestLogItemLink("reward", i)
                if link then
                    table.insert(rewards, link)
                    local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
                    fixedPricesSum = fixedPricesSum + sellPrice
                end
            end
        end)
    end

    -- Fallback for unaccepted quest in QuestFrame dialog
    if #choices == 0 and #rewards == 0 and QuestFrame and QuestFrame:IsShown() and GetQuestID and GetQuestID() == questID then
        local numOfferChoices = (GetNumQuestChoices and GetNumQuestChoices()) or 0
        for i = 1, numOfferChoices do
            local link = GetQuestItemLink and GetQuestItemLink("choice", i)
            if link then
                table.insert(choices, link)
                local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
                if sellPrice > maxChoicePrice then maxChoicePrice = sellPrice end
            end
        end
        local numOfferRewards = (GetNumQuestRewards and GetNumQuestRewards()) or 0
        for i = 1, numOfferRewards do
            local link = GetQuestItemLink and GetQuestItemLink("reward", i)
            if link then
                table.insert(rewards, link)
                local sellPrice = select(11, addon.SafeGetItemInfo(link)) or 0
                fixedPricesSum = fixedPricesSum + sellPrice
            end
        end
    end

    -- If we found items or prices, cache it!
    if #choices > 0 or #rewards > 0 then
        _questRewardsCache[questID] = {
            choices = choices,
            rewards = rewards,
            maxChoicePrice = maxChoicePrice,
            fixedPricesSum = fixedPricesSum,
        }
    end

    return choices, rewards, maxChoicePrice, fixedPricesSum
end

function Utils.ClearQuestRewardsCache(questID)
    if questID then
        _questRewardsCache[questID] = nil
    else
        wipe(_questRewardsCache)
    end
end
addon.ClearQuestRewardsCache = Utils.ClearQuestRewardsCache

-- Smooth, continuous Red -> Orange -> Yellow -> Lime -> Bright Green gradient
function Utils.GetScoreColor(score)
    score = tonumber(score) or 0.50
    score = math.max(0.0, math.min(1.0, score))

    local r, g, b
    if score < 0.50 then
        local t = score / 0.50
        r = 1.00
        g = 0.15 + (0.85 * t)
        b = 0.10
    else
        local t = (score - 0.50) / 0.50
        r = 1.00 - (0.88 * t)
        g = 1.00
        b = 0.10 + (0.20 * t)
    end

    return r, g, b
end

local _hexCache = {}
function Utils.GetScoreColorHex(score)
    score = tonumber(score) or 0.50
    score = math.max(0.0, math.min(1.0, score))
    local bucket = math.floor(score * 200 + 0.5)
    local cached = _hexCache[bucket]
    if cached then return cached end
    local realScore = bucket / 200
    local r, g, b = Utils.GetScoreColor(realScore)
    cached = string.format("%02x%02x%02x", math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
    _hexCache[bucket] = cached
    return cached
end

function Utils.FormatScore(score)
    score = tonumber(score) or 0.50
    if score ~= score then score = 0.50 end
    score = math.max(0.0, math.min(1.0, score))
    local hex = Utils.GetScoreColorHex(score)
    local pct = math.max(0, math.min(100, math.floor(score * 100 + 0.5)))
    return string.format("|cff%s%d%%|r", hex, pct)
end

function Utils.FormatBadge(score, isComplete, isHard, isBankable)
    if isComplete then
        return "|cff1aff4d[OK]|r"
    end
    score = tonumber(score) or 0.50
    if score ~= score then score = 0.50 end
    score = math.max(0.0, math.min(1.0, score))
    local pct = math.max(0, math.min(100, math.floor(score * 100 + 0.5)))
    
    local hex
    if isBankable then
        -- Distinctive Warm Amber / Orange for Viability-Damped / Bankable quests (Save for later)
        hex = "ff9900"
    else
        hex = Utils.GetScoreColorHex(score)
    end

    local badge = string.format("|cff%s[%d%%]|r", hex, pct)
    if isHard then
        return "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:12:12:0:0|t " .. badge
    end
    return badge
end

function Utils.CleanQuestTitle(title)
    if not title or title == "" then return "" end
    local cleaned = title
    local changed = true
    local passes = 0
    while changed and passes < 5 do
        passes = passes + 1
        local prev = cleaned
        cleaned = string.gsub(cleaned, "^(%s*%-?%s*)|T[^|]+|t%s*", "%1")
        cleaned = string.gsub(cleaned, "^(%s*%-?%s*)|c%x%x%x%x%x%x%x%x%[[^%]]+%]%|r%s*", "%1")
        cleaned = string.gsub(cleaned, "^(%s*%-?%s*)%[[^%]]*Worth[^%]]*%]%s*", "%1")
        cleaned = string.gsub(cleaned, "^(%s*%-?%s*)%[%d+%%%]%s*", "%1")
        cleaned = string.gsub(cleaned, "^(%s*%-?%s*)%[OK%]%s*", "%1")
        cleaned = string.gsub(cleaned, "%s*|T[^|]+|t$", "")
        cleaned = string.gsub(cleaned, "%s*|c%x%x%x%x%x%x%x%x%[[^%]]+%]%|r$", "")
        cleaned = string.gsub(cleaned, "%s*%[[^%]]*Worth[^%]]*%]$", "")
        cleaned = string.gsub(cleaned, "%s*%[%d+%%%]$", "")
        cleaned = string.gsub(cleaned, "%s*%[OK%]$", "")
        changed = (cleaned ~= prev)
    end
    return cleaned
end

function addon.Print(msg, ...)
    if select("#", ...) > 0 then
        msg = string.format(msg, ...)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffWorthIt:|r " .. tostring(msg))
end

function addon.Debug(msg, ...)
    if not (addon.db and addon.db.debug) then return end
    if select("#", ...) > 0 then
        msg = string.format(msg, ...)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cff888888[WorthIt Debug]|r " .. tostring(msg))
end

-- Normalize 5 weights (Difficulty, Reward, Chain, ClassFit, Density) to sum to 1.0
function Utils.NormalizeWeights(wD, wR, wC, wF, wH)
    local d = math.max(0, (wD ~= nil and tonumber(wD)) or 0.00)
    local r = math.max(0, (wR ~= nil and tonumber(wR)) or 0.40)
    local c = math.max(0, (wC ~= nil and tonumber(wC)) or 0.30)
    local f = math.max(0, (wF ~= nil and tonumber(wF)) or 0.15)
    local h = math.max(0, (wH ~= nil and tonumber(wH)) or 0.15)

    local sum = d + r + c + f + h
    if sum <= 0 then
        if wF == 0 then
            return 0.00, 0.47, 0.35, 0.00, 0.18
        end
        return 0.00, 0.40, 0.30, 0.15, 0.15
    end
    return d / sum, r / sum, c / sum, f / sum, h / sum
end

-- Safe Quest Title/Level getter across Modern C_QuestLog, Gossip NPCs, and Legacy APIs
function Utils.GetQuestBasicInfo(questID)
    if not questID or questID <= 0 then return nil end

    local title, level, isElite, isHeader

    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        local ok, t = pcall(C_QuestLog.GetTitleForQuestID, questID)
        if ok and t and t ~= "" then
            title = t
        end
    end

    if C_QuestLog and C_QuestLog.GetQuestDifficultyLevel then
        local ok, lvl = pcall(C_QuestLog.GetQuestDifficultyLevel, questID)
        if ok and lvl and lvl > 0 then
            level = lvl
        end
    end

    if C_QuestLog and C_QuestLog.GetQuestTagInfo then
        local ok, tagInfo = pcall(C_QuestLog.GetQuestTagInfo, questID)
        if ok and tagInfo then
            if tagInfo.isElite == true then
                isElite = true
            elseif tagInfo.tagName and type(tagInfo.tagName) == "string"
                   and (string.find(tagInfo.tagName, "Elite", 1, true) or (ELITE and string.find(tagInfo.tagName, ELITE, 1, true))) then
                isElite = true
            end
        end
    end

    -- Scan active Quest Log if title or level is still missing
    if not title or not level then
        local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries()) or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
        for i = 1, numEntries do
            if C_QuestLog and C_QuestLog.GetInfo then
                local ok, info = pcall(C_QuestLog.GetInfo, i)
                if ok and info and info.questID == questID then
                    title = title or info.title
                    level = level or (info.level and info.level > 0 and info.level)
                    isElite = isElite or info.isElite
                    isHeader = info.isHeader
                    break
                end
            elseif GetQuestLogTitle then
                local ok, t, lvl, tag, isH, _, _, _, qid = pcall(GetQuestLogTitle, i)
                if ok and (qid == questID or (not qid and t == title)) then
                    title = title or t
                    level = level or (lvl and lvl > 0 and lvl)
                    isElite = isElite or (tag == "Elite" or tag == ELITE)
                    isHeader = isH
                    break
                end
            end
        end
    end

    -- Scan NPC Gossip Available Quests for unaccepted quests
    if (not title or not level) and C_GossipInfo and C_GossipInfo.GetAvailableQuests then
        local ok, available = pcall(C_GossipInfo.GetAvailableQuests)
        if ok and type(available) == "table" then
            for _, q in ipairs(available) do
                if q.questID == questID then
                    title = title or q.title
                    if not level and q.questLevel and q.questLevel > 0 then
                        level = q.questLevel
                    end
                    break
                end
            end
        end
    end

    -- Scan QuestFrameGreetingPanel for unaccepted quests
    if (not level) and QuestFrameGreetingPanel and QuestFrameGreetingPanel:IsShown() and GetNumAvailableQuests and GetAvailableLevel and GetAvailableTitle then
        local numAvail = GetNumAvailableQuests() or 0
        for i = 1, numAvail do
            local availTitle = GetAvailableTitle(i)
            if title and availTitle == title then
                local availLvl = GetAvailableLevel(i)
                if availLvl and availLvl > 0 then
                    level = availLvl
                end
                break
            end
        end
    end

    local finalLevel = level
    if not finalLevel or finalLevel <= 0 then
        finalLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
    end

    return {
        questID = questID,
        title = title or ("Quest #" .. questID),
        level = finalLevel,
        isElite = isElite or false,
        isHeader = isHeader or false,
    }
end
