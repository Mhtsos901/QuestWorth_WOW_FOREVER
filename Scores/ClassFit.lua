--[[
    WorthIt / QuestWorth - Scores/ClassFit.lua
    Score 4: Class Fit (F) in [0.0, 1.0].
]]

local addonName, addon = ...
addon.Scores = addon.Scores or {}
local Scores = addon.Scores
local Data = addon.Data
local Utils = addon.Utils

-- Fallback tables in case Data tables are uninitialized
local SHIELD_USERS = { WARRIOR = true, PALADIN = true, SHAMAN = true }
local HOLDABLE_USERS = {
    MAGE = true, WARLOCK = true, PRIEST = true, DRUID = true,
    PALADIN = true, SHAMAN = true, MONK = true, EVOKER = true
}

-- Slot mapping for inventory inspection
local EQUIP_SLOT_MAP = {
    ["INVTYPE_HEAD"] = { 1 },
    ["INVTYPE_NECK"] = { 2 },
    ["INVTYPE_SHOULDER"] = { 3 },
    ["INVTYPE_BODY"] = { 4 },
    ["INVTYPE_CHEST"] = { 5 },
    ["INVTYPE_ROBE"] = { 5 },
    ["INVTYPE_WAIST"] = { 6 },
    ["INVTYPE_LEGS"] = { 7 },
    ["INVTYPE_FEET"] = { 8 },
    ["INVTYPE_WRIST"] = { 9 },
    ["INVTYPE_HAND"] = { 10 },
    ["INVTYPE_FINGER"] = { 11, 12 },
    ["INVTYPE_TRINKET"] = { 13, 14 },
    ["INVTYPE_CLOAK"] = { 15 },
    ["INVTYPE_WEAPON"] = { 16, 17 },
    ["INVTYPE_2HWEAPON"] = { 16 },
    ["INVTYPE_WEAPONMAINHAND"] = { 16 },
    ["INVTYPE_WEAPONOFFHAND"] = { 17 },
    ["INVTYPE_SHIELD"] = { 17 },
    ["INVTYPE_HOLDABLE"] = { 17 },
    ["INVTYPE_RANGED"] = { 18 },
    ["INVTYPE_THROWN"] = { 18 },
    ["INVTYPE_RELIC"] = { 18 },
}

-- Hidden tooltip scanner for bag slots and weapon DPS
local tooltipScanner = nil
local function GetTooltipScanner()
    if not tooltipScanner then
        tooltipScanner = CreateFrame("GameTooltip", "WorthIt_TooltipScanner", nil, "GameTooltipTemplate")
        tooltipScanner:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    return tooltipScanner
end

-- Parse slot count of an unequipped reward bag
local function GetRewardBagSlots(itemLink)
    local scanner = GetTooltipScanner()
    scanner:ClearLines()
    scanner:SetHyperlink(itemLink)
    for i = 2, 5 do
        local line = _G["WorthIt_TooltipScannerTextLeft" .. i]
        if line and line:GetText() then
            local text = line:GetText()
            local slots = string.match(text, "(%d+)%s+[Ss]lot") or
                          string.match(text, "(%d+)%s+[Θθ]έσε") or
                          string.match(text, "(%d+)%s+[Pp]latz") or
                          string.match(text, "(%d+)%s+[Ee]mplacement") or
                          string.match(text, "(%d+)%s+[Cc]asilla") or
                          string.match(text, "(%d+)%s+[Cc]uadro") or
                          string.match(text, "(%d+)%s+слот") or
                          string.match(text, "(%d+)%s+Слот")
            if slots then return tonumber(slots) end
        end
    end
    return 10
end

-- Parse Weapon DPS from tooltip or item stats
local function GetWeaponDPS(itemLink)
    if not itemLink then return 0 end
    local stats = (C_Item and C_Item.GetItemStats and C_Item.GetItemStats(itemLink)) or (GetItemStats and GetItemStats(itemLink))
    if stats and stats["ITEM_MOD_DAMAGE_PER_SECOND_SHORT"] then
        return tonumber(stats["ITEM_MOD_DAMAGE_PER_SECOND_SHORT"]) or 0
    end
    local scanner = GetTooltipScanner()
    scanner:ClearLines()
    scanner:SetHyperlink(itemLink)
    for i = 2, 6 do
        local line = _G["WorthIt_TooltipScannerTextLeft" .. i]
        if line and line:GetText() then
            local text = line:GetText()
            local dps = string.match(text, "%((%d+%.?%d*)%s+damage per second%)") or
                        string.match(text, "%((%d+%.?%d*)%s+[Dd][Pp][Ss]%)") or
                        string.match(text, "%((%d+%.?%d*)%s+ζημιά ανά δευτερόλεπτο%)")
            if dps then return tonumber(dps) end
        end
    end
    return 0
end

-- Safe Item Stats Getter
local function GetStatsForItem(itemLink)
    if not itemLink then return {} end
    if C_Item and C_Item.GetItemStats then
        local ok, stats = pcall(C_Item.GetItemStats, itemLink)
        if ok and type(stats) == "table" then return stats end
    end
    if GetItemStats then
        local ok, stats = pcall(GetItemStats, itemLink)
        if ok and type(stats) == "table" then return stats end
    end
    return {}
end

-- Detect Active Class, Spec and Talent Archetype
local function GetPlayerSpecInfo()
    local _, playerClass = UnitClass("player")
    playerClass = playerClass or "WARRIOR"

    local specIndex = nil

    if GetSpecialization then
        local ok, idx = pcall(GetSpecialization)
        if ok and idx and idx > 0 then
            specIndex = idx
        end
    end

    if not specIndex and GetNumTalentTabs and GetTalentTabInfo then
        local bestTab, maxPoints = nil, 0
        local numTabs = GetNumTalentTabs() or 0
        for i = 1, numTabs do
            local _, _, pointsSpent = GetTalentTabInfo(i)
            if pointsSpent and pointsSpent > maxPoints then
                maxPoints = pointsSpent
                bestTab = i
            end
        end
        specIndex = bestTab
    end

    local classTable = (Data.ClassStatWeights and Data.ClassStatWeights[playerClass]) or {}
    local weights = (specIndex and classTable[specIndex]) or classTable["DEFAULT"] or {
        STRENGTH = 1.0, AGILITY = 1.0, INTELLECT = 1.0, STAMINA = 0.5
    }

    return playerClass, specIndex, weights
end

-- Check if Rogue is currently playing a Dagger build (either Assassination spec or wielding a Dagger in Main Hand)
local function IsRogueDaggerBuild(specIndex)
    local mhLink = GetInventoryItemLink("player", 16)
    if mhLink then
        local mhSubClass = select(13, addon.SafeGetItemInfo(mhLink))
        if mhSubClass == 15 then
            return true -- Wielding a Dagger in Main Hand (covers Combat Daggers, Assassination & Subtlety Daggers)
        elseif mhSubClass then
            return (specIndex == 1) -- Only enforce if Assassination when wielding non-dagger
        end
    end
    return (specIndex == 1 or specIndex == 3)
end

-- Check container / bag upgrade potential
local function CheckBagUpgrade(itemLink)
    local rewardSlots = GetRewardBagSlots(itemLink)
    local hasEmptyBagSlot = false
    local minBagSlots = 99

    for bagID = 1, 4 do
        local numSlots = 0
        if C_Container and C_Container.GetContainerNumSlots then
            local ok, s = pcall(C_Container.GetContainerNumSlots, bagID)
            if ok and s then numSlots = s end
        elseif GetContainerNumSlots then
            local ok, s = pcall(GetContainerNumSlots, bagID)
            if ok and s then numSlots = s end
        end

        if numSlots == 0 then
            hasEmptyBagSlot = true
            break
        elseif numSlots < minBagSlots then
            minBagSlots = numSlots
        end
    end

    if hasEmptyBagSlot then
        return 1.00
    end

    if rewardSlots > minBagSlots then
        return 0.90
    else
        return 0.05
    end
end

-- Check weapon upgrade (DPS comparison)
local function CheckWeaponUpgrade(itemLink, equipLoc, targetSlot)
    local slots
    if targetSlot then
        slots = { targetSlot }
    else
        slots = EQUIP_SLOT_MAP[equipLoc] or { 16 }
    end
    local newDPS = GetWeaponDPS(itemLink)
    local _, _, newQuality, newItemLevel = addon.SafeGetItemInfo(itemLink)
    newItemLevel = newItemLevel or 1
    newQuality = newQuality or 1

    for _, slotID in ipairs(slots) do
        local equippedLink = GetInventoryItemLink("player", slotID)
        if not equippedLink and slotID == 17 then
            local mhLink = GetInventoryItemLink("player", 16)
            local mhEquipLoc = nil
            if mhLink then
                local mhInfo = addon.SafeGetItemInfo(mhLink)
                if mhInfo then
                    mhEquipLoc = select(9, addon.SafeGetItemInfo(mhLink))
                end
            end
            if mhEquipLoc == "INVTYPE_2HWEAPON" then
                equippedLink = mhLink
            end
        end

        if not equippedLink then
            return true, 0.30
        end

        local currDPS = GetWeaponDPS(equippedLink)
        if newDPS > 0 and currDPS > 0 and newDPS > currDPS then
            local dpsGainPercent = (newDPS - currDPS) / currDPS
            return true, math.min(0.35, dpsGainPercent * 0.40)
        end
    end

    for _, slotID in ipairs(slots) do
        local equippedLink = GetInventoryItemLink("player", slotID)
        if not equippedLink and slotID == 17 then
            local mhLink = GetInventoryItemLink("player", 16)
            local mhEquipLoc = nil
            if mhLink then
                local mhInfo = addon.SafeGetItemInfo(mhLink)
                if mhInfo then
                    mhEquipLoc = select(9, addon.SafeGetItemInfo(mhLink))
                end
            end
            if mhEquipLoc == "INVTYPE_2HWEAPON" then
                equippedLink = mhLink
            end
        end

        if equippedLink then
            local _, _, currQuality, currItemLevel = addon.SafeGetItemInfo(equippedLink)
            currItemLevel = currItemLevel or 1
            currQuality = currQuality or 1
            local newPower = newItemLevel * (1 + (newQuality * 0.15))
            local currPower = currItemLevel * (1 + (currQuality * 0.15))
            if newPower > currPower then
                return true, math.min(0.25, (newPower - currPower) * 0.02)
            end
        end
    end

    return false, 0.0
end

-- Check armor upgrade
local function CheckArmorUpgrade(itemLink, equipLoc)
    local slots = EQUIP_SLOT_MAP[equipLoc]
    if not slots then return false, 0.0 end

    local _, _, _, newItemLevel = addon.SafeGetItemInfo(itemLink)
    if not newItemLevel or newItemLevel <= 0 then return false, 0.0 end

    for _, slotID in ipairs(slots) do
        local equippedLink = GetInventoryItemLink("player", slotID)
        if not equippedLink and slotID == 17 then
            local mhLink = GetInventoryItemLink("player", 16)
            local mhEquipLoc = nil
            if mhLink then
                local mhInfo = addon.SafeGetItemInfo(mhLink)
                if mhInfo then
                    mhEquipLoc = select(9, addon.SafeGetItemInfo(mhLink))
                end
            end
            if mhEquipLoc == "INVTYPE_2HWEAPON" then
                equippedLink = mhLink
            end
        end

        if not equippedLink then
            return true, 0.30
        end

        local _, _, _, currentItemLevel = addon.SafeGetItemInfo(equippedLink)
        if currentItemLevel and newItemLevel > currentItemLevel then
            return true, math.min(0.30, (newItemLevel - currentItemLevel) * 0.03)
        end
    end

    return false, 0.0
end

-- Cached equipped Hit & Expertise (session cache, invalidated on PLAYER_EQUIPMENT_CHANGED)
local _cachedEquippedStats = nil

local function GetPlayerEquippedHitAndExpertise()
    if _cachedEquippedStats then
        return _cachedEquippedStats.hit, _cachedEquippedStats.expertise
    end

    local currentHit = 0
    local currentExpertise = 0
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link then
            local itemStats = GetStatsForItem(link)
            if itemStats then
                for k, v in pairs(itemStats) do
                    local al = (Data.StatAliases and Data.StatAliases[k]) or k
                    if al == "HIT" then
                        currentHit = currentHit + (v / 10.0) / 100.0
                    elseif al == "EXPERTISE" then
                        -- 4 rating = 1 skill, 1 skill = 0.25% dodge reduction -> 16 rating = 1% (0.01)
                        currentExpertise = currentExpertise + (v / 16.0) / 100.0
                    end
                end
            end
        end
    end

    _cachedEquippedStats = { hit = currentHit, expertise = currentExpertise }
    return currentHit, currentExpertise
end

function Scores.InvalidateEquippedStatsCache()
    _cachedEquippedStats = nil
end
addon.InvalidateHitExpertiseCache = Scores.InvalidateEquippedStatsCache

-- Score a single item reward
local function EvaluateItemFit(itemLink, playerClass, playerLevel, specIndex, statWeights)
    if not itemLink then return 0.30 end

    local name, _, quality, itemLevel, _, _, _, _, equipLoc, _, _, classID, subClassID = addon.SafeGetItemInfo(itemLink)
    if not name then
        local itemID = tonumber(string.match(itemLink or "", "item:(%d+)"))
        if itemID and C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, itemID)
        end
        return 0.50, true
    end

    if classID == 1 or classID == 11 or equipLoc == "INVTYPE_BAG" or equipLoc == "INVTYPE_QUIVER" then
        return CheckBagUpgrade(itemLink)
    end

    if equipLoc == "INVTYPE_SHIELD" then
        local allowed = (Data.ShieldProficiency or SHIELD_USERS)[playerClass]
        if not allowed then return 0.05 end
    elseif equipLoc == "INVTYPE_HOLDABLE" then
        local allowed = (Data.HoldableProficiency or HOLDABLE_USERS)[playerClass]
        if not allowed then return 0.05 end
    end

    local isWeapon = (classID == 2)
    local isRogueDagger = (playerClass == "ROGUE") and IsRogueDaggerBuild(specIndex)

    if isWeapon and subClassID then
        local weaponTable = (Data.ClassWeaponProficiency and Data.ClassWeaponProficiency[playerClass]) or (Data.ClassWeaponProficiency and Data.ClassWeaponProficiency["WARRIOR"])
        if weaponTable and not weaponTable[subClassID] then
            return 0.05
        end

        if isRogueDagger then
            if equipLoc == "INVTYPE_WEAPONMAINHAND" and subClassID ~= 15 then
                return 0.15 -- Non-dagger main hand breaks Backstab/Ambush builds
            elseif equipLoc == "INVTYPE_WEAPON" and subClassID ~= 15 then
                local mhLink = GetInventoryItemLink("player", 16)
                local mhSubClass = mhLink and select(13, addon.SafeGetItemInfo(mhLink))
                if mhSubClass ~= 15 then
                    return 0.15
                end
            end
        end
    end

    if classID == 4 and subClassID and subClassID > 0 and subClassID <= 4 then
        local prof = Data.BaseArmorProficiencies and Data.BaseArmorProficiencies[playerClass]
        if prof then
            if not (prof.allowed and prof.allowed[subClassID]) then
                return 0.05
            end

            local preferred = (Data.GetPreferredArmorType and Data.GetPreferredArmorType(playerClass, playerLevel)) or 1
            if subClassID > preferred then
                return 0.05
            end
        end
    end

    local stats = GetStatsForItem(itemLink)
    local statScore = 0.0
    local beneficialStatCount = 0
    local conflictingStatCount = 0

    local statBudgetUnit = math.max(2.0, playerLevel * 0.40)

    local isMaxLevel = playerLevel >= 60
    local hitCap = isMaxLevel and 0.08 or 0.05
    local expertiseCap = isMaxLevel and 0.065 or 0.05

    local currentHit, currentExpertise = GetPlayerEquippedHitAndExpertise()

    for statKey, statValue in pairs(stats) do
        local alias = (Data.StatAliases and Data.StatAliases[statKey]) or statKey
        local weight = statWeights[alias] or 0.0

        if weight > 0 then
            if alias == "HIT" and currentHit >= hitCap then
                weight = weight * 0.10
            elseif alias == "EXPERTISE" and currentExpertise >= expertiseCap then
                weight = weight * 0.10
            end
            statScore = statScore + (weight * math.min(1.5, statValue / statBudgetUnit))
            beneficialStatCount = beneficialStatCount + 1
        elseif weight == 0 and (alias == "STRENGTH" or alias == "AGILITY" or alias == "INTELLECT" or alias == "SPIRIT") then
            statScore = statScore - 0.50
            conflictingStatCount = conflictingStatCount + 1
        end
    end

    if conflictingStatCount > 0 and beneficialStatCount == 0 then
        return 0.05
    end

    local fitScore = 0.35
    if beneficialStatCount > 0 then
        fitScore = math.min(0.85, 0.35 + (statScore * 0.35))
    elseif isWeapon then
        local dps = GetWeaponDPS(itemLink)
        if dps > 0 then
            fitScore = 0.55
        end
    end

    local qualityBonus = ({[2]=0.0, [3]=0.03, [4]=0.06, [5]=0.10})[quality] or 0
    fitScore = math.min(0.90, fitScore + qualityBonus)

    if fitScore >= 0.30 then
        local skipMainHandCheck = (isRogueDagger and equipLoc == "INVTYPE_WEAPON" and subClassID ~= 15)
        local isUpgrade, upgradeBonus
        if isWeapon then
            isUpgrade, upgradeBonus = CheckWeaponUpgrade(itemLink, equipLoc, skipMainHandCheck and 17 or nil)
        else
            isUpgrade, upgradeBonus = CheckArmorUpgrade(itemLink, equipLoc)
        end

        if isUpgrade then
            fitScore = math.min(1.0, fitScore + 0.15 + upgradeBonus)
        end
    end

    return math.max(0.05, math.min(1.0, fitScore))
end

function Scores.CalculateClassFit(questID)
    local playerClass, specIndex, statWeights = GetPlayerSpecInfo()
    local playerLevel = UnitLevel("player") or 1

    local itemLinks = {}

    if Utils and Utils.GetQuestRewardData then
        local choices, rewards = Utils.GetQuestRewardData(questID)
        if choices then
            for _, link in ipairs(choices) do
                table.insert(itemLinks, link)
            end
        end
        if rewards then
            for _, link in ipairs(rewards) do
                table.insert(itemLinks, link)
            end
        end
    end

    if #itemLinks == 0 then
        return 0.50, {
            hasItems = false,
            bestScore = 0.50,
            final = 0.50,
            note = "No item rewards offered (Neutral)",
        }
    end

    local bestMatch = 0.0
    local bestLink = nil
    local anyPending = false

    for _, link in ipairs(itemLinks) do
        local score, isPending = EvaluateItemFit(link, playerClass, playerLevel, specIndex, statWeights)
        if isPending then anyPending = true end
        if score > bestMatch then
            bestMatch = score
            bestLink = link
        end
    end

    local finalScore = math.max(0.05, math.min(1.0, bestMatch))

    local reason = nil
    if finalScore >= 0.80 then
        reason = "Gear Upgrade"
    elseif finalScore <= 0.20 then
        reason = "Unusable Items"
    end

    local details = {
        hasItems = true,
        itemCount = #itemLinks,
        bestLink = bestLink,
        playerClass = playerClass,
        playerLevel = playerLevel,
        specIndex = specIndex,
        isPending = anyPending,
        final = finalScore,
        reason = reason,
    }

    if addon.db and addon.db.debug then
        addon.Debug("ClassFit [Q:%d]: Checked %d items for %s (Spec %s, Lvl %d) -> BestFit=%.2f",
            questID, #itemLinks, playerClass, tostring(specIndex), playerLevel, finalScore)
    end

    return finalScore, details
end
