--[[
    WorthIt / QuestWorth - UI/WorldMap.lua
    World Map Zone Worth Banner & Hover Breakdown.
    Displays zone suitability and leveling recommendations directly on the map.
]]

local addonName, addon = ...
addon.UI = addon.UI or {}
local UI = addon.UI
local Utils = addon.Utils
local L = addon.L

local mapBanner = nil

local function CreateWorldMapBanner()
    if mapBanner then return mapBanner end
    if not WorldMapFrame then return nil end

    local parent = (WorldMapFrame.ScrollContainer) or WorldMapFrame
    local frame = CreateFrame("Button", "WorthItWorldMapBanner", parent, "BackdropTemplate")
    frame:SetHeight(26)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(parent:GetFrameLevel() + 10)

    -- Anchor top center of the map
    frame:SetPoint("TOP", parent, "TOP", 0, -8)

    -- Backdrop styling
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

    -- Tooltip on hover
    frame:SetScript("OnEnter", function(self)
        if not self.data then return end
        local d = self.data
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
        GameTooltip:ClearLines()

        local colorHex = Utils.GetScoreColorHex(d.worth)
        GameTooltip:AddDoubleLine(
            string.format("|cffffffff%s|r |cff888888(Level %d - %d)|r", d.zoneName, d.minLevel, d.maxLevel),
            string.format("|cff%sZone Worth: %.0f%%|r", colorHex, d.worth * 100),
            1, 1, 1, 1, 1, 1
        )
        GameTooltip:AddLine(" ")

        -- Suitability / Status
        GameTooltip:AddDoubleLine(
            "|cff00ccffSuitability:|r",
            string.format("|cff%s%s|r", colorHex, d.status),
            0.9, 0.9, 0.9, 1, 1, 1
        )

        -- Territory / Faction
        local fColor = (d.faction == "Alliance" and "|cff0070dd") or (d.faction == "Horde" and "|cffc41f3b") or "|cffffff00"
        GameTooltip:AddDoubleLine(
            "|cff00ccffTerritory:|r",
            fColor .. d.faction .. "|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )

        -- Active Quests
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
                "|cff888888None|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        -- Recommendation
        if d.recommendation then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff00ff00Recommendation:|r", 1, 1, 1)
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

    local mapInfo = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    if not mapInfo or not mapInfo.name then
        if mapBanner then mapBanner:Hide() end
        return
    end

    local res = addon.Engine and addon.Engine.CalculateWorldMapZoneWorth and addon.Engine.CalculateWorldMapZoneWorth(mapInfo.name)
    if not res then
        if mapBanner then mapBanner:Hide() end
        return
    end

    local banner = CreateWorldMapBanner()
    if not banner then return end

    banner.data = res

    local badge = Utils.FormatBadge(res.worth, false)
    local statusColor = (res.worth >= 0.70 and "|cff00ff00") or (res.worth >= 0.50 and "|cffffff00") or "|cffff3333"

    local displayText
    if res.activeCount and res.activeCount > 0 then
        displayText = string.format("%s |cffffffff%s|r |cff888888(%d-%d)|r  %s%s|r |cffaaaaaa(%d in Log)|r",
            badge, res.zoneName, res.minLevel, res.maxLevel, statusColor, res.status, res.activeCount)
    else
        displayText = string.format("%s |cffffffff%s|r |cff888888(%d-%d)|r  %s%s|r",
            badge, res.zoneName, res.minLevel, res.maxLevel, statusColor, res.status)
    end

    banner.Text:SetText(displayText)

    -- Dynamic width with comfortable padding
    local textWidth = banner.Text:GetStringWidth() or 220
    banner:SetWidth(math.max(220, textWidth + 24))

    banner:Show()
end

function UI.InitializeWorldMap()
    if not WorldMapFrame then return end

    if WorldMapFrame.OnMapChanged then
        hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
            UI.UpdateWorldMapBanner()
        end)
    end

    if WorldMapFrame.SetMapID then
        hooksecurefunc(WorldMapFrame, "SetMapID", function()
            UI.UpdateWorldMapBanner()
        end)
    end

    WorldMapFrame:HookScript("OnShow", function()
        UI.UpdateWorldMapBanner()
    end)
end
