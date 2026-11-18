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

local function ResolveCanonicalZoneName(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then return "" end
    local clean = string.gsub(zoneName, "%s*%(%d+/?%d*%)%s*$", "")
    clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
    if clean == "" then return "" end

    local lower = string.lower(clean)
    if CANONICAL_ZONE_ALIASES[lower] then
        return CANONICAL_ZONE_ALIASES[lower]
    end

    local Zones = addon.Data and addon.Data.Zones
    if Zones then
        local direct = Zones[clean]
        if direct and not direct.isAlias then
            return clean
        end
        if direct and direct.isAlias and direct.mapID then
            for k, zData in pairs(Zones) do
                if not zData.isAlias and zData.mapID == direct.mapID then
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
                    return k
                end
            end
        end
    end

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

function Scores.CalculateDensity(questID)
    if not Utils.IsValidQuestID(questID) then
        return 0.30, { count = 0, zone = "Unknown", final = 0.30 }
    end
    ScanQuestLogClusters()

    local zone = questZoneMap[questID]
    local isUnaccepted = not zone
    local isAtNPC = (QuestFrame and QuestFrame:IsShown()) or (GossipFrame and GossipFrame:IsShown())
    local count = 1

    if zone then
        count = zoneClusterCounts[zone] or 1
    else
        -- Quest is not in active quest log yet (e.g. tooltip on questgiver NPC / link)
        zone = ResolvePlayerCurrentZone()
        local existingInZone = (zone and zoneClusterCounts[zone]) or #(Scores.GetQuestsForZone(zone))
        local npcAvailable = isAtNPC and CountNPCAvailableQuestsExcluding(questID) or 0
        count = math.max(1, existingInZone + 1 + npcAvailable)

        local zInfo = addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(zone)
        if zInfo and (zInfo.density == "High" or zInfo.density == "Very High") and isAtNPC then
            count = math.max(2, count)
        end
    end

    -- Cap cluster count to prevent oversized zone headers from giving blanket 100% density
    local effectiveCount = math.min(5, count)

    local score
    if effectiveCount <= 1 then
        score = 0.35 -- Lonely quest: travel time kills XP/hour
    elseif effectiveCount == 2 then
        score = 0.65
    elseif effectiveCount == 3 then
        score = 0.85
    else
        score = 1.00 -- 4+ quests: dense leveling hub
    end

    -- Unaccepted Hub Density Boost:
    -- When talking to an NPC (Quest Offer), assume hub synergy (0.65 minimum)
    if isUnaccepted and isAtNPC then
        score = math.max(0.65, score)
    end

    local reason = nil
    if score <= 0.35 then
        reason = "Isolated"
    elseif score >= 0.85 then
        reason = "Quest Hub"
    elseif isUnaccepted and isAtNPC then
        reason = "NPC Hub"
    end

    local details = {
        zone = zone,
        clusterCount = count,
        isUnaccepted = isUnaccepted,
        isAtNPC = isAtNPC,
        final = score,
        reason = reason,
    }

    if addon.db and addon.db.debug then
        addon.Debug("Density [Q:%d]: Zone='%s' (Cluster: %d, Unaccepted=%s, AtNPC=%s) -> Score=%.2f",
            questID, zone, count, tostring(isUnaccepted), tostring(isAtNPC), score)
    end

    return score, details
end

-- Called by Engine/Core on quest log changes (accept/remove/turn-in) for immediate refresh
function Scores.InvalidateDensityCache()
    _forceRescan = true
    lastScanTime = 0
    PruneZoneQuests()
end
