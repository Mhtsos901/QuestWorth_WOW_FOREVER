--[[
    WorthIt / QuestWorth - Core.lua
    Main Addon Controller, Event Listener, and Module Initializer.
    Tuned for WoW Forever (Interface 16001).
]]

local addonName, addon = ...
local L = addon.L

local eventFrame = CreateFrame("Frame", "WorthIt_EventFrame")

local function ScanCurrentZoneQuestLines()
    if C_Map and C_Map.GetBestMapForUnit and addon.Data and addon.Data.ScanQuestLinesForMap then
        local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
        if ok and mapID and mapID > 0 then
            addon.Data.ScanQuestLinesForMap(mapID)
        end
    end
end

addon.isUpdatingUI = false

local function RefreshAllUI()
    if addon.isUpdatingUI then return end
    if InCombatLockdown and InCombatLockdown() then return end
    if addon.UI then
        if addon.UI.UpdateQuestLog then
            addon.UI.UpdateQuestLog()
        end
        if addon.UI.UpdateObjectiveTracker then
            addon.UI.UpdateObjectiveTracker()
        end
        if addon.UI.UpdateWorldMapBanner then
            addon.UI.UpdateWorldMapBanner()
        end
        if addon.UI.UpdateZoneAdvisor then
            addon.UI.UpdateZoneAdvisor()
        end
    end
end

local _refreshPending = false
local function DelayedRefresh(delay)
    if _refreshPending then return end
    _refreshPending = true
    delay = delay or 0.18
    if C_Timer and C_Timer.After then
        C_Timer.After(delay, function()
            _refreshPending = false
            RefreshAllUI()
        end)
    else
        _refreshPending = false
        RefreshAllUI()
    end
end

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName or loadedAddon == "QuestWorth" or loadedAddon == "WorthIt" then
            addon.DB.Initialize()
            addon.UI.InitializeConfig()
            addon.UI.InitializeTooltips()
            addon.UI.InitializeQuestLog()
            if addon.UI.InitializeQuestOffer then
                addon.UI.InitializeQuestOffer()
            end
            if addon.UI.InitializeWorldMap then
                addon.UI.InitializeWorldMap()
            end
            ScanCurrentZoneQuestLines()
            addon.Print(L["ADDON_LOADED"])
        elseif loadedAddon == "Blizzard_ObjectiveTracker" or
               loadedAddon == "Blizzard_QuestObjectiveTracker" or
               loadedAddon == "Blizzard_QuestMap" or
               loadedAddon == "Blizzard_WorldMap" or
               loadedAddon == "OpenMap" then
            if addon.UI and addon.UI.InvalidateModuleListCache then
                addon.UI.InvalidateModuleListCache()
            end
            if addon.UI and addon.UI.HookTrackerModules then
                addon.UI.HookTrackerModules()
            end
            if addon.UI and addon.UI.InitializeQuestLog then
                addon.UI.InitializeQuestLog()
            end
            if addon.UI and addon.UI.InitializeWorldMap then
                addon.UI.InitializeWorldMap()
            end
            DelayedRefresh(0.1)
        end

    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        if addon.Player and addon.Player.Update then
            addon.Player.Update()
        end
        ScanCurrentZoneQuestLines()
        if addon.UI and addon.UI.InitializeQuestLog then
            addon.UI.InitializeQuestLog()
        end
        if addon.UI and addon.UI.InitializeWorldMap then
            addon.UI.InitializeWorldMap()
        end
        if addon.Engine and addon.Engine.InvalidateCache then
            addon.Engine.InvalidateCache()
        end
        DelayedRefresh(0.2)
        if C_Timer and C_Timer.After then
            C_Timer.After(0.8, function()
                if addon.UI and addon.UI.UpdateObjectiveTracker then
                    addon.UI.UpdateObjectiveTracker(true)
                end
                if addon.UI and addon.UI.UpdateQuestLog then
                    addon.UI.UpdateQuestLog(true)
                end
            end)
        end

    elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" then
        ScanCurrentZoneQuestLines()
        if addon.Engine and addon.Engine.InvalidateCache then
            addon.Engine.InvalidateCache()
        end
        DelayedRefresh(0.1)

    elseif event == "QUEST_LOG_UPDATE" or
           event == "QUEST_DATA_LOAD_RESULT" or
           event == "QUEST_WATCH_UPDATE" or
           event == "UNIT_QUEST_LOG_CHANGED" or
           event == "BAG_UPDATE_DELAYED" then
        if addon.Engine and addon.Engine.InvalidateCache then
            addon.Engine.InvalidateCache()
        end
        DelayedRefresh(0.18)

    elseif event == "QUEST_WATCH_LIST_CHANGED" then
        -- Watch list (tracked quests) changed: only refresh UI badges, do not invalidate calculation cache
        DelayedRefresh(0.15)

    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if addon.Engine and addon.Engine.InvalidateCache then addon.Engine.InvalidateCache() end
        if addon.InvalidateHitExpertiseCache then addon.InvalidateHitExpertiseCache() end
        DelayedRefresh(0.18)

    elseif event == "QUEST_ACCEPTED" or
           event == "QUEST_TURNED_IN" or
           event == "QUEST_REMOVED" then
        if addon.Engine and addon.Engine.InvalidateCache then addon.Engine.InvalidateCache() end
        if addon.Scores and addon.Scores.InvalidateDensityCache then addon.Scores.InvalidateDensityCache() end
        if addon.Utils and addon.Utils.ClearQuestRewardsCache then addon.Utils.ClearQuestRewardsCache() end
        DelayedRefresh(0.18)

    elseif event == "PLAYER_LEVEL_UP" or
           event == "PLAYER_SPECIALIZATION_CHANGED" or
           event == "CHARACTER_POINTS_CHANGED" or
           event == "TRAIT_CONFIG_UPDATED" then
        if addon.Player and addon.Player.Update then
            addon.Player.Update()
        end
        if addon.Engine then
            if addon.Engine.InvalidateCache then addon.Engine.InvalidateCache() end
            if addon.Engine.InvalidateSpecCache then addon.Engine.InvalidateSpecCache() end
        end
        DelayedRefresh(0.18)

    elseif event == "GET_ITEM_INFO_RECEIVED" then
        if addon.Engine and addon.Engine.InvalidateCache then
            addon.Engine.InvalidateCache()
        end
        if addon.ClearSafeGetItemInfoCache then
            addon.ClearSafeGetItemInfoCache()
        end
        DelayedRefresh(0.18)

    elseif event == "PLAYER_REGEN_ENABLED" then
        DelayedRefresh(0.10)

    elseif event == "QUEST_DETAIL" or event == "QUEST_PROGRESS" or event == "QUEST_COMPLETE" then
        if addon.UI and addon.UI.UpdateQuestOfferDialog then
            if C_Timer and C_Timer.After then
                C_Timer.After(0.02, addon.UI.UpdateQuestOfferDialog)
            else
                addon.UI.UpdateQuestOfferDialog()
            end
        end

    elseif event == "GOSSIP_SHOW" then
        if addon.UI and addon.UI.UpdateGossipAvailableQuests then
            if C_Timer and C_Timer.After then
                C_Timer.After(0.02, addon.UI.UpdateGossipAvailableQuests)
            else
                addon.UI.UpdateGossipAvailableQuests()
            end
        end

    elseif event == "QUEST_GREETING" then
        if addon.UI and addon.UI.UpdateQuestGreetingPanel then
            if C_Timer and C_Timer.After then
                C_Timer.After(0.02, addon.UI.UpdateQuestGreetingPanel)
            else
                addon.UI.UpdateQuestGreetingPanel()
            end
        end
    end
end

local EVENTS = {
    "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD",
    "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "QUEST_LOG_UPDATE",
    "QUEST_WATCH_LIST_CHANGED", "QUEST_DATA_LOAD_RESULT",
    "QUEST_WATCH_UPDATE", "UNIT_QUEST_LOG_CHANGED",
    "BAG_UPDATE_DELAYED",
    "PLAYER_LEVEL_UP", "PLAYER_SPECIALIZATION_CHANGED", "CHARACTER_POINTS_CHANGED",
    "TRAIT_CONFIG_UPDATED", "PLAYER_EQUIPMENT_CHANGED",
    "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_REMOVED",
    "GET_ITEM_INFO_RECEIVED", "PLAYER_REGEN_ENABLED", "QUEST_DETAIL", "QUEST_PROGRESS",
    "QUEST_COMPLETE", "GOSSIP_SHOW", "QUEST_GREETING"
}

for _, ev in ipairs(EVENTS) do
    pcall(eventFrame.RegisterEvent, eventFrame, ev)
end

eventFrame:SetScript("OnEvent", OnEvent)
