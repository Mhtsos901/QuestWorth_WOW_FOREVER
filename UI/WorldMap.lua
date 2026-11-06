--[[
    WorthIt / QuestWorth - UI/WorldMap.lua
    World Map Zone Worth Banner & Hover Breakdown.
    Displays zone suitability and leveling recommendations directly on the map.
    Reactive updater detects map navigation, zooming, and sub-zone traversal in real time.
]]

local addonName, addon = ...
addon.UI = addon.UI or {}
local UI = addon.UI
local Utils = addon.Utils
local L = addon.L

local mapBanner = nil

-- Resolve geographical leveling zone name even when zoomed into towns, areas, or sub-zones
local function ResolveZoneName(mapID)
    if not mapID or mapID <= 0 then return nil end
    local mapInfo = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    if not mapInfo or not mapInfo.name then return nil end

    -- Check if mapInfo is a Continent or Cosmic/World view (Enum.UIMapType: Cosmic=0, World=1, Continent=2)
    local mapType = mapInfo.mapType
    if mapType and (mapType == 0 or mapType == 1 or mapType == 2) then
        return nil, mapInfo
    end

    -- Ignore continent names by string check as well
    local name = mapInfo.name
    if name == "Eastern Kingdoms" or name == "Kalimdor" or name == "Azeroth" or name == "The Maelstrom" or name == "Outland" then
        return nil, mapInfo
    end

    -- 1. Direct match in Data.Zones
    if addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(name) then
        return name, mapInfo
    end

    -- 2. Traverse parentMapID up to 4 levels if viewing a sub-zone, town, or micro area
    local current = mapInfo
    for depth = 1, 4 do
        if current.parentMapID and current.parentMapID > 0 then
            local parent = C_Map.GetMapInfo(current.parentMapID)
            if parent and parent.name then
                if addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(parent.name) then
                    return parent.name, parent
                end
                current = parent
            else
                break
            end
        else
            break
        end
    end

    -- 3. Fallback: Check if we have active quests mapped for this zone name in Quest Log
    local quests = addon.Scores and addon.Scores.GetQuestsForZone and addon.Scores.GetQuestsForZone(name)
    if quests and #quests > 0 then
        return name, mapInfo
    end

    return name, mapInfo
end

local function CreateWorldMapBanner()
    if mapBanner then return mapBanner end
    if not WorldMapFrame then return nil end

    local parent = (WorldMapFrame.ScrollContainer) or WorldMapFrame
    local frame = CreateFrame("Button", "WorthItWorldMapBanner", parent, "BackdropTemplate")
    frame:SetHeight(26)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(parent:GetFrameLevel() + 10)

    -- Anchor top center of the map canvas
    frame:SetPoint("TOP", parent, "TOP", 0, -8)

    -- Backdrop styling: sleek dark panel with subtle border
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0.05, 0.05, 0.08, 0.88)
    frame:SetBackdropBorderColor(0.35, 0.35, 0.40, 0.90)

    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.Text = text

    -- Rich hover tooltip with full zone breakdown
    frame:SetScript("OnEnter", function(self)
        if not self.data then return end
        local d = self.data
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
        GameTooltip:ClearLines()

        local colorHex = Utils.GetScoreColorHex(d.worth)
        local levelText = (d.minLevel and d.maxLevel) and string.format(" |cff888888(Level %d - %d)|r", d.minLevel, d.maxLevel) or ""
        GameTooltip:AddDoubleLine(
            string.format("|cffffffff%s|r%s", d.zoneName, levelText),
            string.format("|cff%sZone Worth: %.0f%%|r", colorHex, d.worth * 100),
            1, 1, 1, 1, 1, 1
        )
        GameTooltip:AddLine(" ")

        -- Suitability / Level Bracket Status
        local statusColor = (d.worth >= 0.70 and "|cff00ff00") or (d.worth >= 0.50 and "|cffffff00") or "|cffff3333"
        GameTooltip:AddDoubleLine(
            "|cff00ccffSuitability:|r",
            string.format("%s%s|r", statusColor, d.status),
            0.9, 0.9, 0.9, 1, 1, 1
        )

        -- Territory / Faction
        local fColor = (d.faction == "Alliance" and "|cff0070dd") or (d.faction == "Horde" and "|cffc41f3b") or "|cffffff00"
        GameTooltip:AddDoubleLine(
            "|cff00ccffTerritory:|r",
            fColor .. d.faction .. "|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )

        -- Active Quests in Log vs General Zone
        if d.activeCount and d.activeCount > 0 then
            local qColorHex = Utils.GetScoreColorHex(d.activeWorth or 0.5)
            GameTooltip:AddDoubleLine(
                "|cff00ccffActive Quests in Log:|r",
                string.format("|cff%s%d Quests (%.0f%% Avg)|r", qColorHex, d.activeCount, (d.activeWorth or 0) * 100),
                0.9, 0.9, 0.9, 1, 1, 1
            )

            -- List individual active quests in this zone
            local quests = addon.Scores and addon.Scores.GetQuestsForZone and addon.Scores.GetQuestsForZone(d.zoneName)
            if quests and #quests > 0 then
                for _, qID in ipairs(quests) do
                    local qWorth, qBreak = addon.Engine.CalculateWorth(qID)
                    local info = Utils.GetQuestBasicInfo(qID)
                    if info and qWorth then
                        local badge = Utils.FormatBadge(qWorth, qBreak and qBreak.isComplete, qBreak and qBreak.isHard)
                        GameTooltip:AddLine(string.format("  * %s %s", badge, info.title), 0.8, 0.8, 0.8)
                    end
                end
            end
        else
            GameTooltip:AddDoubleLine(
                "|cff00ccffActive Quests in Log:|r",
                "|cff8888880 Quests (Zone evaluation based on Level Bracket)|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        -- Recommendation
        if d.recommendation then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff00ff00Leveling Advice:|r", 1, 1, 1)
            GameTooltip:AddLine(string.format("  |cffcccccc%s|r", d.recommendation), 0.9, 0.9, 0.9, true)
        end

        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    mapBanner = frame
    return mapBanner
end

function UI.UpdateWorldMapBanner()
    if not (addon.db and addon.db.enabled and addon.db.showInWorldMap ~= false) then
        if mapBanner then mapBanner:Hide() end
        return
    end

    if not WorldMapFrame or not WorldMapFrame:IsShown() then
        if mapBanner then mapBanner:Hide() end
        return
    end

    local mapID = (WorldMapFrame.GetMapID and WorldMapFrame:GetMapID())
    if not mapID or mapID <= 0 then
        if C_Map and C_Map.GetBestMapForUnit then
            mapID = C_Map.GetBestMapForUnit("player")
        end
    end

    if not mapID or mapID <= 0 then
        if mapBanner then mapBanner:Hide() end
        return
    end

    local zoneName, mapInfo = ResolveZoneName(mapID)
    if not zoneName then
        if mapBanner then mapBanner:Hide() end
        return
    end

    local res = addon.Engine and addon.Engine.CalculateWorldMapZoneWorth and addon.Engine.CalculateWorldMapZoneWorth(zoneName)
    if not res then
        if mapBanner then mapBanner:Hide() end
        return
    end

    local banner = CreateWorldMapBanner()
    if not banner then return end

    banner.data = res

    local badge = Utils.FormatBadge(res.worth, false)
    local statusColor = (res.worth >= 0.70 and "|cff00ff00") or (res.worth >= 0.50 and "|cffffff00") or "|cffff3333"

    local levelStr = ""
    if res.minLevel and res.maxLevel and res.minLevel > 0 and res.maxLevel > 0 then
        levelStr = string.format(" |cff888888(%d-%d)|r", res.minLevel, res.maxLevel)
    end

    local displayText
    if res.activeCount and res.activeCount > 0 then
        displayText = string.format("%s |cffffffff%s|r%s  %s%s|r  |cffffcc00[Log: %.0f%% (%d Qs)]|r",
            badge, res.zoneName, levelStr, statusColor, res.status, (res.activeWorth or 0) * 100, res.activeCount)
    else
        displayText = string.format("%s |cffffffff%s|r%s  %s%s|r  |cff888888[0 Quests in Log]|r",
            badge, res.zoneName, levelStr, statusColor, res.status)
    end

    banner.Text:SetText(displayText)

    -- Dynamic width with comfortable padding
    local textWidth = banner.Text:GetStringWidth() or 220
    banner:SetWidth(math.max(240, textWidth + 28))

    banner:Show()
end

-- Reactive frame that watches map navigation, zooming, and clicking in real time
local mapWatcher = CreateFrame("Frame", "WorthIt_MapWatcherFrame")
local _lastWatchedMapID = nil
local _watchThrottle = 0

local function OnMapWatchUpdate(self, elapsed)
    _watchThrottle = _watchThrottle + elapsed
    if _watchThrottle < 0.10 then return end
    _watchThrottle = 0

    if not (WorldMapFrame and WorldMapFrame:IsShown()) then
        _lastWatchedMapID = nil
        if mapBanner and mapBanner:IsShown() then mapBanner:Hide() end
        return
    end

    local currentMapID = (WorldMapFrame.GetMapID and WorldMapFrame:GetMapID())
    if currentMapID ~= _lastWatchedMapID then
        _lastWatchedMapID = currentMapID
        UI.UpdateWorldMapBanner()
    end
end

function UI.InitializeWorldMap()
    if not WorldMapFrame then return end

    -- Start hidden: only runs OnUpdate while WorldMapFrame is actively visible
    mapWatcher:Hide()
    mapWatcher:SetScript("OnUpdate", OnMapWatchUpdate)

    WorldMapFrame:HookScript("OnShow", function()
        _lastWatchedMapID = nil
        mapWatcher:Show()
        UI.UpdateWorldMapBanner()
    end)

    WorldMapFrame:HookScript("OnHide", function()
        _lastWatchedMapID = nil
        mapWatcher:Hide()
        if mapBanner and mapBanner:IsShown() then
            mapBanner:Hide()
        end
    end)

    -- Also hook explicit Blizzard events/methods as backup
    if WorldMapFrame.OnMapChanged then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
            _lastWatchedMapID = nil
            UI.UpdateWorldMapBanner()
        end)
    end

    if WorldMapFrame.SetMapID then
        hooksecurefunc(WorldMapFrame, "SetMapID", function()
            _lastWatchedMapID = nil
            UI.UpdateWorldMapBanner()
        end)
    end
end
