--[[
    WorthIt / QuestWorth - Data/Zones.lua
    Classic & WoW Forever geographical leveling zone database.
    Contains level brackets, faction-specific entry levels, map metadata,
    and mob ecology tags (undead, elemental, mechanical, humanoid, beasts, open terrain, caves).
]]

local addonName, addon = ...
addon.Data = addon.Data or {}

addon.Data.Zones = {
    -- =========================================================================
    -- EASTERN KINGDOMS
    -- =========================================================================
    ["Dun Morogh"]          = { min = 1,  max = 10, faction = "Alliance",  continent = 2, mapID = 1426, beastHeavy = true, humanoidHeavy = true,
        density = "Very High", hubMod = 0.05, allianceHub = "Kharanos & Anvilmar",
        summary = "Dense starter zone with smooth 1-10 progression across Anvilmar, Kharanos, and Amberstill Ranch." },
    ["Elwynn Forest"]       = { min = 1,  max = 10, faction = "Alliance",  continent = 2, mapID = 1429, humanoidHeavy = true, beastHeavy = true,
        density = "Very High", hubMod = 0.05, allianceHub = "Goldshire & Northshire",
        summary = "Highest-efficiency Alliance 1-10 loop; tight hubs in Northshire, Goldshire, and Eastvale Logging Camp." },
    ["Tirisfal Glades"]     = { min = 1,  max = 10, faction = "Horde",     continent = 2, mapID = 1420, undeadHeavy = true, humanoidHeavy = true,
        density = "Very High", hubMod = 0.05, hordeHub = "Brill & Deathknell",
        summary = "Fast Forsaken 1-10 progression with Scarlet & Scourge hubs centered at Deathknell and Brill." },
    ["Loch Modan"]          = { min = 10, max = 20, faction = "Alliance",  continent = 2, mapID = 1432, allianceMin = 10, humanoidHeavy = true, beastHeavy = true,
        density = "Very High", hubMod = 0.04, allianceHub = "Thelsamar & Farstrider Lodge",
        summary = "Compact 10-18 quest loops around Thelsamar and the lake; watch for Elite Mo'grosh Ogres in the east." },
    ["Westfall"]            = { min = 10, max = 20, faction = "Alliance",  continent = 2, mapID = 1436, allianceMin = 10, humanoidHeavy = true, mechanicalHeavy = true, openTerrain = true,
        density = "Very High", hubMod = 0.05, allianceHub = "Sentinel Hill",
        summary = "Iconic Defias Brotherhood chain leading directly into The Deadmines dungeon with strong blue rewards." },
    ["Silverpine Forest"]   = { min = 10, max = 20, faction = "Horde",     continent = 2, mapID = 1421, hordeMin = 10, undeadHeavy = true, beastHeavy = true, humanoidHeavy = true,
        density = "High", hubMod = 0.02, hordeHub = "The Sepulcher",
        summary = "Strong Horde storyline at The Sepulcher linking into Shadowfang Keep; mind Son of Arugal elites." },
    ["Redridge Mountains"]  = { min = 15, max = 25, faction = "Alliance",  continent = 2, mapID = 1433, allianceMin = 15, humanoidHeavy = true, hasMidDip = true,
        density = "High", hubMod = 0.02, allianceHub = "Lakeshire",
        summary = "Rich 15-19 solo hub at Lakeshire, then transitions into challenging 21-25 Blackrock & Elite group quests." },
    ["Duskwood"]            = { min = 18, max = 30, faction = "Alliance",  continent = 2, mapID = 1431, allianceMin = 22, hordeMin = 22, undeadHeavy = true,
        density = "Very High", hubMod = 0.05, allianceHub = "Darkshire & Raven Hill",
        summary = "Massive XP density (35+ quests) in Darkshire & Raven Hill; major Stalvan & Mor'Ladim chains with top gear." },
    ["Hillsbrad Foothills"] = { min = 20, max = 30, faction = "Contested", continent = 2, mapID = 1424, allianceMin = 23, hordeMin = 20, humanoidHeavy = true, openTerrain = true,
        density = "Very High", hubMod = 0.05, allianceHub = "Southshore", hordeHub = "Tarren Mill",
        summary = "Super-efficient humanoid kill & syndicate quests; Horde starts at 20 (Tarren Mill), Alliance at 23 (Southshore)." },
    ["Wetlands"]            = { min = 20, max = 30, faction = "Alliance",  continent = 2, mapID = 1437, allianceMin = 20, humanoidHeavy = true, beastHeavy = true, openTerrain = true,
        density = "High", hubMod = 0.02, allianceHub = "Menethil Harbor & Dun Modr",
        summary = "Consistent 20-28 Alliance hub at Menethil Harbor; strong dragonmaw & Dark Iron chains near Dun Modr." },
    ["Alterac Mountains"]   = { min = 30, max = 40, faction = "Contested", continent = 2, mapID = 1416, allianceMin = 30, hordeMin = 30, humanoidHeavy = true, denseCaves = true,
        density = "Low", hubMod = -0.07, allianceHub = "Southshore (Hillsbrad)", hordeHub = "Tarren Mill (Hillsbrad)",
        summary = "Sparse solo quests; mostly dense Syndicate camps and Elite Crushridge Ogre group quests (35-38)." },
    ["Arathi Highlands"]    = { min = 30, max = 40, faction = "Contested", continent = 2, mapID = 1417, allianceMin = 30, hordeMin = 30, humanoidHeavy = true, elementalHeavy = true, openTerrain = true,
        density = "Medium", hubMod = 0.00, allianceHub = "Refuge Pointe", hordeHub = "Hammerfall",
        summary = "Clean open-field questing at Refuge Pointe / Hammerfall plus Stromgarde Keep group chains at 36+." },
    ["Badlands"]            = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 1418, effectiveMin = 38, allianceMin = 38, hordeMin = 38, elementalHeavy = true, humanoidHeavy = true, openTerrain = true,
        density = "Medium", hubMod = 0.00, allianceHub = "Kargath / Dustbowl", hordeHub = "Kargath",
        summary = "Concentrated 38-44 elemental, buzzard, and trogg quests; also houses key Uldaman dungeon chains." },
    ["Swamp of Sorrows"]    = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 1435, hordeMin = 35, allianceMin = 38, beastHeavy = true, humanoidHeavy = true,
        density = "Low", hubMod = -0.07, hordeHub = "Stonard", allianceHub = "Misty Reed Post",
        summary = "Lower quest count especially for Alliance; mostly Horde Stonard tasks and Sunken Temple prequests." },
    ["Stranglethorn Vale"]  = { min = 30, max = 45, faction = "Contested", continent = 2, mapID = 1434, effectiveMin = 32, allianceMin = 32, hordeMin = 32, beastHeavy = true, humanoidHeavy = true,
        density = "Very High", hubMod = 0.05, allianceHub = "Rebel Camp, Nesingwary & Booty Bay", hordeHub = "Grom'gol, Nesingwary & Booty Bay",
        summary = "Highest XP/hour zone for 32-44 (45+ quests) across Nesingwary Safari, Rebel Camp/Grom'gol, and Booty Bay." },
    ["Searing Gorge"]       = { min = 43, max = 50, faction = "Contested", continent = 2, mapID = 1427, effectiveMin = 44, allianceMin = 44, hordeMin = 44, elementalHeavy = true, humanoidHeavy = true, denseCaves = true,
        density = "High", hubMod = 0.03, hub = "Thorium Point",
        summary = "Very tight, high-XP 45-49 quest circuit around Thorium Point and Cauldron; zero wasted travel time." },
    ["The Hinterlands"]     = { min = 40, max = 50, faction = "Contested", continent = 2, mapID = 1425, allianceMin = 40, hordeMin = 43, humanoidHeavy = true, beastHeavy = true,
        density = "High", hubMod = 0.02, allianceHub = "Aerie Peak", hordeHub = "Revantusk Village",
        summary = "Great 43-49 troll & owlbeast chains plus Mallet of Zul'Farrak and Jintha'Alor elite finale quests." },
    ["Blasted Lands"]       = { min = 45, max = 55, faction = "Contested", continent = 2, mapID = 1419, effectiveMin = 47, allianceMin = 47, hordeMin = 47, beastHeavy = true, elementalHeavy = true,
        density = "Low", hubMod = -0.07, hub = "Nethergarde & Blood Elves",
        summary = "Low quest count focused on repeatable beast stat-buff turn-ins and Elite Demon/Fallen Hero chains." },
    ["Burning Steppes"]     = { min = 50, max = 58, faction = "Contested", continent = 2, mapID = 1428, effectiveMin = 50, allianceMin = 50, hordeMin = 50, elementalHeavy = true, humanoidHeavy = true,
        density = "Medium", hubMod = 0.00, allianceHub = "Morgan's Vigil", hordeHub = "Flame Crest",
        summary = "Solid 50-56 Blackrock & dragonkin chains; feeds directly into BRD and LBRS/UBRS dungeon attunements." },
    ["Western Plaguelands"] = { min = 51, max = 58, faction = "Contested", continent = 2, mapID = 1422, effectiveMin = 51, allianceMin = 51, hordeMin = 51, undeadHeavy = true, humanoidHeavy = true,
        density = "Very High", hubMod = 0.05, allianceHub = "Chillwind Camp & Hearthglen", hordeHub = "The Bulwark & Andorhal",
        summary = "Premier 51-57 XP zone with fast cauldron chains, Scholomance key/prequests, and Tirion Fordring epics." },
    ["Eastern Plaguelands"] = { min = 53, max = 60, faction = "Contested", continent = 2, mapID = 1423, effectiveMin = 54, allianceMin = 54, hordeMin = 54, undeadHeavy = true,
        density = "High", hubMod = 0.03, hub = "Light's Hope Chapel",
        summary = "Endgame 54-60 hub with iconic Tirion Fordring / Darrowshire / Stratholme chains and Pre-BiS rewards." },
    ["Deadwind Pass"]       = { min = 55, max = 60, faction = "Contested", continent = 2, mapID = 1430, undeadHeavy = true,
        density = "Sparse", hubMod = -0.14, hub = "None (Karazhan Courtyard)",
        summary = "Very sparse zone with almost no quest hubs; mainly elite ogres outside Karazhan." },
    ["Riverglades"]         = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 2548, beastHeavy = true, humanoidHeavy = true,
        density = "High", hubMod = 0.02, hub = "Riverglades Hubs",
        summary = "WoW Forever custom 35-45 zone packed with custom quest chains and blue gear upgrades." },
    ["Riverlands"]          = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 2548, beastHeavy = true, humanoidHeavy = true,
        isAlias = true, density = "High", hubMod = 0.02, hub = "Riverglades Hubs",
        summary = "WoW Forever custom 35-45 zone packed with custom quest chains and blue gear upgrades." },

    -- =========================================================================
    -- KALIMDOR
    -- =========================================================================
    ["Durotar"]             = { min = 1,  max = 10, faction = "Horde",     continent = 1, mapID = 1411, humanoidHeavy = true, beastHeavy = true,
        density = "Very High", hubMod = 0.05, hordeHub = "Sen'jin Village & Razor Hill",
        summary = "Fast Horde 1-10 progression across Valley of Trials, Sen'jin Village, and Razor Hill." },
    ["Mulgore"]             = { min = 1,  max = 10, faction = "Horde",     continent = 1, mapID = 1412, humanoidHeavy = true, beastHeavy = true, openTerrain = true,
        density = "Very High", hubMod = 0.04, hordeHub = "Bloodhoof Village",
        summary = "Smooth open-plains 1-10 questing around Bloodhoof Village with easy kiting and zero clutter." },
    ["Teldrassil"]          = { min = 1,  max = 10, faction = "Alliance",  continent = 1, mapID = 1438, beastHeavy = true, humanoidHeavy = true,
        density = "Very High", hubMod = 0.04, allianceHub = "Shadowglen & Dolanaar",
        summary = "Focused Night Elf 1-10 loop through Shadowglen and Dolanaar with good early green weapons." },
    ["Darkshore"]           = { min = 10, max = 20, faction = "Alliance",  continent = 1, mapID = 1439, allianceMin = 10, humanoidHeavy = true, beastHeavy = true,
        density = "Very High", hubMod = 0.05, allianceHub = "Auberdine",
        summary = "One of the highest-XP 11-19 zones in Classic; over 30 quests stack neatly along the Auberdine coast." },
    ["The Barrens"]         = { min = 10, max = 25, faction = "Horde",     continent = 1, mapID = 1413, hordeMin = 10, humanoidHeavy = true, beastHeavy = true, openTerrain = true,
        density = "Very High", hubMod = 0.05, hordeHub = "Crossroads, Ratchet & Camp Taurajo",
        summary = "Cornerstone Horde 10-25 mega-zone with 50+ quests across Crossroads, Ratchet, and Camp Taurajo." },
    ["Ashenvale"]           = { min = 18, max = 30, faction = "Contested", continent = 1, mapID = 1440, allianceMin = 19, hordeMin = 22, humanoidHeavy = true, beastHeavy = true,
        density = "High", hubMod = 0.02, allianceHub = "Astranaar", hordeHub = "Splintertree Post & Zoram'gar",
        summary = "Dense forest questing at Astranaar (Alliance) and Splintertree (Horde); also feeds Blackfathom Deeps." },
    ["Stonetalon Mountains"]= { min = 15, max = 27, faction = "Contested", continent = 1, mapID = 1442, hordeMin = 16, allianceMin = 20, humanoidHeavy = true, mechanicalHeavy = true,
        density = "Medium", hubMod = 0.00, hordeHub = "Sun Rock Retreat", allianceHub = "Stonetalon Peak",
        summary = "Strong early-20s Horde complement to The Barrens; smaller Alliance presence near Stonetalon Peak." },
    ["Thousand Needles"]    = { min = 25, max = 35, faction = "Contested", continent = 1, mapID = 1441, hordeMin = 25, allianceMin = 28, humanoidHeavy = true, beastHeavy = true, openTerrain = true,
        density = "High", hubMod = 0.03, hordeHub = "Freewind Post & Mirage Raceway", allianceHub = "Mirage Raceway (Shimmering Flats)",
        summary = "Shimmering Flats (Mirage Raceway) offers one of the fastest 30-34 quest circuits in the entire game." },
    ["Desolace"]            = { min = 30, max = 40, faction = "Contested", continent = 1, mapID = 1443, allianceMin = 30, hordeMin = 30, undeadHeavy = true, humanoidHeavy = true, openTerrain = true,
        density = "Medium", hubMod = 0.00, allianceHub = "Nijel's Point", hordeHub = "Shadowprey Village",
        summary = "Reliable 32-38 Centaur & demon chains with Maraudon prequests, though hubs involve long travel runs." },
    ["Dustwallow Marsh"]    = { min = 35, max = 45, faction = "Contested", continent = 1, mapID = 1445, hordeMin = 35, allianceMin = 36, beastHeavy = true, humanoidHeavy = true, openTerrain = true,
        density = "Medium", hubMod = 0.01, allianceHub = "Theramore Isle", hordeHub = "Brackenwall Village",
        summary = "Concentrated 36-41 quest cluster at Theramore / Brackenwall + Mudsprocket; quick turn-in loops." },
    ["Feralas"]             = { min = 40, max = 50, faction = "Contested", continent = 1, mapID = 1444, allianceMin = 40, hordeMin = 40, beastHeavy = true, humanoidHeavy = true,
        density = "High", hubMod = 0.02, allianceHub = "Feathermoon Stronghold", hordeHub = "Camp Mojache",
        summary = "Smooth 41-48 solo leveling with yeti/gnoll quests, chicken escort, and key Dire Maul links." },
    ["Tanaris"]             = { min = 40, max = 50, faction = "Contested", continent = 1, mapID = 1446, allianceMin = 40, hordeMin = 40, humanoidHeavy = true, beastHeavy = true, openTerrain = true,
        density = "Very High", hubMod = 0.05, hub = "Gadgetzan & Steamwheedle Port",
        summary = "Massive 43-49 hub at Gadgetzan with dense pirate/bug/Zul'Farrak quests and great Pre-50 upgrades." },
    ["Azshara"]             = { min = 45, max = 55, faction = "Contested", continent = 1, mapID = 1447, allianceMin = 45, hordeMin = 45, humanoidHeavy = true, elementalHeavy = true,
        density = "Sparse", hubMod = -0.14, hub = "Talrendis Point / Valormok",
        summary = "Very sparse solo leveling quests and difficult terrain; mainly used for Level 50 Class Quests & Timbermaw." },
    ["Felwood"]             = { min = 48, max = 55, faction = "Contested", continent = 1, mapID = 1448, effectiveMin = 48, allianceMin = 48, hordeMin = 48, elementalHeavy = true, humanoidHeavy = true, beastHeavy = true,
        density = "High", hubMod = 0.03, hub = "Emerald Sanctuary & Bloodvenom Post",
        summary = "Clean linear 48-54 hub with Timbermaw reputation, Cleansing Felwood, and high XP per hour." },
    ["Un'Goro Crater"]      = { min = 48, max = 55, faction = "Contested", continent = 1, mapID = 1449, effectiveMin = 49, allianceMin = 49, hordeMin = 49, beastHeavy = true, elementalHeavy = true,
        density = "Very High", hubMod = 0.05, hub = "Marshal's Refuge",
        summary = "Arguably the best 49-54 XP zone in Classic; 25+ stacked quests right from Marshal's Refuge." },
    ["Silithus"]            = { min = 55, max = 60, faction = "Contested", continent = 1, mapID = 1451, effectiveMin = 55, allianceMin = 55, hordeMin = 55, elementalHeavy = true, beastHeavy = true, openTerrain = true,
        density = "Low", hubMod = -0.06, hub = "Cenarion Hold",
        summary = "Lvl 57-60 endgame Twilight/hive focus; fewer leveling quests than Plaguelands or Winterspring." },
    ["Winterspring"]        = { min = 53, max = 60, faction = "Contested", continent = 1, mapID = 1452, effectiveMin = 53, allianceMin = 53, hordeMin = 53, beastHeavy = true, humanoidHeavy = true,
        density = "High", hubMod = 0.03, hub = "Everlook & Donova Snowden",
        summary = "Top 55-60 leveling zone at Everlook with Winterfall/owlbeast loops and great endgame trinket/weapon rewards." },
    ["Moonglade"]           = { min = 1,  max = 60, faction = "Neutral",   continent = 1, mapID = 1450, class = "DRUID",
        density = "Low", hubMod = -0.05, hub = "Nighthaven",
        summary = "Druid class sanctuary (Bear/Aquatic Form & class quests only; not a general leveling zone)." },
    ["Zephras Isle"]        = { min = 1,  max = 12, faction = "Contested", continent = 1, mapID = 2521,
        density = "High", hubMod = 0.02, hub = "Zephras Isle Hub",
        summary = "WoW Forever custom 1-12 starting island with streamlined introductory quests and custom gear." },
    ["Mount Hyjal"]         = { min = 58, max = 60, faction = "Contested", continent = 1, mapID = 1459, elementalHeavy = true, humanoidHeavy = true,
        density = "Medium", hubMod = 0.01, hub = "Nordrassil / Hyjal",
        summary = "WoW Forever custom 58-60 endgame zone featuring high-difficulty demons and custom endgame rewards." },
    ["Hyjal"]               = { min = 58, max = 60, faction = "Contested", continent = 1, mapID = 1459, elementalHeavy = true, humanoidHeavy = true,
        isAlias = true, density = "Medium", hubMod = 0.01, hub = "Nordrassil / Hyjal",
        summary = "WoW Forever custom 58-60 endgame zone featuring high-difficulty demons and custom endgame rewards." },

    -- =========================================================================
    -- MAJOR CITIES
    -- =========================================================================
    ["Stormwind City"]      = { min = 1,  max = 60, faction = "Alliance",  continent = 2, mapID = 1453, isCity = true },
    ["Ironforge"]           = { min = 1,  max = 60, faction = "Alliance",  continent = 2, mapID = 1455, isCity = true },
    ["Darnassus"]           = { min = 1,  max = 60, faction = "Alliance",  continent = 1, mapID = 1457, isCity = true },
    ["Orgrimmar"]           = { min = 1,  max = 60, faction = "Horde",     continent = 1, mapID = 1454, isCity = true },
    ["Thunder Bluff"]       = { min = 1,  max = 60, faction = "Horde",     continent = 1, mapID = 1456, isCity = true },
    ["Undercity"]           = { min = 1,  max = 60, faction = "Horde",     continent = 2, mapID = 1458, isCity = true },

    -- =========================================================================
    -- DUNGEONS & INSTANCES
    -- =========================================================================
    -- Eastern Kingdoms Dungeons (Continent 2)
    ["The Deadmines"]             = { min = 18, max = 23, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "Moonbrook (Westfall)",
        summary = "Classic 5-man instance (5+ dungeon quests); VanCleef drops Tunic of Westfall / Staff of Westfall finale." },
    ["Shadowfang Keep"]           = { min = 22, max = 30, faction = "Contested", continent = 2, isDungeon = true,
        density = "Medium", hubMod = 0.00, hub = "Pyrewood Village (Silverpine)",
        summary = "5-man instance in Silverpine; strong Horde quests and Paladin/Warlock class chains." },
    ["The Stockade"]              = { min = 24, max = 32, faction = "Alliance",  continent = 2, isDungeon = true,
        density = "High", hubMod = 0.02, allianceHub = "Stormwind Keep / Old Town",
        summary = "Fast Alliance dungeon right inside Stormwind with 6 stackable quests and high XP/hour." },
    ["Gnomeregan"]                = { min = 29, max = 38, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.01, hub = "Dun Morogh / Booty Bay",
        summary = "Long 5-man dungeon with 6+ quests; finale rewards BiS Triprunner Dungarees (Agility leather legs)." },
    ["Scarlet Monastery"]         = { min = 34, max = 45, faction = "Contested", continent = 2, isDungeon = true,
        density = "Very High", hubMod = 0.04, hub = "Tirisfal Glades (NE)",
        summary = "Premier mid-level dungeon (GY/Lib/Arm/Cath); rewards Sword of Serenity / Bonebiter & Scarlet loot." },
    ["Uldaman"]                   = { min = 41, max = 51, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.01, hub = "Badlands (North)",
        summary = "5-man Titan dungeon in Badlands with multi-zone prequests and Platinum Discs finale." },
    ["Sunken Temple"]             = { min = 50, max = 60, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Swamp of Sorrows",
        summary = "5-man instance for lvl 50 Class Quests, Eranikus lore, and Egg of Hakkar chain." },
    ["The Temple of Atal'Hakkar"] = { min = 50, max = 60, faction = "Contested", continent = 2, isDungeon = true,
        isAlias = true, density = "High", hubMod = 0.02, hub = "Swamp of Sorrows",
        summary = "5-man instance for lvl 50 Class Quests, Eranikus lore, and Egg of Hakkar chain." },
    ["Blackrock Depths"]          = { min = 52, max = 60, faction = "Contested", continent = 2, isDungeon = true,
        density = "Very High", hubMod = 0.04, hub = "Blackrock Mountain",
        summary = "Massive 5-man dungeon with Onyxia/MC attunements, Windsor chain, and huge XP/Pre-BiS gear." },
    ["Lower Blackrock Spire"]     = { min = 55, max = 60, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Blackrock Mountain",
        summary = "Endgame 5-man dungeon housing BWL/UBRS key chains and Highlord Omokk / Vosh'gajin quests." },
    ["Upper Blackrock Spire"]     = { min = 58, max = 60, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Blackrock Mountain",
        summary = "Endgame dungeon for Onyxia attunement, Blackhand's Command, and Tier 0 chest/shoulders." },
    ["Scholomance"]               = { min = 58, max = 60, faction = "Contested", continent = 2, isDungeon = true,
        density = "Very High", hubMod = 0.04, hub = "Caer Darrow (WPL)",
        summary = "Top endgame dungeon; Ras Frostwhisper & Barov chains grant Pre-BiS trinkets/gear." },
    ["Stratholme"]                = { min = 58, max = 60, faction = "Contested", continent = 2, isDungeon = true,
        density = "Very High", hubMod = 0.04, hub = "Eastern Plaguelands",
        summary = "Endgame Scourge/Scarlet dungeon with Tier 0.5/Pre-BiS chains and high XP turn-ins." },
    ["Hall of Thanes"]            = { min = 13, max = 20, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "Ironforge / Wetlands",
        summary = "WoW Forever custom early dungeon with multi-step dwarf/trogg chains and blue upgrades." },
    ["Ruins of Lordaeron"]        = { min = 15, max = 25, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Tirisfal Glades",
        summary = "WoW Forever custom 15-22 dungeon with Scourge lore quests and rare item drops." },

    -- Kalimdor Dungeons (Continent 1)
    ["Ragefire Chasm"]            = { min = 13, max = 18, faction = "Horde",     continent = 1, isDungeon = true,
        density = "High", hubMod = 0.03, hordeHub = "Orgrimmar (Cleft of Shadow)",
        summary = "Fast Horde starter dungeon inside Orgrimmar with 5 easy quests and blue gear rewards." },
    ["Wailing Caverns"]           = { min = 17, max = 24, faction = "Contested", continent = 1, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "The Barrens (Lushwater Oasis)",
        summary = "Rich 17-23 instance with 6 stackable quests (Deviate Hides, Serpentbloom, Glowing Shard)." },
    ["Blackfathom Deeps"]         = { min = 24, max = 32, faction = "Contested", continent = 1, isDungeon = true,
        density = "High", hubMod = 0.01, hub = "Ashenvale (Zoram Strand)",
        summary = "24-30 instance with strong quests (Researching the Corruption, Twilight Falls) & Damp Note." },
    ["Razorfen Kraul"]            = { min = 29, max = 38, faction = "Contested", continent = 1, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Southern Barrens",
        summary = "29-35 dungeon with Blueleaf Tubers, Willix escort, and Vanquisher's Sword quest chain." },
    ["Razorfen Downs"]            = { min = 37, max = 46, faction = "Contested", continent = 1, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Southern Barrens",
        summary = "37-43 undead instance featuring Scourge of the Downs & Amnennar finale (Sword of Omen / Vanquisher)." },
    ["Zul'Farrak"]                = { min = 44, max = 54, faction = "Contested", continent = 1, isDungeon = true,
        density = "Very High", hubMod = 0.05, hub = "Tanaris (NW)",
        summary = "Highest-XP dungeon per run at 44-50 with 7 stackable quests including Carrot on a Stick!" },
    ["Maraudon"]                  = { min = 46, max = 55, faction = "Contested", continent = 1, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Desolace (SW)",
        summary = "46-52 instance; Scepter of Celebras & Princess Theradras finale award Thrash Blade / Blackstone Ring." },
    ["Dire Maul"]                 = { min = 55, max = 60, faction = "Contested", continent = 1, isDungeon = true,
        density = "Very High", hubMod = 0.04, hub = "Feralas (North)",
        summary = "Endgame 3-wing dungeon (East/West/North Tribute) with class books and top Pre-BiS gear." },
}

-- Helper function to lookup zone info by name (supports flexible casing and aliases)
function addon.Data.GetZoneInfo(zoneName)
    if type(zoneName) ~= "string" or zoneName == "" then return nil end
    local clean = string.gsub(zoneName, "^%s*(.-)%s*$", "%1")
    if addon.Data.Zones[clean] then
        return addon.Data.Zones[clean]
    end

    -- Case-insensitive lookup
    local lower = string.lower(clean)
    for name, info in pairs(addon.Data.Zones) do
        if string.lower(name) == lower then
            return info
        end
    end

    -- Flexible "The " prefix handling (e.g. "The Barrens" <-> "Barrens")
    local noThe = string.gsub(lower, "^the%s+", "")
    for name, info in pairs(addon.Data.Zones) do
        local nameLower = string.lower(name)
        local nameNoThe = string.gsub(nameLower, "^the%s+", "")
        if nameNoThe == noThe then
            return info
        end
    end

    return nil
end

-- =========================================================================
-- CLASS-AWARE DUNGEON LOOT & XP PROFILES (vs Open-World Questing)
-- =========================================================================
addon.Data.DungeonProfiles = {
    ["Ragefire Chasm"] = {
        sweetMin = 14, sweetMax = 16, allianceQuests = 0, hordeQuests = 5,
        classes = {
            WARRIOR = { mod = 0.06, short = "Cursed Felblade & Bracers", loot = "Cursed Felblade, Subterranean Cape, Savannah Bracers" },
            ROGUE   = { mod = 0.06, short = "Cursed Felblade & Bracers", loot = "Cursed Felblade, Subterranean Cape, Savannah Bracers" },
            HUNTER  = { mod = 0.06, short = "Subterranean Cape & Bracers", loot = "Subterranean Cape, Savannah Bracers, Cursed Felblade" },
            SHAMAN  = { mod = 0.06, short = "Cursed Felblade & Cuffs", loot = "Cursed Felblade, Garrison Cuffs, Subterranean Cape" },
            DRUID   = { mod = 0.06, short = "Savannah Bracers & Staff", loot = "Savannah Bracers, Featherbead Bracers, Subterranean Cape" },
            MAGE    = { mod = 0.06, short = "Robe of Evocation & Blade", loot = "Robe of Evocation, Chanting Blade, Featherbead Bracers" },
            PRIEST  = { mod = 0.06, short = "Robe of Evocation & Blade", loot = "Robe of Evocation, Chanting Blade, Featherbead Bracers" },
            WARLOCK = { mod = 0.06, short = "Robe of Evocation & Blade", loot = "Robe of Evocation, Chanting Blade, Featherbead Bracers" },
            PALADIN = { mod = 0.05, short = "Garrison Cuffs & Felblade", loot = "Cursed Felblade, Garrison Cuffs, Subterranean Cape" },
        },
    },
    ["Hall of Thanes"] = {
        sweetMin = 15, sweetMax = 18, allianceQuests = 4, hordeQuests = 3,
        classes = {
            WARRIOR = { mod = 0.06, short = "Deepgrave Trousers & Cloak", loot = "Deepgrave Trousers, Catacomb Cloak, Tomb Robber's Gloves" },
            PALADIN = { mod = 0.06, short = "Deepgrave Trousers & Cloak", loot = "Deepgrave Trousers, Catacomb Cloak, Dwarven Tome" },
            ROGUE   = { mod = 0.07, short = "Tomb Robber's Gloves & Cloak", loot = "Tomb Robber's Gloves, Catacomb Cloak, Deepgrave Trousers" },
            HUNTER  = { mod = 0.07, short = "Tomb Robber's Gloves & Cloak", loot = "Tomb Robber's Gloves, Catacomb Cloak, Deepgrave Trousers" },
            DRUID   = { mod = 0.06, short = "Tomb Robber's Gloves & Tome", loot = "Tomb Robber's Gloves, Dwarven Tome, Catacomb Cloak" },
            SHAMAN  = { mod = 0.06, short = "Deepgrave Trousers & Tome", loot = "Deepgrave Trousers, Dwarven Tome, Catacomb Cloak" },
            MAGE    = { mod = 0.06, short = "Dwarven Tome & Cloak", loot = "Dwarven Tome, Catacomb Cloak, Deepgrave Trousers" },
            PRIEST  = { mod = 0.06, short = "Dwarven Tome & Cloak", loot = "Dwarven Tome, Catacomb Cloak, Deepgrave Trousers" },
            WARLOCK = { mod = 0.06, short = "Dwarven Tome & Cloak", loot = "Dwarven Tome, Catacomb Cloak, Deepgrave Trousers" },
        },
    },
    ["Ruins of Lordaeron"] = {
        sweetMin = 17, sweetMax = 21, allianceQuests = 4, hordeQuests = 4,
        classes = {
            ROGUE   = { mod = 0.07, short = "Plaguefang & The Stitcher", loot = "Plaguefang, The Stitcher, Tarnished Locket, Small Sack of Gems" },
            WARRIOR = { mod = 0.06, short = "The Stitcher & Locket", loot = "The Stitcher, Plaguefang, Tarnished Locket, Small Sack of Gems" },
            PALADIN = { mod = 0.06, short = "The Stitcher & Locket", loot = "The Stitcher, Tarnished Locket, Spare Part Bindings" },
            HUNTER  = { mod = 0.06, short = "Plaguefang & Locket", loot = "Plaguefang, The Stitcher, Tarnished Locket" },
            DRUID   = { mod = 0.06, short = "Plaguefang & Blight Gloves", loot = "Plaguefang, Blight Gloves, Tarnished Locket" },
            SHAMAN  = { mod = 0.06, short = "The Stitcher & Blight Gloves", loot = "The Stitcher, Blight Gloves, Tarnished Locket" },
            MAGE    = { mod = 0.06, short = "Blight Gloves & Bindings", loot = "Blight Gloves, Spare Part Bindings, Tarnished Locket" },
            PRIEST  = { mod = 0.06, short = "Blight Gloves & Bindings", loot = "Blight Gloves, Spare Part Bindings, Tarnished Locket" },
            WARLOCK = { mod = 0.06, short = "Blight Gloves & Bindings", loot = "Blight Gloves, Spare Part Bindings, Tarnished Locket" },
        },
    },
    ["Wailing Caverns"] = {
        sweetMin = 18, sweetMax = 22, allianceQuests = 5, hordeQuests = 7,
        classes = {
            ROGUE   = { mod = 0.08, short = "Wingblade & Fang Leggings", loot = "Wingblade (BiS 1H), Leggings of the Fang, Cobrahn's Grasp, Deviate Pack" },
            HUNTER  = { mod = 0.08, short = "Venomstrike & Fang Leggings", loot = "Venomstrike, Wingblade, Leggings of the Fang, Slick Deviate Leggings" },
            DRUID   = { mod = 0.08, short = "Crescent Staff & Fang Set", loot = "Crescent Staff, Leggings of the Fang, Footpads of the Fang" },
            WARRIOR = { mod = 0.06, short = "Wingblade & Cobrahn's Grasp", loot = "Wingblade, Cobrahn's Grasp, Mutant Scale Breastplate, Kresh's Back" },
            PALADIN = { mod = 0.06, short = "Wingblade & Mutant Scale", loot = "Wingblade, Cobrahn's Grasp, Mutant Scale Breastplate, Kresh's Back" },
            SHAMAN  = { mod = 0.07, short = "Crescent Staff & Wingblade", loot = "Crescent Staff, Wingblade, Cobrahn's Grasp, Deep Fathom Ring" },
            MAGE    = { mod = 0.07, short = "Crescent Staff & Deep Fathom", loot = "Crescent Staff (BiS Staff), Robe of the Moccasin, Deep Fathom Ring" },
            PRIEST  = { mod = 0.07, short = "Crescent Staff & Sizzle Stick", loot = "Crescent Staff (BiS Staff), Sizzle Stick, Deep Fathom Ring" },
            WARLOCK = { mod = 0.07, short = "Crescent Staff & Sizzle Stick", loot = "Crescent Staff (BiS Staff), Sizzle Stick, Robe of the Moccasin" },
        },
    },
    ["The Deadmines"] = {
        sweetMin = 19, sweetMax = 22, allianceQuests = 5, hordeQuests = 0,
        classes = {
            ROGUE   = { mod = 0.09, short = "Cruel Barb & Tunic of Westfall", loot = "Cruel Barb (BiS 1H), Tunic of Westfall, Blackened Defias Armor, Brotherhood Cape" },
            HUNTER  = { mod = 0.09, short = "Tunic of Westfall & Cruel Barb", loot = "Tunic of Westfall (BiS Chest), Cruel Barb, Piercing Harpoon, Brotherhood Cape" },
            DRUID   = { mod = 0.08, short = "Tunic/Staff of Westfall", loot = "Tunic of Westfall, Staff of Westfall, Blackened Defias Armor" },
            WARRIOR = { mod = 0.08, short = "Chausses of Westfall & Smite's", loot = "Chausses of Westfall, Smite's Mighty Hammer, Cruel Barb, Taskmaster Axe" },
            PALADIN = { mod = 0.08, short = "Chausses of Westfall & Smite's", loot = "Chausses of Westfall, Smite's Mighty Hammer, Polar Gauntlets" },
            SHAMAN  = { mod = 0.06, short = "Smite's Hammer & Emberstone", loot = "Smite's Mighty Hammer, Emberstone Staff, Cruel Barb" },
            MAGE    = { mod = 0.08, short = "Staff of Westfall & Stirring Rod", loot = "Staff of Westfall (BiS Staff), Cookie's Stirring Rod, Lavishly Jeweled Ring" },
            PRIEST  = { mod = 0.08, short = "Staff of Westfall & Stirring Rod", loot = "Staff of Westfall (BiS Staff), Cookie's Stirring Rod, Lavishly Jeweled Ring" },
            WARLOCK = { mod = 0.08, short = "Staff of Westfall & Stirring Rod", loot = "Staff of Westfall (BiS Staff), Cookie's Stirring Rod, Lavishly Jeweled Ring" },
        },
    },
    ["Shadowfang Keep"] = {
        sweetMin = 23, sweetMax = 27, allianceQuests = 0, hordeQuests = 3,
        classes = {
            PALADIN = { mod = 0.09, allianceQuests = 1, short = "Verigan's Fist / Wolfsbane Quest", loot = "Verigan's Fist / Wolfsbane (BiS Class 2H), Silverlaine's Family Seal" },
            WARLOCK = { mod = 0.08, allianceQuests = 1, short = "Orb/Staff of Soran'ruk & Robes", loot = "Orb/Staff of Soran'ruk (Class Quest), Arugal's Robes, Belt of Arugal" },
            MAGE    = { mod = 0.07, short = "Arugal's Robes & Belt", loot = "Arugal's Robes, Belt of Arugal, Meteor Shard, Feline Mantle" },
            PRIEST  = { mod = 0.07, short = "Arugal's Robes & Belt", loot = "Arugal's Robes, Belt of Arugal, Feline Mantle, Seal of Sylvanas" },
            ROGUE   = { mod = 0.02, short = "Meteor Shard & Baron's Ring", loot = "Meteor Shard, Butcher's Slicer, Silverlaine's Family Seal" },
            HUNTER  = { mod = 0.01, short = "Baron's Ring & Shoulderpads", loot = "Silverlaine's Family Seal, Tanned Shoulderpads, Meteor Shard" },
            WARRIOR = { mod = 0.01, short = "Baron's Ring & Haunting Blade", loot = "Silverlaine's Family Seal, Haunting Blade, Steel-clasped Bracers" },
            DRUID   = { mod = 0.03, short = "Arugal's Belt & Baron's Ring", loot = "Belt of Arugal, Silverlaine's Family Seal, Ghostly Mantle" },
            SHAMAN  = { mod = 0.04, short = "Arugal's Belt & Seal of Sylvanas", loot = "Seal of Sylvanas, Belt of Arugal, Silverlaine's Family Seal" },
        },
    },
    ["The Stockade"] = {
        sweetMin = 25, sweetMax = 29, allianceQuests = 6, hordeQuests = 0,
        classes = {
            WARRIOR = { mod = 0.07, short = "6 Fast Quests • Belt of Vindication", loot = "6 Stackable Quests (Huge XP/hr), Belt of Vindication, Iron Knuckles" },
            PALADIN = { mod = 0.07, short = "6 Fast Quests • Belt of Vindication", loot = "6 Stackable Quests (Huge XP/hr), Belt of Vindication, Headbasher" },
            ROGUE   = { mod = 0.07, short = "6 Fast Quests • Prison Shank", loot = "6 Stackable Quests (Huge XP/hr), Belt of Vindication, Defias Renegade Ring" },
            HUNTER  = { mod = 0.07, short = "6 Fast Quests • Ambassador's Boots", loot = "6 Stackable Quests (Huge XP/hr), Ambassador's Boots, Darkshire Mail Leggings" },
            DRUID   = { mod = 0.07, short = "6 Fast Quests • Kam's Walking Stick", loot = "6 Stackable Quests (Huge XP/hr), Belt of Vindication, Kam's Walking Stick" },
            MAGE    = { mod = 0.07, short = "6 Fast Quests • Pantaloons", loot = "6 Stackable Quests (Huge XP/hr), Magistrate's Pantaloons, Town Clerk's Mittens" },
            PRIEST  = { mod = 0.07, short = "6 Fast Quests • Pantaloons", loot = "6 Stackable Quests (Huge XP/hr), Magistrate's Pantaloons, Town Clerk's Mittens" },
            WARLOCK = { mod = 0.07, short = "6 Fast Quests • Pantaloons", loot = "6 Stackable Quests (Huge XP/hr), Magistrate's Pantaloons, Town Clerk's Mittens" },
            SHAMAN  = { mod = 0.06, short = "6 Fast Quests • Darkshire Mail", loot = "Darkshire Mail Leggings, Belt of Vindication, Kam's Walking Stick" },
        },
    },
    ["Blackfathom Deeps"] = {
        sweetMin = 25, sweetMax = 29, allianceQuests = 4, hordeQuests = 4,
        classes = {
            MAGE    = { mod = 0.08, short = "Gravestone Scepter (BiS Wand)", loot = "Gravestone Scepter (BiS Wand), Rod of the Sleepwalker, Witch's Finger" },
            PRIEST  = { mod = 0.08, short = "Gravestone Scepter (BiS Wand)", loot = "Gravestone Scepter (BiS Wand), Rod of the Sleepwalker, Witch's Finger" },
            WARLOCK = { mod = 0.08, short = "Gravestone Scepter (BiS Wand)", loot = "Gravestone Scepter (BiS Wand), Rod of the Sleepwalker, Dark Ritual Leggings" },
            WARRIOR = { mod = 0.07, short = "Strike of the Hydra & Outlaw Sabre", loot = "Strike of the Hydra (2H Sword), Outlaw Sabre, Arctic Buckler" },
            PALADIN = { mod = 0.07, short = "Strike of the Hydra & Buckler", loot = "Strike of the Hydra (2H Sword), Arctic Buckler, Beetle Clasps" },
            SHAMAN  = { mod = 0.07, short = "Strike of the Hydra & Rod", loot = "Strike of the Hydra, Rod of the Sleepwalker, Outlaw Sabre" },
            ROGUE   = { mod = 0.07, short = "Outlaw Sabre & Dreamer's Chest", loot = "Outlaw Sabre (1H Sword), Dreamer's Chestguard, Torturing Poker" },
            HUNTER  = { mod = 0.07, short = "Outlaw Sabre & Naga Heartpiercer", loot = "Outlaw Sabre, Naga Heartpiercer, Dreamer's Chestguard" },
            DRUID   = { mod = 0.07, short = "Dreamer's Chest & Sleepwalker Rod", loot = "Dreamer's Chestguard, Rod of the Sleepwalker, Staghide Armguards" },
        },
    },
    ["Excavation Site: Wetlands"] = {
        sweetMin = 27, sweetMax = 31, allianceQuests = 4, hordeQuests = 3,
        classes = {
            WARRIOR = { mod = 0.06, short = "Heavehammer & Ironwood Destroyer", loot = "Heavehammer, Ironwood Destroyer, Daewyn's Girdle, Dirt-Heavy Bracers" },
            PALADIN = { mod = 0.06, short = "Heavehammer & Ironwood Destroyer", loot = "Heavehammer, Ironwood Destroyer, Daewyn's Girdle, Healer's Staff" },
            SHAMAN  = { mod = 0.06, short = "Heavehammer & Healer's Staff", loot = "Heavehammer, Healer's Staff, Ironwood Destroyer, Daewyn's Girdle" },
            ROGUE   = { mod = 0.06, short = "Hornbeam Heft & Stabilizer", loot = "Hornbeam Heft, Songblade Stabilizer, Knife-Polishing Rag" },
            HUNTER  = { mod = 0.06, short = "Dustcover & Songblade Stabilizer", loot = "Explorer's League Dustcover, Hornbeam Heft, Songblade Stabilizer" },
            DRUID   = { mod = 0.06, short = "Healer's Staff & Hornbeam Heft", loot = "Healer's Staff, Hornbeam Heft, Curl of Life, Daewyn's Girdle" },
            MAGE    = { mod = 0.06, short = "Healer's Staff & Curl of Life", loot = "Healer's Staff, Curl of Life, Explorer's League Dustcover" },
            PRIEST  = { mod = 0.06, short = "Healer's Staff & Curl of Life", loot = "Healer's Staff, Curl of Life, Explorer's League Dustcover" },
            WARLOCK = { mod = 0.06, short = "Healer's Staff & Curl of Life", loot = "Healer's Staff, Curl of Life, Explorer's League Dustcover" },
        },
    },
    ["City of Dalaran"] = {
        sweetMin = 29, sweetMax = 32, allianceQuests = 3, hordeQuests = 3,
        classes = {
            MAGE    = { mod = 0.07, short = "Spellguard Pauldrons & Arcane Rod", loot = "Spellguard Pauldrons, Arcane Infused Rod, Renewing Footpads" },
            PRIEST  = { mod = 0.07, short = "Spellguard Pauldrons & Footpads", loot = "Spellguard Pauldrons, Renewing Footpads, Arcane Infused Rod" },
            WARLOCK = { mod = 0.07, short = "Spellguard Pauldrons & Arcane Rod", loot = "Spellguard Pauldrons, Arcane Infused Rod, Renewing Footpads" },
            WARRIOR = { mod = 0.05, short = "Defender of Dalaran & Pendant", loot = "Defender of Dalaran, Fallen Guard's Pendant, Thorn Protecting Girdle" },
            PALADIN = { mod = 0.06, short = "Defender of Dalaran & Footpads", loot = "Defender of Dalaran, Renewing Footpads, Fallen Guard's Pendant" },
            ROGUE   = { mod = 0.05, short = "Fallen Guard's Pendant & Cloak", loot = "Fallen Guard's Pendant, Vine Pruner's Cloak, Thorn Protecting Girdle" },
            HUNTER  = { mod = 0.05, short = "Fallen Guard's Pendant & Cloak", loot = "Fallen Guard's Pendant, Vine Pruner's Cloak, Thorn Protecting Girdle" },
            DRUID   = { mod = 0.06, short = "Renewing Footpads & Pendant", loot = "Renewing Footpads, Fallen Guard's Pendant, Spellguard Pauldrons" },
            SHAMAN  = { mod = 0.06, short = "Defender of Dalaran & Footpads", loot = "Defender of Dalaran, Renewing Footpads, Fallen Guard's Pendant" },
        },
    },
    ["Gnomeregan"] = {
        sweetMin = 31, sweetMax = 35, allianceQuests = 7, hordeQuests = 4,
        classes = {
            ROGUE   = { mod = 0.08, short = "Triprunner Dungarees (+18 Agi BiS)", loot = "Triprunner Dungarees (+18 Agi BiS Legs), Electrocutioner Lagnut, Toxic Revenger" },
            HUNTER  = { mod = 0.08, short = "Triprunner Dungarees (+18 Agi BiS)", loot = "Triprunner Dungarees (+18 Agi BiS Legs), Hi-tech Supergun, Shoni's Disarming Tool" },
            DRUID   = { mod = 0.08, short = "Triprunner Dungarees & Pummeler", loot = "Triprunner Dungarees (+18 Agi BiS Legs), Manual Crowd Pummeler, Civinad Robes" },
            MAGE    = { mod = 0.04, short = "Civinad Robes & Gigaflux Cap", loot = "Civinad Robes, Electromagnetic Gigaflux Reactivator, Talvash's Gold Ring" },
            PRIEST  = { mod = 0.04, short = "Civinad Robes & Gold Ring", loot = "Civinad Robes, Talvash's/Nogg's Gold Ring, Acidic Walkers" },
            WARLOCK = { mod = 0.04, short = "Civinad Robes & Gigaflux Cap", loot = "Civinad Robes, Electromagnetic Gigaflux Reactivator, Acidic Walkers" },
            WARRIOR = { mod = 0.02, short = "Thermaplugg's Arm (Long Run)", loot = "Thermaplugg's Left Arm, Phalanx Leggings, Talvash's/Nogg's Gold Ring" },
            PALADIN = { mod = 0.02, short = "Thermaplugg's Arm (Long Run)", loot = "Thermaplugg's Left Arm, Phalanx Leggings, Talvash's Gold Ring" },
            SHAMAN  = { mod = 0.03, short = "Thermaplugg's Arm & Civinad Robes", loot = "Thermaplugg's Left Arm, Civinad Robes, Nogg's Gold Ring" },
        },
    },
    ["Razorfen Kraul"] = {
        sweetMin = 30, sweetMax = 35, allianceQuests = 3, hordeQuests = 5,
        classes = {
            WARRIOR = { mod = 0.07, short = "Corpsemaker (BiS 2H) & Tusken Helm", loot = "Corpsemaker (BiS 2H Axe), Tusken Helm, Pugilist Bracers, Marbled Buckler" },
            PALADIN = { mod = 0.07, short = "Corpsemaker (BiS 2H) & Tusken Helm", loot = "Corpsemaker (BiS 2H Axe), Tusken Helm, Pugilist Bracers, Marbled Buckler" },
            SHAMAN  = { mod = 0.07, short = "Corpsemaker (BiS 2H) & Buckler", loot = "Corpsemaker (BiS 2H Axe), Marbled Buckler, Pugilist Bracers, Tiger Band" },
            ROGUE   = { mod = 0.05, short = "Swinetusk Shank & Vendetta", loot = "Swinetusk Shank, Vendetta, Archer's Trousers, Monkey/Tiger Ring" },
            HUNTER  = { mod = 0.05, short = "Archer's Trousers & Monkey Ring", loot = "Archer's Trousers, Wolfclaw Gloves, Monkey/Tiger Ring, Swinetusk Shank" },
            DRUID   = { mod = 0.04, short = "Archer's Trousers & Rings", loot = "Archer's Trousers, Pugilist Bracers, Monkey/Tiger/Snake Ring" },
            MAGE    = { mod = 0.00, short = "Berylline Pads (Few Caster Drops)", loot = "Berylline Pads, Mourning Shawl, Snake Hoop (Low Caster Loot)" },
            PRIEST  = { mod = 0.00, short = "Berylline Pads (Few Caster Drops)", loot = "Berylline Pads, Mourning Shawl, Snake Hoop (Low Caster Loot)" },
            WARLOCK = { mod = 0.00, short = "Berylline Pads (Few Caster Drops)", loot = "Berylline Pads, Mourning Shawl, Snake Hoop (Low Caster Loot)" },
        },
    },
    ["Scarlet Monastery"] = {
        sweetMin = 35, sweetMax = 42, allianceQuests = 3, hordeQuests = 4,
        classes = {
            WARRIOR = { mod = 0.09, short = "Bonebiter / Ravager & Herod Gear", loot = "Bonebiter / Sword of Serenity, Ravager, Herod's Shoulder, Raging Berserker's Helm" },
            PALADIN = { mod = 0.09, short = "Bonebiter / Mograine's Might", loot = "Bonebiter / Sword of Serenity, Mograine's Might, Herod's Shoulder, Scarlet Shield" },
            SHAMAN  = { mod = 0.09, short = "Ravager / Mograine's & Herod Gear", loot = "Ravager, Mograine's Might, Herod's Shoulder, Raging Berserker's Helm" },
            MAGE    = { mod = 0.09, short = "Illusionary Rod & Whitemane's Hat", loot = "Illusionary Rod, Hypnotic Blade, Whitemane's Chapeau, Triune Amulet" },
            PRIEST  = { mod = 0.09, short = "Whitemane's Hat & Amulet", loot = "Whitemane's Chapeau, Triune Amulet, Illusionary Rod, Hand of Righteousness" },
            WARLOCK = { mod = 0.09, short = "Hypnotic Blade & Whitemane's Hat", loot = "Hypnotic Blade, Orb of Lorica, Whitemane's Chapeau, Illusionary Rod" },
            ROGUE   = { mod = 0.07, short = "Sword of Serenity/Omen (BiS 1H)", loot = "Sword of Serenity / Sword of Omen (BiS 1H), Flintrock Shoulders, Gauntlets of Divinity" },
            HUNTER  = { mod = 0.07, short = "Sword of Serenity & Scarlet Mail", loot = "Sword of Serenity / Omen, Herod's Shoulder, Raging Berserker's Helm, Gauntlets of Divinity" },
            DRUID   = { mod = 0.07, short = "Mograine's Might & Whitemane's Hat", loot = "Mograine's Might, Whitemane's Chapeau, Triune Amulet, Flintrock Shoulders" },
        },
    },
    ["The Drowned City"] = {
        sweetMin = 36, sweetMax = 39, allianceQuests = 6, hordeQuests = 6,
        classes = {
            ROGUE   = { mod = 0.08, short = "14-Slot Bag & Sacrificial Sword", loot = "Ancient Voodoo Pouch (14-Slot Bag), Sacrificial Sword / I'lalai Flayer, Saltseer's Helm" },
            WARRIOR = { mod = 0.08, short = "14-Slot Bag & Sacrificial Sword", loot = "Ancient Voodoo Pouch (14-Slot Bag), Sacrificial Sword, Rusted Troll War Belt, Chainmail" },
            PALADIN = { mod = 0.08, short = "14-Slot Bag & Explorer's Chainmail", loot = "Ancient Voodoo Pouch (14-Slot Bag), Intrepid Explorer's Chainmail, Sacrificial Sword" },
            HUNTER  = { mod = 0.08, short = "14-Slot Bag & Explorer's Chainmail", loot = "Ancient Voodoo Pouch (14-Slot Bag), Intrepid Explorer's Chainmail, Saltseer's Helm" },
            SHAMAN  = { mod = 0.08, short = "14-Slot Bag & Ceremonial Mallet", loot = "Ancient Voodoo Pouch (14-Slot Bag), Ceremonial Mallet, Intrepid Explorer's Chainmail" },
            DRUID   = { mod = 0.08, short = "14-Slot Bag & Saltseer's Helm", loot = "Ancient Voodoo Pouch (14-Slot Bag), Saltseer's Helm, Ceremonial Mallet, Mutinous Cuffs" },
            MAGE    = { mod = 0.08, short = "14-Slot Bag & Rune-Etched Epaulets", loot = "Ancient Voodoo Pouch (14-Slot Bag), Rune-Etched Epaulets, Ceremonial Mallet, Naga Mantle" },
            PRIEST  = { mod = 0.08, short = "14-Slot Bag & Ceremonial Mallet", loot = "Ancient Voodoo Pouch (14-Slot Bag), Ceremonial Mallet, Rune-Etched Epaulets, Naga Mantle" },
            WARLOCK = { mod = 0.08, short = "14-Slot Bag & Rune-Etched Epaulets", loot = "Ancient Voodoo Pouch (14-Slot Bag), Rune-Etched Epaulets, Ceremonial Mallet, Naga Mantle" },
        },
    },
    ["Razorfen Downs"] = {
        sweetMin = 38, sweetMax = 43, allianceQuests = 3, hordeQuests = 3,
        classes = {
            ROGUE   = { mod = 0.08, short = "Vanquisher's Sword (+28 AP BiS 1H)", loot = "Vanquisher's Sword (+28 AP BiS 1H), Arachnid Gloves, Stormgale Fists" },
            WARRIOR = { mod = 0.08, short = "Vanquisher's Sword & Carapace", loot = "Vanquisher's Sword (+28 AP BiS 1H), Carapace of Tuten'kash, Boar Champion's Belt" },
            PALADIN = { mod = 0.07, short = "Vanquisher's Sword & Carapace", loot = "Vanquisher's Sword, Carapace of Tuten'kash, Purified Ring, Amberglow Talisman" },
            HUNTER  = { mod = 0.06, short = "Vanquisher's Sword & Quillshooter", loot = "Vanquisher's Sword (+28 AP), Quillshooter, Arachnid Gloves, Boar Champion's Belt" },
            DRUID   = { mod = 0.06, short = "Arachnid Gloves & Purified Ring", loot = "Arachnid Gloves, Stormgale Fists, Purified Ring, Amberglow Talisman" },
            SHAMAN  = { mod = 0.06, short = "Boar Champion's Belt & Ring", loot = "Boar Champion's Belt, Arachnid Gloves, Purified Ring, Amberglow Talisman" },
            MAGE    = { mod = 0.06, short = "Robes of the Lich & Amberglow", loot = "Robes of the Lich, Lich's Spellbook, Amberglow Talisman, Deathchill Armor" },
            PRIEST  = { mod = 0.06, short = "Robes of the Lich & Purified Ring", loot = "Robes of the Lich, Purified Ring, Amberglow Talisman, Glowing Eye of Mordresh" },
            WARLOCK = { mod = 0.06, short = "Robes of the Lich & Spellbook", loot = "Robes of the Lich, Lich's Spellbook, Deathchill Armor, Amberglow Talisman" },
        },
    },
    ["Krol'dok Stronghold"] = {
        sweetMin = 41, sweetMax = 44, allianceQuests = 4, hordeQuests = 4,
        classes = {
            WARRIOR = { mod = 0.06, short = "Bigger Rock on Bigger Stick", loot = "Bigger Rock on Bigger Stick, Semblance of Twilight, Twilight Initiate's Belt" },
            PALADIN = { mod = 0.06, short = "Bigger Rock on Bigger Stick", loot = "Bigger Rock on Bigger Stick, Semblance of Twilight, Convert's Bindings" },
            ROGUE   = { mod = 0.06, short = "Rock on Stick & Twilight Trinket", loot = "Rock on Stick, Semblance of Twilight, Twilight Initiate's Belt" },
            HUNTER  = { mod = 0.06, short = "Rock on Stick & Twilight Trinket", loot = "Rock on Stick, Semblance of Twilight, Torn Cultist Cloak" },
            DRUID   = { mod = 0.06, short = "Bigger Rock & Twilight Trinket", loot = "Bigger Rock on Bigger Stick, Stick No Rock, Semblance of Twilight" },
            SHAMAN  = { mod = 0.06, short = "Bigger Rock & Twilight Trinket", loot = "Bigger Rock on Bigger Stick, Stick No Rock, Semblance of Twilight" },
            MAGE    = { mod = 0.06, short = "Stick No Rock & Choker", loot = "Stick No Rock, Indoctrinated Choker, Semblance of Twilight, Torn Cultist Cloak" },
            PRIEST  = { mod = 0.06, short = "Stick No Rock & Choker", loot = "Stick No Rock, Indoctrinated Choker, Semblance of Twilight, Convert's Bindings" },
            WARLOCK = { mod = 0.06, short = "Stick No Rock & Choker", loot = "Stick No Rock, Indoctrinated Choker, Semblance of Twilight, Torn Cultist Cloak" },
        },
    },
    ["Uldaman"] = {
        sweetMin = 43, sweetMax = 47, allianceQuests = 7, hordeQuests = 5,
        classes = {
            WARRIOR = { mod = 0.06, short = "Stoneslayer & Rockpounder (2H)", loot = "Stoneslayer, Rockpounder, Grimlok's Charge, Cragfists, Medal of Courage" },
            PALADIN = { mod = 0.06, short = "Stoneslayer & Rockpounder (2H)", loot = "Stoneslayer, Rockpounder, Skullplate Bracers, Explorer's League Lodestar" },
            SHAMAN  = { mod = 0.06, short = "Rockpounder & Grimlok's Charge", loot = "Rockpounder, Grimlok's Charge, Energized Stone Circle, Medal of Courage" },
            ROGUE   = { mod = 0.03, short = "Medal of Courage & Pith Helmet", loot = "Medal of Courage, Adventurer's Pith Helmet, Charged Leather Bracers" },
            HUNTER  = { mod = 0.04, short = "Grimlok's Charge & Pith Helmet", loot = "Grimlok's Charge (+15 Agi Polearm), Adventurer's Pith Helmet, Medal of Courage" },
            DRUID   = { mod = 0.04, short = "Pith Helmet & Lodestar", loot = "Adventurer's Pith Helmet, Explorer's League Lodestar, Medal of Courage" },
            MAGE    = { mod = 0.03, short = "Doomsayer's Robe & Stone Circle", loot = "Doomsayer's Robe, Energized Stone Circle, Ironshod Bludgeon" },
            PRIEST  = { mod = 0.04, short = "Explorer's Lodestar & Robe", loot = "Explorer's League Lodestar, Doomsayer's Robe, Energized Stone Circle" },
            WARLOCK = { mod = 0.03, short = "Doomsayer's Robe & Stone Circle", loot = "Doomsayer's Robe, Doomcaller's Pants, Energized Stone Circle" },
        },
    },
    ["Zul'Farrak"] = {
        sweetMin = 45, sweetMax = 50, allianceQuests = 7, hordeQuests = 7,
        classes = {
            WARRIOR = { mod = 0.09, short = "Carrot on a Stick & Mason's Ring", loot = "Carrot on a Stick (+3% Mount), Mason's Fraternity Ring, Sul'thraze / Big Bad Pauldrons" },
            PALADIN = { mod = 0.09, short = "Carrot on a Stick & Mason's Ring", loot = "Carrot on a Stick (+3% Mount), Mason's Fraternity Ring, Sul'thraze, Jumanza Grips" },
            ROGUE   = { mod = 0.09, short = "Carrot on a Stick & Mason's Ring", loot = "Carrot on a Stick (+3% Mount), Mason's Fraternity Ring, Sang'thraze, Eyegouger" },
            HUNTER  = { mod = 0.09, short = "Carrot on a Stick & Mason's Ring", loot = "Carrot on a Stick (+3% Mount), Mason's Fraternity Ring, Diabolic Skiver, Gahz'rilla Scale" },
            DRUID   = { mod = 0.09, short = "Carrot on a Stick & Mason's Ring", loot = "Carrot on a Stick (+3% Mount), Mason's Fraternity Ring, Zum'rah's Vexing Cane" },
            SHAMAN  = { mod = 0.09, short = "Carrot on a Stick & Mason's Ring", loot = "Carrot on a Stick (+3% Mount), Mason's Fraternity Ring, Zum'rah's Cane, Gahz'rilla Scale" },
            MAGE    = { mod = 0.09, short = "Carrot on a Stick & Bad Mojo Mask", loot = "Carrot on a Stick (+3% Mount), Bad Mojo Mask, Zum'rah's Vexing Cane, Spellshifter Rod" },
            PRIEST  = { mod = 0.09, short = "Carrot on a Stick & Bad Mojo Mask", loot = "Carrot on a Stick (+3% Mount), Bad Mojo Mask, Zum'rah's Vexing Cane, Jumanza Grips" },
            WARLOCK = { mod = 0.09, short = "Carrot on a Stick & Bad Mojo Mask", loot = "Carrot on a Stick (+3% Mount), Bad Mojo Mask, Zum'rah's Vexing Cane, Spellshifter Rod" },
        },
    },
    ["Maraudon"] = {
        sweetMin = 47, sweetMax = 52, allianceQuests = 6, hordeQuests = 6,
        classes = {
            ROGUE   = { mod = 0.09, short = "Thrash Blade & Blackstone Ring (BiS)", loot = "Thrash Blade (BiS Extra-Attack 1H), Blackstone Ring (+20 AP/+1% Hit BiS), Mark of the Chosen" },
            WARRIOR = { mod = 0.09, short = "Thrash Blade & Blackstone Ring (BiS)", loot = "Thrash Blade (BiS 1H), Blackstone Ring (+20 AP/+1% Hit BiS), Gatorbite Axe, Mark of the Chosen" },
            PALADIN = { mod = 0.09, short = "Thrash Blade & Blackstone Ring (BiS)", loot = "Thrash Blade, Blackstone Ring (+20 AP/+1% Hit), Gizlock's Hypertech Buckler" },
            HUNTER  = { mod = 0.09, short = "Blackstone Ring & Verdant Aim (BiS)", loot = "Blackstone Ring (+20 AP/+1% Hit BiS), Verdant Keeper's Aim, Satyr's Bow" },
            DRUID   = { mod = 0.09, short = "Blackstone Ring & Mark of Chosen", loot = "Blackstone Ring (+20 AP/+1% Hit BiS), Mark of the Chosen, Resurgence Rod" },
            SHAMAN  = { mod = 0.08, short = "Blackstone Ring & Resurgence Rod", loot = "Blackstone Ring (+20 AP/+1% Hit), Resurgence Rod, Gizlock's Buckler, Mark of the Chosen" },
            MAGE    = { mod = 0.07, short = "Blade of Eternal Darkness & Rod", loot = "Blade of Eternal Darkness, Charstone Dirk, Resurgence Rod, Eye of Theradras" },
            PRIEST  = { mod = 0.07, short = "Resurgence Rod & Eye of Theradras", loot = "Resurgence Rod, Eye of Theradras, Charstone Dirk, Noxxion's Shackles" },
            WARLOCK = { mod = 0.07, short = "Blade of Eternal Darkness & Dirk", loot = "Blade of Eternal Darkness, Charstone Dirk, Resurgence Rod, Eye of Theradras" },
        },
    },
    ["Alcaz Prison"] = {
        sweetMin = 49, sweetMax = 52, allianceQuests = 4, hordeQuests = 4,
        classes = {
            WARRIOR = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
            PALADIN = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
            ROGUE   = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
            HUNTER  = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
            DRUID   = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
            SHAMAN  = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
            MAGE    = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
            PRIEST  = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
            WARLOCK = { mod = 0.06, short = "Alcaz Prison Chains & Rare Gear", loot = "Alcaz Prison High-XP Chains & Rare 48-53 Weapons/Armor" },
        },
    },
    ["Sunken Temple"] = {
        sweetMin = 51, sweetMax = 55, allianceQuests = 6, hordeQuests = 6,
        classes = {
            WARRIOR = { mod = 0.09, short = "Diamond Flask (BiS Class Trinket)", loot = "Diamond Flask / Fury Visor (Lvl 50 Class Quest), Dragon's Call, Hakkar Chain" },
            PALADIN = { mod = 0.09, short = "Lightforged Blade / Sanctified Orb", loot = "Lightforged Blade / Sanctified Orb (Lvl 50 Class Quest), Hakkar Chain" },
            HUNTER  = { mod = 0.09, short = "Devilsaur Eye / Tooth (Class BiS)", loot = "Devilsaur Eye / Devilsaur Tooth (Lvl 50 Class Quest), Dragonstalker Spike" },
            ROGUE   = { mod = 0.08, short = "Ebon Mask / Whisperwalk Boots", loot = "Ebon Mask / Whisperwalk Boots (Lvl 50 Class Quest), Dragon's Call, Hakkar Chain" },
            PRIEST  = { mod = 0.09, short = "Blessed Prayer Beads (Class BiS)", loot = "Blessed Prayer Beads / Woestave (Lvl 50 Class Quest), Atal'ai Gear" },
            MAGE    = { mod = 0.08, short = "Arcane Crystal Pendant / Fire Ruby", loot = "Arcane Crystal Pendant / Fire Ruby (Lvl 50 Class Quest), Hakkar Chain" },
            WARLOCK = { mod = 0.08, short = "Soul Harvester / Abyss Shard", loot = "Soul Harvester / Abyss Shard (Lvl 50 Class Quest), Atal'ai Gear" },
            DRUID   = { mod = 0.08, short = "Grizzled Pelt / Moonstone (Class)", loot = "Grizzled Pelt / Forest's Embrace (Lvl 50 Class Quest), Atal'ai Gear" },
            SHAMAN  = { mod = 0.08, short = "Enamored Water Spirit (Class BiS)", loot = "Enamored Water Spirit / AzuriteFist (Lvl 50 Class Quest), Hakkar Chain" },
        },
    },
    ["Blackrock Depths"] = {
        sweetMin = 53, sweetMax = 59, allianceQuests = 10, hordeQuests = 10,
        classes = {
            ROGUE   = { mod = 0.09, short = "Hand of Justice (BiS Trinket) & Attune", loot = "Hand of Justice (BiS Trinket), Barman Shanker, Onyxia/MC Attunement (10+ Quests)" },
            WARRIOR = { mod = 0.09, short = "Hand of Justice & Gladiator Chain", loot = "Hand of Justice (BiS), Savage Gladiator Chain (BiS), Ironfoe, Onyxia/MC Attunement" },
            PALADIN = { mod = 0.09, short = "Hand of Justice & Second Wind", loot = "Hand of Justice, Second Wind, Ironfoe, Onyxia/MC Attunement (10+ Quests)" },
            HUNTER  = { mod = 0.09, short = "Savage Gladiator Chain & HoJ", loot = "Savage Gladiator Chain (BiS), Hand of Justice, Blackcrow, Onyxia/MC Attunement" },
            DRUID   = { mod = 0.09, short = "Hand of Justice & Second Wind", loot = "Hand of Justice, Second Wind, Nagmara's Belt, Onyxia/MC Attunement" },
            SHAMAN  = { mod = 0.09, short = "Hand of Justice & Gladiator Chain", loot = "Hand of Justice, Savage Gladiator Chain, Second Wind, Onyxia/MC Attunement" },
            MAGE    = { mod = 0.09, short = "Ban'thok Sash & Omnicast Boots", loot = "Ban'thok Sash (BiS Hit), Omnicast Boots, Boreal Mantle, Onyxia/MC Attunement" },
            PRIEST  = { mod = 0.09, short = "Second Wind & Omnicast Boots", loot = "Second Wind (BiS Trinket), Omnicast Boots, Kentic Amice, Onyxia/MC Attunement" },
            WARLOCK = { mod = 0.09, short = "Ban'thok Sash & Omnicast Boots", loot = "Ban'thok Sash (BiS Hit), Omnicast Boots, Spritecaster Cape, Onyxia/MC Attunement" },
        },
    },
    ["Lower Blackrock Spire"] = {
        sweetMin = 56, sweetMax = 60, allianceQuests = 6, hordeQuests = 6,
        classes = {
            ROGUE   = { mod = 0.08, short = "Voone's Grips (+2% Hit) & Blackcrow", loot = "Voone's Vice Grips, Blackcrow, Omokk's Girth Restrainer, UBRS Key" },
            HUNTER  = { mod = 0.09, short = "Voone's Grips (+2% Hit) & Blackcrow", loot = "Voone's Vice Grips (+2% Hit BiS), Blackcrow (BiS Crossbow), Truestrike Pre-Run" },
            WARRIOR = { mod = 0.08, short = "Omokk's Girdle (+1% Crit/+1% Hit)", loot = "Omokk's Girth Restrainer, Voone's Vice Grips, Blackcrow, UBRS Key" },
            DRUID   = { mod = 0.08, short = "Omokk's Girdle & Hands of Power", loot = "Omokk's Girth Restrainer, Hands of Power, UBRS Key" },
            PALADIN = { mod = 0.08, short = "Omokk's Girdle & Hands of Power", loot = "Omokk's Girth Restrainer, Hands of Power, UBRS Key" },
            SHAMAN  = { mod = 0.08, short = "Hands of Power & Skyshroud", loot = "Hands of Power, Skyshroud Leggings, Omokk's Girth Restrainer, UBRS Key" },
            MAGE    = { mod = 0.08, short = "Hands of Power & Skyshroud Legs", loot = "Hands of Power (BiS Gloves), Skyshroud Leggings (BiS Legs), UBRS Key" },
            PRIEST  = { mod = 0.08, short = "Hands of Power & Truefaith Pattern", loot = "Hands of Power, Pattern: Robe of the Archmage / Truefaith, UBRS Key" },
            WARLOCK = { mod = 0.08, short = "Hands of Power & Skyshroud Legs", loot = "Hands of Power (BiS Gloves), Skyshroud Leggings (BiS Legs), UBRS Key" },
        },
    },
    ["Dire Maul"] = {
        sweetMin = 56, sweetMax = 60, allianceQuests = 6, hordeQuests = 6,
        classes = {
            ROGUE   = { mod = 0.09, short = "Tarnished Elven Ring (+1% Hit BiS)", loot = "Tarnished Elven Ring (+1% Hit BiS), Royal Seal Class Trinket, Counterattack Lodestone" },
            HUNTER  = { mod = 0.09, short = "Tarnished Elven Ring & Barbarous Blade", loot = "Tarnished Elven Ring (+1% Hit BiS), Barbarous Blade (+1% Crit/+60 AP BiS), Royal Seal" },
            WARRIOR = { mod = 0.09, short = "Tarnished Elven Ring & Barbarous Blade", loot = "Tarnished Elven Ring (+1% Hit BiS), Barbarous Blade, Counterattack Lodestone" },
            DRUID   = { mod = 0.09, short = "Tarnished Elven Ring & Padre's", loot = "Tarnished Elven Ring, Padre's Trousers, Royal Seal Class Trinket" },
            PALADIN = { mod = 0.09, short = "Padre's Trousers & Royal Seal", loot = "Padre's Trousers, Mindtap Talisman, Tarnished Elven Ring, Royal Seal" },
            SHAMAN  = { mod = 0.09, short = "Padre's Trousers & Mindtap Talisman", loot = "Padre's Trousers, Mindtap Talisman, Tarnished Elven Ring, Royal Seal" },
            MAGE    = { mod = 0.09, short = "Rod of the Ogre Magi & Mindtap", loot = "Rod of the Ogre Magi (BiS Staff), Mindtap Talisman, Tempest Talisman, Royal Seal" },
            PRIEST  = { mod = 0.09, short = "Padre's Trousers & Mindtap (BiS)", loot = "Padre's Trousers (BiS Legs), Mindtap Talisman (BiS Trinket), Royal Seal" },
            WARLOCK = { mod = 0.09, short = "Rod of the Ogre Magi & Felcloth", loot = "Rod of the Ogre Magi (BiS Staff), Mindtap Talisman, Royal Seal, Dreadsteed" },
        },
    },
    ["Blackmaw Hold"] = {
        sweetMin = 56, sweetMax = 60, allianceQuests = 4, hordeQuests = 4,
        classes = {
            ROGUE   = { mod = 0.07, short = "Great Bear Claw & Nama's Necklace", loot = "Great Bear Claw, Wild Malleus, Nama's Cherished Necklace" },
            WARRIOR = { mod = 0.07, short = "Great Bear Claw & Wild Malleus", loot = "Great Bear Claw, Wild Malleus, Nama's Cherished Necklace" },
            HUNTER  = { mod = 0.07, short = "Great Bear Claw & Nama's Necklace", loot = "Great Bear Claw, Staff of Wild Beasts, Nama's Cherished Necklace" },
            DRUID   = { mod = 0.07, short = "Staff of Wild Beasts & Bear Claw", loot = "Staff of Wild Beasts, Great Bear Claw, Nama's Cherished Necklace" },
            PALADIN = { mod = 0.07, short = "Wild Malleus & Nama's Necklace", loot = "Wild Malleus, Great Bear Claw, Nama's Cherished Necklace" },
            SHAMAN  = { mod = 0.07, short = "Wild Malleus & Staff of Beasts", loot = "Wild Malleus, Staff of Wild Beasts, Nama's Cherished Necklace" },
            MAGE    = { mod = 0.07, short = "Staff of Wild Beasts & Necklace", loot = "Staff of Wild Beasts, Wild Malleus, Nama's Cherished Necklace" },
            PRIEST  = { mod = 0.07, short = "Staff of Wild Beasts & Malleus", loot = "Staff of Wild Beasts, Wild Malleus, Nama's Cherished Necklace" },
            WARLOCK = { mod = 0.07, short = "Staff of Wild Beasts & Necklace", loot = "Staff of Wild Beasts, Wild Malleus, Nama's Cherished Necklace" },
        },
    },
    ["Upper Blackrock Spire"] = {
        sweetMin = 58, sweetMax = 60, allianceQuests = 4, hordeQuests = 4,
        classes = {
            ROGUE   = { mod = 0.09, short = "Dal'Rend's, Truestrike & +2% Crit", loot = "Dal'Rend's Swords, Blackhand's Breadth (+2% Crit BiS), Truestrike Shoulders (+2% Hit)" },
            WARRIOR = { mod = 0.09, short = "Dal'Rend's, Truestrike & +2% Crit", loot = "Dal'Rend's Swords, Blackhand's Breadth (+2% Crit BiS), Truestrike Shoulders (+2% Hit)" },
            HUNTER  = { mod = 0.09, short = "Blackhand's Breadth & Truestrike", loot = "Blackhand's Breadth (+2% Crit BiS), Truestrike Shoulders (+2% Hit), Dal'Rend's" },
            PALADIN = { mod = 0.09, short = "Blackhand's Breadth & Briarwood", loot = "Blackhand's Breadth (+2% Crit), Briarwood Reed, Truestrike Shoulders" },
            DRUID   = { mod = 0.09, short = "Blackhand's Breadth & Briarwood", loot = "Blackhand's Breadth (+2% Crit), Briarwood Reed, Truestrike Shoulders" },
            SHAMAN  = { mod = 0.09, short = "Blackhand's Breadth & Briarwood", loot = "Blackhand's Breadth (+2% Crit), Briarwood Reed, Eye of the Beast" },
            MAGE    = { mod = 0.09, short = "Briarwood Reed & Eye of the Beast", loot = "Briarwood Reed (BiS Trinket), Eye of the Beast (+2% Spell Crit BiS), BWL Attune" },
            PRIEST  = { mod = 0.09, short = "Briarwood Reed & Tooth of Gnarr", loot = "Briarwood Reed (BiS Trinket), Eye of the Beast, Tooth of Gnarr, BWL Attune" },
            WARLOCK = { mod = 0.09, short = "Briarwood Reed & Eye of the Beast", loot = "Briarwood Reed (BiS Trinket), Eye of the Beast (+2% Spell Crit BiS), BWL Attune" },
        },
    },
    ["Scholomance"] = {
        sweetMin = 58, sweetMax = 60, allianceQuests = 5, hordeQuests = 5,
        classes = {
            ROGUE   = { mod = 0.09, short = "Mirah's Song (BiS 1H) & Cadaverous", loot = "Mirah's Song (BiS Offhand Sword), Cadaverous Armor (BiS Chest), Shadowcraft Cap" },
            WARRIOR = { mod = 0.09, short = "Mirah's Song & Deathbone/Valor", loot = "Mirah's Song (BiS 1H), Cadaverous Armor, Helm of Valor, Bonelicing Hatchet" },
            HUNTER  = { mod = 0.08, short = "Cadaverous Armor & Bonelicing", loot = "Cadaverous Armor (BiS Chest), Bonelicing Hatchet, Beaststalker's Cap" },
            PALADIN = { mod = 0.08, short = "Deathbone Set & Penelope's Rose", loot = "Penelope's Rose, Cadaverous Armor, Lightforge Helm, Deathbone Plate" },
            DRUID   = { mod = 0.08, short = "Cadaverous Armor & Penelope's Rose", loot = "Cadaverous Armor (BiS Feral), Penelope's Rose, Wildheart Cowl" },
            SHAMAN  = { mod = 0.09, short = "Helm of Latent Power (Class BiS)", loot = "Helm of Latent Power (Shaman Class Quest), Penelope's Rose, Cadaverous Armor" },
            MAGE    = { mod = 0.09, short = "Witchblade, Necropile & T0 Head", loot = "Witchblade, Necropile Robe, Star of Mystaria, Magister's Crown" },
            PRIEST  = { mod = 0.09, short = "Penelope's Rose & Necropile Set", loot = "Penelope's Rose, Alanna's Embrace, Necropile Robe, Devout Crown" },
            WARLOCK = { mod = 0.09, short = "Witchblade, Necropile & Dreadsteed", loot = "Witchblade, Necropile Robe, Dreadsteed Alchemy Lab, Dreadmist Mask" },
        },
    },
    ["Stratholme"] = {
        sweetMin = 58, sweetMax = 60, allianceQuests = 6, hordeQuests = 6,
        classes = {
            ROGUE   = { mod = 0.09, short = "Mask of the Unforgiven & Baron Cape", loot = "Mask of the Unforgiven (+2% Hit/+1% Crit BiS), Cape of the Black Baron (BiS)" },
            WARRIOR = { mod = 0.09, short = "Mask of the Unforgiven & Baron Cape", loot = "Mask of the Unforgiven (+2% Hit/+1% Crit BiS), Cape of the Black Baron (BiS)" },
            HUNTER  = { mod = 0.09, short = "Cape of the Black Baron & Mask", loot = "Cape of the Black Baron (BiS Cloak), Mask of the Unforgiven, Diana's Pearl Necklace" },
            PALADIN = { mod = 0.09, short = "Fordring's Seal & Animated Chain", loot = "Fordring's Seal (BiS Ring), Animated Chain Necklace (BiS Neck), Mask of Unforgiven" },
            DRUID   = { mod = 0.09, short = "Fordring's Seal &Mask of Unforgiven", loot = "Fordring's Seal (BiS Heal Ring), Mask of the Unforgiven (BiS Feral), Animated Chain" },
            SHAMAN  = { mod = 0.09, short = "Fordring's Seal & Animated Chain", loot = "Fordring's Seal (BiS Ring), Animated Chain Necklace (BiS Neck), Baron Cape" },
            MAGE    = { mod = 0.09, short = "Crimson Felt Hat & Fordring's Seal", loot = "Crimson Felt Hat (BiS Head), Diana's Pearl Necklace, Tome of Conjure Food VII" },
            PRIEST  = { mod = 0.09, short = "Robes of the Exalted & Fordring's", loot = "Robes of the Exalted (BiS Chest), Fordring's Seal (BiS Ring), Animated Chain" },
            WARLOCK = { mod = 0.09, short = "Crimson Felt Hat & Pearl Necklace", loot = "Crimson Felt Hat (BiS Head), Diana's Pearl Necklace,Choker of theiren" },
        },
    },
    ["Shaper's Terrace"] = {
        sweetMin = 58, sweetMax = 60, allianceQuests = 4, hordeQuests = 4,
        classes = {
            WARRIOR = { mod = 0.08, short = "Crystalline Pauldrons & Titan Relic", loot = "Crystalline Pauldrons, Potent Treads, Titan Relic Pre-BiS Rewards" },
            PALADIN = { mod = 0.08, short = "Crystalline Pauldrons & Titan Relic", loot = "Crystalline Pauldrons, Potent Treads, Titan Relic Pre-BiS Rewards" },
            ROGUE   = { mod = 0.08, short = "Potent Treads & Titan Relic", loot = "Potent Treads, Crystalline Pauldrons, Titan Relic Pre-BiS Rewards" },
            HUNTER  = { mod = 0.08, short = "Potent Treads & Titan Relic", loot = "Potent Treads, Crystalline Pauldrons, Titan Relic Pre-BiS Rewards" },
            DRUID   = { mod = 0.08, short = "Potent Treads & Titan Relic", loot = "Potent Treads, Crystalline Pauldrons, Titan Relic Pre-BiS Rewards" },
            SHAMAN  = { mod = 0.08, short = "Crystalline Pauldrons & Titan Relic", loot = "Crystalline Pauldrons, Potent Treads, Titan Relic Pre-BiS Rewards" },
            MAGE    = { mod = 0.08, short = "Potent Treads & Titan Relic", loot = "Potent Treads, Crystalline Pauldrons, Titan Relic Pre-BiS Rewards" },
            PRIEST  = { mod = 0.08, short = "Potent Treads & Titan Relic", loot = "Potent Treads, Crystalline Pauldrons, Titan Relic Pre-BiS Rewards" },
            WARLOCK = { mod = 0.08, short = "Potent Treads & Titan Relic", loot = "Potent Treads, Crystalline Pauldrons, Titan Relic Pre-BiS Rewards" },
        },
    },
}
addon.Data.DungeonProfiles["The Temple of Atal'Hakkar"] = addon.Data.DungeonProfiles["Sunken Temple"]

function addon.Data.GetDungeonProfile(zoneName, playerClass, playerFaction)
    if type(zoneName) ~= "string" or zoneName == "" then return nil end
    local prof = addon.Data.DungeonProfiles[zoneName]
    if not prof then
        local lower = string.lower(zoneName)
        local noThe = string.gsub(lower, "^the%s+", "")
        for k, v in pairs(addon.Data.DungeonProfiles) do
            local kLower = string.lower(k)
            if kLower == lower or string.gsub(kLower, "^the%s+", "") == noThe then
                prof = v
                break
            end
        end
    end
    if not prof then return nil end

    local pClass = playerClass or "WARRIOR"
    local pFaction = playerFaction or "Alliance"
    local cEntry = (prof.classes and prof.classes[pClass]) or (prof.classes and prof.classes.WARRIOR) or {}
    local questCount
    if pFaction == "Alliance" then
        questCount = cEntry.allianceQuests or prof.allianceQuests or 3
    else
        questCount = cEntry.hordeQuests or prof.hordeQuests or 3
    end

    return {
        sweetMin = prof.sweetMin,
        sweetMax = prof.sweetMax,
        questCount = questCount,
        classMod = cEntry.mod or 0.04,
        shortLoot = cEntry.short or "Dungeon Gear & Quests",
        loot = cEntry.loot or "Dungeon Boss Drops & Quest Rewards",
    }
end
