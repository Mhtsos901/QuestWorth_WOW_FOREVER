--[[
    WorthIt / QuestWorth - Data/Chains.lua
    Fallback quest chain lookup table, reverse index builder,
    and Meta-Knowledge Quest Payoffs & Key Unlocks database.
    
    Provides:
    - Pre-quest & Finale mapping for iconic Dungeons (Deadmines, WC, SM, RFD, ZF, Maraudon, BRD, etc.)
    - Key Unlocks (Shadowforge Key, Skeleton Key, Crescent Key, Searing Gorge Key, etc.)
    - Attunements (Molten Core, Blackwing Lair, Onyxia)
    - Class Milestone Abilities & Weapons (Whirlwind Axe, Defensive/Berserker Stance, Bear Form, Poisons, Totems)
    - High-Value Rewards (Rare/Epic Gear, 14-Slot Bag, Furbolg Form, PvP Trinkets)
    - Dynamic Auto-Detector scanning rewards & keywords for custom/unlisted quests!
]]

local addonName, addon = ...
addon.Data = addon.Data or {}
local Data = addon.Data

-- Reverse index: questID -> { chainID = number, step = number, totalSteps = number, isCap = boolean, isImportant = boolean }
Data.ChainIndex = {}

-- Dynamic API quest line mapping: questID -> questLineID
Data.APIQuestLineMap = {}

Data.KnownChains = {
    -- [1001] The Defias Brotherhood (Westfall / Deadmines)
    [1001] = {
        quests = { 155, 166, 167, 168, 65, 132, 135, 141, 142, 153 },
        isImportant = true,
    },
    -- [1007] Leaders of the Fang (Wailing Caverns)
    [1007] = {
        quests = { 903, 904, 905, 906, 907 },
        isImportant = true,
    },
    -- [1010] The Missing Diplomat (Alliance Mystery)
    [1010] = {
        quests = { 1241, 1242, 1243, 1244, 1245, 1246, 1247, 1248, 1249, 1250, 1261 },
        isImportant = true,
    },
    -- [1015] The Legend of Stalvan (Duskwood Murder Mystery)
    [1015] = {
        quests = { 66, 67, 68, 69, 70, 71, 72, 73, 74, 75 },
        isImportant = true,
    },
    -- [1020] Cortello's Riddle (14-Slot Bag Treasure Hunt)
    [1020] = {
        quests = { 625, 626, 627 },
        isImportant = true,
    },
    -- [1025] Raene's Cleansing (Dartol's Rod Furbolg Form)
    [1025] = {
        quests = { 1029, 1030, 1031, 1032, 1033 },
        isImportant = true,
    },
    -- [1030] Whirlwind Weapon (Warrior Level 30 Weapon Milestone)
    [1030] = {
        quests = { 1711, 1712, 1713, 1714, 1715 },
        isImportant = true,
    },
    -- [1035] The Test of Righteousness (Paladin Level 20 Verigan's Fist)
    [1035] = {
        quests = { 1649, 1650, 1651, 1652 },
        isImportant = true,
    },
    -- [1040] The Key to Scholomance (Skeleton Key)
    [1040] = {
        quests = { 5505, 5511 },
        isImportant = true,
    },
    -- [1045] Dark Iron Legacy (Shadowforge Key)
    [1045] = {
        quests = { 3801, 3802 },
        isImportant = true,
    },
    -- [1050] Legends of Maraudon (Scepter of Celebras)
    [1050] = {
        quests = { 7044, 7064, 7065 },
        isImportant = true,
    },
    -- [1055] In Dreams / Of Love and Family (Tirion Fordring)
    [1055] = {
        quests = { 5742, 5944 },
        isImportant = true,
    },
}

-- Build the fast lookup reverse index
function Data.BuildChainIndex()
    for chainID, chainData in pairs(Data.KnownChains) do
        local quests = chainData.quests or {}
        local total = #quests
        for step, qID in ipairs(quests) do
            Data.ChainIndex[qID] = {
                chainID = chainID,
                step = step,
                totalSteps = total,
                isCap = (step == total),
                isImportant = chainData.isImportant or false,
            }
        end
    end
end

local MAX_API_MAP_SIZE = 5000

-- Active scanner for C_QuestLine API across zones
function Data.ScanQuestLinesForMap(mapID)
    if not mapID or mapID <= 0 then return end
    if not (C_QuestLine and C_QuestLine.GetAvailableQuestLines and C_QuestLine.GetQuestLineQuests) then return end

    local count = 0
    for _ in pairs(Data.APIQuestLineMap) do
        count = count + 1
        if count >= MAX_API_MAP_SIZE then break end
    end
    if count >= MAX_API_MAP_SIZE then
        wipe(Data.APIQuestLineMap)
    end

    local ok, lines = pcall(C_QuestLine.GetAvailableQuestLines, mapID)
    if ok and type(lines) == "table" then
        for _, lineInfo in ipairs(lines) do
            local lineID = lineInfo.questLineID
            if lineID then
                local ok2, quests = pcall(C_QuestLine.GetQuestLineQuests, lineID)
                if ok2 and type(quests) == "table" then
                    for _, qID in ipairs(quests) do
                        Data.APIQuestLineMap[qID] = lineID
                    end
                end
            end
        end
    end
end

-- =========================================================================
-- Meta-Knowledge: Curated Quest Payoffs, Key Unlocks & High-Value Rewards
-- =========================================================================
Data.QuestPayoffs = {
    -- The Deadmines / Defias Brotherhood
    [153] = {
        unlock = "Dungeon: The Deadmines",
        reward = "Westfall Tunic / Chausses of Westfall (Rare)",
        chain = "The Defias Brotherhood (Step 10/10 Finale)",
        note = "Alliance iconic chain finale & main Deadmines quest.",
        summary = "Unlocks: Deadmines Dungeon • Westfall Tunic (Rare)",
        isKeyUnlock = true,
    },
    [155] = { chain = "The Defias Brotherhood (Step 1/10)", note = "Leads to Deadmines dungeon unlock & Westfall Tunic (Rare).", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [166] = { chain = "The Defias Brotherhood (Step 2/10)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [167] = { chain = "The Defias Brotherhood (Step 3/10)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [168] = { chain = "The Defias Brotherhood (Step 4/10)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [65]  = { chain = "The Defias Brotherhood (Step 5/10)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [132] = { chain = "The Defias Brotherhood (Step 6/10)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [135] = { chain = "The Defias Brotherhood (Step 7/10)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [141] = { chain = "The Defias Brotherhood (Step 8/10)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [142] = { chain = "The Defias Brotherhood (Step 9/10)", note = "Escort step in Moonbrook. Unlocks final Deadmines dungeon quest.", summary = "Pre-quest to: Deadmines Dungeon Finale" },
    [81]  = { unlock = "Dungeon: The Deadmines", reward = "Miner's Revenge", note = "Interior Deadmines quest.", summary = "Deadmines Dungeon Quest" },
    [144] = { unlock = "Dungeon: The Deadmines", note = "Interior Deadmines quest.", summary = "Deadmines Dungeon Quest" },

    -- Wailing Caverns
    [907] = {
        unlock = "Dungeon: Wailing Caverns",
        reward = "Crescent Staff / Wingblade (Rare BiS)",
        chain = "Leaders of the Fang (Step 5/5 Finale)",
        note = "Horde & Neutral iconic dungeon weapon rewards.",
        summary = "Unlocks: Wailing Caverns • Crescent Staff / Wingblade (Rare)",
        isKeyUnlock = true,
    },
    [903] = { chain = "Leaders of the Fang (Step 1/5)", summary = "Leads to: Crescent Staff / Wingblade (Rare)" },
    [904] = { chain = "Leaders of the Fang (Step 2/5)", summary = "Leads to: Crescent Staff / Wingblade (Rare)" },
    [905] = { chain = "Leaders of the Fang (Step 3/5)", summary = "Leads to: Crescent Staff / Wingblade (Rare)" },
    [906] = { chain = "Leaders of the Fang (Step 4/5)", summary = "Leads to: Crescent Staff / Wingblade (Rare)" },
    [943] = { unlock = "Dungeon: Wailing Caverns", chain = "The Glowing Shard (Step 1/4)", summary = "WC Shard Chain" },
    [961] = { unlock = "Dungeon: Wailing Caverns", reward = "Talbar Mantle (Rare Shoulder)", chain = "The Glowing Shard (Step 4/4 Finale)", summary = "WC Shard Finale • Talbar Mantle (Rare)" },
    [882] = { unlock = "Dungeon: Wailing Caverns", reward = "Deviate Hide Pack (10-Slot Bag)", summary = "WC Quest • Deviate Hide Pack (10-Slot Bag)" },

    -- Shadowfang Keep
    [1014] = {
        unlock = "Dungeon: Shadowfang Keep",
        reward = "Seal of Sylvanas (Rare BiS Ring)",
        note = "Horde iconic SFK dungeon finale reward.",
        summary = "Shadowfang Keep • Seal of Sylvanas (Rare Ring)",
        isKeyUnlock = true,
    },
    [1013] = { unlock = "Dungeon: Shadowfang Keep", reward = "Ghostly Bow / Brushwood Blade", summary = "Shadowfang Keep Quest" },

    -- Blackfathom Deeps
    [1198] = {
        unlock = "Dungeon: Blackfathom Deeps",
        reward = "Gravestone Scepter (Rare BiS Wand) / Arctic Buckler",
        note = "Alliance BFD dungeon finale.",
        summary = "Blackfathom Deeps • Gravestone Scepter (Rare Wand)",
        isKeyUnlock = true,
    },
    [1199] = {
        unlock = "Dungeon: Blackfathom Deeps",
        reward = "Gravestone Scepter (Rare BiS Wand) / Arctic Buckler",
        note = "Horde BFD dungeon finale.",
        summary = "Blackfathom Deeps • Gravestone Scepter (Rare Wand)",
        isKeyUnlock = true,
    },

    -- Gnomeregan
    [2841] = {
        unlock = "Dungeon: Gnomeregan",
        reward = "Triprunner Dungarees (BiS Rare Leather Legs)",
        note = "Horde Gnomeregan boss quest reward.",
        summary = "Gnomeregan • Triprunner Dungarees (BiS Rare)",
        isKeyUnlock = true,
    },
    [2842] = {
        unlock = "Dungeon: Gnomeregan",
        reward = "Triprunner Dungarees (BiS Rare Leather Legs)",
        note = "Alliance Gnomeregan boss quest reward.",
        summary = "Gnomeregan • Triprunner Dungarees (BiS Rare)",
        isKeyUnlock = true,
    },
    [2845] = { unlock = "Dungeon: Gnomeregan", reward = "Workshop Key / Electrocutioner Lagniappe", summary = "Gnomeregan • Workshop Key", isKeyUnlock = true },

    -- Scarlet Monastery
    [1053] = {
        unlock = "Dungeon: Scarlet Monastery",
        reward = "Bonebiter / Sword of Serenity (Iconic Rare Weapons)",
        note = "Alliance SM finale reward for Mograine & Whitemane.",
        summary = "SM Cathedral Finale • Bonebiter / Sword of Serenity (Rare)",
        isKeyUnlock = true,
    },
    [1048] = {
        unlock = "Dungeon: Scarlet Monastery",
        reward = "Sword of Omen / Prophetic Cane (Iconic Rare Weapons)",
        note = "Horde SM finale reward for Mograine & Whitemane.",
        summary = "SM Cathedral Finale • Sword of Omen / Prophetic Cane (Rare)",
        isKeyUnlock = true,
    },

    -- Razorfen Kraul & Downs
    [1149] = {
        unlock = "Dungeon: Razorfen Downs",
        reward = "Vanquisher's Sword (BiS Fast Sword) / Amberclaw",
        note = "Major dungeon weapon reward for melee classes.",
        summary = "RFD Finale • Vanquisher's Sword (BiS Rare)",
        isKeyUnlock = true,
    },
    [1144] = { unlock = "Dungeon: Razorfen Kraul", reward = "Bainham's Leggings", summary = "RFK Dungeon Quest" },

    -- Zul'Farrak
    [2770] = {
        unlock = "Dungeon Boss: Gahz'rilla (Zul'Farrak)",
        reward = "Carrot on a Stick (+3% Mount Speed Trinket)",
        note = "Requires Mallet of Zul'Farrak to summon Gahz'rilla.",
        summary = "ZF Boss: Gahz'rilla • Carrot on a Stick (Mount Speed)",
        isKeyUnlock = true,
    },

    -- Maraudon
    [7044] = {
        unlock = "Key: Scepter of Celebras (Maraudon Portal Key)",
        note = "Permanent teleport shortcut directly to Maraudon Inner / Princess.",
        summary = "Unlocks: Scepter of Celebras (Maraudon Inner Portal)",
        isKeyUnlock = true,
    },
    [7064] = {
        unlock = "Dungeon: Maraudon (Princess Theradras)",
        reward = "Thrash Blade (BiS Extra Attack Sword) / Resplendent Guardian",
        note = "Alliance Maraudon finale.",
        summary = "Maraudon Princess • Thrash Blade (BiS Rare)",
        isKeyUnlock = true,
    },
    [7065] = {
        unlock = "Dungeon: Maraudon (Princess Theradras)",
        reward = "Thrash Blade (BiS Extra Attack Sword) / Resplendent Guardian",
        note = "Horde Maraudon finale.",
        summary = "Maraudon Princess • Thrash Blade (BiS Rare)",
        isKeyUnlock = true,
    },

    -- Blackrock Depths & Attunements
    [3801] = {
        unlock = "Key: Shadowforge Key (BRD Key)",
        note = "Crucial key that unlocks the interior gates and doors of BRD.",
        summary = "Unlocks: Shadowforge Key (BRD Key)",
        isKeyUnlock = true,
    },
    [3802] = {
        unlock = "Key: Shadowforge Key (BRD Key)",
        note = "Ghost-form quest at the shrine inside Blackrock Mountain.",
        summary = "Unlocks: Shadowforge Key (BRD Key)",
        isKeyUnlock = true,
    },
    [7848] = {
        unlock = "Attunement: Molten Core Raid",
        note = "Permanent teleport shortcut via Lothos Riftwaker into Molten Core.",
        summary = "Unlocks: Molten Core Raid Attunement",
        isKeyUnlock = true,
    },
    [7487] = {
        unlock = "Attunement: Molten Core Raid",
        note = "Permanent teleport shortcut via Lothos Riftwaker into Molten Core.",
        summary = "Unlocks: Molten Core Raid Attunement",
        isKeyUnlock = true,
    },
    [7761] = {
        unlock = "Attunement: Blackwing Lair Raid",
        note = "Permanent Orb of Command teleport into Blackwing Lair.",
        summary = "Unlocks: Blackwing Lair Raid Attunement",
        isKeyUnlock = true,
    },
    [4742] = {
        unlock = "Key: Seal of Ascension (UBRS Key)",
        note = "Crucial key to unlock the gate to Upper Blackrock Spire.",
        summary = "Unlocks: Seal of Ascension (UBRS Key)",
        isKeyUnlock = true,
    },
    [4743] = {
        unlock = "Key: Seal of Ascension (UBRS Key)",
        note = "Forging the Seal in Dustwallow Marsh via Emberstrife.",
        summary = "Unlocks: Seal of Ascension (UBRS Key)",
        isKeyUnlock = true,
    },
    [4322] = {
        unlock = "Attunement: Onyxia's Lair (Alliance)",
        chain = "The Great Masquerade (Step 14/16)",
        note = "Stormwind throne room confrontation.",
        summary = "Attunement: Onyxia's Lair • Great Masquerade",
        isKeyUnlock = true,
    },
    [4264] = {
        unlock = "Attunement: Onyxia's Lair Pre-quest",
        note = "Jail Break escort in BRD with Marshal Windsor.",
        summary = "Attunement: Onyxia's Lair • Jail Break!",
        isKeyUnlock = true,
    },
    [4903] = {
        unlock = "Attunement: Onyxia's Lair (Horde)",
        note = "Horde Onyxia attunement chain starter in LBRS.",
        summary = "Attunement: Onyxia's Lair • Warlord's Command",
        isKeyUnlock = true,
    },

    -- Scholomance Keys
    [5505] = {
        unlock = "Key: Skeleton Key (Scholomance Key)",
        chain = "The Key to Scholomance (Alliance)",
        note = "Crucial key to open the Scholomance front gate.",
        summary = "Unlocks: Skeleton Key (Scholomance Key)",
        isKeyUnlock = true,
    },
    [5511] = {
        unlock = "Key: Skeleton Key (Scholomance Key)",
        chain = "The Key to Scholomance (Horde)",
        note = "Crucial key to open the Scholomance front gate.",
        summary = "Unlocks: Skeleton Key (Scholomance Key)",
        isKeyUnlock = true,
    },

    -- Searing Gorge Gate Key
    [3702] = {
        unlock = "Key: Key to Searing Gorge",
        note = "Permanently unlocks the iron gate between Loch Modan and Searing Gorge.",
        summary = "Unlocks: Key to Searing Gorge (Loch Modan Gate)",
        isKeyUnlock = true,
    },
    [3701] = {
        chain = "Horn of the Beast (Pre-quest)",
        note = "Drops from Margol the Rager. Leads to the Key to Searing Gorge.",
        summary = "Leads to: Key to Searing Gorge",
    },

    -- Dartol's Rod of Transformation (Furbolg Form)
    [1030] = {
        reward = "Dartol's Rod of Transformation (Furbolg Disguise)",
        chain = "Raene's Cleansing (Step 5)",
        note = "DO NOT complete the final turn-in if you want to keep the permanent Furbolg form!",
        summary = "Reward: Dartol's Rod of Transformation (Keep Unfinished!)",
        isKeyUnlock = true,
    },
    [1032] = {
        reward = "Dartol's Rod of Transformation (Furbolg Disguise)",
        chain = "Raene's Cleansing (Step 5)",
        note = "DO NOT complete the final turn-in if you want to keep the permanent Furbolg form!",
        summary = "Reward: Dartol's Rod of Transformation (Keep Unfinished!)",
        isKeyUnlock = true,
    },

    -- Really Sticky Glue & Light of Elune
    [863] = {
        reward = "10x Really Sticky Glue (10-sec CC Root)",
        note = "Target immobilizer for PvP and emergency escapes.",
        summary = "Reward: 10x Really Sticky Glue (10s Root)",
    },
    [101] = {
        reward = "Light of Elune (10s Complete Invulnerability)",
        note = "Consumable 10-second Divine Shield / Immunity potion.",
        summary = "Reward: Light of Elune (10s Immunity)",
    },

    -- Badlands Trinkets
    [778] = {
        reward = "Skull of Impending Doom (Off-hand CC Break & Sprint)",
        note = "Legendary PvP and escape off-hand item.",
        summary = "Reward: Skull of Impending Doom (PvP CC Break)",
    },
    [777] = {
        reward = "Nifty Stopwatch (+40% Run Speed Trinket)",
        note = "Valuable sprint trinket usable by all classes.",
        summary = "Reward: Nifty Stopwatch (+40% Speed Trinket)",
    },

    -- Bags
    [138] = {
        reward = "Captain Sanders' Booty Bag (8-Slot Bag)",
        note = "Early Westfall treasure hunt reward.",
        summary = "Reward: Captain Sanders' Booty Bag (8-Slot)",
    },
    [625] = { chain = "Cortello's Riddle (Step 1/3)", summary = "Leads to: Explorer's Knapsack (14-Slot Bag)" },
    [626] = { chain = "Cortello's Riddle (Step 2/3)", summary = "Leads to: Explorer's Knapsack (14-Slot Bag)" },
    [627] = {
        reward = "Explorer's Knapsack (14-Slot Bag)",
        chain = "Cortello's Riddle (Step 3/3 Finale)",
        note = "Treasure hunt finale in the Hinterlands waterfall.",
        summary = "Reward: Explorer's Knapsack (14-Slot Bag)",
        isKeyUnlock = true,
    },

    -- Major Lore Chains
    [1241] = { chain = "The Missing Diplomat (Step 1/11)", note = "Alliance epic investigation chain.", summary = "The Missing Diplomat Chain" },
    [1261] = { chain = "The Missing Diplomat (Finale)", summary = "The Missing Diplomat (Finale)" },
    [66]   = { chain = "The Legend of Stalvan (Step 1/10)", note = "Duskwood classic murder mystery.", summary = "The Legend of Stalvan Chain" },
    [75]   = { reward = "Stalvan's Reaper (2H Axe)", chain = "The Legend of Stalvan (Finale)", summary = "The Legend of Stalvan (Finale)" },
    [229]  = { reward = "Archeus (2H Sword)", chain = "The Story of Morgan Ladimore", summary = "Mor'ladim Finale • Archeus (Rare Sword)" },
    [5601] = { chain = "The Battle of Darrowshire (Step 1/6)", note = "Little Pamela in EPL.", summary = "Battle of Darrowshire Chain" },
    [5944] = {
        reward = "Mark of Fordring (BiS Neck) / Fordring's Seal",
        chain = "In Dreams (Tirion Fordring Finale)",
        note = "Escort Taelan Fordring from Hearthglen. Iconic Classic storyline.",
        summary = "In Dreams • Mark of Fordring (BiS Neck)",
        isKeyUnlock = true,
    },

    -- Class Milestones
    -- Warrior
    [1665] = { unlock = "Ability: Defensive Stance & Taunt", note = "Warrior Level 10 class milestone.", summary = "Unlocks: Defensive Stance & Taunt", isKeyUnlock = true },
    [1498] = { unlock = "Ability: Defensive Stance & Taunt", note = "Warrior Level 10 class milestone.", summary = "Unlocks: Defensive Stance & Taunt", isKeyUnlock = true },
    [1505] = { unlock = "Ability: Defensive Stance & Taunt", note = "Warrior Level 10 class milestone.", summary = "Unlocks: Defensive Stance & Taunt", isKeyUnlock = true },
    [1718] = { unlock = "Ability: Berserker Stance & Intercept", note = "Warrior Level 30 milestone on Fray Island.", summary = "Unlocks: Berserker Stance & Intercept", isKeyUnlock = true },
    [1719] = { unlock = "Ability: Berserker Stance & Intercept", note = "Warrior Level 30 milestone on Fray Island.", summary = "Unlocks: Berserker Stance & Intercept", isKeyUnlock = true },
    [1711] = { chain = "Whirlwind Weapon (Step 1/5)", note = "Leads to Whirlwind Axe / Sword / Flail (Level 30).", summary = "Leads to: Whirlwind Weapon (Level 30)" },
    [1715] = { reward = "Whirlwind Axe / Sword / Flail (Iconic Weapon)", chain = "Whirlwind Weapon (Finale)", note = "Level 30 Warrior weapon milestone.", summary = "Reward: Whirlwind Axe / Sword / Flail", isKeyUnlock = true },

    -- Paladin
    [1641] = { unlock = "Ability: Redemption (Resurrection)", note = "Paladin Level 12 resurrection spell quest.", summary = "Unlocks: Redemption (Resurrection)", isKeyUnlock = true },
    [1642] = { unlock = "Ability: Redemption (Resurrection)", note = "Paladin Level 12 resurrection spell quest.", summary = "Unlocks: Redemption (Resurrection)", isKeyUnlock = true },
    [1643] = { unlock = "Ability: Redemption (Resurrection)", note = "Paladin Level 12 resurrection spell quest.", summary = "Unlocks: Redemption (Resurrection)", isKeyUnlock = true },
    [1644] = { unlock = "Ability: Redemption (Resurrection)", note = "Paladin Level 12 resurrection spell quest.", summary = "Unlocks: Redemption (Resurrection)", isKeyUnlock = true },
    [1649] = { chain = "The Test of Righteousness (Step 1/4)", note = "Leads to Verigan's Fist (Level 20 Paladin 2H Hammer).", summary = "Leads to: Verigan's Fist (2H Hammer)" },
    [1652] = { reward = "Verigan's Fist (Powerful 2H Hammer)", chain = "The Test of Righteousness (Finale)", summary = "Reward: Verigan's Fist (2H Hammer)", isKeyUnlock = true },

    -- Rogue
    [2240] = { unlock = "Ability: Poisons & Thistle Tea Recipe", note = "Rogue Level 20 class milestone.", summary = "Unlocks: Poisons & Thistle Tea Recipe", isKeyUnlock = true },
    [2359] = { unlock = "Ability: Poisons & Thistle Tea Recipe", note = "Rogue Level 20 class milestone (Klaven's Tower).", summary = "Unlocks: Poisons & Thistle Tea Recipe", isKeyUnlock = true },

    -- Druid
    [5921] = { unlock = "Ability: Bear Form & Growl", note = "Druid Level 10 class milestone.", summary = "Unlocks: Bear Form & Growl", isKeyUnlock = true },
    [5922] = { unlock = "Ability: Bear Form & Growl", note = "Druid Level 10 class milestone.", summary = "Unlocks: Bear Form & Growl", isKeyUnlock = true },
    [27]   = { unlock = "Ability: Aquatic Form", note = "Druid Level 16 class milestone.", summary = "Unlocks: Aquatic Form", isKeyUnlock = true },
    [28]   = { unlock = "Ability: Aquatic Form", note = "Druid Level 16 class milestone.", summary = "Unlocks: Aquatic Form", isKeyUnlock = true },
    [29]   = { unlock = "Ability: Aquatic Form", note = "Druid Level 16 class milestone.", summary = "Unlocks: Aquatic Form", isKeyUnlock = true },

    -- Warlock
    [1501] = { unlock = "Summon: Voidwalker (Tank Pet)", note = "Warlock Level 10 class milestone.", summary = "Unlocks: Summon Voidwalker", isKeyUnlock = true },
    [1504] = { unlock = "Summon: Voidwalker (Tank Pet)", note = "Warlock Level 10 class milestone.", summary = "Unlocks: Summon Voidwalker", isKeyUnlock = true },
    [1506] = { unlock = "Summon: Voidwalker (Tank Pet)", note = "Warlock Level 10 class milestone.", summary = "Unlocks: Summon Voidwalker", isKeyUnlock = true },
    [1507] = { unlock = "Summon: Succubus (Seduce Pet)", note = "Warlock Level 20 class milestone.", summary = "Unlocks: Summon Succubus", isKeyUnlock = true },
    [1510] = { unlock = "Summon: Succubus (Seduce Pet)", note = "Warlock Level 20 class milestone.", summary = "Unlocks: Summon Succubus", isKeyUnlock = true },
    [1798] = { unlock = "Summon: Felhunter (Silence Pet)", note = "Warlock Level 30 class milestone.", summary = "Unlocks: Summon Felhunter", isKeyUnlock = true },

    -- Shaman
    [1516] = { unlock = "Totem: Earth Totem", note = "Shaman Level 4 class milestone.", summary = "Unlocks: Earth Totem", isKeyUnlock = true },
    [1524] = { unlock = "Totem: Fire Totem", note = "Shaman Level 10 class milestone.", summary = "Unlocks: Fire Totem", isKeyUnlock = true },
    [63]   = { unlock = "Totem: Water Totem", note = "Shaman Level 20 class milestone journey.", summary = "Unlocks: Water Totem", isKeyUnlock = true },
    [100]  = { unlock = "Totem: Water Totem", note = "Shaman Level 20 class milestone journey.", summary = "Unlocks: Water Totem", isKeyUnlock = true },
    [96]   = { unlock = "Totem: Air Totem", note = "Shaman Level 30 class milestone.", summary = "Unlocks: Air Totem", isKeyUnlock = true },

    -- Hunter
    [6061] = { unlock = "Ability: Beast Taming & Pet Training", note = "Hunter Level 10 class milestone.", summary = "Unlocks: Beast Taming & Pet Training", isKeyUnlock = true },
    [6062] = { unlock = "Ability: Beast Taming & Pet Training", note = "Hunter Level 10 class milestone.", summary = "Unlocks: Beast Taming & Pet Training", isKeyUnlock = true },
    [6063] = { unlock = "Ability: Beast Taming & Pet Training", note = "Hunter Level 10 class milestone.", summary = "Unlocks: Beast Taming & Pet Training", isKeyUnlock = true },
    [6064] = { unlock = "Ability: Beast Taming & Pet Training", note = "Hunter Level 10 class milestone.", summary = "Unlocks: Beast Taming & Pet Training", isKeyUnlock = true },
}

-- Title-based matching (handles custom Forever servers or varying quest IDs)
Data.QuestPayoffsByTitle = {
    ["the defias brotherhood"] = {
        unlock = "Dungeon: The Deadmines",
        reward = "Westfall Tunic / Chausses (Rare)",
        chain = "The Defias Brotherhood",
        note = "Alliance iconic chain leading to the Deadmines dungeon.",
        summary = "Unlocks: Deadmines Dungeon • Westfall Tunic (Rare)",
        isKeyUnlock = true,
    },
    ["leaders of the fang"] = {
        unlock = "Dungeon: Wailing Caverns",
        reward = "Crescent Staff / Wingblade (Rare BiS)",
        chain = "Leaders of the Fang",
        note = "Iconic dungeon weapon rewards in Wailing Caverns.",
        summary = "Unlocks: Wailing Caverns • Crescent Staff / Wingblade",
        isKeyUnlock = true,
    },
    ["arugal must die"] = {
        unlock = "Dungeon: Shadowfang Keep",
        reward = "Seal of Sylvanas (Rare BiS Ring)",
        summary = "Shadowfang Keep • Seal of Sylvanas (Rare)",
        isKeyUnlock = true,
    },
    ["blackfathom villainy"] = {
        unlock = "Dungeon: Blackfathom Deeps",
        reward = "Gravestone Scepter (Rare BiS Wand)",
        summary = "Blackfathom Deeps • Gravestone Scepter (Rare)",
        isKeyUnlock = true,
    },
    ["rig wars"] = {
        unlock = "Dungeon: Gnomeregan",
        reward = "Triprunner Dungarees (BiS Rare Leather Legs)",
        summary = "Gnomeregan • Triprunner Dungarees (BiS Rare)",
        isKeyUnlock = true,
    },
    ["the grand betrayal"] = {
        unlock = "Dungeon: Gnomeregan",
        reward = "Triprunner Dungarees (BiS Rare Leather Legs)",
        summary = "Gnomeregan • Triprunner Dungarees (BiS Rare)",
        isKeyUnlock = true,
    },
    ["in the name of the light"] = {
        unlock = "Dungeon: Scarlet Monastery",
        reward = "Bonebiter / Sword of Serenity (Iconic Rare)",
        summary = "SM Cathedral • Bonebiter / Sword of Serenity (Rare)",
        isKeyUnlock = true,
    },
    ["into the scarlet monastery"] = {
        unlock = "Dungeon: Scarlet Monastery",
        reward = "Sword of Omen / Prophetic Cane (Iconic Rare)",
        summary = "SM Cathedral • Sword of Omen / Prophetic Cane (Rare)",
        isKeyUnlock = true,
    },
    ["bring the end"] = {
        unlock = "Dungeon: Razorfen Downs",
        reward = "Vanquisher's Sword (BiS Rare Fast Sword)",
        summary = "RFD Finale • Vanquisher's Sword (BiS Rare)",
        isKeyUnlock = true,
    },
    ["gahz'rilla"] = {
        unlock = "Dungeon Boss: Gahz'rilla (Zul'Farrak)",
        reward = "Carrot on a Stick (+3% Mount Speed)",
        summary = "ZF Boss: Gahz'rilla • Carrot on a Stick (Mount Speed)",
        isKeyUnlock = true,
    },
    ["legends of maraudon"] = {
        unlock = "Key: Scepter of Celebras (Maraudon Portal)",
        summary = "Unlocks: Scepter of Celebras (Maraudon Portal)",
        isKeyUnlock = true,
    },
    ["corruption of earth and seed"] = {
        unlock = "Dungeon: Maraudon Princess",
        reward = "Thrash Blade (BiS Rare Extra Attack Sword)",
        summary = "Maraudon Princess • Thrash Blade (BiS Rare)",
        isKeyUnlock = true,
    },
    ["dark iron legacy"] = {
        unlock = "Key: Shadowforge Key (BRD Key)",
        summary = "Unlocks: Shadowforge Key (BRD Key)",
        isKeyUnlock = true,
    },
    ["attunement to the core"] = {
        unlock = "Attunement: Molten Core Raid",
        summary = "Unlocks: Molten Core Raid Attunement",
        isKeyUnlock = true,
    },
    ["blackhand's command"] = {
        unlock = "Attunement: Blackwing Lair Raid",
        summary = "Unlocks: Blackwing Lair Raid Attunement",
        isKeyUnlock = true,
    },
    ["seal of ascension"] = {
        unlock = "Key: Seal of Ascension (UBRS Key)",
        summary = "Unlocks: Seal of Ascension (UBRS Key)",
        isKeyUnlock = true,
    },
    ["the key to scholomance"] = {
        unlock = "Key: Skeleton Key (Scholomance Key)",
        summary = "Unlocks: Skeleton Key (Scholomance Key)",
        isKeyUnlock = true,
    },
    ["key to searing gorge"] = {
        unlock = "Key: Key to Searing Gorge",
        summary = "Unlocks: Key to Searing Gorge (Loch Modan Gate)",
        isKeyUnlock = true,
    },
    ["margol the rager"] = {
        chain = "Key to Searing Gorge",
        summary = "Leads to: Key to Searing Gorge",
    },
    ["horn of the beast"] = {
        chain = "Key to Searing Gorge",
        summary = "Leads to: Key to Searing Gorge",
    },
    ["raene's cleansing"] = {
        reward = "Dartol's Rod of Transformation (Furbolg Form)",
        note = "DO NOT complete final turn-in to keep Furbolg disguise!",
        summary = "Reward: Dartol's Rod of Transformation (Furbolg Disguise)",
        isKeyUnlock = true,
    },
    ["a solvent spirit"] = {
        reward = "10x Really Sticky Glue (10s Root)",
        summary = "Reward: 10x Really Sticky Glue (10s Root)",
    },
    ["the light of elune"] = {
        reward = "Light of Elune (10s Complete Immunity)",
        summary = "Reward: Light of Elune (10s Immunity)",
    },
    ["morbent fel"] = {
        reward = "Light of Elune / Duskwood Finale",
        summary = "Duskwood Finale • Light of Elune",
    },
    ["forbidden knowledge"] = {
        reward = "Skull of Impending Doom (PvP CC Break)",
        summary = "Reward: Skull of Impending Doom (PvP CC Break)",
    },
    ["this is going to be hard"] = {
        reward = "Nifty Stopwatch (+40% Run Speed)",
        summary = "Reward: Nifty Stopwatch (+40% Speed Trinket)",
    },
    ["captain sanders' hidden treasure"] = {
        reward = "Captain Sanders' Booty Bag (8-Slot Bag)",
        summary = "Reward: Captain Sanders' Booty Bag (8-Slot)",
    },
    ["cortello's riddle"] = {
        reward = "Explorer's Knapsack (14-Slot Bag)",
        summary = "Reward: Explorer's Knapsack (14-Slot Bag)",
        isKeyUnlock = true,
    },
    ["the missing diplomat"] = {
        chain = "The Missing Diplomat (Alliance Lore)",
        summary = "The Missing Diplomat Chain",
    },
    ["the legend of stalvan"] = {
        chain = "The Legend of Stalvan (Duskwood Murder)",
        summary = "The Legend of Stalvan Chain",
    },
    ["a daughter's love"] = {
        reward = "Archeus (Rare 2H Sword)",
        summary = "Mor'ladim Finale • Archeus (Rare Sword)",
    },
    ["in dreams"] = {
        reward = "Mark of Fordring (BiS Neck) / Fordring's Seal",
        chain = "Tirion Fordring Storyline Finale",
        summary = "In Dreams • Mark of Fordring (BiS Neck)",
        isKeyUnlock = true,
    },
    ["the test of righteousness"] = {
        reward = "Verigan's Fist (Paladin 2H Hammer)",
        summary = "Reward: Verigan's Fist (2H Hammer)",
        isKeyUnlock = true,
    },
    ["whirlwind weapon"] = {
        reward = "Whirlwind Axe / Sword / Flail (Warrior L30)",
        summary = "Reward: Whirlwind Axe / Weapon (Level 30)",
        isKeyUnlock = true,
    },
}

-- Known dungeon & instance keywords for the Auto-Detector
local DUNGEON_KEYWORDS = {
    { pattern = "deadmines", name = "The Deadmines" },
    { pattern = "wailing caverns", name = "Wailing Caverns" },
    { pattern = "shadowfang", name = "Shadowfang Keep" },
    { pattern = "blackfathom", name = "Blackfathom Deeps" },
    { pattern = "gnomeregan", name = "Gnomeregan" },
    { pattern = "scarlet monastery", name = "Scarlet Monastery" },
    { pattern = "razorfen", name = "Razorfen Kraul / Downs" },
    { pattern = "uldaman", name = "Uldaman" },
    { pattern = "zul'farrak", name = "Zul'Farrak" },
    { pattern = "maraudon", name = "Maraudon" },
    { pattern = "sunken temple", name = "Sunken Temple" },
    { pattern = "atal'hakkar", name = "Sunken Temple" },
    { pattern = "blackrock depths", name = "Blackrock Depths" },
    { pattern = "blackrock spire", name = "Blackrock Spire" },
    { pattern = "stratholme", name = "Stratholme" },
    { pattern = "scholomance", name = "Scholomance" },
    { pattern = "dire maul", name = "Dire Maul" },
    { pattern = "molten core", name = "Molten Core Raid" },
    { pattern = "blackwing lair", name = "Blackwing Lair Raid" },
    { pattern = "onyxia", name = "Onyxia's Lair Raid" },
}

-- Public API: Retrieve Meta-Knowledge Payoff for any quest
function Data.GetQuestPayoff(questID, questTitle)
    local targetID = tonumber(questID) or questID
    local payoff = nil

    -- 1. Check direct questID lookup in Data.QuestPayoffs
    if targetID and Data.QuestPayoffs[targetID] then
        local entry = Data.QuestPayoffs[targetID]
        payoff = {
            unlock = entry.unlock,
            reward = entry.reward,
            chain = entry.chain,
            note = entry.note,
            summary = entry.summary,
            isKeyUnlock = entry.isKeyUnlock or false,
        }
    end

    -- 2. Check title lookup in Data.QuestPayoffsByTitle
    local rawTitle = questTitle
    if not rawTitle and targetID and targetID > 0 then
        local basic = addon.Utils and addon.Utils.GetQuestBasicInfo and addon.Utils.GetQuestBasicInfo(targetID)
        if basic and basic.title then rawTitle = basic.title end
    end

    local cleanTitle = nil
    if rawTitle then
        cleanTitle = addon.Utils and addon.Utils.CleanQuestTitle and addon.Utils.CleanQuestTitle(rawTitle) or rawTitle
        cleanTitle = string.gsub(cleanTitle, "^%s*%[%d+%]%s*", "")
        cleanTitle = string.lower(string.gsub(cleanTitle, "^%s*(.-)%s*$", "%1"))

        if not payoff and Data.QuestPayoffsByTitle[cleanTitle] then
            local entry = Data.QuestPayoffsByTitle[cleanTitle]
            payoff = {
                unlock = entry.unlock,
                reward = entry.reward,
                chain = entry.chain,
                note = entry.note,
                summary = entry.summary,
                isKeyUnlock = entry.isKeyUnlock or false,
            }
        end
    end

    -- 3. Dynamic Auto-Detector: Scans rewards, bags, keys, and keywords for unlisted/custom quests
    local detectedUnlock = nil
    local detectedReward = nil
    local detectedChain = nil
    local detectedNote = nil
    local isKeyUnlock = false

    if targetID and targetID > 0 and addon.Utils and addon.Utils.GetQuestRewardData then
        local choices, rewards = addon.Utils.GetQuestRewardData(targetID)
        local allItems = {}
        for _, link in ipairs(choices or {}) do table.insert(allItems, link) end
        for _, link in ipairs(rewards or {}) do table.insert(allItems, link) end

        for _, itemLink in ipairs(allItems) do
            local name, _, quality, _, _, itemType, _, _, _, _, _, _, classID = addon.Utils.SafeGetItemInfo(itemLink)
            if name then
                -- Rare (Blue, Quality 3) or Epic (Purple, Quality 4)
                if quality and quality >= 4 and not detectedReward then
                    detectedReward = name .. " (Epic Gear)"
                    isKeyUnlock = true
                elseif quality and quality == 3 and not detectedReward then
                    detectedReward = name .. " (Rare Gear)"
                    isKeyUnlock = true
                end

                -- Container / Bag (ClassID 1 or itemType Container)
                if (classID == 1 or itemType == "Container" or string.find(name, "Bag") or string.find(name, "Pack") or string.find(name, "Pouch")) and not detectedReward then
                    detectedReward = name .. " (Bag Container)"
                    isKeyUnlock = true
                end

                -- Keys (ClassID 13 or itemType Key or "Key" in name)
                if (classID == 13 or itemType == "Key" or string.find(name, "Key") or string.find(name, "Scepter")) and not detectedUnlock then
                    detectedUnlock = "Key: " .. name
                    isKeyUnlock = true
                end
            end
        end
    end

    -- Keyword scan on title
    if cleanTitle then
        for _, kw in ipairs(DUNGEON_KEYWORDS) do
            if string.find(cleanTitle, kw.pattern, 1, true) then
                detectedUnlock = detectedUnlock or ("Dungeon: " .. kw.name)
                isKeyUnlock = true
                break
            end
        end
        if string.find(cleanTitle, "attunement", 1, true) then
            detectedUnlock = detectedUnlock or "Raid Attunement Quest"
            isKeyUnlock = true
        end
        if string.find(cleanTitle, "key to", 1, true) or string.find(cleanTitle, "skeleton key", 1, true) then
            detectedUnlock = detectedUnlock or "Key Unlock Quest"
            isKeyUnlock = true
        end
    end

    -- Merge auto-detected attributes if not already present
    if not payoff and (detectedUnlock or detectedReward or detectedChain or detectedNote) then
        payoff = {}
    end

    if payoff then
        payoff.unlock = payoff.unlock or detectedUnlock
        payoff.reward = payoff.reward or detectedReward
        payoff.chain = payoff.chain or detectedChain
        payoff.note = payoff.note or detectedNote
        if isKeyUnlock then payoff.isKeyUnlock = true end

        -- Build concise summary if missing
        if not payoff.summary then
            local parts = {}
            if payoff.unlock then table.insert(parts, payoff.unlock) end
            if payoff.reward then table.insert(parts, payoff.reward) end
            if #parts == 0 and payoff.chain then table.insert(parts, payoff.chain) end
            if #parts > 0 then
                payoff.summary = table.concat(parts, " • ")
            end
        end
    end

    return payoff
end

-- Initialize the index
Data.BuildChainIndex()
