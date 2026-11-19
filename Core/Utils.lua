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

function Player.Update(forcedLevel)
    local okLvl, lvl
    if UnitLevel then okLvl, lvl = pcall(UnitLevel, "player") end
    local liveLvl = (okLvl and type(lvl) == "number" and lvl > 0) and lvl or nil
    if type(forcedLevel) == "number" and forcedLevel > 0 then
        Player._pendingMinLevel = forcedLevel
        Player.level = math.max(liveLvl or 0, forcedLevel)
    elseif liveLvl then
        if Player._pendingMinLevel and liveLvl == (Player._pendingMinLevel - 1) then
            Player.level = Player._pendingMinLevel
        else
            Player._pendingMinLevel = nil
            Player.level = liveLvl
        end
    else
        Player.level = Player.level or 1
    end

    local okClass, locClass, engClass
    if UnitClass then okClass, locClass, engClass = pcall(UnitClass, "player") end
    if okClass and (engClass or locClass) then
        Player.class = engClass or locClass
    else
        Player.class = Player.class or "WARRIOR"
    end

    local okRace, locRace, engRace
    if UnitRace then okRace, locRace, engRace = pcall(UnitRace, "player") end
    if okRace and (engRace or locRace) then
        Player.race = engRace or locRace
    else
        Player.race = Player.race or "Human"
    end

    local okFaction, faction
    if UnitFactionGroup then okFaction, faction = pcall(UnitFactionGroup, "player") end
    if okFaction and faction and faction ~= "Neutral" and faction ~= "" then
        Player.faction = faction
    elseif okFaction and faction and not Player.faction then
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
    if type(UnitLevel) == "function" then
        local lvl = UnitLevel("player")
        if type(lvl) == "number" and lvl > 0 then
            if Player._pendingMinLevel and lvl >= Player._pendingMinLevel then
                Player._pendingMinLevel = nil
            end
            if not (Player._pendingMinLevel and lvl < Player._pendingMinLevel) and lvl ~= Player.level then
                Player.Update()
            end
        end
    end
    if not Player.level or Player.level <= 0 then Player.Update() end
    return Player.level or 1
end

function Player.GetClass()
    if type(UnitClass) == "function" then
        local locC, engC = UnitClass("player")
        local liveC = engC or locC
        if liveC and liveC ~= Player.class then
            Player.Update()
        end
    end
    if not Player.class then Player.Update() end
    return Player.class or "WARRIOR"
end

function Player.GetRace()
    if type(UnitRace) == "function" then
        local locR, engR = UnitRace("player")
        local liveR = engR or locR
        if liveR and liveR ~= Player.race then
            Player.Update()
        end
    end
    if not Player.race then Player.Update() end
    return Player.race or "Human"
end

function Player.GetFaction()
    if type(UnitFactionGroup) == "function" then
        local fac = UnitFactionGroup("player")
        if fac and fac ~= "Neutral" and fac ~= "" and fac ~= Player.faction then
            Player.Update()
        end
    end
    if not Player.faction then Player.Update() end
    return Player.faction or "Alliance"
end

function Player.GetCharacterKey()
    if type(UnitName) ~= "function" then return "Default" end
    local name = UnitName("player")
    if type(name) ~= "string" or name == "" or name == "Unknown" then
        return "Default"
    end
    local realm = (type(GetRealmName) == "function" and GetRealmName()) or nil
    realm = (type(realm) == "string" and realm ~= "") and realm or "DefaultRealm"
    if name == Player._cachedUnitName and realm == Player._cachedRealmName and Player._cachedCharKey then
        return Player._cachedCharKey
    end
    Player._cachedUnitName = name
    Player._cachedRealmName = realm
    Player._cachedCharKey = name .. "-" .. realm
    return Player._cachedCharKey
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

-- Resolve the Quest Log index for a questID across modern & legacy APIs (O(1) cached per log snapshot)
local _questLogIndexMap = {}
local _questLogIndexScanned = false
local _questLogIndexLastCount = -1

function Utils.GetQuestLogIndex(questID)
    if not questID or type(questID) ~= "number" or questID <= 0 or questID ~= questID then return nil end
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local okIdx, idx = pcall(C_QuestLog.GetLogIndexForQuestID, questID)
        if okIdx and type(idx) == "number" and idx > 0 then
            _questLogIndexMap[questID] = idx
            return idx
        end
    end
    if GetQuestLogIndexByID then
        local okIdx, idx = pcall(GetQuestLogIndexByID, questID)
        if okIdx and type(idx) == "number" and idx > 0 then
            _questLogIndexMap[questID] = idx
            return idx
        end
    end
    local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                       or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
    if _questLogIndexScanned and numEntries == _questLogIndexLastCount then
        local cachedIdx = _questLogIndexMap[questID]
        if cachedIdx then
            if C_QuestLog and C_QuestLog.GetInfo then
                local ok, info = pcall(C_QuestLog.GetInfo, cachedIdx)
                if ok and info and not info.isHeader and info.questID == questID then
                    return cachedIdx
                end
            elseif GetQuestLogTitle then
                local ok, _, _, _, isH, _, _, _, qid = pcall(GetQuestLogTitle, cachedIdx)
                if ok and not isH and qid == questID then
                    return cachedIdx
                end
            end
            _questLogIndexScanned = false
        else
            return nil
        end
    end

    wipe(_questLogIndexMap)
    _questLogIndexScanned = true
    _questLogIndexLastCount = numEntries
    for i = 1, numEntries do
        if C_QuestLog and C_QuestLog.GetInfo then
            local ok, info = pcall(C_QuestLog.GetInfo, i)
            if ok and info and not info.isHeader and info.questID and info.questID > 0 then
                _questLogIndexMap[info.questID] = i
            end
        elseif GetQuestLogTitle then
            local ok, _, _, _, isH, _, _, _, qid = pcall(GetQuestLogTitle, i)
            if ok and not isH and qid and qid > 0 then
                _questLogIndexMap[qid] = i
            end
        end
    end
    return _questLogIndexMap[questID]
end

-- Check whether a questID is currently present in the player's Quest Log
function Utils.IsQuestInLog(questID)
    if not questID or type(questID) ~= "number" or questID <= 0 or questID ~= questID then return false end
    if C_QuestLog and C_QuestLog.IsOnQuest then
        local ok, on = pcall(C_QuestLog.IsOnQuest, questID)
        if ok and on then return true end
    end
    return Utils.GetQuestLogIndex(questID) ~= nil
end

-- Check whether an active quest in the player's Quest Log is ready for turn-in
function Utils.IsQuestComplete(questID)
    if not questID or type(questID) ~= "number" or questID <= 0 or questID ~= questID then return false end
    if C_QuestLog and C_QuestLog.IsComplete then
        local ok, comp = pcall(C_QuestLog.IsComplete, questID)
        if ok and comp == true then return true end
    end
    local idx = Utils.GetQuestLogIndex(questID)
    if not idx then return false end
    if C_QuestLog and C_QuestLog.GetInfo then
        local ok, info = pcall(C_QuestLog.GetInfo, idx)
        if ok and info and info.isComplete then return true end
    elseif GetQuestLogTitle then
        local ok, _, _, _, _, _, isComp = pcall(GetQuestLogTitle, idx)
        if ok and isComp and isComp ~= 0 then return true end
    end
    return false
end

-- Collect all active quest IDs currently in the player's Quest Log
function Utils.GetActiveQuestIDs()
    local ids = {}
    local seen = {}
    local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
                       or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
    for i = 1, numEntries do
        local isH, qid = nil, nil
        if C_QuestLog and C_QuestLog.GetInfo then
            local ok, info = pcall(C_QuestLog.GetInfo, i)
            if ok and info then isH = info.isHeader; qid = info.questID end
        elseif GetQuestLogTitle then
            local ok, _, _, _, h, _, _, _, id = pcall(GetQuestLogTitle, i)
            if ok then isH = h; qid = id end
        end
        if not isH and qid and type(qid) == "number" and qid > 0 and not seen[qid] then
            seen[qid] = true
            table.insert(ids, qid)
        end
    end
    return ids
end

-- Helper: Check if questID corresponds to the currently open NPC QuestFrame offer/turn-in dialog
function Utils.IsActiveOfferQuest(questID, titleHint)
    if not questID or type(questID) ~= "number" or questID <= 0 then return false end
    if not (QuestFrame and QuestFrame:IsShown()) then return false end
    if (QuestFrameGreetingPanel and QuestFrameGreetingPanel:IsShown()) or (QuestFrameProgressPanel and QuestFrameProgressPanel:IsShown()) then return false end

    if addon._activeOfferQuestID and addon._activeOfferQuestID == questID then
        return true
    end
    if GetQuestID then
        local okID, cID = pcall(GetQuestID)
        if okID and cID and cID == questID then
            return true
        end
    end
    if QuestFrame.questID and QuestFrame.questID == questID then
        return true
    end
    if QuestFrameDetailPanel and QuestFrameDetailPanel.questID and QuestFrameDetailPanel.questID == questID then
        return true
    end
    if GetTitleText then
        local okT, offerTitle = pcall(GetTitleText)
        if okT and type(offerTitle) == "string" and offerTitle ~= "" then
            local cleanOffer = Utils.CleanQuestTitle(offerTitle)
            cleanOffer = string.gsub(cleanOffer, "^%s*%[%d+%+?%]%s*", "")
            local candidate = titleHint
            if not candidate or candidate == "" then
                if C_QuestLog and C_QuestLog.GetTitleForQuestID then
                    local okQT, qt = pcall(C_QuestLog.GetTitleForQuestID, questID)
                    if okQT and qt and qt ~= "" then candidate = qt end
                end
            end
            if candidate and candidate ~= "" then
                local cleanCand = Utils.CleanQuestTitle(candidate)
                cleanCand = string.gsub(cleanCand, "^%s*%[%d+%+?%]%s*", "")
                if cleanOffer ~= "" and (cleanOffer == cleanCand or string.lower(cleanOffer) == string.lower(cleanCand)) then
                    return true
                end
            end
        end
    end
    return false
end

-- Helper: Temporarily selects questID so legacy/hybrid functions
-- (GetQuestLogItemLink, GetQuestLogRewardXP, GetQuestLogRewardMoney) read the right quest.
-- CRITICAL SAFETY: Never change C_QuestLog.SetSelectedQuest if the QuestMap is open,
-- and NEVER run callback against the wrong currently-selected quest!
function Utils.WithSelectedQuest(questID, callback)
    if not questID or questID <= 0 then
        return callback()
    end

    local idx = Utils.GetQuestLogIndex(questID)
    if not idx then
        if C_QuestLog and C_QuestLog.IsOnQuest then
            local okOn, isOn = pcall(C_QuestLog.IsOnQuest, questID)
            if not (okOn and isOn) then
                return nil
            end
        else
            return nil
        end
    end

    local currID = C_QuestLog and C_QuestLog.GetSelectedQuest and C_QuestLog.GetSelectedQuest()
    local currIdx = GetQuestLogSelection and GetQuestLogSelection()
    local idMatches = (currID and currID > 0) and (currID == questID)
    local idxMatches = (idx and currIdx and currIdx > 0) and (currIdx == idx)
    local idSynced = (not currID or currID <= 0 or currID == questID)
    local idxSynced = (not idx or not currIdx or currIdx <= 0 or currIdx == idx)
    if (idMatches or idxMatches) and idSynced and idxSynced then
        return callback()
    end

    -- If the map, quest details, or quest log is currently open, DO NOT alter selection or read the wrong quest
    local mapShown = (QuestMapFrame and QuestMapFrame:IsShown())
        or (WorldMapFrame and WorldMapFrame:IsShown())
        or (QuestLogFrame and QuestLogFrame.IsShown and QuestLogFrame:IsShown())
    if mapShown then
        return nil
    end

    local prevSelectedQuestID = currID
    local prevIndex = currIdx
    local changed = false
    addon._isInternalQuestSelection = true

    if C_QuestLog and C_QuestLog.SetSelectedQuest then
        local okSel = pcall(C_QuestLog.SetSelectedQuest, questID)
        if okSel then changed = true end
    end
    if SelectQuestLogEntry and idx and idx > 0 and idx ~= prevIndex then
        local okSel = pcall(SelectQuestLogEntry, idx)
        if okSel then changed = true end
    end

    local okCall, res1, res2, res3 = pcall(callback)

    if changed then
        if prevIndex and prevIndex > 0 and SelectQuestLogEntry then
            pcall(SelectQuestLogEntry, prevIndex)
        end
        if prevSelectedQuestID and prevSelectedQuestID > 0 and C_QuestLog and C_QuestLog.SetSelectedQuest then
            pcall(C_QuestLog.SetSelectedQuest, prevSelectedQuestID)
        end
    end
    addon._isInternalQuestSelection = false

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

local function ResolveRewardItemLink(kind, index, questID)
    local link = nil
    local unresolvedItemID = nil
    local count = nil

    local infoFunc = (kind == "choice") and GetQuestLogChoiceInfo or GetQuestLogRewardInfo
    if infoFunc then
        local okI, r1, _, r3 = pcall(infoFunc, index, questID)
        if okI then
            local q = (type(r1) == "table" and r1.quantity) or (type(r3) == "number" and r3)
            if type(q) == "number" and q > 0 then count = q end
        end
    end

    if C_QuestLog and C_QuestLog.GetQuestRewardItemLink then
        local ok, l = pcall(C_QuestLog.GetQuestRewardItemLink, index, questID)
        if ok and l then link = l end
        if not link then
            local ok2, l2 = pcall(C_QuestLog.GetQuestRewardItemLink, questID, index)
            if ok2 and l2 then link = l2 end
        end
    end

    if not link and GetQuestLogItemLink then
        local ok, l = pcall(GetQuestLogItemLink, kind, index, questID)
        if ok and l then link = l end
    end

    local slotUnresolved = false

    if not link then
        if infoFunc then
            local ok, r1, _, r3, _, _, r6 = pcall(infoFunc, index, questID)
            if ok then
                local q = (type(r1) == "table" and r1.quantity) or (type(r3) == "number" and r3)
                if type(q) == "number" and q > 0 then count = q end
                local itemID = (type(r1) == "table" and r1.itemID) or (type(r6) == "number" and r6) or (type(r1) == "number" and r1)
                if type(itemID) == "number" and itemID > 0 then
                    link = select(2, addon.SafeGetItemInfo(itemID))
                    if not link then
                        unresolvedItemID = itemID
                        if C_Item and C_Item.RequestLoadItemDataByID then
                            pcall(C_Item.RequestLoadItemDataByID, itemID)
                        end
                        link = "item:" .. itemID
                    end
                elseif r1 == nil then
                    slotUnresolved = true
                end
            end
        end
    end

    if not link and C_QuestLog and C_QuestLog.GetQuestLogRewardInfo then
        local ok, info = pcall(C_QuestLog.GetQuestLogRewardInfo, index, questID)
        if ok and type(info) == "table" and type(info.quantity) == "number" and info.quantity > 0 then
            count = count or info.quantity
        end
        local itemID = (type(info) == "table" and info.itemID) or (type(info) == "number" and info)
        if ok and type(itemID) == "number" and itemID > 0 then
            link = select(2, addon.SafeGetItemInfo(itemID))
            if not link then
                unresolvedItemID = itemID
                if C_Item and C_Item.RequestLoadItemDataByID then
                    pcall(C_Item.RequestLoadItemDataByID, itemID)
                end
                link = "item:" .. itemID
            end
        elseif ok and info == nil then
            slotUnresolved = true
        end
    end

    return link, (unresolvedItemID ~= nil) or slotUnresolved, count or 1
end

local function ResolveOfferRewardItem(kind, idx)
    local link = GetQuestItemLink and GetQuestItemLink(kind, idx)
    local count = 1
    local unresolved = false
    if GetQuestItemInfo then
        local ok, itemName, _, numItems, _, _, itemID = pcall(GetQuestItemInfo, kind, idx)
        if ok then
            if type(numItems) == "number" and numItems > 0 then
                count = numItems
            end
            if not link then
                if type(itemID) == "number" and itemID > 0 then
                    local cachedLink = select(2, addon.SafeGetItemInfo(itemID))
                    if cachedLink then
                        link = cachedLink
                    else
                        if C_Item and C_Item.RequestLoadItemDataByID then
                            pcall(C_Item.RequestLoadItemDataByID, itemID)
                        end
                        link = "item:" .. itemID
                        unresolved = true
                    end
                elseif itemName == nil then
                    unresolved = true
                end
            end
        end
    end
    return link, unresolved, count
end

function Utils.GetQuestRewardData(questID)
    if not Utils.IsValidQuestID(questID) then
        return {}, {}, 0, 0, false
    end

    if _questRewardsCache[questID] then
        local c = _questRewardsCache[questID]
        return c.choices, c.rewards, c.maxChoicePrice, c.fixedPricesSum, false
    end

    local choices = {}
    local choiceCounts = {}
    local rewards = {}
    local maxChoicePrice = 0
    local fixedPricesSum = 0
    local anyUncachedItem = false

    -- 1. Direct questID resolution across Modern C_QuestLog & Hybrid Classic globals (independent of Quest Log focus!)
    local numChoices = 0
    if C_QuestLog and C_QuestLog.GetNumQuestLogChoices then
        local ok, n = pcall(C_QuestLog.GetNumQuestLogChoices, questID)
        if ok and type(n) == "number" and n > 0 then numChoices = n end
    end
    if numChoices == 0 and GetNumQuestLogChoices then
        local ok, n = pcall(GetNumQuestLogChoices, questID)
        if ok and type(n) == "number" and n > 0 then numChoices = n end
    end
    for i = 1, numChoices do
        local link, uncached, qty = ResolveRewardItemLink("choice", i, questID)
        if uncached then anyUncachedItem = true end
        if link then
            table.insert(choices, link)
            table.insert(choiceCounts, qty or 1)
            local itemName, _, _, _, _, _, _, _, _, _, sellPrice = addon.SafeGetItemInfo(link)
            if not itemName then
                anyUncachedItem = true
            end
            local totalSell = (sellPrice or 0) * (qty or 1)
            if totalSell > maxChoicePrice then
                maxChoicePrice = totalSell
            end
        end
    end

    local numRewards = 0
    if C_QuestLog and C_QuestLog.GetNumQuestLogRewards then
        local ok, n = pcall(C_QuestLog.GetNumQuestLogRewards, questID)
        if ok and type(n) == "number" and n > 0 then numRewards = n end
    end
    if numRewards == 0 and GetNumQuestLogRewards then
        local ok, n = pcall(GetNumQuestLogRewards, questID)
        if ok and type(n) == "number" and n > 0 then numRewards = n end
    end
    for i = 1, numRewards do
        local link, uncached, qty = ResolveRewardItemLink("reward", i, questID)
        if uncached then anyUncachedItem = true end
        if link then
            table.insert(rewards, link)
            local itemName, _, _, _, _, _, _, _, _, _, sellPrice = addon.SafeGetItemInfo(link)
            if not itemName then
                anyUncachedItem = true
            end
            fixedPricesSum = fixedPricesSum + ((sellPrice or 0) * (qty or 1))
        end
    end

    -- 2. Live QuestFrame dialog offer rewards (for unaccepted quests currently shown by NPC)
    if #choices == 0 and #rewards == 0 and Utils.IsActiveOfferQuest(questID) then
        local numOfferChoices = (GetNumQuestChoices and GetNumQuestChoices()) or 0
        for i = 1, numOfferChoices do
            local link, uncached, qty = ResolveOfferRewardItem("choice", i)
            if uncached then anyUncachedItem = true end
            if link then
                table.insert(choices, link)
                table.insert(choiceCounts, qty or 1)
                local itemName, _, _, _, _, _, _, _, _, _, sellPrice = addon.SafeGetItemInfo(link)
                if not itemName then
                    anyUncachedItem = true
                end
                local totalSell = (sellPrice or 0) * (qty or 1)
                if totalSell > maxChoicePrice then maxChoicePrice = totalSell end
            end
        end
        local numOfferRewards = (GetNumQuestRewards and GetNumQuestRewards()) or 0
        for i = 1, numOfferRewards do
            local link, uncached, qty = ResolveOfferRewardItem("reward", i)
            if uncached then anyUncachedItem = true end
            if link then
                table.insert(rewards, link)
                local itemName, _, _, _, _, _, _, _, _, _, sellPrice = addon.SafeGetItemInfo(link)
                if not itemName then
                    anyUncachedItem = true
                end
                fixedPricesSum = fixedPricesSum + ((sellPrice or 0) * (qty or 1))
            end
        end
    end

    -- 3. Last-resort fallback: temporarily select questID when map is closed
    if #choices == 0 and #rewards == 0 and not anyUncachedItem then
        Utils.WithSelectedQuest(questID, function()
            local nC = (GetNumQuestLogChoices and GetNumQuestLogChoices(questID)) or 0
            for i = 1, nC do
                local link = GetQuestLogItemLink and GetQuestLogItemLink("choice", i)
                local qty = 1
                local uncached = false
                if GetQuestLogChoiceInfo then
                    local okQ, r1, _, r3 = pcall(GetQuestLogChoiceInfo, i)
                    if okQ then
                        local q = (type(r1) == "table" and r1.quantity) or (type(r3) == "number" and r3)
                        if type(q) == "number" and q > 0 then qty = q end
                    end
                end
                if not link then
                    link, uncached, qty = ResolveRewardItemLink("choice", i, questID)
                end
                if uncached then anyUncachedItem = true end
                if link then
                    table.insert(choices, link)
                    table.insert(choiceCounts, qty or 1)
                    local itemName, _, _, _, _, _, _, _, _, _, sellPrice = addon.SafeGetItemInfo(link)
                    if not itemName then
                        anyUncachedItem = true
                    end
                    local totalSell = (sellPrice or 0) * (qty or 1)
                    if totalSell > maxChoicePrice then maxChoicePrice = totalSell end
                end
            end
            local nR = (GetNumQuestLogRewards and GetNumQuestLogRewards(questID)) or 0
            for i = 1, nR do
                local link = GetQuestLogItemLink and GetQuestLogItemLink("reward", i)
                local qty = 1
                local uncached = false
                if GetQuestLogRewardInfo then
                    local okQ, r1, _, r3 = pcall(GetQuestLogRewardInfo, i)
                    if okQ then
                        local q = (type(r1) == "table" and r1.quantity) or (type(r3) == "number" and r3)
                        if type(q) == "number" and q > 0 then qty = q end
                    end
                end
                if not link then
                    link, uncached, qty = ResolveRewardItemLink("reward", i, questID)
                end
                if uncached then anyUncachedItem = true end
                if link then
                    table.insert(rewards, link)
                    local itemName, _, _, _, _, _, _, _, _, _, sellPrice = addon.SafeGetItemInfo(link)
                    if not itemName then
                        anyUncachedItem = true
                    end
                    fixedPricesSum = fixedPricesSum + ((sellPrice or 0) * (qty or 1))
                end
            end
        end)
    end

    -- Only cache when all item rewards have resolved item info from the server
    if (#choices > 0 or #rewards > 0) and not anyUncachedItem then
        _questRewardsCache[questID] = {
            choices = choices,
            choiceCounts = choiceCounts,
            rewards = rewards,
            maxChoicePrice = maxChoicePrice,
            fixedPricesSum = fixedPricesSum,
        }
    end

    return choices, rewards, maxChoicePrice, fixedPricesSum, anyUncachedItem
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
    if score ~= score or score == math.huge or score == -math.huge then score = 0.50 end
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
    if score ~= score or score == math.huge or score == -math.huge then score = 0.50 end
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

Utils.META_ICON = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12:12:0:0|t"

local META_TAG_COLORS = {
    KEY   = "|cff00ffff",
    MOUNT = "|cffff80ff",
    BAG   = "|cff66ff99",
    EPIC  = "|cffa335ee",
    CLASS = "|cffffd100",
    BIS   = "|cff0099ff",
}

function Utils.GetMetaTagBadge(tag)
    local key = string.upper(tostring(tag or "META"))
    local color = META_TAG_COLORS[key] or "|cffffd100"
    return string.format("%s[%s]|r", color, key)
end

function Utils.GetZoneMetaSummary(zoneName, countsOnly)
    if not (zoneName and addon.Data and addon.Data.GetZoneMetaQuests) then return nil end
    local pFaction = (addon.Player and addon.Player.GetFaction and addon.Player.GetFaction()) or (UnitFactionGroup and UnitFactionGroup("player"))
    local pClass = (addon.Player and addon.Player.GetClass and addon.Player.GetClass())
    if not pClass and UnitClass then
        local _, engClass = UnitClass("player")
        pClass = engClass
    end
    return addon.Data.GetZoneMetaQuests(zoneName, pFaction, pClass, countsOnly)
end

function Utils.FormatBadge(score, isComplete, isHard, isBankable, isLowValue, isMeta)
    local showMeta = isMeta and (not addon.db or addon.db.showMetaIndicator ~= false)
    local metaPrefix = showMeta and (Utils.META_ICON .. " ") or ""

    if isComplete then
        return metaPrefix .. "|cff1aff4d[OK]|r"
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
    local statusPrefix = ""
    if isHard then
        statusPrefix = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:12:12:0:0|t "
    elseif isLowValue then
        statusPrefix = "|TInterface\\Buttons\\UI-MicroStream-Red:12:12:0:0|t "
    end
    return metaPrefix .. statusPrefix .. badge
end

local _cleanTitleCache = {}
local _cleanTitleCacheSize = 0

function Utils.CleanQuestTitle(title)
    if type(title) ~= "string" or title == "" then return "" end
    local cached = _cleanTitleCache[title]
    if cached then return cached end
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
    if _cleanTitleCacheSize >= 300 then
        wipe(_cleanTitleCache)
        _cleanTitleCacheSize = 0
    end
    _cleanTitleCache[title] = cleaned
    _cleanTitleCacheSize = _cleanTitleCacheSize + 1
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
local _knownQuestLevels = {}
local _knownQuestLevelsByTitle = {}

function Utils.RecordKnownQuestLevel(questID, title, level)
    if type(level) == "number" and level > 0 then
        if Utils.IsValidQuestID(questID) then
            _knownQuestLevels[questID] = level
        end
        if type(title) == "string" and title ~= "" then
            local clean = Utils.CleanQuestTitle(title)
            clean = string.gsub(clean, "^%s*%[%d+%+?%]%s*", "")
            local lower = string.lower(string.gsub(clean, "^%s*(.-)%s*$", "%1"))
            if lower ~= "" then
                _knownQuestLevelsByTitle[lower] = level
            end
        end
    end
end

function Utils.GetQuestBasicInfo(questID)
    if not Utils.IsValidQuestID(questID) then return nil end

    if _basicInfoCache[questID] then
        local entry = _basicInfoCache[questID]
        if entry.title and not string.find(entry.title, "^Quest #") and not entry.isLevelFallback then
            return entry
        end
    end

    local title, level, isElite, isDungeon, isGroup, isHeader
    local hasLiveTag = false
    local inLog = false

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
            hasLiveTag = true
            local tagID = tagInfo.tagID or tagInfo.worldStateID
            local tagName = type(tagInfo.tagName) == "string" and tagInfo.tagName or ""
            if tagInfo.isElite == true or (tagName ~= "" and (string.find(tagName, "Elite", 1, true) or (ELITE and string.find(tagName, ELITE, 1, true)))) then
                isElite = true
            end
            if (Enum and Enum.QuestTag and (tagID == Enum.QuestTag.Dungeon or tagID == Enum.QuestTag.Raid or tagID == Enum.QuestTag.Heroic))
               or tagID == 81 or tagID == 62 or tagID == 85
               or (tagName ~= "" and (string.find(tagName, "Dungeon", 1, true) or string.find(tagName, "Raid", 1, true))) then
                isDungeon = true
            elseif (Enum and Enum.QuestTag and tagID == Enum.QuestTag.Group) or tagID == 1
               or (tagName ~= "" and string.find(tagName, "Group", 1, true)) then
                isGroup = true
            end
        end
    end

    -- Scan active Quest Log when title/level or tag flags are still missing
    if not title or not level or (not isElite and not isDungeon and not isGroup) then
        local qLogIdx = Utils.GetQuestLogIndex(questID)
        local startIdx, endIdx = 1, 0
        if qLogIdx then
            startIdx, endIdx = qLogIdx, qLogIdx
        elseif not (C_QuestLog and C_QuestLog.GetInfo) and GetQuestLogTitle and title then
            local numEntries = (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
            startIdx, endIdx = 1, numEntries
        end
        for i = startIdx, endIdx do
            if C_QuestLog and C_QuestLog.GetInfo then
                local ok, info = pcall(C_QuestLog.GetInfo, i)
                if ok and info and info.questID == questID then
                    inLog = true
                    title = title or info.title
                    level = level or (info.level and info.level > 0 and info.level)
                    isElite = isElite or info.isElite
                    local qTag = type(info.questTag) == "string" and info.questTag or ""
                    isDungeon = isDungeon or info.isDungeon or (qTag ~= "" and (string.find(qTag, "Dungeon", 1, true) ~= nil or string.find(qTag, "Raid", 1, true) ~= nil))
                    isGroup = isGroup or ((info.suggestedGroup or 0) > 1) or (qTag ~= "" and string.find(qTag, "Group", 1, true) ~= nil)
                    isHeader = info.isHeader
                    break
                end
            elseif GetQuestLogTitle then
                local ok, t, lvl, tag, isH, _, _, _, qid = pcall(GetQuestLogTitle, i)
                if ok and (qid == questID or (not qid and t == title)) then
                    inLog = true
                    title = title or t
                    level = level or (lvl and lvl > 0 and lvl)
                    local qTag = type(tag) == "string" and tag or ""
                    isElite = isElite or (qTag == "Elite" or (ELITE and qTag == ELITE))
                    isDungeon = isDungeon or (qTag ~= "" and (string.find(qTag, "Dungeon", 1, true) ~= nil or string.find(qTag, "Raid", 1, true) ~= nil))
                    isGroup = isGroup or (qTag ~= "" and string.find(qTag, "Group", 1, true) ~= nil)
                    isHeader = isH
                    break
                end
            end
        end
    end

    -- Scan NPC Gossip Available & Active Quests for unaccepted / in-progress quests
    if (not title or not level) and C_GossipInfo then
        for _, getter in ipairs({ C_GossipInfo.GetAvailableQuests, C_GossipInfo.GetActiveQuests }) do
            if getter then
                local ok, list = pcall(getter)
                if ok and type(list) == "table" then
                    for _, q in ipairs(list) do
                        local qLvl = q.questLevel or q.level
                        if q.questID and qLvl and qLvl > 0 then
                            Utils.RecordKnownQuestLevel(q.questID, q.title, qLvl)
                        end
                        if q.questID == questID then
                            title = title or q.title
                            if not level and qLvl and qLvl > 0 then
                                level = qLvl
                            end
                        end
                    end
                end
            end
        end
    end

    -- Scan QuestFrameGreetingPanel for unaccepted quests
    if (not level) and QuestFrameGreetingPanel and QuestFrameGreetingPanel:IsShown() and GetNumAvailableQuests and GetAvailableLevel and GetAvailableTitle then
        local numAvail = GetNumAvailableQuests() or 0
        for i = 1, numAvail do
            local availTitle = GetAvailableTitle(i)
            local availLvl = GetAvailableLevel(i)
            if availTitle and availLvl and availLvl > 0 then
                Utils.RecordKnownQuestLevel(nil, availTitle, availLvl)
            end
            if title and availTitle and Utils.CleanQuestTitle(availTitle) == Utils.CleanQuestTitle(title) then
                if availLvl and availLvl > 0 then
                    level = availLvl
                end
                break
            end
        end
    end

    -- Scan active QuestFrame offer dialog for unaccepted quest title and embedded level prefix
    if QuestFrame and QuestFrame:IsShown() and GetTitleText and Utils.IsActiveOfferQuest(questID, title) then
        local okT, rawOffer = pcall(GetTitleText)
        if okT and type(rawOffer) == "string" and rawOffer ~= "" then
            local cleanOffer = Utils.CleanQuestTitle(rawOffer)
            if not level then
                local lvlTag = string.match(cleanOffer, "^%s*%[(%d+)%+?%]")
                if lvlTag and tonumber(lvlTag) and tonumber(lvlTag) > 0 then
                    level = tonumber(lvlTag)
                end
            end
            if not title then
                title = string.gsub(cleanOffer, "^%s*%[%d+%+?%]%s*", "")
            end
        end
    end

    -- Clean any badge markup from resolved title
    if type(title) == "string" and title ~= "" then
        title = Utils.CleanQuestTitle(title)
        title = string.gsub(title, "^%s*%[%d+%+?%]%s*", "")
    end

    if level and level > 0 then
        Utils.RecordKnownQuestLevel(questID, title, level)
    else
        level = _knownQuestLevels[questID]
        if not level and type(title) == "string" and title ~= "" then
            local lowerTitle = string.lower(string.gsub(title, "^%s*(.-)%s*$", "%1"))
            level = _knownQuestLevelsByTitle[lowerTitle]
        end
    end

    -- Fallback: Wowhead Forever catalog level & elite/dungeon tags when client hasn't provided them
    if addon.Data and addon.Data.GetForeverCatalogEntry then
        local cat = addon.Data.GetForeverCatalogEntry(questID)
        if cat then
            if (not level or level <= 0) and type(cat[2]) == "number" and cat[2] > 0 then
                level = cat[2]
            end
            if not inLog and not hasLiveTag and not isElite and not isDungeon and not isGroup then
                local tag = cat[5]
                if tag == "Elite" then
                    isElite = true
                elseif tag == "Dungeon" or tag == "Raid" then
                    isDungeon = true
                end
            end
        end
    end

    local isLevelFallback = false
    local finalLevel = level
    if not finalLevel or finalLevel <= 0 then
        finalLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
        isLevelFallback = true
    end

    local res = {
        questID = questID,
        title = title or ("Quest #" .. questID),
        level = finalLevel,
        isLevelFallback = isLevelFallback,
        isElite = isElite or false,
        isDungeon = isDungeon or false,
        isGroup = isGroup or false,
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
    _questLogIndexScanned = false
    if questID then
        _basicInfoCache[questID] = nil
        _questLogIndexMap[questID] = nil
    else
        wipe(_basicInfoCache)
        _basicInfoCacheSize = 0
        wipe(_questLogIndexMap)
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

local MULTI_UNIT_IGNORE = {
    gold = true, silver = true, copper = true, g = true, s = true, c = true,
    lvl = true, level = true, levels = true,
    yard = true, yards = true, yd = true, yds = true,
    minute = true, minutes = true, min = true, mins = true,
    second = true, seconds = true, sec = true, secs = true,
    hour = true, hours = true, hr = true, hrs = true,
    day = true, days = true, week = true, weeks = true,
    year = true, years = true, step = true, steps = true,
    slot = true, slots = true, pct = true, percent = true,
    floor = true, part = true, rank = true, tier = true,
}

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
    for numStr, unitWord in string.gmatch(lower, "%f[%d](%d+)%s+([%a']+)") do
        local n = tonumber(numStr)
        if n and n >= 2 and n <= 200 and not MULTI_UNIT_IGNORE[unitWord] then
            return true
        end
    end
    return false
end

-- Shared helper to extract live objective texts from QuestFrame, C_QuestLog, or active QuestLog
local function CollectQuestObjectiveTexts(questID, titleHint)
    local objectiveTexts = {}
    local offerDescription = nil
    local matchesOffer = false

    local isOnQuest = true
    if C_QuestLog and C_QuestLog.IsOnQuest then
        local okOn, onQ = pcall(C_QuestLog.IsOnQuest, questID)
        if okOn then isOnQuest = onQ end
    end

    -- Priority 1: Check QuestFrame FIRST when viewing an offer/detail dialog (prevents QuestLog bleed!)
    if Utils.IsActiveOfferQuest(questID, titleHint) then
        matchesOffer = true
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

    -- Priority 2: Check modern C_QuestLog objectives
    if #objectiveTexts == 0 and C_QuestLog and C_QuestLog.GetQuestObjectives then
        local okObjs, objs = pcall(C_QuestLog.GetQuestObjectives, questID)
        if okObjs and type(objs) == "table" and #objs > 0 then
            for _, obj in ipairs(objs) do
                if obj and obj.text and obj.text ~= "" then
                    table.insert(objectiveTexts, obj.text)
                end
            end
        end
    end

    -- Priority 3: Check active QuestLog leaderboards directly by logIndex (no selection switch needed)
    if #objectiveTexts == 0 and isOnQuest then
        local logIndex = Utils.GetQuestLogIndex(questID)
        if logIndex and logIndex > 0 then
            if GetNumQuestLeaderBoards and GetQuestLogLeaderBoard then
                local okNum, numLB = pcall(GetNumQuestLeaderBoards, logIndex)
                if okNum and numLB and numLB > 0 then
                    for i = 1, numLB do
                        local okLB, desc = pcall(GetQuestLogLeaderBoard, i, logIndex)
                        if okLB and desc and desc ~= "" then
                            table.insert(objectiveTexts, desc)
                        end
                    end
                end
            end
            if #objectiveTexts == 0 and type(GetQuestLogQuestText) == "function" then
                local okQT, desc, obj = pcall(GetQuestLogQuestText, logIndex)
                if okQT then
                    if type(obj) == "string" and obj ~= "" then
                        table.insert(objectiveTexts, obj)
                    elseif type(desc) == "string" and desc ~= "" and (not offerDescription or offerDescription == "") then
                        offerDescription = desc
                    end
                end
            end
        end
        if #objectiveTexts == 0 and GetNumQuestLeaderBoards and GetQuestLogLeaderBoard then
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
    end

    return objectiveTexts, offerDescription, matchesOffer
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
    local objectiveTexts, offerDescription, matchesOffer = CollectQuestObjectiveTexts(questID, title)

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
                if liveXP == 0 and GetQuestLogRewardXP then
                    local okXP, val = pcall(GetQuestLogRewardXP, questID)
                    if okXP and type(val) == "number" and val > 0 then liveXP = val end
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

-- Compact currency formatter (e.g. "1g 25s", "42s", "85c")
function Utils.FormatMoneyCompact(copper)
    local amount = math.floor(tonumber(copper) or 0)
    if amount <= 0 then return nil end
    local g = math.floor(amount / 10000)
    local s = math.floor((amount % 10000) / 100)
    local c = amount % 100
    local parts = {}
    if g > 0 then table.insert(parts, g .. "g") end
    if s > 0 then table.insert(parts, s .. "s") end
    if c > 0 and g == 0 then table.insert(parts, c .. "c") end
    return (#parts > 0) and table.concat(parts, " ") or nil
end

-- Live dynamic quest summary (objectives, task classification, object detection)
function Utils.GetQuestLiveSummary(questID)
    if not Utils.IsValidQuestID(questID) then return nil end
    local basicInfo = Utils.GetQuestBasicInfo(questID)
    local title = basicInfo and basicInfo.title
    local objectiveTexts, offerDescription = CollectQuestObjectiveTexts(questID, title)

    local cleanLines = {}
    for _, raw in ipairs(objectiveTexts or {}) do
        for part in string.gmatch(tostring(raw), "[^\r\n]+") do
            local trimmed = part:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):match("^%s*(.-)%s*$")
            if trimmed and trimmed ~= "" then
                table.insert(cleanLines, trimmed)
            end
        end
    end

    local objectiveSummary = nil
    if #cleanLines > 0 then
        local preview = (#cleanLines <= 2)
            and table.concat(cleanLines, " • ")
            or (cleanLines[1] .. " • " .. cleanLines[2] .. string.format(" (+%d)", #cleanLines - 2))
        if #preview > 140 then
            preview = preview:sub(1, 137) .. "..."
        end
        objectiveSummary = preview
    end

    local scanText = string.lower(table.concat(cleanLines, " "))
    if scanText == "" and offerDescription and offerDescription ~= "" then
        scanText = string.lower(offerDescription)
    elseif scanText == "" and title then
        scanText = string.lower(title)
    end

    local hasKill = (
        string.find(scanText, "slain") or string.find(scanText, "kill")
        or string.find(scanText, "slay") or string.find(scanText, "defeat")
    ) ~= nil
    local hasCollect = (
        string.find(scanText, "collect") or string.find(scanText, "gather")
        or string.find(scanText, "obtain") or string.find(scanText, "loot")
        or string.find(scanText, "recover") or string.find(scanText, "retrieve")
        or string.find(scanText, "bring")
    ) ~= nil
    local hasObject = (
        string.find(scanText, "open ") or string.find(scanText, "search ")
        or string.find(scanText, "examine ") or string.find(scanText, "interact")
        or string.find(scanText, "activate") or string.find(scanText, "plant ")
        or string.find(scanText, "place ") or string.find(scanText, "chest")
        or string.find(scanText, "crate") or string.find(scanText, "tablet")
        or string.find(scanText, "book") or string.find(scanText, "supplies")
    ) ~= nil
    local hasExplore = (
        string.find(scanText, "locate ") or string.find(scanText, "find ")
        or string.find(scanText, "explore") or string.find(scanText, "investigate")
    ) ~= nil

    local isTalkTo = Utils.IsTalkToQuest and Utils.IsTalkToQuest(questID)
    local taskType
    if isTalkTo then
        taskType = "Talk to NPC / Delivery (Fast XP)"
    elseif basicInfo and basicInfo.isDungeon then
        taskType = "5-Player Dungeon Quest"
    elseif basicInfo and (basicInfo.isElite or basicInfo.isGroup) then
        taskType = "Elite / Group Quest"
    elseif hasKill and hasCollect then
        taskType = "Kill & Collect Quest"
    elseif hasObject and hasKill then
        taskType = "Combat & Object Interaction"
    elseif hasObject then
        taskType = "Object Interaction Quest"
    elseif hasKill then
        taskType = "Combat / Kill Quest"
    elseif hasCollect then
        taskType = "Item / Object Collection"
    elseif hasExplore then
        taskType = "Exploration / Recon Quest"
    else
        taskType = "Standard Quest"
    end

    return {
        taskType = taskType,
        objectiveSummary = objectiveSummary,
        objectives = cleanLines,
        hasObjectObjective = hasObject,
    }
end
