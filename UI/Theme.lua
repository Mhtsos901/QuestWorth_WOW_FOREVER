--[[
    WorthIt / QuestWorth - UI/Theme.lua
    Cohesive Warcraft Native UI Design System.
    Uses Blizzard Classic / WoW Forever NineSlice chrome, tiled stone/parchment
    surfaces, embossed antique-bronze rules, framed item/map medallions, and crisp
    tabs while guarding optional client APIs for universal compatibility.
]]

local addonName, addon = ...
addon.UI = addon.UI or {}
local UI = addon.UI

local Theme = {}
UI.Theme = Theme

Theme.COLORS = {
    GOLD           = { 1.00, 0.82, 0.00 },
    ANTIQUE_GOLD   = { 0.94, 0.80, 0.44 },
    BRONZE         = { 0.66, 0.49, 0.28 },
    BRONZE_DARK    = { 0.36, 0.27, 0.16 },
    SLATE_BG       = { 0.06, 0.052, 0.045, 0.96 },
    INSET_BG       = { 0.04, 0.034, 0.028, 0.90 },
    PARCHMENT_DARK = { 0.09, 0.070, 0.048, 0.96 },
    IVORY          = { 0.95, 0.91, 0.82 },
    MUTED          = { 0.72, 0.65, 0.52 },
}

function Theme.HasAtlas(atlasName)
    if type(atlasName) ~= "string" or atlasName == "" then return false end
    return C_Texture ~= nil and C_Texture.GetAtlasInfo ~= nil and C_Texture.GetAtlasInfo(atlasName) ~= nil
end

local function ApplyRockAndParchment(frame, leftPad, topPad, rightPad, bottomPad, vignetteAlpha, parchmentAlpha)
    if not frame or not frame.CreateTexture then return end
    local lp = leftPad or 4
    local tp = topPad or -4
    local rp = rightPad or -4
    local bp = bottomPad or 4

    local rock = frame:CreateTexture(nil, "BACKGROUND", nil, -4)
    rock:SetPoint("TOPLEFT", frame, "TOPLEFT", lp, tp)
    rock:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", rp, bp)
    local okTex = rock:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock", "REPEAT", "REPEAT")
    if okTex == false and rock.SetColorTexture then
        rock:SetColorTexture(0.08, 0.068, 0.055, 1)
    end
    if rock.SetHorizTile then rock:SetHorizTile(true) end
    if rock.SetVertTile then rock:SetVertTile(true) end
    frame._themeRock = rock

    local shade = frame:CreateTexture(nil, "BACKGROUND", nil, -3)
    shade:SetAllPoints(rock)
    if shade.SetColorTexture then
        shade:SetColorTexture(0.03, 0.025, 0.02, vignetteAlpha or 0.50)
    end
    frame._themeShade = shade

    local pAlpha = parchmentAlpha or 0
    if pAlpha > 0 then
        local parch = frame:CreateTexture(nil, "BACKGROUND", nil, -2)
        parch:SetAllPoints(rock)
        parch:SetTexture("Interface\\QuestFrame\\QuestBG")
        if parch.SetTexCoord then parch:SetTexCoord(0, 1, 0, 1) end
        if parch.SetVertexColor then parch:SetVertexColor(1.0, 0.95, 0.84) end
        if parch.SetAlpha then parch:SetAlpha(pAlpha) end
        frame._themeParchment = parch
    end
end

function Theme.DressWindow(frame, opts)
    if not frame then return 0 end
    local parchmentAlpha = (type(opts) == "table" and opts.parchmentAlpha) or 0.08
    local util = _G.NineSliceUtil
    local layout = util and util.GetLayout and util.GetLayout("ButtonFrameTemplateNoPortrait") and "ButtonFrameTemplateNoPortrait"

    if layout then
        local ok, nine = pcall(CreateFrame, "Frame", nil, frame, "NineSlicePanelTemplate")
        if ok and nine and pcall(util.ApplyLayoutByName, nine, layout) then
            nine:SetAllPoints(frame)
            frame._themeNineSlice = nine
            ApplyRockAndParchment(frame, 6, -22, -3, 3, 0.50, parchmentAlpha)
            return 22
        end
    end

    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            tile = true, tileSize = 32, edgeSize = 20,
            insets = { left = 5, right = 5, top = 5, bottom = 5 },
        })
        if frame.SetBackdropColor then
            frame:SetBackdropColor(0.08, 0.068, 0.055, 0.96)
        end
        if frame.SetBackdropBorderColor then
            frame:SetBackdropBorderColor(0.86, 0.72, 0.42, 0.95)
        end
    end
    ApplyRockAndParchment(frame, 5, -5, -5, 5, 0.48, parchmentAlpha)
    return 0
end

function Theme.DressInset(frame, opts)
    if not frame then return end
    local parchmentAlpha = (type(opts) == "table" and opts.parchmentAlpha) or 0.05
    local util = _G.NineSliceUtil
    local layout = util and util.GetLayout and util.GetLayout("InsetFrameTemplate") and "InsetFrameTemplate"

    if layout then
        local ok, nine = pcall(CreateFrame, "Frame", nil, frame, "NineSlicePanelTemplate")
        if ok and nine and pcall(util.ApplyLayoutByName, nine, layout) then
            nine:SetAllPoints(frame)
            frame._themeNineSlice = nine
            ApplyRockAndParchment(frame, 3, -3, -3, 3, 0.58, parchmentAlpha)
            return
        end
    end

    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        if frame.SetBackdropColor then
            frame:SetBackdropColor(0.045, 0.038, 0.032, 0.92)
        end
        if frame.SetBackdropBorderColor then
            frame:SetBackdropBorderColor(0.54, 0.41, 0.22, 0.88)
        end
    end
    if parchmentAlpha > 0 and frame.CreateTexture then
        local parch = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
        parch:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -3)
        parch:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -3, 3)
        parch:SetTexture("Interface\\QuestFrame\\QuestBG")
        if parch.SetTexCoord then parch:SetTexCoord(0, 1, 0, 1) end
        if parch.SetVertexColor then parch:SetVertexColor(1.0, 0.95, 0.84) end
        if parch.SetAlpha then parch:SetAlpha(parchmentAlpha) end
        frame._themeParchment = parch
    end
end

function Theme.DressParchmentCard(frame)
    if not frame then return end
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            tile = true, tileSize = 24, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        if frame.SetBackdropColor then
            frame:SetBackdropColor(0.11, 0.085, 0.058, 0.96)
        end
        if frame.SetBackdropBorderColor then
            frame:SetBackdropBorderColor(0.88, 0.74, 0.42, 0.95)
        end
    end
    if frame.CreateTexture then
        local parch = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
        parch:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
        parch:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
        parch:SetTexture("Interface\\QuestFrame\\QuestBG")
        if parch.SetTexCoord then parch:SetTexCoord(0, 1, 0, 1) end
        if parch.SetVertexColor then parch:SetVertexColor(1.0, 0.95, 0.84) end
        if parch.SetAlpha then parch:SetAlpha(0.16) end
        frame._themeParchment = parch

        local hdrStrip = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
        hdrStrip:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
        hdrStrip:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
        hdrStrip:SetHeight(24)
        if hdrStrip.SetColorTexture then
            hdrStrip:SetColorTexture(0.24, 0.17, 0.08, 0.48)
        end
        frame._themeHeaderStrip = hdrStrip
    end
end

function Theme.DressBanner(frame)
    if not frame then return end
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        if frame.SetBackdropColor then
            frame:SetBackdropColor(0.08, 0.066, 0.052, 0.96)
        end
        if frame.SetBackdropBorderColor then
            frame:SetBackdropBorderColor(0.84, 0.69, 0.38, 0.95)
        end
    end
    if frame.CreateTexture then
        local sheen = frame:CreateTexture(nil, "ARTWORK")
        sheen:SetHeight(1)
        sheen:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -3)
        sheen:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -3)
        if sheen.SetColorTexture then
            sheen:SetColorTexture(0.94, 0.80, 0.44, 0.22)
        end
        frame._themeSheen = sheen
    end
    if frame.SetHighlightTexture then
        frame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        local hl = frame.GetHighlightTexture and frame:GetHighlightTexture()
        if hl then
            if hl.SetAlpha then hl:SetAlpha(0.30) end
            if hl.SetAllPoints then hl:SetAllPoints(frame) end
        end
    end
end

function Theme.CreateFramedIcon(parent, texturePath, size)
    local sz = size or 20
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetSize(sz, sz)

    local icon = container:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -2, 2)
    icon:SetTexture(texturePath or "Interface\\Icons\\INV_Misc_Book_09")
    if icon.SetTexCoord then
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    container.Icon = icon

    if Theme.HasAtlas("UI-HUD-ActionBar-IconFrame") then
        local border = container:CreateTexture(nil, "OVERLAY")
        border:SetAllPoints(container)
        border:SetAtlas("UI-HUD-ActionBar-IconFrame")
        container.Border = border
    elseif container.SetBackdrop then
        container:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        if container.SetBackdropColor then container:SetBackdropColor(0.05, 0.04, 0.03, 0.90) end
        if container.SetBackdropBorderColor then container:SetBackdropBorderColor(0.72, 0.56, 0.30, 0.95) end
    end

    return container
end

function Theme.CreateHeaderRule(parent, insetX, yOffset, relTo)
    if not parent or not parent.CreateTexture then return nil end
    local xPad = insetX or 8
    local y = yOffset or -28
    local anchorTarget = relTo or parent

    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", anchorTarget, "TOPLEFT", xPad, y)
    line:SetPoint("TOPRIGHT", anchorTarget, "TOPRIGHT", -xPad, y)
    if line.SetColorTexture then
        line:SetColorTexture(0.68, 0.52, 0.28, 0.78)
    end

    local shadow = parent:CreateTexture(nil, "ARTWORK")
    shadow:SetHeight(1)
    shadow:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, 0)
    shadow:SetPoint("TOPRIGHT", line, "BOTTOMRIGHT", 0, 0)
    if shadow.SetColorTexture then
        shadow:SetColorTexture(0, 0, 0, 0.55)
    end

    return line
end

function Theme.CreateTab(parent, text, width, height)
    local w = width or 120
    local h = height or 22

    if _G.MinimalTabTemplate or _G.NineSliceUtil then
        local ok, nativeBtn = pcall(CreateFrame, "Button", nil, parent, "MinimalTabTemplate")
        if ok and nativeBtn and nativeBtn.Text and (nativeBtn.SetSelected or nativeBtn.isSelected ~= nil) then
            nativeBtn:SetSize(w, h)
            nativeBtn.Text:SetText(text or "")
            function nativeBtn:SetActive(isActive)
                local active = isActive and true or false
                if self.SetSelected then
                    pcall(self.SetSelected, self, active)
                else
                    self.isSelected = active
                end
                if self.Text and self.Text.SetTextColor then
                    if active then
                        self.Text:SetTextColor(1.0, 0.92, 0.42, 1)
                    else
                        self.Text:SetTextColor(0.78, 0.72, 0.62, 0.92)
                    end
                end
            end
            nativeBtn:SetActive(false)
            return nativeBtn
        end
    end

    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w, h)
    if btn.SetBackdrop then
        btn:SetBackdrop({
            bgFile = "Interface\\FrameGeneral\\UI-Background-Rock",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        if btn.SetBackdropColor then btn:SetBackdropColor(0.06, 0.05, 0.04, 0.90) end
        if btn.SetBackdropBorderColor then btn:SetBackdropBorderColor(0.45, 0.35, 0.20, 0.85) end
    end
    if btn.SetHighlightTexture then
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        local hl = btn.GetHighlightTexture and btn:GetHighlightTexture()
        if hl then
            if hl.SetAlpha then hl:SetAlpha(0.28) end
            if hl.SetAllPoints then hl:SetAllPoints(btn) end
        end
    end

    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("CENTER", btn, "CENTER", 0, 1)
    fs:SetText(text or "")
    btn.Text = fs

    local activeBar = btn:CreateTexture(nil, "OVERLAY")
    activeBar:SetHeight(2)
    activeBar:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 4, 2)
    activeBar:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 2)
    if activeBar.SetColorTexture then
        activeBar:SetColorTexture(1.0, 0.82, 0.15, 0.95)
    end
    if activeBar.Hide then activeBar:Hide() end
    btn.ActiveBar = activeBar

    function btn:SetActive(isActive)
        local active = isActive and true or false
        self._isActiveTab = active
        if active then
            if self.SetBackdropColor then self:SetBackdropColor(0.15, 0.11, 0.05, 0.96) end
            if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0.86, 0.70, 0.32, 0.98) end
            if self.Text and self.Text.SetTextColor then self.Text:SetTextColor(1.0, 0.92, 0.42, 1) end
            if self.ActiveBar and self.ActiveBar.Show then self.ActiveBar:Show() end
        else
            if self.SetBackdropColor then self:SetBackdropColor(0.06, 0.05, 0.04, 0.88) end
            if self.SetBackdropBorderColor then self:SetBackdropBorderColor(0.45, 0.35, 0.20, 0.82) end
            if self.Text and self.Text.SetTextColor then self.Text:SetTextColor(0.76, 0.70, 0.58, 0.90) end
            if self.ActiveBar and self.ActiveBar.Hide then self.ActiveBar:Hide() end
        end
    end

    btn:SetActive(false)
    return btn
end

function Theme.StyleScrollbar(slider)
    if not slider then return end
    if slider.SetBackdrop then
        slider:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 6,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        if slider.SetBackdropColor then
            slider:SetBackdropColor(0.03, 0.025, 0.02, 0.85)
        end
        if slider.SetBackdropBorderColor then
            slider:SetBackdropBorderColor(0.48, 0.36, 0.20, 0.85)
        end
    end
    if slider.SetThumbTexture then
        slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    end
    local thumb = slider.GetThumbTexture and slider:GetThumbTexture()
    if thumb and thumb.SetSize then
        thumb:SetSize(14, 20)
    end
end
