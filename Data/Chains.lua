--[[
    WorthIt / QuestWorth - Data/Chains.lua
    Fallback quest chain lookup table and reverse index builder.
    Includes active C_QuestLine scanner and iconic Azeroth / WoW Forever leveling chains.
]]

local addonName, addon = ...
addon.Data = addon.Data or {}
local Data = addon.Data

-- Reverse index: questID -> { chainID = number, step = number, totalSteps = number, isCap = boolean, isImportant = boolean }
Data.ChainIndex = {}

-- Dynamic API quest line mapping: questID -> questLineID
Data.APIQuestLineMap = {}

-- Forever note: quest IDs from Classic are NOT guaranteed to be valid.
-- The C_QuestLine API (Data.ScanQuestLinesForMap) is the primary source.
-- Only include chains here that have been verified in WoW Forever.
Data.KnownChains = {
    -- [1001] The Defias Brotherhood (Westfall) — verified via WowHandbook Rogue BiS
    [1001] = {
        quests = { 155, 166, 167, 168, 65, 132, 135, 141, 142, 153 },
        isImportant = true,
    },
    -- [1007] Leaders of the Fang (Wailing Caverns) — verified via WowHandbook
    [1007] = {
        quests = { 903, 904, 905, 906, 907 },
        isImportant = true,
    },
}

-- Build the fast lookup reverse index
function Data.BuildChainIndex()
    for chainID, chainData in pairs(Data.KnownChains) do
        local quests = chainData.quests or {}
        local total = #quests
        for step, qID in ipairs(quests) do
            Data.ChainIndex[qID] = {
                chainID = chainID,
                step = step,
                totalSteps = total,
                isCap = (step == total),
                isImportant = chainData.isImportant or false,
            }
        end
    end
end

local MAX_API_MAP_SIZE = 5000

-- Active scanner for C_QuestLine API across zones
function Data.ScanQuestLinesForMap(mapID)
    if not mapID or mapID <= 0 then return end
    if not (C_QuestLine and C_QuestLine.GetAvailableQuestLines and C_QuestLine.GetQuestLineQuests) then return end

    -- Cap map size to avoid unbounded growth across zones
    local count = 0
    for _ in pairs(Data.APIQuestLineMap) do
        count = count + 1
        if count >= MAX_API_MAP_SIZE then break end
    end
    if count >= MAX_API_MAP_SIZE then
        wipe(Data.APIQuestLineMap)
    end

    local ok, lines = pcall(C_QuestLine.GetAvailableQuestLines, mapID)
    if ok and type(lines) == "table" then
        for _, lineInfo in ipairs(lines) do
            local lineID = lineInfo.questLineID
            if lineID then
                local ok2, quests = pcall(C_QuestLine.GetQuestLineQuests, lineID)
                if ok2 and type(quests) == "table" then
                    for _, qID in ipairs(quests) do
                        Data.APIQuestLineMap[qID] = lineID
                    end
                end
            end
        end
    end
end

-- Initialize the index
Data.BuildChainIndex()
