--[[
    WorthIt / QuestWorth - UI/Config.lua
    Slash command handling (/worthit, /qw, /questworth) and Blizzard Options Panel integration.
]]

local addonName, addon = ...
addon.UI = addon.UI or {}
local UI = addon.UI
local Utils = addon.Utils
local L = addon.L

local configPanel = nil
local frameCounter = 0

local function GetUniqueName(prefix)
    frameCounter = frameCounter + 1
    return string.format("WorthIt_%s_%d", prefix, frameCounter)
end

local function PrintHelp()
    DEFAULT_CHAT_FRAME:AddMessage(L["HELP_TITLE"])
    DEFAULT_CHAT_FRAME:AddMessage(L["HELP_TOGGLE"])
    DEFAULT_CHAT_FRAME:AddMessage(L["HELP_DEBUG"])
    DEFAULT_CHAT_FRAME:AddMessage(L["HELP_WEIGHTS"])
    DEFAULT_CHAT_FRAME:AddMessage(L["HELP_QUESTLOG"])
    DEFAULT_CHAT_FRAME:AddMessage(L["HELP_TRACKER"])
    DEFAULT_CHAT_FRAME:AddMessage(L["HELP_TEST"])
    DEFAULT_CHAT_FRAME:AddMessage(L["HELP_RESET"])
end

local function CreateCheckbox(parent, label, point, relativeTo, relativePoint, x, y, getVal, setVal)
    local name = GetUniqueName("CheckButton")
    local cb = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint(point, relativeTo, relativePoint, x, y)
    local text = cb.Text or _G[name .. "Text"]
    if text then
        text:SetText(label)
        text:SetFontObject("GameFontNormal")
    end
    cb:SetChecked(getVal())
    cb:SetScript("OnClick", function(self)
        setVal(self:GetChecked())
        if addon.Engine and addon.Engine.InvalidateCache then
            addon.Engine.InvalidateCache()
        end
    end)
    return cb
end

local function CreateWeightSlider(parent, label, point, relativeTo, relativePoint, x, y, getVal, setVal)
    local name = GetUniqueName("Slider")
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint(point, relativeTo, relativePoint, x, y)
    slider:SetMinMaxValues(0, 100)
    slider:SetValueStep(5)
    if slider.SetObeyStepOnDrag then
        slider:SetObeyStepOnDrag(true)
    end
    slider:SetWidth(200)

    local lowText = _G[name .. "Low"]
    local highText = _G[name .. "High"]
    local titleText = _G[name .. "Text"]

    if lowText then lowText:SetText("0%") end
    if highText then highText:SetText("100%") end

    local current = math.floor(getVal() * 100 + 0.5)
    slider:SetValue(current)
    if titleText then
        titleText:SetText(string.format("%s: %d%%", label, current))
    end

    slider:SetScript("OnValueChanged", function(self, value)
        if self._syncing then return end
        value = math.floor(value + 0.5)
        if titleText then
            titleText:SetText(string.format("%s: %d%%", label, value))
        end
        setVal(value / 100)
        if addon.Engine and addon.Engine.InvalidateCache then
            addon.Engine.InvalidateCache()
        end
    end)

    slider.SyncValue = function(self)
        self._syncing = true
        local val = math.floor(getVal() * 100 + 0.5)
        self:SetValue(val)
        if titleText then
            titleText:SetText(string.format("%s: %d%%", label, val))
        end
        self._syncing = false
    end

    return slider
end

local function RefreshAllUI()
    if addon.Engine and addon.Engine.InvalidateCache then
        addon.Engine.InvalidateCache()
    end
    if addon.UI then
        if addon.UI.UpdateQuestLog then addon.UI.UpdateQuestLog(true) end
        if addon.UI.UpdateObjectiveTracker then addon.UI.UpdateObjectiveTracker(true) end
        if addon.UI.UpdateWorldMapBanner then addon.UI.UpdateWorldMapBanner() end
        if addon.UI.ToggleZoneAdvisor then
            local showAdvisor = not addon.db or (addon.db.enabled ~= false and addon.db.showZoneAdvisor ~= false)
            addon.UI.ToggleZoneAdvisor(showAdvisor)
        elseif addon.UI.UpdateZoneAdvisor then
            addon.UI.UpdateZoneAdvisor()
        end
        if addon.UI.UpdateQuestOfferDialog then addon.UI.UpdateQuestOfferDialog() end
    end
end

local function CreateOptionsPanel()
    if configPanel then return configPanel end

    local panel = CreateFrame("Frame", "WorthItOptionsPanel", UIParent)
    panel.name = "WorthIt"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("|cff00ccffWorthIt|r |cffffffff(QuestWorth)|r - Settings")

    local subTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subTitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subTitle:SetText("Configure weighted scoring criteria and visual elements for WoW Forever.")

    local cbEnable = CreateCheckbox(panel, "Enable Addon", "TOPLEFT", subTitle, "BOTTOMLEFT", 0, -16,
        function() return addon.db and addon.db.enabled end,
        function(v)
            addon.db.enabled = v
            RefreshAllUI()
        end)

    local cbTooltip = CreateCheckbox(panel, "Show Worth in Tooltip", "TOPLEFT", cbEnable, "BOTTOMLEFT", 0, -8,
        function() return addon.db and addon.db.showInTooltip end,
        function(v) addon.db.showInTooltip = v end)

    local cbBreakdown = CreateCheckbox(panel, "Show Detailed 5-Score Breakdown in Tooltip", "TOPLEFT", cbTooltip, "BOTTOMLEFT", 0, -8,
        function() return addon.db and addon.db.showBreakdown end,
        function(v) addon.db.showBreakdown = v end)

    local cbQuestLog = CreateCheckbox(panel, "Show Worth Tag in Quest Log (Window)", "TOPLEFT", cbBreakdown, "BOTTOMLEFT", 0, -8,
        function() return addon.db and addon.db.showInQuestLog end,
        function(v)
            addon.db.showInQuestLog = v
            if addon.UI and addon.UI.UpdateQuestLog then
                addon.UI.UpdateQuestLog(true)
            end
        end)

    local cbTracker = CreateCheckbox(panel, "Show Worth Tag in Objective Tracker (Right)", "TOPLEFT", cbQuestLog, "BOTTOMLEFT", 0, -8,
        function() return addon.db and addon.db.showInTracker end,
        function(v)
            addon.db.showInTracker = v
            if addon.UI and addon.UI.UpdateObjectiveTracker then
                addon.UI.UpdateObjectiveTracker(true)
            end
        end)

    local cbWorldMap = CreateCheckbox(panel, "Show Zone Worth Banner on World Map", "TOPLEFT", cbTracker, "BOTTOMLEFT", 0, -8,
        function() return addon.db and addon.db.showInWorldMap end,
        function(v)
            addon.db.showInWorldMap = v
            if addon.UI and addon.UI.UpdateWorldMapBanner then
                addon.UI.UpdateWorldMapBanner()
            end
        end)

    local cbZoneAdvisor = CreateCheckbox(panel, "Show Zone Advisor Sidebar on World Map", "TOPLEFT", cbWorldMap, "BOTTOMLEFT", 0, -8,
        function() return addon.db and addon.db.showZoneAdvisor end,
        function(v)
            addon.db.showZoneAdvisor = v
            if addon.UI and addon.UI.ToggleZoneAdvisor then
                addon.UI.ToggleZoneAdvisor(v)
            end
        end)

    local cbDebug = CreateCheckbox(panel, "Debug Mode (verbose console logs)", "TOPLEFT", cbZoneAdvisor, "BOTTOMLEFT", 0, -8,
        function() return addon.db and addon.db.debug end,
        function(v) addon.db.debug = v end)

    -- Right column: Scoring Weights (keeps full layout well above bottom action buttons)
    local weightHeader = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    weightHeader:SetPoint("TOPLEFT", subTitle, "BOTTOMLEFT", 330, -16)
    weightHeader:SetText("|cffffff00Scoring Weights (Auto-normalized)|r")

    local sR = CreateWeightSlider(panel, L["REWARD"], "TOPLEFT", weightHeader, "BOTTOMLEFT", 10, -24,
        function() return addon.db and addon.db.weights and addon.db.weights.reward or 0.40 end,
        function(v) addon.db.weights.reward = v end)

    local sF = CreateWeightSlider(panel, L["CLASS_FIT"], "TOPLEFT", sR, "BOTTOMLEFT", 0, -28,
        function() return addon.db and addon.db.weights and addon.db.weights.classFit or 0.25 end,
        function(v) addon.db.weights.classFit = v end)

    local sC = CreateWeightSlider(panel, L["CHAIN"], "TOPLEFT", sF, "BOTTOMLEFT", 0, -28,
        function() return addon.db and addon.db.weights and addon.db.weights.chain or 0.25 end,
        function(v) addon.db.weights.chain = v end)

    local sH = CreateWeightSlider(panel, L["DENSITY"] or "Hub Density", "TOPLEFT", sC, "BOTTOMLEFT", 0, -28,
        function() return addon.db and addon.db.weights and addon.db.weights.density or 0.10 end,
        function(v) addon.db.weights.density = v end)

    local sD = CreateWeightSlider(panel, L["DIFFICULTY"], "TOPLEFT", sH, "BOTTOMLEFT", 0, -28,
        function() return addon.db and addon.db.weights and addon.db.weights.difficulty or 0.00 end,
        function(v) addon.db.weights.difficulty = v end)

    local function SyncPanelControls()
        if not addon.db then return end
        cbEnable:SetChecked(addon.db.enabled)
        cbTooltip:SetChecked(addon.db.showInTooltip)
        cbBreakdown:SetChecked(addon.db.showBreakdown)
        cbQuestLog:SetChecked(addon.db.showInQuestLog)
        cbTracker:SetChecked(addon.db.showInTracker)
        cbWorldMap:SetChecked(addon.db.showInWorldMap ~= false)
        cbZoneAdvisor:SetChecked(addon.db.showZoneAdvisor ~= false)
        cbDebug:SetChecked(addon.db.debug)
        sR:SyncValue()
        sF:SyncValue()
        sC:SyncValue()
        sH:SyncValue()
        sD:SyncValue()
    end

    panel:SetScript("OnShow", SyncPanelControls)
    panel:SetScript("OnHide", RefreshAllUI)

    local btnReset = CreateFrame("Button", GetUniqueName("BtnReset"), panel, "UIPanelButtonTemplate")
    btnReset:SetPoint("BOTTOMLEFT", 16, 16)
    btnReset:SetSize(140, 24)
    btnReset:SetText("Reset Defaults")
    btnReset:SetScript("OnClick", function()
        addon.DB.Reset()
        SyncPanelControls()
        RefreshAllUI()
        addon.Print(L["RESET_DEFAULTS"])
    end)

    local btnDiag = CreateFrame("Button", GetUniqueName("BtnDiag"), panel, "UIPanelButtonTemplate")
    btnDiag:SetPoint("LEFT", btnReset, "RIGHT", 10, 0)
    btnDiag:SetSize(140, 24)
    btnDiag:SetText("Run Diagnostics")
    btnDiag:SetScript("OnClick", function()
        addon.Engine.RunDiagnostics()
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        addon.settingsCategory = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end

    configPanel = panel
    return panel
end

local function OpenOptionsPanel()
    local panel = configPanel or CreateOptionsPanel()

    if Settings and Settings.OpenToCategory and addon.settingsCategory then
        Settings.OpenToCategory(addon.settingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    else
        panel:Show()
    end
end

local function HandleSlashCmd(msg)
    local args = {}
    for word in string.gmatch(msg or "", "%S+") do
        table.insert(args, word)
    end

    local cmd = string.lower(args[1] or "")

    if cmd == "" or cmd == "options" or cmd == "config" or cmd == "gui" then
        OpenOptionsPanel()
    elseif cmd == "help" then
        PrintHelp()
    elseif cmd == "toggle" then
        addon.db.enabled = not addon.db.enabled
        RefreshAllUI()
        addon.Print(addon.db.enabled and L["ADDON_ENABLED"] or L["ADDON_DISABLED"])
    elseif cmd == "debug" then
        if args[2] then
            local qID = tonumber(args[2])
            if qID then
                addon.Engine.PrintBreakdown(qID)
            else
                addon.Print("Invalid Quest ID: %s", args[2])
            end
        else
            if addon.lastHoveredQuestID then
                addon.Engine.PrintBreakdown(addon.lastHoveredQuestID)
            else
                addon.db.debug = not addon.db.debug
                addon.Print(addon.db.debug and L["DEBUG_MODE_ON"] or L["DEBUG_MODE_OFF"])
            end
        end
    elseif cmd == "weights" or cmd == "weight" or cmd == "w" then
        local d = tonumber(args[2])
        local r = tonumber(args[3])
        local c = tonumber(args[4])
        local f = tonumber(args[5])
        local h = tonumber(args[6]) or 0.10

        if not d or not r or not c or not f then
            addon.Print(L["WEIGHTS_ERROR"])
            return
        end

        local nD, nR, nC, nF, nH = Utils.NormalizeWeights(d, r, c, f, h)
        addon.db.weights.difficulty = nD
        addon.db.weights.reward = nR
        addon.db.weights.chain = nC
        addon.db.weights.classFit = nF
        addon.db.weights.density = nH

        RefreshAllUI()
        addon.Print(string.format(L["WEIGHTS_UPDATED"], nD, nR, nC, nF, nH, (nD + nR + nC + nF + nH)))
    elseif cmd == "questlog" or cmd == "ql" then
        addon.db.showInQuestLog = not addon.db.showInQuestLog
        if addon.UI and addon.UI.UpdateQuestLog then
            addon.UI.UpdateQuestLog(true)
        end
        addon.Print(string.format(L["QUEST_LOG_TAG_TOGGLED"], addon.db.showInQuestLog and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "tracker" or cmd == "ot" or cmd == "objectives" then
        addon.db.showInTracker = not addon.db.showInTracker
        if addon.UI and addon.UI.UpdateObjectiveTracker then
            addon.UI.UpdateObjectiveTracker(true)
        end
        addon.Print(string.format(L["TRACKER_TAG_TOGGLED"], addon.db.showInTracker and "|cff00ff00ON|r" or "|cffff0000OFF|r"))
    elseif cmd == "map" or cmd == "worldmap" then
        addon.db.showInWorldMap = not addon.db.showInWorldMap
        if addon.UI and addon.UI.UpdateWorldMapBanner then
            addon.UI.UpdateWorldMapBanner()
        end
        addon.Print("World Map Zone Banner: %s", addon.db.showInWorldMap and "|cff00ff00ON|r" or "|cffff0000OFF|r")
    elseif cmd == "advisor" or cmd == "zones" then
        addon.db.showZoneAdvisor = not addon.db.showZoneAdvisor
        if addon.UI and addon.UI.ToggleZoneAdvisor then
            addon.UI.ToggleZoneAdvisor(addon.db.showZoneAdvisor)
        end
        addon.Print("Zone Advisor Sidebar: %s", addon.db.showZoneAdvisor and "|cff00ff00ON|r" or "|cffff0000OFF|r")
    elseif cmd == "test" or cmd == "diag" then
        addon.Engine.RunDiagnostics()
    elseif cmd == "reset" then
        addon.DB.Reset()
        RefreshAllUI()
        addon.Print(L["RESET_DEFAULTS"])
    else
        addon.Print("Unknown command '%s'. Use |cffffcc00/worthit help|r.", cmd)
    end
end

function UI.InitializeConfig()
    SLASH_WORTHIT1 = "/worthit"
    SLASH_WORTHIT2 = "/questworth"
    SLASH_WORTHIT3 = "/qw"
    SlashCmdList["WORTHIT"] = HandleSlashCmd

    SLASH_QUESTWORTH1 = "/questworth"
    SLASH_QUESTWORTH2 = "/qw"
    SlashCmdList["QUESTWORTH"] = HandleSlashCmd

    CreateOptionsPanel()
end
