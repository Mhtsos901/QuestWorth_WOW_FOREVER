--[[
    WorthIt / QuestWorth - Data/ClassStats.lua
    Stat weights per Class and Specialization.
    Tuned for WoW Forever (Classic Plus level 60 pacing & itemization).
]]

local addonName, addon = ...
addon.Data = addon.Data or {}
local Data = addon.Data

-- Stat mapping tokens returned by C_Item.GetItemStats or item tooltips
Data.StatAliases = {
    -- Primary
    ["ITEM_MOD_STRENGTH_SHORT"] = "STRENGTH",
    ["ITEM_MOD_AGILITY_SHORT"] = "AGILITY",
    ["ITEM_MOD_INTELLECT_SHORT"] = "INTELLECT",
    ["ITEM_MOD_SPIRIT_SHORT"] = "SPIRIT",
    ["ITEM_MOD_STAMINA_SHORT"] = "STAMINA",
    -- Secondary & Ratings
    ["ITEM_MOD_CRIT_RATING_SHORT"] = "CRIT",
    ["ITEM_MOD_CRIT_SHORT"] = "CRIT",
    ["ITEM_MOD_HASTE_RATING_SHORT"] = "HASTE",
    ["ITEM_MOD_HASTE_SHORT"] = "HASTE",
    ["ITEM_MOD_HIT_RATING_SHORT"] = "HIT",
    ["ITEM_MOD_HIT_SHORT"] = "HIT",
    ["ITEM_MOD_MASTERY_RATING_SHORT"] = "MASTERY",
    ["ITEM_MOD_VERSATILITY"] = "VERSATILITY",
    -- Classic / Forever specific
    ["ITEM_MOD_SPELL_POWER_SHORT"] = "SPELL_POWER",
    ["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = "SPELL_POWER",
    ["ITEM_MOD_SPELL_HEALING_DONE_SHORT"] = "SPELL_POWER",
    ["ITEM_MOD_ATTACK_POWER_SHORT"] = "ATTACK_POWER",
    ["ITEM_MOD_RANGED_ATTACK_POWER_SHORT"] = "ATTACK_POWER",
    ["ITEM_MOD_MANA_REGENERATION_SHORT"] = "SPIRIT", -- MP5 behaves like spirit regen
    ["ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"] = "DEFENSE",
    ["ITEM_MOD_BLOCK_VALUE_SHORT"] = "DEFENSE",
    -- WoW Forever additions
    ["ITEM_MOD_EXPERTISE_RATING_SHORT"] = "EXPERTISE",
    ["ITEM_MOD_EXPERTISE_SHORT"] = "EXPERTISE",
    ["ITEM_MOD_WEAPON_SKILL_RATING_SHORT"] = "WEAPON_SKILL", -- severely nerfed, keep for completeness
    ["ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT"] = "ARMOR_PEN",
    ["ITEM_MOD_RESILIENCE_RATING_SHORT"] = "RESILIENCE",
    ["ITEM_MOD_PVP_POWER_SHORT"] = "PVP_POWER",
    ["ITEM_MOD_SPELL_POWER"] = "SPELL_POWER",
}

-- Default Class/Spec stat weights table (Forever-specific, normalized to 1.0)
Data.ClassStatWeights = {
    ["WARRIOR"] = {
        -- Forever: Crit generates Rage. Hit is unified. Expertise is new.
        ["DEFAULT"] = { STRENGTH = 1.0, HIT = 0.9, EXPERTISE = 0.8, CRIT = 0.75, HASTE = 0.5, STAMINA = 0.4, AGILITY = 0.3, ARMOR_PEN = 0.4, INTELLECT = 0.0 },
        [1] = { -- Arms: Hit to 9% > Expertise > Crit > Haste
            STRENGTH = 1.0, HIT = 0.95, EXPERTISE = 0.85, CRIT = 0.75, HASTE = 0.5, STAMINA = 0.4, ARMOR_PEN = 0.4, AGILITY = 0.25,
        },
        [2] = { -- Fury: Hit to 9% > Expertise > Haste > Crit (dual wield needs more hit)
            STRENGTH = 1.0, HIT = 1.0, EXPERTISE = 0.85, HASTE = 0.7, CRIT = 0.65, STAMINA = 0.35, ARMOR_PEN = 0.35, AGILITY = 0.25,
        },
        [3] = { -- Protection: Defense 440 > Hit 9% > Stamina > Avoidance
            STAMINA = 1.0, DEFENSE = 0.95, STRENGTH = 0.7, HIT = 0.8, EXPERTISE = 0.6, HASTE = 0.35, CRIT = 0.25,
        },
    },
    ["PALADIN"] = {
        -- Forever: most reworked class. Ret needs Hit first, then Crit/Str/AP/SP.
        -- Holy: Int/SP/Spirit. Prot: Stamina/Defense/Block.
        ["DEFAULT"] = { STRENGTH = 0.9, INTELLECT = 0.6, STAMINA = 0.6, SPIRIT = 0.4, HIT = 0.7, CRIT = 0.6 },
        [1] = { -- Holy
            INTELLECT = 1.0, SPIRIT = 0.8, SPELL_POWER = 1.0, CRIT = 0.6, HASTE = 0.6, STAMINA = 0.3, STRENGTH = 0.0,
        },
        [2] = { -- Protection
            STAMINA = 1.0, DEFENSE = 0.95, STRENGTH = 0.7, SPELL_POWER = 0.5, HIT = 0.6, EXPERTISE = 0.5, INTELLECT = 0.3,
        },
        [3] = { -- Retribution: Weapon Damage > Hit & Expertise > Crit > Strength > SP
            WEAPON_DPS = 1.0, STRENGTH = 0.9, HIT = 0.85, EXPERTISE = 0.75, CRIT = 0.7, SPELL_POWER = 0.5, HASTE = 0.4, INTELLECT = 0.15, AGILITY = 0.1,
        },
    },
    ["HUNTER"] = {
        -- Forever: Ranged weapon is absolute priority. Hit to 8% > Agility > Crit > Haste.
        ["DEFAULT"] = { AGILITY = 1.0, HIT = 0.9, CRIT = 0.8, HASTE = 0.6, ATTACK_POWER = 0.7, STAMINA = 0.4, INTELLECT = 0.15, STRENGTH = 0.0 },
        [1] = { -- Beast Mastery: Hit > Agility > Crit > Haste
            AGILITY = 1.0, HIT = 0.95, CRIT = 0.85, HASTE = 0.6, ATTACK_POWER = 0.7, STAMINA = 0.4, INTELLECT = 0.15,
        },
        [2] = { -- Marksmanship: Weapon DPS > Hit > Agility > Crit > Haste
            WEAPON_DPS = 1.0, AGILITY = 0.9, HIT = 0.9, CRIT = 0.75, HASTE = 0.6, ATTACK_POWER = 0.6, STAMINA = 0.35, INTELLECT = 0.1,
        },
        [3] = { -- Survival: Agility > Hit > Crit > AP
            AGILITY = 1.0, HIT = 0.85, CRIT = 0.8, ATTACK_POWER = 0.7, HASTE = 0.55, STAMINA = 0.4, INTELLECT = 0.15,
        },
    },
    ["ROGUE"] = {
        -- Forever: Expertise (to 6.5%) > Hit (to 8%) > Agility > Weapon Damage > Crit.
        -- Hit and Crit are unified across melee/ranged/spells (poisons benefit).
        ["DEFAULT"] = { AGILITY = 1.0, HIT = 0.95, EXPERTISE = 0.85, CRIT = 0.75, HASTE = 0.6, ATTACK_POWER = 0.7, STAMINA = 0.35, STRENGTH = 0.25, INTELLECT = 0.0 },
        [1] = { -- Assassination: two daggers. Expertise > Hit > Agility > Weapon Damage > Crit.
            AGILITY = 1.0, EXPERTISE = 0.9, HIT = 0.85, CRIT = 0.8, WEAPON_DPS = 0.75, HASTE = 0.55, ATTACK_POWER = 0.6, STAMINA = 0.35, STRENGTH = 0.2,
        },
        [2] = { -- Combat: Expertise > Hit > Agility > Weapon Damage > Crit. Slow main-hand sword/axe.
            AGILITY = 1.0, EXPERTISE = 0.9, HIT = 0.85, WEAPON_DPS = 0.8, CRIT = 0.75, HASTE = 0.6, ATTACK_POWER = 0.65, STAMINA = 0.35, STRENGTH = 0.25,
        },
        [3] = { -- Subtlety: Agility > Hit (to 9%) > Crit > Strength
            AGILITY = 1.0, HIT = 0.85, CRIT = 0.8, STRENGTH = 0.4, EXPERTISE = 0.6, HASTE = 0.55, STAMINA = 0.4,
        },
    },
    ["PRIEST"] = {
        ["DEFAULT"] = { INTELLECT = 1.0, SPIRIT = 0.8, SPELL_POWER = 1.0, STAMINA = 0.35, HASTE = 0.6, CRIT = 0.55, HIT = 0.5, STRENGTH = 0.0, AGILITY = 0.0 },
        [1] = { -- Discipline
            INTELLECT = 1.0, SPIRIT = 0.85, SPELL_POWER = 1.0, HASTE = 0.6, CRIT = 0.55, HIT = 0.4, STAMINA = 0.3,
        },
        [2] = { -- Holy
            INTELLECT = 1.0, SPIRIT = 0.9, SPELL_POWER = 1.0, HASTE = 0.65, CRIT = 0.5, HIT = 0.35, STAMINA = 0.3,
        },
        [3] = { -- Shadow: Hit to cap > SP = Shadow Damage = Mp5 > Int = Spirit
            SPELL_POWER = 1.0, INTELLECT = 0.85, HIT = 0.9, HASTE = 0.7, CRIT = 0.65, SPIRIT = 0.55, STAMINA = 0.4,
        },
    },
    ["DEATHKNIGHT"] = {
        ["DEFAULT"] = { STRENGTH = 1.0, STAMINA = 0.6, HIT = 0.8, CRIT = 0.7, HASTE = 0.6, INTELLECT = 0.0, AGILITY = 0.0 },
    },
    ["SHAMAN"] = {
        -- Forever: Enhancement uses Mental Quickness -> Int converts to AP + spell damage.
        -- Agility is worth ~2x Str/Int until 33% crit, then Str/Int take over.
        ["DEFAULT"] = { INTELLECT = 0.8, AGILITY = 0.7, STAMINA = 0.5, SPELL_POWER = 0.7, STRENGTH = 0.6, HIT = 0.6 },
        [1] = { -- Elemental
            INTELLECT = 1.0, SPELL_POWER = 1.0, HIT = 0.9, HASTE = 0.8, CRIT = 0.75, STAMINA = 0.4, AGILITY = 0.0,
        },
        [2] = { -- Enhancement: Int converts to AP/SP. Agility strong until 33% crit.
            INTELLECT = 0.9, AGILITY = 0.85, STRENGTH = 0.7, SPELL_POWER = 0.7, HIT = 0.85, EXPERTISE = 0.7, CRIT = 0.75, HASTE = 0.65, ATTACK_POWER = 0.6, STAMINA = 0.4,
        },
        [3] = { -- Restoration
            INTELLECT = 1.0, SPIRIT = 0.8, SPELL_POWER = 1.0, HASTE = 0.7, CRIT = 0.55, STAMINA = 0.35,
        },
    },
    ["MAGE"] = {
        -- Forever: Caster weapons now carry Spell Power — weapon slot feeds spells directly.
        ["DEFAULT"] = { INTELLECT = 1.0, SPELL_POWER = 1.0, HIT = 0.9, CRIT = 0.8, HASTE = 0.7, SPIRIT = 0.4, STAMINA = 0.2, STRENGTH = 0.0, AGILITY = 0.0 },
        [1] = { -- Arcane
            INTELLECT = 1.0, SPELL_POWER = 1.0, HIT = 0.9, CRIT = 0.8, HASTE = 0.7, SPIRIT = 0.5, STAMINA = 0.2,
        },
        [2] = { -- Fire
            INTELLECT = 1.0, SPELL_POWER = 1.0, CRIT = 0.9, HIT = 0.85, HASTE = 0.6, SPIRIT = 0.3, STAMINA = 0.2,
        },
        [3] = { -- Frost
            INTELLECT = 1.0, SPELL_POWER = 1.0, HIT = 0.9, HASTE = 0.8, CRIT = 0.7, SPIRIT = 0.4, STAMINA = 0.2,
        },
    },
    ["WARLOCK"] = {
        ["DEFAULT"] = { INTELLECT = 1.0, SPELL_POWER = 1.0, HIT = 0.9, CRIT = 0.75, HASTE = 0.7, STAMINA = 0.6, SPIRIT = 0.35, STRENGTH = 0.0 },
        [1] = { -- Affliction
            INTELLECT = 1.0, SPELL_POWER = 1.0, HIT = 0.9, HASTE = 0.75, CRIT = 0.6, STAMINA = 0.6, SPIRIT = 0.4,
        },
        [2] = { -- Demonology
            INTELLECT = 1.0, SPELL_POWER = 1.0, HIT = 0.85, CRIT = 0.7, STAMINA = 0.8, HASTE = 0.6, SPIRIT = 0.25,
        },
        [3] = { -- Destruction
            INTELLECT = 1.0, SPELL_POWER = 1.0, CRIT = 0.85, HIT = 0.85, HASTE = 0.7, STAMINA = 0.55, SPIRIT = 0.25,
        },
    },
    ["DRUID"] = {
        -- Forever: forms use weapon DPS. Feral scales with weapon DPS + AP + Agility.
        ["DEFAULT"] = { INTELLECT = 0.8, AGILITY = 0.8, STAMINA = 0.6, STRENGTH = 0.5, SPIRIT = 0.5 },
        [1] = { -- Balance
            INTELLECT = 1.0, SPELL_POWER = 1.0, HIT = 0.85, HASTE = 0.8, CRIT = 0.7, SPIRIT = 0.5, STAMINA = 0.35,
        },
        [2] = { -- Feral (Cat): Weapon DPS > Agility > AP > Crit
            WEAPON_DPS = 1.0, AGILITY = 0.9, ATTACK_POWER = 0.8, CRIT = 0.75, HIT = 0.7, STRENGTH = 0.5, STAMINA = 0.4, INTELLECT = 0.0,
        },
        [3] = { -- Guardian (Bear)
            STAMINA = 1.0, AGILITY = 0.85, DEFENSE = 0.8, WEAPON_DPS = 0.7, CRIT = 0.6, HASTE = 0.4, STRENGTH = 0.5,
        },
        [4] = { -- Restoration
            INTELLECT = 1.0, SPIRIT = 0.8, SPELL_POWER = 1.0, HASTE = 0.8, CRIT = 0.6, STAMINA = 0.3,
        },
    },
    ["MONK"] = {
        ["DEFAULT"] = { AGILITY = 0.8, INTELLECT = 0.8, STAMINA = 0.5 },
    },
    ["DEMONHUNTER"] = {
        ["DEFAULT"] = { AGILITY = 1.0, CRIT = 0.8, HASTE = 0.7, VERSATILITY = 0.6, INTELLECT = 0.0, STRENGTH = 0.0 },
    },
    ["EVOKER"] = {
        ["DEFAULT"] = { INTELLECT = 1.0, HASTE = 0.8, CRIT = 0.7, MASTERY = 0.7, STRENGTH = 0.0, AGILITY = 0.0 },
    },
}
