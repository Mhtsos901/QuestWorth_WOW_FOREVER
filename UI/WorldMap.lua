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

-- Helper to return inline texture markup for continent faction symbols or dungeon icon
local function GetContinentMarkup(continent, isDungeon)
    if isDungeon then
        return "|TInterface\\LFGFrame\\LFG-Eye:14:14:0:0:512:256:0:64:0:64|t"
    elseif continent == 1 then
        -- Kalimdor -> Horde Crest
        return "|TInterface\\TargetingFrame\\UI-PVP-Horde:14:14:0:0:64:64:3:38:3:38|t"
    elseif continent == 2 then
        -- Eastern Kingdoms -> Alliance Crest
        return "|TInterface\\TargetingFrame\\UI-PVP-Alliance:14:14:0:0:64:64:3:38:3:38|t"
    end
    return ""
end

-- Helper to update a row's continent faction or dungeon icon texture
-- (Dungeon = Dungeon Portal/Eye, Kalimdor = Horde Crest, Eastern Kingdoms = Alliance Crest)
local function UpdateRowContinentIcon(icon, continent, isDungeon)
    if not icon then return end

    -- Always clear any active Atlas before switching textures so Dungeon atlases never stick on Continent rows
    if icon.SetAtlas then
        pcall(icon.SetAtlas, icon, nil)
    end
    if icon.SetTexture then
        icon:SetTexture(nil)
    end

    if isDungeon then
        local set = false
        if icon.SetAtlas then
            local atlases = { "groupfinder-icon-dungeon", "dungeon", "Dungeon" }
            for _, atlas in ipairs(atlases) do
                if not C_Texture or not C_Texture.GetAtlasInfo or C_Texture.GetAtlasInfo(atlas) then
                    local ok = pcall(icon.SetAtlas, icon, atlas)
                    local tex = ok and icon.GetTexture and icon:GetTexture()
                    local curAtlas = ok and icon.GetAtlas and icon:GetAtlas()
                    if ok and (curAtlas == atlas or (tex and tex ~= "" and tex ~= "Atlas:nil")) then
                        set = true
                        break
                    end
                end
            end
        end
        if not set then
            if icon.SetAtlas then pcall(icon.SetAtlas, icon, nil) end
            icon:SetTexture("Interface\\LFGFrame\\LFG-Eye")
            icon:SetTexCoord(0, 0.125, 0, 0.25)
        else
            icon:SetTexCoord(0, 1, 0, 1)
        end
        icon:SetSize(16, 16)
        icon:Show()
    elseif continent == 1 then
        -- Kalimdor -> Horde Crest Symbol (mirrors GetContinentMarkup)
        icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Horde")
        icon:SetTexCoord(0.04, 0.60, 0.04, 0.60)
        icon:SetSize(16, 16)
        icon:Show()
    elseif continent == 2 then
        -- Eastern Kingdoms -> Alliance Crest Symbol (mirrors GetContinentMarkup)
        icon:SetTexture("Interface\\TargetingFrame\\UI-PVP-Alliance")
        icon:SetTexCoord(0.04, 0.60, 0.04, 0.60)
        icon:SetSize(16, 16)
        icon:Show()
    else
        icon:SetSize(0.001, 16)
        icon:Hide()
    end
end

local DUNGEON_SET = {
    ["the deadmines"] = true, ["deadmines"] = true,
    ["wailing caverns"] = true,
    ["shadowfang keep"] = true,
    ["blackfathom deeps"] = true,
    ["the stockade"] = true, ["stockade"] = true,
    ["gnomeregan"] = true,
    ["razorfen kraul"] = true,
    ["scarlet monastery"] = true,
    ["razorfen downs"] = true,
    ["uldaman"] = true,
    ["zul'farrak"] = true,
    ["maraudon"] = true,
    ["sunken temple"] = true, ["the temple of atal'hakkar"] = true, ["temple of atal'hakkar"] = true,
    ["blackrock depths"] = true,
    ["lower blackrock spire"] = true, ["upper blackrock spire"] = true, ["blackrock spire"] = true,
    ["dire maul"] = true,
    ["scholomance"] = true,
    ["stratholme"] = true,
    ["ragefire chasm"] = true,
    ["hall of thanes"] = true,
    ["ruins of lordaeron"] = true,
    ["excavation site: wetlands"] = true,
    ["city of dalaran"] = true,
    ["the drowned city"] = true, ["drowned city"] = true,
    ["krol'dok stronghold"] = true,
    ["alcaz prison"] = true,
    ["blackmaw hold"] = true,
    ["shaper's terrace"] = true,
}

local function IsDungeonZone(name)
    if not name then return false end
    local zInfo = addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(name)
    if zInfo and zInfo.isDungeon then return true end
    local lower = string.lower(name)
    if DUNGEON_SET[lower] then return true end
    local noThe = string.gsub(lower, "^the%s+", "")
    if DUNGEON_SET[noThe] then return true end
    return false
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

-- Shared helper to populate rich Zone Breakdown & Leveling Guide tooltips (for Map Banner & Advisor Rows)
local function PopulateZoneTooltip(tooltip, d, isDungeonHint, rankIndex, showClickHint)
    if not tooltip or not d then return end

    local colorHex = Utils.GetScoreColorHex(d.worth)
    local levelText = (d.minLevel and d.maxLevel) and string.format(" |cff888888(Level %d - %d)|r", d.minLevel, d.maxLevel) or ""
    tooltip:AddDoubleLine(
        string.format("|cffffffff%s|r%s", d.zoneName, levelText),
        string.format("|cff%sZone Worth: %.0f%%|r", colorHex, d.worth * 100),
        1, 1, 1, 1, 1, 1
    )

    local pLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
    if rankIndex and d.worth >= 0.70 then
        if rankIndex == 1 then
            tooltip:AddLine(string.format("|cffffd100* #1 Best Leveling Choice for Level %d|r", pLevel), 1, 0.85, 0)
        else
            tooltip:AddLine(string.format("|cff00ccffRanked #%d Optimal Zone for Level %d|r", rankIndex, pLevel), 0.5, 0.9, 1)
        end
    end

    tooltip:AddLine(" ")

    -- Suitability & Sweet Spot
    local statusColor = (d.worth >= 0.70 and "|cff00ff00") or (d.worth >= 0.50 and "|cffffff00") or "|cffff3333"
    local sweetInfo = (d.sweetMin and d.sweetMax) and string.format(" |cff888888(Sweet Spot: %d-%d)|r", d.sweetMin, d.sweetMax) or ""
    tooltip:AddDoubleLine(
        "|cff00ccffSuitability:|r",
        string.format("%s%s|r%s", statusColor, d.status, sweetInfo),
        0.9, 0.9, 0.9, 1, 1, 1
    )

    -- Effective Minimum Entry (if different from raw bracket min)
    if d.effectiveMin and d.minLevel and d.effectiveMin ~= d.minLevel then
        tooltip:AddDoubleLine(
            "|cff00ccffEffective Entry:|r",
            string.format("|cffffcc00Level %d+|r |cff888888(%s Hubs)|r", d.effectiveMin, d.faction == "Contested" and "Faction" or d.faction),
            0.9, 0.9, 0.9, 1, 1, 1
        )
    end

    -- Faction Quest Hubs & Density Tier
    if d.hubName and d.hubName ~= "" then
        tooltip:AddDoubleLine(
            "|cff00ccffQuest Hubs:|r",
            "|cffffffff" .. d.hubName .. "|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )
    end

    if d.densityLabel then
        local dColor = "|cffffff00"
        if d.densityLabel == "Very High" or d.densityLabel == "High" then
            dColor = "|cff00ff00"
        elseif d.densityLabel == "Low" or d.densityLabel == "Sparse" then
            dColor = "|cffff6644"
        end
        tooltip:AddDoubleLine(
            "|cff00ccffQuest Density:|r",
            dColor .. d.densityLabel .. "|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )
    end

    -- Zone Score Breakdown
    tooltip:AddLine(" ")
    tooltip:AddLine("|cff888888Zone Score Breakdown:|r", 0.7, 0.7, 0.7)

    local brkPct = (d.bracketScore or 0.5) * 100
    local brkColor = (brkPct >= 85 and "|cff00ff00") or (brkPct >= 70 and "|cffffff00") or "|cffff6644"
    tooltip:AddDoubleLine(
        "  |cffa0a0a0Level Sweet-Spot:|r",
        string.format("%s%.0f%%|r |cff888888(Lvl %d)|r", brkColor, brkPct, pLevel),
        0.8, 0.8, 0.8, 1, 1, 1
    )

    if d.hubMod and d.hubMod ~= 0 then
        local sign = d.hubMod > 0 and "+" or ""
        local col = d.hubMod > 0 and "|cff00ff00" or "|cffff4444"
        tooltip:AddDoubleLine(
            "  |cffa0a0a0Hub Richness:|r",
            string.format("%s%s%.0f%%|r |cff888888(%s)|r", col, sign, d.hubMod * 100, d.densityLabel or "Density"),
            0.8, 0.8, 0.8, 1, 1, 1
        )
    end

    if d.classModifier and d.classModifier ~= 0 then
        local modSign = d.classModifier > 0 and "+" or ""
        local modColor = d.classModifier > 0 and "|cff00ff00" or "|cffff4444"
        local reasonText = (d.classModifierReason and d.classModifierReason ~= "") and string.format(" |cffaaaaaa(%s)|r", d.classModifierReason) or ""
        local classLabel = (isDungeonHint or d.isDungeon) and "  |cffa0a0a0Class Loot & XP:|r" or "  |cffa0a0a0Class & Terrain:|r"
        tooltip:AddDoubleLine(
            classLabel,
            string.format("%s%s%.0f%%%s|r", modColor, modSign, d.classModifier * 100, reasonText),
            0.8, 0.8, 0.8, 1, 1, 1
        )
    end

    if d.territoryBonus and d.territoryBonus > 0 then
        tooltip:AddDoubleLine(
            "  |cffa0a0a0Territory Safety:|r",
            string.format("|cff00ff00+%.0f%%|r |cff888888(%s Hub)|r", d.territoryBonus * 100, d.faction or "Friendly"),
            0.8, 0.8, 0.8, 1, 1, 1
        )
    end

    if d.travelPenalty and d.travelPenalty > 0 then
        local reasonText = (d.travelReason and d.travelReason ~= "") and string.format(" |cffaaaaaa(%s)|r", d.travelReason) or " |cffaaaaaa(Cross-Continent)|r"
        tooltip:AddDoubleLine(
            "  |cffa0a0a0Travel Friction:|r",
            string.format("|cffff8844-%.0f%%%s|r", d.travelPenalty * 100, reasonText),
            0.8, 0.8, 0.8, 1, 1, 1
        )
    end

    -- Dungeon Class Loot & XP vs Open-World Questing
    if isDungeonHint or (d and d.isDungeon) or IsDungeonZone(d.zoneName) then
        tooltip:AddLine(" ")
        local dungIcon = "|TInterface\\LFGFrame\\LFG-Eye:14:14:0:0:512:256:0:64:0:64|t"
        tooltip:AddDoubleLine(
            "|cff00ccffZone Type:|r",
            dungIcon .. " |cffffd1005-Player Dungeon Instance|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )
        if d.vsWorldQuesting then
            local vColor = ((d.classModifier or 0) >= 0.04 and "|cff00ff00") or ((d.classModifier or 0) >= 0.00 and "|cffffff00") or "|cffff6644"
            tooltip:AddDoubleLine(
                "|cff00ccffvs World Questing:|r",
                vColor .. d.vsWorldQuesting .. "|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end
        if d.dungeonQuestCount then
            local qCol = (d.dungeonQuestCount >= 5 and "|cff00ff00") or (d.dungeonQuestCount >= 3 and "|cffffff00") or "|cffff6644"
            tooltip:AddDoubleLine(
                "|cff00ccffDungeon Quests:|r",
                string.format("%s%d Faction Quests|r", qCol, d.dungeonQuestCount),
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end
        if d.dungeonLoot and d.dungeonLoot ~= "" then
            local pClass = (addon.Player and addon.Player.GetClass and addon.Player.GetClass()) or "Class"
            tooltip:AddDoubleLine(
                string.format("|cff00ccffKey %s Loot:|r", pClass),
                "|cffffd100" .. d.dungeonLoot .. "|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end
        if d.isCompletedDungeon then
            tooltip:AddDoubleLine(
                "|cff00ccffCompletion:|r",
                "|cff00ff00Completed by Player (Click checkbox to unmark)|r",
                0.9, 0.9, 0.9, 1, 1, 1
            )
        end
    else
        tooltip:AddLine(" ")
    end

    local fColor = (d.faction == "Alliance" and "|cff0070dd") or (d.faction == "Horde" and "|cffc41f3b") or "|cffffff00"
    tooltip:AddDoubleLine(
        "|cff00ccffTerritory:|r",
        fColor .. (d.faction or "Contested") .. "|r",
        0.9, 0.9, 0.9, 1, 1, 1
    )

    local cont = d.continent or (addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(d.zoneName) and addon.Data.GetZoneInfo(d.zoneName).continent)
    if cont == 1 then
        local hordeIcon = "|TInterface\\TargetingFrame\\UI-PVP-Horde:14:14:0:0:64:64:3:38:3:38|t"
        tooltip:AddDoubleLine(
            "|cff00ccffContinent:|r",
            hordeIcon .. " |cffc41f3bKalimdor|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )
    elseif cont == 2 then
        local allianceIcon = "|TInterface\\TargetingFrame\\UI-PVP-Alliance:14:14:0:0:64:64:3:38:3:38|t"
        tooltip:AddDoubleLine(
            "|cff00ccffContinent:|r",
            allianceIcon .. " |cff0070ddEastern Kingdoms|r",
            0.9, 0.9, 0.9, 1, 1, 1
        )
    end

    -- Curated Zone Summary & Recommendation
    local guideText = d.recommendation or d.zoneSummary
    if guideText and guideText ~= "" then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff00ff00Why Choose This Zone:|r", 1, 1, 1)
        tooltip:AddLine(string.format("  |cffcccccc%s|r", guideText), 0.9, 0.9, 0.9, true)
        if d.zoneSummary and d.zoneSummary ~= "" and d.zoneSummary ~= guideText then
            tooltip:AddLine(string.format("  |cff99ccff%s|r", d.zoneSummary), 0.8, 0.9, 1.0, true)
        end
    end

    -- Meta Quests Left in Zone (live completion check against player faction/class)
    if (not addon.db or addon.db.showMetaIndicator ~= false) and addon.Utils and addon.Utils.GetZoneMetaSummary then
        local metaSum = addon.Utils.GetZoneMetaSummary(d.zoneName)
        if metaSum and metaSum.total > 0 then
            tooltip:AddLine(" ")
            local star = (addon.Utils and addon.Utils.META_ICON) or ""
            local leftLabel = "  " .. star .. " |cffffd100" .. (L["META_LEFT_IN_ZONE"] or "Meta Quests Left:") .. "|r"
            if metaSum.remaining == 0 then
                tooltip:AddDoubleLine(
                    leftLabel,
                    string.format("|cff1aff4d%s (%d/%d)|r", L["META_ALL_DONE"] or "All Done", metaSum.done, metaSum.total),
                    1, 1, 1, 1, 1, 1
                )
            else
                tooltip:AddDoubleLine(
                    leftLabel,
                    string.format("|cffffd100%d Left|r |cffaaaaaa(%d/%d Done)|r", metaSum.remaining, metaSum.done, metaSum.total),
                    1, 1, 1, 1, 1, 1
                )
                local maxShow = 4
                for idx = 1, math.min(#metaSum.remainingItems, maxShow) do
                    local m = metaSum.remainingItems[idx]
                    local tBadge = (addon.Utils and addon.Utils.GetMetaTagBadge and addon.Utils.GetMetaTagBadge(m.tag)) or ("[" .. m.tag .. "]")
                    local logNote = m.inLog and " |cff1aff4d(In Log)|r" or ""
                    local detail = (m.reason and m.reason ~= "") and m.reason or (m.title or ("Quest #" .. m.questID))
                    tooltip:AddLine(string.format("    %s |cffffffff%s|r%s |cffaaaaaa— %s|r",
                        tBadge, m.title or ("Quest #" .. m.questID), logNote, detail), 0.9, 0.9, 0.9, true)
                end
                if #metaSum.remainingItems > maxShow then
                    tooltip:AddLine(string.format("    |cff888888...and %d more (/qw meta for full list)|r", #metaSum.remainingItems - maxShow), 0.7, 0.7, 0.7)
                end
            end
        end
    end

    if showClickHint then
        tooltip:AddLine(" ")
        tooltip:AddLine("|cff00ccffClick to view this zone on the map.|r", 0.7, 0.9, 1)
    end
end

local STRATA_RANK = {
    BACKGROUND = 1,
    LOW = 2,
    MEDIUM = 3,
    HIGH = 4,
    DIALOG = 5,
    FULLSCREEN = 6,
    FULLSCREEN_DIALOG = 7,
    TOOLTIP = 8,
}

local function GetMapAnchorFrame()
    if not WorldMapFrame then return nil end
    local sc = WorldMapFrame.ScrollContainer
    if sc and (not sc.IsShown or sc:IsShown()) then
        return sc
    end
    return WorldMapFrame
end

local function SyncMapWidgetLayer(widget, offset)
    if not (widget and WorldMapFrame) then return end
    local bestStrata = "HIGH"
    local bestRank = STRATA_RANK[bestStrata]
    local maxLvl = 1

    for pass = 1, 3 do
        local f = (pass == 1 and WorldMapFrame) or (pass == 2 and WorldMapFrame.BorderFrame) or WorldMapFrame.ScrollContainer
        if f then
            if f.GetFrameStrata then
                local s = f:GetFrameStrata()
                local r = s and STRATA_RANK[s]
                if r and r > bestRank then
                    bestRank = r
                    bestStrata = s
                end
            end
            if f.GetFrameLevel then
                local lvl = f:GetFrameLevel() or 1
                if lvl > maxLvl then maxLvl = lvl end
            end
        end
    end

    local targetLevel = math.min(maxLvl + 9020 + (offset or 0), 9930)
    if widget.GetFrameStrata and widget.SetFrameStrata and widget:GetFrameStrata() ~= bestStrata then
        widget:SetFrameStrata(bestStrata)
    end
    if widget.GetFrameLevel and widget.SetFrameLevel and widget:GetFrameLevel() ~= targetLevel then
        widget:SetFrameLevel(targetLevel)
    end
end

local function CreateWorldMapBanner()
    if mapBanner then
        if WorldMapFrame and mapBanner.GetParent and mapBanner:GetParent() ~= WorldMapFrame and mapBanner.SetParent then
            mapBanner:SetParent(WorldMapFrame)
        end
        SyncMapWidgetLayer(mapBanner, 5)
        return mapBanner
    end
    if not WorldMapFrame then return nil end

    local frame = CreateFrame("Button", "WorthItWorldMapBanner", WorldMapFrame, "BackdropTemplate")
    frame:SetHeight(20)
    SyncMapWidgetLayer(frame, 5)

    -- Anchor directly at the height of the Zones % button (Y = -1 on ScrollContainer)
    local anchor = GetMapAnchorFrame() or WorldMapFrame
    frame._qwAnchor = anchor
    frame:ClearAllPoints()
    if WorldMapFrame.ScrollContainer and anchor == WorldMapFrame.ScrollContainer then
        frame:SetPoint("TOP", anchor, "TOP", 0, -1)
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
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
        GameTooltip:ClearLines()
        PopulateZoneTooltip(GameTooltip, self.data, self.isDungeon, nil, false)
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
    banner.isDungeon = res.isDungeon

    -- Keep anchor and strata/level synced only when changed
    local anchor = GetMapAnchorFrame() or WorldMapFrame
    if banner._qwAnchor ~= anchor then
        banner._qwAnchor = anchor
        banner:ClearAllPoints()
        if WorldMapFrame.ScrollContainer and anchor == WorldMapFrame.ScrollContainer then
            banner:SetPoint("TOP", anchor, "TOP", 0, -1)
        else
            banner:SetPoint("TOP", WorldMapFrame, "TOP", 0, -28)
        end
    end

    local badge = res.isCompletedDungeon and "|cff00ff00[Done]|r" or Utils.FormatBadge(res.worth, false, false, false, res.isLowValue)
    local statusColor = (res.isCompletedDungeon and "|cff88cc88") or (res.worth >= 0.70 and "|cff00ff00") or (res.worth >= 0.50 and "|cffffff00") or "|cffff3333"

    local levelStr = ""
    if res.minLevel and res.maxLevel and res.minLevel > 0 and res.maxLevel > 0 then
        levelStr = string.format(" |cff888888(%d-%d)|r", res.minLevel, res.maxLevel)
    end

    local cont = res.continent or (addon.Data and addon.Data.GetZoneInfo and addon.Data.GetZoneInfo(res.zoneName) and addon.Data.GetZoneInfo(res.zoneName).continent)
    local contMarkup = GetContinentMarkup(cont, res.isDungeon)
    local contPrefix = (contMarkup ~= "") and (contMarkup .. " ") or ""

    local metaSuffix = ""
    if (not addon.db or addon.db.showMetaIndicator ~= false) and Utils and Utils.GetZoneMetaSummary then
        local metaSum = Utils.GetZoneMetaSummary(res.zoneName, true)
        if metaSum and metaSum.remaining > 0 then
            metaSuffix = string.format("  %s |cffffd100%d Meta|r", (Utils and Utils.META_ICON) or "", metaSum.remaining)
        end
    end

    -- Display only the core zone evaluation without cluttering with Log quest count
    local displayText = string.format("%s %s|cffffffff%s|r%s  %s%s|r%s",
        badge, contPrefix, res.zoneName, levelStr, statusColor, res.status, metaSuffix)

    if banner._lastDisplayText ~= displayText then
        banner._lastDisplayText = displayText
        banner.Text:SetText(displayText)
        local textWidth = (banner.Text and banner.Text.GetStringWidth and banner.Text:GetStringWidth()) or 180
        banner:SetWidth(math.max(190, textWidth + 24))
        banner:SetHeight(20)
    end

    if not banner:IsShown() then
        banner:Show()
    end
end

-- =========================================================================
-- ZONE ADVISOR SIDEBAR (RANKED LEVELING ZONES ON THE LEFT OF WORLD MAP)
-- =========================================================================

local advisorPanel = nil
local advisorToggleButton = nil
local advisorRows = {}

local function UpdateAdvisorToggleText(btn, isOpen)
    if not btn then return end
    local text = isOpen and "|cff00ff00[< Zones]|r" or "|cff00ccff[Zones %]|r"
    if btn.SetText then btn:SetText(text) end
    if btn.Text and btn.Text.SetText then btn.Text:SetText(text) end
    local fs = btn.GetFontString and btn:GetFontString()
    if fs and fs.SetText then fs:SetText(text) end
end

local function CreateZoneAdvisorToggle(anchor)
    local parent = WorldMapFrame or anchor
    local targetAnchor = anchor or GetMapAnchorFrame() or parent
    if advisorToggleButton then
        if parent and advisorToggleButton.GetParent and advisorToggleButton:GetParent() ~= parent and advisorToggleButton.SetParent then
            advisorToggleButton:SetParent(parent)
        end
        if targetAnchor and advisorToggleButton._worthItAnchor ~= targetAnchor then
            advisorToggleButton:ClearAllPoints()
            advisorToggleButton:SetPoint("TOPLEFT", targetAnchor, "TOPLEFT", 8, -1)
            advisorToggleButton._worthItAnchor = targetAnchor
        end
        SyncMapWidgetLayer(advisorToggleButton, 8)
        return advisorToggleButton
    end
    if not parent then return nil end

    local btn = CreateFrame("Button", "WorthItAdvisorToggleButton", parent, "UIPanelButtonTemplate")
    btn._worthItAnchor = targetAnchor
    btn:SetSize(106, 20)
    btn:SetPoint("TOPLEFT", targetAnchor, "TOPLEFT", 8, -1)
    SyncMapWidgetLayer(btn, 8)

    UpdateAdvisorToggleText(btn, false)
    if btn.GetFontString and btn:GetFontString() then
        btn:GetFontString():SetFontObject("GameFontNormalSmall")
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
    row:SetHeight(34)
    row:SetWidth(250)
    if row.SetClipsChildren then
        row:SetClipsChildren(true)
    end

    -- Authentic Blizzard Quest Title Highlight on mouse hover
    row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    local hl = row.GetHighlightTexture and row:GetHighlightTexture()
    if hl then
        hl:SetAlpha(0.35)
        hl:SetAllPoints(row)
    end

    -- Alternating subtle row stripe for readability (like standard WoW tables)
    local stripe = row:CreateTexture(nil, "BACKGROUND")
    stripe:SetAllPoints(row)
    if index % 2 == 0 then
        stripe:SetColorTexture(1, 1, 1, 0.03)
    else
        stripe:SetColorTexture(0, 0, 0, 0.22)
    end
    row.Stripe = stripe

    local badgeFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    badgeFS:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -4)
    badgeFS:SetWidth(42)
    badgeFS:SetJustifyH("LEFT")
    row.Badge = badgeFS

    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", badgeFS, "RIGHT", 1, 0)
    row.ContinentIcon = icon

    local rightFS = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rightFS:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -4)
    rightFS:SetWidth(52)
    rightFS:SetJustifyH("RIGHT")
    row.RightTag = rightFS

    local nameFS = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameFS:SetPoint("LEFT", icon, "RIGHT", 4, 0)
    nameFS:SetPoint("RIGHT", rightFS, "LEFT", -4, 0)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetWordWrap(false)
    row.Name = nameFS

    -- Line 2: Clear 1-line explanation of why the zone got this score
    local subFS = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subFS:SetPoint("TOPLEFT", row, "TOPLEFT", 48, -19)
    subFS:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    subFS:SetJustifyH("LEFT")
    subFS:SetWordWrap(false)
    row.SubText = subFS

    local doneBtn = CreateFrame("Button", "WorthItAdvisorRowDoneBtn" .. index, row)
    doneBtn:SetSize(16, 16)
    doneBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -3)
    doneBtn:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight", "ADD")

    local doneBg = doneBtn:CreateTexture(nil, "BACKGROUND")
    doneBg:SetAllPoints(doneBtn)
    doneBg:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
    doneBtn.Bg = doneBg

    local doneCheck = doneBtn:CreateTexture(nil, "OVERLAY")
    doneCheck:SetAllPoints(doneBtn)
    doneCheck:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    doneCheck:Hide()
    doneBtn.Check = doneCheck

    doneBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 4, 0)
        GameTooltip:ClearLines()
        local isDone = self.zoneName and addon.DB and addon.DB.IsDungeonCompleted and addon.DB.IsDungeonCompleted(self.zoneName)
        if isDone then
            GameTooltip:AddLine("Dungeon Completed", 0, 1, 0)
            GameTooltip:AddLine("Click to unmark as completed and return to Advisor list.", 1, 1, 1, true)
        else
            GameTooltip:AddLine("Mark Dungeon Completed", 1, 0.82, 0)
            GameTooltip:AddLine("Click if you already cleared this dungeon's quests.", 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)

    doneBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    doneBtn:SetScript("OnClick", function(self)
        if not self.zoneName or not addon.DB or not addon.DB.ToggleDungeonCompleted then return end
        local nowDone = addon.DB.ToggleDungeonCompleted(self.zoneName)
        if nowDone then
            self.Check:Show()
        else
            self.Check:Hide()
        end
        if PlaySound then
            pcall(PlaySound, SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856)
        end
        if UI.UpdateZoneAdvisor then
            UI.UpdateZoneAdvisor()
        end
        if UI.UpdateWorldMapBanner then
            UI.UpdateWorldMapBanner()
        end
        if GameTooltip and GameTooltip.IsOwned and GameTooltip:IsOwned(self) then
            if self:IsShown() then
                local onEnter = self:GetScript("OnEnter")
                if onEnter then onEnter(self) end
            else
                GameTooltip:Hide()
            end
        end
    end)

    doneBtn:Hide()
    row.DoneBtn = doneBtn

    row:SetScript("OnEnter", function(self)
        if not self.data then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 4, 0)
        GameTooltip:ClearLines()
        PopulateZoneTooltip(GameTooltip, self.data, self.isDungeon, self.rankIndex, self.mapID and self.mapID > 0)
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

local function CreateZoneAdvisorPanel(anchor)
    local parent = WorldMapFrame or anchor
    local targetAnchor = anchor or GetMapAnchorFrame() or parent
    if advisorPanel then
        if parent and advisorPanel.GetParent and advisorPanel:GetParent() ~= parent and advisorPanel.SetParent then
            advisorPanel:SetParent(parent)
        end
        if targetAnchor and advisorPanel._worthItAnchor ~= targetAnchor then
            advisorPanel:ClearAllPoints()
            advisorPanel:SetPoint("TOPLEFT", targetAnchor, "TOPLEFT", 8, -25)
            advisorPanel:SetPoint("BOTTOMLEFT", targetAnchor, "BOTTOMLEFT", 8, 22)
            advisorPanel._worthItAnchor = targetAnchor
        end
        SyncMapWidgetLayer(advisorPanel, 12)
        return advisorPanel
    end
    if not parent then return nil end

    local panel = CreateFrame("Frame", "WorthItZoneAdvisorPanel", parent, "BackdropTemplate")
    panel._worthItAnchor = targetAnchor
    panel:SetWidth(286)
    panel:SetPoint("TOPLEFT", targetAnchor, "TOPLEFT", 8, -25)
    panel:SetPoint("BOTTOMLEFT", targetAnchor, "BOTTOMLEFT", 8, 22)
    SyncMapWidgetLayer(panel, 12)

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
    subTitle:SetText("|cff888888Ranked by Efficiency|r")

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
    local filterQ   = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")

    local function SetupFilterBtn(btn, text, width)
        btn:SetSize(width, 20)
        btn:SetText(text)
        if btn:GetFontString() then
            btn:GetFontString():SetFontObject("GameFontNormalSmall")
        end
    end

    SetupFilterBtn(filterAll, "All", 129)
    SetupFilterBtn(filterQ,   "Dungeons", 129)

    filterAll:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -34)
    filterQ:SetPoint("LEFT", filterAll, "RIGHT", 4, 0)

    local function UpdateFilterVisuals()
        local cur = (addon.db and addon.db.zoneAdvisorFilter == "DUNGEONS") and "DUNGEONS" or "ALL"
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
        styleBtn(filterQ, cur == "DUNGEONS")
    end

    filterAll:SetScript("OnClick", function()
        if addon.db then addon.db.zoneAdvisorFilter = "ALL" end
        if panel.scrollFrame and panel.slider then
            panel.scrollFrame:SetVerticalScroll(0)
            panel.slider:SetValue(0)
        end
        UpdateFilterVisuals()
        UI.UpdateZoneAdvisor()
    end)

    filterQ:SetScript("OnClick", function()
        if addon.db then addon.db.zoneAdvisorFilter = "DUNGEONS" end
        if panel.scrollFrame and panel.slider then
            panel.scrollFrame:SetVerticalScroll(0)
            panel.slider:SetValue(0)
        end
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
    scrollChild:SetWidth(250)
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

    if slider.SetThumbTexture then
        slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    end
    local thumb = slider.GetThumbTexture and slider:GetThumbTexture()
    if thumb and thumb.SetSize then
        thumb:SetSize(14, 20)
    end

    if slider.SetOrientation then
        slider:SetOrientation("VERTICAL")
    end
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

local _advisorList = {}
local _advisorItemPool = {}

function UI.UpdateZoneAdvisor()
    if not advisorPanel or not advisorPanel:IsShown() then return end
    SyncMapWidgetLayer(advisorPanel, 12)
    if advisorToggleButton then
        SyncMapWidgetLayer(advisorToggleButton, 8)
    end
    if advisorPanel.UpdateFilterVisuals then
        advisorPanel.UpdateFilterVisuals()
    end

    local curFilter = addon.db and addon.db.zoneAdvisorFilter or "ALL"
    local list = _advisorList
    local listCount = 0

    local playerClass = (addon.Player and addon.Player.GetClass and addon.Player.GetClass())
    if not playerClass then
        local _, c = UnitClass("player")
        playerClass = c or "WARRIOR"
    end
    local playerFaction = (addon.Player and addon.Player.GetFaction and addon.Player.GetFaction()) or UnitFactionGroup("player") or "Alliance"

    if addon.Data and addon.Data.Zones then
        local pLevel = (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1
        for name, zData in pairs(addon.Data.Zones) do
            local isCity = zData.isCity
            local reqClass = zData.class
            local faction = zData.faction
            local isDung = zData.isDungeon or IsDungeonZone(name)

            local skip = zData.isAlias and true or false
            -- 1. Never show major cities in Zone Advisor (cities are hubs/economy, not leveling zones)
            if isCity then
                skip = true
            end
            -- 2. Never show class-restricted zones if player is not that class (e.g. Moonglade for non-Druids)
            if reqClass and reqClass ~= playerClass then
                skip = true
            end
            -- 3. Never show enemy faction zones
            if faction and faction ~= "Contested" and faction ~= "Neutral" and faction ~= playerFaction then
                skip = true
            end
            -- 4. Filter by Dungeon vs Zone mode & level bracket (never count quests in log)
            if curFilter == "DUNGEONS" then
                if not isDung then
                    skip = true
                else
                    local isCompleted = addon.DB and addon.DB.IsDungeonCompleted and addon.DB.IsDungeonCompleted(name)
                    if not isCompleted then
                        local minL = zData.min or 1
                        local maxL = zData.max or 60
                        if pLevel < (minL - 8) or pLevel > (maxL + 6) then
                            skip = true
                        end
                    end
                end
            elseif isDung then
                local minL = zData.min or 1
                local maxL = zData.max or 60
                if pLevel < (minL - 2) or pLevel > (maxL + 2) then
                    skip = true
                end
            end

            if not skip then
                local res = addon.Engine and addon.Engine.CalculateWorldMapZoneWorth and addon.Engine.CalculateWorldMapZoneWorth(name)
                if res then
                    local include = true
                    if curFilter == "DUNGEONS" then
                        include = isDung
                    elseif isDung and (res.worth < 0.70 or res.isCompletedDungeon) then
                        -- In "ALL" view, hide dungeons that are completed or not worth running (< 70%) compared to World Questing
                        include = false
                    end

                    if include then
                        listCount = listCount + 1
                        local entry = _advisorItemPool[listCount]
                        if not entry then
                            entry = {}
                            _advisorItemPool[listCount] = entry
                        end
                        entry.name = name
                        entry.res = res
                        entry.mapID = zData.mapID
                        entry.continent = zData.continent
                        entry.isDungeon = isDung
                        list[listCount] = entry
                    end
                end
            end
        end
    end
    for i = listCount + 1, #list do
        list[i] = nil
    end

    local playerRace = (addon.Player and addon.Player.GetRace and addon.Player.GetRace())
    if not playerRace then
        local _, r = UnitRace("player")
        playerRace = r or "Human"
    end
    local homeCont = addon.Engine and addon.Engine.GetHomeContinent and addon.Engine.GetHomeContinent(playerRace)
    local starterZone = addon.Engine and addon.Engine.GetStarterZone and addon.Engine.GetStarterZone(playerRace)

    local currentPlayerZone = nil
    if C_Map and C_Map.GetBestMapForUnit then
        local okM, pMapID = pcall(C_Map.GetBestMapForUnit, "player")
        if okM and pMapID and pMapID > 0 then
            currentPlayerZone = ResolveZoneName(pMapID)
        end
    end
    if not currentPlayerZone and GetRealZoneText then
        local okZ, rz = pcall(GetRealZoneText)
        if okZ and type(rz) == "string" and rz ~= "" then
            currentPlayerZone = rz
        end
    end

    table.sort(list, function(a, b)
        local aDone = (a and a.isDungeon and a.res and a.res.isCompletedDungeon) and true or false
        local bDone = (b and b.isDungeon and b.res and b.res.isCompletedDungeon) and true or false
        if aDone ~= bDone then
            return not aDone
        end
        local aWorth = (a and a.res and a.res.worth) or 0
        local bWorth = (b and b.res and b.res.worth) or 0
        if math.abs(aWorth - bWorth) > 0.005 then
            return aWorth > bWorth
        end
        -- Tie-breakers when zones score identically within 0.5%:
        -- 1. Current physical zone where the player is actively questing (if viable >= 50%)
        if currentPlayerZone and aWorth >= 0.50 and bWorth >= 0.50 then
            local aCur = (a.name == currentPlayerZone)
            local bCur = (b.name == currentPlayerZone)
            if aCur ~= bCur then return aCur end
        end
        -- 2. Racial starting zone (if viable starter >= 70%)
        if starterZone and aWorth >= 0.70 and bWorth >= 0.70 then
            local aStart = (a.name == starterZone)
            local bStart = (b.name == starterZone)
            if aStart ~= bStart then return aStart end
        end
        -- 3. Home continent tie-breaker for low-level travel proximity
        if homeCont and a and b and a.continent ~= b.continent then
            if a.continent == homeCont then return true end
            if b.continent == homeCont then return false end
        end
        local aMin = (a and a.res and a.res.minLevel) or 99
        local bMin = (b and b.res and b.res.minLevel) or 99
        if aMin ~= bMin then
            return aMin < bMin
        end
        local aName = (a and a.name) or ""
        local bName = (b and b.name) or ""
        return aName < bName
    end)

    local rowHeight = 34
    local child = advisorPanel.scrollChild
    for i = 1, #list do
        local item = list[i]
        local row = advisorRows[i] or CreateAdvisorRow(i, child)
        row.data = item.res
        row.mapID = item.mapID
        row.isDungeon = item.isDungeon
        row.rankIndex = i

        local isDoneDung = item.isDungeon and item.res.isCompletedDungeon
        local badge = isDoneDung and "|cff00ff00[Done]|r" or Utils.FormatBadge(item.res.worth, false)
        row.Badge:SetText(badge)

        -- Dynamic text hierarchy matching Quest Log styling (Gold for optimal, White for standard, Silver for low)
        local nameColor = (isDoneDung and "|cff88cc88")
            or (item.res.worth >= 0.70 and "|cffffd100")
            or (item.res.worth >= 0.50 and "|cffffffff")
            or "|cffaaaaaa"
        local prefix = (not isDoneDung and i == 1 and item.res.worth >= 0.70 and "|cff00ff00#1 |r")
            or (item.res.isLowValue and "|TInterface\\Buttons\\UI-MicroStream-Red:12:12:0:0|t ")
            or ""
        row.Name:SetText(prefix .. nameColor .. item.name .. "|r")

        -- Line 2 explanation right inside the sidebar row
        if row.SubText then
            local reason = item.res.shortReason or item.res.status or ""
            if isDoneDung then
                row.SubText:SetText("|cff66aa66" .. reason .. "|r")
            elseif i == 1 and item.res.worth >= 0.70 then
                row.SubText:SetText("|cff88ff88Best Pick: " .. reason .. "|r")
            elseif item.res.worth >= 0.70 then
                row.SubText:SetText("|cffb0b0b0" .. reason .. "|r")
            else
                row.SubText:SetText("|cff808080" .. reason .. "|r")
            end
        end

        -- Update continent faction or dungeon symbol (Dungeon = Portal/Eye, Kalimdor = Horde, Eastern Kingdoms = Alliance)
        local cont = item.continent or (item.res and item.res.continent)
        UpdateRowContinentIcon(row.ContinentIcon, cont, item.isDungeon)

        if row.RightTag then
            row.RightTag:ClearAllPoints()
            if item.isDungeon then
                row.RightTag:SetPoint("TOPRIGHT", row, "TOPRIGHT", -22, -4)
            else
                row.RightTag:SetPoint("TOPRIGHT", row, "TOPRIGHT", -4, -4)
            end
            if item.res.minLevel and item.res.maxLevel then
                row.RightTag:SetText(string.format("|cff888888(%d-%d)|r", item.res.minLevel, item.res.maxLevel))
            else
                row.RightTag:SetText("")
            end
        end

        if row.DoneBtn then
            if item.isDungeon then
                row.DoneBtn.zoneName = item.name
                if isDoneDung then
                    row.DoneBtn.Check:Show()
                else
                    row.DoneBtn.Check:Hide()
                end
                row.DoneBtn:Show()
            else
                row.DoneBtn.zoneName = nil
                row.DoneBtn.Check:Hide()
                row.DoneBtn:Hide()
            end
        end

        if row._qwLayoutIndex ~= i then
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -((i - 1) * rowHeight))
            row._qwLayoutIndex = i
        end
        row:Show()
    end

    for i = #list + 1, #advisorRows do
        advisorRows[i]:Hide()
    end

    if #list == 0 then
        if advisorPanel.emptyText then
            local msg
            if curFilter == "DUNGEONS" then
                msg = "No dungeons in your\ncurrent level bracket."
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
    if maxScroll <= 0 then
        advisorPanel.scrollFrame:SetVerticalScroll(0)
        advisorPanel.slider:SetValue(0)
        advisorPanel.slider:Hide()
    else
        advisorPanel.slider:Show()
        if advisorPanel.scrollFrame:GetVerticalScroll() > maxScroll then
            advisorPanel.scrollFrame:SetVerticalScroll(maxScroll)
            advisorPanel.slider:SetValue(maxScroll)
        end
    end
end

function UI.ToggleZoneAdvisor(enable)
    local anchor = GetMapAnchorFrame()
    if not anchor then return end

    local panel = CreateZoneAdvisorPanel(anchor)
    local toggle = CreateZoneAdvisorToggle(anchor)
    if not panel then return end

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
        if toggle then
            if addon.db and addon.db.enabled == false then
                toggle:Hide()
            else
                toggle:Show()
            end
        end
        if targetState then
            panel:Show()
            UI.UpdateZoneAdvisor()
            if toggle then
                UpdateAdvisorToggleText(toggle, true)
            end
        else
            panel:Hide()
            if toggle then
                UpdateAdvisorToggleText(toggle, false)
            end
        end
    end)
end

-- Reactive frame that watches map navigation, zooming, and clicking in real time
local mapWatcher = CreateFrame("Frame", "WorthIt_MapWatcherFrame")
local _lastWatchedMapID = nil
local _watchThrottle = 0

local function SyncMapWidgetsLayout()
    if not (WorldMapFrame and WorldMapFrame:IsShown()) then return end
    local anchor = GetMapAnchorFrame()
    if anchor then
        local toggle = CreateZoneAdvisorToggle(anchor)
        if toggle then
            if addon.db and addon.db.enabled == false then
                toggle:Hide()
            else
                toggle:Show()
            end
        end
        local panel = CreateZoneAdvisorPanel(anchor)
        if panel and panel:IsShown() then
            UI.UpdateZoneAdvisor()
        end
    end
    UI.UpdateWorldMapBanner()
end

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
    local wantBanner = (not addon.db or (addon.db.enabled ~= false and addon.db.showInWorldMap ~= false))
    if currentMapID ~= _lastWatchedMapID or (wantBanner and not (mapBanner and mapBanner:IsShown())) then
        _lastWatchedMapID = currentMapID
        UI.UpdateWorldMapBanner()
    else
        if mapBanner and mapBanner:IsShown() then SyncMapWidgetLayer(mapBanner, 5) end
        if advisorToggleButton then SyncMapWidgetLayer(advisorToggleButton, 8) end
        if advisorPanel and advisorPanel:IsShown() then SyncMapWidgetLayer(advisorPanel, 12) end
    end
end

local isWorldMapHooked = false

function UI.InitializeWorldMap()
    if not WorldMapFrame then return end

    local anchor = GetMapAnchorFrame()
    CreateZoneAdvisorToggle(anchor)
    CreateZoneAdvisorPanel(anchor)

    if WorldMapFrame.QuestLog and WorldMapFrame.QuestLog.HookScript and not WorldMapFrame.QuestLog._worthItMapSyncHooked then
        WorldMapFrame.QuestLog._worthItMapSyncHooked = true
        pcall(function()
            WorldMapFrame.QuestLog:HookScript("OnShow", SyncMapWidgetsLayout)
            WorldMapFrame.QuestLog:HookScript("OnHide", SyncMapWidgetsLayout)
        end)
    end

    WorldMapFrame._qwHookedMethods = WorldMapFrame._qwHookedMethods or {}
    for _, methodName in ipairs({
        "OnMapChanged", "SetMapID", "SetDisplayState", "Maximize", "Minimize",
        "RefreshOverlayFrames", "UpdateSpacerFrameAnchoring",
        "HandleUserActionToggleSidePanel", "HandleUserActionOpenSidePanel", "HandleUserActionCloseSidePanel"
    }) do
        if WorldMapFrame[methodName] and not WorldMapFrame._qwHookedMethods[methodName] then
            WorldMapFrame._qwHookedMethods[methodName] = true
            hooksecurefunc(WorldMapFrame, methodName, function()
                if methodName == "OnMapChanged" or methodName == "SetMapID" then
                    _lastWatchedMapID = nil
                end
                SyncMapWidgetsLayout()
            end)
        end
    end

    if isWorldMapHooked then return end
    isWorldMapHooked = true

    -- Start hidden unless WorldMapFrame is already open
    if not WorldMapFrame:IsShown() then
        mapWatcher:Hide()
    end
    mapWatcher:SetScript("OnUpdate", OnMapWatchUpdate)

    WorldMapFrame:HookScript("OnShow", function()
        _lastWatchedMapID = nil
        mapWatcher:Show()
        SyncMapWidgetsLayout()
        if addon.db and addon.db.showZoneAdvisor ~= false then
            UI.ToggleZoneAdvisor(true)
        else
            UI.ToggleZoneAdvisor(false)
        end
        if C_Timer and C_Timer.After then
            C_Timer.After(0.05, SyncMapWidgetsLayout)
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
end
