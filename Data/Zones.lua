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
        isAlias = true, density = "High", hubMod = 0.02, hub = "Riverlands Hubs",
        summary = "WoW Forever custom 35-45 zone packed with custom quest chains and blue gear upgrades." },
    ["Riverlands"]          = { min = 35, max = 45, faction = "Contested", continent = 2, mapID = 2548, beastHeavy = true, humanoidHeavy = true,
        density = "High", hubMod = 0.02, hub = "Riverlands Hubs",
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
