--[[
    WorthIt / QuestWorth - UI/MapPins.lua
    World Map Dependency & Prerequisite Step Helper Pins.
    Displays numbered step markers ONLY for focused / selected complicated quests
    (SuperTracked quest, open Quest Details, or manual [Pin Steps]) so the map stays clean.
    Scales cleanly alongside the built-in Questie / OpenMap icons across all zoom levels.
]]

local addonName, addon = ...
addon.UI = addon.UI or {}
local UI = addon.UI
local L = addon.L

local _pinLayer = nil
local _pinPool = {}
local _activePins = {}
local _manualPinnedQuestID = nil
local _detailsFocusedQuestID = nil
local _selectedLogQuestID = nil
local _hiddenPinQuests = {}
local _pinsHooked = false
local _focusEventFrame = nil
local _lastSuperTrackedID = nil
local _openMapMenuRegistered = false
local _updatePending = false
local _zoomWatcher = nil
local _lastCanvasScale = 0
local _lastIconScale = 0
local _lastCanvasW = 0
local _lastCanvasH = 0

local PIN_SIZE = 20

local function IsFinitePosNumber(v)
    return type(v) == "number" and v == v and v > 0 and v < 1e9
end

local function GetBuiltInIconScale()
    local s = 1
    if _G.OpenMap and type(_G.OpenMap.GetModule) == "function" then
        local ok, m = pcall(_G.OpenMap.GetModule, _G.OpenMap, "worldmap", true)
        if ok and type(m) == "table" and type(m.db) == "table" and type(m.db.iconScale) == "number" then
            s = m.db.iconScale
        end
    elseif _G.OpenMapDB and type(_G.OpenMapDB) == "table" and type(_G.OpenMapDB.worldmap) == "table"
        and type(_G.OpenMapDB.worldmap.iconScale) == "number" then
        s = _G.OpenMapDB.worldmap.iconScale
    end
    if s ~= s or s < 0.5 then
        s = 0.5
    elseif s > 2.5 then
        s = 2.5
    end
    return s
end

local function GetWorldMapCanvas()
    if not WorldMapFrame then return nil end
    if type(WorldMapFrame.GetCanvas) == "function" then
        local ok, canvas = pcall(WorldMapFrame.GetCanvas, WorldMapFrame)
        if ok and canvas then return canvas end
    end
    if WorldMapFrame.ScrollContainer then
        return WorldMapFrame.ScrollContainer.Child or WorldMapFrame.ScrollContainer
    end
    return nil
end

local function GetMapViewportContainer(canvas)
    local sc = WorldMapFrame and WorldMapFrame.ScrollContainer
    if sc and sc ~= canvas and sc.GetWidth and sc.SetPoint and sc.GetFrameLevel then
        return sc
    end
    return nil
end

local function GetCurrentCanvasScale(canvas)
    local s = 1
    if WorldMapFrame and WorldMapFrame.GetCanvasScale then
        local okS, val = pcall(WorldMapFrame.GetCanvasScale, WorldMapFrame)
        if okS and type(val) == "number" and val > 0 then
            s = val
        end
    elseif canvas and canvas.GetScale then
        local okS, val = pcall(canvas.GetScale, canvas)
        if okS and type(val) == "number" and val > 0 then
            s = val
        end
    end
    if s < 0.1 then s = 0.1 end
    return s
end

local function GetFocusedGuideQuestIDs()
    local ids = {}
    local seen = {}
    local function addID(qid)
        if IsFinitePosNumber(qid) and not seen[qid] then
            seen[qid] = true
            table.insert(ids, qid)
        end
    end

    if C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID then
        local ok, stID = pcall(C_SuperTrack.GetSuperTrackedQuestID)
        if ok then addID(stID) end
    end

    if QuestMapFrame and QuestMapFrame.DetailsFrame
        and (not QuestMapFrame.DetailsFrame.IsShown or QuestMapFrame.DetailsFrame:IsShown()) then
        addID(QuestMapFrame.DetailsFrame.questID or _detailsFocusedQuestID)
    end

    if _selectedLogQuestID then
        addID(_selectedLogQuestID)
    end

    if QuestLogFrame and QuestLogFrame.IsShown and QuestLogFrame:IsShown() then
        if C_QuestLog and C_QuestLog.GetSelectedQuest then
            local ok, selID = pcall(C_QuestLog.GetSelectedQuest)
            if ok then addID(selID) end
        elseif GetQuestLogSelection and GetQuestLogTitle then
            local okSel, idx = pcall(GetQuestLogSelection)
            if okSel and idx and idx > 0 then
                local okQ, _, _, _, isH, _, _, _, qid = pcall(GetQuestLogTitle, idx)
                if okQ and not isH then addID(qid) end
            end
        end
    end

    return (#ids > 0) and ids or nil
end

local function HideAllPins()
    for _, pin in ipairs(_activePins) do
        pin:Hide()
        pin._pinData = nil
        pin._anchorCanvas = nil
        if pin._activeAnchor and pin._activeAnchor.Hide then
            pin._activeAnchor:Hide()
        end
        pin._activeAnchor = nil
    end
    _activePins = {}
end

local function EnsurePinLayer(container, baseLevel)
    if not container then return nil end
    if not _pinLayer and CreateFrame then
        _pinLayer = CreateFrame("Frame", "WorthIt_DepPinLayer", container)
        _pinLayer:SetAllPoints(container)
        if _pinLayer.EnableMouse then _pinLayer:EnableMouse(false) end
        if _pinLayer.SetClipsChildren then _pinLayer:SetClipsChildren(true) end
    end
    if _pinLayer then
        if _pinLayer.GetParent and _pinLayer:GetParent() ~= container then
            _pinLayer:SetParent(container)
            _pinLayer:SetAllPoints(container)
        end
        if baseLevel and _pinLayer.SetFrameLevel then
            _pinLayer:SetFrameLevel(baseLevel)
        end
        _pinLayer:Show()
    end
    return _pinLayer
end

local function AcquireAnchor(pin, canvas)
    pin._anchorsByCanvas = pin._anchorsByCanvas or {}
    local anchor = pin._anchorsByCanvas[canvas]
    if not anchor and canvas and canvas.CreateTexture then
        anchor = canvas:CreateTexture(nil, "BACKGROUND")
        anchor:SetSize(1, 1)
        anchor:SetAlpha(0)
        pin._anchorsByCanvas[canvas] = anchor
    end
    return anchor
end

local function AcquirePin(hostParent, idx)
    local pin = _pinPool[idx]
    if not pin then
        pin = CreateFrame("Button", "WorthIt_DepMapPin_" .. idx, hostParent)
        pin:SetSize(PIN_SIZE, PIN_SIZE)
        pin:EnableMouse(true)
        if pin.RegisterForClicks then
            pcall(pin.RegisterForClicks, pin, "LeftButtonUp", "RightButtonUp")
        end
        pin._worthItQuestPin = true

        local shadow = pin:CreateTexture(nil, "BACKGROUND", nil, -1)
        shadow:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
        shadow:SetVertexColor(0, 0, 0, 0.55)
        shadow:SetSize(PIN_SIZE + 4, PIN_SIZE + 4)
        shadow:SetPoint("CENTER", 0, -1)
        pin.shadow = shadow

        local ring = pin:CreateTexture(nil, "BACKGROUND")
        local Theme = addon.UI and addon.UI.Theme
        local useAtlas = Theme and Theme.HasAtlas and Theme.HasAtlas("UI-QuestPoi-QuestNumber")
        if useAtlas and ring.SetAtlas then
            ring:SetAtlas("UI-QuestPoi-QuestNumber")
            pin._useAtlasMedallion = true
        else
            ring:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
            pin._useAtlasMedallion = false
        end
        ring:SetSize(PIN_SIZE, PIN_SIZE)
        ring:SetPoint("CENTER")
        pin.ring = ring

        local bg = pin:CreateTexture(nil, "BORDER")
        bg:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
        bg:SetVertexColor(0.07, 0.055, 0.04, 0.95)
        bg:SetSize(PIN_SIZE - 5, PIN_SIZE - 5)
        bg:SetPoint("CENTER")
        if pin._useAtlasMedallion and bg.Hide then
            bg:Hide()
        end
        pin.bg = bg

        local hl = pin:CreateTexture(nil, "HIGHLIGHT")
        hl:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
        hl:SetSize(PIN_SIZE, PIN_SIZE)
        hl:SetPoint("CENTER")
        if hl.SetBlendMode then hl:SetBlendMode("ADD") end
        hl:SetAlpha(0.30)
        pin.hl = hl

        local txt = pin:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        txt:SetPoint("CENTER", 0, 0)
        if txt.GetFont and txt.SetFont then
            local fPath, fSize = txt:GetFont()
            if fPath and fSize then pcall(txt.SetFont, txt, fPath, fSize, "OUTLINE") end
        end
        if txt.SetShadowColor then txt:SetShadowColor(0, 0, 0, 1) end
        if txt.SetShadowOffset then txt:SetShadowOffset(1, -1) end
        pin.labelTxt = txt

        pin:SetScript("OnEnter", function(self)
            local d = self._pinData
            if not d or not GameTooltip then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine("|cff00ccffWorthIt Guide|r |cffffd100" .. (d.questTitle or "") .. "|r", 1, 1, 1, true)
            if d.label and d.label ~= "" and d.label ~= d.questTitle then
                GameTooltip:AddLine(d.label, 0.4, 0.9, 1.0, true)
            end
            if d.detail and d.detail ~= "" then
                GameTooltip:AddLine(d.detail, 1, 1, 1, true)
            end
            GameTooltip:AddLine(string.format("|cffb8d8f8Coords: %.1f, %.1f|r", (d.x or 0) * 100, (d.y or 0) * 100), 0.7, 0.85, 1.0)
            GameTooltip:AddLine("|cff999999" .. (L["GUIDE_PIN_HINT"] or "Left-Click: Track & Details | Right-Click: Hide Pin") .. "|r", 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        pin:SetScript("OnLeave", function()
            if GameTooltip then GameTooltip:Hide() end
        end)
        pin:SetScript("OnClick", function(self, button)
            local d = self._pinData
            if not d then return end
            if button == "RightButton" then
                if d.isManual and _manualPinnedQuestID == d.questID then
                    _manualPinnedQuestID = nil
                else
                    _hiddenPinQuests[d.questID] = true
                end
                if GameTooltip then GameTooltip:Hide() end
                UI.UpdateDependencyPins()
                return
            end
            if d.questID and d.questID > 0 then
                if C_QuestLog and C_QuestLog.AddQuestWatch then
                    pcall(C_QuestLog.AddQuestWatch, d.questID)
                end
                if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID then
                    pcall(C_SuperTrack.SetSuperTrackedQuestID, d.questID)
                end
                if not (InCombatLockdown and InCombatLockdown()) and QuestMapFrame_ShowQuestDetails and WorldMapFrame and WorldMapFrame.QuestLog and WorldMapFrame.QuestLog.IsShown and WorldMapFrame.QuestLog:IsShown() then
                    pcall(QuestMapFrame_ShowQuestDetails, d.questID)
                end
            end
        end)

        _pinPool[idx] = pin
    end

    if hostParent and pin.GetParent and pin:GetParent() ~= hostParent then
        pin:SetParent(hostParent)
    end
    return pin
end

function UI.UpdateDependencyPins()
    HideAllPins()

    if not (addon.db and addon.db.enabled ~= false and addon.db.showDependencyPins ~= false) then
        return
    end
    if not WorldMapFrame or (WorldMapFrame.IsShown and not WorldMapFrame:IsShown()) then
        return
    end

    local canvas = GetWorldMapCanvas()
    if not canvas or not canvas.GetWidth or not canvas.GetHeight then return end
    local w = canvas:GetWidth() or 0
    local h = canvas:GetHeight() or 0
    if w <= 10 or h <= 10 then return end

    local focusedIDs = GetFocusedGuideQuestIDs()
    local pins = addon.Data and addon.Data.GetActiveDependencyPins and addon.Data.GetActiveDependencyPins(_manualPinnedQuestID, focusedIDs)
    if not pins or #pins == 0 then return end

    local isStitched = false
    if OpenMapAPI and OpenMapAPI.IsStitched then
        local okS, stVal = pcall(OpenMapAPI.IsStitched)
        isStitched = okS and stVal and true or false
    end
    local currentMapID = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
    if not currentMapID or currentMapID <= 0 then return end

    local baseLevel = 1200
    if isStitched and OpenMapAPI and OpenMapAPI.ArtTopLevel then
        local okL, artLvl = pcall(OpenMapAPI.ArtTopLevel)
        if okL and type(artLvl) == "number" then
            baseLevel = math.max(baseLevel, artLvl + 65)
        end
    elseif canvas.GetFrameLevel then
        baseLevel = math.max(baseLevel, (canvas:GetFrameLevel() or 1) + 40)
    end

    local container = GetMapViewportContainer(canvas)
    local pinLayer = container and EnsurePinLayer(container, baseLevel) or nil
    local hostParent = pinLayer or canvas

    local iconScale = GetBuiltInIconScale()
    local canvasScale = GetCurrentCanvasScale(canvas)
    _lastIconScale = iconScale
    _lastCanvasScale = canvasScale
    _lastCanvasW = w
    _lastCanvasH = h

    local usedCount = 0
    for _, p in ipairs(pins) do
        if p and p.questID and not _hiddenPinQuests[p.questID] and p.mapID and p.x and p.y then
            local cx, cy = nil, nil
            local inBounds = false
            if isStitched and OpenMapAPI and OpenMapAPI.WorldFromMap and OpenMapAPI.MapFromWorld then
                local okW, u, v = pcall(OpenMapAPI.WorldFromMap, p.mapID, p.x, p.y)
                if okW and u and v then
                    local okC, mx, my = pcall(OpenMapAPI.MapFromWorld, currentMapID, u, v)
                    if okC and mx and my then
                        cx, cy = mx, my
                        inBounds = (cx >= -6.0 and cx <= 7.0 and cy >= -6.0 and cy <= 7.0)
                    end
                end
            elseif currentMapID == p.mapID then
                cx, cy = p.x, p.y
                inBounds = (cx >= 0.0 and cx <= 1.0 and cy >= 0.0 and cy <= 1.0)
            elseif C_Map and C_Map.GetMapRectOnMap then
                local okR, minX, maxX, minY, maxY = pcall(C_Map.GetMapRectOnMap, p.mapID, currentMapID)
                if okR and type(minX) == "number" and type(maxX) == "number" and maxX > minX and type(minY) == "number" and type(maxY) == "number" and maxY > minY then
                    cx = minX + p.x * (maxX - minX)
                    cy = minY + p.y * (maxY - minY)
                    inBounds = (cx >= 0.0 and cx <= 1.0 and cy >= 0.0 and cy <= 1.0)
                end
            end

            if inBounds and cx and cy then
                usedCount = usedCount + 1
                local pin = AcquirePin(hostParent, usedCount)
                pin._pinData = p
                pin._cx = cx
                pin._cy = cy
                pin._anchorCanvas = canvas
                pin:ClearAllPoints()

                if pinLayer then
                    local anchor = AcquireAnchor(pin, canvas)
                    if anchor then
                        if anchor.ClearAllPoints then anchor:ClearAllPoints() end
                        anchor:SetPoint("TOPLEFT", canvas, "TOPLEFT", cx * w, -(cy * h))
                        if anchor.Show then anchor:Show() end
                        pin._activeAnchor = anchor
                        pin:SetPoint("CENTER", anchor, "TOPLEFT")
                    else
                        pin:SetPoint("CENTER", hostParent, "TOPLEFT", cx * w, -(cy * h))
                    end
                    if pin.SetScale then pin:SetScale(iconScale) end
                    pin:SetFrameLevel(baseLevel + 10 + (p.isManual and 20 or 0))
                else
                    local targetPinScale = iconScale / canvasScale
                    if pin.SetScale then pin:SetScale(targetPinScale) end
                    pin:SetPoint("CENTER", canvas, "TOPLEFT", (cx * w) / targetPinScale, -(cy * h) / targetPinScale)
                    pin:SetFrameLevel(baseLevel + (p.isManual and 20 or 0))
                end

                if p.isManual then
                    pin.ring:SetVertexColor(1.0, 0.85, 0.22, 0.98)
                    pin.labelTxt:SetTextColor(1.0, 0.96, 0.72)
                else
                    pin.ring:SetVertexColor(0.22, 0.84, 1.0, 0.96)
                    pin.labelTxt:SetTextColor(0.95, 0.98, 1.0)
                end

                local glyph = (p.stepIdx and p.stepIdx >= 1 and p.stepIdx <= 9) and tostring(p.stepIdx) or "*"
                pin.labelTxt:SetText(glyph)
                pin:Show()
                table.insert(_activePins, pin)
            end
        end
    end
end

local function SchedulePinRefresh()
    if _updatePending then return end
    _updatePending = true
    if C_Timer and C_Timer.After then
        C_Timer.After(0.03, function()
            _updatePending = false
            UI.UpdateDependencyPins()
        end)
    else
        _updatePending = false
        UI.UpdateDependencyPins()
    end
end

function UI.PinQuestGuide(questID, focusOnMap)
    if not IsFinitePosNumber(questID) then return end
    _hiddenPinQuests[questID] = nil
    _manualPinnedQuestID = questID
    if addon.db and addon.db.showDependencyPins == false then
        addon.db.showDependencyPins = true
    end

    local pins = addon.Data and addon.Data.GetActiveDependencyPins and addon.Data.GetActiveDependencyPins(questID)
    local targetPin = pins and pins[1]
    if focusOnMap and targetPin and WorldMapFrame then
        if WorldMapFrame.Show and not (WorldMapFrame.IsShown and WorldMapFrame:IsShown()) and not (InCombatLockdown and InCombatLockdown()) then
            pcall(WorldMapFrame.Show, WorldMapFrame)
        end
        if OpenMapAPI and OpenMapAPI.IsStitched and OpenMapAPI.IsStitched() and OpenMapAPI.WorldFromMap and OpenMapAPI.ShowWorld then
            local okW, u, v = pcall(OpenMapAPI.WorldFromMap, targetPin.mapID, targetPin.x, targetPin.y)
            if okW and u and v then
                pcall(OpenMapAPI.ShowWorld, u, v, 5)
            elseif WorldMapFrame.SetMapID then
                pcall(WorldMapFrame.SetMapID, WorldMapFrame, targetPin.mapID)
            end
        elseif WorldMapFrame.SetMapID then
            pcall(WorldMapFrame.SetMapID, WorldMapFrame, targetPin.mapID)
        end
    end

    UI.UpdateDependencyPins()
end

function UI.ClearManualGuidePin(hideCurrentFocused)
    _manualPinnedQuestID = nil
    _selectedLogQuestID = nil
    if hideCurrentFocused then
        local focused = GetFocusedGuideQuestIDs()
        if focused then
            for _, qid in ipairs(focused) do
                _hiddenPinQuests[qid] = true
            end
        end
    else
        for k in pairs(_hiddenPinQuests) do
            _hiddenPinQuests[k] = nil
        end
    end
    UI.UpdateDependencyPins()
end

function UI.GetManualPinnedQuestID()
    return _manualPinnedQuestID
end

function UI.HasVisiblePinsForQuest(questID)
    if not IsFinitePosNumber(questID) then return false end
    if _manualPinnedQuestID == questID then return true end
    for _, pin in ipairs(_activePins) do
        if pin and pin._pinData and pin._pinData.questID == questID then
            return true
        end
    end
    return false
end

local function RescaleActivePinsOnly()
    if #_activePins == 0 then return end
    local canvas = GetWorldMapCanvas()
    if not canvas or not canvas.GetWidth or not canvas.GetHeight then return end
    local w = canvas:GetWidth() or 0
    local h = canvas:GetHeight() or 0
    if w <= 10 or h <= 10 then return end

    local iconScale = GetBuiltInIconScale()
    local canvasScale = GetCurrentCanvasScale(canvas)
    local scaleChanged = math.abs(canvasScale - _lastCanvasScale) >= 0.005
    local iconChanged = math.abs(iconScale - _lastIconScale) >= 0.005
    local sizeChanged = math.abs(w - _lastCanvasW) >= 1 or math.abs(h - _lastCanvasH) >= 1
    if not (scaleChanged or iconChanged or sizeChanged) then return end

    _lastCanvasScale = canvasScale
    _lastIconScale = iconScale
    _lastCanvasW = w
    _lastCanvasH = h

    local targetPinScale = iconScale / canvasScale
    for _, pin in ipairs(_activePins) do
        if pin and pin._cx and pin._cy then
            if _pinLayer and pin.GetParent and pin:GetParent() == _pinLayer then
                if iconChanged and pin.SetScale then
                    pin:SetScale(iconScale)
                end
                if sizeChanged and pin._activeAnchor then
                    if pin._activeAnchor.ClearAllPoints then pin._activeAnchor:ClearAllPoints() end
                    pin._activeAnchor:SetPoint("TOPLEFT", canvas, "TOPLEFT", pin._cx * w, -(pin._cy * h))
                end
            else
                if pin.SetScale then pin:SetScale(targetPinScale) end
                pin:ClearAllPoints()
                pin:SetPoint("CENTER", canvas, "TOPLEFT", (pin._cx * w) / targetPinScale, -(pin._cy * h) / targetPinScale)
            end
        end
    end
end

function UI.InitializeMapPins()
    if WorldMapFrame and not _pinsHooked then
        if WorldMapFrame.HookScript then
            pcall(function()
                WorldMapFrame:HookScript("OnShow", SchedulePinRefresh)
                WorldMapFrame:HookScript("OnHide", HideAllPins)
                WorldMapFrame:HookScript("OnSizeChanged", RescaleActivePinsOnly)
            end)
        end
        if WorldMapFrame.OnMapChanged then
            pcall(hooksecurefunc, WorldMapFrame, "OnMapChanged", SchedulePinRefresh)
        end
        if WorldMapFrame.OnCanvasScaleChanged then
            pcall(hooksecurefunc, WorldMapFrame, "OnCanvasScaleChanged", RescaleActivePinsOnly)
        end
        if WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.HookScript then
            pcall(function()
                WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", function()
                    if C_Timer and C_Timer.After then
                        C_Timer.After(0.02, RescaleActivePinsOnly)
                    else
                        RescaleActivePinsOnly()
                    end
                end)
            end)
        end
        if not _zoomWatcher and CreateFrame then
            _zoomWatcher = CreateFrame("Frame", nil, WorldMapFrame)
            _zoomWatcher:SetScript("OnUpdate", function()
                if #_activePins > 0 then
                    RescaleActivePinsOnly()
                end
            end)
        end

        if C_SuperTrack and C_SuperTrack.SetSuperTrackedQuestID and not UI._superTrackSetHooked then
            UI._superTrackSetHooked = true
            pcall(hooksecurefunc, C_SuperTrack, "SetSuperTrackedQuestID", function(qid)
                if qid ~= _lastSuperTrackedID then
                    _lastSuperTrackedID = qid
                    if IsFinitePosNumber(qid) then
                        _selectedLogQuestID = nil
                        _hiddenPinQuests[qid] = nil
                    end
                end
                SchedulePinRefresh()
            end)
        end

        if QuestMapFrame_ShowQuestDetails and not UI._pinsShowDetailsHooked then
            UI._pinsShowDetailsHooked = true
            pcall(hooksecurefunc, "QuestMapFrame_ShowQuestDetails", function(questID)
                if IsFinitePosNumber(questID) then
                    _detailsFocusedQuestID = questID
                    _hiddenPinQuests[questID] = nil
                end
                SchedulePinRefresh()
            end)
        end
        if QuestMapFrame_ReturnFromQuestDetails and not UI._pinsReturnDetailsHooked then
            UI._pinsReturnDetailsHooked = true
            pcall(hooksecurefunc, "QuestMapFrame_ReturnFromQuestDetails", function()
                _detailsFocusedQuestID = nil
                SchedulePinRefresh()
            end)
        end
        if QuestMapFrame and QuestMapFrame.DetailsFrame and QuestMapFrame.DetailsFrame.HookScript and not UI._pinsDetailsScriptHooked then
            UI._pinsDetailsScriptHooked = true
            pcall(function()
                QuestMapFrame.DetailsFrame:HookScript("OnShow", SchedulePinRefresh)
                QuestMapFrame.DetailsFrame:HookScript("OnHide", function()
                    _detailsFocusedQuestID = nil
                    SchedulePinRefresh()
                end)
            end)
        end
        if SelectQuestLogEntry and not UI._pinsSelectLogHooked then
            UI._pinsSelectLogHooked = true
            pcall(hooksecurefunc, "SelectQuestLogEntry", function()
                if addon._isInternalQuestSelection then return end
                if QuestLogFrame and QuestLogFrame.IsShown and QuestLogFrame:IsShown() then
                    local selID = nil
                    if C_QuestLog and C_QuestLog.GetSelectedQuest then
                        local ok, qid = pcall(C_QuestLog.GetSelectedQuest)
                        if ok then selID = qid end
                    end
                    if not IsFinitePosNumber(selID) and GetQuestLogSelection and GetQuestLogTitle then
                        local okSel, idx = pcall(GetQuestLogSelection)
                        if okSel and idx and idx > 0 then
                            local okQ, _, _, _, isH, _, _, _, qid = pcall(GetQuestLogTitle, idx)
                            if okQ and not isH then selID = qid end
                        end
                    end
                    if IsFinitePosNumber(selID) then
                        _selectedLogQuestID = selID
                        _hiddenPinQuests[selID] = nil
                    end
                end
                if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
                    SchedulePinRefresh()
                end
            end)
        end

        _pinsHooked = true
    end

    if not _focusEventFrame and CreateFrame then
        _focusEventFrame = CreateFrame("Frame")
        pcall(_focusEventFrame.RegisterEvent, _focusEventFrame, "SUPER_TRACKING_CHANGED")
        pcall(_focusEventFrame.RegisterEvent, _focusEventFrame, "QUEST_WATCH_LIST_CHANGED")
        _focusEventFrame:SetScript("OnEvent", function(_, event)
            if event == "SUPER_TRACKING_CHANGED" and C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID then
                local ok, qid = pcall(C_SuperTrack.GetSuperTrackedQuestID)
                if ok and qid ~= _lastSuperTrackedID then
                    _lastSuperTrackedID = qid
                    if IsFinitePosNumber(qid) then
                        _selectedLogQuestID = nil
                        _hiddenPinQuests[qid] = nil
                    end
                end
            end
            if WorldMapFrame and WorldMapFrame.IsShown and WorldMapFrame:IsShown() then
                UI.UpdateDependencyPins()
            end
        end)
    end

    if OpenMapAPI and OpenMapAPI.RegisterCallback and not UI._openMapPinsCB then
        UI._openMapPinsCB = true
        pcall(OpenMapAPI.RegisterCallback, addon, "OpenMap_ViewChanged", SchedulePinRefresh)
        pcall(OpenMapAPI.RegisterCallback, addon, "OpenMap_StitchedChanged", SchedulePinRefresh)
    end

    if OpenMapAPI and OpenMapAPI.RegisterMenuToggle and not _openMapMenuRegistered then
        _openMapMenuRegistered = true
        pcall(OpenMapAPI.RegisterMenuToggle, "QuestWorth", {
            id = "dependency_pins",
            label = "WorthIt: Focused Guide Pins",
            icon = "Interface\\Icons\\INV_Misc_Map_01",
            tab = "show",
            section = "QuestWorth",
            get = function() return addon.db and addon.db.enabled ~= false and addon.db.showDependencyPins ~= false end,
            set = function(v)
                if addon.db then
                    addon.db.showDependencyPins = v and true or false
                end
                UI.UpdateDependencyPins()
            end,
        })
    end
end
