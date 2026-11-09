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

-- Helper to return inline texture markup for continent faction symbols
local function GetContinentMarkup(continent)
    if continent == 1 then
        -- Kalimdor -> Horde Crest
        return "|TInterface\\TargetingFrame\\UI-PVP-Horde:14:14:0:0:64:64:3:38:3:38|t"
    elseif continent == 2 then
        -- Eastern Kingdoms -> Alliance Crest
        return "|TInterface\\TargetingFrame\\UI-PVP-Alliance:14:14:0:0:64:64:3:38:3:38|t"
    end
    return ""
end

-- Helper to update a row's continent faction icon texture (Kalimdor = Horde, Eastern Kingdoms = Alliance)
local function UpdateRowContinentIcon(icon, continent)
    if not icon then return end
    if continent == 1 then
        -- Kalimdor -> Horde Crest Symbol
        local set = false
        if icon.SetAtlas then
            local ok = pcall(icon.SetAtlas, icon, "factionicon-horde")
            if ok and icon:GetTexture() then set = true end
        end
        if not set then
            icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde")
            icon:SetTexCoord(0.04, 0.60, 0.04, 0.60)
        else
            icon:SetTexCoord(0, 1, 0, 1)
        end
        icon:SetSize(16, 16)
        icon:Show()
    elseif continent == 2 then
        -- Eastern Kingdoms -> Alliance Crest Symbol
        local set = false
        if icon.SetAtlas then
            local ok = pcall(icon.SetAtlas, icon, "factionicon-alliance")
            if ok and icon:GetTexture() then set = true end
        end
        if not set then
            icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance")
            icon:SetTexCoord(0.04, 0.60, 0.04, 0.60)
        else
            icon:SetTexCoord(0, 1, 0, 1)
        end
        icon:SetSize(16, 16)
        icon:Show()
    else
        icon:SetSize(0.001, 16)
        icon:Hide()
    end
end

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

    local scrollContainer = (WorldMapFrame.ScrollContainer) or WorldMapFrame
    local frame = CreateFrame("Button", "WorthItWorldMapBanner", WorldMapFrame, "BackdropTemplate")
    frame:SetHeight(24)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 25)

    -- Anchor directly above the map canvas so it never obstructs zone titles (e.g. Westfall (10-20) / Fishing)
    frame:ClearAllPoints()
    if WorldMapFrame.ScrollContainer then
        frame:SetPoint("BOTTOM", WorldMapFrame.ScrollContainer, "TOP", 0, 4)
    else
        frame:SetPoint("TOP", WorldMapFrame, "TOP", 0, -28)
    end

    -- Backdrop styling: authentic Blizzard dark slate panel with gold border
    frame:SetBackdrop({
        bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0.06, 0.06, 0.08, 0.95)
    frame:SetBackdropBorderColor(0.70, 0.58, 0.32, 0.95)

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

        -- Effective Minimum Entry (if different from raw bracket min)
        if d.effectiveMin and d.minLevel and d.effectiveMin ~= d.minLevel then
            GameTooltip:AddDoubleLine(
                "|cff00ccffEffective Entry:|r",
                string.format("|cffffcc00Level %d+|r |cff888888(%s Hubs)|r", d.effectiveMin, d.faction == "Contested" and "Faction" or d.faction),
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        -- Class Mob Synergy / Penalty
        if d.classModifier and d.classModifier ~= 0 then
            local modSign = d.classModifier > 0 and "+" or ""
            local modColor = d.classModifier > 0 and "|cff00ff00" or "|cffff4444"
            local reasonText = (d.classModifierReason and d.classModifierReason ~= "") and string.format(" |cffaaaaaa(%s)|r", d.classModifierReason) or ""
            GameTooltip:AddDoubleLine(
                "|cff00ccffClass Mob Synergy:|r",
                string.format("%s%s%.0f%%%s|r", modColor, modSign, d.classModifier * 100, reasonText),
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        -- Travel Friction
        if d.travelPenalty and d.travelPenalty > 0 then
            local reasonText = (d.travelReason and d.travelReason ~= "") and string.format(" |cffaaaaaa(%s)|r", d.travelReason) or " |cffaaaaaa(Cross-Continent)|r"
            GameTooltip:AddDoubleLine(
                "|cff00ccffTravel Friction:|r",
                string.format("|cffff8844-%.0f%%%s|r", d.travelPenalty * 100, reasonText),
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        -- Territory / Faction
        local fColor = (d.faction == "Alliance" and "|cff0070dd") or (d.faction == "Horde" and "|cffc41f3b") or "|cffffff00"
        GameTooltip:AddDoubleLine(
            "|cff00ccffTerritory:|r",
            fColor .. d.faction .. "|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )

        -- Continent (Kalimdor = Horde, Eastern Kingdoms = Alliance)
        local cont = d.continent or (addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(d.zoneName) and addon.Data.GetZoneInfo(d.zoneName).continent)
        if cont == 1 then
            local hordeIcon = "|TInterface\\TargetingFrame\\UI-PVP-Horde:14:14:0:0:64:64:3:38:3:38|t"
            GameTooltip:AddDoubleLine(
                "|cff00ccffContinent:|r",
                hordeIcon .. " |cffc41f3bKalimdor|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        elseif cont == 2 then
            local allianceIcon = "|TInterface\\TargetingFrame\\UI-PVP-Alliance:14:14:0:0:64:64:3:38:3:38|t"
            GameTooltip:AddDoubleLine(
                "|cff00ccffContinent:|r",
                allianceIcon .. " |cff0070ddEastern Kingdoms|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

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
                        local badge = Utils.FormatBadge(qWorth, qBreak and qBreak.isComplete, qBreak and qBreak.isHard, qBreak and qBreak.isBankable)
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

    local cont = res.continent or (addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(res.zoneName) and addon.Data.GetZoneInfo(res.zoneName).continent)
    local contMarkup = GetContinentMarkup(cont)
    local contPrefix = (contMarkup ~= "") and (contMarkup .. " ") or ""

    local displayText
    if res.activeCount and res.activeCount > 0 then
        displayText = string.format("%s %s|cffffffff%s|r%s  %s%s|r  |cffffcc00[Log: %.0f%% (%d Qs)]|r",
            badge, contPrefix, res.zoneName, levelStr, statusColor, res.status, (res.activeWorth or 0) * 100, res.activeCount)
    else
        displayText = string.format("%s %s|cffffffff%s|r%s  %s%s|r  |cff888888[0 Quests in Log]|r",
            badge, contPrefix, res.zoneName, levelStr, statusColor, res.status)
    end

    banner.Text:SetText(displayText)

    -- Dynamic width with comfortable padding
    local textWidth = banner.Text:GetStringWidth() or 220
    banner:SetWidth(math.max(240, textWidth + 28))

    banner:Show()
end

-- =========================================================================
-- ZONE ADVISOR SIDEBAR (RANKED LEVELING ZONES ON THE LEFT OF WORLD MAP)
-- =========================================================================

local advisorPanel = nil
local advisorToggleButton = nil
local advisorRows = {}

local function CreateZoneAdvisorToggle(parent)
    if advisorToggleButton then return advisorToggleButton end
    if not parent then return nil end

    local btn = CreateFrame("Button", "WorthItAdvisorToggleButton", parent, "UIPanelButtonTemplate")
    btn:SetSize(116, 22)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -6)
    btn:SetFrameStrata("HIGH")
    btn:SetFrameLevel(parent:GetFrameLevel() + 15)

    btn:SetText("Zone Advisor")
    if btn:GetFontString() then
        btn:GetFontString():SetFontObject("GameFontNormalSmall")
        btn:GetFontString():SetTextColor(1, 0.82, 0, 1) -- Blizzard Gold
    end

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, -4)
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cffffd100QuestWorth: Zone Advisor|r", 1, 1, 1)
        GameTooltip:AddLine("Click to toggle the leveling zone ranking sidebar.", 0.9, 0.9, 0.9, true)
        GameTooltip:AddLine("Shows recommended leveling zones ranked by Worth %, with continent crests.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    btn:SetScript("OnClick", function()
        UI.ToggleZoneAdvisor()
    end)

    advisorToggleButton = btn
    return advisorToggleButton
end

local function CreateAdvisorRow(index, parent)
    local row = CreateFrame("Button", "WorthItAdvisorRow" .. index, parent, "BackdropTemplate")
    row:SetHeight(24)
    row:SetWidth(236)

    -- Authentic Blizzard Quest Title Highlight on mouse hover
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    local hl = row:GetHighlightTexture()
    if hl then
        hl:SetAlpha(0.35)
        hl:SetAllPoints(row)
    end

    -- Alternating subtle row stripe for readability (like standard WoW tables)
    local stripe = row:CreateTexture(nil, "BACKGROUND")
    stripe:SetAllPoints(row)
    if index % 2 == 0 then
        stripe:SetColorTexture(1, 1, 1, 0.025)
    else
        stripe:SetColorTexture(0, 0, 0, 0.20)
    end
    row.Stripe = stripe

    local badgeFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    badgeFS:SetPoint("LEFT", row, "LEFT", 4, 0)
    badgeFS:SetWidth(42)
    badgeFS:SetJustifyH("LEFT")
    row.Badge = badgeFS

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", badgeFS, "RIGHT", 1, 0)
    row.ContinentIcon = icon

    local rightFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rightFS:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    rightFS:SetWidth(48)
    rightFS:SetJustifyH("RIGHT")
    row.RightTag = rightFS

    local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameFS:SetPoint("LEFT", icon, "RIGHT", 4, 0)
    nameFS:SetPoint("RIGHT", rightFS, "LEFT", -4, 0)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetWordWrap(false)
    row.Name = nameFS

    row:SetScript("OnEnter", function(self)
        if not self.data then return end
        local d = self.data
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 4, 0)
        GameTooltip:ClearLines()

        local colorHex = Utils.GetScoreColorHex(d.worth)
        local levelText = (d.minLevel and d.maxLevel) and string.format(" |cff888888(Level %d - %d)|r", d.minLevel, d.maxLevel) or ""
        GameTooltip:AddDoubleLine(
            string.format("|cffffffff%s|r%s", d.zoneName, levelText),
            string.format("|cff%sZone Worth: %.0f%%|r", colorHex, d.worth * 100),
            1, 1, 1, 1, 1, 1
        )
        GameTooltip:AddLine(" ")

        local statusColor = (d.worth >= 0.70 and "|cff00ff00") or (d.worth >= 0.50 and "|cffffff00") or "|cffff3333"
        GameTooltip:AddDoubleLine(
            "|cff00ccffSuitability:|r",
            string.format("%s%s|r", statusColor, d.status),
            0.9, 0.9, 0.9, 1, 1, 1
        )

        -- Effective Minimum Entry (if different from raw bracket min)
        if d.effectiveMin and d.minLevel and d.effectiveMin ~= d.minLevel then
            GameTooltip:AddDoubleLine(
                "|cff00ccffEffective Entry:|r",
                string.format("|cffffcc00Level %d+|r |cff888888(%s Hubs)|r", d.effectiveMin, d.faction == "Contested" and "Faction" or d.faction),
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        -- Class Mob Synergy / Penalty
        if d.classModifier and d.classModifier ~= 0 then
            local modSign = d.classModifier > 0 and "+" or ""
            local modColor = d.classModifier > 0 and "|cff00ff00" or "|cffff4444"
            local reasonText = (d.classModifierReason and d.classModifierReason ~= "") and string.format(" |cffaaaaaa(%s)|r", d.classModifierReason) or ""
            GameTooltip:AddDoubleLine(
                "|cff00ccffClass Mob Synergy:|r",
                string.format("%s%s%.0f%%%s|r", modColor, modSign, d.classModifier * 100, reasonText),
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        -- Travel Friction
        if d.travelPenalty and d.travelPenalty > 0 then
            local reasonText = (d.travelReason and d.travelReason ~= "") and string.format(" |cffaaaaaa(%s)|r", d.travelReason) or " |cffaaaaaa(Cross-Continent)|r"
            GameTooltip:AddDoubleLine(
                "|cff00ccffTravel Friction:|r",
                string.format("|cffff8844-%.0f%%%s|r", d.travelPenalty * 100, reasonText),
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        local fColor = (d.faction == "Alliance" and "|cff0070dd") or (d.faction == "Horde" and "|cffc41f3b") or "|cffffff00"
        GameTooltip:AddDoubleLine(
            "|cff00ccffTerritory:|r",
            fColor .. d.faction .. "|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )

        local cont = d.continent or (addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(d.zoneName) and addon.Data.GetZoneInfo(d.zoneName).continent)
        if cont == 1 then
            local hordeIcon = "|TInterface\\TargetingFrame\\UI-PVP-Horde:14:14:0:0:64:64:3:38:3:38|t"
            GameTooltip:AddDoubleLine(
                "|cff00ccffContinent:|r",
                hordeIcon .. " |cffc41f3bKalimdor|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        elseif cont == 2 then
            local allianceIcon = "|TInterface\\TargetingFrame\\UI-PVP-Alliance:14:14:0:0:64:64:3:38:3:38|t"
            GameTooltip:AddDoubleLine(
                "|cff00ccffContinent:|r",
                allianceIcon .. " |cff0070ddEastern Kingdoms|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end

        if d.activeCount and d.activeCount > 0 then
            local qColorHex = Utils.GetScoreColorHex(d.activeWorth or 0.5)
            GameTooltip:AddDoubleLine(
                "|cff00ccffActive Quests in Log:|r",
                string.format("|cff%s%d Quests (%.0f%% Avg)|r", qColorHex, d.activeCount, (d.activeWorth or 0) * 100),
                0.9, 0.9, 0.9, 1, 1, 1
            )
            local quests = addon.Scores and addon.Scores.GetQuestsForZone and addon.Scores.GetQuestsForZone(d.zoneName)
            if quests and #quests > 0 then
                for _, qID in ipairs(quests) do
                    local qWorth, qBreak = addon.Engine.CalculateWorth(qID)
                    local info = Utils.GetQuestBasicInfo(qID)
                    if info and qWorth then
                        local badge = Utils.FormatBadge(qWorth, qBreak and qBreak.isComplete, qBreak and qBreak.isHard, qBreak and qBreak.isBankable)
                        GameTooltip:AddLine(string.format("  * %s %s", badge, info.title), 0.8, 0.8, 0.8)
                    end
                end
            end
        end

        if d.recommendation then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff00ff00Leveling Advice:|r", 1, 1, 1)
            GameTooltip:AddLine(string.format("  |cffcccccc%s|r", d.recommendation), 0.9, 0.9, 0.9, true)
        end

        if self.mapID and self.mapID > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff00ccffClick to view this zone on the map.|r", 0.7, 0.9, 1)
        end

        GameTooltip:Show()
    end)

    row:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    row:SetScript("OnClick", function(self)
        if self.mapID and self.mapID > 0 and WorldMapFrame and WorldMapFrame.SetMapID then
            WorldMapFrame:SetMapID(self.mapID)
            if PlaySound then
                pcall(PlaySound, SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856)
            end
        end
    end)

    advisorRows[index] = row
    return row
end

local function CreateZoneAdvisorPanel(parent)
    if advisorPanel then return advisorPanel end
    if not parent then return nil end

    local panel = CreateFrame("Frame", "WorthItZoneAdvisorPanel", parent, "BackdropTemplate")
    panel:SetWidth(272)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -32)
    panel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 8, 22)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(parent:GetFrameLevel() + 25)

    -- Authentic Blizzard Warcraft panel backdrop: Deep slate rock with antique gold border
    panel:SetBackdrop({
        bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel:SetBackdropColor(0.06, 0.06, 0.08, 0.96)
    panel:SetBackdropBorderColor(0.70, 0.58, 0.32, 0.95)

    -- Header Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    if not title:GetFont() then
        title:SetFontObject("GameFontNormal")
    end
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -10)
    title:SetText("|cffffd100Zone Advisor|r")

    -- Subtle sub-label
    local subTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subTitle:SetPoint("LEFT", title, "RIGHT", 6, 0)
    subTitle:SetText("|cff888888Leveling Guide|r")

    -- Blizzard Close Button
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
    closeBtn:SetScript("OnClick", function()
        UI.ToggleZoneAdvisor(false)
    end)

    -- Decorative gold header divider line
    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(2)
    divider:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -28)
    divider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -28)
    divider:SetColorTexture(0.55, 0.45, 0.22, 0.80)

    -- Filter Buttons using Blizzard UIPanelButtonTemplate
    local filterAll = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    local filterOpt = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    local filterQ   = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")

    local function SetupFilterBtn(btn, text, width)
        btn:SetSize(width, 20)
        btn:SetText(text)
        if btn:GetFontString() then
            btn:GetFontString():SetFontObject("GameFontNormalSmall")
        end
    end

    SetupFilterBtn(filterAll, "All", 54)
    SetupFilterBtn(filterOpt, "Optimal (70%+)", 116)
    SetupFilterBtn(filterQ,   "In Log", 72)

    filterAll:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -34)
    filterOpt:SetPoint("LEFT", filterAll, "RIGHT", 4, 0)
    filterQ:SetPoint("LEFT", filterOpt, "RIGHT", 4, 0)

    local function UpdateFilterVisuals()
        local cur = addon.db and addon.db.zoneAdvisorFilter or "ALL"
        local function styleBtn(btn, isActive)
            local fs = btn:GetFontString()
            if fs then
                if isActive then
                    fs:SetTextColor(1, 0.95, 0.40, 1) -- Bright Gold
                else
                    fs:SetTextColor(0.75, 0.75, 0.75, 0.9) -- Muted Silver
                end
            end
        end
        styleBtn(filterAll, cur == "ALL")
        styleBtn(filterOpt, cur == "OPTIMAL")
        styleBtn(filterQ, cur == "ACTIVE")
    end

    filterAll:SetScript("OnClick", function()
        if addon.db then addon.db.zoneAdvisorFilter = "ALL" end
        UpdateFilterVisuals()
        UI.UpdateZoneAdvisor()
    end)

    filterOpt:SetScript("OnClick", function()
        if addon.db then addon.db.zoneAdvisorFilter = "OPTIMAL" end
        UpdateFilterVisuals()
        UI.UpdateZoneAdvisor()
    end)

    filterQ:SetScript("OnClick", function()
        if addon.db then addon.db.zoneAdvisorFilter = "ACTIVE" end
        UpdateFilterVisuals()
        UI.UpdateZoneAdvisor()
    end)

    panel.UpdateFilterVisuals = UpdateFilterVisuals

    -- Content Inset Panel (Inner recessed dark parchment area for the zone list)
    local inset = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    inset:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -58)
    inset:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 8)
    inset:SetBackdrop({
        bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    inset:SetBackdropColor(0.02, 0.02, 0.03, 0.90)
    inset:SetBackdropBorderColor(0.30, 0.25, 0.18, 0.75)

    -- ScrollFrame inside inset
    local scrollFrame = CreateFrame("ScrollFrame", "WorthIt_AdvisorScrollFrame", inset)
    scrollFrame:SetPoint("TOPLEFT", inset, "TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", -16, 4)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(236)
    scrollChild:SetHeight(200)
    scrollFrame:SetScrollChild(scrollChild)

    -- Blizzard styled scrollbar slider
    local slider = CreateFrame("Slider", "WorthIt_AdvisorSlider", scrollFrame, "BackdropTemplate")
    slider:SetWidth(10)
    slider:SetPoint("TOPRIGHT", inset, "TOPRIGHT", -4, -14)
    slider:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", -4, 14)
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 6,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    slider:SetBackdropColor(0.02, 0.02, 0.03, 0.80)
    slider:SetBackdropBorderColor(0.35, 0.30, 0.20, 0.80)

    slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    local thumb = slider:GetThumbTexture()
    thumb:SetSize(14, 20)

    slider:SetOrientation("VERTICAL")
    slider:SetMinMaxValues(0, 100)
    slider:SetValue(0)
    slider:SetScript("OnValueChanged", function(self, val)
        scrollFrame:SetVerticalScroll(val)
    end)

    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local maxScroll = math.max(0, scrollChild:GetHeight() - self:GetHeight())
        if maxScroll <= 0 then return end
        local cur = self:GetVerticalScroll()
        local nextScroll = math.max(0, math.min(maxScroll, cur - (delta * 36)))
        self:SetVerticalScroll(nextScroll)
        slider:SetValue(nextScroll)
    end)

    panel.scrollFrame = scrollFrame
    panel.scrollChild = scrollChild
    panel.slider = slider

    local emptyText = inset:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyText:SetPoint("CENTER", inset, "CENTER", 0, 0)
    emptyText:SetWidth(200)
    emptyText:SetJustifyH("CENTER")
    emptyText:SetTextColor(0.65, 0.65, 0.65, 1)
    emptyText:Hide()
    panel.emptyText = emptyText

    advisorPanel = panel
    return advisorPanel
end

function UI.UpdateZoneAdvisor()
    if not advisorPanel or not advisorPanel:IsShown() then return end
    if advisorPanel.UpdateFilterVisuals then
        advisorPanel.UpdateFilterVisuals()
    end

    local curFilter = addon.db and addon.db.zoneAdvisorFilter or "ALL"
    local list = {}
    local seen = {}

    local playerClass = (addon.Player and addon.Player.GetClass and addon.Player.GetClass())
    if not playerClass then
        local _, c = UnitClass("player")
        playerClass = c or "WARRIOR"
    end
    local playerFaction = (addon.Player and addon.Player.GetFaction and addon.Player.GetFaction()) or UnitFactionGroup("player") or "Alliance"

    if addon.Data and addon.Data.Zones then
        for name, zData in pairs(addon.Data.Zones) do
            local isCity = zData.isCity
            local reqClass = zData.class
            local faction = zData.faction

            local skip = false
            -- 1. Never show major cities in Zone Advisor (cities are hubs/economy, not leveling zones)
            if isCity then
                skip = true
            end
            -- 2. Never show class-restricted zones if player is not that class (e.g. Moonglade for non-Druids)
            if reqClass and reqClass ~= playerClass then
                skip = true
            end
            -- 3. Never show enemy faction zones unless player has active quests there
            if faction and faction ~= "Contested" and faction ~= "Neutral" and faction ~= playerFaction then
                local quests = addon.Scores and addon.Scores.GetQuestsForZone and addon.Scores.GetQuestsForZone(name)
                if not quests or #quests == 0 then
                    skip = true
                end
            end

            if not skip then
                local res = addon.Engine and addon.Engine.CalculateWorldMapZoneWorth and addon.Engine.CalculateWorldMapZoneWorth(name)
                if res then
                    local include = true
                    if curFilter == "OPTIMAL" then
                        include = (res.worth >= 0.70)
                    elseif curFilter == "ACTIVE" then
                        include = (res.activeCount and res.activeCount > 0)
                    end

                    if include then
                        list[#list + 1] = {
                            name = name,
                            res = res,
                            mapID = zData.mapID,
                            continent = zData.continent,
                        }
                    end
                end
            end
            seen[name] = true
        end
    end

    if addon.Scores and addon.Scores.ZoneQuests then
        for zName in pairs(addon.Scores.ZoneQuests) do
            if not seen[zName] and not (addon.Scores.IsNonZoneHeader and addon.Scores.IsNonZoneHeader(zName)) then
                local zInfo = addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(zName)
                local isCity = zInfo and zInfo.isCity
                local reqClass = zInfo and zInfo.class
                local skip = isCity or (reqClass and reqClass ~= playerClass)

                if not skip then
                    local res = addon.Engine and addon.Engine.CalculateWorldMapZoneWorth and addon.Engine.CalculateWorldMapZoneWorth(zName)
                    if res and res.activeCount and res.activeCount > 0 then
                        local include = true
                        if curFilter == "OPTIMAL" and res.worth < 0.70 then
                            include = false
                        end
                        if include then
                            list[#list + 1] = {
                                name = zName,
                                res = res,
                                mapID = nil,
                                continent = zInfo and zInfo.continent,
                            }
                        end
                    end
                end
                seen[zName] = true
            end
        end
    end

    local playerRace = (addon.Player and addon.Player.GetRace and addon.Player.GetRace())
    if not playerRace then
        local _, r = UnitRace("player")
        playerRace = r or "Human"
    end
    local homeCont = addon.Engine and addon.Engine.GetHomeContinent and addon.Engine.GetHomeContinent(playerRace)

    table.sort(list, function(a, b)
        if math.abs(a.res.worth - b.res.worth) > 0.005 then
            return a.res.worth > b.res.worth
        end
        -- Home continent tie-breaker for low-level travel proximity
        if homeCont and a.continent ~= b.continent then
            if a.continent == homeCont then return true end
            if b.continent == homeCont then return false end
        end
        local aMin = a.res.minLevel or 99
        local bMin = b.res.minLevel or 99
        if aMin ~= bMin then
            return aMin < bMin
        end
        return a.name < b.name
    end)

    local rowHeight = 24
    local child = advisorPanel.scrollChild
    for i = 1, #list do
        local item = list[i]
        local row = advisorRows[i] or CreateAdvisorRow(i, child)
        row.data = item.res
        row.mapID = item.mapID

        local badge = Utils.FormatBadge(item.res.worth, false)
        row.Badge:SetText(badge)

        -- Dynamic text hierarchy matching Quest Log styling (Gold for optimal, White for standard, Silver for low)
        local nameColor = (item.res.worth >= 0.70 and "|cffffd100") or (item.res.worth >= 0.50 and "|cffffffff") or "|cffaaaaaa"
        row.Name:SetText(nameColor .. item.name .. "|r")

        -- Update continent faction symbol (Kalimdor = Horde, Eastern Kingdoms = Alliance)
        local cont = item.continent or (item.res and item.res.continent)
        UpdateRowContinentIcon(row.ContinentIcon, cont)

        if item.res.activeCount and item.res.activeCount > 0 then
            row.RightTag:SetText(string.format("|cffffcc00[%dQ]|r", item.res.activeCount))
        elseif item.res.minLevel and item.res.maxLevel then
            row.RightTag:SetText(string.format("|cff888888(%d-%d)|r", item.res.minLevel, item.res.maxLevel))
        else
            row.RightTag:SetText("")
        end

        row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -((i - 1) * rowHeight))
        row:Show()
    end

    for i = #list + 1, #advisorRows do
        advisorRows[i]:Hide()
    end

    if #list == 0 then
        if advisorPanel.emptyText then
            local msg
            if curFilter == "ACTIVE" then
                msg = "No active quests in log\nfor any zone."
            elseif curFilter == "OPTIMAL" then
                msg = "No optimal (70%+)\nzones found."
            else
                msg = "No zones available."
            end
            advisorPanel.emptyText:SetText(msg)
            advisorPanel.emptyText:Show()
        end
    else
        if advisorPanel.emptyText then
            advisorPanel.emptyText:Hide()
        end
    end

    local totalHeight = #list * rowHeight
    child:SetHeight(math.max(1, totalHeight))
    local maxScroll = math.max(0, totalHeight - advisorPanel.scrollFrame:GetHeight())
    advisorPanel.slider:SetMinMaxValues(0, maxScroll)
    if advisorPanel.scrollFrame:GetVerticalScroll() > maxScroll then
        advisorPanel.scrollFrame:SetVerticalScroll(maxScroll)
        advisorPanel.slider:SetValue(maxScroll)
    end
end

function UI.ToggleZoneAdvisor(enable)
    local parent = (WorldMapFrame.ScrollContainer) or WorldMapFrame
    if not parent then return end

    local panel = CreateZoneAdvisorPanel(parent)
    local toggle = CreateZoneAdvisorToggle(parent)

    local targetState
    if enable ~= nil then
        targetState = enable
    else
        targetState = not panel:IsShown()
    end

    if addon.db then
        addon.db.showZoneAdvisor = targetState
    end

    pcall(function()
        if targetState then
            panel:Show()
            UI.UpdateZoneAdvisor()
            if toggle then
                toggle.Text:SetText("|cff00ff00[◀ Zones]|r")
            end
        else
            panel:Hide()
            if toggle then
                toggle.Text:SetText("|cff00ccff[≡ Zones %]|r")
            end
        end
    end)
end

-- Reactive frame that watches map navigation, zooming, and clicking in real time
local mapWatcher = CreateFrame("Frame", "WorthIt_MapWatcherFrame")
local _lastWatchedMapID = nil
local _watchThrottle = 0

local function OnMapWatchUpdate(self, elapsed)
    _watchThrottle = _watchThrottle + elapsed
    if _watchThrottle < 0.10 then return end
    _watchThrottle = 0

    if InCombatLockdown and InCombatLockdown() then return end

    if not (WorldMapFrame and WorldMapFrame:IsShown()) then
        _lastWatchedMapID = nil
        if mapBanner and mapBanner:IsShown() then mapBanner:Hide() end
        if advisorPanel and advisorPanel:IsShown() then advisorPanel:Hide() end
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

    local parent = (WorldMapFrame.ScrollContainer) or WorldMapFrame
    CreateZoneAdvisorToggle(parent)
    CreateZoneAdvisorPanel(parent)

    -- Start hidden: only runs OnUpdate while WorldMapFrame is actively visible
    mapWatcher:Hide()
    mapWatcher:SetScript("OnUpdate", OnMapWatchUpdate)

    WorldMapFrame:HookScript("OnShow", function()
        _lastWatchedMapID = nil
        mapWatcher:Show()
        UI.UpdateWorldMapBanner()
        if addon.db and addon.db.showZoneAdvisor ~= false then
            UI.ToggleZoneAdvisor(true)
        else
            UI.ToggleZoneAdvisor(false)
        end
    end)

    WorldMapFrame:HookScript("OnHide", function()
        _lastWatchedMapID = nil
        mapWatcher:Hide()
        if mapBanner and mapBanner:IsShown() then
            mapBanner:Hide()
        end
        if advisorPanel and advisorPanel:IsShown() then
            advisorPanel:Hide()
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
