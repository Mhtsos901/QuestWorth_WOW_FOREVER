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

-- Non-zone quest log categories that should NOT form artificial quest hubs
local NON_ZONE_HEADERS = {
    -- Professions & Secondary
    ["Alchemy"] = true, ["Blacksmithing"] = true, ["Enchanting"] = true, ["Engineering"] = true,
    ["Leatherworking"] = true, ["Tailoring"] = true, ["Herbalism"] = true, ["Mining"] = true,
    ["Skinning"] = true, ["Cooking"] = true, ["First Aid"] = true, ["Fishing"] = true,
    ["Jewelcrafting"] = true, ["Inscription"] = true, ["Archaeology"] = true,
    -- Misc non-geographical headers
    ["Seasonal"] = true, ["Special"] = true, ["Battlegrounds"] = true, ["World Events"] = true,
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

local function ScanQuestLogClusters()
    -- Manual invalidation only (event-driven, see Scores.InvalidateDensityCache)
    -- Fallback: rescan at most once per 5 seconds if no explicit invalidation happened
    local now = (GetTime and GetTime()) or 0
    if (now - lastScanTime) < 5.0 and next(questZoneMap) then
        return
    end

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
            currentHeader = (cleanH ~= "") and cleanH or title
            isNonZoneHeader = NON_ZONE_HEADERS[currentHeader] or NON_ZONE_HEADERS[title] or false
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
    if not zoneName or zoneName == "" then return {} end
    ScanQuestLogClusters()
    PruneZoneQuests()

    local clean = string.gsub(zoneName, "^%s*(.-)%s*$", "%1")
    local list = {}

    -- 1. Direct match
    local quests = ZoneQuests[clean]

    -- 2. Strip trailing count like "Westfall (3)"
    if not quests then
        local noCount = string.gsub(clean, "%s*%(%d+/?%d*%)%s*$", "")
        quests = ZoneQuests[noCount]
    end

    -- 3. Case-insensitive and "The " flexible match
    if not quests then
        local lower = string.lower(clean)
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
    ScanQuestLogClusters()

    local zone = questZoneMap[questID]
    local isUnaccepted = not zone
    local isAtNPC = (QuestFrame and QuestFrame:IsShown()) or (GossipFrame and GossipFrame:IsShown())
    local count = 1

    if zone then
        count = zoneClusterCounts[zone] or 1
    else
        -- Quest is not in active quest log yet (e.g. tooltip on questgiver NPC / link)
        local currentZone = (GetRealZoneText and GetRealZoneText()) or (GetZoneText and GetZoneText())
        if currentZone then
            count = (zoneClusterCounts[currentZone] or 0) + 1
            zone = currentZone
        else
            zone = "Unknown"
            count = 1
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
    lastScanTime = 0
    PruneZoneQuests()
end
