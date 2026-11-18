--[[
    WorthIt / QuestWorth - Data/Tips.lua
    Curated hints & sourcing guide for cryptic, puzzle, vendor-bought,
    hidden ground item, and search quests across Classic & WoW: Forever.
    
    Helps players instantly know:
    - Where to find hidden objects/tomes/chests (e.g. Raven Hill Tome)
    - Which mobs drop un-obvious items (e.g. Lean Wolf Flanks from Duskwood wolves)
    - Which items are bought from vendors (e.g. Soothing Spices, Bronze Tube)
    - How to trigger puzzle/interaction mechanics (e.g. Cluck!, Morbent Fel holy water)
]]

local addonName, addon = ...
addon.Data = addon.Data or {}
local Data = addon.Data

-- 1. Direct quest tips keyed by questID
Data.QuestTips = {
    -- Duskwood
    [225]  = "Inspect the Weathered Grave at Raven Hill Cemetery (17.7, 29.1) and bring it to Sirra Von'Indi in Darkshire.",
    [226]  = "Kill 12 Starving Dire Wolves and 8 Rabid Dire Wolves along the northern riverbank near Sven's Camp (44, 15).",
    [227]  = "Listen to Sirra Von'Indi's story in Darkshire and speak with Commander Althea Ebonlocke. Safe talk-to step in the Mor'Ladim chain.",
    [228]  = "DANGER: Mor'Ladim is a level 35 Elite roaming northeast of Raven Hill Cemetery (19, 34). Bring a group or kite toward the Darkshire road guards!",
    [229]  = "Deliver Morgan's skull to Watcher Sarah Ladimore along the Darkshire road.",
    [230]  = "Return the Book from Sven's Farm to Sven Yorgen at Sven's Camp (7.8, 34.1) in northwest Duskwood.",
    [231]  = "Place Sarah's Ring onto Morgan Ladimore's grave at Raven Hill Cemetery (17.7, 29.1) to complete the chain and claim Archeus!",
    [90]   = "Seasoned Wolf Kabobs: Needs 10 Lean Wolf Flanks (Prairie Wolves / Starving Dire Wolves in Duskwood or AH) + Stormwind Seasoning Herbs (Felicia Gump in Stormwind Canals, 64,60).",
    [93]   = "Dusky Crab Cakes: Needs 6 Gooey Spider Legs — drop from Pygmy Venom Web Spiders and Green Recluse spiders in northern/western Duskwood.",
    [174]  = "Look to the Stars (Step 1/4): Needs 1 Bronze Tube — crafted by Engineers or sold by Gearcutter Cogspinner (Stormwind), Neal Allen (Menethil), or Gnaz Blunderflame (STV).",
    [175]  = "Look to the Stars (Step 2/4): Speak with Blind Mary in the haunted house southeast of Darkshire (81.9, 59.3).",
    [177]  = "Look to the Stars (Step 3/4): Kill the Insane Ghoul inside the chapel at Tranquil Gardens Cemetery (79, 70) for Mary's Looking Glass.",
    [181]  = "Look to the Stars (Step 4/4 Finale): Kill Zzarc'Vul inside the cave at Vul'Gol Ogre Mound (36, 80) for the Ogre's Monocle.",
    [165]  = "The Hermit: Speak with Abercrombie at his shack on the northeast edge of Raven Hill Cemetery (28.0, 31.5).",
    [148]  = "Supplies from Darkshire: Deliver Abercrombie's letter to Madame Eva in Darkshire (part of the Hermit/Eliza chain).",
    [149]  = "Ghost Hair Thread: Take Madame Eva's Spectralfuge to Blind Mary in the haunted house southeast of Darkshire (81.9, 59.3).",
    [154]  = "Return the Comb from Blind Mary back to Madame Eva in Darkshire.",
    [156]  = "Gather Rot Blossoms: Drop from Skeletal Horrors and Skeletal Fiends at Raven Hill Cemetery (around the crypt at 20, 45).",
    [157]  = "Deliver the Thread from Madame Eva back to Abercrombie at his shack north of Raven Hill Cemetery.",
    [158]  = "Zombie Juice: Bring Abercrombie's crate of Zombie Juice to Tavernkeep Smitts in Darkshire.",
    [159]  = "Juice Delivery: Deliver Tavernkeep Smitts' Ghost-o-plasm back to Abercrombie north of Raven Hill.",
    [133]  = "Ghoulish Effigy: Collect 7 Ghoul Ribs from flesh-eating ghouls and horrors around Raven Hill Cemetery.",
    [134]  = "Ogre Thieves: Loot Abercrombie's Crate just outside the cave entrance at Vul'Gol Ogre Mound (33.4, 76.3) in southern Duskwood.",
    [253]  = "Bride of the Embalmer Finale: Dig up Eliza's Grave (28.8, 30.9) north of Abercrombie's shack. WARNING: Spawns Lvl 31 Elite Eliza + 3 guards — bring help!",
    [66]   = "Legend of Stalvan (Step 1): Speak with Clerk Daltry inside the Darkshire Town Hall.",
    [67]   = "Legend of Stalvan (Step 2): Inspect the Old Footlocker inside the ruined Moonbrook Schoolhouse in Westfall (41.5, 66.7).",
    [68]   = "Legend of Stalvan (Step 3): Return the Moonbrook clues to Clerk Daltry in Darkshire.",
    [69]   = "Legend of Stalvan (Step 4): Deliver the sealed box to Innkeeper Farley at Lion's Pride Inn in Goldshire.",
    [70]   = "Legend of Stalvan (Step 5): Loot the Undelivered Letter from the Storage Chest upstairs in the Lion's Pride Inn in Goldshire (44.2, 65.8).",
    [72]   = "Legend of Stalvan (Step 7): Open the Sealed Crate beside the canal building in Stormwind Trade District (56.8, 64.6).",
    [75]   = "Legend of Stalvan (Step 9): Loot the Faded Journal Page from Marshal Haggard's Chest upstairs at the Eastvale Logging Camp (85.6, 69.0).",
    [98]   = "Legend of Stalvan Finale: Slay Stalvan Mistmantle (Lvl 32 undead) inside Manor Mistmantle north of Darkshire (77.6, 35.6).",
    [95]   = "Sven's Revenge: Find the Mound of Loose Dirt behind the barn at the Addle Stead (49.8, 77.7) in southern Duskwood.",
    [55]   = "Morbent Fel: Target Morbent Fel in the upper floor of the northern Raven Hill house (17, 33) and USE Morbent's Bane from your bags to strip his shield!",
    [101]  = "The Totem of Infliction: Collect 10 Ghoul Fangs, 10 Skeleton Fingers, and 5 Vials of Spider Venom in western Duskwood for Madame Eva.",
    [173]  = "Worgen in the Woods: Kill 6 Nightbane Shadow Weavers around the Rotting Orchard and southeastern Duskwood mounds (64, 72).",

    -- Westfall & Elwynn
    [151]  = "Handfuls of Oats are scattered on the ground around the farms in Westfall (near Saldean and Furlbrow).",
    [153]  = "Red Leather Bandanas: Collect 15 Red Leather Bandanas from Defias bandits across Westfall (Moonbrook, Gold Coast Quarry, Jangolode Mine).",
    [22]   = "Goretusk Liver Pie: Collect 8 Goretusk Livers from Goretusks and Young Goretusks across Westfall.",
    [36]   = "Westfall Stew Breadcrumb: Deliver Wiley's Stew notice to Salma Saldean at Saldean's Farm (56.4, 30.6). Safe talk-to step.",
    [38]   = "Westfall Stew: Needs 3 Stringy Vulture Meat (Fleshrippers), 3 Murloc Eyes (coast), 3 Goretusk Snouts (Boars), and 3 Okra (Harvest Watchers in fields).",
    [85]   = "Lost Necklace: Deliver Bernice Stonefield's Lost Necklace to Billy Maclure at the Maclure Vineyards (43, 86).",
    [87]   = "Goldtooth: Billy's Lost Necklace drops from Goldtooth deep inside the back cave of Fargodeep Mine (41, 78) in Elwynn Forest.",
    [88]   = "Princess Must Die!: Princess (level 11 boar) patrols inside the fenced field at the Brackwell Pumpkin Patch (69, 79) with 2 porcine guards.",
    [5545] = "A Bundle of Wood: Gather 8 Bundles of Wood under the trees around the Eastvale Logging Camp in Elwynn Forest.",
    [106]  = "Young Lovers: Deliver Maybell's Love Letter to Tommy Joe Stonefield by the Stonefield Farm riverbank (29.8, 86.0).",
    [3861] = "CLUCK!: Buy Special Chicken Feed from Farmer Saldean (Westfall) or William Maclure (Elwynn), target a Chicken, and /chicken until friendly to feed it for a pet!",

    -- Redridge Mountains
    [129]  = "A Free Lunch: Deliver Darcy's Lunch to Guard Parker at the Three Corners watchpost in western Redridge (15.3, 71.4).",
    [3741] = "Hilary's Necklace: Dive into Lake Everstill near the Lakeshire pier — the Glinting Mud pile spawns underwater between the dock and bridge (around 29, 53).",
    [92]   = "Ingredients: Crisp Spider Meat (spiders), Tough Condor Meat (condors), Great Goretusk Snout (Westfall boars).",
    [91]   = "Solomon's Law: Collect 10 Shadowhide Pendants from Shadowhide Gnolls in northern Redridge Mountains.",
    [119]  = "Return to Verner: Speak with Verner Osgood near the Lakeshire stables in Redridge.",
    [122]  = "Underbelly Scales: Collect 6 Underbelly Whelp Scales from Black Dragon Whelps in southern/eastern Redridge Mountains.",
    [125]  = "The Lost Tools: Dive underwater in Lake Everstill east of the bridge (41.5, 54.6) to open Oslow's Toolbox (watch for elite Murlocs).",
    [169]  = "Wanted: Gath'Ilzogg: Elite Orc Warchief inside Stonewatch Keep (69, 55) — bring a group and combine with Tharil'zun / Shadow Magic.",
    [180]  = "Wanted: Lieutenant Fangore: Level 26 Gnoll boss in the eastern Shadowhide camp at Galardell Valley (80.1, 37.0).",
    [115]  = "Shadow Magic: 3 Midnight Orbs drop from Blackrock Shadowcasters inside Stonewatch Keep and Render's Rock cave in Redridge.",

    -- Darkshore, Ashenvale & Wetlands
    [982]  = "Two waterlogged silver & iron chests are located inside the sunken ship ruins off the Darkshore coast. Keep an eye on your breath bar!",
    [3524] = "Click the giant Sea Creature Ribcage skeleton washed up on the shoreline of Darkshore.",
    [1007] = "Blow the horn at Kerlonian's camp to awaken him. Stay close to protect him from ambushes and wake him if he falls asleep.",
    [963]  = "Follow the glowing runes on the shore to find the ancient statue near the cliffs.",
    [654]  = "Stardust bushes grow on the shrine island in the center of the lake in southern Ashenvale.",
    [1036] = "The Light of Elune: Fill the Phial of Scrying at the pool in Ashenvale; rewards Light of Elune (10s complete immunity potion!).",

    -- The Barrens & Durotar
    [870]  = "The Forgotten Pools: Dive to the bottom of the northern oasis pool in the Barrens (45, 22) and interact with the bubbling white fissure.",
    [877]  = "The Stagnant Oasis: Swim to the bottom center of the Stagnant Oasis (55, 42) and interact with the bubbling water fissure.",
    [871]  = "Disrupt the Attacks: Slay Razormane Water Seekers, Thornweavers, and Hunters just northeast of The Crossroads (54, 25).",
    [872]  = "The Disruption Ends: Kill Kreenig Snarlsnout (58.6, 27.2) in the Razormane camp east of Crossroads for his tusk.",
    [3961] = "Pull control valves 1, 2, 3 inside the Venture Co building. The main console is up on the metal catwalk.",
    [881]  = "Stand on the white lion bone pile on the mountain slope north of Crossroads and blow the horn in your bags.",
    [819]  = "Plainstrider Beaks drop from Fleeting and Greater Plainstriders across central Barrens.",
    [821]  = "Zhevra Hooves drop from Zhevra Chargers and Coursers throughout the Barrens plains.",

    -- Hillsbrad & Arathi
    [555]  = "Turtle Meat drops from River Snappers in the rivers. Soothing Spices are purchased directly from any Cooking Supplies vendor.",
    [1241] = "Question Innkeeper Allison in Menethil Harbor, then travel to Stormwind to confront Dashel Stonefist.",

    -- Stranglethorn Vale
    [185]  = "NORTH STV (Nesingwary): Young Stranglethorn Tigers prowl right around Nesingwary's Expedition camp (Step 1/4 of Tiger Mastery).",
    [186]  = "NORTH STV: Stranglethorn Tigers prowl between Nesingwary's camp and Tkashi Ruins (Step 2/4 of Tiger Mastery).",
    [187]  = "CENTRAL STV: Elder Stranglethorn Tigers prowl west of Bambala and around Tkashi Ruins (Step 3/4 of Tiger Mastery).",
    [188]  = "NORTH STV: Sin'Dall (Lvl 37 Tiger) is atop the hill just south of Nesingwary's Expedition (32, 17).",
    [190]  = "NORTH STV (Nesingwary): Young Panthers prowl north and east of Nesingwary's Expedition (Step 1/4 of Panther Mastery).",
    [194]  = "NORTH STV (Nesingwary): Stranglethorn Raptors roam west of Nesingwary's Expedition toward Zul'Kunda (Step 1/4 of Raptor Mastery).",
    [201]  = "NORTH STV: Locate the hunters' camp north across the river from Nesingwary's Expedition (Lvl 31-33 zone).",
    [213]  = "NORTH STV: Tumbled Crystals drop from Venture Co. geologists in central/north STV around Lake Nazferiti (Lvl 35-36 mobs).",
    [338]  = "Collect Chapter pages 1-27. Pages can be traded or bought directly from other players on the Auction House.",
    [339]  = "Chapter I requires pages 1, 4, 6, 8. Pages can be traded or bought on the Auction House.",
    [340]  = "Chapter II requires pages 10, 11, 14, 16. Pages can be traded or bought on the Auction House.",
    [341]  = "Chapter III requires pages 18, 20, 21, 24. Pages can be traded or bought on the Auction House.",
    [342]  = "Chapter IV requires pages 25, 26, 27. Pages can be traded or bought on the Auction House.",
    [348]  = "SOUTH STV: Witch Doctor Unbagwa is inside the Mistvale Gorilla cave outside Booty Bay (Lvl 40-42 mobs).",
    [575]  = "NORTH STV: Large River Crocolisk Skins drop from young/river crocolisks along the northern STV river (Lvl 30-32, NOT South STV).",
    [578]  = "NORTHWEST STV: The haunted island is off the northwestern coast (west of Zul'Kunda), guarded by Level 37-39 Water Elementals.",
    [587]  = "SOUTH STV: Loot 15 Snuff from Bloodsail pirates (Raiders, Swashbucklers, Warlocks) along the southern coast & ships south/southeast of Booty Bay.",
    [605]  = "NORTH STV: Singing Crystal Shards drop from Basilisks around the crystal mines north of Lake Nazferiti (Lvl 34-36).",
    [606]  = "SOUTH STV: Mistvale Giblets drop from Elder Mistvale Gorillas in the valley outside Booty Bay (Lvl 40-42 mobs).",
    [617]  = "Akiris reeds grow in large bundles along the riverbanks and naga coast in northern Stranglethorn.",
    [624]  = "Cortello's Riddle 1/3: Scroll starts on Bloodsail ships; follow clue under the bridge in Swamp of Sorrows (22.8, 48.1).",
    [625]  = "Cortello's Riddle 2/3: Check the submerged wooden chest under the stone bridge in Swamp of Sorrows (22.8, 48.1), then head to Dustwallow Marsh.",
    [626]  = "Cortello's Riddle 3/3 Finale: Treasure chest is inside the cave behind the waterfall in The Hinterlands (80.8, 46.8) -> 14-Slot Bag + huge XP!",
    [627]  = "Favor for Krazek: Needs 4 Lesser Bloodstone Ore — mined in Arathi Highlands (Drywhisker Gorge cave, 80, 39) or bought on the Auction House.",

    -- Tanaris & Un'Goro
    [2605] = "Dew Glands drop from Wasps and Scorpids throughout the Tanaris desert dunes.",
    [3844] = "Defeat primal oozes in Felwood / Un'Goro, then target the remains and USE the Empty Canteen in your bags.",
    [3984] = "Use the Golden Flame near Fire Plume Ridge in Un'Goro to strip Blazerunner's elemental invulnerability.",
}

-- 2. Title-based lookup (case-insensitive & stripped of prefixes)
Data.QuestTipsByTitle = {
    -- Duskwood
    ["the valor family"]                  = "The Raven Hill Tome is inside a chest in the southern mausoleum/crypt of Raven Hill Cemetery.",
    ["seasoned wolf kabobs"]              = "Lean Wolf Flanks drop from Prairie Wolves & Starving Dire Wolves in western Duskwood (around Raven Hill) + Stormwind Seasoning Herbs (Felicia Gump in Stormwind Canals).",
    ["dusky crab cakes"]                  = "Gooey Spider Legs drop from Pygmy Venom Web Spiders and Green Recluse spiders in northern/western Duskwood.",
    ["look to the stars"]                 = "Bronze Tube is crafted by Engineers or sold in limited quantities by Gearcutter Cogspinner (Stormwind), Neal Allen (Menethil), or Gnaz Blunderflame (STV).",
    ["the hermit"]                        = "Speak with Abercrombie at his shack on the northeast edge of Raven Hill Cemetery (28.0, 31.5).",
    ["ogre thieves"]                      = "Abercrombie's Crate sits just outside the cave entrance at Vul'Gol Ogre Mound (33.4, 76.3) in southern Duskwood.",
    ["the legend of stalvan"]             = "Clue 1: Moonbrook schoolhouse chest. Clue 2: Goldshire Lion's Pride Inn (2nd floor). Clue 3: Stormwind Canal house.",
    ["morbent fel"]                       = "Target Morbent Fel and USE Morbent's Bane (Holy Water) from your bags to strip his shield before attacking!",
    ["gather rot blossoms"]               = "Rot Blossoms drop from Skeletal Horrors and Skeletal Fiends at Raven Hill Cemetery (around the crypt at 20, 45).",
    ["rot blossom"]                       = "Rot Blossoms drop from Skeletal Horrors and Skeletal Fiends at Raven Hill Cemetery (around the crypt at 20, 45).",
    ["the totem of infliction"]           = "Collect 10 Ghoul Fangs, 10 Skeleton Fingers, and 5 Vials of Spider Venom in western Duskwood for Madame Eva in Darkshire.",
    ["a recipe for death"]                = "Collect reagents from spiders and ghouls, then interact with the Cauldron in Raven Hill cemetery.",
    ["worgen in the woods"]               = "Kill Nightbane Shadow Weavers around the Rotting Orchard and southeastern Duskwood mounds (64, 72).",

    -- Westfall & Elwynn
    ["poor old blanchy"]                  = "Handfuls of Oats are scattered on the ground around the farms in Westfall (near Saldean and Furlbrow).",
    ["westfall stew"]                     = "Stringy Vulture Meat (fleshrippers), Goretusk Snout (boars), Murloc Eye (coast), Okra (Harvest Watchers).",
    ["goretusk liver pie"]                = "Goretusk Livers drop from all wild boars and goretusks across Westfall.",
    ["cluck!"]                            = "Buy 'Special Chicken Feed' from Farmer Saldean in Westfall or William Maclure in Elwynn. Target a chicken and /chicken repeatedly until friendly!",
    ["the lost necklace"]                 = "Deliver Bernice Stonefield's Lost Necklace to Billy Maclure at the Maclure Vineyards (Goldtooth holds it in Fargodeep Mine).",
    ["goldtooth"]                         = "Kill Goldtooth deep inside the back cave of Fargodeep Mine (41, 78) in Elwynn Forest.",
    ["a bundle of wood"]                  = "Wood bundles are scattered on the ground around the timber yard in Eastvale Logging Camp.",
    ["gold dust exchange"]                = "Gold Dust drops from all kobolds inside the Elwynn mines (Fargodeep & Jasperlode).",

    -- Redridge
    ["hilary's necklace"]                 = "Hilary's Necklace is inside a glinting object on the lake floor right near the wooden dock in Lakeshire (29, 53).",
    ["redridge goulash"]                  = "Crisp Spider Meat (spiders), Tough Condor Meat (condors), Great Goretusk Snout (Westfall boars).",
    ["solomon's law"]                     = "Collect 10 Shadowhide Pendants from Shadowhide Gnolls in northern Redridge Mountains.",
    ["the lost tools"]                    = "Dive underwater in Lake Everstill east of the bridge (41.5, 54.6) to open Oslow's Toolbox (watch for elite Murlocs).",
    ["underbelly scales"]                 = "Loot Underbelly Scales from dragon whelps flying in the mountains southeast/northeast of Lake Everstill.",

    -- Darkshore & Ashenvale
    ["deep ocean, vast sea"]              = "Two waterlogged silver & iron chests are located inside the sunken ship ruins off the Darkshore coast. Watch your breath bar!",
    ["washed ashore"]                     = "Click the giant Sea Creature Ribcage skeleton washed up on the shoreline of Darkshore.",
    ["beached sea creature"]              = "Interact with the large beached bones washed up along the shoreline.",
    ["the sleeper has awakened"]          = "Blow the horn at Kerlonian's camp. Protect him from ambush waves and wake him if he falls asleep.",
    ["the ruins of stardust"]             = "Stardust bushes grow on the shrine island in the center of the lake in southern Ashenvale.",
    ["warsong supplies"]                  = "Lumber, oil, rope, and axes are scattered across the ground in the Warsong Lumber Camp.",

    -- The Barrens & Durotar
    ["the forgotten pools"]               = "Dive to the bottom of the northern pool in the Barrens and interact with the bubbling white fissure.",
    ["the stagnant oasis"]                = "Swim to the bottom center of the stagnant oasis and interact with the bubbling white water fissure.",
    ["the lushwater oasis"]               = "Dive to the bubbling fissure on the bottom floor of the southern oasis.",
    ["samophlange"]                       = "Pull control valves 1, 2, 3 inside the Venture Co building. The main console is up on the metal catwalk.",
    ["samophlange manual"]                = "The manual is found on the control console up on the metal catwalk inside the Venture Co compound.",
    ["echeyakee"]                         = "Stand on the white lion bone pile on the mountain slope north of Crossroads and blow the horn in your bags.",
    ["chen's empty keg"]                  = "Hidden drop item! Take the keg to Brewmaster Drohn in Ratchet to start the quest chain.",
    ["plainstrider menace"]               = "Plainstrider Beaks drop from Fleeting and Greater Plainstriders across central Barrens.",
    ["zhevra hooves"]                     = "Zhevra Hooves drop from Zhevra Chargers and Coursers throughout the Barrens plains.",

    -- Hillsbrad & Arathi
    ["soothing turtle bisque"]            = "Turtle Meat drops from River Snappers in the rivers. Soothing Spices are purchased directly from any Cooking Supplies vendor.",
    ["the missing diplomat"]              = "Question Innkeeper Allison in Menethil Harbor, then travel to Stormwind to confront Dashel Stonefist.",
    ["costly menace"]                     = "Mountain Lions prowl in the hills and grassy highlands north of Southshore.",

    -- Stranglethorn
    ["tiger mastery"]                     = "NORTH STV (Nesingwary): Young Stranglethorn Tigers prowl around Nesingwary's Expedition; chain leads to Sin'Dall & Big Game Hunter.",
    ["panther mastery"]                   = "NORTH STV (Nesingwary): Young Panthers prowl north/east of Nesingwary's Expedition; chain leads to Bhag'thera & Big Game Hunter.",
    ["raptor mastery"]                    = "NORTH STV (Nesingwary): Stranglethorn Raptors roam west of Nesingwary's Expedition; chain leads to Tethis & Big Game Hunter.",
    ["the green hills of stranglethorn"]  = "Collect Chapter pages 1-27. Pages can be traded or bought directly from other players on the Auction House.",
    ["chapter i"]                         = "Chapter I requires pages 1, 4, 6, 8. Pages can be traded or bought on the Auction House.",
    ["chapter ii"]                        = "Chapter II requires pages 10, 11, 14, 16. Pages can be traded or bought on the Auction House.",
    ["chapter iii"]                       = "Chapter III requires pages 18, 20, 21, 24. Pages can be traded or bought on the Auction House.",
    ["chapter iv"]                        = "Chapter IV requires pages 25, 26, 27. Pages can be traded or bought on the Auction House.",
    ["cortello's riddle"]                 = "Step 1: Under bridge in STV. Step 2: Swamp of Sorrows cave. Step 3: Hinterlands waterfall.",
    ["supply and demand"]                 = "NORTH STV: River Crocolisks swim in the northern STV river (Lvl 30-32). Pick up in Booty Bay, hunt in the north!",
    ["investigate the camp"]              = "NORTH STV: Locate Nesingwary's Expedition north across the river (Lvl 31-33 area).",
    ["singing blue shards"]               = "NORTH STV: Singing Crystal Shards drop from Basilisks around the crystal mines north of Lake Nazferiti (Lvl 34-36).",
    ["hostile takeover"]                  = "NORTH STV: Tumbled Crystals drop from Venture Co. geologists in central/north STV near Lake Nazferiti (Lvl 35-36 mobs).",
    ["the stone of the tides"]            = "NORTHWEST STV: The haunted island is off the northwestern coast (west of Zul'Kunda), guarded by Level 37-39 Water Elementals.",
    ["scaring shaky"]                     = "SOUTH STV: Mistvale Giblets drop from Elder Mistvale Gorillas in the valley outside Booty Bay (Lvl 40-42 mobs).",
    ["akiris by the bundle"]              = "Akiris reeds grow in large bundles along the riverbanks and naga coast in northern Stranglethorn.",

    -- Tanaris & Un'Goro
    ["noggenfogger elixir"]               = "Dew Glands drop from Wasps and Scorpids throughout the Tanaris desert dunes.",
    ["it's dangerous to go alone"]        = "Use the Golden Flame near Fire Plume Ridge in Un'Goro to strip Blazerunner's elemental invulnerability.",
    ["a little slime goes a long way"]    = "Defeat primal oozes in Felwood / Un'Goro, then target the remains and USE the Empty Canteen in your bags.",

    -- General / Class Quests
    ["the test of righteousness"]         = "Whitestone Oak from Deadmines, Jordan's Ore from Loch Modan, Kor Gem from BFD, and Jordan's Hammer from Shadowfang Keep.",
    ["whirlwind weapon"]                  = "Whirlwind Axe: Bloodscalp Tusks (STV), 8 of each Charms (Arathi elementals), and defeat Cyclonian.",
}

-- 3. Objective & Item Sourcing Tips
-- Matched against required quest item names, objectives, and progress strings
Data.ObjectiveItemTips = {
    -- Cryptic & Quest Specific Drops / Objects
    ["raven hill tome"]          = "Inside a chest in the southern mausoleum/crypt of Raven Hill Cemetery in Duskwood.",
    ["lean wolf flank"]          = "Drops from Prairie Wolves & Starving Dire Wolves in western Duskwood (around Raven Hill). Tradeable on AH.",
    ["bronze tube"]              = "Crafted by Engineers (skill 65) or sold in limited quantity by engineering vendors in Ironforge, Orgrimmar, or Duskwood.",
    ["hilary's necklace"]        = "Inside a glinting object on the lake floor right near the wooden dock in Lakeshire.",
    ["special chicken feed"]     = "Purchased from Farmer Saldean at the Saldean Farm in Westfall.",
    ["handful of oats"]          = "Spawn on the ground around the farms in Westfall.",
    ["rot blossom"]              = "Gathered from purple bushes near the corrupted giant tree in southern Duskwood.",
    ["ghost hair thread"]        = "Looted from weeping ghosts in the Raven Hill cemetery.",
    ["skeletal finger"]          = "Looted from skeletons in Raven Hill and Addle's Stead in Duskwood.",
    ["ghoul rib"]                = "Looted from flesh-eating ghouls in Raven Hill Cemetery.",
    ["dew gland"]                = "Drops from Tanaris dune wasps and scorpids across the desert.",
    ["mistvale giblets"]         = "Drops from elder mistvale gorillas in the valley south of Booty Bay.",
    ["akiris reed"]              = "Harvested from reed clusters growing along the riverbanks in northern Stranglethorn.",
    ["stardust"]                 = "Harvested from bushes on the shrine island in the southern Ashenvale lake.",
    ["underbelly scale"]         = "Drops from dragon whelps flying in the northeast mountains of Redridge.",
    ["wood bundle"]              = "Bundles lying on the ground around the Eastvale Logging Camp in Elwynn.",
    ["gold dust"]                = "Drops from all kobolds inside the Fargodeep and Jasperlode mines in Elwynn.",
    ["samophlange manual"]       = "Found on the control console up on the metal catwalk inside the Venture Co compound.",

    -- Cooking & Vendor Reagents
    ["soothing spices"]          = "Purchased directly from any Cooking Supplies vendor in towns.",
    ["mild spices"]              = "Purchased directly from any Cooking Supplies vendor.",
    ["hot spices"]               = "Purchased directly from any Cooking Supplies vendor.",
    ["moonberry juice"]          = "Purchased from Innkeepers and Food & Drink vendors (level 45+ drink).",
    ["morning glory dew"]        = "Purchased from Innkeepers and Food & Drink vendors (level 35+ drink).",
    ["sweet nectar"]             = "Purchased from Innkeepers and Food & Drink vendors (level 25+ drink).",
    ["melon juice"]              = "Purchased from Innkeepers and Food & Drink vendors (level 15+ drink).",
    ["ice cold milk"]            = "Purchased from Innkeepers and General Goods vendors (level 5+ drink).",
    ["refreshing spring water"]   = "Purchased from General Goods vendors and Innkeepers.",
    ["crisp spider meat"]        = "Drops from forest and tarantula spiders in Redridge and Duskwood.",
    ["tough condor meat"]        = "Drops from condors in the Redridge Mountains.",
    ["goretusk liver"]           = "Drops from wild boars and goretusks in Westfall.",
    ["goretusk snout"]           = "Drops from wild boars and goretusks in Westfall.",
    ["stringy vulture meat"]     = "Drops from fleshrippers and vultures in Westfall.",
    ["murloc eye"]               = "Drops from murlocs along coastlines and rivers.",
    ["murloc fin"]               = "Drops from murlocs along coastlines and rivers.",
    ["crawler meat"]             = "Drops from sea crawlers and crabs along coasts.",
    ["okra"]                     = "Found in crates on the ground at Saldean's Farm in Westfall.",
    ["turtle meat"]              = "Drops from snapjaw and river turtles in Hillsbrad rivers.",

    -- Trade Reagents & Tools
    ["coarse thread"]            = "Sold by Tailoring and General Trade vendors.",
    ["fine thread"]              = "Sold by Tailoring and General Trade vendors.",
    ["silken thread"]            = "Sold by Tailoring and General Trade vendors.",
    ["heavy silken thread"]      = "Sold by Tailoring and General Trade vendors.",
    ["rune thread"]              = "Sold by Tailoring and General Trade vendors.",
    ["bleach"]                   = "Sold by Alchemy and Trade Supplies vendors.",
    ["coal"]                     = "Sold by Blacksmithing and Mining Supplies vendors.",
    ["mining pick"]              = "Sold by Mining Supplies and General Goods vendors.",
    ["blacksmith hammer"]        = "Sold by Blacksmithing Supplies vendors.",
    ["skinning knife"]           = "Sold by Leatherworking Supplies and General Goods vendors.",
    ["simple wood"]              = "Sold by Woodcraft and Trade vendors.",
    ["star wood"]                = "Sold by Woodcraft and Trade vendors.",
    ["flint and tinder"]         = "Sold by General Goods vendors to light campfires.",
    ["empty canteen"]            = "Target the defeated elemental or ooze and USE this item from your bags.",
    ["holy water"]               = "Target the boss and USE this item from your bags to remove their invulnerability.",
}

-- Normalizes string: trims, lowercases, removes color codes and prefixes
local function CleanKey(str)
    if not str or str == "" then return "" end
    local s = tostring(str)
    s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
    s = string.gsub(s, "|r", "")
    s = string.gsub(s, "^%s*%[%d+%]%s*", "")
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")
    return string.lower(s)
end

-- Retrieves a curated tip or applies heuristic sourcing rules
function Data.GetQuestTip(questID, questTitle)
    local numID = tonumber(questID)
    local targetID = (numID and numID == numID and numID ~= 0 and numID > -math.huge and numID < math.huge) and numID or nil
    local rawTitle = (type(questTitle) == "string" and questTitle ~= "") and questTitle or nil
    local cleanTitle = CleanKey(rawTitle)

    -- If title not provided, attempt to look it up from quest log or basic info
    if (not cleanTitle or cleanTitle == "") and targetID and targetID > 0 then
        local basic = addon.Utils and addon.Utils.GetQuestBasicInfo and addon.Utils.GetQuestBasicInfo(targetID)
        if basic and basic.title then
            cleanTitle = CleanKey(basic.title)
        end
    end

    -- 1. Exact Title lookup first (prevents stale IDs from overriding a distinct known quest title)
    if cleanTitle and cleanTitle ~= "" and not string.find(cleanTitle, "^quest #") then
        if Data.QuestTipsByTitle[cleanTitle] then
            return Data.QuestTipsByTitle[cleanTitle]
        end
        local noThe = string.gsub(cleanTitle, "^the%s+", "")
        if Data.QuestTipsByTitle[noThe] then
            return Data.QuestTipsByTitle[noThe]
        end
    end

    -- 2. Exact questID lookup
    if targetID and Data.QuestTips[targetID] then
        return Data.QuestTips[targetID]
    end

    -- 3. Check Quest Log objectives if quest is in active player's log
    if targetID and targetID > 0 and GetNumQuestLogEntries and GetQuestLogTitle and GetNumQuestLeaderBoards and GetQuestLogLeaderBoard then
        local numEntries = GetNumQuestLogEntries() or 0
        for qIndex = 1, numEntries do
            local okTitle, title, _, _, isHeader, _, _, _, qID = pcall(GetQuestLogTitle, qIndex)
            if okTitle and not isHeader and (qID == targetID or (cleanTitle and cleanTitle ~= "" and CleanKey(title) == cleanTitle)) then
                local numLeaderBoards = GetNumQuestLeaderBoards(qIndex) or 0
                for objIndex = 1, numLeaderBoards do
                    local objText, objType = GetQuestLogLeaderBoard(objIndex, qIndex)
                    if objText and objText ~= "" then
                        local lowerObj = CleanKey(objText)
                        -- Check against known objective/item tips
                        for key, tip in pairs(Data.ObjectiveItemTips) do
                            if string.find(lowerObj, key, 1, true) then
                                return tip
                            end
                        end

                        -- Heuristic 3A: Vendor trade goods / reagents
                        if string.find(lowerObj, "spices") or string.find(lowerObj, "juice") or string.find(lowerObj, "thread") or
                           string.find(lowerObj, "bleach") or string.find(lowerObj, "coal") or string.find(lowerObj, "flux") or
                           string.find(lowerObj, "flint") or string.find(lowerObj, "vial") then
                            return "Common crafting reagent. Can be purchased directly from trade or profession vendors in towns."
                        end

                        -- Heuristic 3B: Clickable environmental objects
                        if string.find(lowerObj, "tome") or string.find(lowerObj, "chest") or string.find(lowerObj, "crate") or
                           string.find(lowerObj, "journal") or string.find(lowerObj, "document") or string.find(lowerObj, "fissure") or
                           string.find(lowerObj, "cauldron") or string.find(lowerObj, "altar") or string.find(lowerObj, "shrine") then
                            return "Search the quest area for a clickable container, chest, or environmental object on the ground."
                        end
                    end
                end
                break
            end
        end
    end

    -- 4. Check clean title keywords against known objective items
    if cleanTitle and cleanTitle ~= "" then
        for key, tip in pairs(Data.ObjectiveItemTips) do
            if string.find(cleanTitle, key, 1, true) then
                return tip
            end
        end
    end

    return nil
end
