--[[
    WorthIt / QuestWorth - Data/ArmorTypes.lua
    Armor, Weapon & Container proficiencies per class.
    
    WoW Forever / Classic Rules:
    - Armor Progression:
        Warrior / Paladin: Mail (1-39), Plate (40-60).
        Hunter / Shaman: Leather (1-39), Mail (40-60).
    - Weapon Proficiencies:
        Strictly enforced per class.
]]

local addonName, addon = ...
addon.Data = addon.Data or {}
local Data = addon.Data

-- Armor subClass IDs (classID == 4):
-- 1 = Cloth, 2 = Leather, 3 = Mail, 4 = Plate, 6 = Shield
Data.BaseArmorProficiencies = {
    ["WARRIOR"] = {
        allowed = { [1] = true, [2] = true, [3] = true, [4] = true, [6] = true },
    },
    ["PALADIN"] = {
        allowed = { [1] = true, [2] = true, [3] = true, [4] = true, [6] = true },
    },
    ["HUNTER"] = {
        allowed = { [1] = true, [2] = true, [3] = true },
    },
    ["ROGUE"] = {
        allowed = { [1] = true, [2] = true },
    },
    ["PRIEST"] = {
        allowed = { [1] = true },
    },
    ["DEATHKNIGHT"] = {
        allowed = { [1] = true, [2] = true, [3] = true, [4] = true },
    },
    ["SHAMAN"] = {
        allowed = { [1] = true, [2] = true, [3] = true, [6] = true },
    },
    ["MAGE"] = {
        allowed = { [1] = true },
    },
    ["WARLOCK"] = {
        allowed = { [1] = true },
    },
    ["DRUID"] = {
        allowed = { [1] = true, [2] = true },
    },
    ["MONK"] = {
        allowed = { [1] = true, [2] = true },
    },
    ["DEMONHUNTER"] = {
        allowed = { [1] = true, [2] = true },
    },
    ["EVOKER"] = {
        allowed = { [1] = true, [2] = true, [3] = true },
    },
}

-- Shield proficiency (INVTYPE_SHIELD)
Data.ShieldProficiency = {
    ["WARRIOR"] = true,
    ["PALADIN"] = true,
    ["SHAMAN"] = true,
}

-- Held-in-off-hand (INVTYPE_HOLDABLE / Frills)
Data.HoldableProficiency = {
    ["MAGE"] = true,
    ["PRIEST"] = true,
    ["WARLOCK"] = true,
    ["DRUID"] = true,
    ["SHAMAN"] = true,
    ["PALADIN"] = true,
    ["MONK"] = true,
    ["EVOKER"] = true,
}

-- Weapon subClass IDs (classID == 2):
-- 0=1H Axe, 1=2H Axe, 2=Bow, 3=Gun, 4=1H Mace, 5=2H Mace, 6=Polearm, 7=1H Sword, 8=2H Sword,
-- 9=Warglaive, 10=Staff, 13=Fist, 14=Misc, 15=Dagger, 16=Thrown, 18=Crossbow, 19=Wand, 20=Fishing Pole
--
-- WoW Forever weapon proficiencies (verified November 2026):
-- • Rogues can now learn One-Handed Axes (new in Forever)
-- • Druids can now learn Polearms (new in Forever)
-- • Paladins CAN use axes (1H + 2H) — this is unchanged from Classic and confirmed
-- • Paladins are the ONLY class without Daggers
-- • Hunter can use Staves (already present, keep)
-- • All racial weapon skill bonuses removed; weapon skill on gear severely nerfed
Data.ClassWeaponProficiency = {
    ["WARRIOR"] = {
        -- Every weapon except Wands
        [0]=true, [1]=true, [2]=true, [3]=true, [4]=true, [5]=true, [6]=true, [7]=true,
        [8]=true, [10]=true, [13]=true, [14]=true, [15]=true, [16]=true, [18]=true, [20]=true,
    },
    ["PALADIN"] = {
        -- Axes, Maces, Swords, Polearms. NO Daggers, NO ranged, NO staves.
        [0]=true, [1]=true, [4]=true, [5]=true, [6]=true, [7]=true, [8]=true, [14]=true, [20]=true,
    },
    ["HUNTER"] = {
        -- Bows, Crossbows, Daggers, Fist, Guns, 1H Axes, 1H Swords, Polearms,
        -- Staves, Thrown, 2H Axes, 2H Swords
        [0]=true, [1]=true, [2]=true, [3]=true, [6]=true, [7]=true, [8]=true, [10]=true,
        [13]=true, [14]=true, [15]=true, [16]=true, [18]=true, [20]=true,
    },
    ["ROGUE"] = {
        -- Bows, Crossbows, Daggers, Fist, Guns, 1H Axes (NEW), 1H Maces,
        -- 1H Swords, Thrown
        [0]=true, [2]=true, [3]=true, [4]=true, [7]=true, [13]=true, [14]=true, [15]=true,
        [16]=true, [18]=true, [20]=true,
    },
    ["PRIEST"] = {
        -- Daggers, 1H Maces, Staves, Wands
        [4]=true, [10]=true, [14]=true, [15]=true, [19]=true, [20]=true,
    },
    ["DEATHKNIGHT"] = {
        -- (Forever doesn't have DK, but kept for compatibility)
        [0]=true, [1]=true, [4]=true, [5]=true, [6]=true, [7]=true, [8]=true, [14]=true, [20]=true,
    },
    ["SHAMAN"] = {
        -- Daggers, Fist, 1H Axes, 1H Maces, Staves, 2H Axes, 2H Maces
        [0]=true, [1]=true, [4]=true, [5]=true, [10]=true, [13]=true, [14]=true, [15]=true, [20]=true,
    },
    ["MAGE"] = {
        -- Daggers, 1H Swords, Staves, Wands
        [7]=true, [10]=true, [14]=true, [15]=true, [19]=true, [20]=true,
    },
    ["WARLOCK"] = {
        -- Daggers, 1H Swords, Staves, Wands
        [7]=true, [10]=true, [14]=true, [15]=true, [19]=true, [20]=true,
    },
    ["DRUID"] = {
        -- Daggers, Fist, 1H Maces, Polearms (NEW), Staves, 2H Maces
        [4]=true, [5]=true, [6]=true, [10]=true, [13]=true, [14]=true, [15]=true, [20]=true,
    },
    ["MONK"] = {
        [0]=true, [4]=true, [7]=true, [10]=true, [13]=true, [14]=true, [20]=true,
    },
    ["DEMONHUNTER"] = {
        [0]=true, [7]=true, [9]=true, [13]=true, [14]=true, [15]=true, [20]=true,
    },
    ["EVOKER"] = {
        [0]=true, [4]=true, [7]=true, [10]=true, [13]=true, [14]=true, [15]=true, [20]=true,
    },
}

-- Dynamic resolver for preferred armor type based on current player level
function Data.GetPreferredArmorType(playerClass, playerLevel)
    playerLevel = playerLevel or (addon.Player and addon.Player.GetLevel and addon.Player.GetLevel()) or UnitLevel("player") or 1

    if playerClass == "WARRIOR" or playerClass == "PALADIN" or playerClass == "DEATHKNIGHT" then
        return (playerLevel >= 40) and 4 or 3 -- Plate at 40+, Mail before 40
    elseif playerClass == "HUNTER" or playerClass == "SHAMAN" or playerClass == "EVOKER" then
        return (playerLevel >= 40) and 3 or 2 -- Mail at 40+, Leather before 40
    elseif playerClass == "ROGUE" or playerClass == "DRUID" or playerClass == "MONK" or playerClass == "DEMONHUNTER" then
        return 2 -- Leather
    else
        return 1 -- Cloth (Mage, Priest, Warlock)
    end
end
