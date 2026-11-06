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

    local scrollContainer = (WorldMapFrame.ScrollContainer) or WorldMapFrame
    local frame = CreateFrame("Button", "WorthItWorldMapBanner", WorldMapFrame, "BackdropTemplate")
    frame:SetHeight(24)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 25)

    -- Anchor directly above the map canvas so it never obstructs zone titles (e.g. Westfall (10-20) / Fishing)
    if WorldMapFrame.ScrollContainer then
        frame:SetPoint("BOTTOM", WorldMapFrame.ScrollContainer, "TOP", 0, 4)
    else
        frame:SetPoint("TOP", WorldMapFrame, "TOP", 0, -28)
    end

    -- Backdrop styling: sleek dark panel with subtle border
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frame:SetBackdropColor(0.05, 0.05, 0.08, 0.92)
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

-- =========================================================================
-- ZONE ADVISOR SIDEBAR (RANKED LEVELING ZONES ON THE LEFT OF WORLD MAP)
-- =========================================================================

local advisorPanel = nil
local advisorToggleButton = nil
local advisorRows = {}

local function CreateZoneAdvisorToggle(parent)
    if advisorToggleButton then return advisorToggleButton end
    if not parent then return nil end

    local btn = CreateFrame("Button", "WorthItAdvisorToggleButton", parent, "BackdropTemplate")
    btn:SetSize(96, 24)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -8)
    btn:SetFrameStrata("HIGH")
    btn:SetFrameLevel(parent:GetFrameLevel() + 15)

    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn:SetBackdropColor(0.06, 0.08, 0.12, 0.92)
    btn:SetBackdropBorderColor(0.20, 0.60, 0.90, 0.90)

    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    txt:SetPoint("CENTER", btn, "CENTER", 0, 0)
    txt:SetText("|cff00ccff[≡ Zones %]|r")
    btn.Text = txt

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.12, 0.18, 0.26, 0.95)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, -4)
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cff00ccffWorthIt: Zone Advisor|r", 1, 1, 1)
        GameTooltip:AddLine("Click to toggle the leveling zone ranking sidebar.", 0.9, 0.9, 0.9, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.06, 0.08, 0.12, 0.92)
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
    row:SetWidth(230)

    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    local hl = row:GetHighlightTexture()
    if hl then hl:SetAlpha(0.25) end

    local badgeFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    badgeFS:SetPoint("LEFT", row, "LEFT", 2, 0)
    row.Badge = badgeFS

    local rightFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rightFS:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row.RightTag = rightFS

    local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nameFS:SetPoint("LEFT", badgeFS, "RIGHT", 4, 0)
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

        local fColor = (d.faction == "Alliance" and "|cff0070dd") or (d.faction == "Horde" and "|cffc41f3b") or "|cffffff00"
        GameTooltip:AddDoubleLine(
            "|cff00ccffTerritory:|r",
            fColor .. d.faction .. "|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )

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
                        local badge = Utils.FormatBadge(qWorth, qBreak and qBreak.isComplete, qBreak and qBreak.isHard)
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
    panel:SetWidth(256)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -36)
    panel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 8, 24)
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(parent:GetFrameLevel() + 25)

    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    panel:SetBackdropColor(0.04, 0.05, 0.08, 0.95)
    panel:SetBackdropBorderColor(0.20, 0.50, 0.80, 0.95)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -8)
    title:SetText("|cff00ccffZone Advisor|r")

    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetSize(18, 18)
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -3, -3)
    closeBtn:SetScript("OnClick", function()
        UI.ToggleZoneAdvisor(false)
    end)

    local filterAll = CreateFrame("Button", nil, panel, "BackdropTemplate")
    local filterOpt = CreateFrame("Button", nil, panel, "BackdropTemplate")
    local filterQ   = CreateFrame("Button", nil, panel, "BackdropTemplate")

    local function SetupFilterBtn(btn, text, width)
        btn:SetSize(width, 18)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 12, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        local t = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        t:SetPoint("CENTER", btn, "CENTER", 0, 0)
        t:SetText(text)
        btn.Text = t
    end

    SetupFilterBtn(filterAll, "All", 50)
    SetupFilterBtn(filterOpt, "Optimal (70%+)", 105)
    SetupFilterBtn(filterQ, "In Log", 65)

    filterAll:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -28)
    filterOpt:SetPoint("LEFT", filterAll, "RIGHT", 4, 0)
    filterQ:SetPoint("LEFT", filterOpt, "RIGHT", 4, 0)

    local function UpdateFilterVisuals()
        local cur = addon.db and addon.db.zoneAdvisorFilter or "ALL"
        filterAll:SetBackdropColor(cur == "ALL" and 0.15 or 0.05, cur == "ALL" and 0.35 or 0.05, cur == "ALL" and 0.60 or 0.08, 0.90)
        filterOpt:SetBackdropColor(cur == "OPTIMAL" and 0.15 or 0.05, cur == "OPTIMAL" and 0.35 or 0.05, cur == "OPTIMAL" and 0.60 or 0.08, 0.90)
        filterQ:SetBackdropColor(cur == "ACTIVE" and 0.15 or 0.05, cur == "ACTIVE" and 0.35 or 0.05, cur == "ACTIVE" and 0.60 or 0.08, 0.90)
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

    local scrollFrame = CreateFrame("ScrollFrame", "WorthIt_AdvisorScrollFrame", panel)
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 6)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(230)
    scrollChild:SetHeight(200)
    scrollFrame:SetScrollChild(scrollChild)

    local slider = CreateFrame("Slider", "WorthIt_AdvisorSlider", scrollFrame, "BackdropTemplate")
    slider:SetWidth(8)
    slider:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -52)
    slider:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -4, 8)
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    slider:SetBackdropColor(0.02, 0.02, 0.04, 0.60)
    slider:SetBackdropBorderColor(0.15, 0.20, 0.30, 0.80)

    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb = slider:GetThumbTexture()
    thumb:SetColorTexture(0.20, 0.60, 0.95, 0.85)
    thumb:SetSize(6, 24)

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

    if addon.Data and addon.Data.Zones then
        for name, zData in pairs(addon.Data.Zones) do
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
                    }
                end
            end
            seen[name] = true
        end
    end

    if addon.Scores and addon.Scores.ZoneQuests then
        for zName in pairs(addon.Scores.ZoneQuests) do
            if not seen[zName] and not (addon.Scores.IsNonZoneHeader and addon.Scores.IsNonZoneHeader(zName)) then
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
                        }
                    end
                end
                seen[zName] = true
            end
        end
    end

    table.sort(list, function(a, b)
        if math.abs(a.res.worth - b.res.worth) > 0.001 then
            return a.res.worth > b.res.worth
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
        row.Name:SetText(item.name)

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
