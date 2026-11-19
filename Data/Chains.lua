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
        quests = { 65, 132, 135, 141, 142, 155, 166 },
        isImportant = true,
    },
    -- [1007] Leaders of the Fang (Wailing Caverns)
    [1007] = {
        quests = { 870, 877, 880, 1489, 1490, 914 },
        isImportant = true,
    },
    -- [1010] The Missing Diplomat (Alliance Mystery)
    [1010] = {
        quests = { 1241, 1242, 1243, 1244, 1245, 1246, 1247, 1248, 1249, 1250, 1261 },
        isImportant = true,
    },
    -- [1015] The Legend of Stalvan (Duskwood Murder Mystery)
    [1015] = {
        quests = { 66, 67, 68, 69, 70, 71, 72, 74, 75, 78, 79, 80, 97, 98 },
        isImportant = true,
    },
    -- [1020] Cortello's Riddle (14-Slot Bag Treasure Hunt)
    [1020] = {
        quests = { 624, 625, 626 },
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
    -- [1060] The Night Watch (Duskwood Undead Defense)
    [1060] = {
        quests = { 56, 57, 58 },
        isImportant = true,
    },
    -- [1065] The Hermit & Eliza (Duskwood Lore)
    [1065] = {
        quests = { 165, 148, 149, 154, 157, 158, 156, 159, 133, 134, 160, 251, 401, 252, 253 },
        isImportant = true,
    },
    -- [1070] The Story of Morgan Ladimore (Mor'Ladim & Archeus)
    [1070] = {
        quests = { 225, 227, 228, 229, 231 },
        isImportant = true,
    },
    -- [1071] Sven's Revenge & Morbent Fel (Duskwood)
    [1071] = {
        quests = { 95, 230, 262, 265, 266, 323, 268, 269, 270, 325, 55 },
        isImportant = true,
    },
    -- [1072] Look to the Stars (Duskwood)
    [1072] = {
        quests = { 174, 175, 177, 181 },
        isImportant = false,
    },
    -- [1073] Barrens Beast Mastery (Cry of the Thunderhawk)
    [1073] = {
        quests = { 903, 905, 907, 913 },
        isImportant = false,
    },
    -- [1074] Krazek's Cookery -> Favor for Krazek -> Return to Corporal Kaleb (STV / Arathi)
    [1074] = {
        quests = { 210, 627, 622 },
        isImportant = false,
    },
    -- [1075] Nesingwary Safari: Tiger Mastery -> Big Game Hunter
    [1075] = {
        quests = { 185, 186, 187, 188, 208 },
        isImportant = true,
    },
    -- [1076] Nesingwary Safari: Panther Mastery -> Big Game Hunter
    [1076] = {
        quests = { 190, 191, 192, 193, 208 },
        isImportant = true,
    },
    -- [1077] Nesingwary Safari: Raptor Mastery -> Big Game Hunter
    [1077] = {
        quests = { 194, 195, 196, 197, 208 },
        isImportant = true,
    },
}

-- Build the fast lookup reverse index (deterministic priority: longer chain wins, curated < 3000 wins ties)
function Data.BuildChainIndex()
    wipe(Data.ChainIndex)
    if Data.InvalidateMetaMemo then
        Data.InvalidateMetaMemo()
    end
    local sortedIDs = {}
    for chainID in pairs(Data.KnownChains) do
        if type(chainID) == "number" then
            table.insert(sortedIDs, chainID)
        end
    end
    table.sort(sortedIDs)

    for _, chainID in ipairs(sortedIDs) do
        local chainData = Data.KnownChains[chainID]
        local quests = (chainData and chainData.quests) or {}
        local total = #quests
        local chainHasUnlock = false
        local chainHasReward = false
        if Data.QuestPayoffs then
            for _, id in ipairs(quests) do
                local p = Data.QuestPayoffs[id]
                if p then
                    if p.unlock or p.isKeyUnlock then chainHasUnlock = true end
                    if p.reward then chainHasReward = true end
                end
            end
        end
        for step, qID in ipairs(quests) do
            if type(qID) == "number" and qID > 0 then
                local existing = Data.ChainIndex[qID]
                local shouldReplace = false
                if not existing then
                    shouldReplace = true
                elseif total > (existing.totalSteps or 0) then
                    shouldReplace = true
                elseif total == (existing.totalSteps or 0) and chainID < 3000 and (existing.chainID or 9999) >= 3000 then
                    shouldReplace = true
                end

                if shouldReplace then
                    Data.ChainIndex[qID] = {
                        chainID = chainID,
                        step = step,
                        totalSteps = total,
                        isCap = (step == total),
                        isImportant = chainData.isImportant or false,
                        hasUnlock = chainHasUnlock,
                        hasMajorReward = chainHasReward,
                    }
                end
            end
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
-- Meta-Knowledge: Item-Quest Mapping (Hidden Item Drops & Quest Starters)
-- =========================================================================
Data.ItemQuestMap = {
    [1358]  = 136,   -- Captain Sanders' Treasure Map (Westfall)
    [1361]  = 138,   -- Captain Sanders' Treasure Map (Part 2)
    [1362]  = 139,   -- Captain Sanders' Treasure Map (Part 3)
    [8623]  = 2767,  -- OOX-17/TN Distress Beacon (Tanaris)
    [8704]  = 2766,  -- OOX-09/HL Distress Beacon (Hinterlands)
    [8705]  = 2768,  -- OOX-22/SC Distress Beacon (Feralas)
    [5462]  = 943,   -- The Glowing Shard (Wailing Caverns)
    [10593] = 3701,  -- Horn of the Beast (Margol the Rager / Searing Gorge Key)
    [4098]  = 625,   -- Cortello's Riddle Scroll (Bloodsail / STV)
    [4433]  = 633,   -- A Letter to Sully Balloo (Thandol Span)
    [4854]  = 1017,  -- Befouled Water Globe (Ashenvale)
    [4851]  = 954,   -- Glowing Stave (Darkshore)
    [5805]  = 1435,  -- The Corrupter Flute (Desolace)
    [10441] = 6981,  -- Glowing Shard (Wailing Caverns)
    [9254]  = 7003,  -- Perfect Yeti Hide (Feralas)
    [12840] = 977,   -- Pristine Yeti Hide (Winterspring)
    [13180] = 5405,  -- Araj's Scarab (Andorhal)
    [12844] = 5401,  -- Minion's Scourgestone (WPL/EPL)
    [2794]  = 338,   -- The Green Hills of Stranglethorn (STV)
    [4941]  = 1029,  -- Dartol's Rod of Transformation (Ashenvale)
}

-- =========================================================================
-- Meta-Knowledge: Curated Quest Payoffs, Key Unlocks & High-Value Rewards
-- =========================================================================
Data.QuestPayoffs = {
    -- The Deadmines / Defias Brotherhood
    [65]  = { chain = "The Defias Brotherhood (Step 1/7)", note = "First step of the required Defias Brotherhood chain.", summary = "Leads to: Deadmines Dungeon & Westfall Tunic", isTalkTo = true },
    [132] = { chain = "The Defias Brotherhood (Step 2/7)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic", isTalkTo = true },
    [135] = { chain = "The Defias Brotherhood (Step 3/7)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic", isTalkTo = true },
    [141] = { chain = "The Defias Brotherhood (Step 4/7)", summary = "Leads to: Deadmines Dungeon & Westfall Tunic", isTalkTo = true },
    [142] = { chain = "The Defias Brotherhood (Step 5/7)", note = "Defias Messenger spawns along Westfall roads. Unlocks the traitor escort.", summary = "Leads to: Deadmines Dungeon & Westfall Tunic" },
    [155] = { chain = "The Defias Brotherhood (Step 6/7)", note = "Escort the Defias Traitor in Moonbrook. Unlocks final Deadmines dungeon quest.", summary = "Pre-quest to: Deadmines Dungeon Finale" },
    [166] = {
        unlock = "Dungeon: The Deadmines",
        reward = "Westfall Tunic / Chausses / Staff of Westfall (Rare)",
        chain = "The Defias Brotherhood (Step 7/7 Finale)",
        note = "Alliance iconic chain finale & main Deadmines quest.",
        summary = "Unlocks: Deadmines Dungeon • Westfall Tunic (Rare)",
        isKeyUnlock = true,
    },
    [153] = { reward = "Leather Armor", note = "Red Leather Bandanas from Defias in Westfall / Moonbrook.", summary = "Westfall Defias Quest" },
    [167] = { unlock = "Dungeon: The Deadmines", note = "Interior Deadmines quest (Oh Brother. . .).", summary = "Deadmines Dungeon Quest" },
    [168] = { unlock = "Dungeon: The Deadmines", note = "Interior Deadmines quest (Collecting Memories).", summary = "Deadmines Dungeon Quest" },
    [81]  = { unlock = "Dungeon: The Deadmines", reward = "Miner's Revenge", note = "Interior Deadmines quest.", summary = "Deadmines Dungeon Quest" },
    [144] = { unlock = "Dungeon: The Deadmines", note = "Interior Deadmines quest.", summary = "Deadmines Dungeon Quest" },

    -- Wailing Caverns
    [914] = {
        unlock = "Dungeon: Wailing Caverns",
        reward = "Crescent Staff / Wingblade (Rare BiS)",
        chain = "Leaders of the Fang (Step 6/6 Finale)",
        note = "Horde & Neutral iconic dungeon weapon rewards.",
        summary = "Unlocks: Wailing Caverns • Crescent Staff / Wingblade (Rare)",
        isKeyUnlock = true,
    },
    [903] = { chain = "Barrens Beast Mastery (Step 1/4)", note = "Prowlers of the Barrens near The Crossroads.", summary = "Leads to: Cry of the Thunderhawk" },
    [905] = { chain = "Barrens Beast Mastery (Step 2/4)", note = "The Angry Scytheclaws (feathers from Barrens raptors).", summary = "Leads to: Cry of the Thunderhawk" },
    [907] = { chain = "Barrens Beast Mastery (Step 3/4)", note = "Enraged Thunder Lizards (blood from Southern Barrens thunder lizards).", summary = "Leads to: Cry of the Thunderhawk" },
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
    [1036] = {
        reward = "Light of Elune (10s Complete Invulnerability)",
        note = "Consumable 10-second Divine Shield / Immunity potion.",
        summary = "Reward: Light of Elune (10s Immunity)",
        isKeyUnlock = true,
    },
    [101] = {
        reward = "Totem of Infliction (Duskwood)",
        note = "Gather 10 Ghoul Fangs, 10 Skeleton Fingers, and 5 Vials of Spider Venom for Madame Eva.",
        summary = "Duskwood Reagent Quest • Madame Eva",
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
    [624] = { chain = "Cortello's Riddle (Step 1/3)", summary = "Leads to: Explorer's Knapsack (14-Slot Bag)" },
    [625] = { chain = "Cortello's Riddle (Step 2/3)", summary = "Leads to: Explorer's Knapsack (14-Slot Bag)" },
    [626] = {
        reward = "Explorer's Knapsack (14-Slot Bag)",
        chain = "Cortello's Riddle (Step 3/3 Finale)",
        note = "Treasure hunt finale behind the Hinterlands waterfall.",
        summary = "Reward: Explorer's Knapsack (14-Slot Bag)",
        isKeyUnlock = true,
    },
    [627] = {
        chain = "Krazek's Cookery (Step 2/3)",
        note = "Favor for Krazek in Booty Bay: requires 4 Lesser Bloodstone Ore. Unlocks Return to Corporal Kaleb.",
        summary = "Leads to: Return to Corporal Kaleb",
    },

    -- Major Lore Chains
    [1241] = { chain = "The Missing Diplomat (Step 1/11)", note = "Alliance epic investigation chain.", summary = "The Missing Diplomat Chain" },
    [1261] = { chain = "The Missing Diplomat (Finale)", summary = "The Missing Diplomat (Finale)" },
    [66]   = { chain = "The Legend of Stalvan (Step 1/14)", note = "Duskwood classic murder mystery.", summary = "The Legend of Stalvan Chain", isTalkTo = true },
    [98]   = { reward = "Ring of Precision / Stalvan's Reaper", chain = "The Legend of Stalvan (Finale)", summary = "The Legend of Stalvan (Finale)", isKeyUnlock = true },
    [225]  = { chain = "The Story of Morgan Ladimore (Step 1/5)", note = "Inspect the weathered grave in Raven Hill. Safe talk-to breadcrumb leading to Mor'ladim & Archeus (Rare 2H Sword).", summary = "Leads to: Mor'ladim & Archeus (Rare Sword)", isTalkTo = true },
    [227]  = { chain = "The Story of Morgan Ladimore (Step 2/5)", note = "Speak with Commander Althea Ebonlocke in Darkshire. Safe talk-to step before Mor'ladim.", summary = "Leads to: Mor'ladim & Archeus (Rare Sword)", isTalkTo = true },
    [228]  = { reward = "Mor'ladim's Skull", chain = "The Story of Morgan Ladimore (Step 3/5)", note = "Defeat Level 35 Elite Mor'Ladim in Raven Hill Cemetery. Pre-quest to Archeus.", summary = "Mor'ladim • Leads to Archeus (Rare Sword)", isKeyUnlock = true },
    [229]  = { chain = "The Story of Morgan Ladimore (Step 4/5)", note = "Deliver Morgan's skull to Watcher Sarah Ladimore on the Darkshire road.", summary = "Leads to: Archeus (Rare Sword)", isTalkTo = true },
    [231]  = { reward = "Archeus (Rare 2H Sword) / Lion's Heart", chain = "The Story of Morgan Ladimore (Step 5/5 Finale)", note = "Place Sarah's ring on Morgan Ladimore's grave in Raven Hill.", summary = "Mor'ladim Finale • Archeus (Rare Sword)", isKeyUnlock = true },
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

    -- Hidden Item Drop Quests & Secrets
    [2767] = { unlock = "Pet: Mechanical Chicken", chain = "Find OOX-17/TN! (Tanaris Escort)", origin = "Hidden Item Drop", note = "Rare distress beacon drop from Tanaris mobs.", summary = "Hidden Drop • OOX-17/TN Distress Beacon", isKeyUnlock = true },
    [2766] = { unlock = "Pet: Mechanical Chicken", chain = "Find OOX-09/HL! (Hinterlands Escort)", origin = "Hidden Item Drop", note = "Rare distress beacon drop from Hinterlands mobs.", summary = "Hidden Drop • OOX-09/HL Distress Beacon", isKeyUnlock = true },
    [2768] = { unlock = "Pet: Mechanical Chicken", chain = "Find OOX-22/SC! (Feralas Escort)", origin = "Hidden Item Drop", note = "Rare distress beacon drop from Feralas mobs.", summary = "Hidden Drop • OOX-22/SC Distress Beacon", isKeyUnlock = true },
    [3791] = { reward = "Mechanical Chicken Companion Pet", chain = "An OOX of Your Own (Finale)", origin = "Secret Quest Finale", note = "Requires all 3 distress beacon escorts completed.", summary = "Reward: Mechanical Chicken Companion Pet", isKeyUnlock = true },
    [633]  = { reward = "Sully Balloo's Letter", origin = "Hidden World Corpse", note = "Item drop from submerged dwarf corpse at Thandol Span.", summary = "Hidden Quest • Underwater Corpse at Thandol Span" },
    [1017] = { origin = "Hidden Item Drop", note = "Item drop from Ashenvale water elementals.", summary = "Hidden Item Drop • Befouled Water Globe" },
    [954]  = { origin = "Hidden Item Drop", note = "Item drop from Darkshore murlocs and naga.", summary = "Hidden Item Drop • Glowing Stave" },
    [1435] = { origin = "Hidden Item Drop", note = "Item drop flute from Desolace centaurs.", summary = "Hidden Item Drop • The Corrupter" },
    [3367] = { reward = "Slaghide Gauntlets (Mail/Leather)", origin = "Hidden Item Drop", note = "Item drop in Searing Gorge.", summary = "Hidden Item Drop • Slaghide Gauntlets" },
    [7003] = { reward = "Pratt's Handcrafted Gloves", origin = "Hidden Item Drop", note = "Rare item drop from Feralas yetis.", summary = "Hidden Drop • Perfect Yeti Hide" },
    [977]  = { reward = "Pristine Yeti Hide Gear", origin = "Hidden Item Drop", note = "Rare item drop from Winterspring yetis.", summary = "Hidden Drop • Pristine Yeti Hide" },
    [5405] = { origin = "Hidden Item Drop", note = "Item drop from Araj the Summoner in Andorhal.", summary = "Hidden Drop • Araj's Scarab" },
    [5401] = { origin = "Hidden Item Drop", note = "Scourgestone turn-ins in Western/Eastern Plaguelands.", summary = "Argent Dawn Commission Turn-in" },
    [338]  = { reward = "Jungle Remedy / STV Book", origin = "Secret Collection", note = "Collection of all 4 chapters of Hemingway's book.", summary = "STV Lore • Green Hills of Stranglethorn" },

    -- Wanted Posters & Bounties
    [176]  = { reward = "Redridge Machete / Footman's Boots", origin = "Wanted Poster", note = "Wanted poster outside Lion's Pride Inn in Elwynn.", summary = "Wanted Poster • Hogger Bounty", isKeyUnlock = true },
    [267]  = { reward = "Chok'sul's Cleaver", origin = "Wanted Poster", note = "Wanted poster in Thelsamar (Loch Modan).", summary = "Wanted Poster • Chok'sul Bounty", isKeyUnlock = true },
    [184]  = { origin = "Wanted Poster", note = "Wanted poster in Sentinel Hill (Westfall).", summary = "Wanted Poster • Lieutenant Valent Bounty" },
    [169]  = { reward = "Blackrock Mace / Redridge Shield", origin = "Wanted Poster", note = "Wanted poster outside Lakeshire Town Hall (Gath'Ilzogg).", summary = "Wanted Poster • Gath'Ilzogg Bounty", isKeyUnlock = true },
    [180]  = { origin = "Wanted Poster", note = "Wanted poster outside Lakeshire Town Hall (Lieutenant Fangore).", summary = "Wanted Poster • Lieutenant Fangore Bounty" },
    [125]  = { note = "Oslow's Toolbox underwater in Lake Everstill east of the bridge.", summary = "Redridge Underwater Quest • The Lost Tools" },
    [563]  = { origin = "Wanted Poster", note = "Wanted poster in Southshore (Hillsbrad).", summary = "Wanted Poster • Baron Vardus Bounty" },
    [681]  = { origin = "Wanted Poster", note = "Wanted poster in Refuge Pointe (Arathi).", summary = "Wanted Poster • Syndicate Personnel Bounty" },
    [2781] = { origin = "Wanted Poster", note = "Wanted poster in Gadgetzan (Tanaris).", summary = "Wanted Poster • Caliph Scorpidsting" },
    [2875] = { origin = "Wanted Poster", note = "Wanted poster in Gadgetzan (Tanaris).", summary = "Wanted Poster • Andre Firebeard" },
    [4740] = { origin = "Wanted Poster", note = "Wanted poster in Auberdine (Darkshore).", summary = "Wanted Poster • Murkdeep Bounty" },
    [2855] = { origin = "Wanted Poster", note = "Wanted poster in Aerie Peak (Hinterlands).", summary = "Wanted Poster • Vile Priestess Hexx" },
    [1070] = { origin = "Wanted Poster", note = "Wanted poster in Sun Rock Retreat / Stonetalon.", summary = "Wanted Poster • Besseleth Bounty" },

    -- Duskwood Leveling Chains & Lore
    [56]   = { chain = "The Night Watch (Step 1/3)", note = "Darkshire undead defense series. Kill Skeletal Warriors and Mages.", summary = "The Night Watch (Step 1/3)" },
    [57]   = { chain = "The Night Watch (Step 2/3)", note = "Second step in Raven Hill cemetery against Skeletal Fiends and Horrors.", summary = "The Night Watch (Step 2/3)" },
    [58]   = { reward = "Ring of the Night Watch / Weapon", chain = "The Night Watch (Step 3/3 Finale)", note = "Final step in Dawning Wood Catacombs against Plague Spreaders.", summary = "The Night Watch Finale • Ring of the Night Watch", isKeyUnlock = true },
    [226]  = { note = "Kill 12 Starving Dire Wolves and 8 Rabid Dire Wolves along the northern riverbank near Sven's Camp.", summary = "Duskwood Wolf Hunt" },
    [230]  = { chain = "Sven's Revenge (Step 2)", note = "Deliver the book from Sven's Farm to Sven Yorgen at Sven's Camp.", summary = "Sven's Revenge Chain", isTalkTo = true },
    [55]   = { reward = "Tunic of Westfall / Morbent Fel Finale Gear", chain = "Sven's Revenge / Morbent Fel (Finale)", note = "Use Morbent's Bane to break Morbent Fel's shield in northern Raven Hill.", summary = "Morbent Fel Finale", isKeyUnlock = true },
    [165]  = { chain = "The Hermit & Eliza (Step 1)", note = "Visit Abercrombie northeast of Raven Hill Cemetery.", summary = "The Hermit & Eliza Chain", isTalkTo = true },
    [148]  = { chain = "The Hermit & Eliza (Step 2)", note = "Speak with Madame Eva in Darkshire.", summary = "The Hermit & Eliza Chain", isTalkTo = true },
    [156]  = { chain = "The Hermit & Eliza", note = "Gather Rot Blossoms from skeletons in Raven Hill Cemetery.", summary = "The Hermit & Eliza Chain" },
    [157]  = { chain = "The Hermit & Eliza", summary = "The Hermit & Eliza Chain", isTalkTo = true },
    [158]  = { chain = "The Hermit & Eliza", summary = "The Hermit & Eliza Chain", isTalkTo = true },
    [253]  = { reward = "Embalmer's Robes / Bride of the Embalmer Finale", chain = "The Hermit & Eliza (Finale)", note = "Slay Level 31 Elite Eliza at her grave northeast of Raven Hill.", summary = "Bride of the Embalmer Finale", isKeyUnlock = true },
    [163]  = { note = "Althea Ebonlocke's research into the Darkshire undead curse.", summary = "Duskwood Undead Defense" },
    [174]  = { chain = "Look to the Stars (Step 1/4)", note = "Requires Bronze Tube from Engineering. Leads to telescope quest rewards.", summary = "Look to the Stars Chain" },
    [175]  = { chain = "Look to the Stars (Step 2/4)", summary = "Look to the Stars Chain", isTalkTo = true },
    [177]  = { chain = "Look to the Stars (Step 3/4)", summary = "Look to the Stars Chain" },
    [181]  = { reward = "Viktori's Telescope / Star Belt", chain = "Look to the Stars (Finale)", summary = "Look to the Stars (Finale)", isKeyUnlock = true },
    [90]   = { reward = "Recipe: Seasoned Wolf Kabobs", note = "Farmed from Duskwood wolves or bought on AH (tradeable Lean Wolf Flanks).", summary = "Cooking Recipe Quest" },
    [93]   = { reward = "Recipe: Gooey Spider Cake (Dusky Crab Cakes)", note = "6 Gooey Spider Legs from Pygmy Venom Web Spiders in northern Duskwood.", summary = "Cooking Recipe Quest" },
    [377]  = { unlock = "Dungeon: The Stockade", note = "Stockade prison dungeon quest in Stormwind.", summary = "Dungeon: The Stockade", isKeyUnlock = true },
    [115]  = { reward = "Midnight Orb / Redridge Finale", note = "Elite quest inside Stonewatch Keep & Render's Rock in Redridge.", summary = "Redridge Elite Quest", isKeyUnlock = true },

    -- Stranglethorn Vale: Nesingwary Safari Mastery Chains
    [185]  = { chain = "Tiger Mastery (Step 1/4)", unlock = "Big Game Hunter Finale", summary = "Nesingwary Safari • Tiger Mastery (1/4)" },
    [190]  = { chain = "Panther Mastery (Step 1/4)", unlock = "Big Game Hunter Finale", summary = "Nesingwary Safari • Panther Mastery (1/4)" },
    [194]  = { chain = "Raptor Mastery (Step 1/4)", unlock = "Big Game Hunter Finale", summary = "Nesingwary Safari • Raptor Mastery (1/4)" },
    [208]  = { reward = "Master Hunter's Bow / Rifle (Rare)", chain = "Big Game Hunter (Safari Finale)", summary = "Safari Finale • Master Hunter's Bow / Rifle", isKeyUnlock = true },
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
        reward = "Morbent Fel Finale Gear",
        note = "Use Morbent's Bane from your bags to strip Morbent Fel's shield in northern Raven Hill.",
        summary = "Duskwood Finale • Morbent Fel",
        isKeyUnlock = true,
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
    ["the weathered grave"] = {
        chain = "The Story of Morgan Ladimore (Step 1/4)",
        note = "Investigate the weathered grave in Raven Hill. Safe talk-to breadcrumb leading to Mor'ladim & Archeus (Rare 2H Sword).",
        summary = "Leads to: Mor'ladim & Archeus (Rare Sword)",
        isTalkTo = true,
    },
    ["morgan ladimore"] = {
        chain = "The Story of Morgan Ladimore (Step 2/4)",
        note = "Speak with Commander Althea Ebonlocke in Darkshire. Safe talk-to step before Mor'ladim.",
        summary = "Leads to: Mor'ladim & Archeus (Rare Sword)",
        isTalkTo = true,
    },
    ["mor'ladim"] = {
        reward = "Mor'ladim's Skull",
        chain = "The Story of Morgan Ladimore (Step 3/4)",
        summary = "Mor'ladim • Leads to Archeus (Rare Sword)",
        isKeyUnlock = true,
    },
    ["the daughter's love"] = {
        reward = "Archeus (Rare 2H Sword)",
        chain = "The Story of Morgan Ladimore (Step 4/4 Finale)",
        summary = "Mor'ladim Finale • Archeus (Rare Sword)",
        isKeyUnlock = true,
    },
    ["a daughter's love"] = {
        reward = "Archeus (Rare 2H Sword)",
        chain = "The Story of Morgan Ladimore (Step 4/4 Finale)",
        summary = "Mor'ladim Finale • Archeus (Rare Sword)",
        isKeyUnlock = true,
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
    ["find oox-17/tn!"] = {
        unlock = "Pet: Mechanical Chicken",
        origin = "Hidden Item Drop",
        note = "Rare distress beacon drop in Tanaris.",
        summary = "Hidden Drop • OOX-17/TN Distress Beacon",
        isKeyUnlock = true,
    },
    ["find oox-09/hl!"] = {
        unlock = "Pet: Mechanical Chicken",
        origin = "Hidden Item Drop",
        note = "Rare distress beacon drop in Hinterlands.",
        summary = "Hidden Drop • OOX-09/HL Distress Beacon",
        isKeyUnlock = true,
    },
    ["find oox-22/sc!"] = {
        unlock = "Pet: Mechanical Chicken",
        origin = "Hidden Item Drop",
        note = "Rare distress beacon drop in Feralas.",
        summary = "Hidden Drop • OOX-22/SC Distress Beacon",
        isKeyUnlock = true,
    },
    ["an oox of your own"] = {
        reward = "Mechanical Chicken Companion Pet",
        origin = "Secret Quest Finale",
        summary = "Reward: Mechanical Chicken Companion Pet",
        isKeyUnlock = true,
    },
    ["a letter to sully balloo"] = {
        origin = "Hidden World Corpse",
        note = "Underwater dwarf corpse at Thandol Span.",
        summary = "Hidden Quest • Underwater Corpse at Thandol Span",
    },
    ["the green hills of stranglethorn"] = {
        origin = "Secret Collection",
        summary = "STV Lore • Green Hills of Stranglethorn",
    },
    ["wanted: hogger"] = {
        reward = "Redridge Machete / Footman's Boots",
        origin = "Wanted Poster",
        summary = "Wanted Poster • Hogger Bounty",
        isKeyUnlock = true,
    },
    ["wanted: chok'sul"] = {
        reward = "Chok'sul's Cleaver",
        origin = "Wanted Poster",
        summary = "Wanted Poster • Chok'sul Bounty",
        isKeyUnlock = true,
    },
    ["wanted: lieutenant valent"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Lieutenant Valent Bounty",
    },
    ["wanted: gath'ilzogg"] = {
        reward = "Blackrock Mace / Redridge Shield",
        origin = "Wanted Poster",
        summary = "Wanted Poster • Gath'Ilzogg Bounty",
        isKeyUnlock = true,
    },
    ["wanted: baron vardus"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Baron Vardus Bounty",
    },
    ["wanted: syndicate personnel"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Syndicate Personnel Bounty",
    },
    ["wanted: caliph scorpidsting"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Caliph Scorpidsting",
    },
    ["wanted: andre firebeard"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Andre Firebeard",
    },
    ["wanted: murkdeep"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Murkdeep Bounty",
    },
    ["wanted: vile priestess hexx"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Vile Priestess Hexx",
    },
    ["wanted: besseleth"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Besseleth Bounty",
    },
    ["wanted: maggot eye"] = {
        origin = "Wanted Poster",
        summary = "Wanted Poster • Maggot Eye Bounty",
    },
    ["the night watch"] = {
        chain = "The Night Watch",
        note = "Alliance iconic Duskwood undead defense chain.",
        summary = "The Night Watch Chain (Step 1/3)",
    },
    ["the valor family"] = {
        chain = "The Story of Morgan Ladimore",
        note = "Leads to Mor'ladim & Archeus (Rare 2H Sword).",
        summary = "Leads to: Mor'ladim & Archeus (Rare Sword)",
    },
    ["the hermit"] = {
        chain = "The Hermit & Eliza",
        note = "Abercrombie in Raven Hill. Leads to Eliza's Tomb.",
        summary = "The Hermit & Eliza Chain",
    },
    ["the totem of infliction"] = {
        note = "Althea Ebonlocke's research into the Darkshire undead curse.",
        summary = "Duskwood Undead Defense",
    },
    ["look to the stars"] = {
        chain = "Look to the Stars",
        note = "Requires Bronze Tube from Engineering.",
        summary = "Look to the Stars Chain",
    },
    ["seasoned wolf kabobs"] = {
        reward = "Recipe: Seasoned Wolf Kabobs",
        note = "Farmed from Duskwood wolves (Starving/Rabid Dire Wolf) or bought on AH (tradeable meat).",
        summary = "Cooking Recipe Quest",
    },
    ["crime and punishment"] = {
        unlock = "Dungeon: The Stockade",
        summary = "Dungeon: The Stockade",
        isKeyUnlock = true,
    },
    ["shadow magic"] = {
        reward = "Midnight Orb",
        summary = "Redridge Elite Quest",
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

-- META QUESTS DATA & RESOLVER (Classic + WoW Forever)
Data.META_TAG_PRIORITY = { KEY = 1, MOUNT = 2, BAG = 3, EPIC = 4, CLASS = 5, BIS = 6 }

-- Auto-generated Classic + WoW Forever Meta Quests Catalog (Wowhead verified)
-- Format: [questID] = { tag, reason, zone, level, side, perm, reqClass, title }
Data.MetaQuests = {
    [31] = { "CLASS", "Class Spell / Ability Unlock", nil, 16, "H", true, "DRUID", "Aquatic Form" },
    [58] = { "BAG", "Bag Reward: Gunnysack of the Night Watch", "Duskwood", 30, "A", true, nil, "The Night Watch" },
    [96] = { "CLASS", "Class Spell / Ability Unlock", nil, 23, "H", true, "SHAMAN", "Call of Water" },
    [166] = { "BIS", "Rare Weapon / Shield: Staff of Westfall", "The Deadmines", 22, "A", false, nil, "The Defias Brotherhood" },
    [378] = { "BIS", "Rare Weapon / Shield: Headbasher", "The Stockade", 27, "A", false, nil, "The Fury Runs Deep" },
    [396] = { "BIS", "Rare Accessory: Seal of Wrynn", "Stormwind City", 31, "A", false, nil, "An Audience with the King" },
    [470] = { "BAG", "Bag Reward: Ooze-covered Bag", "Wetlands", 19, "A", true, nil, "Digging Through the Ooze" },
    [626] = { "BAG", "Bag Reward: Explorer's Knapsack", "Stranglethorn Vale", 51, "B", true, nil, "Cortello's Riddle" },
    [778] = { "BIS", "Trinket: Nifty Stopwatch (+40% Sprint Speed)", "Badlands", 45, "B", true, nil, "This Is Going to Be Hard" },
    [909] = { "BIS", "Rare Weapon / Shield: Outlaw Sabre", "Ashenvale", 30, "B", false, nil, "Baron Aquanis" },
    [914] = { "BIS", "Rare Weapon / Shield: Crescent Staff", "Wailing Caverns", 22, "H", false, nil, "Leaders of the Fang" },
    [1014] = { "BIS", "Rare Accessory: Seal of Sylvanas", "Shadowfang Keep", 27, "H", false, nil, "Arugal Must Die" },
    [1048] = { "BIS", "Rare Accessory: Dragon's Blood Necklace", "Scarlet Monastery", 42, "H", false, nil, "Into The Scarlet Monastery" },
    [1049] = { "BIS", "Rare Weapon / Shield: Vile Protector", "Scarlet Monastery", 38, "H", false, nil, "Compendium of the Fallen" },
    [1050] = { "BIS", "Rare Accessory: Explorers' League Commendation", "Scarlet Monastery", 38, "A", false, nil, "Mythology of the Titans" },
    [1053] = { "BIS", "Rare Weapon / Shield: Sword of Serenity", "Scarlet Monastery", 40, "A", true, nil, "In the Name of the Light" },
    [1101] = { "BIS", "Rare Weapon / Shield: Quilboar Blaster", "Razorfen Kraul", 34, "A", false, nil, "The Crone of the Kraul" },
    [1102] = { "BIS", "Rare Weapon / Shield: Quilboar Blaster", "Razorfen Kraul", 34, "H", false, nil, "A Vengeful Fate" },
    [1200] = { "BIS", "Rare Weapon / Shield: Gravestone Scepter", "Blackfathom Deeps", 27, "A", false, nil, "Blackfathom Villainy" },
    [1318] = { "BIS", "Rare Gear Reward: Gordok's Handguards", "Dire Maul", 60, "B", false, nil, "Unfinished Gordok Business" },
    [1383] = { "BIS", "Rare Accessory: Cloak of Blight", "Duskwood", 42, "H", false, nil, "Nothing But The Truth" },
    [1446] = { "BIS", "Rare Gear Reward: Rainstrider Leggings", "Sunken Temple", 53, "B", false, nil, "Jammal'an the Prophet" },
    [1471] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "WARLOCK", "The Binding" },
    [1474] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "WARLOCK", "The Binding" },
    [1486] = { "BAG", "Bag Reward: Deviate Hide Pack", "Wailing Caverns", 17, "B", true, nil, "Deviate Hides" },
    [1498] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "WARRIOR", "Path of Defense" },
    [1504] = { "CLASS", "Class Spell / Ability Unlock", nil, 11, "H", true, "WARLOCK", "The Binding" },
    [1513] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "WARLOCK", "The Binding" },
    [1527] = { "CLASS", "Class Spell / Ability Unlock", nil, 13, "H", true, "SHAMAN", "Call of Fire" },
    [1652] = { "CLASS", "Class Spell / Ability Unlock", nil, 25, "A", true, "PALADIN", "The Tome of Valor" },
    [1661] = { "CLASS", "Class Spell / Ability Unlock", nil, 40, "A", true, "PALADIN", "The Tome of Nobility" },
    [1665] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "WARRIOR", "Bartleby's Mug" },
    [1678] = { "CLASS", "Class Spell / Ability Unlock", nil, 11, "A", true, "WARRIOR", "Vejrek" },
    [1683] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "WARRIOR", "Vorlus Vilehoof" },
    [1689] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "WARLOCK", "The Binding" },
    [1719] = { "CLASS", "Class Spell / Ability Unlock", nil, 30, "B", true, "WARRIOR", "The Affray" },
    [1739] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "WARLOCK", "The Binding" },
    [1740] = { "BIS", "Rare Weapon / Shield: Orb of Soran'ruk", nil, 25, "B", false, "WARLOCK", "The Orb of Soran'ruk" },
    [1785] = { "CLASS", "Class Spell / Ability Unlock", nil, 13, "A", true, "PALADIN", "The Tome of Divinity" },
    [1788] = { "CLASS", "Class Spell / Ability Unlock", nil, 13, "A", true, "PALADIN", "The Tome of Divinity" },
    [1792] = { "BIS", "Rare Weapon / Shield: Whirlwind Axe", "Hillsbrad Foothills", 40, "B", true, "WARRIOR", "Whirlwind Weapon" },
    [1795] = { "BAG", "Bag Reward: Box of Souls", nil, 30, "B", true, "WARLOCK", "The Binding" },
    [1819] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "WARRIOR", "Ulag the Cleaver" },
    [1952] = { "BIS", "Rare Weapon / Shield: Icefury Wand", nil, 40, "B", false, "MAGE", "Mage's Wand" },
    [1958] = { "BIS", "Rare Weapon / Shield: Celestial Orb", nil, 40, "B", false, "MAGE", "Celestial Power" },
    [2204] = { "BIS", "Dungeon Chain: Talvash's Enhancing Necklace", "Uldaman", 44, "A", false, nil, "Solution to Doom" },
    [2341] = { "BIS", "Rare Accessory: Jarkal's Enhancing Necklace", "Uldaman", 44, "H", false, nil, "Necklace Recovery, Take 3" },
    [2359] = { "CLASS", "Class Spell / Ability Unlock", nil, 24, "A", true, "ROGUE", "Klaven's Tower" },
    [2361] = { "BIS", "Rare Accessory: Talvash's Enhancing Necklace", "Uldaman", 44, "A", false, nil, "Restoring the Necklace" },
    [2439] = { "BAG", "Bag Reward: Thawpelt Sack", "Ironforge", 47, "A", true, nil, "The Platinum Discs" },
    [2480] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "ROGUE", "Hinott's Assistance" },
    [2768] = { "BIS", "Rare Accessory: Masons Fraternity Ring", "Zul'Farrak", 47, "B", false, nil, "Divino-matic Rod" },
    [2770] = { "BIS", "Rare Trinket: Carrot on a Stick (+3% Mount Speed)", "Zul'Farrak", 50, "B", true, nil, "Gahz'rilla" },
    [2841] = { "BIS", "Rare Gear Reward: Civinad Robes", "Gnomeregan", 35, "H", false, nil, "Rig Wars" },
    [2929] = { "BIS", "Rare Gear Reward: Civinad Robes", "Gnomeregan", 35, "A", false, nil, "The Grand Betrayal" },
    [2948] = { "BIS", "Rare Accessory: Talvash's Gold Ring", "Ironforge", 28, "A", false, nil, "Gnome Improvement" },
    [2950] = { "BIS", "Rare Accessory: Nogg's Gold Ring", "Orgrimmar", 35, "H", false, nil, "Nogg's Ring Redo" },
    [3201] = { "KEY", "Key / Attunement: Key to Searing Gorge", "Ironforge", 48, "A", true, nil, "At Last!" },
    [3341] = { "BIS", "Rare Accessory: Amberglow Talisman", "Razorfen Downs", 42, "H", false, nil, "Bring the End" },
    [3525] = { "BIS", "Rare Accessory: Dragonclaw Ring", "Razorfen Downs", 37, "B", false, nil, "Extinguishing the Idol" },
    [3528] = { "BIS", "Rare Weapon / Shield: Lifeforce Dirk", "Sunken Temple", 53, "B", false, nil, "The God Hakkar" },
    [3636] = { "BIS", "Rare Accessory: Amberglow Talisman", "Razorfen Downs", 42, "A", false, nil, "Bring the Light" },
    [3802] = { "KEY", "Key / Attunement: Shadowforge Key", "Blackrock Depths", 52, "B", true, nil, "Dark Iron Legacy" },
    [3962] = { "BIS", "Rare Weapon / Shield: Linken's Sword of Mastery", "Un'Goro Crater", 56, "B", false, nil, "It's Dangerous to Go Alone" },
    [4004] = { "BIS", "Rare Accessory: Thrall's Resolve", "Blackrock Depths", 60, "H", false, nil, "The Princess Saved?" },
    [4132] = { "BIS", "Rare Accessory: Conqueror's Medallion", "Blackrock Depths", 58, "H", false, nil, "Operation: Death to Angerforge" },
    [4201] = { "BIS", "Rare Gear Reward: Manacle Cuffs", "Blackrock Depths", 54, "B", false, nil, "The Love Potion" },
    [4242] = { "BIS", "Rare Gear Reward: Conservator Helm", "Blackrock Depths", 54, "A", false, nil, "Abandoned Hope" },
    [4264] = { "KEY", "Attunement: Onyxia's Lair (Jail Break!)", "Blackrock Depths", 58, "A", true, nil, "A Crumpled Up Note" },
    [4322] = { "KEY", "Attunement: Onyxia's Lair (The Great Masquerade)", "Stormwind City", 60, "A", true, nil, "Jail Break!" },
    [4363] = { "BIS", "Rare Accessory: Magni's Will", "Blackrock Depths", 59, "A", false, nil, "The Princess's Surprise" },
    [4490] = { "CLASS", "Class Spell / Ability Unlock", nil, 40, "B", true, "WARLOCK", "Summon Felsteed" },
    [4621] = { "BIS", "Rare Gear Reward: Bloodsail Admiral's Hat", "Stranglethorn Vale", 60, "B", false, nil, "Avast Ye, Admiral!" },
    [4742] = { "KEY", "Key / Unlock: Forging Seal of Ascension (UBRS Key)", "Lower Blackrock Spire", 60, "B", true, nil, "Seal of Ascension" },
    [4743] = { "KEY", "Key / Attunement: Seal of Ascension (UBRS Key)", "Upper Blackrock Spire", 60, "B", true, nil, "Seal of Ascension" },
    [4771] = { "BIS", "Rare Weapon / Shield: Windreaper", "Scholomance", 60, "B", false, nil, "Dawn's Gambit" },
    [4786] = { "BIS", "Rare Gear Reward: Enchanted Gold Bloodrobe", nil, 38, "B", false, "WARLOCK", "The Completed Robe" },
    [4866] = { "BIS", "Rare Accessory: Ragged John's Neverending Cup", "Lower Blackrock Spire", 60, "B", false, nil, "Mother's Milk" },
    [4903] = { "BIS", "Rare Gear Reward: Wyrmthalak's Shackles", "Lower Blackrock Spire", 60, "H", false, nil, "Warlord's Command" },
    [4964] = { "BIS", "Rare Weapon / Shield: Orb of Dar'Orahil", nil, 40, "B", false, "WARLOCK", "The Completed Orb of Dar'Orahil" },
    [4974] = { "BIS", "BiS UBRS Trinket: Blackhand's Breadth / Mark of Tyranny", "Upper Blackrock Spire", 60, "H", true, nil, "For The Horde!" },
    [4975] = { "BIS", "Rare Weapon / Shield: Orb of Noh'Orahil", nil, 40, "B", false, "WARLOCK", "The Completed Orb of Noh'Orahil" },
    [5061] = { "CLASS", "Class Spell / Ability Unlock", nil, 16, "A", true, "DRUID", "Aquatic Form" },
    [5063] = { "EPIC", "Epic Reward: Cap of the Scarlet Savant", "Winterspring", 60, "B", true, nil, "Cap of the Scarlet Savant" },
    [5081] = { "BIS", "Rare Gear Reward: Wyrmthalak's Shackles", "Lower Blackrock Spire", 60, "A", false, nil, "Maxwell's Mission" },
    [5102] = { "BIS", "BiS UBRS Trinket: Blackhand's Breadth / Eye of the Beast", "Upper Blackrock Spire", 60, "A", true, nil, "General Drakkisath's Demise" },
    [5124] = { "BIS", "Rare Gear Reward: Plans: Fiery Plate Gauntlets", "Winterspring", 60, "B", false, nil, "Fiery Plate Gauntlets" },
    [5125] = { "BIS", "Rare Accessory: Will of the Martyr", "Stratholme", 60, "B", false, nil, "Aurius' Reckoning" },
    [5127] = { "BIS", "Rare Gear Reward: Plans: Demon Forged Breastplate", "Lower Blackrock Spire", 60, "B", false, nil, "The Demon Forge" },
    [5166] = { "EPIC", "Epic Reward: Breastplate of the Chromatic Flight", "Western Plaguelands", 60, "B", true, nil, "Breastplate of the Chromatic Flight" },
    [5167] = { "EPIC", "Epic Reward: Legguards of the Chromatic Defier", "Western Plaguelands", 60, "B", true, nil, "Legplates of the Chromatic Defier" },
    [5213] = { "BIS", "Rare Accessory: Seal of the Dawn", "Stratholme", 60, "B", false, nil, "The Active Agent" },
    [5265] = { "BIS", "Rare Weapon / Shield: Argent Avenger", "Eastern Plaguelands", 60, "B", false, nil, "The Argent Hold" },
    [5306] = { "BIS", "Rare Gear Reward: Plans: Dawn's Edge", "Lower Blackrock Spire", 60, "B", false, nil, "Snakestone of the Shadow Huntress" },
    [5342] = { "BIS", "Rare Accessory: Barov Peasant Caller", "Western Plaguelands", 60, "H", false, nil, "The Last Barov" },
    [5344] = { "BIS", "Rare Accessory: Barov Peasant Caller", "Western Plaguelands", 60, "A", false, nil, "The Last Barov" },
    [5384] = { "BIS", "Rare Weapon / Shield: Penelope's Rose", "Scholomance", 60, "B", false, nil, "Kirtonos the Herald" },
    [5466] = { "BIS", "Rare Weapon / Shield: Darrowshire Strongguard", "Scholomance", 60, "B", false, nil, "The Lich, Ras Frostwhisper" },
    [5505] = { "KEY", "Key / Attunement: Skeleton Key", "Western Plaguelands", 60, "A", true, nil, "The Key to Scholomance" },
    [5511] = { "KEY", "Key / Attunement: Skeleton Key", "Western Plaguelands", 60, "H", true, nil, "The Key to Scholomance" },
    [5526] = { "BIS", "Rare Weapon / Shield: Milli's Shield", "Moonglade", 60, "B", false, nil, "Shards of the Felvine" },
    [5627] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Stars of Elune" },
    [5628] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Returning Home" },
    [5629] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Returning Home" },
    [5630] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Returning Home" },
    [5631] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Returning Home" },
    [5632] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Returning Home" },
    [5633] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Returning Home" },
    [5634] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Desperate Prayer" },
    [5635] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Desperate Prayer" },
    [5636] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Desperate Prayer" },
    [5637] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Desperate Prayer" },
    [5638] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Desperate Prayer" },
    [5639] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Desperate Prayer" },
    [5640] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Desperate Prayer" },
    [5641] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "A Lack of Fear" },
    [5642] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "PRIEST", "Shadowguard" },
    [5643] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "PRIEST", "Shadowguard" },
    [5644] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "PRIEST", "Devouring Plague" },
    [5645] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "A Lack of Fear" },
    [5646] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "PRIEST", "Devouring Plague" },
    [5647] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "A Lack of Fear" },
    [5652] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Hex of Weakness" },
    [5654] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Hex of Weakness" },
    [5655] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Hex of Weakness" },
    [5656] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Hex of Weakness" },
    [5657] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Hex of Weakness" },
    [5658] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Touch of Weakness" },
    [5660] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Touch of Weakness" },
    [5661] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Touch of Weakness" },
    [5662] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Touch of Weakness" },
    [5663] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "PRIEST", "Touch of Weakness" },
    [5672] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Elune's Grace" },
    [5673] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Elune's Grace" },
    [5674] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Elune's Grace" },
    [5675] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Elune's Grace" },
    [5676] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Arcane Feedback" },
    [5677] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Arcane Feedback" },
    [5678] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Arcane Feedback" },
    [5679] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "PRIEST", "Devouring Plague" },
    [5680] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "PRIEST", "Shadowguard" },
    [5730] = { "BIS", "Rare Weapon / Shield: Kris of Orgrimmar", "Orgrimmar", 16, "H", false, nil, "Hidden Enemies" },
    [5942] = { "BIS", "Rare Accessory: Ring of Protection", "Eastern Plaguelands", 60, "B", false, nil, "Hidden Treasures" },
    [5944] = { "BIS", "Rare Accessory: Mark of Fordring", "Western Plaguelands", 60, "B", true, nil, "In Dreams" },
    [6001] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "DRUID", "Body and Heart" },
    [6002] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "DRUID", "Body and Heart" },
    [6081] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "HUNTER", "Training the Beast" },
    [6082] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "HUNTER", "Taming the Beast" },
    [6085] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "HUNTER", "Taming the Beast" },
    [6086] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "HUNTER", "Training the Beast" },
    [6088] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "HUNTER", "Taming the Beast" },
    [6089] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "HUNTER", "Training the Beast" },
    [6102] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "HUNTER", "Taming the Beast" },
    [6103] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "HUNTER", "Training the Beast" },
    [6125] = { "CLASS", "Class Spell / Ability Unlock", nil, 14, "A", true, "DRUID", "Power over Poison" },
    [6130] = { "CLASS", "Class Spell / Ability Unlock", nil, 14, "H", true, "DRUID", "Power over Poison" },
    [6148] = { "BIS", "Rare Weapon / Shield: Gorewood Bow", "Eastern Plaguelands", 60, "H", false, nil, "The Scarlet Oracle, Demetria" },
    [6163] = { "BIS", "Rare Accessory: Royal Seal of Alexis", "Stratholme", 60, "H", true, nil, "Ramstein" },
    [6187] = { "BIS", "Rare Weapon / Shield: Gorewood Bow", "Eastern Plaguelands", 60, "A", false, nil, "Order Must Be Restored" },
    [6502] = { "KEY", "Key / Attunement: Drakefire Amulet (Onyxia's Lair)", "Upper Blackrock Spire", 60, "A", true, nil, "Drakefire Amulet" },
    [6561] = { "BIS", "Rare Weapon / Shield: Gravestone Scepter", "Blackfathom Deeps", 27, "H", false, nil, "Blackfathom Villainy" },
    [6602] = { "KEY", "Key / Attunement: Drakefire Amulet (Onyxia's Lair)", "Upper Blackrock Spire", 60, "H", true, nil, "Blood of the Black Dragon Champion" },
    [6861] = { "BIS", "Rare Gear Reward: Zinfizzlex's Portable Shredder Unit", "Alterac Valley", 60, "B", false, nil, "Zinfizzlex's Portable Shredder Unit" },
    [6922] = { "BIS", "Rare Weapon / Shield: Outlaw Sabre", "Ashenvale", 30, "H", false, nil, "Baron Aquanis" },
    [6981] = { "BIS", "Secret Dungeon Quest: Leads to Talbar Mantle", "Wailing Caverns", 26, "B", false, nil, "The Glowing Shard" },
    [7044] = { "KEY", "Key / Attunement: Scepter of Celebras (Maraudon Portal)", "Maraudon", 49, "B", true, nil, "Legends of Maraudon" },
    [7046] = { "BIS", "Rare Gear Reward: Scepter of Celebras", "Maraudon", 49, "B", false, nil, "The Scepter of Celebras" },
    [7064] = { "BIS", "Rare Weapon / Shield: Thrash Blade", "Maraudon", 51, "H", true, nil, "Corruption of Earth and Seed" },
    [7065] = { "BIS", "Rare Weapon / Shield: Thrash Blade", "Maraudon", 51, "A", true, nil, "Corruption of Earth and Seed" },
    [7165] = { "BIS", "Rare Accessory: Frostwolf Insignia Rank 4", "Alterac Valley", 51, "H", false, nil, "Earned Reverence" },
    [7166] = { "BIS", "Rare Accessory: Frostwolf Insignia Rank 5", "Alterac Valley", 51, "H", false, nil, "Legendary Heroes" },
    [7167] = { "EPIC", "Epic Reward: Frostwolf Insignia Rank 6", "Alterac Valley", 51, "H", true, nil, "The Eye of Command" },
    [7170] = { "BIS", "Rare Accessory: Stormpike Insignia Rank 4", "Alterac Valley", 51, "A", false, nil, "Earned Reverence" },
    [7171] = { "BIS", "Rare Accessory: Stormpike Insignia Rank 5", "Alterac Valley", 51, "A", false, nil, "Legendary Heroes" },
    [7172] = { "EPIC", "Epic Reward: Stormpike Insignia Rank 6", "Alterac Valley", 51, "A", true, nil, "The Eye of Command" },
    [7181] = { "BIS", "Rare Weapon / Shield: Bloodseeker", "Alterac Valley", 60, "B", true, nil, "The Legend of Korrak" },
    [7202] = { "BIS", "Rare Weapon / Shield: Bloodseeker", "Alterac Valley", 60, "B", true, nil, "Korrak the Bloodrager" },
    [7441] = { "BIS", "Dire Maul: East • Spry Boots / Sprinter's Sword (+Crescent Key drop)", "Dire Maul", 58, "B", false, nil, "Pusillin and the Elder Azj'Tordin" },
    [7462] = { "BIS", "Rare Weapon / Shield: Bonecrusher", "Dire Maul", 60, "B", false, nil, "The Treasure of the Shen'dralar" },
    [7463] = { "CLASS", "Class Spell: Conjure Water (Rank 7)", "Dire Maul", 60, "B", true, "MAGE", "Arcane Refreshment" },
    [7486] = { "BIS", "Rare Accessory: Ocean's Breeze", "Azshara", 55, "B", false, nil, "A Hero's Reward" },
    [7487] = { "KEY", "Attunement: Molten Core Raid (Lothos Riftwaker)", "Blackrock Depths", 60, "B", true, nil, "Attunement to the Core" },
    [7488] = { "BIS", "Rare Weapon / Shield: Lorespinner", "Dire Maul", 57, "A", false, nil, "Lethtendris's Web" },
    [7489] = { "BIS", "Rare Weapon / Shield: Lorespinner", "Dire Maul", 57, "H", false, nil, "Lethtendris's Web" },
    [7491] = { "EPIC", "Epic Reward: Onyxia Blood Talisman", "Orgrimmar", 60, "H", true, nil, "For All To See" },
    [7496] = { "EPIC", "Epic Reward: Onyxia Blood Talisman", "Stormwind City", 60, "A", true, nil, "Celebrating Good Times" },
    [7498] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "B", true, "ROGUE", "Garona: A Study on Stealth and Treachery" },
    [7499] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "B", true, "WARRIOR", "Codex of Defense" },
    [7500] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "B", true, "MAGE", "The Arcanist's Cookbook" },
    [7501] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "A", true, "PALADIN", "The Light and How To Swing It" },
    [7502] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "B", true, "WARLOCK", "Harnessing Shadows" },
    [7503] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "B", true, "HUNTER", "The Greatest Race of Hunters" },
    [7504] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "B", true, "PRIEST", "Holy Bologna: What the Light Won't Tell You" },
    [7505] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "H", true, "SHAMAN", "Frost Shock and You" },
    [7506] = { "BIS", "Rare Accessory: Royal Seal of Eldre'Thalas", "Dire Maul", 60, "B", true, "DRUID", "The Emerald Dream..." },
    [7508] = { "EPIC", "Epic Reward: A Dull and Flat Elven Blade", "Dire Maul", 60, "B", true, nil, "The Forging of Quel'Serrar" },
    [7509] = { "EPIC", "Epic Reward: Quel'Serrar", "Onyxia's Lair", 60, "B", true, nil, "The Forging of Quel'Serrar" },
    [7541] = { "BIS", "Rare Accessory: Lonetree's Circle", "Orgrimmar", 30, "H", false, nil, "Service to the Horde" },
    [7583] = { "CLASS", "Class Milestone (Tome of Sacrifice)", nil, 60, "B", true, "WARLOCK", "Suppression" },
    [7603] = { "CLASS", "Class Milestone (Shard of the Green Flame)", nil, 55, "B", true, "WARLOCK", "Kroshius' Infernal Core" },
    [7604] = { "EPIC", "Epic Reward: Plans: Sulfuron Hammer", "Blackrock Depths", 60, "B", true, nil, "A Binding Contract" },
    [7622] = { "EPIC", "Epic Reward: Splinter of Nordrassil", nil, 60, "B", true, "PRIEST", "The Balance of Light and Shadow" },
    [7631] = { "CLASS", "Class Spell / Ability Unlock", nil, 60, "B", true, "WARLOCK", "Dreadsteed of Xoroth" },
    [7634] = { "EPIC", "Epic Reward: Ancient Sinew Wrapped Lamina", nil, 60, "B", true, "HUNTER", "Ancient Sinew Wrapped Lamina" },
    [7635] = { "EPIC", "Epic Reward: Enchanted Black Dragon Sinew", nil, 60, "B", true, "HUNTER", "A Proper String" },
    [7636] = { "EPIC", "Epic Reward: Ancient Rune Etched Stave", nil, 60, "B", true, "HUNTER", "Stave of the Ancients" },
    [7647] = { "CLASS", "Class Spell / Ability Unlock", nil, 60, "A", true, "PALADIN", "Judgment and Redemption" },
    [7649] = { "BIS", "Rare Gear Reward: Plans: Enchanted Thorium Breastplate", "Dire Maul", 60, "B", false, nil, "Enchanted Thorium Platemail: Volume I" },
    [7650] = { "BIS", "Rare Gear Reward: Plans: Enchanted Thorium Leggings", "Dire Maul", 60, "B", false, nil, "Enchanted Thorium Platemail: Volume II" },
    [7651] = { "BIS", "Rare Gear Reward: Plans: Enchanted Thorium Helm", "Dire Maul", 60, "B", false, nil, "Enchanted Thorium Platemail: Volume III" },
    [7668] = { "BIS", "Rare Gear Reward: Helm of Latent Power", nil, 60, "H", false, "SHAMAN", "The Darkreaver Menace" },
    [7703] = { "BIS", "Rare Gear Reward: Gordok's Handguards", "Dire Maul", 60, "B", false, nil, "Unfinished Gordok Business" },
    [7761] = { "KEY", "Attunement: Blackwing Lair Raid (Orb of Command)", "Upper Blackrock Spire", 60, "B", true, nil, "Blackhand's Command" },
    [7782] = { "EPIC", "Epic Reward: Master Dragonslayer's Medallion", "Stormwind City", 60, "A", true, nil, "The Lord of Blackrock" },
    [7784] = { "EPIC", "Epic Reward: Master Dragonslayer's Medallion", "Orgrimmar", 60, "H", true, nil, "The Lord of Blackrock" },
    [7785] = { "EPIC", "Epic Reward: Vessel of Rebirth", "Silithus", 60, "B", true, nil, "Examine the Vessel" },
    [7787] = { "EPIC", "Epic Reward: Thunderfury, Blessed Blade of the Windseeker", "Silithus", 60, "B", true, nil, "Rise, Thunderfury!" },
    [7848] = { "KEY", "Attunement: Molten Core Raid (Lothos Riftwaker)", "Blackrock Depths", 60, "B", true, nil, "Attunement to the Core" },
    [7861] = { "BIS", "Rare Accessory: Woven Ivy Necklace", "The Hinterlands", 51, "H", false, nil, "Wanted: Vile Priestess Hexx and Her Minions" },
    [7862] = { "BIS", "BiS Melee Trinket: Rune of the Guard Captain (+20 AP, +1% Hit)", "The Hinterlands", 51, "H", true, nil, "Job Opening: Guard Captain of Revantusk Village" },
    [7877] = { "BIS", "Rare Weapon / Shield: Bonecrusher", "Dire Maul", 60, "B", false, nil, "The Treasure of the Shen'dralar" },
    [8042] = { "BIS", "Rare Accessory: Strength of Mugamba", "Zul'Gurub", 60, "B", false, nil, "Strength of Mount Mugamba" },
    [8043] = { "BIS", "Rare Accessory: Strength of Mugamba", "Zul'Gurub", 60, "B", false, nil, "Strength of Mount Mugamba" },
    [8044] = { "EPIC", "Epic Reward: Rage of Mugamba", "Zul'Gurub", 60, "B", true, nil, "The Rage of Mugamba" },
    [8046] = { "BIS", "Rare Accessory: Heathen's Brand", "Zul'Gurub", 60, "A", false, nil, "The Heathen's Brand" },
    [8047] = { "BIS", "Rare Accessory: Heathen's Brand", "Zul'Gurub", 60, "A", false, nil, "The Heathen's Brand" },
    [8048] = { "EPIC", "Epic Reward: Hero's Brand", "Zul'Gurub", 60, "A", true, nil, "The Hero's Brand" },
    [8050] = { "BIS", "Rare Accessory: The Eye of Zuldazar", "Zul'Gurub", 60, "B", false, nil, "The Eye of Zuldazar" },
    [8051] = { "BIS", "Rare Accessory: The Eye of Zuldazar", "Zul'Gurub", 60, "B", false, nil, "The Eye of Zuldazar" },
    [8052] = { "EPIC", "Epic Reward: The All-Seeing Eye of Zuldazar", "Zul'Gurub", 60, "B", true, nil, "The All-Seeing Eye of Zuldazar" },
    [8102] = { "BIS", "Rare Accessory: Pebble of Kajaro", "Zul'Gurub", 60, "B", false, nil, "The Pebble of Kajaro" },
    [8103] = { "BIS", "Rare Accessory: Pebble of Kajaro", "Zul'Gurub", 60, "B", false, nil, "The Pebble of Kajaro" },
    [8104] = { "EPIC", "Epic Reward: Jewel of Kajaro", "Zul'Gurub", 60, "B", true, nil, "The Jewel of Kajaro" },
    [8107] = { "BIS", "Rare Accessory: Kezan's Taint", "Zul'Gurub", 60, "B", false, nil, "Kezan's Taint" },
    [8108] = { "BIS", "Rare Accessory: Kezan's Taint", "Zul'Gurub", 60, "B", false, nil, "Kezan's Taint" },
    [8109] = { "EPIC", "Epic Reward: Kezan's Unstoppable Taint", "Zul'Gurub", 60, "B", true, nil, "Kezan's Unstoppable Taint" },
    [8111] = { "BIS", "Rare Accessory: Enchanted South Seas Kelp", "Zul'Gurub", 60, "B", false, nil, "Enchanted South Seas Kelp" },
    [8112] = { "BIS", "Rare Accessory: Enchanted South Seas Kelp", "Zul'Gurub", 60, "B", false, nil, "Enchanted South Seas Kelp" },
    [8113] = { "EPIC", "Epic Reward: Pristine Enchanted South Seas Kelp", "Zul'Gurub", 60, "B", true, nil, "Pristine Enchanted South Seas Kelp" },
    [8117] = { "BIS", "Rare Accessory: Vision of Voodress", "Zul'Gurub", 60, "H", false, nil, "Vision of Voodress" },
    [8118] = { "BIS", "Rare Accessory: Vision of Voodress", "Zul'Gurub", 60, "H", false, nil, "Vision of Voodress" },
    [8119] = { "EPIC", "Epic Reward: Unmarred Vision of Voodress", "Zul'Gurub", 60, "H", true, nil, "The Unmarred Vision of Voodress" },
    [8142] = { "BIS", "Rare Accessory: Zandalarian Shadow Talisman", "Zul'Gurub", 60, "B", false, nil, "Zandalarian Shadow Talisman" },
    [8143] = { "BIS", "Rare Accessory: Zandalarian Shadow Talisman", "Zul'Gurub", 60, "B", false, nil, "Zandalarian Shadow Talisman" },
    [8144] = { "EPIC", "Epic Reward: Zandalarian Shadow Mastery Talisman", "Zul'Gurub", 60, "B", true, nil, "Zandalarian Shadow Mastery Talisman" },
    [8146] = { "BIS", "Rare Accessory: Maelstrom's Tendril", "Zul'Gurub", 60, "B", false, nil, "The Maelstrom's Tendril" },
    [8147] = { "BIS", "Rare Accessory: Maelstrom's Tendril", "Zul'Gurub", 60, "B", false, nil, "The Maelstrom's Tendril" },
    [8148] = { "EPIC", "Epic Reward: Maelstrom's Wrath", "Zul'Gurub", 60, "B", true, nil, "Maelstrom's Wrath" },
    [8181] = { "BIS", "Rare Accessory: Faded Hakkari Cloak", "Zul'Gurub", 58, "B", false, nil, "Confront Yeh'kinya" },
    [8183] = { "EPIC", "Epic Reward: Zandalarian Hero Charm", "Zul'Gurub", 58, "B", true, nil, "The Heart of Hakkar" },
    [8232] = { "BIS", "Rare Accessory: Devilsaur Eye", nil, 52, "B", false, "HUNTER", "The Green Drake" },
    [8236] = { "CLASS", "Class Milestone: Rogue Sunken Temple Reward", "Sunken Temple", 52, "B", true, "ROGUE", "The Azure Key" },
    [8253] = { "BIS", "Rare Accessory: Arcane Crystal Pendant", nil, 52, "B", false, "MAGE", "Destroy Morphaz" },
    [8257] = { "BIS", "Rare Accessory: Blessed Prayer Beads", nil, 52, "B", false, "PRIEST", "Blood of Morphaz" },
    [8258] = { "EPIC", "Epic Reward: Skyfury Helm", nil, 60, "H", true, "SHAMAN", "The Darkreaver Menace" },
    [8259] = { "EPIC", "Epic Reward: Skyfury Helm", nil, 60, "H", true, "SHAMAN", "A More Fitting Reward" },
    [8271] = { "BIS", "Rare Weapon / Shield: Bloodseeker", "Alterac Valley", 60, "A", true, nil, "Hero of the Stormpike" },
    [8272] = { "BIS", "Rare Weapon / Shield: Bloodseeker", "Alterac Valley", 60, "H", true, nil, "Hero of the Frostwolf" },
    [8413] = { "BIS", "Rare Accessory: Enamored Water Spirit", nil, 52, "H", false, "SHAMAN", "Da Voodoo" },
    [8418] = { "BIS", "Rare Accessory: Sanctified Orb", nil, 52, "A", false, "PALADIN", "Forging the Mightstone" },
    [8422] = { "BIS", "Rare Accessory: Abyss Shard", nil, 52, "B", false, "WARLOCK", "Trolls of a Feather" },
    [8425] = { "BIS", "Rare Accessory: Diamond Flask", nil, 52, "B", false, "WARRIOR", "Voodoo Feathers" },
    [8446] = { "EPIC", "Epic Reward: Nightmare Engulfed Object", "Moonglade", 60, "B", true, nil, "Shrouded in Nightmare" },
    [8447] = { "EPIC", "Epic Reward: Malfurion's Signet Ring", "Moonglade", 60, "B", true, nil, "Waking Legends" },
    [8481] = { "EPIC", "Epic Reward: Defender of the Timbermaw", "Blackmaw Hold", 60, "B", true, nil, "The Root of All Evil" },
    [8557] = { "EPIC", "Epic Reward: Drape of Unyielding Strength", "Ahn'Qiraj", 60, "B", true, nil, "Drape of Unyielding Strength" },
    [8558] = { "EPIC", "Epic Reward: Sickle of Unyielding Strength", "Ahn'Qiraj", 60, "B", true, nil, "Sickle of Unyielding Strength" },
    [8586] = { "EPIC", "Epic Reward: Recipe: Dirge's Kickin' Chimaerok Chops", "Tanaris", 1, "B", true, nil, "Dirge's Kickin' Chimaerok Chops" },
    [8620] = { "EPIC", "Epic Reward: Gnomish Turban of Psychic Might", "Tanaris", 60, "B", true, nil, "The Only Prescription" },
    [8689] = { "EPIC", "Epic Reward: Shroud of Infinite Wisdom", "Ahn'Qiraj", 60, "B", true, nil, "Shroud of Infinite Wisdom" },
    [8690] = { "EPIC", "Epic Reward: Cloak of the Gathering Storm", "Ahn'Qiraj", 60, "H", true, nil, "Cloak of the Gathering Storm" },
    [8691] = { "EPIC", "Epic Reward: Drape of Vaulted Secrets", "Ahn'Qiraj", 60, "B", true, nil, "Drape of Vaulted Secrets" },
    [8692] = { "EPIC", "Epic Reward: Cloak of Unending Life", "Ahn'Qiraj", 60, "B", true, nil, "Cloak of Unending Life" },
    [8693] = { "EPIC", "Epic Reward: Cloak of Veiled Shadows", "Ahn'Qiraj", 60, "B", true, nil, "Cloak of Veiled Shadows" },
    [8694] = { "EPIC", "Epic Reward: Shroud of Unspoken Names", "Ahn'Qiraj", 60, "B", true, nil, "Shroud of Unspoken Names" },
    [8695] = { "EPIC", "Epic Reward: Cape of Eternal Justice", "Ahn'Qiraj", 60, "A", true, nil, "Cape of Eternal Justice" },
    [8696] = { "EPIC", "Epic Reward: Cloak of the Unseen Path", "Ahn'Qiraj", 60, "B", true, nil, "Cloak of the Unseen Path" },
    [8697] = { "EPIC", "Epic Reward: Ring of Infinite Wisdom", "Ahn'Qiraj", 60, "B", true, nil, "Ring of Infinite Wisdom" },
    [8698] = { "EPIC", "Epic Reward: Ring of the Gathering Storm", "Ahn'Qiraj", 60, "H", true, nil, "Ring of the Gathering Storm" },
    [8699] = { "EPIC", "Epic Reward: Band of Vaulted Secrets", "Ahn'Qiraj", 60, "B", true, nil, "Band of Vaulted Secrets" },
    [8700] = { "EPIC", "Epic Reward: Band of Unending Life", "Ahn'Qiraj", 60, "B", true, nil, "Band of Unending Life" },
    [8701] = { "EPIC", "Epic Reward: Band of Veiled Shadows", "Ahn'Qiraj", 60, "B", true, nil, "Band of Veiled Shadows" },
    [8702] = { "EPIC", "Epic Reward: Ring of Unspoken Names", "Ahn'Qiraj", 60, "B", true, nil, "Ring of Unspoken Names" },
    [8703] = { "EPIC", "Epic Reward: Ring of Eternal Justice", "Ahn'Qiraj", 60, "A", true, nil, "Ring of Eternal Justice" },
    [8705] = { "EPIC", "Epic Reward: Gavel of Infinite Wisdom", "Ahn'Qiraj", 60, "B", true, nil, "Gavel of Infinite Wisdom" },
    [8706] = { "EPIC", "Epic Reward: Hammer of the Gathering Storm", "Ahn'Qiraj", 60, "H", true, nil, "Hammer of the Gathering Storm" },
    [8707] = { "EPIC", "Epic Reward: Blade of Vaulted Secrets", "Ahn'Qiraj", 60, "B", true, nil, "Blade of Vaulted Secrets" },
    [8708] = { "EPIC", "Epic Reward: Mace of Unending Life", "Ahn'Qiraj", 60, "B", true, nil, "Mace of Unending Life" },
    [8709] = { "EPIC", "Epic Reward: Dagger of Veiled Shadows", "Ahn'Qiraj", 60, "B", true, nil, "Dagger of Veiled Shadows" },
    [8710] = { "EPIC", "Epic Reward: Kris of Unspoken Names", "Ahn'Qiraj", 60, "B", true, nil, "Kris of Unspoken Names" },
    [8711] = { "EPIC", "Epic Reward: Blade of Eternal Justice", "Ahn'Qiraj", 60, "A", true, nil, "Blade of Eternal Justice" },
    [8712] = { "EPIC", "Epic Reward: Scythe of the Unseen Path", "Ahn'Qiraj", 60, "B", true, nil, "Scythe of the Unseen Path" },
    [8729] = { "EPIC", "Epic Reward: Band of Icy Depths", "Azshara", 60, "B", true, nil, "The Wrath of Neptulon" },
    [8730] = { "EPIC", "Epic Reward: Onyx Embedded Leggings", "Blackwing Lair", 60, "B", true, nil, "Nefarius's Corruption" },
    [8736] = { "EPIC", "Epic Reward: Drake Tooth Necklace", "Moonglade", 60, "B", true, nil, "The Nightmare Manifests" },
    [8741] = { "EPIC", "Epic Reward: Green Scepter Shard", "Moonglade", 60, "B", true, nil, "The Champion Returns" },
    [8743] = { "MOUNT", "Mount: Black Qiraji Resonating Crystal", "Silithus", 60, "B", true, nil, "Bang a Gong!" },
    [8745] = { "EPIC", "Epic Reward: Fang of Korialstrasz", "Ahn'Qiraj", 60, "B", true, nil, "Treasure of the Timeless One" },
    [8747] = { "EPIC", "Epic Reward: Signet Ring of the Bronze Dragonflight", "Ahn'Qiraj", 60, "B", true, nil, "The Path of the Protector" },
    [8752] = { "EPIC", "Epic Reward: Signet Ring of the Bronze Dragonflight", "Ahn'Qiraj", 60, "B", true, nil, "The Path of the Conqueror" },
    [8757] = { "EPIC", "Epic Reward: Signet Ring of the Bronze Dragonflight", "Ahn'Qiraj", 60, "B", true, nil, "The Path of the Invoker" },
    [8791] = { "EPIC", "Epic Reward: Charm of the Shifting Sands", "Ruins of Ahn'Qiraj", 60, "B", true, nil, "The Fall of Ossirian" },
    [8802] = { "EPIC", "Epic Reward: Amulet of the Fallen God", "Ahn'Qiraj", 60, "B", true, nil, "The Savior of Kalimdor" },
    [8905] = { "BIS", "Rare Gear Reward: Feralheart Bracers", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [8906] = { "BIS", "Rare Gear Reward: Beastmaster's Bindings", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [8907] = { "BIS", "Rare Gear Reward: Sorcerer's Bindings", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [8908] = { "BIS", "Rare Gear Reward: Soulforge Bracers", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [8909] = { "BIS", "Rare Gear Reward: Virtuous Bracers", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [8910] = { "BIS", "Rare Gear Reward: Darkmantle Bracers", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [8911] = { "BIS", "Rare Gear Reward: Deathmist Bracers", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [8912] = { "BIS", "Rare Gear Reward: Bracers of Heroism", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [8913] = { "BIS", "Rare Gear Reward: Feralheart Bracers", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [8914] = { "BIS", "Rare Gear Reward: Beastmaster's Bindings", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [8915] = { "BIS", "Rare Gear Reward: Sorcerer's Bindings", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [8916] = { "BIS", "Rare Gear Reward: Virtuous Bracers", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [8917] = { "BIS", "Rare Gear Reward: Darkmantle Bracers", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [8918] = { "BIS", "Rare Gear Reward: Bindings of The Five Thunders", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [8919] = { "BIS", "Rare Gear Reward: Deathmist Bracers", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [8920] = { "BIS", "Rare Gear Reward: Bracers of Heroism", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [8949] = { "BIS", "Rare Accessory: Beads of Ogre Might", "Dire Maul", 60, "B", false, nil, "Falrin's Vendetta" },
    [8999] = { "EPIC", "Epic Reward: Feralheart Cowl", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [9000] = { "EPIC", "Epic Reward: Beastmaster's Cap", "Ironforge", 60, "B", true, nil, "Saving the Best for Last" },
    [9001] = { "EPIC", "Epic Reward: Sorcerer's Crown", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [9002] = { "EPIC", "Epic Reward: Soulforge Helm", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [9003] = { "EPIC", "Epic Reward: Virtuous Crown", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [9004] = { "EPIC", "Epic Reward: Darkmantle Cap", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [9005] = { "EPIC", "Epic Reward: Deathmist Mask", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [9006] = { "EPIC", "Epic Reward: Helm of Heroism", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [9007] = { "EPIC", "Epic Reward: Feralheart Cowl", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [9008] = { "EPIC", "Epic Reward: Beastmaster's Cap", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [9009] = { "EPIC", "Epic Reward: Virtuous Crown", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [9010] = { "EPIC", "Epic Reward: Darkmantle Cap", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [9011] = { "EPIC", "Epic Reward: Coif of The Five Thunders", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [9012] = { "EPIC", "Epic Reward: Deathmist Mask", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [9013] = { "EPIC", "Epic Reward: Helm of Heroism", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [9014] = { "EPIC", "Epic Reward: Sorcerer's Crown", "Orgrimmar", 60, "B", true, nil, "Saving the Best for Last" },
    [9023] = { "BIS", "Rare Weapon / Shield: Ravenholdt Slicer", "Silithus", 60, "B", false, nil, "The Perfect Poison" },
    [9053] = { "BIS", "Rare Weapon / Shield: Moonshadow Stave", nil, 52, "B", false, "DRUID", "A Better Ingredient" },
    [9068] = { "EPIC", "Epic Reward: Earthshatter Tunic", "Naxxramas", 60, "H", true, nil, "Earthshatter Tunic" },
    [9069] = { "EPIC", "Epic Reward: Earthshatter Legguards", "Naxxramas", 60, "H", true, nil, "Earthshatter Legguards" },
    [9070] = { "EPIC", "Epic Reward: Earthshatter Headpiece", "Naxxramas", 60, "H", true, nil, "Earthshatter Headpiece" },
    [9071] = { "EPIC", "Epic Reward: Earthshatter Spaulders", "Naxxramas", 60, "H", true, nil, "Earthshatter Spaulders" },
    [9072] = { "EPIC", "Epic Reward: Earthshatter Boots", "Naxxramas", 60, "H", true, nil, "Earthshatter Boots" },
    [9073] = { "EPIC", "Epic Reward: Earthshatter Handguards", "Naxxramas", 60, "H", true, nil, "Earthshatter Handguards" },
    [9074] = { "EPIC", "Epic Reward: Earthshatter Girdle", "Naxxramas", 60, "H", true, nil, "Earthshatter Girdle" },
    [9075] = { "EPIC", "Epic Reward: Earthshatter Wristguards", "Naxxramas", 60, "H", true, nil, "Earthshatter Wristguards" },
    [9111] = { "EPIC", "Epic Reward: Robe of Faith", "Naxxramas", 60, "B", true, nil, "Robe of Faith" },
    [9112] = { "EPIC", "Epic Reward: Leggings of Faith", "Naxxramas", 60, "B", true, nil, "Leggings of Faith" },
    [9113] = { "EPIC", "Epic Reward: Circlet of Faith", "Naxxramas", 60, "B", true, nil, "Circlet of Faith" },
    [9114] = { "EPIC", "Epic Reward: Shoulderpads of Faith", "Naxxramas", 60, "B", true, nil, "Shoulderpads of Faith" },
    [9115] = { "EPIC", "Epic Reward: Sandals of Faith", "Naxxramas", 60, "B", true, nil, "Sandals of Faith" },
    [9116] = { "EPIC", "Epic Reward: Gloves of Faith", "Naxxramas", 60, "B", true, nil, "Gloves of Faith" },
    [9117] = { "EPIC", "Epic Reward: Belt of Faith", "Naxxramas", 60, "B", true, nil, "Belt of Faith" },
    [9118] = { "EPIC", "Epic Reward: Bindings of Faith", "Naxxramas", 60, "B", true, nil, "Bindings of Faith" },
    [9120] = { "EPIC", "Epic Reward: Mark of the Champion", "Naxxramas", 60, "B", true, nil, "The Fall of Kel'Thuzad" },
    [9121] = { "KEY", "Attunement: Naxxramas Raid (Argent Dawn Honored)", "Eastern Plaguelands", 60, "B", true, nil, "The Dread Citadel - Naxxramas" },
    [9122] = { "KEY", "Attunement: Naxxramas Raid (Argent Dawn Revered)", "Eastern Plaguelands", 60, "B", true, nil, "The Dread Citadel - Naxxramas" },
    [9123] = { "KEY", "Attunement: Naxxramas Raid (Argent Dawn Exalted)", "Eastern Plaguelands", 60, "B", true, nil, "The Dread Citadel - Naxxramas" },
    [9230] = { "EPIC", "Epic Reward: Ramaladni's Icy Grasp", "Naxxramas", 60, "B", true, nil, "Ramaladni's Icy Grasp" },
    [9232] = { "EPIC", "Epic Reward: Glacial Leggings", "Naxxramas", 60, "B", true, nil, "The Only Song I Know..." },
    [9234] = { "EPIC", "Epic Reward: Icebane Gauntlets", "Naxxramas", 60, "B", true, nil, "Icebane Gauntlets" },
    [9235] = { "EPIC", "Epic Reward: Icebane Bracers", "Naxxramas", 60, "B", true, nil, "Icebane Bracers" },
    [9236] = { "EPIC", "Epic Reward: Icebane Breastplate", "Naxxramas", 60, "B", true, nil, "Icebane Breastplate" },
    [9237] = { "EPIC", "Epic Reward: Glacial Cloak", "Naxxramas", 60, "B", true, nil, "Glacial Cloak" },
    [9238] = { "EPIC", "Epic Reward: Glacial Wrists", "Naxxramas", 60, "A", true, nil, "Glacial Wrists" },
    [9239] = { "EPIC", "Epic Reward: Glacial Gloves", "Naxxramas", 60, "A", true, nil, "Glacial Gloves" },
    [9240] = { "EPIC", "Epic Reward: Glacial Vest", "Naxxramas", 60, "A", true, nil, "Glacial Vest" },
    [9241] = { "EPIC", "Epic Reward: Polar Bracers", "Naxxramas", 60, "B", true, nil, "Polar Bracers" },
    [9242] = { "EPIC", "Epic Reward: Polar Gloves", "Naxxramas", 60, "B", true, nil, "Polar Gloves" },
    [9243] = { "EPIC", "Epic Reward: Polar Tunic", "Naxxramas", 60, "B", true, nil, "Polar Tunic" },
    [9244] = { "EPIC", "Epic Reward: Icy Scale Bracers", "Naxxramas", 60, "B", true, nil, "Icy Scale Bracers" },
    [9245] = { "EPIC", "Epic Reward: Icy Scale Gauntlets", "Naxxramas", 60, "B", true, nil, "Icy Scale Gauntlets" },
    [9246] = { "EPIC", "Epic Reward: Icy Scale Breastplate", "Naxxramas", 60, "B", true, nil, "Icy Scale Breastplate" },
    [9248] = { "BIS", "Rare Accessory: Band of Cenarius", "Silithus", 58, "B", false, nil, "A Humble Offering" },
    [9250] = { "EPIC", "Epic Reward: Frame of Atiesh", "Naxxramas", 60, "H", true, nil, "Frame of Atiesh" },
    [9257] = { "EPIC", "Epic Reward: Atiesh, Greatstaff of the Guardian", "Naxxramas", 60, "B", true, nil, "Atiesh, Greatstaff of the Guardian" },
    [9269] = { "EPIC", "Epic Reward: Atiesh, Greatstaff of the Guardian", "Naxxramas", 60, "B", true, nil, "Atiesh, Greatstaff of the Guardian" },
    [9270] = { "EPIC", "Epic Reward: Atiesh, Greatstaff of the Guardian", "Naxxramas", 60, "B", true, nil, "Atiesh, Greatstaff of the Guardian" },
    [9271] = { "EPIC", "Epic Reward: Atiesh, Greatstaff of the Guardian", "Naxxramas", 60, "B", true, nil, "Atiesh, Greatstaff of the Guardian" },
    [9364] = { "CLASS", "Class Spell / Ability Unlock", nil, 60, "B", true, "MAGE", "Fragmented Magic" },
    [78093] = { "BIS", "Rare Accessory: Cloak of the Divine Storm", nil, 25, "A", false, "PALADIN", "Return to Delgren" },
    [78150] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "B", true, "MAGE", "Friend of the Library" },
    [78307] = { "BIS", "Rare Accessory: Pyrewood Signet Ring", "Shadowfang Keep", 23, "B", false, "ROGUE", "The Horn of Xelthos" },
    [78699] = { "BIS", "Rare Weapon / Shield: Ruby-Adorned Blade", "Scarlet Monastery", 23, "B", false, "ROGUE", "The Eye of Bhossca" },
    [78916] = { "BIS", "Rare Accessory: Acolyte's Void Pearl", "Blackfathom Deeps", 25, "A", false, nil, "The Heart of the Void" },
    [78917] = { "BIS", "Rare Accessory: Acolyte's Void Pearl", "Blackfathom Deeps", 25, "H", false, nil, "The Heart of the Void" },
    [79192] = { "BAG", "Bag Reward: Sturdy Lunchbox", "The Barrens", 24, "B", true, nil, "Stepping Stones" },
    [79366] = { "BIS", "Rare Gear Reward: Stormchaser's Bindings", "Thousand Needles", 40, "H", true, "SHAMAN", "Calm Before the Storm" },
    [79442] = { "BIS", "Rare Weapon / Shield: Elementalist's Guard", "Thousand Needles", 40, "H", false, "SHAMAN", "The Tempest's Weapons" },
    [79536] = { "CLASS", "Class Milestone (Field Researcher's Loop)", nil, 35, "B", true, "MAGE", "Greater Friend of the Library" },
    [79970] = { "CLASS", "Class Milestone (Pauldrons of Vindication)", nil, 40, "A", true, "PALADIN", "Aeonas the Vindicated" },
    [79976] = { "BIS", "Utility Item: Cozy Sleeping Bag (+3% Bonus Rested XP)", "Hillsbrad Foothills", 40, "B", true, nil, "This Must Be The Place" },
    [80324] = { "EPIC", "Epic Reward: Pendant of Homecoming", "Gnomeregan", 40, "A", true, nil, "The Mad King" },
    [80325] = { "EPIC", "Epic Reward: Pendant of Homecoming", "Gnomeregan", 40, "H", true, nil, "The Mad King" },
    [80455] = { "BIS", "Rare Accessory: Filcher's Cowl", nil, 50, "B", false, "ROGUE", "Biding Our Time" },
    [81766] = { "CLASS", "Class Spell / Ability Unlock", nil, 46, "A", true, "PALADIN", "The Bloody Missive" },
    [81885] = { "CLASS", "Class Spell / Ability Unlock", nil, 50, "A", true, "PALADIN", "The Ritual" },
    [81919] = { "BIS", "Rare Accessory: Infernal Lasso", "Blasted Lands", 50, "B", false, "HUNTER", "Brought to Heel" },
    [81924] = { "BIS", "Rare Accessory: Seed of Renewal", nil, 50, "B", false, "DRUID", "Wisdom of the Guardians" },
    [82062] = { "BIS", "Rare Gear Reward: Traveler's Symbols", "Blackrock Depths", 56, "B", false, nil, "Ever After" },
    [82084] = { "BIS", "Rare Weapon / Shield: Personal Spellbook", "Zul'Farrak", 45, "B", false, "MAGE", "A Lesson in Literacy" },
    [82135] = { "BIS", "Rare Weapon / Shield: Whisper", nil, 50, "A", false, "PALADIN", "The Price of Hope" },
    [82208] = { "CLASS", "Class Milestone (Truthseeker's Bow)", nil, 45, "B", true, "MAGE", "Greater Friend of the Library" },
    [84124] = { "BIS", "Rare Weapon / Shield: Old Guard Retaliator", nil, 60, "B", false, "WARRIOR", "Legacy of Valor" },
    [84146] = { "BAG", "Bag Reward: Red Bag", "Winterspring", 60, "B", true, "WARRIOR", "Red Bag Blues" },
    [84147] = { "BIS", "Rare Gear Reward: Feralheart Wristguards", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [84148] = { "BIS", "Rare Gear Reward: Beastmaster's Bindings", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [84149] = { "BIS", "Rare Gear Reward: Sorcerer's Bindings", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [84150] = { "BIS", "Rare Gear Reward: Soulforge Wristguards", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [84151] = { "BIS", "Rare Gear Reward: Virtuous Wraps", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [84152] = { "BIS", "Rare Gear Reward: Darkmantle Bracers", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [84153] = { "BIS", "Rare Gear Reward: Deathmist Bracers", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [84154] = { "BIS", "Rare Gear Reward: Wristguards of Heroism", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [84155] = { "BIS", "Rare Gear Reward: Feralheart Wraps", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [84156] = { "BIS", "Rare Gear Reward: Beastmaster's Bindings", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [84157] = { "BIS", "Rare Gear Reward: Sorcerer's Bindings", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [84158] = { "BIS", "Rare Gear Reward: Virtuous Bracers", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [84159] = { "BIS", "Rare Gear Reward: Darkmantle Bracers", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [84160] = { "BIS", "Rare Gear Reward: Bindings of The Five Thunders", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [84161] = { "BIS", "Rare Gear Reward: Deathmist Bracers", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [84162] = { "BIS", "Rare Gear Reward: Bracers of Heroism", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [84195] = { "EPIC", "Epic Reward: Feline Helm and Chestpiece Set", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [84196] = { "EPIC", "Epic Reward: Beastmaster's Cap", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [84200] = { "EPIC", "Epic Reward: Darkmantle Cap", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [84202] = { "EPIC", "Epic Reward: Immoveable Helm and Chestpiece Set", "Ironforge", 60, "A", true, nil, "Saving the Best for Last" },
    [84203] = { "EPIC", "Epic Reward: Feline Helm and Chestpiece Set", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [84208] = { "EPIC", "Epic Reward: Relief's Helm and Chestpiece Set", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [84210] = { "EPIC", "Epic Reward: Immoveable Helm and Chestpiece Set", "Orgrimmar", 60, "H", true, nil, "Saving the Best for Last" },
    [84213] = { "EPIC", "Epic Reward: Sun Shades", "South Seas", 65, "B", true, "WARRIOR", "Rift Away" },
    [84332] = { "CLASS", "Class Milestone (Hammer of the Fallen Thane)", nil, 55, "A", true, "PALADIN", "A Thane's Gratitude" },
    [84394] = { "CLASS", "Class Milestone (Antique Bulwark)", nil, 60, "B", true, "MAGE", "Greater Friend of the Library" },
    [86814] = { "BIS", "Rare Gear Reward: Sacred Bangle", "Azshara", 55, "B", false, nil, "Blackmaw Counter-Offensive" },
    [89015] = { "BIS", "Rare Weapon / Shield: A Bigger Shield", "Azshara", 56, "A", false, nil, "Deadliest Catch" },
    [91611] = { "BIS", "Rare Weapon / Shield: A Bigger Shield", "Azshara", 56, "H", false, nil, "Deadliest Catch" },
    [92065] = { "BIS", "Rare Accessory: Ouroboros Ring", "Blackmaw Hold", 60, "B", false, nil, "Blackmaw Reclamation" },
    [92189] = { "BIS", "Rare Gear Reward: Plans: Bold Dirk", "Mount Hyjal", 57, "A", false, nil, "Back to the Grind" },
    [92422] = { "BIS", "Rare Weapon / Shield: Forsaken Greataxe", "Ruins of Lordaeron", 22, "H", false, nil, "The Wrath of Rath'mael" },
    [92446] = { "BIS", "Rare Weapon / Shield: Elderwild Construction Hammer", "Mount Hyjal", 60, "H", false, nil, "Head Scratcher" },
    [92454] = { "BIS", "Rare Gear Reward: Diablo Stone", "Zephras Isle", 1, "B", false, nil, "Welcome!" },
    [92458] = { "BIS", "Rare Weapon / Shield: Defender of Dalaran", "City of Dalaran", 33, "A", false, nil, "Heart of Disruption" },
    [92753] = { "BIS", "Forever Deadmines Finale (Explosive Consultation)", "The Deadmines", 18, "A", false, nil, "Destruction in Deadmines" },
    [92959] = { "BIS", "Rare Weapon / Shield: Sunderbark Vigil", "Mount Hyjal", 56, "B", false, nil, "The Dying Ancients" },
    [93128] = { "BIS", "Rare Weapon / Shield: Abandoned Ferocity", "Desolace", 42, "B", false, nil, "Khan Jehn" },
    [93196] = { "BIS", "Rare Weapon / Shield: Greatstaff of the Necrokhans", "Desolace", 42, "H", false, nil, "Khan Jehn" },
    [93269] = { "BAG", "Bag Reward: Hyjal Postal Satchel", "Mount Hyjal", 58, "B", true, nil, "Top of the Post" },
    [93404] = { "BIS", "Rare Gear Reward: Overgrown Cuffs", "Maraudon", 49, "B", false, nil, "Rot and Regret" },
    [93444] = { "BIS", "Rare Accessory: Chimaera Wing Cape", "Mount Hyjal", 60, "B", false, nil, "Bait the Beast" },
    [93574] = { "BIS", "Rare Accessory: Corpsefeeder's Shedding", "Dire Maul", 45, "B", false, nil, "Corpsefeeder's Carapace" },
    [93848] = { "BIS", "Rare Accessory: Ring of Nature's Cycles", "Mount Hyjal", 60, "B", false, nil, "Work Well Done" },
    [94003] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "B", true, "WARRIOR", "The Skybreaker Bulwark" },
    [94013] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "B", true, "HUNTER", "Taming the Beast" },
    [94050] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "B", true, "HUNTER", "Training the Beast" },
    [94441] = { "CLASS", "Class Spell / Ability Unlock", nil, 12, "H", true, "PALADIN", "A Lesson in Divinity" },
    [94468] = { "CLASS", "Class Spell / Ability Unlock", nil, 14, "A", true, "SHAMAN", "Call of Fire" },
    [94505] = { "CLASS", "Class Spell / Ability Unlock", nil, 23, "A", true, "SHAMAN", "Call of Water" },
    [94638] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "B", true, "DRUID", "Strength and Mercy" },
    [94773] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Divine Grace" },
    [94774] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Divine Grace" },
    [94775] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Divine Grace" },
    [94776] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Divine Grace" },
    [94777] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Divine Grace" },
    [94778] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Divine Grace" },
    [94779] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Divine Grace" },
    [94793] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "HUNTER", "Training the Beast" },
    [94817] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Confounding Flash" },
    [94818] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Contingency Plan" },
    [94819] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Contingency Plan" },
    [94820] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "PRIEST", "Contingency Plan" },
    [94821] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Confounding Flash" },
    [94822] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Confounding Flash" },
    [94823] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Confounding Flash" },
    [94824] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Confounding Flash" },
    [94825] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Confounding Flash" },
    [94826] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "PRIEST", "Confounding Flash" },
    [94864] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "A", true, "HUNTER", "Taming the Beast" },
    [94927] = { "BIS", "Rare Weapon / Shield: Dunston's Ogre Duster", "Riverglades", 44, "A", false, nil, "Dunston Checks Out" },
    [94968] = { "BIS", "Rare Weapon / Shield: Rock on Stick", "Krol'dok Stronghold", 45, "H", false, nil, "Eye of Mugg" },
    [94971] = { "CLASS", "Class Spell / Ability Unlock", nil, 40, "H", true, "PALADIN", "A Paladin's Steed" },
    [94974] = { "KEY", "Key / Attunement: Krol'dok Compound Key", "Krol'dok Stronghold", 41, "H", true, nil, "Key Ingredients" },
    [94981] = { "KEY", "Key / Attunement: Krol'dok Compound Key", "Krol'dok Stronghold", 41, "A", true, nil, "Key Ingredients" },
    [94982] = { "BIS", "Rare Weapon / Shield: Rock on Stick", "Krol'dok Stronghold", 45, "A", false, nil, "Eye of Mugg" },
    [94998] = { "BIS", "Rare Accessory: Curio-Adorned Necklace", "Krol'dok Stronghold", 42, "A", false, nil, "Curios of Curiosity" },
    [95063] = { "BIS", "Rare Accessory: Bloodmaster's Ring", "Riverglades", 45, "H", false, nil, "Bloodmaster's Ring" },
    [95140] = { "BIS", "Rare Weapon / Shield: Wolfsbane", "Silverpine Forest", 26, "H", true, "PALADIN", "Old Fire-Eye" },
    [95264] = { "BIS", "Rare Accessory: Courier's Clasp", "Stormwind City", 53, "A", false, nil, "Shaw Needs To Know" },
    [95483] = { "BIS", "Rare Accessory: Courier's Clasp", "Alcaz Prison", 53, "H", false, nil, "Thrall Needs to Know" },
    [95511] = { "MOUNT", "Mount: Reins of the Striped Nightsaber", "Darnassus", 40, "A", true, nil, "Your First Feline Friend" },
    [95790] = { "BIS", "Rare Gear Reward: Lost Researcher's Hood", "Shaper's Terrace", 60, "A", false, nil, "Digestible Research" },
    [95798] = { "BIS", "Rare Gear Reward: Rune-Etched Epaulets", "Alterac Mountains", 40, "A", false, nil, "The Web of Magic" },
    [95799] = { "BIS", "Rare Weapon / Shield: Ancient Voodoo Pouch", "Ironforge", 40, "A", false, nil, "Findings for the Explorer's League" },
    [95818] = { "BIS", "Rare Gear Reward: Dwarven Tradeskill Signpost", "Ironforge", 60, "B", false, nil, "A Quick Craft" },
    [95821] = { "BIS", "Rare Gear Reward: Orcish Tradeskill Signpost", "Orgrimmar", 60, "B", false, nil, "A Quick Craft" },
    [95924] = { "BIS", "Rare Gear Reward: Diemetradon Scale Spaulders", "Shaper's Terrace", 60, "A", false, nil, "Panic at the Digsite" },
    [95925] = { "BIS", "Rare Weapon / Shield: Crystal-Infused Cleaver", "Shaper's Terrace", 60, "A", false, nil, "Mapping the Way Forward" },
    [95926] = { "BIS", "Rare Weapon / Shield: Crystal-Infused Cleaver", "Shaper's Terrace", 60, "H", false, nil, "The Dark Crystal" },
    [95928] = { "BIS", "Rare Gear Reward: Crystalline Pauldrons", "Shaper's Terrace", 60, "H", false, nil, "Crystalline Elements" },
    [96016] = { "BIS", "Rare Weapon / Shield: Elementalist's Guard", nil, 40, "A", false, "SHAMAN", "The Tempest's Weapons" },
    [96078] = { "BIS", "Rare Weapon / Shield: Ceremonial Mallet", "Stranglethorn Vale", 40, "H", false, nil, "A Tale Spun Around the Fire" },
    [96260] = { "BAG", "Bag Reward: Spidersilk Sack", "Mulgore", 29, "H", true, nil, "Stronger than Steel" },
    [96339] = { "BIS", "Rare Gear Reward: Holstered Replica Ironforge Air Rifle", "The Barrens", 60, "B", false, nil, "Legacy Reward: Replica Ironforge Air Rifle" },
    [96383] = { "BIS", "Rare Gear Reward: Spectral Bear Cub", "The Barrens", 60, "B", false, nil, "Legacy Reward: Spectral Bear Cub" },
    [96393] = { "BIS", "Rare Weapon / Shield: Calibrated Blunderbuss", "Hall of Thanes", 16, "A", false, nil, "Old Ironforge Incursion" },
    [96609] = { "BIS", "Rare Gear Reward: Everlasting Silvermoon Shimmerwine", "City of Dalaran", 52, "A", false, nil, "A Taste of Home" },
    [96800] = { "BIS", "Rare Accessory: Knucklebound Thimble", "Scarlet Monastery", 38, "A", false, nil, "Past Due" },
    [96982] = { "MOUNT", "Mount: White Kodo", "Mulgore", 40, "H", true, nil, "Your First Riding Kodo" },
    [96984] = { "BIS", "Rare Weapon / Shield: Striking Staff", "City of Dalaran", 33, "H", false, nil, "Heart of Disruption" },
    [96989] = { "MOUNT", "Mount: Whistle of the Emerald Raptor", "Durotar", 40, "H", true, nil, "Your First Riding Raptor" },
    [96994] = { "MOUNT", "Mount: Horn of the Brown Wolf", "Orgrimmar", 40, "H", true, nil, "Your First Riding Wolf" },
    [96996] = { "MOUNT", "Mount: Empyrean Galestrider", "Zephras Isle", 40, "B", true, nil, "Your First Riding Galestrider" },
    [96997] = { "MOUNT", "Mount: Blue Skeletal Horse", "Tirisfal Glades", 40, "H", true, nil, "A Steed in Death as They Were in Life" },
    [97017] = { "MOUNT", "Mount: Brown Ram", "Dun Morogh", 40, "A", true, nil, "Your First Riding Ram" },
    [97045] = { "MOUNT", "Mount: Brown Horse Bridle", "Elwynn Forest", 40, "A", true, nil, "Your First Horse" },
    [97046] = { "MOUNT", "Mount: Red Mechanostrider", "Dun Morogh", 40, "A", true, nil, "Your First Mechanostrider" },
    [97049] = { "BIS", "Rare Gear Reward: Slime-Resistant Shroud", "Shaper's Terrace", 60, "H", false, nil, "Essence of Seeping Slimes" },
    [97169] = { "EPIC", "Epic Reward: Skyfury Helm", nil, 60, "A", true, "SHAMAN", "The Darkreaver Menace" },
    [97171] = { "MOUNT", "Mount: Brown Horse Bridle", "Wetlands", 40, "A", true, nil, "Your First Horse" },
    [97185] = { "CLASS", "Class Spell / Ability Unlock", nil, 60, "H", true, "PALADIN", "Justice and Retribution" },
    [97257] = { "CLASS", "Class Spell / Ability Unlock", nil, 10, "H", true, "SHAMAN", "Call of Fire" },
    [97271] = { "BIS", "Rare Accessory: Shen'dralar Relic", "Dire Maul", 60, "B", false, nil, "Maul or Nothing!" },
    [97286] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "B", true, "MAGE", "Research Access" },
    [97411] = { "BIS", "Rare Gear Reward: Soulforge Wristguards", "Orgrimmar", 60, "H", false, nil, "An Earnest Proposition" },
    [97446] = { "MOUNT", "Mount: White Kodo", "Stonetalon Mountains", 40, "H", true, nil, "Your First Riding Kodo" },
    [97447] = { "BIS", "Rare Gear Reward: Bindings of The Five Thunders", "Ironforge", 60, "A", false, nil, "An Earnest Proposition" },
    [98028] = { "BIS", "Rare Weapon / Shield: Mathystra Channeling Orb", "Darkshore", 21, "A", false, nil, "Baron Marinous" },
    [98166] = { "MOUNT", "Mount: Brown Horse Bridle", "Wetlands", 40, "A", true, nil, "Your First Horse" },
    [98297] = { "BIS", "Rare Weapon / Shield: Fallen Dragon's Scepter", "Wetlands", 34, "A", false, nil, "Stopping the Cycle" },
    [98310] = { "BIS", "Rare Accessory: Golem War Cloak", "Wetlands", 32, "A", false, nil, "Gleaning Our Future" },
    [98362] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "H", true, "DRUID", "To Thunder Bluff" },
    [98397] = { "CLASS", "Class Spell / Ability Unlock", nil, 20, "A", true, "DRUID", "To Darnassus" },
    [98823] = { "BIS", "Rare Accessory: Furs of the Earthen Ring", "Excavation Site: Wetlands", 31, "H", false, nil, "Earthen Echo" },
    [98824] = { "BIS", "Rare Accessory: Explorer's League Dustcover", "Excavation Site: Wetlands", 31, "A", false, nil, "Prehistoric Prism" },
    [99187] = { "BIS", "Rare Weapon / Shield: Sword of Mourning", nil, 58, "H", false, "PALADIN", "The Reliquary of Tyr" },
    [99210] = { "MOUNT", "Mount: Swift White Ram", "Dun Morogh", 60, "A", true, nil, "An Epic Ride" },
    [99211] = { "MOUNT", "Mount: Ochre Skeletal Warhorse", "Tirisfal Glades", 60, "H", true, nil, "An Epic Ride" },
    [99212] = { "MOUNT", "Mount: Swift Green Mechanostrider", "Dun Morogh", 60, "A", true, nil, "An Epic Ride" },
    [99213] = { "MOUNT", "Mount: Swift Palomino", "Elwynn Forest", 60, "A", true, nil, "An Epic Ride" },
    [99214] = { "MOUNT", "Mount: Reins of the Swift Stormsaber", "Darnassus", 60, "A", true, nil, "An Epic Ride" },
    [99215] = { "MOUNT", "Mount: Horn of the Swift Timber Wolf", "Orgrimmar", 60, "H", true, nil, "An Epic Ride" },
    [99216] = { "MOUNT", "Mount: Swift Empyrean Galestrider", "Zephras Isle", 60, "B", true, nil, "An Epic Ride" },
    [99217] = { "MOUNT", "Mount: Great Gray Kodo", "Mulgore", 60, "H", true, nil, "An Epic Ride" },
    [99218] = { "MOUNT", "Mount: Swift Blue Raptor", "Durotar", 60, "H", true, nil, "An Epic Ride" },
    [99326] = { "MOUNT", "Mount: Brown Horse Bridle", "Hillsbrad Foothills", 40, "A", true, nil, "Your First Horse" },
    [99670] = { "BIS", "Rare Accessory: Jereman's Bauble", "Mount Hyjal", 60, "B", false, nil, "Return to Jereman" },

    -- Missing Rare (Q3) Dungeon Quests Synced from ForeverDungeonJournal (41 Unique Quests)
    [96395] = { "BIS", "Rare Gear Reward: Catacomb Cloak / Deepgrave Trousers", "Hall of Thanes", 15, "B", false, nil, "An Ancient Grudge" },
    [96403] = { "BIS", "Rare Gear Reward: Dwarven Tome / Tomb Robber's Gloves", "Hall of Thanes", 15, "B", false, nil, "Important Heirlooms" },
    [96394] = { "BIS", "Rare Gear Reward: Dusty Belt / Cryptwalker Bracers", "Hall of Thanes", 15, "A", false, nil, "The Restless Dead" },
    [5724]  = { "BIS", "Rare Gear Reward: Featherbead Bracers / Savannah Bracers / Garrison Cuffs", "Ragefire Chasm", 16, "H", false, nil, "Returning the Lost Satchel" },
    [5725]  = { "BIS", "Rare Gear Reward: Ghastly Trousers / Dredgemire Leggings / Gargoyle Leggings", "Ragefire Chasm", 16, "H", false, nil, "The Power to Destroy..." },
    [95250] = { "BIS", "Rare Weapon / Shield: Monstrous Cleaver / Grave Shroud / Slain Baron's Signet", "Ruins of Lordaeron", 21, "A", false, nil, "Abominable Creatures" },
    [97288] = { "BIS", "Rare Weapon / Shield: Monstrous Cleaver / Grave Shroud / Slain Baron's Signet", "Ruins of Lordaeron", 21, "H", false, nil, "Unending Torment" },
    [92401] = { "BIS", "Rare Weapon / Shield: Edward's Knife / Tabitha's Cuffs", "Ruins of Lordaeron", 22, "H", false, nil, "A Frightened Request" },
    [95195] = { "BIS", "Rare Gear Reward: Duty Bound Leggings / Remembrance Armor", "Ruins of Lordaeron", 22, "A", false, nil, "Bloodied Insignia" },
    [92421] = { "BIS", "Rare Weapon / Shield: The Stitcher / Spare Part Bindings", "Ruins of Lordaeron", 22, "H", false, nil, "Light's Justice" },
    [92415] = { "BIS", "Rare Accessory: Tarnished Locket", "Ruins of Lordaeron", 22, "A", false, nil, "Remember That I Love You" },
    [95216] = { "BIS", "Rare Weapon / Shield: Plaguefang / Blight Gloves", "Ruins of Lordaeron", 22, "H", false, nil, "The New Plague" },
    [1806]  = { "BIS", "Rare Weapon / Shield: Verigan's Fist", "The Deadmines", 22, "A", true, "PALADIN", "The Test of Righteousness" },
    [1098]  = { "BIS", "Rare Gear Reward: Ghostly Mantle / Tanned Shoulderpads / Bronzed Shoulderguards", "Shadowfang Keep", 25, "H", false, nil, "Deathstalkers in Shadowfang" },
    [1013]  = { "BIS", "Rare Gear Reward: Grizzled Boots / Steel-clasped Bracers / Tattered Mittens", "Shadowfang Keep", 26, "H", false, nil, "The Book of Ur" },
    [1275]  = { "BIS", "Rare Gear Reward: Staghide Armguards / Beetle Clasps / Prelacy Cape", "Blackfathom Deeps", 24, "A", false, nil, "Researching the Corruption" },
    [1199]  = { "BIS", "Rare Gear Reward: Silvered Gauntlets / Nimbus Boots / Heartwood Girdle", "Blackfathom Deeps", 25, "A", false, nil, "Twilight Falls" },
    [6565]  = { "BIS", "Rare Accessory: Band of the Fist / Chestnut Mantle", "Blackfathom Deeps", 26, "H", false, nil, "Allegiance to the Old Gods" },
    [95682] = { "BIS", "Rare Gear Reward: Knife-Polishing Rag / Dirt-Heavy Bracers", "Excavation Site: Wetlands", 31, "H", false, nil, "Open the Maw" },
    [95697] = { "BIS", "Rare Weapon / Shield: Satchel of Potions / Serrated Raptor Claw", "Excavation Site: Wetlands", 31, "H", false, nil, "Changing Tastes" },
    [95646] = { "BIS", "Rare Weapon / Shield: Ironwood Destroyer / Curl of Life / Hornbeam Heft", "Excavation Site: Wetlands", 31, "A", false, nil, "Horrors in the Highland" },
    [95795] = { "BIS", "Rare Gear Reward: Daewyn's Girdle / Songblade Stabilizer", "Excavation Site: Wetlands", 31, "A", false, nil, "Fallen in the Fen" },
    [386]   = { "BIS", "Rare Weapon / Shield: Lucine Longsword / Hardened Root Staff / Ursine Hammer", "The Stockade", 25, "A", false, nil, "What Comes Around..." },
    [377]   = { "BIS", "Rare Gear Reward: Ambassador's Boots / Darkshire Mail Leggings / Town Clerk's Mittens", "The Stockade", 26, "A", false, nil, "Crime and Punishment" },
    [92456] = { "BIS", "Rare Gear Reward: Vine Pruner's Cloak / Thorn Protecting Girdle", "City of Dalaran", 33, "A", false, nil, "A Green Sample" },
    [92489] = { "BIS", "Rare Gear Reward: Violet Sash / Runebound Gloves", "City of Dalaran", 33, "A", false, nil, "Power Overwhelming" },
    [92457] = { "BIS", "Rare Accessory: Fallen Guard's Pendant / Arcane Infused Rod", "City of Dalaran", 33, "A", false, nil, "Starving Arcane" },
    [96987] = { "BIS", "Rare Gear Reward: City of Dalaran Rare Gear", "City of Dalaran", 33, "H", false, nil, "Opportunistic Education" },
    [96988] = { "BIS", "Rare Accessory: Unstable Power Core / Construct Cloak", "City of Dalaran", 33, "H", false, nil, "Source of Power" },
    [96986] = { "BIS", "Rare Gear Reward: Gravewalker Boots / Undead Knight's Bracers", "City of Dalaran", 33, "H", false, nil, "The Grave Knight" },
    [1144]  = { "BIS", "Rare Accessory: Boar Signet / Monkey Ring / Snake Hoop / Tiger Band", "Razorfen Kraul", 30, "B", false, nil, "Willix the Importer" },
    [1394]  = { "BIS", "Rare Weapon / Shield: Windstorm Hammer / Dancing Flame", "Scarlet Monastery", 36, "H", false, nil, "Final Passage" },
    [7029]  = { "BIS", "Rare Gear Reward: Sagebrush Girdle / Branchclaw Gauntlets", "Maraudon", 47, "H", false, nil, "Vyletongue Corruption" },
    [7041]  = { "BIS", "Rare Gear Reward: Sagebrush Girdle / Branchclaw Gauntlets", "Maraudon", 47, "A", false, nil, "Vyletongue Corruption" },
    [7028]  = { "BIS", "Rare Gear Reward: Acumen Robes / Sprightring Helm / Relentless Chain / Hulkstone Pauldrons", "Maraudon", 47, "B", false, nil, "Twisted Evils" },
    [3907]  = { "BIS", "Rare Gear Reward: Stalwart Clutch / Sunborne Cape / Nightfall Gloves", "Blackrock Depths", 56, "H", false, nil, "Disharmony of Fire" },
    [4362]  = { "BIS", "Rare Accessory: Magni's Will / Songstone of Ironforge", "Blackrock Depths", 59, "A", false, nil, "The Fate of the Kingdom" },
    [4003]  = { "BIS", "Rare Accessory: Thrall's Resolve / Eye of Orgrimmar", "Blackrock Depths", 59, "H", false, nil, "The Royal Rescue" },
    [7461]  = { "BIS", "Rare Gear Reward: Bonecrusher / Backwood Helm / Sedge Boots", "Dire Maul", 60, "B", false, nil, "The Madness Within" },
    [92070] = { "BIS", "Rare Accessory: Nama's Cherished Necklace", "Blackmaw Hold", 55, "B", false, nil, "A Lost Memento" },
    [5243]  = { "BIS", "Rare Gear Reward: Crown of the Penitent / Band of the Penitent", "Stratholme", 60, "B", false, nil, "Houses of the Holy" },

    -- Zero-Meta Gameplay Zone & Dungeon Coverage Expansion
    [95775] = { "BIS", "Chain Lead-in to Rare Weapon: Ceremonial Mallet / I'lalai Flayer", "The Drowned City", 40, "H", false, nil, "The Drowned City" },
    [95787] = { "BIS", "Chain Lead-in to Voodoo Pouch / Intrepid Explorer's Chainmail", "The Drowned City", 40, "A", false, nil, "Take Two With Water" },
    [95789] = { "BIS", "Dungeon Gear Upgrade: Rusted Troll War Belt / Saltseer's Helm", "The Drowned City", 40, "B", false, nil, "Shady Saltseers" },
    [95791] = { "BIS", "Dungeon Gear Upgrade: Mutinous Cuffs / South Seas Shroud", "The Drowned City", 40, "B", false, nil, "The Saltseer Captain" },
    [96774] = { "BIS", "Dungeon Finale: Ancient Gurubashi Idol (Earthen Ring +300)", "The Drowned City", 40, "H", false, nil, "Ancient Gurubashi Idol" },
    [97130] = { "BIS", "Dungeon Finale: Ancient Gurubashi Idol (Kirin Tor +300)", "The Drowned City", 40, "A", false, nil, "Ancient Gurubashi Secrets" },
    [92873] = { "BIS", "Rare Weapon / Shield: Blade of the Magram Clan / Staff of Revelations", "Shen'dralas", 41, "H", false, nil, "Proof of Concept" },
    [93609] = { "BIS", "Rare Accessory: Amulet of Vengeance / Amulet of Forgiveness", "Shen'dralas", 45, "B", false, nil, "Forlorn Necklace" },
    [96060] = { "BIS", "Rare Weapon / Shield: Phantasmal Shiv / Greatsword of Great Pasts", "Shen'dralas", 42, "B", false, nil, "Tempered Expectations" },
    [9]     = { "BIS", "Early Zone Finale: Harvester's Pants / Harvester's Robe", "Westfall", 15, "A", false, nil, "The Killing Fields" },
    [14]    = { "BIS", "Zone Chain Finale: Weapon & Boots of the People's Militia", "Westfall", 17, "A", false, nil, "The People's Militia" },
    [140]   = { "BIS", "Treasure Hunt Reward: Captain Sander's Shirt / Captain Sander's Sash", "Westfall", 16, "B", false, nil, "Captain Sander's Hidden Treasure" },
    [256]   = { "BIS", "Elite Wanted Finale: Minor Channeling Ring / Kimbra Boots / Loch Walkers", "Loch Modan", 22, "A", false, nil, "WANTED: Chok'sul" },
    [531]   = { "BIS", "Bag / Quiver Upgrade: Hunting Satchel / Hunting Quiver / Hunting Ammo Sack", "Loch Modan", 20, "A", true, nil, "Vyrin's Revenge" },
    [86585] = { "BIS", "Weapon Upgrade: Mountaineer's Greataxe / Invader's Mace", "Loch Modan", 17, "A", false, nil, "Banner of the Fallen" },
    [169]   = { "BIS", "Elite Wanted Bounty: Blackrock Mace / Redridge Shield", "Redridge Mountains", 26, "A", false, nil, "WANTED: Gath'Ilzogg" },
    [249]   = { "BIS", "Tower of Ilgalar Finale: Rose Mantle / Demonhide Bracers / Shadow Gauntlets", "Redridge Mountains", 27, "A", false, nil, "Morganth" },
    [95999] = { "BIS", "Elite Wanted Finale: Incinerator's Boots / Alacritous Treads", "Redridge Mountains", 25, "A", false, nil, "WANTED: Incinerator Gar'im" },
    [940]   = { "BIS", "Zone Finale: Forest Oracle's Cloak", "Teldrassil", 11, "A", false, nil, "Teldrassil" },
    [98403] = { "BIS", "Zone Upgrade: Webwood Slicer", "Teldrassil", 12, "A", false, nil, "Twisted Hatred" },
    [99053] = { "BIS", "Zone Upgrade: Ban'ethil Quiver / Sentinel's Slasher", "Teldrassil", 10, "A", false, nil, "Escaping Ban'ethil" },
    [646]   = { "BIS", "Stromgarde Finale: Blood-Tinged Armor / Pit Fighter's Shield", "Arathi Highlands", 42, "H", false, nil, "Trol'kalar" },
    [656]   = { "BIS", "Rare Trinket / Shard: Pulsating Crystalline Shard", "Arathi Highlands", 50, "B", false, nil, "Summoning the Princess" },
    [679]   = { "BIS", "Stromgarde Finale Weapon: Silent Hunter / Skullsplitter / Mindslicer", "Arathi Highlands", 40, "H", false, nil, "Call to Arms" },
    [680]   = { "BIS", "Stromgarde Finale: Mistspray Kilt / Sword of Hammerfall", "Arathi Highlands", 40, "H", false, nil, "The Real Threat" },
    [682]   = { "BIS", "Stromgarde Rare Legs: Stromgarde Cavalry Leggings / Librarian Leggings", "Arathi Highlands", 37, "A", false, nil, "Stromgarde Badges" },
    [685]   = { "BIS", "Stromgarde Wanted Finale: Rod of Sorrow / War Rider Bracers / Arathi Armbands", "Arathi Highlands", 40, "A", false, nil, "WANTED: Otto and Falconcrest" },
    [1166]  = { "BIS", "Zone Upgrade: Enormous Ogre Boots / Oversized Ogre's Mittens", "Dustwallow Marsh", 43, "H", false, nil, "Overlord Mok'Morokk's Concern" },
    [1172]  = { "BIS", "Elite Black Dragonflight Chain: Encarmine Boots / Boots of Zuatec", "Dustwallow Marsh", 45, "H", false, nil, "The Brood of Onyxia" },
    [1203]  = { "BIS", "Zone Upgrade: Artisan's Trousers / Reedknot Ring / Swamp Ring", "Dustwallow Marsh", 35, "B", false, nil, "Jarl Needs a Blade" },
    [98233] = { "BIS", "Weapon Upgrade: Jameson's Backup Sword", "Dustwallow Marsh", 42, "A", false, nil, "Sword in the Slime" },
    [93176] = { "BIS", "Unique Companion / Collectible: Weevil K. Neevil", "Swamp of Sorrows", 35, "B", false, nil, "My Little Friends" },
    [3062]  = { "BIS", "Elite Finale: Wingcrest Gloves / Stronghorn Girdle / Protector's Armguards", "Feralas", 50, "H", false, nil, "Dark Heart" },
    [92858] = { "BIS", "Elite Wanted Finale: Staff of Brutal Cunning", "Feralas", 43, "A", false, nil, "WANTED: Ohk'zi" },
    [97378] = { "BIS", "Zone Shoulder Upgrade: Mantle / Pauldrons / Shoulderplates of Scaleslaying", "Feralas", 50, "H", false, nil, "Mirrorscale" },
    [3463]  = { "BIS", "Zone Finale Gear: Dragonflight Leggings / Drakefire Headguard / Axe of the Ebon Drake", "Searing Gorge", 52, "B", false, nil, "Set Them Ablaze!" },
    [7701]  = { "BIS", "Elite Wanted Finale: Seared Mail Vest / Charred Leather Tunic / Singed Cloth Robe", "Searing Gorge", 50, "B", false, nil, "WANTED: Overseer Maltorius" },
    [7741]  = { "BIS", "Faction Milestone: Praise from the Emerald Circle", "Felwood", 59, "B", false, nil, "Praise from the Emerald Circle" },
    [84211] = { "BIS", "Endgame Forever Reward: Fantastic Inventions", "Burning Steppes", 60, "B", false, nil, "Poacher's Den" },
}

local META_ZONE_ALIASES = {
    ["the temple of atal'hakkar"] = "Sunken Temple",
    ["temple of atal'hakkar"] = "Sunken Temple",
    ["riverlands"] = "Riverglades",
    ["hyjal"] = "Mount Hyjal",
    ["stormwind stockade"] = "The Stockade",
    ["blackrock spire"] = "Lower Blackrock Spire",
}

local _metaMemo = {}
local _metaByZone = nil

function Data.InvalidateMetaMemo(questID)
    if questID then
        _metaMemo[questID] = nil
    else
        wipe(_metaMemo)
        _metaByZone = nil
    end
end

local function NormalizeFactionSide(side)
    if type(side) ~= "string" then return nil end
    local up = string.upper(side)
    if up == "A" or up == "ALLIANCE" then return "A" end
    if up == "H" or up == "HORDE" then return "H" end
    return "B"
end

local function BuildMetaEntry(questID, tag, reason, zone, level, side, perm, reqClass, title, isChainStep, leadsTo)
    return {
        questID = questID,
        tag = tag or "BIS",
        reason = reason or "",
        zone = zone,
        level = level,
        side = side or "B",
        perm = perm and true or false,
        reqClass = reqClass,
        title = title,
        isChainStep = isChainStep and true or false,
        leadsTo = leadsTo,
    }
end

local function GetCuratedMetaSource(id)
    local raw = Data.MetaQuests and Data.MetaQuests[id]
    if raw then
        return raw[1], raw[2], raw[3], raw[4], raw[5], raw[6], raw[7], raw[8]
    end
    local p = Data.QuestPayoffs and Data.QuestPayoffs[id]
    if p and p.isKeyUnlock then
        local u = p.unlock or ""
        if string.find(u, "^Key:") or string.find(u, "^Attunement:") then
            return "KEY", (p.summary or p.unlock or ""), nil, nil, "B", true, nil, nil
        elseif string.find(u, "^Ability:") or string.find(u, "^Summon:") or string.find(u, "^Totem:") then
            return "CLASS", (p.summary or p.unlock or ""), nil, nil, "B", true, nil, nil
        elseif id == 1715 or string.find(u, "^Pet:") then
            return "BIS", (p.summary or p.reward or u), nil, nil, "B", true, nil, nil
        elseif string.find(u, "^Dungeon") then
            return "BIS", (p.summary or p.reward or u), nil, nil, "B", false, nil, nil
        end
    end
    return nil
end

function Data.GetMetaQuestInfo(questID)
    local numID = tonumber(questID)
    local targetID = (numID and numID == numID and numID > 0 and numID < math.huge) and numID or nil
    if not targetID then return nil end

    if _metaMemo[targetID] ~= nil then
        return _metaMemo[targetID] or nil
    end

    local result = nil
    local directRaw = Data.MetaQuests and Data.MetaQuests[targetID]
    if directRaw then
        result = BuildMetaEntry(targetID, directRaw[1], directRaw[2], directRaw[3], directRaw[4], directRaw[5], directRaw[6], directRaw[7], directRaw[8], false, nil)
    else
        -- Inherit Meta significance from downstream quest in the same chain
        local cInfo = Data.ChainIndex and Data.ChainIndex[targetID]
        local chainObj = cInfo and cInfo.chainID and Data.KnownChains and Data.KnownChains[cInfo.chainID]
        local quests = chainObj and chainObj.quests
        if quests and cInfo.step and cInfo.step < #quests then
            local bestTag, bestReason, bestZone, bestLvl, bestSide, bestPerm, bestCls, bestTitle, bestTarget = nil
            for i = #quests, cInfo.step + 1, -1 do
                local futID = quests[i]
                if futID and futID ~= targetID then
                    local t, r, z, l, s, pm, cls, ttl = GetCuratedMetaSource(futID)
                    if t then
                        bestTag, bestReason, bestZone, bestLvl, bestSide, bestPerm, bestCls, bestTitle, bestTarget = t, r, z, l, s, pm, cls, ttl, futID
                        break
                    end
                end
            end
            if bestTag then
                local chainReason = (bestReason and bestReason ~= "") and ("Chain -> " .. bestReason) or "Leads to Meta Finale"
                result = BuildMetaEntry(targetID, bestTag, chainReason, bestZone, bestLvl, bestSide, bestPerm, bestCls, bestTitle, true, bestTarget)
            end
        end

        if not result then
            local t, r, z, l, s, pm, cls, ttl = GetCuratedMetaSource(targetID)
            if t then
                result = BuildMetaEntry(targetID, t, r, z, l, s, pm, cls, ttl, false, nil)
            end
        end
    end

    _metaMemo[targetID] = result or false
    return result
end

local function CanonicalizeMetaZone(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then return nil end
    local lower = string.lower(string.gsub(zoneName, "^%s*(.-)%s*$", "%1"))
    return META_ZONE_ALIASES[lower] or zoneName
end

local function BuildZoneMetaIndex()
    local byZone = {}
    local metaQuests = Data.MetaQuests or {}
    for qID, raw in pairs(metaQuests) do
        local z = raw[3]
        if type(z) == "string" and z ~= "" then
            local key = string.lower(z)
            local bucket = byZone[key]
            if not bucket then
                bucket = {}
                byZone[key] = bucket
            end
            bucket[#bucket + 1] = qID
        end
    end
    local prio = Data.META_TAG_PRIORITY
    for _, list in pairs(byZone) do
        table.sort(list, function(aID, bID)
            local a = metaQuests[aID]
            local b = metaQuests[bID]
            local pa = prio[a[1]] or 9
            local pb = prio[b[1]] or 9
            if pa ~= pb then return pa < pb end
            local ap = a[6] and true or false
            local bp = b[6] and true or false
            if ap ~= bp then return ap end
            local la, lb = a[4] or 99, b[4] or 99
            if la ~= lb then return la < lb end
            return aID < bID
        end)
    end
    _metaByZone = byZone
    return byZone
end

local function IsMetaQuestFlaggedDone(questID)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        local ok, done = pcall(C_QuestLog.IsQuestFlaggedCompleted, questID)
        if ok and done then return true end
    elseif IsQuestFlaggedCompleted then
        local ok, done = pcall(IsQuestFlaggedCompleted, questID)
        if ok and done then return true end
    end
    return false
end

local _emptyZoneMeta = { items = {}, remainingItems = {}, total = 0, done = 0, remaining = 0, inLogCount = 0 }

function Data.GetZoneMetaQuests(zoneName, playerFaction, playerClass, countsOnly)
    local canonical = CanonicalizeMetaZone(zoneName)
    if not canonical then return nil end

    local index = _metaByZone or BuildZoneMetaIndex()
    local idList = index[string.lower(canonical)]
    if not idList or #idList == 0 then
        return countsOnly and nil or _emptyZoneMeta
    end

    local pSide = NormalizeFactionSide(playerFaction)
    local pCls = (type(playerClass) == "string" and playerClass ~= "") and string.upper(playerClass) or nil

    local metaQuests = Data.MetaQuests or {}
    local eligible = not countsOnly and {} or nil
    local remainingItems = not countsOnly and {} or nil
    local totalCount, doneCount, inLogCount = 0, 0, 0
    local getLogIdx = (not countsOnly) and addon.Utils and addon.Utils.GetQuestLogIndex

    for _, qID in ipairs(idList) do
        local raw = metaQuests[qID]
        if raw then
            local side = raw[5] or "B"
            local reqClass = raw[7]
            local sideOk = (not pSide or pSide == "B" or side == "B" or side == pSide)
            local classOk = (not reqClass or not pCls or reqClass == pCls)
            if sideOk and classOk then
                totalCount = totalCount + 1
                local done = IsMetaQuestFlaggedDone(qID)
                if done then
                    doneCount = doneCount + 1
                elseif not countsOnly then
                    local inLog = (getLogIdx and getLogIdx(qID) ~= nil) or false
                    if inLog then inLogCount = inLogCount + 1 end
                    local item = BuildMetaEntry(qID, raw[1], raw[2], raw[3], raw[4], side, raw[6], reqClass, raw[8], false, nil)
                    item.isDone = false
                    item.inLog = inLog
                    eligible[#eligible + 1] = item
                    remainingItems[#remainingItems + 1] = item
                end
                if done and not countsOnly then
                    local item = BuildMetaEntry(qID, raw[1], raw[2], raw[3], raw[4], side, raw[6], reqClass, raw[8], false, nil)
                    item.isDone = true
                    item.inLog = false
                    eligible[#eligible + 1] = item
                end
            end
        end
    end

    return {
        zone = canonical,
        items = eligible,
        remainingItems = remainingItems,
        total = totalCount,
        done = doneCount,
        remaining = totalCount - doneCount,
        inLogCount = inLogCount,
    }
end

-- Memoization cache for computed payoffs
local _payoffMemo = {}

function Data.InvalidatePayoffMemo(questID)
    if questID then
        _payoffMemo[questID] = nil
    else
        wipe(_payoffMemo)
    end
    if Data.InvalidateMetaMemo then
        Data.InvalidateMetaMemo(questID)
    end
end

-- Public API: Retrieve Meta-Knowledge Payoff for any quest (memoized)
function Data.GetQuestPayoff(questID, questTitle)
    local numID = tonumber(questID)
    local targetID = (numID and numID == numID and numID ~= 0 and numID > -math.huge and numID < math.huge) and numID or nil
    if targetID and _payoffMemo[targetID] ~= nil then
        return _payoffMemo[targetID] or nil
    end

    local payoff = nil

    -- 1. Check direct questID lookup in Data.QuestPayoffs
    if targetID and Data.QuestPayoffs[targetID] then
        local entry = Data.QuestPayoffs[targetID]
        payoff = {
            unlock = entry.unlock,
            reward = entry.reward,
            chain = entry.chain,
            tip = entry.tip,
            note = entry.note,
            origin = entry.origin,
            summary = entry.summary,
            isKeyUnlock = entry.isKeyUnlock or false,
        }
    end

    -- 2. Check title lookup in Data.QuestPayoffsByTitle
    local rawTitle = (type(questTitle) == "string" and questTitle ~= "") and questTitle or nil
    if not rawTitle and targetID then
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
                tip = entry.tip,
                note = entry.note,
                origin = entry.origin,
                summary = entry.summary,
                isKeyUnlock = entry.isKeyUnlock or false,
            }
        end
    end

    if not payoff and targetID and Data.GetForeverCatalogPayoff then
        payoff = Data.GetForeverCatalogPayoff(targetID)
    end

    -- 3. Dynamic Auto-Detector: Scans rewards, bags, keys, and keywords for unlisted/custom quests
    local detectedUnlock = nil
    local detectedReward = nil
    local detectedChain = nil
    local detectedNote = nil
    local detectedOrigin = nil
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
        if string.find(cleanTitle, "^wanted") or string.find(cleanTitle, "bounty") then
            detectedOrigin = "Wanted Poster / Bounty"
            isKeyUnlock = true
        elseif string.find(cleanTitle, "beacon") or string.find(cleanTitle, "letter") or
               string.find(cleanTitle, "scroll") or string.find(cleanTitle, "riddle") or
               string.find(cleanTitle, "parchment") or string.find(cleanTitle, "bottle") or
               string.find(cleanTitle, "shard") or string.find(cleanTitle, "horn") or
               string.find(cleanTitle, "map") or string.find(cleanTitle, "globe") or
               string.find(cleanTitle, "ledger") or string.find(cleanTitle, "flute") or
               string.find(cleanTitle, "hide") or string.find(cleanTitle, "scarab") or
               string.find(cleanTitle, "scourgestone") then
            detectedOrigin = "Hidden Item Drop / Secret"
        end
    end

    -- Detect WoW Forever Custom Content (Riverglades & Zephras Isle)
    if (not targetID or targetID >= 90000) and C_Map and C_Map.GetBestMapForUnit then
        local ok, currentMap = pcall(C_Map.GetBestMapForUnit, "player")
        if ok and currentMap then
            if currentMap == 2548 then
                detectedNote = detectedNote or "WoW Forever Custom Content (Riverglades)"
            elseif currentMap == 2521 then
                detectedNote = detectedNote or "WoW Forever Custom Content (Zephras Isle)"
            end
        end
    end

    -- Merge auto-detected attributes if not already present
    if not payoff and (detectedUnlock or detectedReward or detectedChain or detectedNote or detectedOrigin) then
        payoff = {}
    end

    -- 4. Query dedicated Quest Tips & Sourcing Guide
    local questTip = Data.GetQuestTip and Data.GetQuestTip(targetID, rawTitle)
    if questTip and questTip ~= "" then
        if not payoff then payoff = {} end
        payoff.tip = payoff.tip or questTip
    end

    if payoff then
        payoff.unlock = payoff.unlock or detectedUnlock
        payoff.reward = payoff.reward or detectedReward
        payoff.chain = payoff.chain or detectedChain
        payoff.note = payoff.note or detectedNote
        payoff.origin = payoff.origin or detectedOrigin
        if isKeyUnlock then payoff.isKeyUnlock = true end

        -- Build concise summary if missing
        if not payoff.summary then
            local parts = {}
            if payoff.origin then table.insert(parts, payoff.origin) end
            if payoff.unlock then table.insert(parts, payoff.unlock) end
            if payoff.reward then table.insert(parts, payoff.reward) end
            if #parts == 0 and payoff.chain then table.insert(parts, payoff.chain) end
            if #parts == 0 and payoff.tip then table.insert(parts, payoff.tip) end
            if #parts > 0 then
                payoff.summary = table.concat(parts, " • ")
            end
        end
    end

    if targetID and targetID > 0 then
        _payoffMemo[targetID] = payoff or false
    end

    return payoff
end

-- Initialize the index
Data.BuildChainIndex()
