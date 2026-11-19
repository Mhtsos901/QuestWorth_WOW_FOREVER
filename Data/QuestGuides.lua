--[[
    WorthIt / QuestWorth - Data/QuestGuides.lua
    Structured multi-step quest prerequisite & item-dependency guide database.
    Resolves "Need Item/Step A before you can obtain Final Objective B" across
    Classic & WoW Forever open-world zones, crafting writs, camping, keys,
    summons, and dungeons.
]]

local addonName, addon = ...
addon.Data = addon.Data or {}
local Data = addon.Data
Data.QuestGuides = Data.QuestGuides or {}
Data.QuestGuidesByTitle = Data.QuestGuidesByTitle or {}
Data.ItemDependencies = Data.ItemDependencies or {}

local function CleanKey(str)
    if not str or str == "" then return "" end
    local s = tostring(str)
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "|T.-|t", "")
    s = string.gsub(s, "^%s*%[%d+%+?%]%s*", "")
    s = string.gsub(s, "%s*%(%s*[Dd]aily%s*%)%s*$", "")
    s = string.gsub(s, "%s*%(%s*[Rr]epeatable%s*%)%s*$", "")
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")
    return string.lower(s)
end

-- Helper for live item count in player bags/bank
local function SafeGetItemCount(itemID, itemName)
    local fn = (C_Item and C_Item.GetItemCount) or GetItemCount
    if not fn then return 0 end
    if itemID and type(itemID) == "number" and itemID > 0 then
        local ok, cnt = pcall(fn, itemID)
        if ok and type(cnt) == "number" then return cnt end
    end
    if itemName and type(itemName) == "string" and itemName ~= "" then
        local ok, cnt = pcall(fn, itemName)
        if ok and type(cnt) == "number" then return cnt end
    end
    return 0
end

local function ParseStepRequiredCount(text)
    if not text or text == "" then return 1 end
    local n = string.match(text, "(%d+)x%s*%[")
        or string.match(text, "%((%d+)%s+needed%)")
        or string.match(text, "Need%s+x(%d+)")
    local num = tonumber(n)
    return (num and num >= 1) and num or 1
end

function Data.GetStepBagProgress(step)
    if not step or (not step.itemID and not step.itemName) then
        return 0, 0, false
    end
    local have = SafeGetItemCount(step.itemID, step.itemName)
    local need = ParseStepRequiredCount(step.text)
    return have, need, (have >= need)
end

-- =========================================================================
-- 1. Universal Item Dependency & Recipe Knowledge Base
--    Keyed by lowercased item name -> explains what precursor item/reagents/
--    action you need BEFORE you can obtain/use this item for a quest.
-- =========================================================================
local ITEM_DEPS = {
    -- Multi-Step Precursor / Summon / Key / Container Chains
    ["purified kor gem"] = {
        id = 7083,
        name = "Purified Kor Gem",
        kind = "quest",
        leadsTo = "The Test of Righteousness / A Moon-Kissed Blade",
        source = "Quest 'Seeking the Kor Gem' (Auberdine / Zoram'gar)",
        before = "Loot [Corrupted Kor Gem] from Blackfathom Tide Priestesses & Oracles outside BFD entrance, then turn in 'Seeking the Kor Gem'.",
    },
    ["corrupted kor gem"] = {
        name = "Corrupted Kor Gem",
        kind = "drop",
        leadsTo = "Purified Kor Gem",
        source = "Blackfathom Tide Priestesses & Oracles outside Blackfathom Deeps (Ashenvale)",
        before = "Turn in to Thundris Windweaver (Auberdine, Alliance) or Ulric Frostveil (Zoram'gar, Horde) on 'Seeking the Kor Gem' to receive [Purified Kor Gem].",
    },
    ["morrowgrain"] = {
        id = 11040,
        name = "Morrowgrain",
        kind = "container",
        source = "Grown from [Evergreen Pouch] + 2x [Un'Goro Soil]",
        before = "Accept quest to receive [Evergreen Pouch], gather [Un'Goro Soil] piles around Un'Goro Crater, and right-click the Pouch every 10m -> spawns [Tharlendris Seeds] -> Morrowgrain.",
    },
    ["evergreen pouch"] = {
        id = 11020,
        name = "Evergreen Pouch",
        kind = "container",
        leadsTo = "Morrowgrain",
        source = "Provided when starting Morrowgrain Research (Darnassus / Thunder Bluff)",
        before = "Keep in bags with [Un'Goro Soil] (2x per use, 10m cooldown) and right-click to grow [Morrowgrain].",
    },
    ["un'goro soil"] = {
        id = 11018,
        name = "Un'Goro Soil",
        kind = "gather",
        leadsTo = "Morrowgrain",
        source = "Un'Goro Dirt Piles & Un'Goro Crater mobs",
        before = "Consumed (2x per use) inside [Evergreen Pouch] (10m CD) to produce [Tharlendris Seeds] -> [Morrowgrain].",
    },
    ["mallet of zul'farrak"] = {
        id = 9240,
        name = "Mallet of Zul'Farrak",
        kind = "use",
        leadsTo = "Gahz'rilla Summon (Zul'Farrak)",
        source = "Sacred Mallet forged at Jintha'Alor Altar (The Hinterlands)",
        before = "Step 1: Kill Qiaga the Keeper atop Altar of Zul (Hinterlands) for [Sacred Mallet]. Step 2: Fight to top altar of Jintha'Alor (Hinterlands) and use it -> [Mallet of Zul'Farrak].",
    },
    ["sacred mallet"] = {
        id = 9241,
        name = "Sacred Mallet",
        kind = "drop",
        leadsTo = "Mallet of Zul'Farrak",
        source = "Qiaga the Keeper atop Altar of Zul (The Hinterlands)",
        before = "Bring to the very top altar of Jintha'Alor (The Hinterlands) and click/use at the Sacred Altar to forge [Mallet of Zul'Farrak].",
    },
    ["scepter of celebras"] = {
        id = 17191,
        name = "Scepter of Celebras",
        kind = "quest",
        leadsTo = "Maraudon Inner Shortcut Portal",
        source = "Quest 'The Scepter of Celebras' inside Maraudon",
        before = "Collect [Celebras's Rod] (Celebras the Cursed / Vyletongue wing) + [Celebras's Diamond] (Landslide / Noxxion side), defeat Celebras, then speak to Celebras the Redeemed.",
    },
    ["shadowforge key"] = {
        id = 11000,
        name = "Shadowforge Key",
        kind = "quest",
        leadsTo = "Blackrock Depths Interior Doors & Arena Shortcut",
        source = "Quest 'Dark Iron Legacy' (Franclorn Forgewright)",
        before = "Step 1: Die & enter ghost form in Blackrock Mountain center (29.0, 28.9) to talk to Franclorn Forgewright. Step 2: Kill Fineous Darkvire in BRD for [Ironfel]. Step 3: Place Ironfel on Franclorn's statue.",
    },
    ["unadorned seal of ascension"] = {
        id = 12219,
        name = "Unadorned Seal of Ascension",
        kind = "drop",
        leadsTo = "Seal of Ascension (UBRS Key)",
        source = "Blackrock Spire mobs (Lower Spire)",
        before = "Combine with 3 boss Gems (Omokk, Vosh'gajin, Voone) -> weaken Emberstrife in Dustwallow & use Orb of Draconic Energy -> Vaelan in LBRS.",
    },
    ["seal of ascension"] = {
        id = 12344,
        name = "Seal of Ascension",
        kind = "quest",
        leadsTo = "Upper Blackrock Spire (UBRS) Door",
        source = "Quest 'Seal of Ascension' (Vaelan in LBRS)",
        before = "Step 1: Loot [Unadorned Seal of Ascension] (LBRS). Step 2: Gems from Omokk, Vosh'gajin, Voone. Step 3: Forge at Emberstrife (Dustwallow Marsh). Step 4: Return to Vaelan in LBRS.",
    },
    ["white punch card"] = {
        id = 9279,
        name = "White Punch Card",
        kind = "drop",
        leadsTo = "Yellow -> Blue -> Red -> Prismatic Punch Card",
        source = "Dark Iron / Leper mobs outside Gnomeregan",
        before = "Use at Matrix Punchograph 3005-A (outside Gnomeregan Workshop/Train Depot) -> [Yellow Punch Card] -> 3005-B -> 3005-C -> 3005-D -> [Prismatic Punch Card].",
    },
    ["yellow punch card"] = {
        id = 9280,
        name = "Yellow Punch Card",
        kind = "object",
        leadsTo = "Blue -> Red -> Prismatic Punch Card",
        source = "Matrix Punchograph 3005-A (outside Gnomeregan)",
        before = "Insert into Matrix Punchograph 3005-B in The Dormitory inside Gnomeregan to receive [Blue Punch Card].",
    },
    ["blue punch card"] = {
        id = 9282,
        name = "Blue Punch Card",
        kind = "object",
        leadsTo = "Red -> Prismatic Punch Card",
        source = "Matrix Punchograph 3005-B (Dormitory, Gnomeregan)",
        before = "Insert into Matrix Punchograph 3005-C on Electrocutioner 6000's platform inside Gnomeregan to receive [Red Punch Card].",
    },
    ["red punch card"] = {
        id = 9281,
        name = "Red Punch Card",
        kind = "object",
        leadsTo = "Prismatic Punch Card",
        source = "Matrix Punchograph 3005-C (Electrocutioner 6000, Gnomeregan)",
        before = "Insert into Matrix Punchograph 3005-D in Lower Engineering Labs (west side after elevator) to receive [Prismatic Punch Card].",
    },
    ["prismatic punch card"] = {
        id = 9316,
        name = "Prismatic Punch Card",
        kind = "object",
        leadsTo = "Data Rescue / Rig Wars",
        source = "Matrix Punchograph 3005-D (Lower Engineering Labs, Gnomeregan)",
        before = "Starts from [White] -> 3005-A [Yellow] -> 3005-B [Blue] -> 3005-C [Red] -> 3005-D [Prismatic]. Turn in to Master Mechanic Castpipe in Ironforge.",
    },
    ["cuergo's treasure map"] = {
        id = 9275,
        name = "Cuergo's Treasure Map",
        kind = "combine",
        leadsTo = "Cuergo's Gold (Tanaris)",
        source = "Combine Upper + Middle + Lower Map Fragments from Lost Rigger Cove pirates",
        before = "Right-click to start 'Cuergo's Gold', then sail to Land's End Beach mast (southern Tanaris) and click flag -> kill spawned pirates for [Cuergo's Key] -> open chest.",
    },
    ["upper map fragment"] = {
        name = "Upper Map Fragment",
        kind = "drop",
        leadsTo = "Cuergo's Treasure Map",
        source = "Southsea Pirates / Pirate's Footlocker in Lost Rigger Cove (Tanaris)",
        before = "Collect Upper + Middle + Lower Map Fragments and right-click to combine into [Cuergo's Treasure Map].",
    },
    ["middle map fragment"] = {
        name = "Middle Map Fragment",
        kind = "drop",
        leadsTo = "Cuergo's Treasure Map",
        source = "Southsea Pirates / Pirate's Footlocker in Lost Rigger Cove (Tanaris)",
        before = "Collect Upper + Middle + Lower Map Fragments and right-click to combine into [Cuergo's Treasure Map].",
    },
    ["lower map fragment"] = {
        name = "Lower Map Fragment",
        kind = "drop",
        leadsTo = "Cuergo's Treasure Map",
        source = "Southsea Pirates / Pirate's Footlocker in Lost Rigger Cove (Tanaris)",
        before = "Collect Upper + Middle + Lower Map Fragments and right-click to combine into [Cuergo's Treasure Map].",
    },
    ["red power crystal"] = {
        name = "Red Power Crystal",
        kind = "gather",
        leadsTo = "Western / Eastern / Northern Crystal Pylon",
        source = "Crystal formations across Un'Goro Crater",
        before = "Used in groups of 7x at Un'Goro Crystal Pylons (N 56,12 / E 77,49 / W 23,59) after completing 'Making Sense of It'.",
    },
    ["blue power crystal"] = {
        name = "Blue Power Crystal",
        kind = "gather",
        leadsTo = "Western / Eastern / Northern Crystal Pylon",
        source = "Crystal formations across Un'Goro Crater",
        before = "Used in groups of 7x at Un'Goro Crystal Pylons (N 56,12 / E 77,49 / W 23,59) after completing 'Making Sense of It'.",
    },
    ["green power crystal"] = {
        name = "Green Power Crystal",
        kind = "gather",
        leadsTo = "Western / Eastern / Northern Crystal Pylon",
        source = "Crystal formations across Un'Goro Crater",
        before = "Used in groups of 7x at Un'Goro Crystal Pylons (N 56,12 / E 77,49 / W 23,59) after completing 'Making Sense of It'.",
    },
    ["yellow power crystal"] = {
        name = "Yellow Power Crystal",
        kind = "gather",
        leadsTo = "Western / Eastern / Northern Crystal Pylon",
        source = "Crystal formations across Un'Goro Crater",
        before = "Used in groups of 7x at Un'Goro Crystal Pylons (N 56,12 / E 77,49 / W 23,59) after completing 'Making Sense of It'.",
    },
    ["silver totem of aquementas"] = {
        id = 11522,
        name = "Silver Totem of Aquementas",
        kind = "use",
        leadsTo = "It's Dangerous to Go Alone (Blazerunner)",
        source = "Quest 'Aquementas' (Summon Aquementas at Tanaris Stone Circle using Book of Aquor)",
        before = "Equip/use Silver Totem of Aquementas to strip Blazerunner's immunity shield at Fire Plume Ridge (Un'Goro).",
    },
    ["book of aquor"] = {
        id = 11169,
        name = "Book of Aquor",
        kind = "use",
        leadsTo = "Silver Totem of Aquementas",
        source = "Provided during 'Aquementas' (Felwood -> Tanaris)",
        before = "Read/use at the Stone Circle in southern Tanaris (70, 49) to summon Aquementas and receive [Silver Totem of Aquementas].",
    },
    ["cenarion plant salve"] = {
        id = 11511,
        name = "Cenarion Plant Salve",
        kind = "use",
        leadsTo = "Cleansed Songflower / Windblossom Berries / Whipper Root",
        source = "Quest turn-ins at Jaedenar / Felwood Emerald Sanctuary (with Cenarion Beacon)",
        before = "First get [Cenarion Beacon] in Felwood -> farm Corrupted Soul Shards / Felwood reagents -> trade for [Cenarion Plant Salve] -> cleanse corrupted plants.",
    },
    ["abyssal crest"] = {
        id = 20513,
        name = "Abyssal Crest",
        kind = "summon",
        leadsTo = "Twilight Cultist Medallion of Station -> Abyssal Dukes",
        source = "Abyssal Templars summoned at Lesser Wind Stones (Silithus)",
        before = "Wear full 3-piece Twilight Cultist set (Robe + Cowl + Mantle from Silithus Twilight camps) and click a Lesser Wind Stone.",
    },
    ["abyssal signet"] = {
        id = 20514,
        name = "Abyssal Signet",
        kind = "summon",
        leadsTo = "Twilight Cultist Ring of Lordship -> Abyssal Lords",
        source = "Abyssal Dukes summoned at Medium Wind Stones (Silithus)",
        before = "Requires 3-piece Twilight Cultist set + [Twilight Cultist Medallion of Station] (quest needs Friendly CC + 3x Abyssal Crest + 1x Large Brilliant Shard).",
    },
    ["abyssal scepter"] = {
        id = 20515,
        name = "Abyssal Scepter",
        kind = "summon",
        source = "Abyssal Lords summoned at Greater Wind Stones (Silithus)",
        before = "Requires 3-piece Twilight Cultist set + Medallion of Station + [Twilight Cultist Ring of Lordship] (Revered CC + 3x Abyssal Signet + 5x Large Brilliant Shard).",
    },
    ["twilight cultist cowl"] = {
        id = 20408,
        name = "Twilight Cultist Cowl",
        kind = "drop",
        leadsTo = "Wind Stone Summons (Abyssal Crest/Signet/Scepter)",
        source = "Twilight's Hammer Cultists in Silithus camps",
        before = "Combine with Twilight Cultist Robe + Mantle (3 pieces total) to activate Lesser Wind Stones.",
    },
    ["twilight cultist robe"] = {
        id = 20407,
        name = "Twilight Cultist Robe",
        kind = "drop",
        leadsTo = "Wind Stone Summons",
        source = "Twilight's Hammer Cultists in Silithus camps",
        before = "Combine with Twilight Cultist Cowl + Mantle (3 pieces total) to activate Lesser Wind Stones.",
    },
    ["twilight cultist mantle"] = {
        id = 20406,
        name = "Twilight Cultist Mantle",
        kind = "drop",
        leadsTo = "Wind Stone Summons",
        source = "Twilight's Hammer Cultists in Silithus camps",
        before = "Combine with Twilight Cultist Cowl + Robe (3 pieces total) to activate Lesser Wind Stones.",
    },
    ["coated cerulean vial"] = {
        name = "Coated Cerulean Vial",
        kind = "use",
        source = "Provided during Vyletongue Corruption (Maraudon)",
        before = "Step 1: Fill vial at the Orange Crystal Pool in outer Maraudon caves. Step 2: Use filled vial on Vylestem Vines inside Orange side and kill Noxxious Scions.",
    },
    ["egan's blaster"] = {
        id = 13289,
        name = "Egan's Blaster",
        kind = "use",
        source = "Provided by Egan outside Stratholme Undead Gate ('The Restless Souls')",
        before = "Use Egan's Blaster on Ghostly Citizens BEFORE killing them inside Stratholme, then collect the freed spirits.",
    },
    ["morbent's bane"] = {
        id = 7297,
        name = "Morbent's Bane",
        kind = "use",
        source = "Reward from 'Armed and Ready' (Grimand Elmore, Stormwind)",
        before = "Target Morbent Fel (house north of Raven Hill, Duskwood) and USE/equip Morbent's Bane to strip his invulnerability shield.",
    },
    ["soulbound keepsake"] = {
        id = 13562,
        name = "Soulbound Keepsake",
        kind = "use",
        source = "Provided during 'The Human Condition' / Ras Frostwhisper chain (Scholomance)",
        before = "Fight Ras Frostwhisper in Scholomance and USE Soulbound Keepsake on him to turn him mortal before killing him.",
    },
    ["medallion of faith"] = {
        id = 12845,
        name = "Medallion of Faith",
        kind = "object",
        source = "Malor's Strongbox inside Scarlet Bastion (Stratholme Live)",
        before = "Give Medallion of Faith to Aurius in the Stratholme Undead Chapel BEFORE engaging Baron Rivendare, then talk to Aurius after the kill.",
    },
    ["gordok shackle key"] = {
        id = 18250,
        name = "Gordok Shackle Key",
        kind = "drop",
        source = "Gordok Guards / Ogres in Dire Maul North",
        before = "Bring to Knot Thimblejack in Dire Maul North to free him and unlock Knot's Cache. (Do Ogre Suit first before freeing him!)",
    },
    ["gordok ogre suit"] = {
        id = 18258,
        name = "Gordok Ogre Suit",
        kind = "quest",
        source = "Crafted via Knot Thimblejack (DM North) or Tailoring/Leatherworking",
        before = "Requires 4x [Bolt of Runecloth], 8x [Rugged Leather], 2x [Rune Thread], 1x [Ogre Tannin] (from upper basket past Knot). Do BEFORE freeing Knot!",
    },
    ["ogre tannin"] = {
        id = 18240,
        name = "Ogre Tannin",
        kind = "object",
        leadsTo = "Gordok Ogre Suit",
        source = "Ogre Tannin Basket on upper platform beyond Knot Thimblejack (DM North)",
        before = "Bring 1x Ogre Tannin + 4x Bolt of Runecloth + 8x Rugged Leather + 2x Rune Thread to Knot Thimblejack.",
    },
    ["special chicken feed"] = {
        id = 11109,
        name = "Special Chicken Feed",
        kind = "vendor",
        leadsTo = "CLUCK! (Westfall Chicken Pet)",
        source = "Sold by Farmer Saldean (Westfall) or William Maclure (Elwynn)",
        before = "Step 1: Buy Special Chicken Feed. Step 2: Target any Westfall Chicken and spam /chicken until it turns friendly and offers 'CLUCK!'.",
    },
    ["empty canteen"] = {
        id = 11804,
        name = "Empty Canteen",
        kind = "use",
        source = "Provided during 'A Little Slime Goes a Long Way'",
        before = "Defeat Primal / Muculent Oozes (Felwood / Un'Goro), target their corpse, and USE the Empty Canteen from your bags.",
    },
    ["stratholme holy water"] = {
        id = 13180,
        name = "Stratholme Holy Water",
        kind = "object",
        source = "Supply Crates scattered in Stratholme streets (careful: some spawn Plagued insects)",
        before = "Open Supply Crates on the ground around Stratholme (also damages Undead / helps clean Plaza).",
    },
    ["healthy dragon scale"] = {
        id = 13920,
        name = "Healthy Dragon Scale",
        kind = "drop",
        source = "Plagued Hatchlings inside Scholomance",
        before = "ONLY starts dropping after turning in the initial 'Plagued Hatchlings' quest to Betina Bigglezink!",
    },

    -- Crafted Quest & Craftsman's Writ Items (Exact Verified Classic Recipes)
    ["bronze tube"] = {
        id = 4371,
        name = "Bronze Tube",
        kind = "craft",
        profession = "Engineering (105)",
        source = "Crafted (Engineering Trainer) OR limited vendor / AH",
        before = "Engineering (105): 2x [Bronze Bar] + 1x [Weak Flux]. Also sold by Gearcutter Cogspinner (SW/Dun Morogh), Neal Allen (Menethil), Gnaz Blunderflame (STV), Sovik (Orgrimmar).",
    },
    ["frost oil"] = {
        id = 3829,
        name = "Frost Oil",
        kind = "craft",
        profession = "Alchemy (200)",
        source = "Alchemy (200) — Recipe sold by Bro'kin (Alterac Ruins 38.4, 38.8) or AH",
        before = "Alchemy (200): 4x [Khadgar's Whisker] + 2x [Wintersbite] + 1x [Leaded Vial]. Needed for Badlands ('Coolant Heads Prevail').",
    },
    ["gyrochronatom"] = {
        id = 4389,
        name = "Gyrochronatom",
        kind = "craft",
        profession = "Engineering (170)",
        source = "Engineering (170, Trainer) or Limited Vendors / AH",
        before = "Engineering (170): 1x [Iron Bar] + 1x [Gold Power Core]. Needed for Badlands ('Gyro... What?').",
    },
    ["patterned bronze bracers"] = {
        id = 2868,
        name = "Patterned Bronze Bracers",
        kind = "craft",
        profession = "Blacksmithing (120)",
        source = "Blacksmithing (120, Trainer) or AH",
        before = "Blacksmithing (120): 5x [Bronze Bar] + 2x [Coarse Grinding Stone]. Needed for Badlands ('Stone Is Better than Cloth').",
    },
    ["mithril casing"] = {
        id = 10561,
        name = "Mithril Casing",
        kind = "craft",
        profession = "Engineering (215)",
        source = "Engineering (215, Trainer) or AH",
        before = "Engineering (215): 3x [Mithril Bar]. Bring BEFORE talking to Karna Remick / heading to A-Me 01 in Un'Goro!",
    },
    ["healing potion"] = {
        id = 929,
        name = "Healing Potion",
        kind = "craft",
        profession = "Alchemy (110)",
        source = "Alchemy (110) / World Drop / AH",
        before = "Alchemy (110): 1x [Bruiseweed] + 1x [Briarthorn] + 1x [Leaded Vial]. Needed for 'Liquid Stone' in Badlands.",
    },
    ["lesser invisibility potion"] = {
        id = 3823,
        name = "Lesser Invisibility Potion",
        kind = "craft",
        profession = "Alchemy (165)",
        source = "Alchemy (165, Trainer) or AH",
        before = "Alchemy (165): 1x [Wild Steelbloom] + 1x [Fadeleaf] + 1x [Leaded Vial]. Needed for 'Liquid Stone' in Badlands.",
    },
    ["elixir of ogre's strength"] = {
        id = 3391,
        name = "Elixir of Ogre's Strength",
        kind = "craft",
        profession = "Alchemy (150)",
        source = "Alchemy (150, World drop in Duskwood/Hillsbrad) or AH",
        before = "Alchemy (150): 1x [Earthroot] + 1x [Kingsblood] + 1x [Leaded Vial].",
    },
    ["shadow protection potion"] = {
        id = 6048,
        name = "Shadow Protection Potion",
        kind = "craft",
        profession = "Alchemy (135)",
        source = "Alchemy (135) — Recipe sold by Harklan Moongrove (Ashenvale) / Christoph Jeffcoat (Tarren Mill)",
        before = "Alchemy (135): 1x [Grave Moss] + 1x [Kingsblood] + 1x [Leaded Vial].",
    },
    ["free action potion"] = {
        id = 5634,
        name = "Free Action Potion",
        kind = "craft",
        profession = "Alchemy (150)",
        source = "Alchemy (150) — Recipe sold by Soolie Berryfizz (IF), Ulthir (Darnassus), Kor'geld (Org)",
        before = "Alchemy (150): 2x [Blackmouth Oil] + 1x [Stranglekelp] + 1x [Leaded Vial].",
    },
    ["frost protection potion"] = {
        id = 6050,
        name = "Frost Protection Potion",
        kind = "craft",
        profession = "Alchemy (190)",
        source = "Alchemy (190) — Recipe sold by Drovnar Strongbrew (Arathi) / Glyx Brewright (Booty Bay)",
        before = "Alchemy (190): 1x [Wintersbite] + 1x [Goldthorn] + 1x [Leaded Vial].",
    },
    ["nature protection potion"] = {
        id = 6052,
        name = "Nature Protection Potion",
        kind = "craft",
        profession = "Alchemy (190)",
        source = "Alchemy (190) — Recipe sold by Alchemist Pestlezugg (Tanaris), Bronk/Logannas (Feralas), Glyx (BB)",
        before = "Alchemy (190): 1x [Liferoot] + 1x [Stranglekelp] + 1x [Leaded Vial].",
    },
    ["greater fire protection potion"] = {
        id = 13457,
        name = "Greater Fire Protection Potion",
        kind = "craft",
        profession = "Alchemy (290)",
        source = "Alchemy (290) — Recipe drops from Firebrand Invokers/Pyromancers in LBRS/UBRS",
        before = "Alchemy (290): 1x [Elemental Fire] + 1x [Dreamfoil] + 1x [Crystal Vial].",
    },
    ["gift of arthas"] = {
        id = 9088,
        name = "Gift of Arthas",
        kind = "craft",
        profession = "Alchemy (240)",
        source = "Alchemy (240) — Recipe drops from WPL Slavering Ghouls & Skeletal Flayers",
        before = "Alchemy (240): 1x [Arthas' Tears] + 1x [Blindweed] + 1x [Crystal Vial].",
    },
    ["limited invulnerability potion"] = {
        id = 3387,
        name = "Limited Invulnerability Potion",
        kind = "craft",
        profession = "Alchemy (250)",
        source = "Alchemy (250) — Rare world drop recipe (lvl 45-55 zones)",
        before = "Alchemy (250): 2x [Blindweed] + 1x [Ghost Mushroom] + 1x [Crystal Vial].",
    },
    ["dreamless sleep potion"] = {
        id = 12190,
        name = "Dreamless Sleep Potion",
        kind = "craft",
        profession = "Alchemy (245)",
        source = "Alchemy (245, Trainer)",
        before = "Alchemy (245): 3x [Purple Lotus] + 1x [Crystal Vial].",
    },
    ["major rejuvenation potion"] = {
        id = 18253,
        name = "Major Rejuvenation Potion",
        kind = "craft",
        profession = "Alchemy (300)",
        source = "Alchemy (300) — Recipe drops from Molten Core bosses",
        before = "Alchemy (300): 1x [Heart of the Wild] + 4x [Golden Sansam] + 4x [Dreamfoil] + 1x [Crystal Vial].",
    },
    ["ornate spyglass"] = {
        id = 5507,
        name = "Ornate Spyglass",
        kind = "craft",
        profession = "Engineering (135)",
        source = "Engineering (135, Trainer) or AH",
        before = "Engineering (135): 2x [Bronze Tube] + 2x [Whirring Bronze Gizmo] + 1x [Copper Modulator] + 1x [Moss Agate].",
    },
    ["explosive sheep"] = {
        id = 4384,
        name = "Explosive Sheep",
        kind = "craft",
        profession = "Engineering (150)",
        source = "Engineering (150, Trainer) or AH",
        before = "Engineering (150): 1x [Bronze Framework] + 1x [Whirring Bronze Gizmo] + 2x [Heavy Blasting Powder] + 2x [Wool Cloth].",
    },
    ["moonsight rifle"] = {
        id = 4383,
        name = "Moonsight Rifle",
        kind = "craft",
        profession = "Engineering (145)",
        source = "Engineering (145) — World Drop Schematic or AH",
        before = "Engineering (145): 3x [Bronze Tube] + 3x [Whirring Bronze Gizmo] + 1x [Heavy Stock] + 2x [Lesser Moonstone].",
    },
    ["minor recombobulator"] = {
        id = 4381,
        name = "Minor Recombobulator",
        kind = "craft",
        profession = "Engineering (140)",
        source = "Engineering (140) — Schematic sold by Fradd Swiftgear (Wetlands) / Gnomeregan",
        before = "Engineering (140): 1x [Bronze Tube] + 2x [Whirring Bronze Gizmo] + 2x [Medium Leather] + 1x [Moss Agate].",
    },
    ["gnomish universal remote"] = {
        id = 7506,
        name = "Gnomish Universal Remote",
        kind = "craft",
        profession = "Engineering (125)",
        source = "Engineering (125) — Schematic sold by Gearcutter Cogspinner (Dun Morogh) / Jinky (1k Needles)",
        before = "Engineering (125): 6x [Bronze Bar] + 1x [Whirring Bronze Gizmo] + 2x [Flask of Oil] + 1x [Tigerseye] + 1x [Malachite].",
    },
    ["sniper scope"] = {
        id = 10548,
        name = "Sniper Scope",
        kind = "craft",
        profession = "Engineering (240)",
        source = "Engineering (240, World drop schematic) or AH",
        before = "Engineering (240): 1x [Mithril Tube] + 1x [Star Ruby] + 2x [Truesilver Bar].",
    },
    ["goblin land mine"] = {
        id = 4395,
        name = "Goblin Land Mine",
        kind = "craft",
        profession = "Engineering (195)",
        source = "Engineering (195) — Goblin/Trainer schematic or AH",
        before = "Engineering (195): 3x [Heavy Blasting Powder] + 2x [Iron Bar] + 1x [Gyrochronatom].",
    },
    ["mithril frag bomb"] = {
        id = 10514,
        name = "Mithril Frag Bomb",
        kind = "craft",
        profession = "Engineering (215)",
        source = "Engineering (215, Trainer) or AH",
        before = "Engineering (215): 1x [Mithril Casing] + 1x [Unstable Trigger] + 1x [Solid Blasting Powder].",
    },
    ["unstable trigger"] = {
        id = 10560,
        name = "Unstable Trigger",
        kind = "craft",
        profession = "Engineering (200)",
        source = "Engineering (200, Trainer) or AH",
        before = "Engineering (200): 1x [Mithril Bar] + 1x [Mageweave Cloth] + 1x [Solid Blasting Powder].",
    },
    ["truesilver transformer"] = {
        id = 18631,
        name = "Truesilver Transformer",
        kind = "craft",
        profession = "Engineering (260)",
        source = "Engineering (260, Trainer) or AH",
        before = "Engineering (260): 2x [Truesilver Bar] + 2x [Elemental Earth] + 1x [Elemental Air].",
    },
    ["tranquil mechanical yeti"] = {
        id = 15778,
        name = "Tranquil Mechanical Yeti",
        kind = "craft",
        profession = "Engineering (300)",
        source = "Engineering (300, Winterspring trainer Umi Rumplesnicker) or AH",
        before = "Engineering (300): 1x [Cured Rugged Hide] + 4x [Thorium Widget] + 2x [Truesilver Transformer] + 1x [Gold Power Core] + 2x [Globe of Water].",
    },
    ["golden rod"] = {
        id = 11128,
        name = "Golden Rod",
        kind = "craft",
        profession = "Blacksmithing (150)",
        source = "Blacksmithing (150, Trainer) or AH",
        before = "Blacksmithing (150): 1x [Gold Bar] + 2x [Coarse Grinding Stone].",
    },
    ["iridescent hammer"] = {
        id = 5541,
        name = "Iridescent Hammer",
        kind = "craft",
        profession = "Blacksmithing (145)",
        source = "Blacksmithing (145) — World Drop Plans or AH",
        before = "Blacksmithing (145): 10x [Bronze Bar] + 1x [Strong Flux] + 1x [Iridescent Pearl] + 2x [Coarse Grinding Stone] + 2x [Medium Leather].",
    },
    ["silver skeleton key"] = {
        id = 15869,
        name = "Silver Skeleton Key",
        kind = "craft",
        profession = "Blacksmithing (100)",
        source = "Blacksmithing (100, Trainer) or AH",
        before = "Blacksmithing (100): 1x [Silver Bar] + 2x [Rough Grinding Stone] (makes 2).",
    },
    ["truesilver rod"] = {
        id = 11144,
        name = "Truesilver Rod",
        kind = "craft",
        profession = "Blacksmithing (200)",
        source = "Blacksmithing (200, Trainer) or AH",
        before = "Blacksmithing (200): 1x [Truesilver Bar] + 1x [Heavy Grinding Stone].",
    },
    ["steel weapon chain"] = {
        id = 6041,
        name = "Steel Weapon Chain",
        kind = "craft",
        profession = "Blacksmithing (165)",
        source = "Blacksmithing (165) — World Drop Plans or AH",
        before = "Blacksmithing (165): 8x [Steel Bar] + 2x [Heavy Grinding Stone] + 4x [Heavy Leather].",
    },
    ["mithril spurs"] = {
        id = 7969,
        name = "Mithril Spurs",
        kind = "craft",
        profession = "Blacksmithing (210)",
        source = "Blacksmithing (210) — World Drop Plans or AH",
        before = "Blacksmithing (210): 4x [Mithril Bar] + 3x [Solid Grinding Stone].",
    },
    ["arcanite skeleton key"] = {
        id = 15872,
        name = "Arcanite Skeleton Key",
        kind = "craft",
        profession = "Blacksmithing (250)",
        source = "Blacksmithing (250, Trainer) or AH",
        before = "Blacksmithing (250): 1x [Arcanite Bar] + 1x [Dense Grinding Stone].",
    },
    ["imperial plate chest"] = {
        id = 12422,
        name = "Imperial Plate Chest",
        kind = "craft",
        profession = "Blacksmithing (275)",
        source = "Blacksmithing (275) — Quest 'Imperial Plate Chest' from Derotain Mudsipper (Tanaris)",
        before = "Blacksmithing (275): 40x [Thorium Bar] + 2x [Star Ruby].",
    },
    ["runecloth bag"] = {
        id = 14046,
        name = "Runecloth Bag",
        kind = "craft",
        profession = "Tailoring (260)",
        source = "Tailoring (260) — Pattern sold by Qia in Everlook (Winterspring)",
        before = "Tailoring (260): 5x [Bolt of Runecloth] + 2x [Rugged Leather] + 1x [Rune Thread].",
    },
    ["soul pouch"] = {
        id = 21340,
        name = "Soul Pouch",
        kind = "craft",
        profession = "Tailoring (260)",
        source = "Tailoring (260) — World Drop Pattern (High-level Undead/Cultists)",
        before = "Tailoring (260): 6x [Bolt of Runecloth] + 4x [Rugged Leather] + 2x [Ichor of Undeath] + 1x [Rune Thread].",
    },
    ["volcanic breastplate"] = {
        id = 15053,
        name = "Volcanic Breastplate",
        kind = "craft",
        profession = "Leatherworking (280)",
        source = "Leatherworking (280) — Pattern drops from Firebrand Grunts in LBRS",
        before = "Leatherworking (280): 8x [Rugged Leather] + 1x [Essence of Fire] + 1x [Essence of Earth] + 1x [Rune Thread].",
    },

    -- Common Vendor Reagents requested in Quests (So players don't farm endlessly!)
    ["soothing spices"] = {
        id = 3713,
        name = "Soothing Spices",
        kind = "vendor",
        source = "Cooking Supplies Vendors in capital cities & inns",
        before = "Bought directly from Cooking Supplies Vendors (not dropped by mobs!). Needed for 'Soothing Turtle Bisque'.",
    },
    ["stormwind seasoning herbs"] = {
        id = 2665,
        name = "Stormwind Seasoning Herbs",
        kind = "vendor",
        source = "Felicia Gump (<Herbalism/Cooking Supplies>, Stormwind Canals 64, 60)",
        before = "Bought directly from Felicia Gump in Stormwind City Canals (64.2, 60.5) for 'Seasoned Wolf Kabobs'.",
    },
    ["mild spices"] = {
        id = 2678,
        name = "Mild Spices",
        kind = "vendor",
        source = "Cooking Supplies & Trade Goods Vendors",
        before = "Purchased from any Cooking Supplies vendor.",
    },
    ["hot spices"] = {
        id = 2692,
        name = "Hot Spices",
        kind = "vendor",
        source = "Cooking Supplies & Trade Goods Vendors",
        before = "Purchased from any Cooking Supplies vendor.",
    },
    ["ice cold milk"] = {
        id = 1179,
        name = "Ice Cold Milk",
        kind = "vendor",
        source = "Innkeepers & Food/Drink Vendors (Lvl 5 Drink)",
        before = "Buy from Innkeeper (do not search mobs!).",
    },
    ["melon juice"] = {
        id = 1205,
        name = "Melon Juice",
        kind = "vendor",
        source = "Innkeepers & Food/Drink Vendors (Lvl 15 Drink)",
        before = "Buy from Innkeeper (do not search mobs!).",
    },
    ["sweet nectar"] = {
        id = 1708,
        name = "Sweet Nectar",
        kind = "vendor",
        source = "Innkeepers & Food/Drink Vendors (Lvl 25 Drink)",
        before = "Buy from Innkeeper.",
    },
    ["morning glory dew"] = {
        id = 8766,
        name = "Morning Glory Dew",
        kind = "vendor",
        source = "Innkeepers & Food/Drink Vendors (Lvl 35 Drink)",
        before = "Buy from Innkeeper.",
    },
    ["moonberry juice"] = {
        id = 1645,
        name = "Moonberry Juice",
        kind = "vendor",
        source = "Innkeepers & Food/Drink Vendors (Lvl 45 Drink)",
        before = "Buy from Innkeeper.",
    },

    -- Attunements, Keys, Dungeon & Class Precursor Items
    ["margol's horn"] = {
        id = 10000,
        name = "Margol's Horn",
        kind = "drop",
        leadsTo = "Key to Searing Gorge (At Last!)",
        source = "Margol the Rager (Lvl 48 Elite in SE Searing Gorge 73.5, 82.3)",
        before = "Defeat Margol the Rager in southeastern Searing Gorge to start 'Caught!' -> leads to Key to Searing Gorge.",
    },
    ["margol's gigantic horn"] = {
        id = 10000,
        name = "Margol's Gigantic Horn",
        kind = "drop",
        leadsTo = "Key to Searing Gorge (At Last!)",
        source = "Margol the Rager (SE Searing Gorge 73.5, 82.3)",
        before = "Loot from Margol the Rager -> turn in at Ironforge -> Loch Modan Gatekeeper for Key to Searing Gorge.",
    },
    ["araj's scarab"] = {
        id = 14610,
        name = "Araj's Scarab",
        kind = "drop",
        leadsTo = "Skeleton Key (Scholomance Key Finale)",
        source = "Araj's Phylactery (Andorhal ruins center 45, 69 after killing Araj the Summoner)",
        before = "Form a group in Western Plaguelands to slay Araj the Summoner in Andorhal and loot the phylactery on the ground.",
    },
    ["core fragment"] = {
        id = 18412,
        name = "Core Fragment",
        kind = "object",
        leadsTo = "Attunement to the Core (Molten Core Raid)",
        source = "Glowing crystal beside the Molten Core portal inside Blackrock Depths",
        before = "Speak to Lothos Riftwaker outside BRD to accept 'Attunement to the Core', enter BRD (or Shadowforge Skip), loot the fragment right next to the MC portal, and exit to Lothos.",
    },
    ["arcane crystal"] = {
        id = 12363,
        name = "Arcane Crystal",
        kind = "gather",
        leadsTo = "Naxxramas Attunement (Argent Dawn) / Arcanite Bar",
        source = "Rich Thorium Veins (Eastern Plaguelands, Winterspring, Un'Goro) & Auction House",
        before = "Required by Archmage Angela Dosantos at Light's Hope Chapel: Honored (5x), Revered (2x), Exalted (Free) — check AH before going!",
    },
    ["nexus crystal"] = {
        id = 20725,
        name = "Nexus Crystal",
        kind = "craft",
        leadsTo = "Naxxramas Attunement (Argent Dawn Honored)",
        source = "Disenchanting Epic (Purple) Lvl 55+ gear / Auction House",
        before = "Required at Light's Hope Chapel for Argent Dawn Honored tier (1x Nexus Crystal) — revered & exalted tiers need 0!",
    },
    ["righteous orb"] = {
        id = 12811,
        name = "Righteous Orb",
        kind = "drop",
        leadsTo = "Naxxramas Attunement / Crusader Enchant",
        source = "Crimson Elite mobs inside Stratholme Live Side & Auction House",
        before = "Needed at Light's Hope Chapel (2x for Honored tier, 1x for Revered tier) alongside Arcane Crystals & Gold.",
    },
    ["grime-encrusted object"] = {
        id = 9308,
        name = "Grime-Encrusted Object",
        kind = "drop",
        leadsTo = "The Sparklematic 5200! (Gnomeregan)",
        source = "Dark Iron dwarves & irradiated troggs inside Gnomeregan",
        before = "Bring 3x Silver coins + [Grime-Encrusted Object] to the Sparklematic 5200 machine near Clean Zone inside Gnomeregan.",
    },
    ["defias tower key"] = {
        id = 7923,
        name = "Defias Tower Key",
        kind = "pickpocket",
        leadsTo = "Klaven's Tower (Rogue Poisons & Thistle Tea)",
        source = "Pick Pocket from Malformed Defias Drone outside Klaven's Tower (SE Westfall 70, 74)",
        before = "ROGUE TIP: Stealth and Pick Pocket the patrolling Malformed Defias Drone outside the tower — do NOT kill him first without pickpocketing, then open the top chest cleanly.",
    },
    ["half-pendant of aquatic endurance"] = {
        id = 15882,
        name = "Half-Pendant of Aquatic Endurance",
        kind = "object",
        leadsTo = "Aquatic Form (Druid Level 16)",
        source = "Fatigue-zone underwater chest: Silverpine north coast (~29, 29, Horde) or northern Darkshore sea abyss (~48, 11, Alliance)",
        before = "Swim straight down with buff/healing pots before fatigue drains you, loot the lockbox, and combine both halves at Moonglade's Shrine of Remulos!",
    },
    ["half-pendant of aquatic agility"] = {
        id = 15883,
        name = "Half-Pendant of Aquatic Agility",
        kind = "object",
        leadsTo = "Aquatic Form (Druid Level 16)",
        source = "Inland underwater lockbox: Sludge Fen, The Barrens (56.7, 8.3, Horde) or northern Darkshore crevice (48.9, 11.3, Alliance)",
        before = "Combine with [Half-Pendant of Aquatic Endurance] at the Shrine of Remulos in Moonglade -> unlocks Aquatic Form!",
    },
    ["bloodscalp tusk"] = {
        id = 3901,
        name = "Bloodscalp Tusk",
        kind = "drop",
        leadsTo = "Whirlwind Weapon (Warrior Level 30)",
        source = "Bloodscalp Trolls in northern Stranglethorn Vale (25-40)",
        before = "Farm 30x [Bloodscalp Tusk] in Northern STV along with Arathi elemental charms & 8x Liferoot for Cyclonian.",
    },
    ["burning charm"] = {
        id = 4479,
        name = "Burning Charm",
        kind = "drop",
        leadsTo = "Whirlwind Weapon (Warrior Level 30)",
        source = "Burning Exiles in Arathi Highlands (Circle of East Binding) & Auction House",
        before = "Need 8x Burning, 8x Cresting, and 8x Thundering Charms for Bath'rah the Windwatcher in Alterac Mountains.",
    },
    ["cresting charm"] = {
        id = 4480,
        name = "Cresting Charm",
        kind = "drop",
        leadsTo = "Whirlwind Weapon (Warrior Level 30)",
        source = "Cresting Exiles in Arathi Highlands (Circle of Outer Binding) & Auction House",
        before = "Need 8x [Cresting Charm] from Arathi water elementals (or AH) for 'Cyclonian'.",
    },
    ["thundering charm"] = {
        id = 4481,
        name = "Thundering Charm",
        kind = "drop",
        leadsTo = "Whirlwind Weapon (Warrior Level 30)",
        source = "Thundering Exiles in Arathi Highlands (Circle of West Binding) & Auction House",
        before = "Need 8x [Thundering Charm] from Arathi air elementals (or AH) for 'Cyclonian'.",
    },
    ["torch of retribution"] = {
        id = 10515,
        name = "Torch of Retribution",
        kind = "provided",
        leadsTo = "Set Them Ablaze! (Searing Gorge)",
        source = "Provided by Squire Maltrake in Searing Gorge (39, 39)",
        before = "Carry it into all 4 Dark Iron Sentry Towers and right-click the brazier inside each tower — do not destroy it before finishing!",
    },
    ["sida's bag"] = {
        id = 4654,
        name = "Sida's Bag",
        kind = "drop",
        leadsTo = "Digging Through the Ooze (Wetlands 10-Slot Bag)",
        source = "Crimson & Black Oozes inside Thelgen Rock / Mosshide caves (Wetlands)",
        before = "Drops off Wetlands oozes while on 'Digging Through the Ooze' -> turn in to Sida in Menethil Harbor for [Ooze-covered Bag].",
    },
    ["whitestone oak lumber"] = {
        id = 6952,
        name = "Whitestone Oak Lumber",
        kind = "drop",
        leadsTo = "The Test of Righteousness (Verigan's Fist — Paladin Lvl 20)",
        source = "Goblin Woodcarvers inside The Deadmines (near Foundry/Mast Room)",
        before = "Collect inside The Deadmines (do NOT leave instance early before Defias foundry!) — one of 4 dungeon components for Verigan's Fist.",
    },
    ["deed to cael darrow"] = {
        id = 13471,
        name = "Deed to Caer Darrow",
        kind = "object",
        leadsTo = "The Last Barov (Barov Peasant Caller Trinket)",
        source = "Inside Scholomance (Viewing Room / Vectus table on floor)",
        before = "Grab all 4 Barov deeds inside Scholomance before leaving — turns into [Barov Peasant Caller] summon trinket!",
    },
    ["deed to caer darrow"] = {
        id = 13471,
        name = "Deed to Caer Darrow",
        kind = "object",
        leadsTo = "The Last Barov (Barov Peasant Caller Trinket)",
        source = "Inside Scholomance (Viewing Room / Vectus table on floor)",
        before = "Grab all 4 Barov deeds inside Scholomance before leaving — turns into [Barov Peasant Caller] summon trinket!",
    },
    ["deed to southshore"] = {
        id = 13448,
        name = "Deed to Southshore",
        kind = "object",
        leadsTo = "The Last Barov (Barov Peasant Caller Trinket)",
        source = "Inside Scholomance (Rattlegore/Viewing Room hall on table)",
        before = "1 of 4 Deeds needed inside Scholomance for 'The Last Barov'.",
    },
    ["deed to tarren mill"] = {
        id = 13450,
        name = "Deed to Tarren Mill",
        kind = "object",
        leadsTo = "The Last Barov (Barov Peasant Caller Trinket)",
        source = "Inside Scholomance (Reliquary / Marduk hall)",
        before = "1 of 4 Deeds needed inside Scholomance for 'The Last Barov'.",
    },
    ["deed to brill"] = {
        id = 13451,
        name = "Deed to Brill",
        kind = "object",
        leadsTo = "The Last Barov (Barov Peasant Caller Trinket)",
        source = "Inside Scholomance (Deputy Krastinov's wing on table)",
        before = "1 of 4 Deeds needed inside Scholomance for 'The Last Barov'.",
    },
}

for k, v in pairs(ITEM_DEPS) do
    Data.ItemDependencies[k] = v
end

-- =========================================================================
-- 2. Open-World & Forever Multi-Step Dependency Quests (merged with FDJ DB)
-- =========================================================================
local OPEN_WORLD_GUIDES = {
    -- Duskwood: Morbent Fel, Look to the Stars, Seasoned Wolf Kabobs, Bride of Embalmer
    [55] = {
        name = "Morbent Fel",
        summary = "Must equip/use [Morbent's Bane] in battle or Morbent Fel stays immune!",
        steps = {
            { kind = "quest", text = "First complete 'Armed and Ready' (Grimand Elmore in SW) to receive [Morbent's Bane]", itemID = 7297, itemName = "Morbent's Bane" },
            { kind = "use", text = "Enter upstairs room at haunted house (17.2, 33.4 Duskwood), target Morbent Fel & USE [Morbent's Bane] to break his shield", mapID = 1431, x = 0.172, y = 0.334, itemID = 7297, itemName = "Morbent's Bane" },
        },
        items = {
            { id = 7297, name = "Morbent's Bane", role = "precursor", source = "Reward from 'Armed and Ready' (must USE on Morbent Fel to strip shield)" },
        },
        pins = {
            { mapID = 1431, x = 0.172, y = 0.334, label = "Morbent Fel — House North of Raven Hill", detail = "Use [Morbent's Bane] from bags/off-hand to strip shield!", kind = "objective" },
        },
    },
    [90] = {
        name = "Seasoned Wolf Kabobs",
        summary = "Needs wolf drops PLUS vendor-bought Stormwind Seasoning Herbs (doesn't drop!).",
        steps = {
            { kind = "item", text = "Farm 10x [Lean Wolf Flank] from wolves in western Duskwood (44, 15 / 18, 25)", mapID = 1431, x = 0.250, y = 0.350, itemName = "Lean Wolf Flank" },
            { kind = "vendor", text = "Buy [Stormwind Seasoning Herbs] from Felicia Gump (Stormwind Canals 64.2, 60.5)", mapID = 1453, x = 0.642, y = 0.605, itemID = 2665, itemName = "Stormwind Seasoning Herbs" },
            { kind = "turnin", text = "Return to Chef Grual inside Darkshire Inn", mapID = 1431, x = 0.738, y = 0.435 },
        },
        items = {
            { id = 2665, name = "Stormwind Seasoning Herbs", role = "required", source = "Sold by Felicia Gump (Stormwind Canals 64.2, 60.5) — vendor only!" },
            { name = "Lean Wolf Flank", role = "required", source = "Wolves around western Duskwood (10 needed)" },
        },
        pins = {
            { mapID = 1453, x = 0.642, y = 0.605, label = "Felicia Gump — Stormwind Seasoning Herbs", detail = "Buy Stormwind Seasoning Herbs for Duskwood Seasoned Wolf Kabobs", kind = "vendor" },
        },
    },
    [174] = {
        name = "Look to the Stars (Step 1/4)",
        summary = "Bronze Tube is crafted by Engineers (105) or bought from rare stock vendors — does NOT drop!",
        steps = {
            { kind = "craft", text = "Get 1x [Bronze Tube]: Engineering 105 (2 Bronze Bar + 1 Weak Flux) OR buy from Gearcutter Cogspinner (SW/Dun Morogh), Neal Allen (Menethil), or Gnaz Blunderflame (STV)", itemID = 4371, itemName = "Bronze Tube" },
            { kind = "turnin", text = "Give Bronze Tube to Viktori Prism'antras in Darkshire (79.8, 48.0)", mapID = 1431, x = 0.798, y = 0.480 },
        },
        items = {
            { id = 4371, name = "Bronze Tube", role = "required", source = "Engineering 105 (2 Bronze Bar + 1 Weak Flux), limited Engineering vendors, or AH" },
        },
        pins = {
            { mapID = 1431, x = 0.798, y = 0.480, label = "Viktori Prism'antras — Darkshire", detail = "Needs 1x Bronze Tube (Craft/Vendor/AH)", kind = "turnin" },
        },
    },
    [253] = {
        name = "Bride of the Embalmer",
        summary = "Dig up Eliza's Grave behind Abercrombie's shack — spawns Lvl 31 Elite + 3 guards!",
        steps = {
            { kind = "object", text = "Click Dirt Mound / Eliza's Grave north of Abercrombie's shack (28.8, 30.9 Duskwood) -> spawns Eliza + 3 adds!", mapID = 1431, x = 0.288, y = 0.309 },
            { kind = "turnin", text = "Loot [The Embalmer's Heart] and return to Lord Ello Ebonlocke in Darkshire Town Hall", mapID = 1431, x = 0.719, y = 0.464 },
        },
        pins = {
            { mapID = 1431, x = 0.288, y = 0.309, label = "Eliza's Grave — North of Abercrombie", detail = "Spawns Elite Eliza + 3 guards on click!", kind = "objective" },
        },
    },

    -- Westfall: CLUCK!, Westfall Stew
    [3861] = {
        name = "CLUCK!",
        summary = "Hidden Pet Quest! Requires buying [Special Chicken Feed] BEFORE using /chicken emote on a chicken!",
        steps = {
            { kind = "vendor", text = "First buy [Special Chicken Feed] from Farmer Saldean (Westfall 56.4, 30.6) or William Maclure (Elwynn 43.0, 85.8)", mapID = 1436, x = 0.564, y = 0.306, itemID = 11109, itemName = "Special Chicken Feed" },
            { kind = "use", text = "Target a Chicken at Saldean's Farm and type /chicken 15-30 times until it turns green/friendly", mapID = 1436, x = 0.560, y = 0.312 },
            { kind = "turnin", text = "Accept 'CLUCK!' from the friendly Chicken -> turn in with Special Chicken Feed for Westfall Chicken pet!", itemID = 11109, itemName = "Special Chicken Feed" },
        },
        items = {
            { id = 11109, name = "Special Chicken Feed", role = "precursor", source = "Sold by Farmer Saldean (Westfall 56.4, 30.6)" },
        },
        pins = {
            { mapID = 1436, x = 0.564, y = 0.306, label = "Farmer Saldean — Special Chicken Feed", detail = "Buy feed BEFORE spamming /chicken at chickens here", kind = "vendor" },
        },
    },

    -- Hillsbrad: Soothing Turtle Bisque
    [555] = {
        name = "Soothing Turtle Bisque",
        summary = "Soothing Spices cannot be looted from turtles — buy from a Cooking Supplies vendor!",
        steps = {
            { kind = "item", text = "Farm 10x [Turtle Meat] from River Snappers along Hillsbrad Foothills rivers", mapID = 1424, x = 0.650, y = 0.450, itemName = "Turtle Meat" },
            { kind = "vendor", text = "Buy [Soothing Spices] from any Cooking Supplies vendor (Southshore / Tarren Mill / capital)", itemID = 3713, itemName = "Soothing Spices" },
        },
        items = {
            { id = 3713, name = "Soothing Spices", role = "required", source = "Sold by Cooking Supplies vendors in towns" },
        },
    },

    -- Badlands Reagent & Craft Chain
    [713] = {
        name = "Coolant Heads Prevail",
        summary = "Requires crafted [Frost Oil] (Alchemy 200) — does NOT drop in Badlands!",
        steps = {
            { kind = "craft", text = "First craft/buy 1x [Frost Oil]: Alchemy (200) = 4x [Khadgar's Whisker] + 2x [Wintersbite] + 1x [Leaded Vial] (Recipe sold by Bro'kin at Alterac Ruins 38.4, 38.8)", itemID = 3829, itemName = "Frost Oil", mapID = 1416, x = 0.384, y = 0.388 },
            { kind = "turnin", text = "Bring 1x Frost Oil to Lotwil Veriatus in Badlands (25.8, 44.4)", mapID = 1418, x = 0.258, y = 0.444 },
        },
        items = {
            { id = 3829, name = "Frost Oil", role = "required", source = "Alchemy 200 (4 Khadgar's Whisker + 2 Wintersbite + 1 Leaded Vial) or AH" },
        },
        pins = {
            { mapID = 1416, x = 0.384, y = 0.388, label = "Bro'kin — Recipe: Frost Oil (Ltd)", detail = "Sells limited Recipe: Frost Oil (Alchemy 200)", kind = "vendor" },
            { mapID = 1418, x = 0.258, y = 0.444, label = "Lotwil Veriatus — Badlands", detail = "Turn in Frost Oil here", kind = "turnin" },
        },
    },
    [714] = {
        name = "Gyro... What?",
        summary = "Requires crafted [Gyrochronatom] (Engineering 170) — cannot drop in Badlands!",
        steps = {
            { kind = "craft", text = "Craft/buy 1x [Gyrochronatom]: Engineering (170) = 1x [Iron Bar] + 1x [Gold Power Core] (or AH)", itemID = 4389, itemName = "Gyrochronatom" },
            { kind = "turnin", text = "Bring 1x Gyrochronatom to Lotwil Veriatus in Badlands (25.8, 44.4)", mapID = 1418, x = 0.258, y = 0.444 },
        },
        items = {
            { id = 4389, name = "Gyrochronatom", role = "required", source = "Engineering 170 (1 Iron Bar + 1 Gold Power Core) or AH" },
        },
        pins = {
            { mapID = 1418, x = 0.258, y = 0.444, label = "Lotwil Veriatus — Badlands", detail = "Turn in Gyrochronatom here", kind = "turnin" },
        },
    },
    [715] = {
        name = "Liquid Stone",
        summary = "Requires 2 pre-made Alchemy potions: 1x [Healing Potion] + 1x [Lesser Invisibility Potion]!",
        steps = {
            { kind = "craft", text = "Get 1x [Healing Potion] (Alchemy 110: 1 Bruiseweed + 1 Briarthorn + 1 Leaded Vial, or world drop/AH)", itemID = 929, itemName = "Healing Potion" },
            { kind = "craft", text = "Get 1x [Lesser Invisibility Potion] (Alchemy 165, Trainer: 1 Wild Steelbloom + 1 Fadeleaf + 1 Leaded Vial, or AH)", itemID = 3823, itemName = "Lesser Invisibility Potion" },
            { kind = "turnin", text = "Give both potions to Lucien Tosselwrench in Badlands (25.8, 44.2)", mapID = 1418, x = 0.258, y = 0.442 },
        },
        items = {
            { id = 929, name = "Healing Potion", role = "required", source = "Alchemy 110 / Drop / AH" },
            { id = 3823, name = "Lesser Invisibility Potion", role = "required", source = "Alchemy 165 (Trainer) / AH" },
        },
        pins = {
            { mapID = 1418, x = 0.258, y = 0.442, label = "Lucien Tosselwrench — Badlands", detail = "Needs Healing Potion + Lesser Invisibility Potion", kind = "turnin" },
        },
    },
    [716] = {
        name = "Stone Is Better than Cloth",
        summary = "Requires crafted [Patterned Bronze Bracers] (Blacksmithing 120)!",
        steps = {
            { kind = "craft", text = "Craft/buy 1x [Patterned Bronze Bracers]: Blacksmithing (120) = 5x [Bronze Bar] + 2x [Coarse Grinding Stone] (or AH)", itemID = 2868, itemName = "Patterned Bronze Bracers" },
            { kind = "turnin", text = "Give to Lucien Tosselwrench in Badlands (25.8, 44.2)", mapID = 1418, x = 0.258, y = 0.442 },
        },
        items = {
            { id = 2868, name = "Patterned Bronze Bracers", role = "required", source = "Blacksmithing 120 (5 Bronze Bar + 2 Coarse Grinding Stone) or AH" },
        },
        pins = {
            { mapID = 1418, x = 0.258, y = 0.442, label = "Lucien Tosselwrench — Badlands", detail = "Needs Patterned Bronze Bracers", kind = "turnin" },
        },
    },

    -- Stranglethorn & Tanaris Multi-Step Keys / Treasure
    [627] = {
        name = "Favor for Krazek",
        summary = "Requires 4x [Lesser Bloodstone Ore] — mined inside Arathi Highlands cave or AH (not in STV!).",
        steps = {
            { kind = "gather", text = "Mine 4x [Lesser Bloodstone Ore] in Drywhisker Gorge cave (Arathi Highlands 80, 39) or buy on AH", mapID = 1417, x = 0.800, y = 0.390, itemName = "Lesser Bloodstone Ore" },
            { kind = "turnin", text = "Deliver to Krazek on top floor of Booty Bay Inn (STV)", mapID = 1434, x = 0.270, y = 0.772 },
        },
        pins = {
            { mapID = 1417, x = 0.800, y = 0.390, label = "Lesser Bloodstone Ore Cave — Arathi", detail = "Drywhisker Gorge cave nodes (required for STV Favor for Krazek)", kind = "objective" },
        },
    },
    [2882] = {
        name = "Cuergo's Gold",
        summary = "First combine 3 Map Fragments from Lost Rigger Cove -> spawns pirate ambush at Land's End mast -> loot key!",
        steps = {
            { kind = "drop", text = "Loot [Upper], [Middle], [Lower Map Fragment] from pirates/footlockers in Lost Rigger Cove -> right-click to combine into [Cuergo's Treasure Map]", mapID = 1446, x = 0.730, y = 0.460, itemID = 9275, itemName = "Cuergo's Treasure Map" },
            { kind = "use", text = "Go to Land's End Beach mast in southern Tanaris (54.9, 94.4) and click the Inconspicuous Landmark flag -> kill Treasure Hunters", mapID = 1446, x = 0.549, y = 0.944 },
            { kind = "object", text = "Loot [Cuergo's Key] from the ambush mobs and open Cuergo's Hidden Treasure chest!", mapID = 1446, x = 0.549, y = 0.944 },
        },
        items = {
            { id = 9275, name = "Cuergo's Treasure Map", role = "starter", source = "Combine Upper + Middle + Lower Map Fragments from Lost Rigger Cove" },
        },
        pins = {
            { mapID = 1446, x = 0.730, y = 0.460, label = "Lost Rigger Cove — 3 Map Fragments", detail = "Collect Upper/Middle/Lower fragments from pirates & footlockers", kind = "item" },
            { mapID = 1446, x = 0.549, y = 0.944, label = "Cuergo's Mast Flag — Land's End Beach", detail = "Spawns pirate ambush; loot Cuergo's Key -> open chest", kind = "objective" },
        },
    },

    -- Un'Goro Crater: Morrowgrain, A-Me 01, Crystal Pylons, Linken's Adventure
    [3785] = {
        name = "Morrowgrain Research (Darnassus)",
        summary = "Cannot loot Morrowgrain directly! Put 2x [Un'Goro Soil] into your [Evergreen Pouch] every 10 minutes!",
        steps = {
            { kind = "gather", text = "Gather [Un'Goro Soil] from dirt piles & mobs around Un'Goro Crater", mapID = 1449, x = 0.480, y = 0.480, itemID = 11018, itemName = "Un'Goro Soil" },
            { kind = "use", text = "Right-click [Evergreen Pouch] (10m CD, uses 2x Un'Goro Soil) -> produces [Tharlendris Seeds] -> open for [Morrowgrain]", itemID = 11020, itemName = "Evergreen Pouch" },
        },
        items = {
            { id = 11020, name = "Evergreen Pouch", role = "provided", source = "Right-click every 10m with 2x Un'Goro Soil in bags" },
            { id = 11018, name = "Un'Goro Soil", role = "precursor", source = "Un'Goro Crater soil piles / mobs -> needed inside Evergreen Pouch" },
            { id = 11040, name = "Morrowgrain", role = "required", source = "Spawns inside Tharlendris Seeds created by Evergreen Pouch" },
        },
    },
    [3803] = {
        name = "Morrowgrain Research (Thunder Bluff)",
        summary = "Cannot loot Morrowgrain directly! Put 2x [Un'Goro Soil] into your [Evergreen Pouch] every 10 minutes!",
        steps = {
            { kind = "gather", text = "Gather [Un'Goro Soil] from dirt piles & mobs around Un'Goro Crater", mapID = 1449, x = 0.480, y = 0.480, itemID = 11018, itemName = "Un'Goro Soil" },
            { kind = "use", text = "Right-click [Evergreen Pouch] (10m CD, uses 2x Un'Goro Soil) -> produces [Tharlendris Seeds] -> open for [Morrowgrain]", itemID = 11020, itemName = "Evergreen Pouch" },
        },
        items = {
            { id = 11020, name = "Evergreen Pouch", role = "provided", source = "Right-click every 10m with 2x Un'Goro Soil in bags" },
            { id = 11018, name = "Un'Goro Soil", role = "precursor", source = "Un'Goro Crater soil piles / mobs" },
            { id = 11040, name = "Morrowgrain", role = "required", source = "Spawns inside Tharlendris Seeds created by Evergreen Pouch" },
        },
    },
    [4243] = {
        name = "Chasing A-Me 01",
        summary = "Bring 1x [Mithril Casing] (Engineering 215 / AH) BEFORE entering Fungal Rock cave or you can't advance!",
        steps = {
            { kind = "craft", text = "Bring 1x [Mithril Casing] FIRST (Engineering 215 = 3x Mithril Bar, or AH)", itemID = 10561, itemName = "Mithril Casing" },
            { kind = "turnin", text = "Enter Fungal Rock cave (67, 16) in Un'Goro and deliver Mithril Casing to A-Me 01", mapID = 1449, x = 0.676, y = 0.167 },
        },
        items = {
            { id = 10561, name = "Mithril Casing", role = "required", source = "Engineering 215 (3x Mithril Bar) or Auction House — get BEFORE cave!" },
        },
        pins = {
            { mapID = 1449, x = 0.676, y = 0.167, label = "A-Me 01 — Fungal Rock Cave", detail = "Bring 1x Mithril Casing BEFORE walking here!", kind = "turnin" },
        },
    },
    [4284] = {
        name = "Crystals of Power",
        summary = "Loot 7 each of Red, Blue, Green, Yellow Power Crystals across Un'Goro Crater (used for the 3 Pylons!).",
        steps = {
            { kind = "gather", text = "Collect 7 Red, 7 Blue, 7 Green, 7 Yellow Power Crystals around Un'Goro Crater (keep extras for the Pylon quests!)" },
            { kind = "turnin", text = "Speak with J.D. Collie in Marshal's Refuge (41.9, 2.7)", mapID = 1449, x = 0.419, y = 0.027 },
        },
        pins = {
            { mapID = 1449, x = 0.419, y = 0.027, label = "J.D. Collie — Marshal's Refuge", detail = "Unlocks Pylon quests; keep extra Power Crystals!", kind = "turnin" },
        },
    },
    [4285] = {
        name = "The Northern Pylon",
        summary = "Climb up the mountain ridge northeast of Marshal's Refuge (56.5, 12.5).",
        steps = {
            { kind = "object", text = "Interact with the Northern Crystal Pylon (56.5, 12.5) on the high ridge", mapID = 1449, x = 0.565, y = 0.125 },
            { kind = "turnin", text = "Return to J.D. Collie in Marshal's Refuge (41.9, 2.7)", mapID = 1449, x = 0.419, y = 0.027 },
        },
        pins = {
            { mapID = 1449, x = 0.565, y = 0.125, label = "Northern Crystal Pylon", detail = "Top of ridge northeast of Marshal's Refuge", kind = "objective" },
        },
    },
    [4287] = {
        name = "The Eastern Pylon",
        summary = "Climb up the eastern ridge wall (77.2, 50.0) overlooking Un'Goro Crater.",
        steps = {
            { kind = "object", text = "Interact with the Eastern Crystal Pylon (77.2, 50.0)", mapID = 1449, x = 0.772, y = 0.500 },
        },
        pins = {
            { mapID = 1449, x = 0.772, y = 0.500, label = "Eastern Crystal Pylon", detail = "Eastern wall ridge", kind = "objective" },
        },
    },
    [4288] = {
        name = "The Western Pylon",
        summary = "Climb up the western ridge west of Golakka Hot Springs (23.8, 59.1).",
        steps = {
            { kind = "object", text = "Interact with the Western Crystal Pylon (23.8, 59.1)", mapID = 1449, x = 0.238, y = 0.591 },
        },
        pins = {
            { mapID = 1449, x = 0.238, y = 0.591, label = "Western Crystal Pylon", detail = "Western wall above Golakka Hot Springs", kind = "objective" },
        },
    },
    [3845] = {
        name = "It's a Secret to Everybody",
        summary = "Starts the Linken chain leading to [Silver Totem of Aquementas] -> [Spirit of Aquementas].",
        steps = {
            { kind = "object", text = "Dive into the Marshal's Refuge north pond (63, 68) and loot A Small Pack underwater for [Linken's Adventure] items", mapID = 1449, x = 0.631, y = 0.686 },
        },
        pins = {
            { mapID = 1449, x = 0.631, y = 0.686, label = "A Small Pack (Underwater)", detail = "Bottom of pond near wrecked raft", kind = "objective" },
        },
    },
    [4005] = {
        name = "Aquementas",
        summary = "Must summon Aquementas at the Tanaris Stone Circle using [Book of Aquor] to forge [Silver Totem of Aquementas]!",
        steps = {
            { kind = "use", text = "Travel to the Stone Circle in southern Tanaris (70.0, 49.0) and USE [Book of Aquor] inside the circle", mapID = 1446, x = 0.700, y = 0.490, itemID = 11169, itemName = "Book of Aquor" },
            { kind = "drop", text = "Slay spawned Aquementas to obtain [Silver Totem of Aquementas] (keep it for Blazerunner!)", mapID = 1446, x = 0.700, y = 0.490, itemID = 11522, itemName = "Silver Totem of Aquementas" },
        },
        items = {
            { id = 11169, name = "Book of Aquor", role = "provided", source = "Use inside Tanaris Stone Circle (70, 49) to summon Aquementas" },
            { id = 11522, name = "Silver Totem of Aquementas", role = "precursor", source = "Used in next step 'It's Dangerous to Go Alone' to strip Blazerunner's shield" },
        },
        pins = {
            { mapID = 1446, x = 0.700, y = 0.490, label = "Aquementas Stone Circle — Tanaris", detail = "Use [Book of Aquor] here -> slay Aquementas -> Silver Totem", kind = "objective" },
        },
    },
    [3984] = {
        name = "It's Dangerous to Go Alone",
        summary = "Blazerunner is INVULNERABLE until you USE [Silver Totem of Aquementas] from your bags on him!",
        steps = {
            { kind = "use", text = "Climb Fire Plume Ridge (Un'Goro 51, 49), target Blazerunner, and USE [Silver Totem of Aquementas] to drop his shield!", mapID = 1449, x = 0.510, y = 0.490, itemID = 11522, itemName = "Silver Totem of Aquementas" },
            { kind = "turnin", text = "Loot [Golden Flame] and return to Linken at Marshal's Refuge (44.6, 8.2)", mapID = 1449, x = 0.446, y = 0.082 },
        },
        items = {
            { id = 11522, name = "Silver Totem of Aquementas", role = "precursor", source = "Reward from 'Aquementas' — MUST use on Blazerunner to break shield!" },
        },
        pins = {
            { mapID = 1449, x = 0.510, y = 0.490, label = "Blazerunner — Fire Plume Ridge", detail = "USE [Silver Totem of Aquementas] to strip his immunity!", kind = "objective" },
        },
    },

    -- WoW Forever Custom Zones: Shen'dralas, Mount Hyjal, Riverglades, Cozy Sleeping Bag
    [96018] = {
        name = "Powering the Pylons",
        summary = "Need [Mana Sieve] from inside the temple FIRST -> gather Ancient Mana Crystals -> repair pylons with [Pile of Pylon Parts]!",
        steps = {
            { kind = "object", text = "Step 1: Enter the Shen'dralas temple/ruins and pick up a [Mana Sieve]", mapID = 2652, x = 0.500, y = 0.500, itemName = "Mana Sieve" },
            { kind = "gather", text = "Step 2: Use the Mana Sieve to gather [Ancient Mana Crystals] and collect [Pile of Pylon Parts]", itemName = "Ancient Mana Crystals" },
            { kind = "object", text = "Step 3: Repair the Eastern & Western Pylons and return to Mordent Evenshade" },
        },
        items = {
            { name = "Mana Sieve", role = "precursor", source = "Pick up inside the Shen'dralas temple -> needed to harvest Ancient Mana Crystals" },
            { name = "Ancient Mana Crystals", role = "required", source = "Collected using Mana Sieve" },
            { name = "Pile of Pylon Parts", role = "required", source = "Used to repair Eastern/Western pylons" },
        },
    },
    [92011] = {
        name = "Rubble Rummage",
        summary = "Scavenge old Horde camp high up the mountain past Elderwild (Mount Hyjal) for 3 different scrap items.",
        steps = {
            { kind = "gather", text = "Head past Elderwild settlement high up Mount Hyjal -> loot 5x [Frayed Wire], 5x [Scrap Metal], 5x [Calcified Excrement]", mapID = 2482, x = 0.550, y = 0.550 },
        },
    },
    [94981] = {
        name = "Broken Chains / Krol'dok Moulding Follow-up",
        summary = "Keep any [Krol'dok Moulding] looted from Tunk beside War Handler Ashka — it starts the prerequisite quest first!",
        steps = {
            { kind = "drop", text = "Kill Tunk at the forge beside War Handler Ashka in Krol'dok Stronghold for [Krol'dok Moulding] (group-lootable!)", itemID = 267137, itemName = "Krol'dok Moulding" },
            { kind = "starter", text = "Right-click [Krol'dok Moulding] to accept & turn in the starter quest BEFORE continuing", itemID = 267137, itemName = "Krol'dok Moulding" },
        },
        items = {
            { id = 267137, name = "Krol'dok Moulding", role = "starter", source = "Dropped by Tunk beside War Handler Ashka (Krol'dok Stronghold)" },
            { id = 267138, name = "Krol'dok Moulding", role = "starter", source = "Dropped by Tunk beside War Handler Ashka (Krol'dok Stronghold)" },
        },
    },
    [4450] = {
        name = "Key to Searing Gorge (Ledger from Tanaris)",
        summary = "Searing Gorge Key chain starts from [Margol's Horn] dropped by elite Margol the Rager (SE Searing Gorge 73.5, 82.3) -> Loch Modan Mountaineer!",
        steps = {
            { kind = "drop", text = "Kill Lvl 48 Elite Margol the Rager in SE Searing Gorge (73.5, 82.3) for [Margol's Horn]", mapID = 1427, x = 0.735, y = 0.823, itemName = "Margol's Horn" },
            { kind = "turnin", text = "Turn in Ledger / Horn steps at Ironforge & Loch Modan Stonewrought Pass to unlock Gate Key" },
        },
        pins = {
            { mapID = 1427, x = 0.735, y = 0.823, label = "Margol the Rager — Margol's Horn", detail = "Drops quest starter [Margol's Horn] -> Key to Searing Gorge", kind = "objective" },
        },
    },
    -- Rogue Poison / Hunter / Warrior Class Helpers
    [1792] = {
        name = "Whirlwind Weapon",
        summary = "Needs 30x [Bloodscalp Tusk] (North STV), 8 each of [Burning/Cresting/Thundering Charm] (Arathi elementals), and defeating Cyclonian!",
        steps = {
            { kind = "drop", text = "Farm 30x [Bloodscalp Tusk] from trolls in northern Stranglethorn Vale", mapID = 1434, x = 0.340, y = 0.160, itemName = "Bloodscalp Tusk" },
            { kind = "drop", text = "Farm 8x [Burning Charm], 8x [Cresting Charm], 8x [Thundering Charm] from Arathi Highlands elementals (or AH!)", mapID = 1417, x = 0.500, y = 0.500 },
            { kind = "drop", text = "Bring 8x [Liferoot] (AH/Herbalism), summon & defeat Cyclonian (Alterac riverbend) with a group -> [Whirlwind Axe]!", mapID = 1416, x = 0.800, y = 0.660, itemName = "Liferoot" },
        },
        pins = {
            { mapID = 1416, x = 0.800, y = 0.660, label = "Bath'rah the Windwatcher — Whirlwind", detail = "Bring Tusks + 8x3 Element Charms + 8x Liferoot -> summon Cyclonian", kind = "turnin" },
        },
    },

    -- =====================================================================
    -- 2b. Missing KEY / Attunement Guides (100% KEY Coverage)
    -- =====================================================================
    [3201] = {
        name = "At Last!",
        summary = "Final step for [Key to Searing Gorge]: Speak with Mountaineer Pebblebitty outside Stonewrought Pass (Loch Modan -> Searing Gorge gate).",
        steps = {
            { kind = "guide", text = "Prerequisites: Kill Margol the Rager in SE Searing Gorge (73.5, 82.3) -> turn in 'Caught!' & Ironforge courier steps first.", mapID = 1427, x = 0.735, y = 0.823 },
            { kind = "turnin", text = "Deliver Curator Thorius's orders to Mountaineer Pebblebitty in SW Loch Modan (18.2, 83.9) -> [Key to Searing Gorge]!", mapID = 1432, x = 0.182, y = 0.839 },
        },
        items = {
            { id = 10000, name = "Margol's Gigantic Horn", role = "precursor", source = "Dropped by Margol the Rager (SE Searing Gorge 73.5, 82.3)" },
        },
        pins = {
            { mapID = 1432, x = 0.182, y = 0.839, label = "Mountaineer Pebblebitty — Searing Gorge Gate", detail = "Turn in 'At Last!' -> unlocks [Key to Searing Gorge]", kind = "turnin" },
        },
    },
    [5505] = {
        name = "The Key to Scholomance",
        summary = "Alliance Scholomance Key chain Finale: Clear Araj the Summoner in Andorhal (WPL) -> loot [Araj's Scarab] from his Phylactery!",
        steps = {
            { kind = "guide", text = "Full Chain: Barov's Skeleton Key questline from Chillwind Camp -> craft mold -> Kirtonos' Wing -> Araj's Scarab.", mapID = 1422, x = 0.428, y = 0.840 },
            { kind = "drop", text = "Group up in Western Plaguelands to defeat Araj the Summoner (Andorhal ruins 45.0, 69.0) and click his Phylactery for [Araj's Scarab]", mapID = 1422, x = 0.450, y = 0.690, itemID = 14610, itemName = "Araj's Scarab" },
            { kind = "turnin", text = "Return [Araj's Scarab] to Alchemist Arbington at Chillwind Camp (42.8, 84.0) -> permanent [Skeleton Key]!", mapID = 1422, x = 0.428, y = 0.840 },
        },
        items = {
            { id = 14610, name = "Araj's Scarab", role = "required", source = "Looted from Araj's Phylactery after killing Araj the Summoner in Andorhal" },
        },
        pins = {
            { mapID = 1422, x = 0.450, y = 0.690, label = "Araj the Summoner — Araj's Scarab", detail = "Group boss in Andorhal; click Phylactery after kill", kind = "objective" },
            { mapID = 1422, x = 0.428, y = 0.840, label = "Alchemist Arbington — Chillwind Camp", detail = "Turn in -> permanent [Skeleton Key]", kind = "turnin" },
        },
    },
    [5511] = {
        name = "The Key to Scholomance",
        summary = "Horde Scholomance Key chain Finale: Clear Araj the Summoner in Andorhal (WPL) -> return [Araj's Scarab] to The Bulwark!",
        steps = {
            { kind = "guide", text = "Full Chain: Starts at High Executor Derrington at The Bulwark -> Tanaris / Felwood / Undercity / Araj's Scarab.", mapID = 1420, x = 0.832, y = 0.689 },
            { kind = "drop", text = "Group up in Western Plaguelands to slay Araj the Summoner (Andorhal 45.0, 69.0) and click his Phylactery for [Araj's Scarab]", mapID = 1422, x = 0.450, y = 0.690, itemID = 14610, itemName = "Araj's Scarab" },
            { kind = "turnin", text = "Return [Araj's Scarab] to Apothecary Dithers at The Bulwark (Tirisfal border 83.2, 68.9) -> permanent [Skeleton Key]!", mapID = 1420, x = 0.832, y = 0.689 },
        },
        items = {
            { id = 14610, name = "Araj's Scarab", role = "required", source = "Looted from Araj's Phylactery after killing Araj the Summoner in Andorhal" },
        },
        pins = {
            { mapID = 1422, x = 0.450, y = 0.690, label = "Araj the Summoner — Araj's Scarab", detail = "Group boss in Andorhal; click Phylactery after kill", kind = "objective" },
            { mapID = 1420, x = 0.832, y = 0.689, label = "Apothecary Dithers — The Bulwark", detail = "Turn in -> permanent [Skeleton Key]", kind = "turnin" },
        },
    },
    [7487] = {
        name = "Attunement to the Core",
        summary = "Molten Core Raid Portal Shortcut: Accept from Lothos Riftwaker (Blackrock Mountain) -> loot [Core Fragment] inside BRD next to the MC portal!",
        steps = {
            { kind = "guide", text = "Speak with Lothos Riftwaker in the lava chain tunnel outside Blackrock Depths (Burning Steppes side inside BRM) to pick up 'Attunement to the Core'.", mapID = 1428, x = 0.290, y = 0.375 },
            { kind = "object", text = "Enter Blackrock Depths (lava-jump window skip or Shadowforge path past Fire Elemental hall) -> click glowing [Core Fragment] beside the Molten Core portal inside BRD", itemID = 18412, itemName = "Core Fragment" },
            { kind = "turnin", text = "Return [Core Fragment] to Lothos Riftwaker outside BRD -> permanently unlocks instant Molten Core window teleport!" },
        },
        items = {
            { id = 18412, name = "Core Fragment", role = "required", source = "Glowing object right beside Molten Core portal inside Blackrock Depths" },
        },
        pins = {
            { mapID = 1428, x = 0.290, y = 0.375, label = "Blackrock Mountain — Lothos Riftwaker", detail = "Enter BRM toward BRD -> Lothos grants MC Attunement", kind = "turnin" },
        },
    },
    [9121] = {
        name = "The Dread Citadel - Naxxramas",
        summary = "Naxxramas Attunement (Argent Dawn HONORED tier): Costs 5x [Arcane Crystal], 2x [Righteous Orb], 1x [Nexus Crystal], and 60g at Light's Hope Chapel.",
        steps = {
            { kind = "guide", text = "Bring Auction House / Dungeon mats BEFORE visiting Light's Hope Chapel (Honored price tier).", mapID = 1423, x = 0.815, y = 0.598 },
            { kind = "gather", text = "Prepare 5x [Arcane Crystal], 2x [Righteous Orb], 1x [Nexus Crystal], and 60 Gold (Revered saves ~half; Exalted is FREE!).", itemID = 12363, itemName = "Arcane Crystal" },
            { kind = "turnin", text = "Speak with Archmage Angela Dosantos at Light's Hope Chapel, Eastern Plaguelands (81.5, 59.8).", mapID = 1423, x = 0.815, y = 0.598 },
        },
        items = {
            { id = 12363, name = "Arcane Crystal", role = "required", source = "5x needed at Honored (AH / Rich Thorium Veins)" },
            { id = 12811, name = "Righteous Orb", role = "required", source = "2x needed at Honored (Stratholme Live Side / AH)" },
            { id = 20725, name = "Nexus Crystal", role = "required", source = "1x needed at Honored (Epic Disenchant / AH)" },
        },
        pins = {
            { mapID = 1423, x = 0.815, y = 0.598, label = "Archmage Angela Dosantos — Light's Hope Chapel", detail = "Honored Naxxramas Attunement turn-in (5x Arcane, 2x Orb, 1x Nexus, 60g)", kind = "turnin" },
        },
    },
    [9122] = {
        name = "The Dread Citadel - Naxxramas",
        summary = "Naxxramas Attunement (Argent Dawn REVERED tier): Discounted cost — 2x [Arcane Crystal], 1x [Righteous Orb], and 30g at Light's Hope Chapel.",
        steps = {
            { kind = "gather", text = "Bring 2x [Arcane Crystal], 1x [Righteous Orb], and 30 Gold (discount vs Honored tier; Exalted is FREE!).", itemID = 12363, itemName = "Arcane Crystal" },
            { kind = "turnin", text = "Turn in to Archmage Angela Dosantos at Light's Hope Chapel, Eastern Plaguelands (81.5, 59.8).", mapID = 1423, x = 0.815, y = 0.598 },
        },
        items = {
            { id = 12363, name = "Arcane Crystal", role = "required", source = "2x needed at Revered" },
            { id = 12811, name = "Righteous Orb", role = "required", source = "1x needed at Revered" },
        },
        pins = {
            { mapID = 1423, x = 0.815, y = 0.598, label = "Archmage Angela Dosantos — Light's Hope Chapel", detail = "Revered Naxxramas Attunement turn-in (2x Arcane, 1x Orb, 30g)", kind = "turnin" },
        },
    },
    [9123] = {
        name = "The Dread Citadel - Naxxramas",
        summary = "Naxxramas Attunement (Argent Dawn EXALTED tier): 100% FREE! Just speak with Archmage Angela Dosantos at Light's Hope Chapel.",
        steps = {
            { kind = "turnin", text = "Exalted reward: Speak with Archmage Angela Dosantos at Light's Hope Chapel (81.5, 59.8) — NO crystals or gold required!", mapID = 1423, x = 0.815, y = 0.598 },
        },
        pins = {
            { mapID = 1423, x = 0.815, y = 0.598, label = "Archmage Angela Dosantos — Free Exalted Attune", detail = "Zero reagents at Argent Dawn Exalted", kind = "turnin" },
        },
    },

    -- =====================================================================
    -- 2c. Missing BAG Reward Guides (100% BAG Coverage)
    -- =====================================================================
    [58] = {
        name = "The Night Watch (Finale -> 10-Slot Bag)",
        summary = "Duskwood 3/3 Finale: Slay 20 Plague Spreaders in the Dawning Wood Catacombs (SW Raven Hill Cemetery 25, 34) -> [Gunnysack of the Night Watch]!",
        steps = {
            { kind = "objective", text = "Enter the Dawning Wood Catacombs in western Duskwood (25.5, 34.0) and defeat 20 Plague Spreaders (high density inside crypt).", mapID = 1431, x = 0.255, y = 0.340 },
            { kind = "turnin", text = "Return to Commander Althea Ebonlocke in Darkshire (73.6, 46.9) for [Gunnysack of the Night Watch] (10-slot bag) + Ring.", mapID = 1431, x = 0.736, y = 0.469 },
        },
        pins = {
            { mapID = 1431, x = 0.255, y = 0.340, label = "Dawning Wood Catacombs — Plague Spreaders", detail = "Best Plague Spreader crypt entrance for Night Watch finale", kind = "objective" },
            { mapID = 1431, x = 0.736, y = 0.469, label = "Commander Althea Ebonlocke — Darkshire", detail = "Rewards 10-Slot Bag ([Gunnysack of the Night Watch])", kind = "turnin" },
        },
    },
    [470] = {
        name = "Digging Through the Ooze",
        summary = "Wetlands 10-Slot Bag: Hunt Crimson & Black Oozes in the Mosshide/Thelgen Rock area (SW/Central Wetlands ~46, 52) until [Sida's Bag] drops.",
        steps = {
            { kind = "drop", text = "Kill Crimson Oozes & Black Oozes around Thelgen Rock / wetlands puddles (46.0, 52.0) to recover [Sida's Bag].", mapID = 1437, x = 0.460, y = 0.520, itemID = 4654, itemName = "Sida's Bag" },
            { kind = "turnin", text = "Return [Sida's Bag] to Sida near Menethil Harbor inn (11.8, 58.0) -> keep [Ooze-covered Bag] (10-slot bag)!", mapID = 1437, x = 0.118, y = 0.580 },
        },
        items = {
            { id = 4654, name = "Sida's Bag", role = "required", source = "Rare/Quest drop off Crimson & Black Oozes in Wetlands" },
        },
        pins = {
            { mapID = 1437, x = 0.460, y = 0.520, label = "Wetlands Oozes — Sida's Bag", detail = "Kill Crimson/Black Oozes around Thelgen Rock area", kind = "objective" },
            { mapID = 1437, x = 0.118, y = 0.580, label = "Sida — Menethil Harbor", detail = "Turn in -> [Ooze-covered Bag] (10-slot)", kind = "turnin" },
        },
    },
    [626] = {
        name = "Cortello's Riddle (Finale -> 14-Slot Bag)",
        summary = "Massive XP + 14-Slot [Explorer's Knapsack]! The treasure chest sits inside the hidden cave BEHIND the waterfall in eastern Hinterlands (80.8, 46.8).",
        steps = {
            { kind = "guide", text = "Prereq Step 1: Loot [Cortello's Riddle] scroll from ships in STV -> Step 2: Check Swamp of Sorrows bridge (22.6, 48.0).", mapID = 1435, x = 0.226, y = 0.480 },
            { kind = "turnin", text = "Swim under/behind the waterfall in northeastern Hinterlands (80.8, 46.8) -> click the hidden Musty Chest inside the cave -> 14-Slot Bag!", mapID = 1425, x = 0.808, y = 0.468 },
        },
        pins = {
            { mapID = 1425, x = 0.808, y = 0.468, label = "Cortello's Chest — Waterfall Cave", detail = "Walk THROUGH waterfall into secret cave -> 14-Slot [Explorer's Knapsack]", kind = "turnin" },
        },
    },
    [1795] = {
        name = "The Binding (Felhunter -> Box of Souls)",
        summary = "Warlock Lvl 30 Class Finale: Inside your Warlock trainer's summoning circle, use [Tome of the Cabal] / summoning ritual to defeat the Felhunter!",
        steps = {
            { kind = "guide", text = "Requires collecting 3x Moldy Tome / Tattered Manuscript pages in Wetlands/Hillsbrad/Ratchet beforehand ('Seekers of the Tome')." },
            { kind = "use", text = "Stand in your capital city Warlock summoning circle (Stormwind Slaughtered Lamb basement / Undercity Magic Quarter / Ratchet) -> USE [Tome of the Cabal] and defeat the summoned Felhunter." },
            { kind = "turnin", text = "Turn in to Strahad Farsan in Ratchet, The Barrens (62.6, 35.5) -> [Summon Felhunter] + [Box of Souls]!", mapID = 1413, x = 0.626, y = 0.355 },
        },
        pins = {
            { mapID = 1413, x = 0.626, y = 0.355, label = "Strahad Farsan — Ratchet", detail = "Warlock Lvl 30 turn-in -> Felhunter + Box of Souls", kind = "turnin" },
        },
    },
    [84146] = {
        name = "Red Bag Blues",
        summary = "WoW Forever Winterspring Warrior Bag Quest (Lvl 60): Complete the objective in Winterspring to claim [Red Bag] (Soul Shard / Class Bag).",
        steps = {
            { kind = "guide", text = "Check your Quest Log objective details in Winterspring — rewards [Red Bag] + 6,600 XP.", mapID = 1452, x = 0.610, y = 0.380 },
        },
    },
    [93269] = {
        name = "Top of the Post",
        summary = "WoW Forever Mount Hyjal Quest (Lvl 58): Follow the Mount Hyjal postal objective to earn [Hyjal Postal Satchel] (Bag Upgrade) or [Hyjal Postal Clasp].",
        steps = {
            { kind = "guide", text = "Complete the Mount Hyjal turn-in for [Hyjal Postal Satchel] (bag upgrade).", mapID = 1459, x = 0.500, y = 0.500 },
        },
    },
    [96260] = {
        name = "Stronger than Steel",
        summary = "WoW Forever Mulgore Horde Quest (Lvl 29): Rewards a choice of [Spidersilk Sack] or [Spidersilk Pouch] PLUS [Crystal Thread Cloak].",
        steps = {
            { kind = "guide", text = "Pick up in Mulgore (Horde) and choose [Spidersilk Sack] (Bag Upgrade) on turn-in along with [Crystal Thread Cloak].", mapID = 1412, x = 0.450, y = 0.580 },
        },
    },

    -- =====================================================================
    -- 2d. Missing FDJ Dungeon Quest Guides (100% 348/348 FDJ Coverage)
    -- =====================================================================
    [96395] = {
        name = "An Ancient Grudge",
        pickup = "Ghostly Attendant, inside Hall of Thanes, after the first room",
        turnin = "Ghostly Attendant, inside the dungeon",
        summary = "Hall of Thanes (Lvl 15 Rare Q3): Clear inside the dungeon to lay the spirit of Faldrim Anvilmar to rest -> [Catacomb Cloak] or [Deepgrave Trousers]!",
        steps = {
            { kind = "guide", text = "Pick up from Ghostly Attendant inside Hall of Thanes (after the first room — Beneath Ironforge, Dun Morogh)." },
            { kind = "objective", text = "Put the spirit of Faldrim Anvilmar to rest inside Hall of Thanes." },
            { kind = "turnin", text = "Turn in to Ghostly Attendant inside the dungeon -> choose Rare Q3 [Catacomb Cloak] or [Deepgrave Trousers]." },
        },
    },
    [5724] = {
        name = "Returning the Lost Satchel",
        pickup = "Grimtotem Satchel, taken from Maur Grimtotem's corpse inside Ragefire Chasm",
        turnin = "Rahauro, Elder Rise, Thunder Bluff",
        summary = "Ragefire Chasm (Lvl 16 Horde Rare Q3): Loot Maur Grimtotem's corpse inside RFC for [Grimtotem Satchel] -> Elder Rise, Thunder Bluff -> Rare Bracers!",
        steps = {
            { kind = "drop", text = "Inside Ragefire Chasm, defeat Maur Grimtotem (far eastern platform) and loot [Grimtotem Satchel] from his corpse." },
            { kind = "turnin", text = "Take the Grimtotem Satchel to Rahauro on Elder Rise, Thunder Bluff (70.4, 29.6) -> [Featherbead Bracers] / [Savannah Bracers] / [Garrison Cuffs].", mapID = 1456, x = 0.704, y = 0.296 },
        },
        pins = {
            { mapID = 1456, x = 0.704, y = 0.296, label = "Rahauro — Elder Rise, Thunder Bluff", detail = "Turn in RFC Maur Grimtotem satchel -> Rare Bracers", kind = "turnin" },
        },
    },
    [95250] = {
        name = "Abominable Creatures",
        pickup = "Captain Truman, just inside Ruins of Lordaeron (left of the entrance)",
        turnin = "Captain Truman, just inside Ruins of Lordaeron",
        summary = "Ruins of Lordaeron Finale (Alliance Lvl 21 Rare Q3): Defeat the Baron inside Ruins of Lordaeron -> [Monstrous Cleaver] / [Grave Shroud] / [Slain Baron's Signet]!",
        steps = {
            { kind = "guide", text = "Pick up from Captain Truman immediately inside Ruins of Lordaeron (to the left of the entrance)." },
            { kind = "objective", text = "Collect the [Head of the Baron] from the final boss inside Ruins of Lordaeron." },
            { kind = "turnin", text = "Return to Captain Truman inside the entrance before leaving." },
        },
    },
    [6561] = {
        name = "Blackfathom Villainy",
        pickup = "Argent Guard Thaelrid, inside Blackfathom Deeps",
        turnin = "Bashana Runetotem, Elder Rise, Thunder Bluff",
        summary = "Blackfathom Deeps (Horde Lvl 27 BiS Wand): Accept from Argent Guard Thaelrid INSIDE BFD -> defeat Twilight Lord Kelris -> Elder Rise, Thunder Bluff -> [Gravestone Scepter]!",
        steps = {
            { kind = "guide", text = "Inside Blackfathom Deeps (near the naga bridge / pool), pick up 'Blackfathom Villainy' from Argent Guard Thaelrid." },
            { kind = "drop", text = "Defeat final boss Twilight Lord Kelris at the altar -> loot [Head of Kelris]." },
            { kind = "turnin", text = "Deliver to Bashana Runetotem on Elder Rise, Thunder Bluff (70.8, 33.8) -> BiS [Gravestone Scepter]!", mapID = 1456, x = 0.708, y = 0.338 },
        },
        pins = {
            { mapID = 1456, x = 0.708, y = 0.338, label = "Bashana Runetotem — Thunder Bluff", detail = "Turn in Head of Kelris -> BiS [Gravestone Scepter]", kind = "turnin" },
        },
    },
    [95809] = {
        name = "Heartwoven",
        pickup = "Ardin Grassman, inside Excavation Site: Wetlands",
        turnin = "Caitlin Grassman, Menethil Harbor",
        summary = "Excavation Site: Wetlands (Alliance Lvl 31): Follow-up to 'Lost in the Thicket Things'. Escort/return [Reed-woven Heart] to Caitlin Grassman in Menethil Harbor!",
        steps = {
            { kind = "guide", text = "Prereq: Complete 'Lost in the Thicket Things' -> accept from Ardin Grassman inside Excavation Site: Wetlands." },
            { kind = "turnin", text = "Bring the [Reed-woven Heart] back to Caitlin Grassman in Menethil Harbor, Wetlands.", mapID = 1437, x = 0.110, y = 0.560 },
        },
    },
    [95795] = {
        name = "Fallen in the Fen",
        pickup = "Daewyn Songblade, inside Excavation Site: Wetlands",
        turnin = "Dorin Songblade, Lakeshire, Redridge Mountains",
        summary = "Excavation Site: Wetlands (Alliance Lvl 31 Rare Q3): Discover Daewyn Songblade inside the dungeon -> report back to Dorin Songblade in Lakeshire -> [Daewyn's Girdle] / [Songblade Stabilizer]!",
        steps = {
            { kind = "guide", text = "Speak with Daewyn Songblade inside Excavation Site: Wetlands." },
            { kind = "turnin", text = "Report Daewyn's fate to Dorin Songblade in Lakeshire, Redridge Mountains (30.8, 60.0) -> Rare Q3 belt/shield.", mapID = 1433, x = 0.308, y = 0.600 },
        },
        pins = {
            { mapID = 1433, x = 0.308, y = 0.600, label = "Dorin Songblade — Lakeshire", detail = "Turn in 'Fallen in the Fen' -> [Daewyn's Girdle] / [Songblade Stabilizer]", kind = "turnin" },
        },
    },
    [2904] = {
        name = "A Fine Mess",
        pickup = "Kernobee, inside Gnomeregan",
        turnin = "Scooty, Booty Bay, Stranglethorn Vale",
        summary = "Gnomeregan Escort (Lvl 30): Rescue Kernobee near the Launch Bay/Clean Zone and escort him to the Clockwerk Run exit -> report to Scooty in Booty Bay!",
        steps = {
            { kind = "objective", text = "Clear the hallway BEFORE starting Kernobee's escort inside Gnomeregan; escort him safely to the Clockwerk Run exit." },
            { kind = "turnin", text = "Report to Scooty in Booty Bay, Stranglethorn Vale (27.4, 77.4).", mapID = 1434, x = 0.274, y = 0.774 },
        },
        pins = {
            { mapID = 1434, x = 0.274, y = 0.774, label = "Scooty — Booty Bay", detail = "Turn in after escorting Kernobee out of Gnomeregan", kind = "turnin" },
        },
    },
    [2951] = {
        name = "The Sparklematic 5200!",
        pickup = "The Sparklematic 5200, inside Gnomeregan",
        turnin = "The Sparklematic 5200, inside Gnomeregan",
        summary = "Gnomeregan Loot-Box Quests: Keep [Grime-Encrusted Object] drops from mobs inside Gnomeregan -> wash with 3x Silver coins at the Sparklematic 5200 machine!",
        steps = {
            { kind = "drop", text = "Loot [Grime-Encrusted Object] from troggs and Dark Iron dwarves inside Gnomeregan.", itemID = 9308, itemName = "Grime-Encrusted Object" },
            { kind = "object", text = "Have at least 3 Silver coins in your bag -> click the Sparklematic 5200 in The Clean Zone inside Gnomeregan -> [Sparklematic-Wrapped Box]!" },
        },
        items = {
            { id = 9308, name = "Grime-Encrusted Object", role = "required", source = "Dropped by Dark Iron dwarves & troggs inside Gnomeregan" },
        },
    },
    [1144] = {
        name = "Willix the Importer",
        pickup = "Willix the Importer, inside Razorfen Kraul",
        turnin = "Willix the Importer, inside Razorfen Kraul",
        summary = "Razorfen Kraul Escort (Lvl 30 Rare Ring): Do NOT trigger early while fighting Charlga! Clear the path back toward the entrance first, then start the escort.",
        steps = {
            { kind = "objective", text = "Clear trash mobs along the central tunnel toward the RFK exit BEFORE talking to Willix -> escort him to the tunnel exit -> Rare [Boar Signet] / Ring!" },
        },
    },
    [1142] = {
        name = "Mortality Wanes",
        pickup = "Heralath Fallowbrook, inside Razorfen Kraul",
        turnin = "Treshala Fallowbrook, Darnassus",
        summary = "Razorfen Kraul (Alliance Lvl 30): Find Heralath Fallowbrook near the quilted quilboar pens inside RFK -> loot [Treshala's Pendant] nearby -> Darnassus!",
        steps = {
            { kind = "guide", text = "Speak with dying Heralath Fallowbrook inside Razorfen Kraul -> recover [Treshala's Pendant] from Quilboar mobs." },
            { kind = "turnin", text = "Deliver [Treshala's Pendant] to Treshala Fallowbrook in Craftsmen's Terrace, Darnassus (66.4, 52.8).", mapID = 1457, x = 0.664, y = 0.528 },
        },
        pins = {
            { mapID = 1457, x = 0.664, y = 0.528, label = "Treshala Fallowbrook — Darnassus", detail = "Turn in Treshala's Pendant from Razorfen Kraul", kind = "turnin" },
        },
    },

    -- =====================================================================
    -- 2e. Iconic Multi-Step CLASS Quests & Upgrades
    -- =====================================================================
    [1806] = {
        name = "The Test of Righteousness",
        summary = "Paladin Lvl 20 BiS 2H Hammer ([Verigan's Fist]): Requires 4 dungeon/open-world mats before turning in to Jordan Stilwell outside Ironforge!",
        steps = {
            { kind = "drop", text = "1) Loot [Whitestone Oak Lumber] from Goblin Woodcarvers inside The Deadmines.", itemID = 6952, itemName = "Whitestone Oak Lumber" },
            { kind = "drop", text = "2) Loot [Jordan's Refined Ore Shard] behind Shadowfang Keep courtyard stables.", itemName = "Jordan's Refined Ore Shard" },
            { kind = "drop", text = "3) Collect [Corrupted Kor Gem] outside Blackfathom Deeps -> purify at Auberdine (Elunite -> [Purified Kor Gem]).", itemID = 7083, itemName = "Purified Kor Gem" },
            { kind = "object", text = "4) Loot [Jordan's Smithing Hammer] inside Dark Iron Fortress chest (NE Loch Modan 72, 65) -> return all 4 to Jordan Stilwell!", mapID = 1432, x = 0.720, y = 0.650 },
        },
        items = {
            { id = 6952, name = "Whitestone Oak Lumber", role = "required", source = "Goblin Woodcarvers inside The Deadmines" },
            { id = 7083, name = "Purified Kor Gem", role = "precursor", source = "Purified from Corrupted Kor Gem (BFD outside -> Auberdine)" },
        },
    },
    [1719] = {
        name = "The Affray",
        summary = "Warrior Lvl 30 Berserker Stance & Intercept: Sail to Fray Island (SE Barrens off Ratchet 68.6, 49.2) -> defeat waves in the arena!",
        steps = {
            { kind = "objective", text = "Swim east from Ratchet (SE Barrens coast) to Fray Island (68.6, 49.2) -> speak to Klannoc Macleod -> defeat arena challengers & Big Will -> Berserker Stance!", mapID = 1413, x = 0.686, y = 0.492 },
        },
        pins = {
            { mapID = 1413, x = 0.686, y = 0.492, label = "Fray Island — The Affray", detail = "Swim from Ratchet -> Berserker Stance + Intercept unlock", kind = "objective" },
        },
    },
    [31] = {
        name = "Aquatic Form (Horde)",
        summary = "Druid Lvl 16 Aquatic Form: Collect both Pendant Halves (Barrens Sludge Fen 56, 8 + Silverpine Fatigue Coast ~29, 29) -> combine at Shrine of Remulos (Moonglade)!",
        steps = {
            { kind = "object", text = "1) [Half-Pendant of Aquatic Agility]: Dive into the Sludge Fen northeast The Barrens (56.7, 8.3) and loot the underwater lockbox.", mapID = 1413, x = 0.567, y = 0.083, itemID = 15883, itemName = "Half-Pendant of Aquatic Agility" },
            { kind = "object", text = "2) [Half-Pendant of Aquatic Endurance]: Swim west into Fatigue waters north-west of The Sepulcher (Silverpine ~29.0, 29.0) — bring health pots!", mapID = 1421, x = 0.290, y = 0.290, itemID = 15882, itemName = "Half-Pendant of Aquatic Endurance" },
            { kind = "use", text = "3) Teleport to Moonglade -> USE both halves at Shrine of Remulos inside the lake (36.5, 40.2) -> Dendrite Starblaze!", mapID = 1450, x = 0.365, y = 0.402 },
        },
        items = {
            { id = 15883, name = "Half-Pendant of Aquatic Agility", role = "required", source = "Sludge Fen underwater chest (The Barrens 56.7, 8.3)" },
            { id = 15882, name = "Half-Pendant of Aquatic Endurance", role = "required", source = "Silverpine Fatigue-zone ocean floor chest (~29, 29)" },
        },
        pins = {
            { mapID = 1413, x = 0.567, y = 0.083, label = "Sludge Fen Chest — Agility Half-Pendant", detail = "Barrens underwater lockbox", kind = "objective" },
            { mapID = 1421, x = 0.290, y = 0.290, label = "Silverpine Ocean Abyss — Endurance Half", detail = "Fatigue-zone chest on sea floor", kind = "objective" },
            { mapID = 1450, x = 0.365, y = 0.402, label = "Shrine of Remulos — Combine Pendants", detail = "Lake of Elune'ara, Moonglade -> Aquatic Form!", kind = "turnin" },
        },
    },
    [5061] = {
        name = "Aquatic Form (Alliance)",
        summary = "Druid Lvl 16 Aquatic Form: Loot both Pendant Halves (Darkshore abyss 48.9, 11.3 & Westfall fatigue waters 17.8, 33.4) -> combine at Shrine of Remulos (Moonglade)!",
        steps = {
            { kind = "object", text = "1) Loot submerged chest off northern Darkshore coast (48.9, 11.3) for [Half-Pendant of Aquatic Agility].", mapID = 1439, x = 0.489, y = 0.113, itemID = 15883, itemName = "Half-Pendant of Aquatic Agility" },
            { kind = "object", text = "2) Swim west from northern Westfall lighthouse into Fatigue waters (17.8, 33.4) -> sunken chest [Half-Pendant of Aquatic Endurance]!", mapID = 1436, x = 0.178, y = 0.334, itemID = 15882, itemName = "Half-Pendant of Aquatic Endurance" },
            { kind = "use", text = "3) Teleport to Moonglade -> USE both halves at Shrine of Remulos in Lake Elune'ara (36.5, 40.2) -> Aquatic Form!", mapID = 1450, x = 0.365, y = 0.402 },
        },
        items = {
            { id = 15883, name = "Half-Pendant of Aquatic Agility", role = "required", source = "Northern Darkshore underwater chest (48.9, 11.3)" },
            { id = 15882, name = "Half-Pendant of Aquatic Endurance", role = "required", source = "Westfall offshore fatigue-zone lockbox (17.8, 33.4)" },
        },
        pins = {
            { mapID = 1439, x = 0.489, y = 0.113, label = "Darkshore Reef — Agility Half-Pendant", detail = "Submerged lockbox", kind = "objective" },
            { mapID = 1436, x = 0.178, y = 0.334, label = "Westfall Fatigue Abyss — Endurance Half", detail = "Swim west fast & watch fatigue bar", kind = "objective" },
            { mapID = 1450, x = 0.365, y = 0.402, label = "Shrine of Remulos — Moonglade", detail = "Combine halves -> Aquatic Form!", kind = "turnin" },
        },
    },
    [2359] = {
        name = "Klaven's Tower",
        summary = "Rogue Lvl 20 Poisons & Thistle Tea: Stealth + Pick Pocket the patrolling Malformed Defias Drone outside Klaven's Tower (SE Westfall 70, 74) for [Defias Tower Key]!",
        steps = {
            { kind = "pickpocket", text = "1) Stealth beside Klaven's Tower in SE Westfall (70.4, 74.0) -> Pick Pocket the Malformed Defias Drone for [Defias Tower Key] (do not kill first!).", mapID = 1436, x = 0.704, y = 0.740, itemID = 7923, itemName = "Defias Tower Key" },
            { kind = "object", text = "2) Sap/evade elite Klaven Mortwake at the top of the tower and picklock the chest -> loot [Defias Journal] -> return to Stormwind SI:7 for Poisons & Thistle Tea!", mapID = 1436, x = 0.704, y = 0.740 },
        },
        items = {
            { id = 7923, name = "Defias Tower Key", role = "required", source = "Pick Pocket from Malformed Defias Drone outside Klaven's Tower" },
        },
        pins = {
            { mapID = 1436, x = 0.704, y = 0.740, label = "Klaven's Tower — SE Westfall", detail = "Pick Pocket Drone for Key -> Sap/Loot top chest -> Poisons + Thistle Tea", kind = "objective" },
        },
    },
    [2480] = {
        name = "Hinott's Assistance",
        summary = "Rogue Lvl 20 Horde Poisons Follow-up (Cure Touch of Zanzil): Return from the Barrens tower stealth run to Serge Hinott in Tarren Mill (Hillsbrad 61.6, 19.2)!",
        steps = {
            { kind = "guide", text = "Requires [Touch of Zanzil] cure quest — travel to Hillsbrad Foothills after Sludge Tower mission." },
            { kind = "turnin", text = "Speak to Serge Hinott inside Tarren Mill, Hillsbrad Foothills (61.6, 19.2) -> cures poison + finishes [Thistle Tea] & Poisons!", mapID = 1424, x = 0.616, y = 0.192 },
        },
        pins = {
            { mapID = 1424, x = 0.616, y = 0.192, label = "Serge Hinott — Tarren Mill", detail = "Rogue Poisons / Touch of Zanzil cure finale", kind = "turnin" },
        },
    },
    [1527] = {
        name = "Call of Fire (Horde Shaman)",
        summary = "Shaman Lvl 10 Fire Totem Finale: Climb the mountain path in southern Durotar / northern Barrens to Telf Joolam at Razor Hill/Shrine (38.9, 58.2) -> summon Minor Manifestation of Fire!",
        steps = {
            { kind = "use", text = "Bring [Fire Sapta] up the mountain path to Telf Joolam in Durotar (38.9, 58.2), drink Sapta, slay Manifestation of Fire, and click the Brazier -> [Fire Totem]!", mapID = 1411, x = 0.389, y = 0.582 },
        },
        pins = {
            { mapID = 1411, x = 0.389, y = 0.582, label = "Shrine of the Dormant Flame — Durotar", detail = "Drink Fire Sapta -> slay Fire Manifestation -> Fire Totem!", kind = "objective" },
        },
    },
    [96] = {
        name = "Call of Water (Air/Water Totem)",
        summary = "Shaman Totem Finale (Water Totem): Drink [Water Sapta] beside the Silverpine/Ashenvale Shrine -> summon & defeat Corrupt Manifestation of Water!",
        steps = {
            { kind = "use", text = "Use [Water Sapta] near Islen Waterseer's Brazier (Ashenvale/Silverpine coast shrine) to reveal and defeat the Corrupt Minor Manifestation of Water." },
        },
    },
    [1785] = {
        name = "The Tome of Divinity (Turn-in)",
        summary = "Paladin Lvl 12 Resurrection Unlock: Speak to Tiza Battleforge in Ironforge Hall of Mysteries (27.4, 7.6) after reviving Henze Faulk!",
        steps = {
            { kind = "turnin", text = "Return to Tiza Battleforge in Ironforge (27.4, 7.6) to unlock [Redemption]!", mapID = 1455, x = 0.274, y = 0.076 },
        },
        pins = {
            { mapID = 1455, x = 0.274, y = 0.076, label = "Tiza Battleforge — Ironforge", detail = "Unlocks [Redemption] Resurrection spell", kind = "turnin" },
        },
    },
    [1788] = {
        name = "The Tome of Divinity (Stormwind Turn-in)",
        summary = "Paladin Lvl 12 Resurrection Unlock: Speak to Duthorian Rall in Stormwind Cathedral (39.8, 29.8) after completing the Westfall/Elwynn revival test.",
        steps = {
            { kind = "turnin", text = "Return to Duthorian Rall inside Stormwind Cathedral (39.8, 29.8) -> learns [Redemption]!", mapID = 1453, x = 0.398, y = 0.298 },
        },
        pins = {
            { mapID = 1453, x = 0.398, y = 0.298, label = "Duthorian Rall — Stormwind Cathedral", detail = "Paladin [Redemption] final turn-in", kind = "turnin" },
        },
    },
    [1652] = {
        name = "The Tome of Valor (Defend Daphne Stilwell)",
        summary = "Paladin Lvl 20 Wave Defense: Defend Daphne Stilwell at the southern Westfall orchard (41.7, 89.2) against 3 waves of Defias Raiders -> turn in to Stormwind Cathedral!",
        steps = {
            { kind = "objective", text = "Defend Daphne Stilwell at her southern Westfall farm (41.7, 89.2) against 3 waves of Defias Raiders (use healing & stuns between waves!).", mapID = 1436, x = 0.417, y = 0.892 },
            { kind = "turnin", text = "Return to Duthorian Rall inside Stormwind Cathedral (39.8, 29.8).", mapID = 1453, x = 0.398, y = 0.298 },
        },
    },
    [1661] = {
        name = "The Tome of Nobility",
        summary = "Paladin Lvl 40 Charger Prerequisite: Speak with Duthorian Rall in Stormwind Cathedral (39.8, 29.8) -> unlocks Summon Warhorse (free 40% mount!).",
        steps = {
            { kind = "turnin", text = "Speak with Duthorian Rall inside Cathedral of Light, Stormwind (39.8, 29.8) -> learn [Summon Warhorse]!", mapID = 1453, x = 0.398, y = 0.298 },
        },
        pins = {
            { mapID = 1453, x = 0.398, y = 0.298, label = "Duthorian Rall — Stormwind Cathedral", detail = "Unlocks free Lvl 40 [Summon Warhorse] mount", kind = "turnin" },
        },
    },
    [1471] = {
        name = "The Binding (Succubus / Undead Lock)",
        summary = "Warlock Summoning Circle Finale: Enter the summoning circle in Undercity Magic Quarter -> USE [Heartswood] / Summoning Rune -> defeat summoned Demon!",
        steps = {
            { kind = "use", text = "Stand inside the Undercity Warlock summoning circle -> USE the provided summoning focus, defeat the demon, and speak to your trainer.", mapID = 1458, x = 0.850, y = 0.250 },
        },
    },
    [1474] = {
        name = "The Binding (Voidwalker — Undercity)",
        summary = "Warlock Lvl 10 Voidwalker Unlock: Stand inside the Undercity summoning circle -> USE [Glyphs of Summoning] -> defeat Summoned Voidwalker!",
        steps = {
            { kind = "use", text = "Go to the Warlock Magic Quarter summoning circle in Undercity (85.0, 25.0) -> summon & defeat Voidwalker -> unlocks [Summon Voidwalker]!", mapID = 1458, x = 0.850, y = 0.250 },
        },
    },
    [1504] = {
        name = "The Binding (Voidwalker — Orgrimmar)",
        summary = "Warlock Lvl 10 Voidwalker Unlock: Go to Neeru Fireblade's cave in Orgrimmar Cleft of Shadow -> step into the circle -> summon & defeat Voidwalker!",
        steps = {
            { kind = "use", text = "In Cleft of Shadow, Orgrimmar (49.5, 50.0), stand on the floor summoning circle -> USE [Glyphs of Summoning] -> defeat Voidwalker -> unlock [Summon Voidwalker]!", mapID = 1454, x = 0.495, y = 0.500 },
        },
        pins = {
            { mapID = 1454, x = 0.495, y = 0.500, label = "Cleft of Shadow Circle — Orgrimmar", detail = "Summon & defeat Voidwalker to unlock pet", kind = "objective" },
        },
    },
    [1513] = {
        name = "The Binding (Succubus — Orgrimmar)",
        summary = "Warlock Lvl 20 Succubus Unlock: Stand on the summoning circle in Cleft of Shadow, Orgrimmar -> USE [Lesser Heartswood] -> defeat Summoned Succubus!",
        steps = {
            { kind = "use", text = "Step into the Cleft of Shadow circle in Orgrimmar (49.5, 50.0) -> USE the focus item -> defeat Succubus -> unlock [Summon Succubus]!", mapID = 1454, x = 0.495, y = 0.500 },
        },
    },
    [1689] = {
        name = "The Binding (Voidwalker — Stormwind)",
        summary = "Warlock Lvl 10 Voidwalker Unlock: Go down to the lowest basement beneath The Slaughtered Lamb in Mage Quarter, Stormwind -> defeat Voidwalker!",
        steps = {
            { kind = "use", text = "Walk deep down the spiral basement under The Slaughtered Lamb (Stormwind Mage Quarter 25.3, 78.2) -> stand in circle & use [Glyphs of Summoning]!", mapID = 1453, x = 0.253, y = 0.782 },
        },
        pins = {
            { mapID = 1453, x = 0.253, y = 0.782, label = "Slaughtered Lamb Basement — Stormwind", detail = "Deep basement summoning circle -> [Summon Voidwalker]", kind = "objective" },
        },
    },
    [1739] = {
        name = "The Binding (Succubus — Stormwind)",
        summary = "Warlock Lvl 20 Succubus Unlock: Go down to The Slaughtered Lamb summoning circle in Stormwind -> defeat the summoned Succubus!",
        steps = {
            { kind = "use", text = "Head to the lowest basement of The Slaughtered Lamb (Stormwind 25.3, 78.2) -> summon & defeat Succubus -> unlock [Summon Succubus]!", mapID = 1453, x = 0.253, y = 0.782 },
        },
    },
    [4490] = {
        name = "Summon Felsteed",
        summary = "Warlock Lvl 40 Free Mount: Speak directly with Strahad Farsan in Ratchet (62.6, 35.5) -> unlocks permanent [Summon Felsteed]!",
        steps = {
            { kind = "turnin", text = "Travel to Ratchet, The Barrens (62.6, 35.5) and speak with Strahad Farsan -> instant free [Summon Felsteed] mount!", mapID = 1413, x = 0.626, y = 0.355 },
        },
        pins = {
            { mapID = 1413, x = 0.626, y = 0.355, label = "Strahad Farsan — Free Lvl 40 Felsteed", detail = "Ratchet, The Barrens -> [Summon Felsteed]", kind = "turnin" },
        },
    },
    [4786] = {
        name = "The Completed Robe (Enchanted Gold Thread)",
        summary = "Warlock Lvl 31 Rare Chest ([Enchanted Gold Bloodrobe]): Bring [Briarthorn] / [Gold Bar] / Fine Thread to Menara Voidrender in Ratchet Hills (Barrens 62.4, 35.5).",
        steps = {
            { kind = "turnin", text = "Speak with Menara Voidrender just north of Ratchet (62.4, 35.5) after completing Demon/Component steps -> Rare [Enchanted Gold Bloodrobe]!", mapID = 1413, x = 0.624, y = 0.355 },
        },
    },
    [4964] = {
        name = "The Completed Orb of Dar'Orahil",
        summary = "Warlock Lvl 40 BiS Off-Hand ([Orb of Dar'Orahil]): Bring Infernal Orb components from Felwood/Desolace back to Tabetha in Dustwallow Marsh (46.0, 57.1).",
        steps = {
            { kind = "turnin", text = "Return to Tabetha in central Dustwallow Marsh (46.0, 57.1) -> Rare Off-Hand [Orb of Dar'Orahil]!", mapID = 1445, x = 0.460, y = 0.571 },
        },
        pins = {
            { mapID = 1445, x = 0.460, y = 0.571, label = "Tabetha's Farm — Dustwallow Marsh", detail = "Warlock Lvl 40 BiS Off-Hand turn-in", kind = "turnin" },
        },
    },
    [4975] = {
        name = "The Completed Orb of Noh'Orahil",
        summary = "Warlock Lvl 40 BiS Off-Hand ([Orb of Noh'Orahil]): Speak with Tabetha in Dustwallow Marsh (46.0, 57.1) after retrieving the Shadow Silk & Orb Shard.",
        steps = {
            { kind = "turnin", text = "Turn in to Tabetha at her tower in central Dustwallow Marsh (46.0, 57.1) -> Rare [Orb of Noh'Orahil]!", mapID = 1445, x = 0.460, y = 0.571 },
        },
        pins = {
            { mapID = 1445, x = 0.460, y = 0.571, label = "Tabetha's Tower — Dustwallow Marsh", detail = "Rewards Rare Off-Hand [Orb of Noh'Orahil]", kind = "turnin" },
        },
    },
    [1952] = {
        name = "Mage's Wand",
        summary = "Mage Lvl 40 BiS Wand ([Icefury Wand] / [Ragefire Wand] / [Nether Force Wand]): Gather mana reagents & visit Tabetha in Dustwallow Marsh (46.0, 57.1)!",
        steps = {
            { kind = "drop", text = "Complete Ur's Treatise / Mana Surge steps in Arathi & Thousand Needles before returning to Tabetha.", mapID = 1445, x = 0.460, y = 0.571 },
            { kind = "turnin", text = "Turn in to Tabetha in Dustwallow Marsh (46.0, 57.1) -> choose [Icefury Wand], [Ragefire Wand], or [Nether Force Wand]!", mapID = 1445, x = 0.460, y = 0.571 },
        },
        pins = {
            { mapID = 1445, x = 0.460, y = 0.571, label = "Tabetha — Mage's Wand", detail = "Lvl 40 Rare Wand turn-in", kind = "turnin" },
        },
    },
    [1958] = {
        name = "Celestial Power",
        summary = "Mage Lvl 40 BiS Off-Hand ([Celestial Orb]): Collect 3x [Power Stone] off Azshara or Dustwallow elementals -> turn in to Tabetha (46.0, 57.1)!",
        steps = {
            { kind = "drop", text = "Gather 3x [Celestial Power] / Power Stones as directed by Tabetha.", mapID = 1445, x = 0.460, y = 0.571 },
            { kind = "turnin", text = "Return to Tabetha in Dustwallow Marsh (46.0, 57.1) -> Rare [Celestial Orb]!", mapID = 1445, x = 0.460, y = 0.571 },
        },
    },

    -- =====================================================================
    -- 2f. Iconic Multi-Step BIS / EPIC / Open-World Guides
    -- =====================================================================
    [778] = {
        name = "This Is Going to Be Hard (Nifty Stopwatch Finale)",
        summary = "Badlands BiS Speed Trinket Finale: Activate the Ancient Stonewatcher -> protect/defeat the summoned Lvl 45 Rock Elemental Custodian -> [Nifty Stopwatch]!",
        steps = {
            { kind = "guide", text = "Requires [Gyromatic Micro-Adjustor] (AH / Engineering 1x) + [Patterned Bronze Bracers] (Blacksmithing/AH) on earlier steps!" },
            { kind = "objective", text = "Speak with Lotwil Veriatus in western Badlands (25.8, 44.2) -> defeat the Lvl 45 Fam'retor Guardian beside his wagon -> +40% Run Speed [Nifty Stopwatch]!", mapID = 1418, x = 0.258, y = 0.442 },
        },
        pins = {
            { mapID = 1418, x = 0.258, y = 0.442, label = "Lotwil Veriatus — Nifty Stopwatch", detail = "Spawn & defeat Guardian -> BiS Sprint Trinket [Nifty Stopwatch]", kind = "turnin" },
        },
    },
    [396] = {
        name = "An Audience with the King",
        summary = "Stockades Finale (Alliance BiS Ring): Take the Defias evidence from Bazil Thredd/Warden Thelwater to King Varian/Baros Alexston in Stormwind Keep -> [Seal of Wrynn]!",
        steps = {
            { kind = "turnin", text = "Walk into Stormwind Keep Throne Room (74.6, 48.2) and deliver the letter to Lord Ello Ebonlocke / Stormwind Throne -> BiS [Seal of Wrynn]!", mapID = 1453, x = 0.746, y = 0.482 },
        },
        pins = {
            { mapID = 1453, x = 0.746, y = 0.482, label = "Stormwind Keep Throne Room — Seal of Wrynn", detail = "Turn in 'An Audience with the King' -> Rare BiS Ring!", kind = "turnin" },
        },
    },
    [1318] = {
        name = "Unfinished Gordok Business",
        summary = "Dire Maul North Tribute Pre-req: Talk to Spirit of King Gordok AFTER becoming Tribute King (kill King Gordok WITHOUT killing Cho'Rush/Guards!) -> [Gordok's Handguards]!",
        steps = {
            { kind = "guide", text = "In Dire Maul North, skip or Frost Trap guards (wear [Gordok Ogre Suit]!) -> slay King Gordok ONLY." },
            { kind = "turnin", text = "Talk to Knot Thimblejack / Tribute Ogre -> leave dungeon only after looting Tribute Chest & speaking to Spirit for [Gordok's Handguards]!" },
        },
        items = {
            { id = 18258, name = "Gordok Ogre Suit", role = "precursor", source = "Crafted inside DM North by Knot Thimblejack (Ogre Tannin + 4 Runecloth + 8 Rugged Leather + 2 Bolt of Runecloth)" },
        },
    },
    [1383] = {
        name = "Nothing But The Truth (Duskwood Finale)",
        summary = "Lvl 42 Horde Duskwood Elixir / Cloak Finale: Collect [Panther Heart], [Kodo Horn], [Cheetah Blood] -> deliver to Apothecary Faustin in Duskwood (87.8, 35.6) -> [Cloak of Blight]!",
        steps = {
            { kind = "turnin", text = "Deliver all reagents to Apothecary Faustin near the eastern Duskwood/Deadwind pass road (87.8, 35.6) -> [Cloak of Blight]!", mapID = 1431, x = 0.878, y = 0.356 },
        },
        pins = {
            { mapID = 1431, x = 0.878, y = 0.356, label = "Apothecary Faustin — Nothing But The Truth", detail = "Eastern Duskwood pass -> [Cloak of Blight]", kind = "turnin" },
        },
    },
    [3962] = {
        name = "It's Dangerous to Go Alone (Blazerunner Finale)",
        summary = "Un'Goro Linken Chain Finale: Blazerunner is IMMUNE until you USE [Silver Totem of Aquementas] from your bags on him -> BiS [Linken's Sword of Mastery] / [Boomerang]!",
        steps = {
            { kind = "use", text = "Climb Fire Plume Ridge in central Un'Goro Crater (51.0, 49.0), target Blazerunner, and USE [Silver Totem of Aquementas] from your bags first to break his shield!", mapID = 1449, x = 0.510, y = 0.490, itemID = 11522, itemName = "Silver Totem of Aquementas" },
            { kind = "turnin", text = "Loot [Golden Flame] and return to Linken at Marshal's Refuge (44.6, 8.2) -> [Linken's Sword of Mastery] + [Linken's Boomerang]!", mapID = 1449, x = 0.446, y = 0.082 },
        },
        items = {
            { id = 11522, name = "Silver Totem of Aquementas", role = "precursor", source = "Reward from 'Aquementas' stone circle in Tanaris (70, 49) — MUST use on Blazerunner!" },
        },
        pins = {
            { mapID = 1449, x = 0.510, y = 0.490, label = "Blazerunner — Fire Plume Ridge", detail = "Use [Silver Totem of Aquementas] to drop immunity!", kind = "objective" },
            { mapID = 1449, x = 0.446, y = 0.082, label = "Linken — Marshal's Refuge", detail = "Rewards [Linken's Sword of Mastery] + [Linken's Boomerang]", kind = "turnin" },
        },
    },
    [4004] = {
        name = "The Princess Saved? (Horde BRD Finale)",
        summary = "Blackrock Depths BiS Horde Ring: Defeat Emperor Dagran Thaurissan in BRD while keeping Princess Moira alive -> speak to her -> Orgrimmar Throne!",
        steps = {
            { kind = "objective", text = "Inside Blackrock Depths Throne Room, burn Emperor Dagran Thaurissan DOWN WITHOUT killing High Priestess Moira Bronzebeard, then accept follow-up from her." },
            { kind = "turnin", text = "Deliver the news to Thrall in Valley of Wisdom, Orgrimmar (31.8, 37.8) -> BiS [Thrall's Resolve] / [Eye of Orgrimmar]!", mapID = 1454, x = 0.318, y = 0.378 },
        },
        pins = {
            { mapID = 1454, x = 0.318, y = 0.378, label = "Warchief Thrall — Grommash Hold", detail = "BRD Princess Saved Finale -> [Thrall's Resolve] / [Eye of Orgrimmar]", kind = "turnin" },
        },
    },
    [4363] = {
        name = "The Princess's Surprise (Alliance BRD Finale)",
        summary = "Blackrock Depths BiS Alliance Ring: Speak with King Magni Bronzebeard in Ironforge High Seat (39.0, 56.2) after freeing Princess Moira -> [Magni's Will] / [Songstone of Ironforge]!",
        steps = {
            { kind = "objective", text = "Inside BRD Throne Room, kill Emperor Dagran Thaurissan ONLY (do NOT cleave Moira!), speak to Princess Moira before leaving!" },
            { kind = "turnin", text = "Speak with King Magni Bronzebeard in Ironforge The High Seat (39.0, 56.2) -> BiS [Magni's Will] / [Songstone of Ironforge]!", mapID = 1455, x = 0.390, y = 0.562 },
        },
        pins = {
            { mapID = 1455, x = 0.390, y = 0.562, label = "King Magni Bronzebeard — Ironforge High Seat", detail = "BRD Princess Finale -> BiS [Magni's Will] / [Songstone of Ironforge]", kind = "turnin" },
        },
    },
    [5124] = {
        name = "Fiery Plate Gauntlets",
        summary = "Blacksmithing Pre-BiS Fire-Resist Gauntlets: Deliver 6x [Enchanted Thorium Bar], 2x [Essence of Fire], 4x [Star Ruby] to Master Blacksmith Lorax in southern Winterspring (63.8, 73.8)!",
        steps = {
            { kind = "gather", text = "Buy/bring 6x [Enchanted Thorium Bar], 2x [Essence of Fire], 4x [Star Ruby] BEFORE heading into southern Winterspring.", itemID = 12655, itemName = "Enchanted Thorium Bar" },
            { kind = "turnin", text = "Deliver to Master Blacksmith Lorax in southern Winterspring (63.8, 73.8) -> [Plans: Fiery Plate Gauntlets].", mapID = 1452, x = 0.638, y = 0.738 },
        },
        pins = {
            { mapID = 1452, x = 0.638, y = 0.738, label = "Lorax — Southern Winterspring", detail = "Bring 6x Ench. Thorium, 2x Essence of Fire, 4x Star Ruby", kind = "turnin" },
        },
    },
    [5265] = {
        name = "The Argent Hold (Argent Avenger Finale)",
        summary = "Stratholme/Scholo Turn-in: Talk to Commander Ashlam Valorfist at Light's Hope Chapel (EPL 81.4, 59.8) after finishing Tirion/Undead Stratholme steps -> [Argent Avenger]!",
        steps = {
            { kind = "turnin", text = "Speak with Betina Bigglezink / Duke Nicholas Zverenhoff at Light's Hope Chapel, Eastern Plaguelands (81.4, 59.8) -> glowing lightsaber [Argent Avenger]!", mapID = 1423, x = 0.814, y = 0.598 },
        },
        pins = {
            { mapID = 1423, x = 0.814, y = 0.598, label = "Light's Hope Chapel — Argent Avenger", detail = "Eastern Plaguelands BiS 1H Sword reward", kind = "turnin" },
        },
    },
    [5342] = {
        name = "The Last Barov (Horde -> Barov Peasant Caller)",
        summary = "Scholomance BiS Trinket: Grab ALL 4 Barov Deeds inside Scholomance ([Caer Darrow], [Southshore], [Tarren Mill], [Brill]) -> turn in to Alexi Barov at The Bulwark (Tirisfal 83.0, 68.5)!",
        steps = {
            { kind = "object", text = "Inside Scholomance, grab all 4 Deeds off tables/floors: [Deed to Southshore], [Deed to Tarren Mill], [Deed to Brill], [Deed to Caer Darrow].", itemID = 13471, itemName = "Deed to Caer Darrow" },
            { kind = "turnin", text = "Return all 4 deeds to Alexi Barov at The Bulwark (Tirisfal/WPL border 83.0, 68.5) -> [Barov Peasant Caller]!", mapID = 1420, x = 0.830, y = 0.685 },
        },
        items = {
            { id = 13471, name = "Deed to Caer Darrow", role = "required", source = "Inside Scholomance (Viewing Room / Vectus hall)" },
            { id = 13448, name = "Deed to Southshore", role = "required", source = "Inside Scholomance (Rattlegore hall table)" },
            { id = 13450, name = "Deed to Tarren Mill", role = "required", source = "Inside Scholomance (Reliquary / Marduk hall)" },
            { id = 13451, name = "Deed to Brill", role = "required", source = "Inside Scholomance (Krastinov wing table)" },
        },
        pins = {
            { mapID = 1420, x = 0.830, y = 0.685, label = "Alexi Barov — The Bulwark", detail = "Turn in all 4 Scholomance Deeds -> [Barov Peasant Caller]", kind = "turnin" },
        },
    },
    [5344] = {
        name = "The Last Barov (Alliance -> Barov Peasant Caller)",
        summary = "Scholomance BiS Trinket: Grab ALL 4 Barov Deeds inside Scholomance ([Caer Darrow], [Southshore], [Tarren Mill], [Brill]) -> Weldon Barov at Chillwind Camp (42.8, 83.8)!",
        steps = {
            { kind = "object", text = "Inside Scholomance, collect all 4 Deeds on dungeon tables/floors before resetting.", itemID = 13471, itemName = "Deed to Caer Darrow" },
            { kind = "turnin", text = "Return to Weldon Barov at Chillwind Camp, Western Plaguelands (42.8, 83.8) -> [Barov Peasant Caller]!", mapID = 1422, x = 0.428, y = 0.838 },
        },
        items = {
            { id = 13471, name = "Deed to Caer Darrow", role = "required", source = "Inside Scholomance" },
            { id = 13448, name = "Deed to Southshore", role = "required", source = "Inside Scholomance" },
            { id = 13450, name = "Deed to Tarren Mill", role = "required", source = "Inside Scholomance" },
            { id = 13451, name = "Deed to Brill", role = "required", source = "Inside Scholomance" },
        },
        pins = {
            { mapID = 1422, x = 0.428, y = 0.838, label = "Weldon Barov — Chillwind Camp", detail = "Turn in all 4 Scholomance Deeds -> [Barov Peasant Caller]", kind = "turnin" },
        },
    },
    [5944] = {
        name = "In Dreams (Mark of Fordring BiS Neck)",
        summary = "Classic Iconic Escort (Hearthglen): Put on your [Scarlet Disguise] BEFORE entering Hearthglen -> clear the tower BEFORE speaking to Taelan Fordring -> return to Tirion (EPL 7.6, 43.6)!",
        steps = {
            { kind = "use", text = "Put on [Scarlet Crusade Disguise] outside Hearthglen (WPL 45.0, 20.0) so Scarlet guards turn neutral — DO NOT break stealth/cast combat buffs if disguised!", mapID = 1422, x = 0.450, y = 0.200 },
            { kind = "objective", text = "Group up! Defeat Inquisitor Isillien after escaping Hearthglen gate (do not solo Isillien!)." },
            { kind = "turnin", text = "Speak with Tirion Fordring at Thondroril River, NW Eastern Plaguelands (7.6, 43.6) -> BiS Melee Neck [Mark of Fordring]!", mapID = 1423, x = 0.076, y = 0.436 },
        },
        pins = {
            { mapID = 1422, x = 0.450, y = 0.200, label = "Hearthglen Keep — Taelan Fordring Escort", detail = "GROUP RECOMMENDED! Equip Scarlet Disguise & clear tower first", kind = "objective" },
            { mapID = 1423, x = 0.076, y = 0.436, label = "Tirion Fordring — Mark of Fordring Finale", detail = "Western EPL riverbank -> BiS [Mark of Fordring]", kind = "turnin" },
        },
    },
    [5942] = {
        name = "Hidden Treasures (Tirion Finale -> Ring of Protection)",
        summary = "Speak with Tirion Fordring at Thondroril River (EPL 7.6, 43.6) -> follow his clue to the buried Strongbox behind his old Mardenholde homestead for [Ring of Protection]!",
        steps = {
            { kind = "object", text = "Follow Tirion's clue to the buried Strongbox near Mardenholde Keep / Tirion's Hidden Strongbox in Western Plaguelands (43.8, 17.6 or beside Tirion's farmstead) -> [Ring of Protection]!", mapID = 1423, x = 0.076, y = 0.436 },
        },
        pins = {
            { mapID = 1423, x = 0.076, y = 0.436, label = "Tirion Fordring — Thondroril River", detail = "Hidden Treasures chain -> [Ring of Protection] / [Argent Crusader]", kind = "turnin" },
        },
    },
    [6148] = {
        name = "The Scarlet Oracle, Demetria (Horde -> Gorewood Bow)",
        summary = "Lvl 60 Raid-Group Boss: Demetria patrols the Tyr's Hand - Northpass road in EPL with 6 Scarlet Elite guards! Trap/pull Demetria -> Nathanos Blightcaller (26.6, 74.8)!",
        steps = {
            { kind = "objective", text = "Bring a group! Ambush Scarlet Oracle Demetria & her 6 guards patrolling the southern EPL road between Corin's Crossing & Tyr's Hand (76, 68).", mapID = 1423, x = 0.760, y = 0.680 },
            { kind = "turnin", text = "Return to Nathanos Blightcaller at Marris Stead, EPL (26.6, 74.8) -> Pre-BiS [Gorewood Bow] / [Robe of the Unseen Path]!", mapID = 1423, x = 0.266, y = 0.748 },
        },
        pins = {
            { mapID = 1423, x = 0.760, y = 0.680, label = "Demetria Patrol Route (Group!)", detail = "Scarlet Oracle + 6 Elite Guards", kind = "objective" },
            { mapID = 1423, x = 0.266, y = 0.748, label = "Nathanos Blightcaller — Marris Stead", detail = "Rewards Pre-BiS [Gorewood Bow]", kind = "turnin" },
        },
    },
    [6187] = {
        name = "Order Must Be Restored (Alliance -> Gorewood Bow)",
        summary = "EPL Group Boss: Slay Nathanos Blightcaller at Marris Stead (Western EPL 26.6, 74.8) — summons Plaguehounds + 2 Elite Champions (bring 5-10+ players!) -> Ironforge!",
        steps = {
            { kind = "objective", text = "RAID/LARGE GROUP REQUIRED! Defeat Nathanos Blightcaller at Marris Stead, EPL (26.6, 74.8).", mapID = 1423, x = 0.266, y = 0.748 },
            { kind = "turnin", text = "Return to Bolvar Fordragon in Stormwind Keep (78.2, 18.2) -> Pre-BiS [Gorewood Bow] / [Mark of Resolution]!", mapID = 1453, x = 0.782, y = 0.182 },
        },
        pins = {
            { mapID = 1423, x = 0.266, y = 0.748, label = "Nathanos Blightcaller (Raid Group!)", detail = "Marris Stead, EPL — kill for Order Must Be Restored", kind = "objective" },
            { mapID = 1453, x = 0.782, y = 0.182, label = "Highlord Bolvar Fordragon — Stormwind Keep", detail = "Rewards Pre-BiS [Gorewood Bow]", kind = "turnin" },
        },
    },
    [7181] = {
        name = "The Legend of Korrak (Horde -> Bloodseeker)",
        summary = "Alterac Valley Pre-BiS Crossbow ([Bloodseeker]): Enter Alterac Valley BG -> defeat Korrak the Bloodrager at Snowfall Graveyard -> Frostwolf Keep!",
        steps = {
            { kind = "objective", text = "Queue Alterac Valley -> slay Korrak the Bloodrager atop Snowfall Graveyard hill with your BG team -> turn in inside Frostwolf Keep for [Bloodseeker] / [Ice Barbed Spear]!" },
        },
    },
    [7202] = {
        name = "Korrak the Bloodrager (Alliance -> Bloodseeker)",
        summary = "Alterac Valley Pre-BiS Crossbow ([Bloodseeker]): Enter Alterac Valley BG -> defeat Korrak the Bloodrager at Snowfall Graveyard -> Dun Baldar North Bunker!",
        steps = {
            { kind = "objective", text = "Queue Alterac Valley -> slay Korrak the Bloodrager at Snowfall Graveyard -> turn in at Stormpike Aid Station for [Bloodseeker] / [Ice Barbed Spear]!" },
        },
    },
    [7462] = {
        name = "The Treasure of the Shen'dralar (Dire Maul)",
        summary = "Dire Maul West BiS Weapons ([Bonecrusher] / [Backwood Helm]): Speak with Pusillin/Lorekeeper Lydros or click the Ancient Chest beside Prince Tortheldrin after killing him!",
        steps = {
            { kind = "object", text = "Inside Dire Maul West, defeat Prince Tortheldrin -> click the Shen'dralar Chest / speak with Lorekeeper in DM Library to claim [The Treasure of the Shen'dralar]!" },
        },
    },
    [7877] = {
        name = "The Treasure of the Shen'dralar (Alternate Turn-in)",
        summary = "Dire Maul West Finale: Claim your Rare Q3 gear ([Bonecrusher] / [Backwood Helm] / [Sedge Boots]) at the Shen'dralar chest in DM Library after slaying Prince Tortheldrin.",
        steps = {
            { kind = "object", text = "In Dire Maul West Athenaeum after defeating Prince Tortheldrin, interact with the Treasure of the Shen'dralar chest!" },
        },
    },
    [7486] = {
        name = "A Hero's Reward",
        summary = "Duke Hydraxis Molten Core Finale (Azshara): Complete Hydraxian Waterlords MC chain -> speak to Duke Hydraxis on his island off SE Azshara (79.2, 73.6) -> [Ocean's Breeze]!",
        steps = {
            { kind = "turnin", text = "Swim/mount east off southeastern Azshara shore to Hydraxian Waterlords island (79.2, 73.6) -> speak to Duke Hydraxis for Rare [Ocean's Breeze]!", mapID = 1447, x = 0.792, y = 0.736 },
        },
        pins = {
            { mapID = 1447, x = 0.792, y = 0.736, label = "Duke Hydraxis — Hydraxian Island", detail = "Off SE Azshara coast -> [Ocean's Breeze]", kind = "turnin" },
        },
    },
    [7649] = {
        name = "Enchanted Thorium Platemail: Volume I",
        summary = "Blacksmithing Breastplate Plans: Deliver [Enchanted Thorium Platemail: Volume I], [Arcanite Bar] / [Large Brilliant Shard] & [Arcane Crystal] inside Dire Maul Library!",
        steps = {
            { kind = "turnin", text = "Bring [Enchanted Thorium Platemail: Volume I] + required materials to Lorekeeper Kildrath inside Dire Maul Library (North/West wing passage)." },
        },
    },
    [7650] = {
        name = "Enchanted Thorium Platemail: Volume II",
        summary = "Blacksmithing Leggings Plans: Turn in [Enchanted Thorium Platemail: Volume II] + Pristine Black Diamond/Large Brilliant Shards to Lorekeeper inside Dire Maul Library.",
        steps = {
            { kind = "turnin", text = "Deliver [Enchanted Thorium Platemail: Volume II] + reagents to the Shen'dralar Lorekeeper inside Dire Maul Library." },
        },
    },
    [7651] = {
        name = "Enchanted Thorium Platemail: Volume III",
        summary = "Blacksmithing Helm Plans: Deliver [Enchanted Thorium Platemail: Volume III] + reagents to the Shen'dralar Lorekeeper in Dire Maul Library.",
        steps = {
            { kind = "turnin", text = "Deliver [Enchanted Thorium Platemail: Volume III] + reagents inside Dire Maul Library for [Plans: Enchanted Thorium Helm]." },
        },
    },
    [7862] = {
        name = "Job Opening: Guard Captain of Revantusk Village",
        summary = "MUST-DO Horde BiS Melee Trinket! Rewards [Rune of the Guard Captain] (+20 AP, +1% Hit)! Slay Vilebranch trolls across Jintha'Alor (The Hinterlands 63, 73).",
        steps = {
            { kind = "objective", text = "Accept from Primal Torntusk in Revantusk Village (78.2, 81.2) -> slay 20 Berserkers, 20 Scalpers, 20 Shadowcasters & 20 Soulflayers up the tiers of Jintha'Alor (63.0, 73.0).", mapID = 1425, x = 0.630, y = 0.730 },
            { kind = "turnin", text = "Return to Primal Torntusk in Revantusk Village (78.2, 81.2) -> BiS Hit Trinket [Rune of the Guard Captain]!", mapID = 1425, x = 0.782, y = 0.812 },
        },
        pins = {
            { mapID = 1425, x = 0.630, y = 0.730, label = "Jintha'Alor Trolls (Group Helpful!)", detail = "20x each of 4 Vilebranch caster/melee types", kind = "objective" },
            { mapID = 1425, x = 0.782, y = 0.812, label = "Primal Torntusk — Revantusk Village", detail = "Rewards BiS [Rune of the Guard Captain] (+1% Hit Trinket)", kind = "turnin" },
        },
    },
    [8183] = {
        name = "The Heart of Hakkar",
        summary = "Zul'Gurub Raid Epic Turn-in: Deliver [Heart of Hakkar] to Molthor on Yojamba Isle (NW Stranglethorn Vale 14.2, 15.8) -> spawns Server World Buff + Epic Trinket/Neck!",
        steps = {
            { kind = "turnin", text = "Fly/swim to Yojamba Isle in NW Stranglethorn Vale (14.2, 15.8) and hand [Heart of Hakkar] to Molthor -> [Zandalarian Hero Charm] / [Zandalarian Hero Medallion] + World Buff!", mapID = 1434, x = 0.142, y = 0.158 },
        },
        pins = {
            { mapID = 1434, x = 0.142, y = 0.158, label = "Molthor — Yojamba Isle", detail = "Heart of Hakkar -> Zandalarian Hero Charm + Rallying Cry buff!", kind = "turnin" },
        },
    },
    [140] = {
        name = "Captain Sander's Hidden Treasure (Finale)",
        summary = "Hidden Westfall Treasure Hunt (Lvl 16): Starts from [Captain Sander's Treasure Map] dropped by Westfall murlocs -> final chest lies on the northern island (25.9, 16.9)!",
        steps = {
            { kind = "object", text = "1) Broken Barrel at Westfall lighthouse shoreline (40.5, 47.8) -> 2) Old Jug near Moonbrook crossroads (40.5, 47.8) -> 3) Locked Chest -> final island chest!", mapID = 1436, x = 0.405, y = 0.478 },
            { kind = "turnin", text = "Swim out to the small island off northwest Westfall (25.9, 16.9) -> open Captain Sander's Chest for [Captain Sander's Booty Bag] + Rare Shirt/Sash!", mapID = 1436, x = 0.259, y = 0.169 },
        },
        pins = {
            { mapID = 1436, x = 0.259, y = 0.169, label = "Captain Sander's Chest — NW Island", detail = "Swim north-west from Westfall shore -> hidden treasure finale", kind = "turnin" },
        },
    },
}

-- Title-based open-world & recurring quest guides (catches Alliance/Horde ID variants too!)
local TITLE_GUIDES = {
    ["...and that note you found"] = {
        summary = "Secret Cozy Sleeping Bag Step 1-2: Examine Burned-Out Remains (Alliance: Westfall 37.1, 50.1 / Horde: Barrens 46.1, 74.3) -> then travel to the OPPOSITE faction's ruins!",
        steps = {
            { kind = "object", text = "Alliance: Westfall (37.1, 50.1) / Horde: Barrens burnt tower (46.1, 74.3) -> click Burned-Out Remains", mapID = 1436, x = 0.371, y = 0.501 },
            { kind = "object", text = "Next go to the opposite faction's ruins (Barrens 46.1, 74.3 or Westfall 37.1, 50.1) to turn in -> 'Stepping Stones'", mapID = 1413, x = 0.461, y = 0.743 },
        },
        pins = {
            { mapID = 1436, x = 0.371, y = 0.501, label = "Burned-Out Remains (Westfall)", detail = "Cozy Sleeping Bag chain (Westfall leg)", kind = "objective" },
            { mapID = 1413, x = 0.461, y = 0.743, label = "Burned Tower (Barrens)", detail = "Cozy Sleeping Bag chain (Barrens leg)", kind = "objective" },
        },
    },
    ["stepping stones"] = {
        summary = "Cozy Sleeping Bag Step 3: Travel to Stonetalon Mountains abandoned camp NE of Sun Rock Retreat (40.6, 52.4).",
        steps = {
            { kind = "object", text = "Follow path NE from Sun Rock Retreat to abandoned camp (40.6, 52.4 Stonetalon) and examine Pocket Litter", mapID = 1442, x = 0.406, y = 0.524 },
        },
        pins = {
            { mapID = 1442, x = 0.406, y = 0.524, label = "Abandoned Camp (Cozy Sleeping Bag)", detail = "Pocket Litter / Stepping Stones step", kind = "objective" },
        },
    },
    ["scramble"] = {
        summary = "Cozy Sleeping Bag Step 4: Climb hill north of Stonetalon camp, jump across gap to Mound of Dirt (39.6, 49.8).",
        steps = {
            { kind = "object", text = "Go north up hill -> jump gap -> click Mound of Dirt at (39.6, 49.8 Stonetalon)", mapID = 1442, x = 0.396, y = 0.498 },
        },
        pins = {
            { mapID = 1442, x = 0.396, y = 0.498, label = "Mound of Dirt (Scramble)", detail = "Jump across gap north of camp", kind = "objective" },
        },
    },
    ["wet job"] = {
        summary = "Cozy Sleeping Bag Step 5: Loch Modan Stonewrought Dam (49.4, 12.9) — jump onto carved dwarf heads facing Wetlands for Eagle Figurine!",
        steps = {
            { kind = "object", text = "Go to Loch Modan Dam (49.4, 12.9) -> jump onto stone heads on Wetlands-facing side -> click Eagle Figurine", mapID = 1432, x = 0.494, y = 0.129 },
        },
        pins = {
            { mapID = 1432, x = 0.494, y = 0.129, label = "Eagle Figurine (Loch Modan Dam)", detail = "Drop onto carved stone heads facing Wetlands", kind = "objective" },
        },
    },
    ["eagle's fist"] = {
        summary = "Cozy Sleeping Bag Finale: On Thoradin's Wall (Hillsbrad 93.4, 39.6 / Arathi 22.4, 24.3) — climb cart onto wall -> open Messenger Bag!",
        steps = {
            { kind = "object", text = "At Thoradin's Wall, climb cart near Hillsbrad (93.4, 39.6 / Arathi 22.4, 24.3) onto ledge -> click hanging Messenger Bag -> Cozy Sleeping Bag (+3% XP buff)!", mapID = 1417, x = 0.224, y = 0.243 },
        },
        pins = {
            { mapID = 1417, x = 0.224, y = 0.243, label = "Messenger Bag (Thoradin's Wall)", detail = "Climb cart on Hillsbrad side -> Cozy Sleeping Bag Finale", kind = "turnin" },
        },
    },
    ["camping 101: cooking"] = {
        summary = "Forever Camping 101: Requires Skill 20+ in Cooking. Gather simple profession mats -> return to zone Camping host (Raan Wildwind / Syriel Nightrain / camp NPC).",
        steps = {
            { kind = "guide", text = "First reach Skill Level 20 in Cooking, buy/cook simple recipe mats, then speak with the follow-up Camping trainer in your log." },
        },
    },
    ["camping 101: herbalism"] = {
        summary = "Forever Camping 101: Requires Herbalism 20+. Gather Peacebloom/Silverleaf -> turn in to Camping host.",
        steps = {
            { kind = "guide", text = "Reach Herbalism skill 20+, gather Peacebloom/Silverleaf nearby, and return to the Camping NPC in your log." },
        },
    },
    ["dark heart"] = {
        summary = "Feralas: Edana Hatetalon does NOT spawn alone — first loot [Horn of Hatetalon] from harpies and blow it at Hatetalon Stones (40, 9)!",
        steps = {
            { kind = "drop", text = "Kill Northspring Harpies in NW Feralas for [Horn of Hatetalon]", mapID = 1444, x = 0.400, y = 0.120, itemName = "Horn of Hatetalon" },
            { kind = "use", text = "Stand near the Hatetalon Stones (40, 9 Feralas) and blow [Horn of Hatetalon] to summon Edana Hatetalon", mapID = 1444, x = 0.400, y = 0.090 },
        },
        pins = {
            { mapID = 1444, x = 0.400, y = 0.090, label = "Hatetalon Stones — Summon Edana", detail = "Loot [Horn of Hatetalon] from harpies first, then blow here!", kind = "objective" },
        },
    },
    ["stinglasher"] = {
        summary = "Feralas: Elite silithid Stinglasher patrols around southern hive (74, 62 Feralas).",
        steps = {
            { kind = "objective", text = "Kill Stinglasher (Lvl 48 Elite) around (74, 62) in eastern/southern Feralas", mapID = 1444, x = 0.740, y = 0.620 },
        },
        pins = {
            { mapID = 1444, x = 0.740, y = 0.620, label = "Stinglasher (Lvl 48 Elite)", detail = "Feralas hive patrol", kind = "objective" },
        },
    },
    ["the great outdoors"] = {
        summary = "Forever Camping intro (Lvl 4+): Follow pointer to the starter campfire in your zone and click it to unlock Camping.",
        steps = {
            { kind = "object", text = "Locate the glowing starter campfire near your starting hub (check quest text/minimap) and interact with it." },
        },
    },
    ["the adventurer"] = {
        summary = "Forever Camping intro: Travel to your faction/race Camp Host to unlock Camping 101 profession quests (requires Skill 20 in a profession).",
        steps = {
            { kind = "guide", text = "Speak with the Camp Host NPC in your starting zone to open Camping quests (each Camping 101 requires Skill 20 in that profession)." },
        },
    },
}

-- Merge OPEN_WORLD_GUIDES into Data.QuestGuides (without clobbering FDJ fields if richer, or enriching steps/pins)
for qid, g in pairs(OPEN_WORLD_GUIDES) do
    local existing = Data.QuestGuides[qid]
    if existing then
        if g.steps and #g.steps > 0 then existing.steps = g.steps end
        if g.items and #g.items > 0 then
            existing.items = existing.items or {}
            for _, it in ipairs(g.items) do table.insert(existing.items, it) end
        end
        if g.pins and #g.pins > 0 then
            existing.pins = existing.pins or {}
            for _, p in ipairs(g.pins) do table.insert(existing.pins, p) end
        end
        if g.summary then existing.summary = g.summary end
        if g.name and not existing.name then existing.name = g.name end
    else
        Data.QuestGuides[qid] = g
    end
end

for titleKey, g in pairs(TITLE_GUIDES) do
    Data.QuestGuidesByTitle[titleKey] = g
end

-- Sync guides by title from QuestGuides that have explicit names
for qid, g in pairs(Data.QuestGuides) do
    if g.name and g.name ~= "" then
        local tk = CleanKey(g.name)
        if tk ~= "" and not Data.QuestGuidesByTitle[tk] then
            Data.QuestGuidesByTitle[tk] = g
        end
    end
end

-- =========================================================================
-- 3. Reverse Item -> Quest Index (for Bag / Vendor / AH / Loot Tooltips!)
-- =========================================================================
local _itemIDToGuides = {}
local _itemNameToGuides = {}
local _reverseIndexBuilt = false

local function RegisterItemMapping(it, qid, qTitle, guideSummary)
    if not it or not it.name or it.name == "" then return end
    local rec = {
        questID = qid,
        title = qTitle,
        role = it.role or "required",
        source = it.source,
        leadsTo = it.leadsTo,
        summary = guideSummary,
    }
    if it.id and type(it.id) == "number" and it.id > 0 then
        _itemIDToGuides[it.id] = _itemIDToGuides[it.id] or {}
        local dup = false
        for _, ex in ipairs(_itemIDToGuides[it.id]) do
            if ex.questID == qid then dup = true break end
        end
        if not dup then table.insert(_itemIDToGuides[it.id], rec) end
    end
    local ik = CleanKey(it.name)
    if ik ~= "" then
        _itemNameToGuides[ik] = _itemNameToGuides[ik] or {}
        local dup = false
        for _, ex in ipairs(_itemNameToGuides[ik]) do
            if ex.questID == qid then dup = true break end
        end
        if not dup then table.insert(_itemNameToGuides[ik], rec) end
    end
end

local function BuildItemReverseIndex()
    if _reverseIndexBuilt then return end
    _reverseIndexBuilt = true
    for qid, g in pairs(Data.QuestGuides) do
        local qTitle = g.name
        if not qTitle and Data.QuestPayoffs and Data.QuestPayoffs[qid] and Data.QuestPayoffs[qid].name then
            qTitle = Data.QuestPayoffs[qid].name
        end
        if not qTitle then qTitle = "Quest #" .. tostring(qid) end
        for _, it in ipairs(g.items or {}) do
            RegisterItemMapping(it, qid, qTitle, g.summary)
        end
    end
    for k, dep in pairs(Data.ItemDependencies) do
        if dep.id and type(dep.id) == "number" and dep.id > 0 then
            Data._itemDepByID = Data._itemDepByID or {}
            Data._itemDepByID[dep.id] = dep
        end
    end
end

-- =========================================================================
-- 4. Runtime API: GetQuestGuide, GetItemQuestUsage, GetActiveDependencyPins
-- =========================================================================
local _guideMemo = {}

function Data.InvalidateGuideCache()
    _guideMemo = {}
end

local function MatchDependencyByObjectiveText(text)
    if not text or text == "" then return nil end
    local lower = CleanKey(text)
    -- Strip trailing progress ": 0/1" or " 0/10"
    local stripped = string.gsub(lower, "%s*:%s*%d+/%d+%s*$", "")
    stripped = string.gsub(stripped, "%s*%d+/%d+%s*$", "")
    stripped = string.gsub(stripped, "^%s*(.-)%s*$", "%1")
    if Data.ItemDependencies[stripped] then
        return Data.ItemDependencies[stripped]
    end
    for depKey, dep in pairs(Data.ItemDependencies) do
        if #depKey >= 4 and string.find(lower, depKey, 1, true) then
            return dep
        end
    end
    return nil
end

-- Check live Quest Log objectives for an active quest to detect item dependencies
local function ScanLiveLogObjectiveDependencies(questID)
    if not questID or questID <= 0 then return nil end
    local logIdx = addon.Utils and addon.Utils.GetQuestLogIndex and addon.Utils.GetQuestLogIndex(questID)
    if not logIdx then return nil end

    local found = nil
    local numObj = (GetNumQuestLeaderBoards and GetNumQuestLeaderBoards(logIdx)) or 0
    if numObj > 0 and GetQuestLogLeaderBoard then
        for i = 1, numObj do
            local ok, text, objType, finished = pcall(GetQuestLogLeaderBoard, i, logIdx)
            if ok and text and text ~= "" and not finished then
                local dep = MatchDependencyByObjectiveText(text)
                if dep then
                    found = found or {}
                    table.insert(found, dep)
                end
            end
        end
    end
    return found
end

function Data.GetQuestGuide(questID, questTitle)
    local numID = tonumber(questID)
    local targetID = (numID and numID == numID and numID > 0 and numID < math.huge) and numID or nil
    local rawTitle = (type(questTitle) == "string" and questTitle ~= "") and questTitle or nil

    if (not rawTitle or rawTitle == "") and targetID and addon.Utils and addon.Utils.GetQuestBasicInfo then
        local info = addon.Utils.GetQuestBasicInfo(targetID)
        if info and info.title then rawTitle = info.title end
    end
    local cleanTitle = CleanKey(rawTitle)

    local base = nil
    if targetID and Data.QuestGuides[targetID] then
        base = Data.QuestGuides[targetID]
    elseif cleanTitle ~= "" then
        base = Data.QuestGuidesByTitle[cleanTitle]
        if not base then
            local noThe = string.gsub(cleanTitle, "^the%s+", "")
            base = Data.QuestGuidesByTitle[noThe]
        end
    end

    -- Check Craftsman's Writ: <Item Name> or Camping 101: <Prof> pattern
    local dynCraftDep = nil
    if cleanTitle ~= "" then
        local writItem = string.match(cleanTitle, "^craftsman's writ:%s*(.+)$")
        if writItem then
            dynCraftDep = Data.ItemDependencies[writItem] or {
                name = writItem,
                kind = "craft",
                source = "Crafted via Profession or bought on Auction House",
                before = "Craft [" .. writItem .. "] (or buy on AH), then turn in the Writ at your faction Commerce NPC for Rep + Coin Pouch.",
            }
        elseif not base then
            local campProf = string.match(cleanTitle, "^camping 101:%s*(.+)$")
            if campProf then
                base = {
                    summary = "Forever Camping 101 (" .. campProf .. "): Reach Skill 20 in " .. campProf .. ", gather starter mats, and return to the Camping NPC in your log.",
                    steps = {
                        { kind = "guide", text = "First reach Skill Level 20 in " .. campProf .. ", gather/craft requested item, then return to Camping host." },
                    },
                }
            end
        end
    end

    -- Scan live quest log objectives for matching ItemDependencies (e.g. Bronze Tube, Frost Oil, Morrowgrain...)
    local liveDeps = ScanLiveLogObjectiveDependencies(targetID)

    -- Fall back to existing Tips/Payoffs if no structured QuestGuides entry yet
    local payoff = addon.Data.GetQuestPayoff and addon.Data.GetQuestPayoff(targetID, rawTitle)
    local tipText = (payoff and payoff.tip) or (addon.Data.GetQuestTip and addon.Data.GetQuestTip(targetID, rawTitle))

    if not base and not dynCraftDep and not liveDeps and not (tipText and tipText ~= "") and not (payoff and payoff.unlock) then
        return nil
    end

    -- Merge cleanly into a fresh/lightweight guide response
    local steps = {}
    local seenStep = {}
    local function addStep(st)
        if not st or not st.text or st.text == "" or seenStep[st.text] then return end
        seenStep[st.text] = true
        local copy = {
            text = st.text,
            kind = st.kind or "guide",
            itemID = st.itemID,
            itemName = st.itemName,
            mapID = st.mapID,
            x = st.x,
            y = st.y,
        }
        table.insert(steps, copy)
    end

    if base and base.steps then
        for _, st in ipairs(base.steps) do
            addStep(st)
        end
    end
    if dynCraftDep then
        addStep({
            kind = dynCraftDep.kind or "craft",
            itemID = dynCraftDep.id,
            itemName = dynCraftDep.name,
            text = dynCraftDep.before or dynCraftDep.source,
        })
    end
    if liveDeps then
        for _, dep in ipairs(liveDeps) do
            addStep({
                kind = dep.kind or "item",
                itemID = dep.id,
                itemName = dep.name,
                text = dep.before or dep.source,
            })
        end
    end
    if #steps == 0 and tipText and tipText ~= "" then
        addStep({ kind = "tip", text = tipText })
    end

    local summary = (base and base.summary)
        or (dynCraftDep and (dynCraftDep.before or dynCraftDep.source))
        or (liveDeps and liveDeps[1] and (liveDeps[1].before or liveDeps[1].source))
        or tipText

    return {
        questID = targetID,
        title = (base and base.name) or rawTitle or (payoff and payoff.name),
        summary = summary,
        pickup = base and base.pickup or (payoff and payoff.pickup),
        turnin = base and base.turnin or (payoff and payoff.turnin),
        warning = base and base.warning,
        steps = steps,
        items = base and base.items or {},
        pins = base and base.pins or {},
        hasLiveBagCheck = true,
        GetItemCount = SafeGetItemCount,
        GetStepBagProgress = Data.GetStepBagProgress,
    }
end

function Data.GetItemQuestUsage(itemID, itemName)
    BuildItemReverseIndex()
    local numID = tonumber(itemID)
    local cleanName = CleanKey(itemName)

    local starter = numID and Data.SecretQuestStarters and Data.SecretQuestStarters[numID]
    local starterQID = (starter and starter.questID) or (numID and Data.ItemQuestMap and Data.ItemQuestMap[numID])
    local dep = (numID and Data._itemDepByID and Data._itemDepByID[numID]) or (cleanName ~= "" and Data.ItemDependencies[cleanName]) or nil

    local usages = {}
    local seenQ = {}
    local function appendList(list)
        if not list then return end
        for _, u in ipairs(list) do
            if not seenQ[u.questID] then
                seenQ[u.questID] = true
                local inLog = addon.Utils and addon.Utils.IsQuestInLog and addon.Utils.IsQuestInLog(u.questID)
                table.insert(usages, {
                    questID = u.questID,
                    title = u.title,
                    role = u.role,
                    source = u.source,
                    leadsTo = u.leadsTo,
                    summary = u.summary,
                    inLog = inLog and true or false,
                })
            end
        end
    end

    if numID then appendList(_itemIDToGuides[numID]) end
    if cleanName ~= "" then appendList(_itemNameToGuides[cleanName]) end

    if not starter and not starterQID and not dep and #usages == 0 then
        return nil
    end

    return {
        starter = starter,
        starterQuestID = starterQID,
        dep = dep,
        usages = usages,
    }
end

local AUTO_DEPENDENCY_KINDS = {
    item = true, craft = true, vendor = true, use = true, object = true,
    drop = true, gather = true, combine = true, summon = true, key = true,
    precursor = true, starter = true,
}

function Data.GetActiveDependencyPins(manualQuestID, focusedQuestID)
    local pins = {}
    local seen = {}
    local seenQuests = {}

    local function isValidQuestID(qid)
        return type(qid) == "number" and qid == qid and qid > 0 and qid < 1e9
    end

    local function collectForQuest(qid, isManual)
        if not isValidQuestID(qid) or seenQuests[qid] then return end
        seenQuests[qid] = true
        local guide = Data.GetQuestGuide(qid)
        if not guide then return end

        local isComplete = addon.Utils and addon.Utils.IsQuestComplete and addon.Utils.IsQuestComplete(qid)
        local title = guide.title or (addon.Utils and addon.Utils.GetQuestTitle and addon.Utils.GetQuestTitle(qid)) or ("Quest #" .. qid)
        local hasMultiOrItems = ((guide.steps and #guide.steps >= 2) or (guide.items and #guide.items >= 1)) and true or false

        local function ShouldIncludeKind(kind)
            if isManual then return true end
            if isComplete then return false end
            if AUTO_DEPENDENCY_KINDS[kind] then return true end
            if kind == "objective" and hasMultiOrItems then return true end
            return false
        end

        -- Add step-level pins first (skip item steps already satisfied in player bags)
        for idx, st in ipairs(guide.steps or {}) do
            if st.mapID and st.x and st.y and ShouldIncludeKind(st.kind) then
                local haveEnough = false
                if (st.kind == "item" or st.kind == "drop" or st.kind == "gather" or st.kind == "craft" or st.kind == "vendor") and (st.itemID or st.itemName) then
                    local _, _, satisfied = Data.GetStepBagProgress(st)
                    haveEnough = satisfied
                end
                if isManual or not haveEnough then
                    local key = string.format("%d:%.3f:%.3f:%d", st.mapID, st.x, st.y, qid)
                    if not seen[key] then
                        seen[key] = true
                        table.insert(pins, {
                            questID = qid,
                            questTitle = title,
                            stepIdx = idx,
                            mapID = st.mapID,
                            x = st.x,
                            y = st.y,
                            label = string.format("[%d] %s", idx, title),
                            detail = st.text,
                            kind = st.kind,
                            isManual = isManual and true or false,
                        })
                    end
                end
            end
        end

        -- Fall back to guide.pins ONLY for actionable/missing dependency points (never duplicate ordinary quest-giver NPCs)
        for idx, p in ipairs(guide.pins or {}) do
            if p.mapID and p.x and p.y and ShouldIncludeKind(p.kind) then
                local key = string.format("%d:%.3f:%.3f:%d", p.mapID, p.x, p.y, qid)
                if not seen[key] then
                    seen[key] = true
                    table.insert(pins, {
                        questID = qid,
                        questTitle = title,
                        stepIdx = idx,
                        mapID = p.mapID,
                        x = p.x,
                        y = p.y,
                        label = p.label or title,
                        detail = p.detail or guide.summary,
                        kind = p.kind or "guide",
                        isManual = isManual and true or false,
                    })
                end
            end
        end
    end

    if isValidQuestID(manualQuestID) then
        collectForQuest(manualQuestID, true)
    end

    -- Show helper pins for focused/selected complicated quests only (zero clutter across the map by default)
    if isValidQuestID(focusedQuestID) then
        collectForQuest(focusedQuestID, false)
    elseif type(focusedQuestID) == "table" then
        for _, qid in ipairs(focusedQuestID) do
            collectForQuest(qid, false)
        end
    end

    return pins
end
