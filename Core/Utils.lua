--[[
    WorthIt / QuestWorth - Core/Utils.lua
    Utility functions, safe API callers (pcall), logging & formatting.
    Features a smooth, continuous Red-to-Green chromatic gradient for Worth scores.
]]

local addonName, addon = ...
addon.Utils = {}
local Utils = addon.Utils

-- =========================================================================
-- Dynamic Player Profile Manager (100% Dynamic for ANY Level 1-60, Class, Race, Faction)
-- Loaded early in Core/Utils.lua so all Data, Score, and Engine modules can safely access it.
-- =========================================================================
addon.Player = addon.Player or {}
local Player = addon.Player

function Player.Update()
    local okLvl, lvl = pcall(UnitLevel, "player")
    if okLvl and lvl and lvl > 0 then
        Player.level = lvl
    else
        Player.level = Player.level or 1
    end

    local okClass, locClass, engClass = pcall(UnitClass, "player")
    if okClass and (engClass or locClass) then
        Player.class = engClass or locClass
    else
        Player.class = Player.class or "WARRIOR"
    end

    local okRace, locRace, engRace = pcall(UnitRace, "player")
    if okRace and (engRace or locRace) then
        Player.race = engRace or locRace
    else
        Player.race = Player.race or "Human"
    end

    local okFaction, faction = pcall(UnitFactionGroup, "player")
    if okFaction and faction then
        Player.faction = faction
    else
        Player.faction = Player.faction or "Alliance"
    end

    local maxLvl = (GetMaxPlayerLevel and GetMaxPlayerLevel()) or (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion()) or 60
    Player.maxLevel = maxLvl
    Player.isMaxLevel = (Player.level >= maxLvl)
    return Player
end

function Player.GetLevel()
    if not Player.level or Player.level <= 0 then Player.Update() end
    return Player.level or 1
end

function Player.GetClass()
    if not Player.class then Player.Update() end
    return Player.class or "WARRIOR"
end

function Player.GetRace()
    if not Player.race then Player.Update() end
    return Player.race or "Human"
end

function Player.GetFaction()
    if not Player.faction then Player.Update() end
    return Player.faction or "Alliance"
end

-- Initialize player profile immediately upon loading Core/Utils.lua
Player.Update()

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

    if C_QuestLog and C_QuestLog.IsOnQuest then
        local okOn, isOn = pcall(C_QuestLog.IsOnQuest, questID)
        if okOn and not isOn then
            return nil
        end
    elseif GetQuestLogIndexByID then
        local okIdx, idx = pcall(GetQuestLogIndexByID, questID)
        if okIdx and (not idx or idx <= 0) then
            return nil
        end
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
local _iicSize = 0

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

    if _iicSize >= 200 then
        wipe(_iic)
        _iicSize = 0
    end

    _iic[item] = {
        name, link, quality, itemLevel, minLevel, itemType, itemSubType,
        maxStack, equipLoc, icon, sellPrice, classID, subClassID,
        bindType, expansionID, setID, isCraftingReagent
    }
    _iicSize = _iicSize + 1
    return name, link, quality, itemLevel, minLevel, itemType, itemSubType,
           maxStack, equipLoc, icon, sellPrice, classID, subClassID,
           bindType, expansionID, setID, isCraftingReagent
end
addon.SafeGetItemInfo = Utils.SafeGetItemInfo

function addon.ClearSafeGetItemInfoCache()
    wipe(_iic)
    _iicSize = 0
end

-- Validate that a questID is a finite positive number (guards against nil, NaN, inf, strings, tables)
function Utils.IsValidQuestID(id)
    return type(id) == "number" and id == id and id > 0 and id < math.huge
end

-- Persistent quest rewards cache (item links & vendor values)
local _questRewardsCache = {}

function Utils.GetQuestRewardData(questID)
    if not Utils.IsValidQuestID(questID) then
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
    if #choices == 0 and #rewards == 0 and QuestFrame and QuestFrame:IsShown() then
        local matchesOffer = false
        if GetQuestID then
            local okID, cID = pcall(GetQuestID)
            if okID and cID and cID == questID then
                matchesOffer = true
            end
        end
        if not matchesOffer and GetTitleText then
            local qTitle = Utils.GetQuestTitle and Utils.GetQuestTitle(questID)
            local offerTitle = GetTitleText()
            if qTitle and offerTitle and qTitle == offerTitle then
                matchesOffer = true
            end
        end
        if matchesOffer then
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
    if type(title) ~= "string" or title == "" then return "" end
    if not string.find(title, "[|%[\r\n]") then
        return title
    end
    local cleaned = string.gsub(title, "[\r\n].*$", "")
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
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffWorthIt:|r " .. tostring(msg))
    elseif print then
        print("|cff00ccffWorthIt:|r " .. tostring(msg))
    end
end

function addon.Debug(msg, ...)
    if not (addon.db and addon.db.debug) then return end
    if select("#", ...) > 0 then
        msg = string.format(msg, ...)
    end
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff888888[WorthIt Debug]|r " .. tostring(msg))
    elseif print then
        print("|cff888888[WorthIt Debug]|r " .. tostring(msg))
    end
end

-- Normalize 5 weights (Difficulty, Reward, Chain, ClassFit, Density) to sum to 1.0
function Utils.NormalizeWeights(wD, wR, wC, wF, wH)
    local isZeroDiff = (wD ~= nil and tonumber(wD) or 0.00) <= 0.001
    local d = isZeroDiff and 0.00 or math.max(0, tonumber(wD) or 0.00)
    local r = math.max(0, (wR ~= nil and tonumber(wR)) or 0.40)
    local c = math.max(0, (wC ~= nil and tonumber(wC)) or 0.25)
    local f = math.max(0, (wF ~= nil and tonumber(wF)) or 0.25)
    local h = math.max(0, (wH ~= nil and tonumber(wH)) or 0.10)

    local sum = d + r + c + f + h
    if sum <= 0 then
        if isZeroDiff then
            return 0.00, 0.40, 0.25, 0.25, 0.10
        end
        return 0.00, 0.40, 0.25, 0.25, 0.10
    end
    return isZeroDiff and 0.00 or (d / sum), r / sum, c / sum, f / sum, h / sum
end

-- Safe Quest Title/Level getter across Modern C_QuestLog, Gossip NPCs, and Legacy APIs (memoized)
local _basicInfoCache = {}
local _basicInfoCacheSize = 0

function Utils.GetQuestBasicInfo(questID)
    if not Utils.IsValidQuestID(questID) then return nil end

    if _basicInfoCache[questID] then
        local entry = _basicInfoCache[questID]
        if entry.title and not string.find(entry.title, "^Quest #") then
            return entry
        end
    end

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

    -- Scan active QuestFrame offer dialog for unaccepted quest title
    if (not title) and QuestFrame and QuestFrame:IsShown() and GetTitleText then
        local okID, cID = pcall(GetQuestID)
        if (okID and cID and cID == questID) or (not cID or cID == 0) then
            local okT, t = pcall(GetTitleText)
            if okT and t and t ~= "" then
                title = t
            end
        end
    end

    local finalLevel = level
    if not finalLevel or finalLevel <= 0 then
        finalLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
    end

    local res = {
        questID = questID,
        title = title or ("Quest #" .. questID),
        level = finalLevel,
        isElite = isElite or false,
        isHeader = isHeader or false,
    }

    if _basicInfoCacheSize >= 500 then
        wipe(_basicInfoCache)
        _basicInfoCacheSize = 0
    end
    _basicInfoCache[questID] = res
    _basicInfoCacheSize = _basicInfoCacheSize + 1
    return res
end

function Utils.GetQuestTitle(questID)
    local info = Utils.GetQuestBasicInfo(questID)
    return info and info.title or nil
end

function Utils.GetQuestLevel(questID)
    local info = Utils.GetQuestBasicInfo(questID)
    return info and info.level or nil
end

function Utils.ClearQuestBasicInfoCache(questID)
    if questID then
        _basicInfoCache[questID] = nil
    else
        wipe(_basicInfoCache)
        _basicInfoCacheSize = 0
    end
end
addon.ClearQuestBasicInfoCache = Utils.ClearQuestBasicInfoCache

-- =========================================================================
-- Talk-To / Courier / Discovery / Breadcrumb Quest Detection
-- Identifies non-combat quests (e.g. "Speak with ...", "Deliver ... to ...")
-- so they are NEVER penalized as high-level combat / orange / red / elite.
-- =========================================================================
local _talkToCache = {}

local function MatchesExplicitTalkToPhrase(lower)
    return (
        string.find(lower, "speak with") or
        string.find(lower, "speak to") or
        string.find(lower, "talk to") or
        string.find(lower, "talk with") or
        string.find(lower, "deliver ") or
        string.find(lower, "report to") or
        string.find(lower, "return to") or
        string.find(lower, "take .- to ") or
        string.find(lower, "give .- to ") or
        string.find(lower, "bring .- to ") or
        string.find(lower, "hand .- to ") or
        string.find(lower, "present .- to ") or
        string.find(lower, "show .- to ") or
        string.find(lower, "ask .- about") or
        string.find(lower, "consult ") or
        string.find(lower, "confer with") or
        string.find(lower, "check in with") or
        string.find(lower, "meet with ") or
        string.find(lower, "inform ") or
        string.find(lower, "μιλήστε με") or
        string.find(lower, "μίλησε με") or
        string.find(lower, "παραδώστε") or
        string.find(lower, "αναφέρετε") or
        string.find(lower, "επιστρέψτε")
    ) ~= nil
end

local function MatchesTalkToPhrase(lower)
    if MatchesExplicitTalkToPhrase(lower) then
        return true
    end
    return (
        string.find(lower, "seek out ") or
        string.find(lower, "locate ") or
        string.find(lower, "find ") or
        string.find(lower, "meet ") or
        string.find(lower, "travel to") or
        string.find(lower, "go to ") or
        string.find(lower, "visit ")
    ) ~= nil
end

local EXPLORATION_HAZARD_WORDS = {
    "island", "haunted", "camp", "cave", "mine", "ruins", "stronghold",
    "den", "lair", "tomb", "crypt", "cemetery", "graveyard", "wreck",
    "barrow", "oasis", "fissure", "altar", "shrine", "monument",
    "chest", "crate", "barrel",
}

local function HasExplorationOrHazardTarget(lower)
    local padded = " " .. (lower or "") .. " "
    for _, word in ipairs(EXPLORATION_HAZARD_WORDS) do
        if string.find(padded, "[^%a]" .. word .. "s?[^%a]") then
            return true
        end
    end
    return false
end

local function HasCombatOrMultiObjective(text)
    local lower = string.lower(text or "")
    if string.find(lower, "slain") or string.find(lower, "kill") or
       string.find(lower, "defeat") or string.find(lower, "destroy") or
       string.find(lower, "collect") or string.find(lower, "gather") or
       string.find(lower, "loot") or string.find(lower, "mine") or
       string.find(lower, "fish") or string.find(lower, "steal") or
       string.find(lower, "obtain") or string.find(lower, "recover") or
       string.find(lower, "acquire") or string.find(lower, "retrieve") or
       string.find(lower, "capture") or string.find(lower, "use ") or
       string.find(lower, "σκοτώστε") or string.find(lower, "νικήστε") or
       string.find(lower, "συλλέξτε") or string.find(lower, "μαζέψτε") then
        return true
    end
    local _, maxCount = string.match(lower, "(%d+)%s*/%s*(%d+)")
    if maxCount and tonumber(maxCount) then
        if tonumber(maxCount) > 1 or not MatchesTalkToPhrase(lower) then
            return true
        end
    end
    return false
end

function Utils.IsTalkToQuest(questID)
    if not Utils.IsValidQuestID(questID) then return false end
    if _talkToCache[questID] ~= nil then
        return _talkToCache[questID]
    end

    -- 1. Metadata check in Data.QuestPayoffs
    if addon.Data and addon.Data.QuestPayoffs and addon.Data.QuestPayoffs[questID] then
        local p = addon.Data.QuestPayoffs[questID]
        if p.isTalkTo == true or p.isCourier == true or p.isDiscovery == true then
            _talkToCache[questID] = true
            return true
        end
    end

    -- 2. Title check in Data.QuestPayoffsByTitle
    local basicInfo = Utils.GetQuestBasicInfo(questID)
    local title = basicInfo and basicInfo.title
    if title and addon.Data and addon.Data.QuestPayoffsByTitle then
        local cleanTitle = Utils.CleanQuestTitle and Utils.CleanQuestTitle(title) or title
        cleanTitle = string.gsub(cleanTitle, "^%s*%[%d+%]%s*", "")
        local lowerTitle = string.lower(string.gsub(cleanTitle, "^%s*(.-)%s*$", "%1"))
        local p = addon.Data.QuestPayoffsByTitle[lowerTitle]
        if p and (p.isTalkTo == true or p.isCourier == true or p.isDiscovery == true) then
            _talkToCache[questID] = true
            return true
        end
    end

    -- 3. Live Objective Text Inspection
    local objectiveTexts = {}
    local offerDescription = nil
    local matchesOffer = false

    local isOnQuest = true
    if C_QuestLog and C_QuestLog.IsOnQuest then
        local okOn, onQ = pcall(C_QuestLog.IsOnQuest, questID)
        if okOn then isOnQuest = onQ end
    end

    -- Priority 3A: Check QuestFrame FIRST when viewing an offer/detail dialog (prevents QuestLog bleed!)
    if QuestFrame and QuestFrame:IsShown() then
        if GetQuestID then
            local okID, cID = pcall(GetQuestID)
            if okID and cID and cID == questID then matchesOffer = true end
        end
        if not matchesOffer and QuestFrame.questID and QuestFrame.questID == questID then
            matchesOffer = true
        end
        if not matchesOffer and title and GetTitleText then
            local frameTitle = GetTitleText()
            if frameTitle and Utils.CleanQuestTitle(frameTitle) == Utils.CleanQuestTitle(title) then
                matchesOffer = true
            end
        end
        if matchesOffer then
            if GetObjectiveText then
                local okObj, txt = pcall(GetObjectiveText)
                if okObj and txt and txt ~= "" then
                    table.insert(objectiveTexts, txt)
                end
            end
            if #objectiveTexts == 0 and QuestInfoObjectivesText and QuestInfoObjectivesText.GetText then
                local txt = QuestInfoObjectivesText:GetText()
                if txt and txt ~= "" then
                    table.insert(objectiveTexts, txt)
                end
            end
            if GetQuestText then
                local okDesc, desc = pcall(GetQuestText)
                if okDesc and desc and desc ~= "" then
                    offerDescription = desc
                end
            end
            if (not offerDescription or offerDescription == "") and QuestInfoDescriptionText and QuestInfoDescriptionText.GetText then
                local desc = QuestInfoDescriptionText:GetText()
                if desc and desc ~= "" then
                    offerDescription = desc
                end
            end
        end
    end

    -- Priority 3B: Check modern C_QuestLog objectives
    if #objectiveTexts == 0 and C_QuestLog and C_QuestLog.GetQuestObjectives then
        local okObjs, objs = pcall(C_QuestLog.GetQuestObjectives, questID)
        if okObjs and type(objs) == "table" and #objs > 0 then
            for _, obj in ipairs(objs) do
                if obj and obj.text then
                    table.insert(objectiveTexts, obj.text)
                end
            end
        end
    end

    -- Priority 3C: Check active QuestLog leaderboards ONLY when quest is actually in the Quest Log
    if #objectiveTexts == 0 and isOnQuest and GetNumQuestLeaderBoards and GetQuestLogLeaderBoard then
        Utils.WithSelectedQuest(questID, function()
            local numLB = GetNumQuestLeaderBoards() or 0
            for i = 1, numLB do
                local desc = GetQuestLogLeaderBoard(i)
                if desc and desc ~= "" then
                    table.insert(objectiveTexts, desc)
                end
            end
        end)
    end

    -- Fallback: If QuestFrame offered a description but no objective text, analyze description
    if #objectiveTexts == 0 and offerDescription and offerDescription ~= "" then
        table.insert(objectiveTexts, offerDescription)
    end

    -- Analyze the gathered objective texts:
    if #objectiveTexts > 0 then
        -- Talk-to / courier quests typically have 1 (rarely 2) simple instructions
        if #objectiveTexts <= 2 then
            local pLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
            local qLevel = (basicInfo and basicInfo.level and basicInfo.level > 0) and basicInfo.level or pLevel
            local delta = qLevel - pLevel
            local phraseMatcher = (delta >= 3) and MatchesExplicitTalkToPhrase or MatchesTalkToPhrase

            local allTalkTo = true
            local hasPositivePhrase = false
            for _, text in ipairs(objectiveTexts) do
                local lowerText = string.lower(text)
                if HasCombatOrMultiObjective(text) or HasExplorationOrHazardTarget(lowerText) then
                    allTalkTo = false
                    break
                end
                if phraseMatcher(lowerText) then
                    hasPositivePhrase = true
                end
            end

            if allTalkTo and not hasPositivePhrase and offerDescription and offerDescription ~= "" then
                if phraseMatcher(string.lower(offerDescription)) then
                    hasPositivePhrase = true
                end
            end

            -- Breadcrumb XP fallback: Non-combat single objective at player level giving pure delivery XP (<= 3.6x mobXP)
            if allTalkTo and not hasPositivePhrase then
                local liveXP = 0
                if matchesOffer and GetRewardXP then
                    local okXP, val = pcall(GetRewardXP)
                    if okXP and val and val > 0 then liveXP = val end
                end
                if liveXP == 0 and C_QuestLog and C_QuestLog.GetQuestRewardXP then
                    local okXP, val = pcall(C_QuestLog.GetQuestRewardXP, questID)
                    if okXP and val and val > 0 then liveXP = val end
                end
                local mobXP = math.max(50, (pLevel * 5) + 45)
                if delta >= -3 and liveXP > 0 and liveXP <= (mobXP * 3.6) then
                    hasPositivePhrase = true
                end
            end

            if allTalkTo and hasPositivePhrase then
                _talkToCache[questID] = true
                return true
            end
        end
        _talkToCache[questID] = false
    end

    return false
end

function Utils.ClearTalkToCache(questID)
    if questID then
        _talkToCache[questID] = nil
    else
        wipe(_talkToCache)
    end
end
addon.ClearTalkToCache = Utils.ClearTalkToCache
