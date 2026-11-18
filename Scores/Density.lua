--[[
    WorthIt / QuestWorth - Scores/Density.lua
    Score 5: Hub Density & Quest Clustering (H) in [0.0, 1.0].
    
    Evaluates:
    - Opportunity cost and travel time efficiency.
    - An isolated quest with travel time gets a penalty (0.35).
    - Clusters of quests in the same zone/hub get a high synergy multiplier:
        1 quest  = 0.35 (Isolated / High travel overhead)
        2 quests = 0.65 (Standard duo)
        3 quests = 0.85 (High efficiency cluster)
        4+ quests = 1.00 (Maximum quest hub synergy)
]]

local addonName, addon = ...
addon.Scores = addon.Scores or {}
local Scores = addon.Scores
local Utils = addon.Utils

-- Non-zone quest log categories that should NOT form artificial quest hubs
local NON_ZONE_HEADERS = {
    -- Professions & Secondary
    ["Alchemy"] = true, ["Blacksmithing"] = true, ["Enchanting"] = true, ["Engineering"] = true,
    ["Leatherworking"] = true, ["Tailoring"] = true, ["Herbalism"] = true, ["Mining"] = true,
    ["Skinning"] = true, ["Cooking"] = true, ["First Aid"] = true, ["Fishing"] = true,
    ["Jewelcrafting"] = true, ["Inscription"] = true, ["Archaeology"] = true,
    -- Misc non-geographical headers
    ["Seasonal"] = true, ["Special"] = true, ["Battlegrounds"] = true, ["World Events"] = true,
    ["Camping"] = true, ["Crafting"] = true, ["Darkmoon Faire"] = true, ["Lunar Festival"] = true,
    ["Children's Week"] = true, ["Winter Veil"] = true, ["Midsummer Fire Festival"] = true,
    ["Hallow's End"] = true, ["Nightmare Incursions"] = true, ["Invasion"] = true,
    ["Raid"] = true, ["Reputation"] = true,
    -- English Class header fallbacks (Classic / headless clients where GetNumClasses is nil)
    ["Warrior"] = true, ["Paladin"] = true, ["Hunter"] = true, ["Rogue"] = true,
    ["Priest"] = true, ["Shaman"] = true, ["Mage"] = true, ["Warlock"] = true,
    ["Druid"] = true, ["Class"] = true, ["Class Quests"] = true,
}

-- Populate localized class names into non-zone headers
for i = 1, (GetNumClasses and GetNumClasses() or 13) do
    if C_CreatureInfo and C_CreatureInfo.GetClassInfo then
        local ok, info = pcall(C_CreatureInfo.GetClassInfo, i)
        if ok and info then
            if info.className then NON_ZONE_HEADERS[info.className] = true end
            if info.classFile then NON_ZONE_HEADERS[info.classFile] = true end
        end
    elseif GetClassInfo then
        local ok, className, classFile = pcall(GetClassInfo, i)
        if ok then
            if className then NON_ZONE_HEADERS[className] = true end
            if classFile then NON_ZONE_HEADERS[classFile] = true end
        end
    end
end

-- Cached zone cluster counts: [zoneName] = count, [questID] = zoneName
local questZoneMap = {}
local zoneClusterCounts = {}
local lastScanTime = 0

-- Persistent Zone-to-Quest mapping across collapsed Quest Log headers
Scores.ZoneQuests = Scores.ZoneQuests or {}
local ZoneQuests = Scores.ZoneQuests

local CANONICAL_ZONE_ALIASES = {
    ["riverlands"] = "Riverglades",
    ["hyjal"] = "Mount Hyjal",
    ["elderwild"] = "Mount Hyjal",
    ["stonewrought dam"] = "Loch Modan",
    ["thoradin's wall"] = "Arathi Highlands",
    ["shaper's terrace"] = "Shaper's Terrace",
    ["the shaper's terrace"] = "Shaper's Terrace",
    ["hall of thanes"] = "Hall of Thanes",
    ["the hall of thanes"] = "Hall of Thanes",
    ["the temple of atal'hakkar"] = "Sunken Temple",
    ["temple of atal'hakkar"] = "Sunken Temple",
    ["anvilmar"] = "Dun Morogh",
    ["coldridge valley"] = "Dun Morogh",
    ["northshire valley"] = "Elwynn Forest",
    ["shadowglen"] = "Teldrassil",
    ["deathknell"] = "Tirisfal Glades",
    ["valley of trials"] = "Durotar",
    ["camp narache"] = "Mulgore",
    ["gadgetzan"] = "Tanaris",
    ["land's end beach"] = "Tanaris",
    ["nighthaven"] = "Moonglade",
    ["aerie peak"] = "The Hinterlands",
    ["rut'theran village"] = "Teldrassil",
    ["the maul"] = "Dire Maul",
    ["booty bay"] = "Stranglethorn Vale",
    ["ratchet"] = "The Barrens",
    ["the crossroads"] = "The Barrens",
    ["blackrock spire"] = "Lower Blackrock Spire",
}

local _canonZoneMemo = {}

local function ResolveCanonicalZoneName(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then return "" end
    local cached = _canonZoneMemo[zoneName]
    if cached then return cached end
    local clean = string.gsub(zoneName, "%s*%(%d+/?%d*%)%s*$", "")
    clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
    if clean == "" then return "" end

    local lower = string.lower(clean)
    if CANONICAL_ZONE_ALIASES[lower] then
        _canonZoneMemo[zoneName] = CANONICAL_ZONE_ALIASES[lower]
        return _canonZoneMemo[zoneName]
    end

    local Zones = addon.Data and addon.Data.Zones
    if Zones then
        local direct = Zones[clean]
        if direct and not direct.isAlias then
            _canonZoneMemo[zoneName] = clean
            return clean
        end
        if direct and direct.isAlias and direct.mapID then
            for k, zData in pairs(Zones) do
                if not zData.isAlias and zData.mapID == direct.mapID then
                    _canonZoneMemo[zoneName] = k
                    return k
                end
            end
        end
        local noThe = string.gsub(lower, "^the%s+", "")
        for k, zData in pairs(Zones) do
            if not zData.isAlias then
                local kLower = string.lower(k)
                local kNoThe = string.gsub(kLower, "^the%s+", "")
                if kLower == lower or kNoThe == noThe then
                    _canonZoneMemo[zoneName] = k
                    return k
                end
            end
        end
    end

    _canonZoneMemo[zoneName] = clean
    return clean
end

local function ResolvePlayerCurrentZone()
    local rawZone = (GetRealZoneText and GetRealZoneText()) or (GetZoneText and GetZoneText()) or ""
    local canonical = ResolveCanonicalZoneName(rawZone)
    local Zones = addon.Data and addon.Data.Zones
    if canonical ~= "" and Zones and Zones[canonical] then
        return canonical
    end

    -- Walk player map hierarchy for subzones (e.g. towns/caves/outposts)
    if C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo then
        local okM, mapID = pcall(C_Map.GetBestMapForUnit, "player")
        if okM and mapID and mapID > 0 then
            local info = C_Map.GetMapInfo(mapID)
            for _ = 1, 4 do
                if not info then break end
                if info.name then
                    local mapCanon = ResolveCanonicalZoneName(info.name)
                    if Zones and Zones[mapCanon] then
                        return mapCanon
                    end
                    if canonical == "" then
                        canonical = mapCanon
                    end
                end
                if info.parentMapID and info.parentMapID > 0 then
                    info = C_Map.GetMapInfo(info.parentMapID)
                else
                    break
                end
            end
        end
    end

    return (canonical ~= "") and canonical or "Unknown"
end

local function CountNPCAvailableQuestsExcluding(questID)
    local extra = 0
    local seen = {}
    local targetTitle = nil
    if Utils.GetQuestTitle then
        targetTitle = Utils.GetQuestTitle(questID)
    end
    local cleanTarget = targetTitle and string.lower(Utils.CleanQuestTitle(targetTitle)) or nil

    if C_GossipInfo and C_GossipInfo.GetAvailableQuests then
        local ok, avail = pcall(C_GossipInfo.GetAvailableQuests)
        if ok and type(avail) == "table" then
            for _, q in ipairs(avail) do
                if q.questID and q.questID ~= questID then
                    extra = extra + 1
                    seen[q.questID] = true
                elseif q.title and not q.questID then
                    local cleanT = string.lower(Utils.CleanQuestTitle(q.title))
                    if not cleanTarget or cleanT ~= cleanTarget then
                        extra = extra + 1
                    end
                end
            end
        end
    end

    if extra == 0 and GetNumAvailableQuests and GetAvailableTitle then
        local okN, numAvail = pcall(GetNumAvailableQuests)
        if okN and type(numAvail) == "number" and numAvail > 0 then
            for i = 1, numAvail do
                local okT, availTitle = pcall(GetAvailableTitle, i)
                if okT and type(availTitle) == "string" and availTitle ~= "" then
                    local cleanAvail = string.lower(Utils.CleanQuestTitle(availTitle))
                    if not cleanTarget or cleanAvail ~= cleanTarget then
                        extra = extra + 1
                    end
                end
            end
        end
    end

    return extra
end

local function PruneZoneQuests()
    local isOnQuest = (C_QuestLog and C_QuestLog.IsOnQuest) or IsOnQuest
    if not isOnQuest then return end
    for zoneName, quests in pairs(ZoneQuests) do
        local hasAny = false
        for qID in pairs(quests) do
            local ok, onQuest = pcall(isOnQuest, qID)
            if ok and onQuest == false then
                quests[qID] = nil
            else
                hasAny = true
            end
        end
        if not hasAny then
            ZoneQuests[zoneName] = nil
        end
    end
end

local _forceRescan = true
local function ScanQuestLogClusters()
    -- Manual invalidation only (event-driven, see Scores.InvalidateDensityCache)
    -- Fallback: rescan at most once per 5 seconds if no explicit invalidation happened
    local now = (GetTime and GetTime()) or 0
    if not _forceRescan and (now - lastScanTime) < 5.0 and next(questZoneMap) then
        return
    end
    _forceRescan = false

    PruneZoneQuests()

    wipe(questZoneMap)
    wipe(zoneClusterCounts)
    lastScanTime = now

    local currentHeader = "Unknown"
    local isNonZoneHeader = false
    local numEntries = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries()) or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0

    for i = 1, numEntries do
        local qID, isHeader, title
        if C_QuestLog and C_QuestLog.GetInfo then
            local info = C_QuestLog.GetInfo(i)
            if info then
                qID = info.questID
                isHeader = info.isHeader
                title = info.title
            end
        elseif GetQuestLogTitle then
            local ok, t, _, _, isH, _, _, _, id = pcall(GetQuestLogTitle, i)
            if ok then
                title = t
                isHeader = isH
                qID = id
            end
        end

        if isHeader and title then
            local cleanH = string.gsub(title, "%s*%(%d+/?%d*%)%s*$", "")
            cleanH = string.gsub(cleanH, "^%s*(.-)%s*$", "%1")
            local rawHeader = (cleanH ~= "") and cleanH or title
            isNonZoneHeader = NON_ZONE_HEADERS[rawHeader] or NON_ZONE_HEADERS[title] or false
            currentHeader = isNonZoneHeader and rawHeader or ResolveCanonicalZoneName(rawHeader)
        elseif not isHeader and qID and qID > 0 then
            if isNonZoneHeader then
                -- Quests under Class/Profession headers do not cluster together as hubs
                questZoneMap[qID] = "ClassOrProf:" .. qID
                zoneClusterCounts["ClassOrProf:" .. qID] = 1
            else
                questZoneMap[qID] = currentHeader
                ZoneQuests[currentHeader] = ZoneQuests[currentHeader] or {}
                ZoneQuests[currentHeader][qID] = true
            end
        end
    end

    -- Re-evaluate zoneClusterCounts and questZoneMap for any quests saved in ZoneQuests
    -- so that collapsed headers in the UI never break Hub Density or omit quests
    for zoneName, quests in pairs(ZoneQuests) do
        local activeCount = 0
        for qID in pairs(quests) do
            activeCount = activeCount + 1
            if not questZoneMap[qID] then
                questZoneMap[qID] = zoneName
            end
        end
        if activeCount > 0 then
            zoneClusterCounts[zoneName] = activeCount
        end
    end
end

-- Export active quests list for a zone
function Scores.GetQuestsForZone(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then return {} end
    ScanQuestLogClusters()

    local clean = string.gsub(zoneName, "^%s*(.-)%s*$", "%1")
    local canonical = ResolveCanonicalZoneName(clean)
    local list = {}

    -- 1. Direct & canonical match
    local quests = ZoneQuests[canonical] or ZoneQuests[clean]

    -- 2. Strip trailing count like "Westfall (3)"
    if not quests then
        local noCount = string.gsub(clean, "%s*%(%d+/?%d*%)%s*$", "")
        quests = ZoneQuests[noCount]
    end

    -- 3. Case-insensitive and "The " flexible match
    if not quests then
        local lower = string.lower(canonical ~= "" and canonical or clean)
        local noThe = string.gsub(lower, "^the%s+", "")
        for zName, qMap in pairs(ZoneQuests) do
            local zLower = string.lower(zName)
            local zNoThe = string.gsub(zLower, "^the%s+", "")
            if zLower == lower or zNoThe == noThe then
                quests = qMap
                break
            end
        end
    end

    if quests then
        for qID in pairs(quests) do
            list[#list + 1] = qID
        end
    end
    return list
end

-- Check if header title is a non-geographical category (Class, Profession, Seasonal, etc.)
function Scores.IsNonZoneHeader(headerTitle)
    if not headerTitle then return true end
    return NON_ZONE_HEADERS[headerTitle] == true
end

-- =========================================================================
-- Zone Good Quests Index (Counts eligible good quests in the zone itself,
-- not just what the player has already picked up in their Quest Log!)
-- =========================================================================
local _zoneGoodQuestsIndex = nil

local CLASS_CATEGORY_NAMES = {
    ["Warrior"] = "WARRIOR", ["Paladin"] = "PALADIN", ["Hunter"] = "HUNTER",
    ["Rogue"] = "ROGUE", ["Priest"] = "PRIEST", ["Shaman"] = "SHAMAN",
    ["Mage"] = "MAGE", ["Warlock"] = "WARLOCK", ["Druid"] = "DRUID",
}

local function BuildZoneGoodQuestsIndex()
    local idx = {}
    local seenByZone = {}
    local Data = addon.Data
    if not Data then
        _zoneGoodQuestsIndex = idx
        return idx
    end

    local function addEntry(zoneName, qID, lvl, side, reqClass, isMeta, perm)
        local canon = ResolveCanonicalZoneName(zoneName)
        if canon == "" or canon == "Unknown" or NON_ZONE_HEADERS[canon] then return end
        local zBucket = idx[canon]
        if not zBucket then
            zBucket = {}
            idx[canon] = zBucket
            seenByZone[canon] = {}
        end
        if seenByZone[canon][qID] then return end
        seenByZone[canon][qID] = true
        zBucket[#zBucket + 1] = {
            qID = qID,
            lvl = (type(lvl) == "number" and lvl > 0) and lvl or 1,
            side = side or "B",
            reqClass = reqClass,
            isMeta = isMeta and true or false,
            perm = perm and true or false,
        }
    end

    -- 1. Index all 543 MetaQuests (Keys, Attunements, Mounts, Bags, Epics, Class, BiS)
    for qID, raw in pairs(Data.MetaQuests or {}) do
        if type(raw[3]) == "string" and raw[3] ~= "" then
            addEntry(raw[3], qID, raw[4], raw[5], raw[7], true, raw[6])
        end
    end

    -- 2. Index good quests from ForeverCatalog (2,266 quests: gear rewards, chains, payoffs, elites/dungeons, or strong XP)
    local chainIdx = Data.ChainIndex or {}
    local payoffs = Data.QuestPayoffs or {}
    local metaTbl = Data.MetaQuests or {}
    for qID, cat in pairs(Data.ForeverCatalog or {}) do
        local rawZone = cat[1]
        if type(rawZone) == "string" and rawZone ~= "" and not CLASS_CATEGORY_NAMES[rawZone] then
            local lvl = tonumber(cat[2]) or 1
            local xp = tonumber(cat[3]) or 0
            local side = cat[4] or "B"
            local tag = cat[5]
            local rew = cat[6]
            local isMeta = (metaTbl[qID] ~= nil)
            local isChainOrPayoff = (chainIdx[qID] ~= nil) or (payoffs[qID] ~= nil)
            local hasGear = (type(rew) == "string" and rew ~= "")
            local isSpecialTag = (tag == "Dungeon" or tag == "Elite" or tag == "Raid")
            local goodXPThreshold = ((lvl * 5) + 45) * 4.5
            if isMeta or isChainOrPayoff or hasGear or isSpecialTag or (xp >= goodXPThreshold) then
                addEntry(rawZone, qID, lvl, side, nil, isMeta, isMeta and metaTbl[qID] and metaTbl[qID][6])
            end
        end
    end

    _zoneGoodQuestsIndex = idx
    return idx
end

local function IsQuestDoneForDensity(questID)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local ok, done = pcall(C_QuestLog.IsQuestFlaggedCompleted, questID)
        if ok and done then return true end
    elseif IsQuestFlaggedCompleted then
        local ok, done = pcall(IsQuestFlaggedCompleted, questID)
        if ok and done then return true end
    end
    return false
end

local DENSITY_TIER_BASELINE = {
    ["Very High"] = 6,
    ["High"]      = 4,
    ["Medium"]    = 3,
    ["Low"]       = 2,
    ["Sparse"]    = 1,
}

local _zoneGoodCountMemo = {}
local _memoCtxKey = nil

-- Count available uncompleted good quests in a zone for the player's current level, faction, and class
function Scores.GetZoneGoodQuestCount(zoneName, playerLevel, playerFaction, playerClass)
    if type(zoneName) ~= "string" or zoneName == "" or string.find(zoneName, "^ClassOrProf:") then
        return 0, 0
    end
    local canonical = ResolveCanonicalZoneName(zoneName)
    if canonical == "" or canonical == "Unknown" or NON_ZONE_HEADERS[canonical] then
        return 0, 0
    end

    local pLevel = tonumber(playerLevel) or (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or (UnitLevel and UnitLevel("player")) or 1
    local rawFac = playerFaction or (addon.Player and addon.Player.GetFaction and addon.Player.GetFaction()) or (UnitFactionGroup and UnitFactionGroup("player")) or "Alliance"
    local pSide = (rawFac == "Horde" or rawFac == "H") and "H" or ((rawFac == "Alliance" or rawFac == "A") and "A" or "B")
    local pClass = playerClass or (addon.Player and addon.Player.GetClass and addon.Player.GetClass())
    if not pClass and UnitClass then
        local _, engC = UnitClass("player")
        pClass = engC
    end
    pClass = (type(pClass) == "string" and pClass ~= "") and string.upper(pClass) or "WARRIOR"

    local ctxKey = pLevel .. ":" .. pSide .. ":" .. pClass
    if _memoCtxKey ~= ctxKey then
        wipe(_zoneGoodCountMemo)
        _memoCtxKey = ctxKey
    end
    local cached = _zoneGoodCountMemo[canonical]
    if cached then
        return cached[1], cached[2]
    end

    local greenRange = 5 + math.floor(pLevel / 10)
    local minViableLvl = pLevel - greenRange
    local maxViableLvl = pLevel + 4

    local idx = _zoneGoodQuestsIndex or BuildZoneGoodQuestsIndex()
    local bucket = idx[canonical]
    local catalogGoodCount = 0

    if bucket then
        for i = 1, #bucket do
            local e = bucket[i]
            local sideOk = (pSide == "B" or e.side == "B" or e.side == pSide)
            local classOk = (not e.reqClass or not pClass or e.reqClass == pClass)
            if sideOk and classOk then
                local lvlOk = (e.lvl >= minViableLvl and e.lvl <= maxViableLvl) or (e.perm and e.lvl <= maxViableLvl)
                if lvlOk and not IsQuestDoneForDensity(e.qID) then
                    catalogGoodCount = catalogGoodCount + 1
                end
            end
        end
    end

    -- Classic zone bracket baseline (covers classic vanilla hub quests not duplicated in ForeverCatalog)
    local bracketBaseline = 0
    local zInfo = addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(canonical)
    if zInfo and not zInfo.isCity then
        local zFac = zInfo.faction
        local facOk = (not zFac or zFac == "Contested" or zFac == "Neutral" or zFac == rawFac)
        local clsOk = (not zInfo.class or not pClass or zInfo.class == pClass)
        if facOk and clsOk then
            local effMin = (addon.Engine and addon.Engine.GetEffectiveMinLevel and addon.Engine.GetEffectiveMinLevel(zInfo, rawFac)) or zInfo.min or 1
            local maxLvl = zInfo.max or 60
            if pLevel >= (effMin - 2) and pLevel <= (maxLvl + 3) then
                bracketBaseline = DENSITY_TIER_BASELINE[zInfo.density or "Medium"] or 3
            end
        end
    end

    local totalZoneGood = math.max(catalogGoodCount, bracketBaseline)
    _zoneGoodCountMemo[canonical] = { totalZoneGood, catalogGoodCount }
    return totalZoneGood, catalogGoodCount
end

local function ResolveQuestZone(questID, isAtNPC)
    local z = questZoneMap[questID]
    if z and z ~= "" and z ~= "Unknown" then
        return z, false
    end
    if isAtNPC or (Utils and Utils.IsActiveOfferQuest and Utils.IsActiveOfferQuest(questID)) then
        local curZ = ResolvePlayerCurrentZone()
        if curZ and curZ ~= "" and curZ ~= "Unknown" then
            return curZ, true
        end
    end
    local Data = addon.Data
    if Data then
        local m = Data.MetaQuests and Data.MetaQuests[questID]
        if m and type(m[3]) == "string" and m[3] ~= "" then
            local canon = ResolveCanonicalZoneName(m[3])
            if canon ~= "" and not NON_ZONE_HEADERS[canon] then
                return canon, true
            end
        end
        local cat = Data.ForeverCatalog and Data.ForeverCatalog[questID]
        if cat and type(cat[1]) == "string" and cat[1] ~= "" and not CLASS_CATEGORY_NAMES[cat[1]] then
            local canon = ResolveCanonicalZoneName(cat[1])
            if canon ~= "" and not NON_ZONE_HEADERS[canon] then
                return canon, true
            end
        end
    end
    return ResolvePlayerCurrentZone(), true
end

function Scores.CalculateDensity(questID)
    if not Utils.IsValidQuestID(questID) then
        return 0.75, { count = 0, clusterCount = 0, inLogCount = 0, zoneGoodCount = 0, zone = "Unknown", final = 0.75 }
    end
    ScanQuestLogClusters()

    local isAtNPC = (QuestFrame and QuestFrame:IsShown()) or (GossipFrame and GossipFrame:IsShown())
    local zone, isUnaccepted = ResolveQuestZone(questID, isAtNPC)
    local inLogCount = 1

    if not isUnaccepted then
        inLogCount = zoneClusterCounts[zone] or 1
    else
        local existingInZone = (zone and zoneClusterCounts[zone]) or #(Scores.GetQuestsForZone(zone))
        local npcAvailable = isAtNPC and CountNPCAvailableQuestsExcluding(questID) or 0
        inLogCount = math.max(1, existingInZone + 1 + npcAvailable)
    end

    -- Count good quests available in the zone itself (not just the player's current Quest Log)
    local zoneGoodCount, catalogGoodCount = Scores.GetZoneGoodQuestCount(zone)
    local totalHubQuests = math.max(inLogCount, zoneGoodCount)

    -- Solution C Curve: Never penalizes good quests when arriving at a zone (neutral 0.75 baseline -> 1.00 hub synergy)
    local score
    if totalHubQuests <= 1 then
        score = 0.75 -- Standalone / Sparse zone: neutral baseline (zero unfair penalty)
    elseif totalHubQuests == 2 then
        score = 0.84
    elseif totalHubQuests == 3 then
        score = 0.92
    else
        score = 1.00 -- 4+ good quests in zone or log: full Zone Hub synergy
    end

    local reason = nil
    if totalHubQuests >= 3 then
        reason = "Quest Hub"
    elseif totalHubQuests == 2 or (isUnaccepted and isAtNPC) then
        reason = "NPC Hub"
    else
        reason = "Standalone"
    end

    local details = {
        zone = zone,
        clusterCount = totalHubQuests,
        inLogCount = inLogCount,
        zoneGoodCount = zoneGoodCount,
        catalogGoodCount = catalogGoodCount,
        isUnaccepted = isUnaccepted,
        isAtNPC = isAtNPC,
        final = score,
        reason = reason,
    }

    if addon.db and addon.db.debug then
        addon.Debug("Density [Q:%d]: Zone='%s' (TotalGood: %d, ZoneGood: %d, InLog: %d) -> Score=%.2f",
            questID, zone, totalHubQuests, zoneGoodCount, inLogCount, score)
    end

    return score, details
end

-- Called by Engine/Core on quest log changes (accept/remove/turn-in) for immediate refresh
function Scores.InvalidateDensityCache()
    _forceRescan = true
    lastScanTime = 0
    wipe(_zoneGoodCountMemo)
    PruneZoneQuests()
end
