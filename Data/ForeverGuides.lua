--[[
    WorthIt / QuestWorth - Data/ForeverGuides.lua
    Structured step-by-step quest prerequisites, required item sourcing,
    and verified map coordinates extracted from WoW Forever records (686 quests).
]]

local addonName, addon = ...
addon.Data = addon.Data or {}
local Data = addon.Data

Data.QuestGuides = {
    [17] = {
        name = "Uldaman Reagent Run",
        pickup = "Ghak Healtouch, Thelsamar, Loch Modan",
        turnin = "Ghak Healtouch, Thelsamar, Loch Modan",
        steps = {
            { text = "Prereq chain (1): Badlands Reagent Run", kind = "quest" },
            { text = "Get [Magenta Fungus Cap]: Need x12", kind = "item", itemID = 8047, itemName = "Magenta Fungus Cap" },
            { text = "Turn in: Ghak Healtouch, Thelsamar, Loch Modan", kind = "turnin" },
        },
        items = {
            { id = 8047, name = "Magenta Fungus Cap", role = "required", source = "Need x12" },
        },
        pins = {
            { mapID = 1432, x = 0.3700, y = 0.4920, label = "Ghak Healtouch — Loch Modan", kind = "start" },
        },
    },
    [65] = {
        pickup = "Gryan Stoutmantle, Sentinel Hill, Westfall",
        turnin = "Wiley the Black, Lakeshire, Redridge Mountains",
        summary = "First step of the required Defias Brotherhood chain.",
        steps = {
            { text = "First step of the required Defias Brotherhood chain.", kind = "guide", mapID = 1436, x = 0.5620, y = 0.4760 },
        },
        pins = {
            { mapID = 1436, x = 0.5620, y = 0.4760, label = "Gryan Stoutmantle — Sentinel Hill", kind = "location", detail = "Start The Defias Brotherhood here" },
        },
    },
    [132] = {
        pickup = "Wiley the Black, Lakeshire, Redridge Mountains",
        turnin = "Gryan Stoutmantle, Sentinel Hill, Westfall",
        summary = "Second step of the Defias Brotherhood chain.",
        steps = {
            { text = "Second step of the Defias Brotherhood chain.", kind = "guide", mapID = 1433, x = 0.2140, y = 0.4540 },
        },
        pins = {
            { mapID = 1433, x = 0.2140, y = 0.4540, label = "Wiley the Black — Redridge Mountains", kind = "start", detail = "Wiley the Black: Lakeshire inn, Redridge Mountains" },
        },
    },
    [135] = {
        pickup = "Gryan Stoutmantle, Sentinel Hill, Westfall",
        turnin = "Master Mathias Shaw, Old Town, Stormwind",
        summary = "Shaw investigates the connection between the Defias and the Stonemasons.",
        steps = {
            { text = "Shaw investigates the connection between the Defias and the Stonemasons.", kind = "guide", mapID = 1436, x = 0.5630, y = 0.4750 },
        },
        pins = {
            { mapID = 1436, x = 0.5630, y = 0.4750, label = "Gryan Stoutmantle — Westfall", kind = "start", detail = "Gryan Stoutmantle: Sentinel Hill, Westfall" },
        },
    },
    [141] = {
        pickup = "Master Mathias Shaw, Old Town, Stormwind",
        turnin = "Gryan Stoutmantle, Sentinel Hill, Westfall",
        summary = "Returns Shaw's findings about Edwin VanCleef to Gryan.",
        steps = {
            { text = "Returns Shaw's findings about Edwin VanCleef to Gryan.", kind = "guide", mapID = 1453, x = 0.7830, y = 0.7070 },
        },
        pins = {
            { mapID = 1453, x = 0.7830, y = 0.7070, label = "Master Mathias Shaw — Stormwind", kind = "start", detail = "Master Mathias Shaw: SI:7, Old Town, Stormwind" },
        },
    },
    [142] = {
        pickup = "Gryan Stoutmantle, Sentinel Hill, Westfall",
        turnin = "Gryan Stoutmantle, Sentinel Hill, Westfall",
        summary = "The messenger travels the roads between Moonbrook, Gold Coast Quarry and Jangolode Mine.",
        steps = {
            { text = "The messenger travels the roads between Moonbrook, Gold Coast Quarry and Jangolode Mine.", kind = "guide", mapID = 1436, x = 0.5630, y = 0.4750 },
        },
        pins = {
            { mapID = 1436, x = 0.5630, y = 0.4750, label = "Gryan Stoutmantle — Westfall", kind = "start", detail = "Gryan Stoutmantle: Sentinel Hill, Westfall" },
        },
    },
    [153] = {
        pickup = "Scout Galiaan, Sentinel Hill, Westfall",
        turnin = "Scout Galiaan, Sentinel Hill, Westfall",
        summary = "Required before Red Silk Bandanas.",
        steps = {
            { text = "Required before Red Silk Bandanas.", kind = "guide", mapID = 1436, x = 0.5660, y = 0.4730 },
        },
        pins = {
            { mapID = 1436, x = 0.5660, y = 0.4730, label = "Scout Galiaan — Sentinel Hill", kind = "location", detail = "Start Red Leather Bandanas here" },
        },
    },
    [155] = {
        pickup = "Defias Traitor, Sentinel Hill, Westfall",
        turnin = "Gryan Stoutmantle, Sentinel Hill, Westfall",
        summary = "Final prerequisite before the dungeon step of The Defias Brotherhood.",
        steps = {
            { text = "Final prerequisite before the dungeon step of The Defias Brotherhood.", kind = "guide", mapID = 1436, x = 0.5570, y = 0.4750 },
        },
        pins = {
            { mapID = 1436, x = 0.5570, y = 0.4750, label = "Defias Traitor — Westfall", kind = "start", detail = "Defias Traitor: Sentinel Hill, Westfall" },
        },
    },
    [166] = {
        name = "The Defias Brotherhood",
        pickup = "Gryan Stoutmantle, Sentinel Hill tower, Westfall (56.4, 47.5)",
        turnin = "Gryan Stoutmantle, Sentinel Hill, Westfall",
        summary = "Final dungeon step of the Defias Brotherhood chain; complete the earlier steps first.",
        steps = {
            { text = "Prereq chain (6): The Defias Brotherhood -> The Defias Brotherhood -> The Defias Brotherhood (+3 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1436, x = 0.5640, y = 0.4750, label = "Gryan Stoutmantle", kind = "start" },
        },
    },
    [167] = {
        name = "Oh Brother...",
        pickup = "Wilder Thistlenettle, the Dwarven District, Stormwind",
        turnin = "Wilder Thistlenettle, Stormwind",
        summary = "The foreman is in the tunnels before the instance portal.",
        steps = {
            { text = "The foreman is in the tunnels before the instance portal.", kind = "guide", mapID = 1453, x = 0.7030, y = 0.4080 },
        },
        pins = {
            { mapID = 1453, x = 0.7030, y = 0.4080, label = "Wilder Thistlenettle", kind = "start" },
        },
    },
    [168] = {
        name = "Collecting Memories",
        pickup = "Wilder Thistlenettle, the Dwarven District, Stormwind",
        turnin = "Wilder Thistlenettle, Stormwind",
        summary = "The undead side tunnel is before the instance portal.",
        steps = {
            { text = "The undead side tunnel is before the instance portal.", kind = "guide", mapID = 1453, x = 0.7030, y = 0.4080 },
        },
        pins = {
            { mapID = 1453, x = 0.7030, y = 0.4080, label = "Wilder Thistlenettle", kind = "start" },
        },
    },
    [203] = {
        pickup = "Sergeant Yohwa, Rebel Camp, Stranglethorn Vale",
        turnin = "Sergeant Yohwa, Rebel Camp, Stranglethorn Vale",
        summary = "Done together with the other of Sergeant Yohwa's two quests (The Second Rebellion and Bad Medicine); Brother Nimetz offers Kurzen's Mystery once both are handed in.",
        steps = {
            { text = "Done together with the other of Sergeant Yohwa's two quests (The Second Rebellion and Bad Medicine); Brother Nimetz offers Kurzen's Mystery once both are handed in.", kind = "guide", mapID = 1434, x = 0.3800, y = 0.0340 },
        },
        pins = {
            { mapID = 1434, x = 0.3800, y = 0.0340, label = "Sergeant Yohwa — Rebel Camp", kind = "location", detail = "Sergeant Yohwa at the Rebel Camp, northern Stranglethorn Vale" },
            { mapID = 1434, x = 0.4470, y = 0.1040, label = "Kurzen's Compound — Stranglethorn Vale", kind = "objective", detail = "Kurzen Jungle Fighters and Medicine Men, in and around Kurzen's Compound" },
        },
    },
    [204] = {
        pickup = "Sergeant Yohwa, Rebel Camp, Stranglethorn Vale",
        turnin = "Sergeant Yohwa, Rebel Camp, Stranglethorn Vale",
        summary = "Done together with the other of Sergeant Yohwa's two quests (The Second Rebellion and Bad Medicine); Brother Nimetz offers Kurzen's Mystery once both are handed in.",
        steps = {
            { text = "Get [Jungle Remedy]: Dropped by the Kurzen trolls in and around Kurzen's Compound (7 needed)", kind = "item", itemID = 2633, itemName = "Jungle Remedy" },
            { text = "Get [Venom Fern Extract]: Dropped by the Kurzen trolls in and around Kurzen's Compound", kind = "item", itemID = 2634, itemName = "Venom Fern Extract" },
            { text = "Turn in: Sergeant Yohwa, Rebel Camp, Stranglethorn Vale", kind = "turnin" },
        },
        items = {
            { id = 2633, name = "Jungle Remedy", role = "required", source = "Dropped by the Kurzen trolls in and around Kurzen's Compound (7 needed)" },
            { id = 2634, name = "Venom Fern Extract", role = "required", source = "Dropped by the Kurzen trolls in and around Kurzen's Compound" },
        },
        pins = {
            { mapID = 1434, x = 0.3800, y = 0.0340, label = "Sergeant Yohwa — Rebel Camp", kind = "location", detail = "Sergeant Yohwa at the Rebel Camp, northern Stranglethorn Vale" },
            { mapID = 1434, x = 0.4470, y = 0.1040, label = "Kurzen's Compound — Stranglethorn Vale", kind = "objective", detail = "Kurzen Jungle Fighters and Medicine Men, in and around Kurzen's Compound" },
        },
    },
    [205] = {
        pickup = "Brother Nimetz, Rebel Camp, Stranglethorn Vale",
        turnin = "Brother Nimetz, Rebel Camp, Stranglethorn Vale",
        steps = {
            { text = "Get [Skullsplitter Fetish]: Dropped by Skullsplitter Witchdoctors and Mystics in the troll ruins south of the Rebel Camp (4 needed)", kind = "item", itemID = 2466, itemName = "Skullsplitter Fetish" },
            { text = "Turn in: Brother Nimetz, Rebel Camp, Stranglethorn Vale", kind = "turnin" },
        },
        items = {
            { id = 2466, name = "Skullsplitter Fetish", role = "required", source = "Dropped by Skullsplitter Witchdoctors and Mystics in the troll ruins south of the Rebel Camp (4 needed)" },
        },
        pins = {
            { mapID = 1434, x = 0.3780, y = 0.0360, label = "Brother Nimetz — Rebel Camp", kind = "location", detail = "Brother Nimetz at the Rebel Camp, northern Stranglethorn Vale" },
            { mapID = 1434, x = 0.4590, y = 0.3640, label = "Skullsplitter trolls — Stranglethorn Vale", kind = "objective", detail = "Skullsplitter Mystics and Witch Doctors in the troll ruins south of Kurzen's Compound" },
        },
    },
    [207] = {
        pickup = "Brother Nimetz, Rebel Camp, Stranglethorn Vale",
        turnin = "Brother Nimetz, Rebel Camp, Stranglethorn Vale",
        steps = {
            { text = "Get [The First Troll Legend]: From the tablet Moon Over the Vale (around 29, 19)", kind = "item", itemID = 2005, itemName = "The First Troll Legend", mapID = 1434, x = 0.2940, y = 0.1920 },
            { text = "Get [The Second Troll Legend]: From the tablet Gri'lek the Wanderer, at the bottom of the Vile Reef (around 25, 23)", kind = "item", itemID = 2006, itemName = "The Second Troll Legend", mapID = 1434, x = 0.2480, y = 0.2280 },
            { text = "Get [The Third Troll Legend]: From the tablet Fall of Gurubashi, in the troll ruins on the coast north of the Vile Reef (around 23, 12)", kind = "item", itemID = 2007, itemName = "The Third Troll Legend", mapID = 1434, x = 0.2300, y = 0.1200 },
            { text = "Get [The Fourth Troll Legend]: From the tablet The Emperor's Tomb (around 25, 9)", kind = "item", itemID = 2008, itemName = "The Fourth Troll Legend", mapID = 1434, x = 0.2470, y = 0.0900 },
            { text = "Turn in: Brother Nimetz, Rebel Camp, Stranglethorn Vale", kind = "turnin" },
        },
        items = {
            { id = 2005, name = "The First Troll Legend", role = "required", source = "From the tablet Moon Over the Vale (around 29, 19)" },
            { id = 2006, name = "The Second Troll Legend", role = "required", source = "From the tablet Gri'lek the Wanderer, at the bottom of the Vile Reef (around 25, 23)" },
            { id = 2007, name = "The Third Troll Legend", role = "required", source = "From the tablet Fall of Gurubashi, in the troll ruins on the coast north of the Vile Reef (around 23, 12)" },
            { id = 2008, name = "The Fourth Troll Legend", role = "required", source = "From the tablet The Emperor's Tomb (around 25, 9)" },
        },
        pins = {
            { mapID = 1434, x = 0.3780, y = 0.0360, label = "Brother Nimetz — Rebel Camp", kind = "location", detail = "Brother Nimetz at the Rebel Camp, northern Stranglethorn Vale" },
            { mapID = 1434, x = 0.2940, y = 0.1920, label = "Moon Over the Vale — Stranglethorn Vale", kind = "item", detail = "The tablet Moon Over the Vale (around 29, 19)" },
            { mapID = 1434, x = 0.2480, y = 0.2280, label = "Gri'lek the Wanderer — Stranglethorn Vale", kind = "item", detail = "The tablet at the bottom of the Vile Reef (around 25, 23)" },
            { mapID = 1434, x = 0.2300, y = 0.1200, label = "Fall of Gurubashi — Stranglethorn Vale", kind = "item", detail = "The tablet in the troll ruins on the coast (around 23, 12)" },
            { mapID = 1434, x = 0.2470, y = 0.0900, label = "The Emperor's Tomb — Stranglethorn Vale", kind = "item", detail = "The tablet The Emperor's Tomb (around 25, 9)" },
        },
    },
    [214] = {
        name = "Red Silk Bandanas",
        pickup = "Scout Riell, Sentinel Hill tower, Westfall",
        turnin = "Scout Riell, Sentinel Hill tower, Westfall",
        summary = "Requires the Defias Brotherhood escort step.",
        steps = {
            { text = "Prereq chain (6): The Defias Brotherhood -> The Defias Brotherhood -> The Defias Brotherhood (+3 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1436, x = 0.5667, y = 0.4735, label = "Scout Riell", kind = "start" },
        },
    },
    [261] = {
        pickup = "Brother Anton, Desolace",
        turnin = "Brother Anton, Desolace",
        pins = {
            { mapID = 1443, x = 0.6640, y = 0.0780, label = "Brother Anton — Desolace", kind = "location" },
            { mapID = 1443, x = 0.6400, y = 0.8200, label = "Undead Ravagers — Valley of Bones, Desolace", kind = "objective", detail = "Through the arch with the red banners, south of the centaur village with the ponds" },
        },
    },
    [275] = {
        pickup = "Rethiel the Greenwarden, The Green Belt, Wetlands",
        turnin = "Rethiel the Greenwarden, The Green Belt, Wetlands",
        summary = "Final required step before Horrors in the Highland.",
        steps = {
            { text = "Final required step before Horrors in the Highland.", kind = "guide", mapID = 1437, x = 0.5620, y = 0.4060 },
        },
        pins = {
            { mapID = 1437, x = 0.5620, y = 0.4060, label = "Rethiel the Greenwarden — Wetlands", kind = "location", detail = "Continue with Blisters on The Land here" },
        },
    },
    [276] = {
        pickup = "Rethiel the Greenwarden, The Green Belt, Wetlands",
        turnin = "Rethiel the Greenwarden, The Green Belt, Wetlands",
        summary = "First required step before Horrors in the Highland.",
        steps = {
            { text = "First required step before Horrors in the Highland.", kind = "guide", mapID = 1437, x = 0.5620, y = 0.4060 },
        },
        pins = {
            { mapID = 1437, x = 0.5620, y = 0.4060, label = "Rethiel the Greenwarden — Wetlands", kind = "location", detail = "Continue with Tramping Paws here" },
        },
    },
    [277] = {
        pickup = "Rethiel the Greenwarden, The Green Belt, Wetlands",
        turnin = "Rethiel the Greenwarden, The Green Belt, Wetlands",
        summary = "Second required step before Horrors in the Highland.",
        steps = {
            { text = "Second required step before Horrors in the Highland.", kind = "guide", mapID = 1437, x = 0.5620, y = 0.4060 },
        },
        pins = {
            { mapID = 1437, x = 0.5620, y = 0.4060, label = "Rethiel the Greenwarden — Wetlands", kind = "location", detail = "Continue with Fire Taboo here" },
        },
    },
    [303] = {
        pickup = "Motley Garmason, Dun Modr, Wetlands",
        turnin = "Motley Garmason, Dun Modr, Wetlands",
        summary = "Complete The Dark Iron War to unlock The Fury Runs Deep.",
        steps = {
            { text = "Complete The Dark Iron War to unlock The Fury Runs Deep.", kind = "guide", mapID = 1437, x = 0.4960, y = 0.1820 },
        },
        pins = {
            { mapID = 1437, x = 0.4960, y = 0.1820, label = "Motley Garmason — Dun Modr", kind = "location", detail = "Start The Dark Iron War here" },
        },
    },
    [356] = {
        pickup = "Deathguard Linnea, camp south-east of Brill, Tirisfal Glades",
        turnin = "Deathguard Linnea, camp south-east of Brill, Tirisfal Glades",
        summary = "Both are at the Balnir Farmstead, east of Linnea's camp.",
        steps = {
            { text = "Both are at the Balnir Farmstead, east of Linnea's camp.", kind = "guide", mapID = 1420, x = 0.6550, y = 0.6030 },
        },
        pins = {
            { mapID = 1420, x = 0.6550, y = 0.6030, label = "Deathguard Linnea — Tirisfal Glades", kind = "location" },
        },
    },
    [373] = {
        name = "The Unsent Letter",
        pickup = "Use An Unsent Letter, looted from Edwin VanCleef in The Deadmines",
        turnin = "Baros Alexston, City Hall, Cathedral Square, Stormwind",
        summary = "First required step leading to The Stockade Riots.",
        steps = {
            { text = "Start with [An Unsent Letter] (Looted from Edwin VanCleef)", kind = "starter", itemID = 2874, itemName = "An Unsent Letter" },
        },
        items = {
            { id = 2874, name = "An Unsent Letter", role = "starter", source = "Looted from Edwin VanCleef" },
        },
    },
    [377] = {
        name = "Crime and Punishment",
        pickup = "Councilman Millstipe, Darkshire, Duskwood",
        turnin = "Councilman Millstipe, Darkshire, Duskwood",
        pins = {
            { mapID = 1431, x = 0.7200, y = 0.4780, label = "Councilman Millstipe — Darkshire", kind = "start" },
        },
    },
    [378] = {
        name = "The Fury Runs Deep",
        pickup = "Motley Garmason, Dun Modr, Wetlands",
        turnin = "Motley Garmason, Dun Modr, Wetlands",
        summary = "Requires The Dark Iron War before this quest becomes available.",
        steps = {
            { text = "Prereq chain (1): The Dark Iron War", kind = "quest" },
        },
        pins = {
            { mapID = 1437, x = 0.4960, y = 0.1820, label = "Motley Garmason — Dun Modr", kind = "start" },
        },
    },
    [386] = {
        name = "What Comes Around...",
        pickup = "Guard Berton, Lakeshire, Redridge Mountains",
        turnin = "Guard Berton, Lakeshire, Redridge Mountains",
        pins = {
            { mapID = 1433, x = 0.2120, y = 0.4660, label = "Guard Berton — Lakeshire", kind = "start" },
        },
    },
    [387] = {
        name = "Quell the Uprising",
        pickup = "Warden Thelwater, outside The Stockade, Stormwind",
        turnin = "Warden Thelwater, outside The Stockade, Stormwind",
        pins = {
            { mapID = 1453, x = 0.5180, y = 0.6930, label = "Warden Thelwater — The Stockade", kind = "start" },
        },
    },
    [388] = {
        name = "The Color of Blood",
        pickup = "Nikova Raskol, Old Town, Stormwind",
        turnin = "Nikova Raskol, Old Town, Stormwind",
        pins = {
            { mapID = 1453, x = 0.7640, y = 0.6370, label = "Nikova Raskol — Old Town", kind = "start" },
        },
    },
    [389] = {
        pickup = "Baros Alexston, City Hall, Cathedral Square, Stormwind",
        turnin = "Warden Thelwater, outside The Stockade, Stormwind",
        summary = "Second required step leading to The Stockade Riots.",
        steps = {
            { text = "Second required step leading to The Stockade Riots.", kind = "guide", mapID = 1453, x = 0.5770, y = 0.4790 },
        },
        pins = {
            { mapID = 1453, x = 0.5770, y = 0.4790, label = "Baros Alexston — Stormwind", kind = "location", detail = "Continue the chain with Bazil Thredd here" },
        },
    },
    [391] = {
        name = "The Stockade Riots",
        pickup = "Warden Thelwater, outside The Stockade, Stormwind",
        turnin = "Warden Thelwater, outside The Stockade, Stormwind",
        summary = "Part of the chain that begins with The Unsent Letter from Edwin VanCleef in The Deadmines.",
        steps = {
            { text = "Prereq chain (2): The Unsent Letter -> Bazil Thredd", kind = "quest" },
        },
        pins = {
            { mapID = 1453, x = 0.5180, y = 0.6930, label = "Warden Thelwater — The Stockade", kind = "start" },
        },
    },
    [447] = {
        pickup = "Apothecary Renferrel, The Sepulcher, Silverpine Forest",
        turnin = "Master Apothecary Faranell, Undercity",
        steps = {
            { text = "Get [Grizzled Bear Heart]: Dropped by Ferocious Grizzled Bears and Giant Grizzled Bears all over Silverpine Forest", kind = "item", itemID = 3253, itemName = "Grizzled Bear Heart" },
            { text = "Get [Skittering Blood]: Dropped by Moss Stalkers and Mist Creepers in the Skittering Dark, north-west of the Sepulcher (around 35, 12)", kind = "item", itemID = 3254, itemName = "Skittering Blood", mapID = 1421, x = 0.3550, y = 0.1200 },
            { text = "Turn in: Master Apothecary Faranell, Undercity", kind = "turnin", mapID = 1458, x = 0.4880, y = 0.6930 },
        },
        items = {
            { id = 3253, name = "Grizzled Bear Heart", role = "required", source = "Dropped by Ferocious Grizzled Bears and Giant Grizzled Bears all over Silverpine Forest" },
            { id = 3254, name = "Skittering Blood", role = "required", source = "Dropped by Moss Stalkers and Mist Creepers in the Skittering Dark, north-west of the Sepulcher (around 35, 12)" },
        },
        pins = {
            { mapID = 1421, x = 0.4280, y = 0.4090, label = "Apothecary Renferrel — The Sepulcher", kind = "location" },
            { mapID = 1458, x = 0.4880, y = 0.6930, label = "Master Apothecary Faranell — Undercity", kind = "turnin" },
            { mapID = 1421, x = 0.3550, y = 0.1200, label = "Moss Stalkers and Mist Creepers", kind = "item", detail = "Dropped by Moss Stalkers and Mist Creepers in the Skittering Dark, north-west of the Sepulcher (around 35, 12)" },
        },
    },
    [450] = {
        pickup = "Master Apothecary Faranell, Undercity",
        turnin = "Apothecary Renferrel, The Sepulcher, Silverpine Forest",
        warning = "Group quest: the inn is in Pyrewood Village, among hostile villagers.",
        steps = {
            { text = "Get [Berard's Journal]: Found on Berard's Bookshelf in the Pyrewood Village inn (Silverpine Forest 43, 73)", kind = "item", itemID = 3255, itemName = "Berard's Journal", mapID = 1421, x = 0.4300, y = 0.7320 },
            { text = "Turn in: Apothecary Renferrel, The Sepulcher, Silverpine Forest", kind = "turnin", mapID = 1421, x = 0.4280, y = 0.4090 },
        },
        items = {
            { id = 3255, name = "Berard's Journal", role = "required", source = "Found on Berard's Bookshelf in the Pyrewood Village inn (Silverpine Forest 43, 73)" },
        },
        pins = {
            { mapID = 1458, x = 0.4880, y = 0.6930, label = "Master Apothecary Faranell — Undercity", kind = "location" },
            { mapID = 1421, x = 0.4280, y = 0.4090, label = "Apothecary Renferrel — The Sepulcher", kind = "turnin" },
            { mapID = 1421, x = 0.4300, y = 0.7320, label = "Berard's Bookshelf — Pyrewood Village", kind = "item", detail = "Found on Berard's Bookshelf in the Pyrewood Village inn (Silverpine Forest 43, 73)" },
        },
    },
    [451] = {
        pickup = "Apothecary Renferrel, The Sepulcher, Silverpine Forest",
        turnin = "Master Apothecary Faranell, Undercity",
        steps = {
            { text = "Get [Lake Skulker Moss]: Dropped by Lake Skulkers and Elder Lake Skulkers on the Dawning Isles in Lordamere Lake (around 72, 35)", kind = "item", itemID = 3256, itemName = "Lake Skulker Moss", mapID = 1421, x = 0.7200, y = 0.3550 },
            { text = "Get [Lake Creeper Moss]: Dropped by Lake Creepers and Elder Lake Creepers on the Dawning Isles in Lordamere Lake (around 77, 25)", kind = "item", itemID = 3257, itemName = "Lake Creeper Moss", mapID = 1421, x = 0.7700, y = 0.2500 },
            { text = "Get [Hardened Tumor]: Rare drop from Vile Fin murlocs around Lordamere Lake; the higher-level ones on the Dawning Isles and on the south-west shore behind Ambermill are the best bet", kind = "item", itemID = 3258, itemName = "Hardened Tumor", mapID = 1421, x = 0.7850, y = 0.3150 },
            { text = "Turn in: Master Apothecary Faranell, Undercity", kind = "turnin", mapID = 1458, x = 0.4880, y = 0.6930 },
        },
        items = {
            { id = 3256, name = "Lake Skulker Moss", role = "required", source = "Dropped by Lake Skulkers and Elder Lake Skulkers on the Dawning Isles in Lordamere Lake (around 72, 35)" },
            { id = 3257, name = "Lake Creeper Moss", role = "required", source = "Dropped by Lake Creepers and Elder Lake Creepers on the Dawning Isles in Lordamere Lake (around 77, 25)" },
            { id = 3258, name = "Hardened Tumor", role = "required", source = "Rare drop from Vile Fin murlocs around Lordamere Lake; the higher-level ones on the Dawning Isles and on the south-west shore behind Ambermill are the best bet" },
        },
        pins = {
            { mapID = 1421, x = 0.4280, y = 0.4090, label = "Apothecary Renferrel — The Sepulcher", kind = "location" },
            { mapID = 1458, x = 0.4880, y = 0.6930, label = "Master Apothecary Faranell — Undercity", kind = "turnin" },
            { mapID = 1421, x = 0.7200, y = 0.3550, label = "Lake Skulkers — Lordamere Lake", kind = "item", detail = "Dropped by Lake Skulkers and Elder Lake Skulkers on the Dawning Isles in Lordamere Lake (around 72, 35)" },
            { mapID = 1421, x = 0.7700, y = 0.2500, label = "Lake Creepers — Lordamere Lake", kind = "item", detail = "Dropped by Lake Creepers and Elder Lake Creepers on the Dawning Isles in Lordamere Lake (around 77, 25)" },
            { mapID = 1421, x = 0.7850, y = 0.3150, label = "Vile Fin murlocs — Lordamere Lake", kind = "item", detail = "Rare drop from Vile Fin murlocs around Lordamere Lake; the higher-level ones on the Dawning Isles and on the south-west shore behind Ambermill are the best bet" },
        },
    },
    [463] = {
        pickup = "First Mate Fitzsimmons, Menethil Harbor, Wetlands",
        turnin = "Rethiel the Greenwarden, The Green Belt, Wetlands",
        summary = "Optional breadcrumb to Rethiel; not required for Horrors in the Highland.",
        steps = {
            { text = "Optional breadcrumb to Rethiel; not required for Horrors in the Highland.", kind = "guide", mapID = 1437, x = 0.1080, y = 0.5960 },
        },
        pins = {
            { mapID = 1437, x = 0.1080, y = 0.5960, label = "First Mate Fitzsimmons — Menethil Harbor", kind = "location", detail = "Start The Greenwarden here" },
        },
    },
    [484] = {
        pickup = "James Halloran, Menethil Harbor, Wetlands",
        turnin = "James Halloran, Menethil Harbor, Wetlands",
        summary = "Required before Highland Hides. Daily Delivery is not required in Forever.",
        steps = {
            { text = "Required before Highland Hides. Daily Delivery is not required in Forever.", kind = "guide", mapID = 1437, x = 0.0800, y = 0.5500 },
        },
        pins = {
            { mapID = 1437, x = 0.0800, y = 0.5500, label = "James Halloran — Menethil Harbor", kind = "location", detail = "Start Young Crocolisk Skins here" },
        },
    },
    [544] = {
        pickup = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
        turnin = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
        summary = "Pick up Key to the City from Magus Wordeen Voidglare at the same time.",
        steps = {
            { text = "Pick up Key to the City from Magus Wordeen Voidglare at the same time.", kind = "guide", mapID = 1424, x = 0.6150, y = 0.2070 },
        },
        pins = {
            { mapID = 1424, x = 0.6150, y = 0.2070, label = "Magus Wordeen Voidglare — Tarren Mill", kind = "location", detail = "Inside the building in Tarren Mill" },
        },
    },
    [545] = {
        pickup = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
        turnin = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
        summary = "Available after completing Prison Break In.",
        steps = {
            { text = "Available after completing Prison Break In.", kind = "guide", mapID = 1424, x = 0.6150, y = 0.2070 },
        },
        pins = {
            { mapID = 1424, x = 0.6150, y = 0.2070, label = "Magus Wordeen Voidglare — Tarren Mill", kind = "location", detail = "Inside the building in Tarren Mill" },
        },
    },
    [629] = {
        pickup = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        turnin = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        warning = "Group quest: the Saltscale murlocs at the Vile Reef are elite.",
        steps = {
            { text = "Get [Tablet Shard]: From the tablet Gri'lek the Wanderer, at the bottom of the Vile Reef (around 25, 23)", kind = "item", itemID = 4094, itemName = "Tablet Shard", mapID = 1434, x = 0.2480, y = 0.2300 },
            { text = "Turn in: Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale", kind = "turnin" },
        },
        items = {
            { id = 4094, name = "Tablet Shard", role = "required", source = "From the tablet Gri'lek the Wanderer, at the bottom of the Vile Reef (around 25, 23)" },
        },
        pins = {
            { mapID = 1434, x = 0.3230, y = 0.2770, label = "Kin'weelay — Grom'gol Base Camp", kind = "location", detail = "Kin'weelay at Grom'gol Base Camp, Stranglethorn Vale" },
            { mapID = 1434, x = 0.2480, y = 0.2300, label = "Gri'lek the Wanderer — the Vile Reef", kind = "item", detail = "The tablet at the bottom of the Vile Reef (around 25, 23)" },
        },
    },
    [704] = {
        name = "Agmond's Fate",
        pickup = "Prospector Ironband, Loch Modan",
        turnin = "Prospector Ironband, Loch Modan",
        summary = "The urns are in the outer Uldaman cave, before the instance portal.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Find Agmond -> Murdaloc", kind = "quest" },
            { text = "Get [Carved Stone Urn]: Need x4", kind = "item", itemID = 4610, itemName = "Carved Stone Urn" },
            { text = "Turn in: Prospector Ironband, Loch Modan", kind = "turnin" },
        },
        items = {
            { id = 4610, name = "Carved Stone Urn", role = "required", source = "Need x4" },
        },
        pins = {
            { mapID = 1432, x = 0.6580, y = 0.6540, label = "Prospector Ironband — Loch Modan", kind = "start" },
        },
    },
    [707] = {
        name = "Ironband Wants You!",
        pickup = "Prospector Stormpike, Hall of Explorers, Ironforge",
        turnin = "Prospector Ironband, Ironband's Excavation Site, Loch Modan",
        summary = "Introductory step leading to Agmond's Fate.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Agmond's Fate.", kind = "guide", mapID = 1455, x = 0.7460, y = 0.1170 },
        },
        pins = {
            { mapID = 1455, x = 0.7460, y = 0.1170, label = "Prospector Stormpike — Ironforge", kind = "start" },
        },
    },
    [709] = {
        name = "Solution to Doom",
        pickup = "Theldurin the Lost, Badlands",
        turnin = "Theldurin the Lost, Badlands",
        steps = {
            { text = "Get [Tablet of Ryun'eh]", kind = "item", itemID = 4631, itemName = "Tablet of Ryun'eh" },
            { text = "Turn in: Theldurin the Lost, Badlands", kind = "turnin" },
        },
        items = {
            { id = 4631, name = "Tablet of Ryun'eh", role = "required" },
        },
        pins = {
            { mapID = 1418, x = 0.5140, y = 0.7640, label = "Theldurin the Lost — Badlands", kind = "start" },
        },
    },
    [720] = {
        pickup = "Crumpled Map",
        turnin = "Prospector Ryedol, Badlands",
        steps = {
            { text = "Interact with: table: 00FAF4C8", kind = "object", mapID = 1418, x = 0.5300, y = 0.3410 },
        },
        pins = {
            { mapID = 1418, x = 0.5300, y = 0.3410, label = "Crumpled Map — Badlands", kind = "location" },
        },
    },
    [721] = {
        name = "A Sign of Hope",
        pickup = "Prospector Ryedol, Badlands",
        turnin = "Hammertoe Grez, Uldaman excavation (outside the instance)",
        pins = {
            { mapID = 1418, x = 0.5340, y = 0.4320, label = "Prospector Ryedol — Badlands", kind = "start" },
        },
    },
    [722] = {
        name = "Amulet of Secrets",
        pickup = "Hammertoe Grez, Uldaman excavation (outside the instance)",
        turnin = "Hammertoe Grez, Uldaman excavation (outside the instance)",
        steps = {
            { text = "Prereq chain (2): A Sign of Hope -> A Sign of Hope", kind = "quest" },
            { text = "Get [Hammertoe's Amulet]: Dropped by Magregan Deepshadow in the Uldaman excavation", kind = "item", itemID = 4635, itemName = "Hammertoe's Amulet" },
            { text = "Turn in: Hammertoe Grez, Uldaman excavation (outside the instance)", kind = "turnin" },
        },
        items = {
            { id = 4635, name = "Hammertoe's Amulet", role = "required", source = "Dropped by Magregan Deepshadow in the Uldaman excavation" },
        },
        pins = {
            { mapID = 1418, x = 0.4430, y = 0.1200, label = "Hammertoe Grez — Uldaman excavation (outside the instance)", kind = "start", detail = "Hammertoe is in the outer excavation caves, before the instance portal" },
        },
    },
    [724] = {
        pickup = "Prospector Ryedol, Badlands",
        turnin = "Historian Karnik, Ironforge",
        pins = {
            { mapID = 1418, x = 0.5340, y = 0.4320, label = "Prospector Ryedol — Badlands", kind = "location" },
        },
    },
    [725] = {
        pickup = "Historian Karnik, Ironforge",
        turnin = "Advisor Belgrum, Ironforge",
        pins = {
            { mapID = 1455, x = 0.7640, y = 0.1220, label = "Historian Karnik — Ironforge", kind = "location" },
        },
    },
    [726] = {
        pickup = "Advisor Belgrum, Ironforge",
        turnin = "Historian Karnik, Ironforge",
        pins = {
            { mapID = 1455, x = 0.7640, y = 0.1080, label = "Advisor Belgrum — Ironforge", kind = "location" },
        },
    },
    [738] = {
        pickup = "Prospector Ironband, Loch Modan",
        turnin = "Battered Dwarven Skeleton",
        pins = {
            { mapID = 1432, x = 0.6580, y = 0.6540, label = "Prospector Ironband — Loch Modan", kind = "location" },
        },
    },
    [739] = {
        pickup = "Battered Dwarven Skeleton",
        turnin = "Prospector Ironband, Loch Modan",
        steps = {
            { text = "Interact with: table: 00FAF1F8", kind = "object", mapID = 1418, x = 0.5090, y = 0.6240 },
        },
        pins = {
            { mapID = 1418, x = 0.5090, y = 0.6240, label = "Battered Dwarven Skeleton — Badlands", kind = "start", detail = "Battered Dwarven Skeleton: Agmond's End, Badlands" },
        },
    },
    [762] = {
        pickup = "Historian Karnik, Ironforge",
        turnin = "Advisor Belgrum, Ironforge",
        pins = {
            { mapID = 1455, x = 0.7640, y = 0.1220, label = "Historian Karnik — Ironforge", kind = "location" },
        },
    },
    [865] = {
        pickup = "Mebok Mizzyrix, Ratchet, The Barrens",
        turnin = "Mebok Mizzyrix, Ratchet, The Barrens",
        summary = "Required before Smart Drinks becomes available.",
        steps = {
            { text = "Required before Smart Drinks becomes available.", kind = "guide", mapID = 1413, x = 0.6280, y = 0.3670 },
        },
        pins = {
            { mapID = 1413, x = 0.6280, y = 0.3670, label = "Mebok Mizzyrix — Ratchet", kind = "location", detail = "Start Raptor Horns here" },
        },
    },
    [870] = {
        pickup = "Tonga Runetotem, The Crossroads",
        turnin = "Tonga Runetotem, The Crossroads",
        summary = "Investigate the fissure beneath the Forgotten Pools.",
        steps = {
            { text = "Investigate the fissure beneath the Forgotten Pools.", kind = "guide", mapID = 1413, x = 0.5200, y = 0.3200 },
        },
        pins = {
            { mapID = 1413, x = 0.5200, y = 0.3200, label = "Tonga Runetotem — The Crossroads", kind = "location", detail = "Start The Forgotten Pools here" },
        },
    },
    [877] = {
        pickup = "Tonga Runetotem, The Crossroads",
        turnin = "Tonga Runetotem, The Crossroads",
        summary = "The next required oasis investigation after The Forgotten Pools.",
        steps = {
            { text = "The next required oasis investigation after The Forgotten Pools.", kind = "guide", mapID = 1413, x = 0.5230, y = 0.3190 },
        },
        pins = {
            { mapID = 1413, x = 0.5230, y = 0.3190, label = "Tonga Runetotem — The Barrens", kind = "start", detail = "Tonga Runetotem: The Crossroads, The Barrens" },
        },
    },
    [880] = {
        pickup = "Tonga Runetotem, The Crossroads",
        turnin = "Tonga Runetotem, The Crossroads",
        summary = "Completing Altered Beings unlocks Hamuul Runetotem.",
        steps = {
            { text = "Completing Altered Beings unlocks Hamuul Runetotem.", kind = "guide", mapID = 1413, x = 0.5230, y = 0.3190 },
        },
        pins = {
            { mapID = 1413, x = 0.5230, y = 0.3190, label = "Tonga Runetotem — The Barrens", kind = "start", detail = "Tonga Runetotem: The Crossroads, The Barrens" },
        },
    },
    [914] = {
        name = "Leaders of the Fang",
        pickup = "Nara Wildmane, Thunder Bluff",
        turnin = "Nara Wildmane, Thunder Bluff",
        summary = "Requires the Barrens oasis quest chain. Complete The Barrens Oases, The Forgotten Pools, The Stagnant Oasis and Altered Beings, then Hamuul Runetotem and Nara Wildmane before Leaders of the Fang becomes available.",
        steps = {
            { text = "Prereq chain (5): The Forgotten Pools -> The Stagnant Oasis -> Altered Beings (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1456, x = 0.7530, y = 0.3130, label = "Nara Wildmane", kind = "start" },
        },
    },
    [959] = {
        name = "Trouble at the Docks",
        pickup = "Crane Operator Bigglefuzz, Ratchet, The Barrens",
        turnin = "Crane Operator Bigglefuzz, Ratchet, The Barrens",
        pins = {
            { mapID = 1413, x = 0.6390, y = 0.3830, label = "Crane Operator Bigglefuzz", kind = "start" },
        },
    },
    [962] = {
        name = "Serpentbloom",
        pickup = "Apothecary Zamah, Thunder Bluff",
        turnin = "Apothecary Zamah, Thunder Bluff",
        pins = {
            { mapID = 1456, x = 0.2300, y = 0.2100, label = "Apothecary Zamah — Pools of Vision, Thunder Bluff", kind = "start", detail = "Serpentbloom starts from Apothecary Zamah in the Pools of Vision beneath Spirit Rise" },
        },
    },
    [971] = {
        name = "Knowledge in the Deeps",
        pickup = "Gerrig Bonegrip, Forlorn Cavern, Ironforge (50.8, 5.6)",
        turnin = "Gerrig Bonegrip, Forlorn Cavern, Ironforge",
        summary = "The Lorgalis Manuscript is inside a Pitted Iron Chest underwater in the Pool of Ask'ar, in the northern alcove just past Ghamoo-ra's turtle room.",
        steps = {
            { text = "The Lorgalis Manuscript is inside a Pitted Iron Chest underwater in the Pool of Ask'ar, in the northern alcove just past Ghamoo-ra's turtle room.", kind = "guide", mapID = 1455, x = 0.5083, y = 0.0561 },
        },
        items = {
            { id = 5359, name = "Lorgalis Manuscript", role = "objective", source = "Found in a Pitted Iron Chest underwater in the Pool of Ask'ar, in the northern alcove just past Ghamoo-ra's turtle room." },
        },
        pins = {
            { mapID = 1455, x = 0.5083, y = 0.0561, label = "Gerrig Bonegrip", kind = "start" },
        },
    },
    [1013] = {
        name = "The Book of Ur",
        pickup = "Keeper Bel'dugur, Apothecarium, Undercity",
        turnin = "Keeper Bel'dugur, Apothecarium, Undercity",
        pins = {
            { mapID = 1458, x = 0.5370, y = 0.5450, label = "Keeper Bel'dugur", kind = "start" },
        },
    },
    [1014] = {
        name = "Arugal Must Die",
        pickup = "Dalar Dawnweaver, The Sepulcher, Silverpine Forest",
        turnin = "Dalar Dawnweaver, The Sepulcher, Silverpine Forest",
        summary = "The current Forever quest data also lists Arcane Intellect as a learned reward.",
        steps = {
            { text = "The current Forever quest data also lists Arcane Intellect as a learned reward.", kind = "guide", mapID = 1421, x = 0.4420, y = 0.3980 },
        },
        pins = {
            { mapID = 1421, x = 0.4420, y = 0.3980, label = "Dalar Dawnweaver", kind = "start" },
        },
    },
    [1048] = {
        name = "Into The Scarlet Monastery",
        pickup = "Varimathras, Undercity",
        turnin = "Varimathras, Undercity",
        summary = "Herod is in the Armory; Loksey in the Library; Mograine and Whitemane in the Cathedral.",
        steps = {
            { text = "Herod is in the Armory; Loksey in the Library; Mograine and Whitemane in the Cathedral.", kind = "guide", mapID = 1458, x = 0.5620, y = 0.9260 },
        },
        pins = {
            { mapID = 1458, x = 0.5620, y = 0.9260, label = "Varimathras — Royal Quarter, Undercity", kind = "start" },
            { mapID = 1458, x = 0.5620, y = 0.9240, label = "Varimathras — Undercity", kind = "start" },
        },
    },
    [1049] = {
        name = "Compendium of the Fallen",
        pickup = "Sage Truthseeker, Thunder Bluff",
        turnin = "Sage Truthseeker, Thunder Bluff",
        warning = "Undead cannot take this quest",
        pins = {
            { mapID = 1456, x = 0.3460, y = 0.4760, label = "Sage Truthseeker — Thunder Bluff", kind = "start" },
            { mapID = 1456, x = 0.3440, y = 0.4720, label = "Sage Truthseeker — Thunder Bluff", kind = "start" },
        },
    },
    [1050] = {
        name = "Mythology of the Titans",
        pickup = "Librarian Mae Paledust, Ironforge",
        turnin = "Librarian Mae Paledust, Ironforge",
        pins = {
            { mapID = 1455, x = 0.7440, y = 0.1280, label = "Librarian Mae Paledust — Hall of Explorers", kind = "start" },
            { mapID = 1455, x = 0.7400, y = 0.1340, label = "Librarian Mae Paledust — Ironforge", kind = "start" },
        },
    },
    [1051] = {
        name = "Vorrel's Revenge",
        pickup = "Vorrel Sengutz, inside the Graveyard",
        turnin = "Monika Sengutz, Tarren Mill, Hillsbrad Foothills",
        warning = "This quest is completed outside the dungeon, in the lake below Undercity.",
    },
    [1052] = {
        pickup = "Brother Anton, Desolace",
        turnin = "Raleigh the Devout",
        pins = {
            { mapID = 1443, x = 0.6640, y = 0.0780, label = "Brother Anton — Desolace", kind = "location" },
        },
    },
    [1053] = {
        name = "In the Name of the Light",
        pickup = "Raleigh the Devout, Southshore",
        turnin = "Raleigh the Devout, Southshore",
        summary = "Herod is in the Armory; Loksey in the Library; Mograine and Whitemane in the Cathedral.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Down the Scarlet Path -> Down the Scarlet Path", kind = "quest" },
        },
        pins = {
            { mapID = 1424, x = 0.5140, y = 0.5840, label = "Raleigh the Devout — Hillsbrad Foothills", kind = "start" },
        },
    },
    [1098] = {
        name = "Deathstalkers in Shadowfang",
        pickup = "High Executor Hadrec, The Sepulcher, Silverpine Forest",
        turnin = "Deathstalker Vincent, inside Shadowfang Keep",
        pins = {
            { mapID = 1421, x = 0.4340, y = 0.4090, label = "High Executor Hadrec", kind = "start" },
        },
    },
    [1100] = {
        pickup = "Henrig Lonebrow's Journal beside his corpse at the bottom of the Great Lift",
        turnin = "Falfindel Waywarder, Thalanaar, Feralas",
        summary = "Required before The Crone of the Kraul.",
        steps = {
            { text = "Required before The Crone of the Kraul.", kind = "guide", mapID = 1441, x = 0.3070, y = 0.2440 },
        },
        pins = {
            { mapID = 1441, x = 0.3070, y = 0.2440, label = "Henrig Lonebrow — bottom of the Great Lift", kind = "location", detail = "Loot Lonebrow's Journal here" },
        },
    },
    [1101] = {
        name = "The Crone of the Kraul",
        pickup = "Falfindel Waywarder, Thalanaar, Feralas",
        turnin = "Falfindel Waywarder, Thalanaar, Feralas",
        steps = {
            { text = "Prereq chain (1): Lonebrow's Journal", kind = "quest" },
        },
        pins = {
            { mapID = 1444, x = 0.8960, y = 0.4660, label = "Falfindel Waywarder — Thalanaar", kind = "start" },
        },
    },
    [1102] = {
        name = "A Vengeful Fate",
        pickup = "Auld Stonespire, Thunder Bluff",
        turnin = "Auld Stonespire, Thunder Bluff",
        pins = {
            { mapID = 1456, x = 0.3600, y = 0.5900, label = "Auld Stonespire — Thunder Bluff", kind = "start" },
        },
    },
    [1109] = {
        name = "Going, Going, Guano!",
        pickup = "Master Apothecary Faranell, Apothecarium, Undercity",
        turnin = "Master Apothecary Faranell, Apothecarium, Undercity",
        summary = "Required before Hearts of Zeal.",
        steps = {
            { text = "Required before Hearts of Zeal.", kind = "guide", mapID = 1458, x = 0.4800, y = 0.6900 },
        },
        pins = {
            { mapID = 1458, x = 0.4800, y = 0.6900, label = "Master Apothecary Faranell — Apothecarium", kind = "location", detail = "Start Going, Going, Guano! here" },
        },
    },
    [1113] = {
        name = "Hearts of Zeal",
        pickup = "Master Apothecary Faranell, Undercity",
        turnin = "Master Apothecary Faranell, Undercity",
        summary = "Monastery-wide collection: any Scarlet humanoid on the way to the Armory can drop Hearts of Zeal.",
        steps = {
            { text = "Prereq chain (1): Going, Going, Guano!", kind = "quest" },
        },
        pins = {
            { mapID = 1458, x = 0.4800, y = 0.6900, label = "Master Apothecary Faranell — Apothecarium", kind = "start" },
        },
    },
    [1139] = {
        name = "The Lost Tablets of Will",
        pickup = "Advisor Belgrum, Ironforge",
        turnin = "Advisor Belgrum, Ironforge",
        steps = {
            { text = "Prereq chain (8): A Sign of Hope -> A Sign of Hope -> Amulet of Secrets (+5 more)", kind = "quest" },
            { text = "Get [Tablet of Will]", kind = "item", itemID = 5824, itemName = "Tablet of Will" },
            { text = "Turn in: Advisor Belgrum, Ironforge", kind = "turnin" },
        },
        items = {
            { id = 5824, name = "Tablet of Will", role = "required" },
        },
        pins = {
            { mapID = 1455, x = 0.7640, y = 0.1080, label = "Advisor Belgrum — Ironforge", kind = "start" },
        },
    },
    [1149] = {
        pickup = "Dorn Plainstalker, Thousand Needles",
        turnin = "Dorn Plainstalker, Thousand Needles",
        pins = {
            { mapID = 1441, x = 0.5380, y = 0.4140, label = "Dorn Plainstalker — Thousand Needles", kind = "location", detail = "Dorn Plainstalker in Thousand Needles" },
        },
    },
    [1150] = {
        pickup = "Dorn Plainstalker, Thousand Needles",
        turnin = "Dorn Plainstalker, Thousand Needles",
        pins = {
            { mapID = 1441, x = 0.5380, y = 0.4140, label = "Dorn Plainstalker — Thousand Needles", kind = "location", detail = "Dorn Plainstalker in Thousand Needles" },
        },
    },
    [1151] = {
        pickup = "Dorn Plainstalker, Thousand Needles",
        turnin = "Dorn Plainstalker, Thousand Needles",
        pins = {
            { mapID = 1441, x = 0.5380, y = 0.4140, label = "Dorn Plainstalker — Thousand Needles", kind = "location", detail = "Dorn Plainstalker in Thousand Needles" },
        },
    },
    [1152] = {
        pickup = "Dorn Plainstalker, Thousand Needles",
        turnin = "Braug Dimspirit, Talondeep Path, Stonetalon Mountains",
        pins = {
            { mapID = 1441, x = 0.5380, y = 0.4140, label = "Dorn Plainstalker — Thousand Needles", kind = "location", detail = "Dorn Plainstalker in Thousand Needles" },
            { mapID = 1442, x = 0.7860, y = 0.4540, label = "Braug Dimspirit — Stonetalon Mountains", kind = "turnin", detail = "Near the entrance to Talondeep Path" },
        },
    },
    [1154] = {
        pickup = "Braug Dimspirit, Talondeep Path, Stonetalon Mountains",
        turnin = "Braug Dimspirit, Talondeep Path, Stonetalon Mountains",
        pins = {
            { mapID = 1442, x = 0.7860, y = 0.4540, label = "Braug Dimspirit — Stonetalon Mountains", kind = "location", detail = "Near the entrance to Talondeep Path" },
        },
    },
    [1159] = {
        pickup = "Braug Dimspirit, Talondeep Path, Stonetalon Mountains",
        turnin = "Parqual Fintallas, Undercity",
        pins = {
            { mapID = 1442, x = 0.7860, y = 0.4540, label = "Braug Dimspirit — Stonetalon Mountains", kind = "location", detail = "Near the entrance to Talondeep Path" },
        },
    },
    [1160] = {
        pickup = "Parqual Fintallas, Undercity",
        turnin = "Parqual Fintallas, Undercity",
        summary = "The book is inside Scarlet Monastery: Library.",
        steps = {
            { text = "The book is inside Scarlet Monastery: Library.", kind = "guide", mapID = 1458, x = 0.5760, y = 0.6520 },
        },
        pins = {
            { mapID = 1458, x = 0.5760, y = 0.6520, label = "Parqual Fintallas — Undercity", kind = "location", detail = "Parqual Fintallas in Undercity" },
        },
    },
    [1198] = {
        name = "In Search of Thaelrid",
        pickup = "Dawnwatcher Shaedlass, Darnassus",
        turnin = "Argent Guard Thaelrid, inside Blackfathom Deeps",
        summary = "Optional lead-in to the Alliance version of Blackfathom Villainy: hand it in before accepting Blackfathom Villainy, or it can no longer be completed.",
        warning = "Warning: if not completed before accepting Blackfathom Villainy, this quest becomes unavailable.",
        steps = {
            { text = "Optional lead-in to the Alliance version of Blackfathom Villainy: hand it in before accepting Blackfathom Villainy, or it can no longer be completed.", kind = "guide", mapID = 1457, x = 0.5500, y = 0.2400 },
        },
        pins = {
            { mapID = 1457, x = 0.5500, y = 0.2400, label = "Dawnwatcher Shaedlass — Darnassus", kind = "location", detail = "Start In Search of Thaelrid here" },
        },
    },
    [1199] = {
        name = "Twilight Falls",
        pickup = "Argent Guard Manados, Craftsmen's Terrace, Darnassus (55, 24)",
        turnin = "Argent Guard Manados, Craftsmen's Terrace, Darnassus",
        pins = {
            { mapID = 1457, x = 0.5500, y = 0.2400, label = "Argent Guard Manados", kind = "start" },
        },
    },
    [1200] = {
        name = "Blackfathom Villainy",
        pickup = "Argent Guard Thaelrid, inside Blackfathom Deeps",
        turnin = "Dawnwatcher Selgorm, Darnassus",
        warning = "Warning: Accept after completing In Search of Thaelrid, or you will lose that quest.",
    },
    [1221] = {
        name = "Blueleaf Tubers",
        pickup = "Mebok Mizzyrix, Ratchet, The Barrens",
        turnin = "Mebok Mizzyrix, Ratchet, The Barrens",
        warning = "Before you go in, pick up the Crate with Holes, the Snufflenose Command Stick and the Snufflenose Owner's Manual. They are right next to the quest giver, Mebok Mizzyrix, in Ratchet.",
        pins = {
            { mapID = 1413, x = 0.6240, y = 0.3760, label = "Mebok Mizzyrix — Ratchet", kind = "start" },
        },
    },
    [1275] = {
        name = "Researching the Corruption",
        pickup = "Gershala Nightwhisper, Auberdine, Darkshore (38.3, 43.1)",
        turnin = "Gershala Nightwhisper, Auberdine, Darkshore",
        summary = "Optional introductory quest:",
        steps = {
            { text = "Optional introductory quest:", kind = "guide", mapID = 1439, x = 0.3830, y = 0.4310 },
        },
        pins = {
            { mapID = 1439, x = 0.3830, y = 0.4310, label = "Gershala Nightwhisper", kind = "start" },
        },
    },
    [1360] = {
        name = "Reclaimed Treasures",
        pickup = "Krom Stoutarm, Ironforge",
        turnin = "Krom Stoutarm, Ironforge",
        steps = {
            { text = "Get [Krom Stoutarm's Treasure]", kind = "item", itemID = 8027, itemName = "Krom Stoutarm's Treasure" },
            { text = "Turn in: Krom Stoutarm, Ironforge", kind = "turnin" },
        },
        items = {
            { id = 8027, name = "Krom Stoutarm's Treasure", role = "required" },
        },
        pins = {
            { mapID = 1455, x = 0.7420, y = 0.0980, label = "Krom Stoutarm — Ironforge", kind = "start" },
        },
    },
    [1394] = {
        name = "Final Passage",
        pickup = "Parqual Fintallas, Undercity",
        turnin = "Dorn Plainstalker, Thousand Needles",
        warning = "This is a long chain that has a step in the Library",
        steps = {
            { text = "Prereq chain (9): Test of Faith -> Test of Endurance -> Test of Strength (+6 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1458, x = 0.5740, y = 0.6540, label = "Parqual Fintallas — Undercity", kind = "start" },
        },
    },
    [1424] = {
        pickup = "Fel'zerul, Swamp of Sorrows",
        turnin = "Fel'zerul, Swamp of Sorrows",
        pins = {
            { mapID = 1435, x = 0.4800, y = 0.5500, label = "Fel'zerul — Swamp of Sorrows", kind = "location" },
        },
    },
    [1429] = {
        pickup = "Fel'zerul, Swamp of Sorrows",
        turnin = "Atal'ai Exile, The Hinterlands",
        pins = {
            { mapID = 1435, x = 0.4800, y = 0.5500, label = "Fel'zerul — Swamp of Sorrows", kind = "location" },
        },
    },
    [1444] = {
        pickup = "Atal'ai Exile, The Hinterlands",
        turnin = "Fel'zerul, Swamp of Sorrows",
        pins = {
            { mapID = 1425, x = 0.3360, y = 0.7520, label = "Atal'ai Exile — The Hinterlands", kind = "location" },
        },
    },
    [1445] = {
        name = "The Temple of Atal'Hakkar",
        pickup = "Fel'Zerul, Stonard, Swamp of Sorrows",
        turnin = "Fel'Zerul, Stonard, Swamp of Sorrows",
        summary = "Collect 20 Fetishes of Hakkar from Atal'ai trolls; outer-temple trolls also drop them.",
        steps = {
            { text = "Prereq chain (3): Pool of Tears -> The Atal'ai Exile -> Return to Fel'Zerul", kind = "quest" },
        },
        pins = {
            { mapID = 1435, x = 0.4800, y = 0.5500, label = "Fel'zerul — Swamp of Sorrows", kind = "start" },
        },
    },
    [1446] = {
        name = "Jammal'an the Prophet",
        pickup = "Atal'ai Exile, The Hinterlands",
        turnin = "Atal'ai Exile, The Hinterlands",
        summary = "Kill the six troll guardians on the balconies to drop Jammal'an's barrier, then bring back his head.",
        steps = {
            { text = "Kill the six troll guardians on the balconies to drop Jammal'an's barrier, then bring back his head.", kind = "guide", mapID = 1425, x = 0.3360, y = 0.7520 },
        },
        pins = {
            { mapID = 1425, x = 0.3360, y = 0.7520, label = "Atal'ai Exile — The Hinterlands", kind = "start" },
        },
    },
    [1448] = {
        pickup = "Brohann Caskbelly, Stormwind",
        turnin = "Brohann Caskbelly, Stormwind",
        pins = {
            { mapID = 1453, x = 0.6950, y = 0.4040, label = "Brohann Caskbelly — Stormwind", kind = "location" },
        },
    },
    [1449] = {
        pickup = "Brohann Caskbelly, Stormwind",
        turnin = "Falstad Wildhammer, The Hinterlands",
        pins = {
            { mapID = 1453, x = 0.6950, y = 0.4040, label = "Brohann Caskbelly — Stormwind", kind = "location" },
        },
    },
    [1450] = {
        pickup = "Falstad Wildhammer, The Hinterlands",
        turnin = "Gryphon Master Talonaxe, The Hinterlands",
        pins = {
            { mapID = 1425, x = 0.1180, y = 0.4680, label = "Falstad Wildhammer — The Hinterlands", kind = "location" },
        },
    },
    [1451] = {
        pickup = "Gryphon Master Talonaxe, The Hinterlands",
        turnin = "Rhapsody Shindigger, The Hinterlands",
        pins = {
            { mapID = 1425, x = 0.0980, y = 0.4440, label = "Gryphon Master Talonaxe — The Hinterlands", kind = "location" },
        },
    },
    [1452] = {
        pickup = "Rhapsody Shindigger, The Hinterlands",
        turnin = "Rhapsody Shindigger, The Hinterlands",
        pins = {
            { mapID = 1425, x = 0.2680, y = 0.4840, label = "Rhapsody Shindigger — The Hinterlands", kind = "location" },
        },
    },
    [1469] = {
        pickup = "Rhapsody Shindigger, The Hinterlands",
        turnin = "Brohann Caskbelly, Stormwind",
        pins = {
            { mapID = 1425, x = 0.2680, y = 0.4840, label = "Rhapsody Shindigger — The Hinterlands", kind = "location" },
        },
    },
    [1475] = {
        name = "Into The Temple of Atal'Hakkar",
        pickup = "Brohann Caskbelly, Stormwind",
        turnin = "Brohann Caskbelly, Stormwind",
        summary = "Collect 10 Atal'ai Tablets around the temple; tablets in the outer temple also count.",
        steps = {
            { text = "Prereq chain (6): In Search of The Temple -> To The Hinterlands -> Gryphon Master Talonaxe (+3 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1453, x = 0.6950, y = 0.4040, label = "Brohann Caskbelly — Stormwind", kind = "start" },
        },
    },
    [1486] = {
        name = "Deviate Hides",
        pickup = "Nalpak, above the entrance to Wailing Caverns, The Barrens",
        turnin = "Nalpak, above the entrance to Wailing Caverns, The Barrens",
        pins = {
            { mapID = 1413, x = 0.4660, y = 0.3630, label = "Nalpak", kind = "start" },
        },
    },
    [1487] = {
        name = "Deviate Eradication",
        pickup = "Ebru, above the entrance to Wailing Caverns, The Barrens",
        turnin = "Ebru, above the entrance to Wailing Caverns, The Barrens",
        pins = {
            { mapID = 1413, x = 0.4660, y = 0.3570, label = "Ebru", kind = "start" },
        },
    },
    [1489] = {
        pickup = "Tonga Runetotem, The Crossroads",
        turnin = "Hamuul Runetotem, Elder Rise, Thunder Bluff",
        summary = "Tonga sends you to Hamuul after Altered Beings.",
        steps = {
            { text = "Tonga sends you to Hamuul after Altered Beings.", kind = "guide", mapID = 1413, x = 0.5230, y = 0.3190 },
        },
        pins = {
            { mapID = 1413, x = 0.5230, y = 0.3190, label = "Tonga Runetotem — The Barrens", kind = "start", detail = "Tonga Runetotem: The Crossroads, The Barrens" },
        },
    },
    [1490] = {
        pickup = "Hamuul Runetotem, Elder Rise, Thunder Bluff",
        turnin = "Nara Wildmane, Thunder Bluff",
        summary = "Nara Wildmane is the final prerequisite before Leaders of the Fang becomes available.",
        steps = {
            { text = "Nara Wildmane is the final prerequisite before Leaders of the Fang becomes available.", kind = "guide", mapID = 1456, x = 0.7860, y = 0.2860 },
        },
        pins = {
            { mapID = 1456, x = 0.7860, y = 0.2860, label = "Arch Druid Hamuul Runetotem — Thunder Bluff", kind = "start", detail = "Arch Druid Hamuul Runetotem: Elder Rise, Thunder Bluff" },
        },
    },
    [1491] = {
        name = "Smart Drinks",
        pickup = "Mebok Mizzyrix, Ratchet, The Barrens",
        turnin = "Mebok Mizzyrix, Ratchet, The Barrens",
        steps = {
            { text = "Prereq chain (1): Raptor Horns", kind = "quest" },
        },
        pins = {
            { mapID = 1413, x = 0.6280, y = 0.3670, label = "Mebok Mizzyrix", kind = "start" },
        },
    },
    [1651] = {
        pickup = "Daphne Stilwell, Westfall",
        turnin = "Daphne Stilwell, Westfall",
        pins = {
            { mapID = 1436, x = 0.4220, y = 0.8860, label = "Daphne Stilwell — Westfall", kind = "location", detail = "Daphne Stilwell is in the far south of Westfall" },
        },
    },
    [1652] = {
        pickup = "Daphne Stilwell, Westfall",
        turnin = "Duthorian Rall, Cathedral Square, Stormwind",
        pins = {
            { mapID = 1436, x = 0.4170, y = 0.8920, label = "Daphne Stilwell — southern Westfall", kind = "location", detail = "Daphne Stilwell: Stilwell farm, southern Westfall" },
        },
    },
    [1653] = {
        pickup = "Duthorian Rall, Cathedral Square, Stormwind",
        turnin = "Jordan Stilwell, Gates of Ironforge, Dun Morogh",
        pins = {
            { mapID = 1453, x = 0.5050, y = 0.4750, label = "Duthorian Rall — Stormwind", kind = "location", detail = "Duthorian Rall: Cathedral of Light, Stormwind" },
        },
    },
    [1654] = {
        pickup = "Jordan Stilwell, Gates of Ironforge, Dun Morogh",
        turnin = "Jordan Stilwell, Gates of Ironforge, Dun Morogh",
        steps = {
            { text = "Use provided [Jordan's Weapon Notes] (Given by Jordan Stilwell when you accept the quest)", kind = "provided", itemID = 6996, itemName = "Jordan's Weapon Notes" },
            { text = "Get [Whitestone Oak Lumber]: Dropped by: Goblin Woodcarver, The Deadmines", kind = "item", itemID = 6994, itemName = "Whitestone Oak Lumber" },
            { text = "Get [Jordan's Refined Ore Shipment]: Reward from the quest Bailor's Ore Shipment: Bailor Stonehand, Thelsamar, Loch Modan", kind = "item", itemID = 6993, itemName = "Jordan's Refined Ore Shipment" },
            { text = "Get [Jordan's Smithing Hammer]: Found in: Jordan's Hammer, Shadowfang Keep courtyard", kind = "item", itemID = 6895, itemName = "Jordan's Smithing Hammer" },
            { text = "Get [Purified Kor Gem]: Reward from the quest Seeking the Kor Gem: Thundris Windweaver, Auberdine, Darkshore. The Corrupted Kor Gem he asks for drops from Blackfathom Tide Priestesses and Oracles at the Blackfathom Deeps entrance and from Blackfathom Sea Witches inside.", kind = "item", itemID = 7083, itemName = "Purified Kor Gem" },
            { text = "Turn in: Jordan Stilwell, Gates of Ironforge, Dun Morogh", kind = "turnin" },
        },
        items = {
            { id = 6996, name = "Jordan's Weapon Notes", role = "provided", source = "Given by Jordan Stilwell when you accept the quest" },
            { id = 6994, name = "Whitestone Oak Lumber", role = "required", source = "Dropped by: Goblin Woodcarver, The Deadmines" },
            { id = 6993, name = "Jordan's Refined Ore Shipment", role = "required", source = "Reward from the quest Bailor's Ore Shipment: Bailor Stonehand, Thelsamar, Loch Modan" },
            { id = 6895, name = "Jordan's Smithing Hammer", role = "required", source = "Found in: Jordan's Hammer, Shadowfang Keep courtyard" },
            { id = 7083, name = "Purified Kor Gem", role = "required", source = "Reward from the quest Seeking the Kor Gem: Thundris Windweaver, Auberdine, Darkshore. The Corrupted Kor Gem he asks for drops from Blackfathom Tide Priestesses and Oracles at the Blackfathom Deeps entrance and from Blackfathom Sea Witches inside." },
        },
        pins = {
            { mapID = 1426, x = 0.5260, y = 0.3680, label = "Jordan Stilwell — Gates of Ironforge", kind = "location", detail = "Jordan Stilwell stands outside the gates of Ironforge" },
        },
    },
    [1699] = {
        pickup = "Yorus Barleybrew, Lakeshire, Redridge Mountains",
        turnin = "Yorus Barleybrew, Lakeshire, Redridge Mountains",
        summary = "Your warrior trainer (Wu Shen in Stormwind, or the trainers in Ironforge and Darnassus) sends you to Yorus Barleybrew in Lakeshire first. The run is timed.",
        steps = {
            { text = "Your warrior trainer (Wu Shen in Stormwind, or the trainers in Ironforge and Darnassus) sends you to Yorus Barleybrew in Lakeshire first. The run is timed.", kind = "guide", mapID = 1433, x = 0.2150, y = 0.4470 },
        },
        pins = {
            { mapID = 1433, x = 0.2150, y = 0.4470, label = "Yorus Barleybrew — Lakeshire", kind = "location" },
        },
    },
    [1701] = {
        pickup = "Furen Longbeard, Dwarven District, Stormwind (64.6, 37.2)",
        turnin = "Furen Longbeard, Dwarven District, Stormwind (64.6, 37.2)",
        summary = "The Razorfen Kraul step.",
        steps = {
            { text = "Use provided [Furen's Instructions] (Given by Furen Longbeard when you accept the quest)", kind = "provided", itemID = 6842, itemName = "Furen's Instructions" },
            { text = "Get [Scorched Spider Fang]: Leech Stalkers and Cave Stalkers at Thelgen Rock, Wetlands (50 needed)", kind = "item", itemID = 6838, itemName = "Scorched Spider Fang" },
            { text = "Get [Charred Horn]: Fledgeling and Young Chimaeras, Charred Vale, Stonetalon Mountains (12 needed)", kind = "item", itemID = 6839, itemName = "Charred Horn" },
            { text = "Get [Galvanized Horn]: Chimaera Matriarch, Charred Vale, Stonetalon Mountains", kind = "item", itemID = 6840, itemName = "Galvanized Horn" },
            { text = "Get [Vial of Phlogiston]: Drops from Roogug, the first boss in Razorfen Kraul (take the first left)", kind = "item", itemID = 6841, itemName = "Vial of Phlogiston" },
            { text = "Turn in: Furen Longbeard, Dwarven District, Stormwind (64.6, 37.2)", kind = "turnin" },
        },
        items = {
            { id = 6842, name = "Furen's Instructions", role = "provided", source = "Given by Furen Longbeard when you accept the quest" },
            { id = 6838, name = "Scorched Spider Fang", role = "required", source = "Leech Stalkers and Cave Stalkers at Thelgen Rock, Wetlands (50 needed)" },
            { id = 6839, name = "Charred Horn", role = "required", source = "Fledgeling and Young Chimaeras, Charred Vale, Stonetalon Mountains (12 needed)" },
            { id = 6840, name = "Galvanized Horn", role = "required", source = "Chimaera Matriarch, Charred Vale, Stonetalon Mountains" },
            { id = 6841, name = "Vial of Phlogiston", role = "required", source = "Drops from Roogug, the first boss in Razorfen Kraul (take the first left)" },
        },
        pins = {
            { mapID = 1453, x = 0.6460, y = 0.3720, label = "Furen Longbeard — Stormwind", kind = "location" },
        },
    },
    [1702] = {
        pickup = "Yorus Barleybrew, Lakeshire, Redridge Mountains",
        turnin = "Furen Longbeard, Dwarven District, Stormwind (64.6, 37.2)",
        summary = "Furen rewards you with a shield, Furen's Favor.",
        steps = {
            { text = "Furen rewards you with a shield, Furen's Favor.", kind = "guide", mapID = 1433, x = 0.2150, y = 0.4470 },
        },
        pins = {
            { mapID = 1433, x = 0.2150, y = 0.4470, label = "Yorus Barleybrew — Lakeshire", kind = "location" },
            { mapID = 1453, x = 0.6460, y = 0.3720, label = "Furen Longbeard — Stormwind", kind = "turnin" },
        },
    },
    [1740] = {
        name = "The Orb of Soran'ruk",
        pickup = "Doan Karhan, The Barrens",
        turnin = "Doan Karhan, The Barrens",
        summary = "Warlock class quest. The fragments come from Shadowfang Keep and Blackfathom Deeps.",
        steps = {
            { text = "Warlock class quest. The fragments come from Shadowfang Keep and Blackfathom Deeps.", kind = "guide", mapID = 1413, x = 0.4930, y = 0.5720 },
        },
        pins = {
            { mapID = 1413, x = 0.4930, y = 0.5720, label = "Doan Karhan", kind = "start" },
        },
    },
    [1782] = {
        name = "Furen's Armor",
        pickup = "Furen Longbeard, Dwarven District, Stormwind (64.6, 37.2)",
        turnin = "Furen Longbeard, Dwarven District, Stormwind (64.6, 37.2)",
        summary = "Final step. Rewards Fire Hardened Hauberk.",
        warning = "This is a chain quest with a step in Razorfen Kraul",
        steps = {
            { text = "Prereq chain (3): The Rethban Gauntlet -> The Shieldsmith -> Fire Hardened Mail", kind = "quest" },
        },
        pins = {
            { mapID = 1453, x = 0.6460, y = 0.3720, label = "Furen Longbeard — Stormwind", kind = "start" },
        },
    },
    [1806] = {
        name = "The Test of Righteousness",
        pickup = "Jordan Stilwell, Gates of Ironforge, Dun Morogh",
        turnin = "Jordan Stilwell, Gates of Ironforge, Dun Morogh",
        summary = "Final step. Rewards Verigan's Fist.",
        warning = "This is a chain quest with a step in Shadowfang Keep",
        steps = {
            { text = "Prereq chain (4): The Tome of Valor -> The Tome of Valor -> The Test of Righteousness (+1 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1426, x = 0.5260, y = 0.3680, label = "Jordan Stilwell — Gates of Ironforge", kind = "start" },
        },
    },
    [1824] = {
        pickup = "Ruga Ragetotem, Camp Taurajo, The Barrens",
        turnin = "Ruga Ragetotem, Camp Taurajo, The Barrens",
        summary = "Your warrior trainer (Sorek in Orgrimmar) sends you to Ruga first. Timed: 30 minutes. The antennae come from the silithids at the Field of Giants, south of Camp Taurajo.",
        steps = {
            { text = "Your warrior trainer (Sorek in Orgrimmar) sends you to Ruga first. Timed: 30 minutes. The antennae come from the silithids at the Field of Giants, south of Camp Taurajo.", kind = "guide", mapID = 1413, x = 0.4500, y = 0.5900 },
        },
        pins = {
            { mapID = 1413, x = 0.4500, y = 0.5900, label = "Ruga Ragetotem — Camp Taurajo", kind = "location" },
            { mapID = 1413, x = 0.4450, y = 0.7050, label = "Field of Giants — The Barrens", kind = "objective", detail = "Silithid Creepers, Swarmers and Grubs at the mounds south of Camp Taurajo drop Twitching Antennae" },
        },
    },
    [1825] = {
        pickup = "Ruga Ragetotem, Camp Taurajo, The Barrens",
        turnin = "Thun'grim Firegaze, hills east of the Crossroads, The Barrens (57, 30)",
        pins = {
            { mapID = 1413, x = 0.4500, y = 0.5900, label = "Ruga Ragetotem — Camp Taurajo", kind = "location" },
            { mapID = 1413, x = 0.5700, y = 0.3000, label = "Thun'grim Firegaze — east of the Crossroads", kind = "turnin", detail = "On the hilltop east of the Crossroads, just south of Thorn Hill" },
        },
    },
    [1838] = {
        pickup = "Thun'grim Firegaze, hills east of the Crossroads, The Barrens (57, 30)",
        turnin = "Thun'grim Firegaze, hills east of the Crossroads, The Barrens (57, 30)",
        summary = "The Razorfen Kraul step.",
        steps = {
            { text = "Get [Smoky Iron Ingot]: Windshear kobolds, Windshear Crag, Stonetalon Mountains (15 needed)", kind = "item", itemID = 7126, itemName = "Smoky Iron Ingot" },
            { text = "Get [Powdered Azurite]: Hillsbrad Miners, Azurelode Mine, Hillsbrad Foothills (10 needed)", kind = "item", itemID = 7127, itemName = "Powdered Azurite" },
            { text = "Get [Iron Bar]: Mining (smelted) or the Auction House (10 needed)", kind = "item", itemID = 3575, itemName = "Iron Bar" },
            { text = "Get [Vial of Phlogiston]: Drops from Roogug, the first boss in Razorfen Kraul (take the first left)", kind = "item", itemID = 6841, itemName = "Vial of Phlogiston" },
            { text = "Turn in: Thun'grim Firegaze, hills east of the Crossroads, The Barrens (57, 30)", kind = "turnin" },
        },
        items = {
            { id = 7126, name = "Smoky Iron Ingot", role = "required", source = "Windshear kobolds, Windshear Crag, Stonetalon Mountains (15 needed)" },
            { id = 7127, name = "Powdered Azurite", role = "required", source = "Hillsbrad Miners, Azurelode Mine, Hillsbrad Foothills (10 needed)" },
            { id = 3575, name = "Iron Bar", role = "required", source = "Mining (smelted) or the Auction House (10 needed)" },
            { id = 6841, name = "Vial of Phlogiston", role = "required", source = "Drops from Roogug, the first boss in Razorfen Kraul (take the first left)" },
        },
        pins = {
            { mapID = 1413, x = 0.5700, y = 0.3000, label = "Thun'grim Firegaze — east of the Crossroads", kind = "location", detail = "On the hilltop east of the Crossroads, just south of Thorn Hill" },
        },
    },
    [1848] = {
        name = "Brutal Hauberk",
        pickup = "Thun'grim Firegaze, hills east of the Crossroads, The Barrens (57, 30)",
        turnin = "Thun'grim Firegaze, hills east of the Crossroads, The Barrens (57, 30)",
        summary = "Final step. Rewards Brutal Hauberk.",
        warning = "This is a chain quest with a step in Razorfen Kraul",
        steps = {
            { text = "Prereq chain (3): Trial at the Field of Giants -> Speak with Thun'grim -> Brutal Armor", kind = "quest" },
        },
        pins = {
            { mapID = 1413, x = 0.5700, y = 0.3000, label = "Thun'grim Firegaze — east of the Crossroads", kind = "start", detail = "On the hilltop east of the Crossroads, just south of Thorn Hill" },
        },
    },
    [1949] = {
        pickup = "Tabetha, Dustwallow Marsh",
        turnin = "Magus Tirth, Shimmering Flats, Thousand Needles",
        pins = {
            { mapID = 1445, x = 0.4600, y = 0.5700, label = "Tabetha — Dustwallow Marsh", kind = "location" },
            { mapID = 1441, x = 0.7820, y = 0.7580, label = "Magus Tirth — Shimmering Flats", kind = "turnin" },
        },
    },
    [1950] = {
        pickup = "Magus Tirth, Shimmering Flats, Thousand Needles",
        turnin = "Magus Tirth, Shimmering Flats, Thousand Needles",
        pins = {
            { mapID = 1441, x = 0.7820, y = 0.7580, label = "Magus Tirth — Shimmering Flats", kind = "location" },
        },
    },
    [1951] = {
        name = "Rituals of Power",
        pickup = "Magus Tirth, Shimmering Flats, Thousand Needles",
        turnin = "Tabetha, Dustwallow Marsh",
        summary = "Mage class quest.",
        steps = {
            { text = "Prereq chain (2): Hidden Secrets -> Get the Scoop", kind = "quest" },
            { text = "Get [Rituals of Power]", kind = "item", itemID = 7274, itemName = "Rituals of Power" },
            { text = "Turn in: Tabetha, Dustwallow Marsh", kind = "turnin", mapID = 1445, x = 0.4600, y = 0.5700 },
        },
        items = {
            { id = 7274, name = "Rituals of Power", role = "required" },
        },
        pins = {
            { mapID = 1441, x = 0.7820, y = 0.7580, label = "Magus Tirth — Shimmering Flats", kind = "start" },
            { mapID = 1445, x = 0.4600, y = 0.5700, label = "Tabetha — Dustwallow Marsh", kind = "turnin" },
        },
    },
    [1954] = {
        pickup = "Tabetha, Dustwallow Marsh",
        turnin = "Tabetha, Dustwallow Marsh",
        steps = {
            { text = "Get [Infernal Orb]: Dropped by the summoners at Mannoroc Coven, Desolace (around 53, 83)", kind = "item", itemID = 7291, itemName = "Infernal Orb" },
            { text = "Turn in: Tabetha, Dustwallow Marsh", kind = "turnin" },
        },
        items = {
            { id = 7291, name = "Infernal Orb", role = "required", source = "Dropped by the summoners at Mannoroc Coven, Desolace (around 53, 83)" },
        },
        pins = {
            { mapID = 1445, x = 0.4600, y = 0.5700, label = "Tabetha — Dustwallow Marsh", kind = "location" },
        },
    },
    [1955] = {
        pickup = "Tabetha, Dustwallow Marsh",
        turnin = "Tabetha, Dustwallow Marsh",
        pins = {
            { mapID = 1445, x = 0.4600, y = 0.5700, label = "Tabetha — Dustwallow Marsh", kind = "location" },
        },
    },
    [1956] = {
        name = "Power in Uldaman",
        pickup = "Tabetha, Dustwallow Marsh",
        turnin = "Tabetha, Dustwallow Marsh",
        summary = "Mage class quest. The Obsidian Sentinel guards the back entrance of Uldaman. Continues with Mana Surges for the Celestial Orb or Celestial Stave.",
        steps = {
            { text = "Prereq chain (2): The Infernal Orb -> The Exorcism", kind = "quest" },
            { text = "Get [Obsidian Power Source]", kind = "item", itemID = 8053, itemName = "Obsidian Power Source" },
            { text = "Turn in: Tabetha, Dustwallow Marsh", kind = "turnin" },
        },
        items = {
            { id = 8053, name = "Obsidian Power Source", role = "required" },
        },
        pins = {
            { mapID = 1445, x = 0.4600, y = 0.5700, label = "Tabetha — Dustwallow Marsh", kind = "start" },
        },
    },
    [2040] = {
        name = "Underground Assault",
        pickup = "Shoni the Shilent, the Dwarven District, Stormwind",
        turnin = "Shoni the Shilent, Stormwind",
        summary = "Follows Speak with Shoni.",
        steps = {
            { text = "Follows Speak with Shoni.", kind = "guide", mapID = 1453, x = 0.6300, y = 0.3400 },
        },
        pins = {
            { mapID = 1453, x = 0.6300, y = 0.3400, label = "Shoni the Shilent — Dwarven District, Stormwind", kind = "start" },
        },
    },
    [2041] = {
        pickup = "Gnoarn, Tinker Town, Ironforge",
        turnin = "Shoni the Shilent, Dwarven District, Stormwind",
        summary = "This leads directly into Underground Assault.",
        steps = {
            { text = "This leads directly into Underground Assault.", kind = "guide", mapID = 1455, x = 0.6920, y = 0.5050 },
        },
        pins = {
            { mapID = 1455, x = 0.6920, y = 0.5050, label = "Gnoarn — Tinker Town", kind = "location", detail = "Start Speak with Shoni here" },
        },
    },
    [2198] = {
        pickup = "Shattered Necklace (drops in Uldaman)",
        turnin = "Talvash del Kissel, Ironforge",
        steps = {
            { text = "Start with [Shattered Necklace] (Drops from the dwarves and troggs in Uldaman)", kind = "starter", itemID = 7666, itemName = "Shattered Necklace" },
        },
        items = {
            { id = 7666, name = "Shattered Necklace", role = "starter", source = "Drops from the dwarves and troggs in Uldaman" },
        },
    },
    [2199] = {
        pickup = "Talvash del Kissel, Ironforge",
        turnin = "Talvash del Kissel, Ironforge",
        steps = {
            { text = "Get [Silver Bar]: Smelted from Silver Ore: mining, trade or the auction house (5 needed)", kind = "item", itemID = 2842, itemName = "Silver Bar" },
            { text = "Turn in: Talvash del Kissel, Ironforge", kind = "turnin" },
        },
        items = {
            { id = 2842, name = "Silver Bar", role = "required", source = "Smelted from Silver Ore: mining, trade or the auction house (5 needed)" },
        },
        pins = {
            { mapID = 1455, x = 0.3600, y = 0.0400, label = "Talvash del Kissel — Ironforge", kind = "location" },
        },
    },
    [2200] = {
        name = "Back to Uldaman",
        pickup = "Talvash del Kissel, Ironforge",
        turnin = "Remains of a Paladin, Uldaman",
        pins = {
            { mapID = 1455, x = 0.3600, y = 0.0400, label = "Talvash del Kissel — Ironforge", kind = "location" },
            { mapID = 1455, x = 0.3600, y = 0.0340, label = "Talvash del Kissel — Ironforge", kind = "start" },
        },
    },
    [2201] = {
        name = "Find the Gems",
        pickup = "Remains of a Paladin, Uldaman",
        turnin = "Talvash del Kissel (Phial of Scrying)",
        summary = "The sapphire drops from Grimlok.",
        steps = {
            { text = "Prereq chain (3): The Shattered Necklace -> Lore for a Price -> Back to Uldaman", kind = "quest" },
            { text = "Get [Shattered Necklace Ruby]: In the Shadowforge Stash in Galgann Firehammer's room; opening it brings two enemies", kind = "item", itemID = 7669, itemName = "Shattered Necklace Ruby" },
            { text = "Get [Shattered Necklace Sapphire]: Dropped by Grimlok", kind = "item", itemID = 7670, itemName = "Shattered Necklace Sapphire" },
            { text = "Get [Shattered Necklace Topaz]: In the Conspicuous Urn in the room with Baelog, Olaf and Eric", kind = "item", itemID = 7671, itemName = "Shattered Necklace Topaz" },
            { text = "Turn in: Talvash del Kissel (Phial of Scrying)", kind = "turnin" },
        },
        items = {
            { id = 7669, name = "Shattered Necklace Ruby", role = "required", source = "In the Shadowforge Stash in Galgann Firehammer's room; opening it brings two enemies" },
            { id = 7670, name = "Shattered Necklace Sapphire", role = "required", source = "Dropped by Grimlok" },
            { id = 7671, name = "Shattered Necklace Topaz", role = "required", source = "In the Conspicuous Urn in the room with Baelog, Olaf and Eric" },
        },
    },
    [2202] = {
        name = "Uldaman Reagent Run",
        pickup = "Jarkal Mossmeld, Kargath, Badlands",
        turnin = "Jarkal Mossmeld, Kargath, Badlands",
        steps = {
            { text = "Prereq chain (1): Badlands Reagent Run", kind = "quest" },
            { text = "Get [Magenta Fungus Cap]: Need x12", kind = "item", itemID = 8047, itemName = "Magenta Fungus Cap" },
            { text = "Turn in: Jarkal Mossmeld, Kargath, Badlands", kind = "turnin" },
        },
        items = {
            { id = 8047, name = "Magenta Fungus Cap", role = "required", source = "Need x12" },
        },
        pins = {
            { mapID = 1418, x = 0.0240, y = 0.4600, label = "Jarkal Mossmeld — Badlands", kind = "start" },
        },
    },
    [2204] = {
        name = "Restoring the Necklace",
        pickup = "Talvash's Scrying Bowl, Uldaman",
        turnin = "Talvash del Kissel, Ironforge",
        summary = "The power source drops from Archaedas. Finishing it unlocks Talvash's Enhancing Necklace.",
        steps = {
            { text = "Prereq chain (4): The Shattered Necklace -> Lore for a Price -> Back to Uldaman (+1 more)", kind = "quest" },
            { text = "Get [Shattered Necklace Power Source]: Dropped by Archaedas, the last boss of Uldaman", kind = "item", itemID = 7672, itemName = "Shattered Necklace Power Source" },
            { text = "Turn in: Talvash del Kissel, Ironforge", kind = "turnin" },
        },
        items = {
            { id = 7672, name = "Shattered Necklace Power Source", role = "required", source = "Dropped by Archaedas, the last boss of Uldaman" },
        },
    },
    [2240] = {
        name = "The Hidden Chamber",
        pickup = "Baelog, Uldaman",
        turnin = "Prospector Stormpike, Ironforge",
        summary = "Optional introductory quest:",
        steps = {
            { text = "Optional introductory quest:", kind = "guide" },
        },
    },
    [2258] = {
        pickup = "Jarkal Mossmeld, Badlands",
        turnin = "Jarkal Mossmeld, Badlands",
        steps = {
            { text = "Get [Buzzard Gizzard]: Dropped by buzzards in the Badlands, e.g. around the big carcass at 15, 60 (5 needed)", kind = "item", itemID = 7847, itemName = "Buzzard Gizzard" },
            { text = "Get [Crag Coyote Fang]: Dropped by crag coyotes all over the Badlands (10 needed)", kind = "item", itemID = 7846, itemName = "Crag Coyote Fang" },
            { text = "Get [Rock Elemental Shard]: Dropped by rock elementals in the hills by Kargath, around 13, 36 (5 needed)", kind = "item", itemID = 7848, itemName = "Rock Elemental Shard" },
            { text = "Turn in: Jarkal Mossmeld, Badlands", kind = "turnin" },
        },
        items = {
            { id = 7847, name = "Buzzard Gizzard", role = "required", source = "Dropped by buzzards in the Badlands, e.g. around the big carcass at 15, 60 (5 needed)" },
            { id = 7846, name = "Crag Coyote Fang", role = "required", source = "Dropped by crag coyotes all over the Badlands (10 needed)" },
            { id = 7848, name = "Rock Elemental Shard", role = "required", source = "Dropped by rock elementals in the hills by Kargath, around 13, 36 (5 needed)" },
        },
        pins = {
            { mapID = 1418, x = 0.0240, y = 0.4600, label = "Jarkal Mossmeld — Badlands", kind = "location" },
        },
    },
    [2278] = {
        name = "The Platinum Discs",
        pickup = "The Discs of Norgannon, Uldaman",
        turnin = "The Discs of Norgannon, Uldaman",
        summary = "The discs are in the Map Chamber, past Ironaya.",
        steps = {
            { text = "Interact with: table: 00FAF9C8", kind = "object" },
        },
    },
    [2279] = {
        name = "The Platinum Discs",
        pickup = "The Discs of Norgannon, Uldaman",
        turnin = "High Explorer Magellas, Ironforge",
        summary = "Speak with the Stone Watcher and activate the discs first. Then hand the reward voucher to Dinita Stonemantle in the Ironforge vault and choose your reward.",
        steps = {
            { text = "Interact with: table: 00ECF5A0", kind = "object", mapID = 1455, x = 0.6960, y = 0.1860 },
        },
        pins = {
            { mapID = 1455, x = 0.6960, y = 0.1860, label = "High Explorer Magellas — Hall of Explorers, Ironforge", kind = "turnin" },
        },
    },
    [2280] = {
        name = "The Platinum Discs",
        pickup = "The Discs of Norgannon, Uldaman",
        turnin = "Sage Truthseeker, Thunder Bluff",
        summary = "Speak with the Stone Watcher and activate the discs first. Then hand the reward voucher to Bena Winterhoof in Thunder Bluff and choose your reward.",
        steps = {
            { text = "Interact with: table: 00ECF140", kind = "object", mapID = 1456, x = 0.3440, y = 0.4720 },
        },
        pins = {
            { mapID = 1456, x = 0.3440, y = 0.4720, label = "Sage Truthseeker — Thunder Bluff", kind = "turnin" },
        },
    },
    [2283] = {
        name = "Necklace Recovery",
        pickup = "Dran Droffers, Orgrimmar",
        turnin = "Dran Droffers, Orgrimmar",
        warning = "As Horde you can't start the quest from the necklace, you need to have the quest first.",
        steps = {
            { text = "Get [Shattered Necklace]: Dropped by the troggs and Shadowforge dwarves of the Uldaman dig site", kind = "item", itemID = 7666, itemName = "Shattered Necklace" },
            { text = "Turn in: Dran Droffers, Orgrimmar", kind = "turnin" },
        },
        items = {
            { id = 7666, name = "Shattered Necklace", role = "required", source = "Dropped by the troggs and Shadowforge dwarves of the Uldaman dig site" },
        },
        pins = {
            { mapID = 1454, x = 0.5940, y = 0.3680, label = "Dran Droffers — Orgrimmar", kind = "start" },
        },
    },
    [2284] = {
        name = "Necklace Recovery, Take 2",
        pickup = "Dran Droffers, Orgrimmar",
        turnin = "Remains of a Paladin, Uldaman",
        pins = {
            { mapID = 1454, x = 0.5940, y = 0.3680, label = "Dran Droffers — Orgrimmar", kind = "start" },
        },
    },
    [2338] = {
        pickup = "Jarkal Mossmeld, Badlands",
        turnin = "Jarkal Mossmeld, Badlands",
        pins = {
            { mapID = 1418, x = 0.0240, y = 0.4600, label = "Jarkal Mossmeld — Badlands", kind = "location" },
        },
    },
    [2339] = {
        name = "Find the Gems and Power Source",
        pickup = "Jarkal Mossmeld, Kargath, Badlands",
        turnin = "Jarkal Mossmeld, Kargath, Badlands",
        summary = "The sapphire drops from Grimlok and the power source from Archaedas.",
        steps = {
            { text = "Prereq chain (4): Necklace Recovery -> Necklace Recovery, Take 2 -> Translating the Journal (+1 more)", kind = "quest" },
            { text = "Get [Shattered Necklace Ruby]: In the Shadowforge Stash in Galgann Firehammer's room; opening it brings two enemies", kind = "item", itemID = 7669, itemName = "Shattered Necklace Ruby" },
            { text = "Get [Shattered Necklace Sapphire]: Dropped by Grimlok", kind = "item", itemID = 7670, itemName = "Shattered Necklace Sapphire" },
            { text = "Get [Shattered Necklace Topaz]: In the Conspicuous Urn in the room with Baelog, Olaf and Eric", kind = "item", itemID = 7671, itemName = "Shattered Necklace Topaz" },
            { text = "Get [Shattered Necklace Power Source]: Dropped by Archaedas, the last boss of Uldaman", kind = "item", itemID = 7672, itemName = "Shattered Necklace Power Source" },
            { text = "Turn in: Jarkal Mossmeld, Kargath, Badlands", kind = "turnin" },
        },
        items = {
            { id = 7669, name = "Shattered Necklace Ruby", role = "required", source = "In the Shadowforge Stash in Galgann Firehammer's room; opening it brings two enemies" },
            { id = 7670, name = "Shattered Necklace Sapphire", role = "required", source = "Dropped by Grimlok" },
            { id = 7671, name = "Shattered Necklace Topaz", role = "required", source = "In the Conspicuous Urn in the room with Baelog, Olaf and Eric" },
            { id = 7672, name = "Shattered Necklace Power Source", role = "required", source = "Dropped by Archaedas, the last boss of Uldaman" },
        },
        pins = {
            { mapID = 1418, x = 0.0240, y = 0.4600, label = "Jarkal Mossmeld — Badlands", kind = "location" },
        },
    },
    [2340] = {
        pickup = "Jarkal Mossmeld, Kargath, Badlands (2.6, 46.0)",
        turnin = "Dran Droffers, The Drag, Orgrimmar (59.4, 36.8)",
        steps = {
            { text = "Use provided [Necklace and Gem Salvage] (Given by Jarkal Mossmeld when you accept the quest)", kind = "provided", itemID = 0, itemName = "Necklace and Gem Salvage" },
            { text = "Turn in: Dran Droffers, The Drag, Orgrimmar (59.4, 36.8)", kind = "turnin", mapID = 1454, x = 0.5940, y = 0.3680 },
        },
        items = {
            { id = 0, name = "Necklace and Gem Salvage", role = "provided", source = "Given by Jarkal Mossmeld when you accept the quest" },
        },
        pins = {
            { mapID = 1418, x = 0.0260, y = 0.4600, label = "Jarkal Mossmeld — Kargath, Badlands", kind = "location" },
            { mapID = 1454, x = 0.5940, y = 0.3680, label = "Dran Droffers — The Drag, Orgrimmar", kind = "turnin" },
        },
    },
    [2341] = {
        name = "Necklace Recovery, Take 3",
        pickup = "Dran Droffers, The Drag, Orgrimmar (59.4, 36.8)",
        turnin = "Jarkal Mossmeld, Kargath, Badlands (2.6, 46.0)",
        steps = {
            { text = "Prereq chain (6): Necklace Recovery -> Necklace Recovery, Take 2 -> Translating the Journal (+3 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1454, x = 0.5940, y = 0.3680, label = "Dran Droffers — The Drag, Orgrimmar", kind = "start" },
            { mapID = 1418, x = 0.0260, y = 0.4600, label = "Jarkal Mossmeld — Kargath, Badlands", kind = "turnin" },
        },
    },
    [2342] = {
        name = "Reclaimed Treasures",
        pickup = "Patrick Garrett, Undercity",
        turnin = "Patrick Garrett, Undercity",
        steps = {
            { text = "Get [Garrett Family Treasure]", kind = "item", itemID = 8026, itemName = "Garrett Family Treasure" },
            { text = "Turn in: Patrick Garrett, Undercity", kind = "turnin" },
        },
        items = {
            { id = 8026, name = "Garrett Family Treasure", role = "required" },
        },
        pins = {
            { mapID = 1458, x = 0.6240, y = 0.4840, label = "Patrick Garrett — Undercity", kind = "start" },
        },
    },
    [2361] = {
        name = "Restoring the Necklace",
        pickup = "Talvash del Kissel, Mystic Ward, Ironforge (36.0, 4.0)",
        turnin = "Talvash del Kissel, Mystic Ward, Ironforge (36.0, 4.0)",
        steps = {
            { text = "Prereq chain (5): The Shattered Necklace -> Lore for a Price -> Back to Uldaman (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1455, x = 0.3600, y = 0.0400, label = "Talvash del Kissel — Mystic Ward, Ironforge", kind = "start" },
        },
    },
    [2398] = {
        name = "The Lost Dwarves",
        pickup = "Prospector Stormpike, Hall of Explorers, Ironforge",
        turnin = "Baelog, Uldaman",
        summary = "Introductory step leading to The Hidden Chamber.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to The Hidden Chamber.", kind = "guide", mapID = 1455, x = 0.7460, y = 0.1170 },
        },
        pins = {
            { mapID = 1455, x = 0.7460, y = 0.1170, label = "Prospector Stormpike — Ironforge", kind = "start" },
        },
    },
    [2418] = {
        name = "Power Stones",
        pickup = "Rigglefuzz, Badlands",
        turnin = "Rigglefuzz, Badlands",
        summary = "The power stones drop from Shadowforge dwarves in the outer cave.",
        steps = {
            { text = "Get [Dentrium Power Stone]: Dropped by the Shadowforge dwarves outside the instance (8 needed)", kind = "item", itemID = 8009, itemName = "Dentrium Power Stone" },
            { text = "Get [An'Alleum Power Stone]: Dropped by the Shadowforge dwarves outside the instance (8 needed)", kind = "item", itemID = 8052, itemName = "An'Alleum Power Stone" },
            { text = "Turn in: Rigglefuzz, Badlands", kind = "turnin" },
        },
        items = {
            { id = 8009, name = "Dentrium Power Stone", role = "required", source = "Dropped by the Shadowforge dwarves outside the instance (8 needed)" },
            { id = 8052, name = "An'Alleum Power Stone", role = "required", source = "Dropped by the Shadowforge dwarves outside the instance (8 needed)" },
        },
        pins = {
            { mapID = 1418, x = 0.4240, y = 0.5240, label = "Rigglefuzz — Badlands", kind = "start" },
        },
    },
    [2439] = {
        name = "The Platinum Discs",
        pickup = "High Explorer Magellas, Hall of Explorers, Ironforge (69.6, 18.6)",
        turnin = "Dinita Stonemantle, The Vault, Ironforge (33.8, 60.2)",
        steps = {
            { text = "Prereq chain (2): The Platinum Discs -> The Platinum Discs", kind = "quest" },
            { text = "Use provided [Reward Voucher] (Given by High Explorer Magellas when you accept the quest)", kind = "provided", itemID = 8070, itemName = "Reward Voucher" },
            { text = "Turn in: Dinita Stonemantle, The Vault, Ironforge (33.8, 60.2)", kind = "turnin", mapID = 1455, x = 0.3380, y = 0.6020 },
        },
        items = {
            { id = 8070, name = "Reward Voucher", role = "provided", source = "Given by High Explorer Magellas when you accept the quest" },
        },
        pins = {
            { mapID = 1455, x = 0.6960, y = 0.1860, label = "High Explorer Magellas — Hall of Explorers, Ironforge", kind = "start" },
            { mapID = 1455, x = 0.3380, y = 0.6020, label = "Dinita Stonemantle — The Vault, Ironforge", kind = "turnin" },
        },
    },
    [2440] = {
        name = "The Platinum Discs",
        pickup = "Sage Truthseeker, Thunder Bluff (34.4, 47.2)",
        turnin = "Bena Winterhoof, Thunder Bluff (46.8, 33.4)",
        steps = {
            { text = "Prereq chain (2): The Platinum Discs -> The Platinum Discs", kind = "quest" },
            { text = "Use provided [Reward Voucher] (Given by Sage Truthseeker when you accept the quest)", kind = "provided", itemID = 8070, itemName = "Reward Voucher" },
            { text = "Turn in: Bena Winterhoof, Thunder Bluff (46.8, 33.4)", kind = "turnin", mapID = 1456, x = 0.4680, y = 0.3340 },
        },
        items = {
            { id = 8070, name = "Reward Voucher", role = "provided", source = "Given by Sage Truthseeker when you accept the quest" },
        },
        pins = {
            { mapID = 1456, x = 0.3440, y = 0.4720, label = "Sage Truthseeker — Thunder Bluff", kind = "start" },
            { mapID = 1456, x = 0.4680, y = 0.3340, label = "Bena Winterhoof — Thunder Bluff", kind = "turnin" },
        },
    },
    [2500] = {
        pickup = "Ghak Healtouch, Loch Modan",
        turnin = "Ghak Healtouch, Loch Modan",
        steps = {
            { text = "Get [Buzzard Gizzard]: Dropped by buzzards in the Badlands, e.g. around the big carcass at 15, 60 (5 needed)", kind = "item", itemID = 7847, itemName = "Buzzard Gizzard" },
            { text = "Get [Crag Coyote Fang]: Dropped by crag coyotes all over the Badlands (10 needed)", kind = "item", itemID = 7846, itemName = "Crag Coyote Fang" },
            { text = "Get [Rock Elemental Shard]: Dropped by rock elementals in the hills by Kargath, around 13, 36 (5 needed)", kind = "item", itemID = 7848, itemName = "Rock Elemental Shard" },
            { text = "Turn in: Ghak Healtouch, Loch Modan", kind = "turnin" },
        },
        items = {
            { id = 7847, name = "Buzzard Gizzard", role = "required", source = "Dropped by buzzards in the Badlands, e.g. around the big carcass at 15, 60 (5 needed)" },
            { id = 7846, name = "Crag Coyote Fang", role = "required", source = "Dropped by crag coyotes all over the Badlands (10 needed)" },
            { id = 7848, name = "Rock Elemental Shard", role = "required", source = "Dropped by rock elementals in the hills by Kargath, around 13, 36 (5 needed)" },
        },
        pins = {
            { mapID = 1432, x = 0.3700, y = 0.4920, label = "Ghak Healtouch — Loch Modan", kind = "location" },
        },
    },
    [2768] = {
        name = "Divino-matic Rod",
        pickup = "Chief Engineer Bilgewhizzle, Gadgetzan, Tanaris",
        turnin = "Chief Engineer Bilgewhizzle, Gadgetzan, Tanaris",
        summary = "The rod drops from Sergeant Bly after the pyramid event.",
        steps = {
            { text = "Get [Divino-matic Rod]", kind = "item", itemID = 8548, itemName = "Divino-matic Rod" },
            { text = "Turn in: Chief Engineer Bilgewhizzle, Gadgetzan, Tanaris", kind = "turnin" },
        },
        items = {
            { id = 8548, name = "Divino-matic Rod", role = "required" },
        },
        pins = {
            { mapID = 1446, x = 0.5240, y = 0.2840, label = "Chief Engineer Bilgewhizzle — Tanaris", kind = "start" },
        },
    },
    [2769] = {
        name = "The Brassbolts Brothers",
        pickup = "Klockmort Spannerspan, Tinker Town, Ironforge",
        turnin = "Wizzle Brassbolts, Mirage Raceway, Thousand Needles",
        summary = "Introductory step leading to Gahz'rilla.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Gahz'rilla.", kind = "guide", mapID = 1455, x = 0.6790, y = 0.4610 },
        },
        pins = {
            { mapID = 1455, x = 0.6790, y = 0.4610, label = "Klockmort Spannerspan — Ironforge", kind = "start", detail = "Klockmort Spannerspan: Tinker Town, Ironforge" },
        },
    },
    [2770] = {
        name = "Gahz'rilla",
        pickup = "Wizzle Brassbolts, Shimmering Flats, Thousand Needles",
        turnin = "Wizzle Brassbolts, Shimmering Flats, Thousand Needles",
        summary = "Optional introductory quest:",
        steps = {
            { text = "Get [Gahz'rilla's Electrified Scale]", kind = "item", itemID = 8707, itemName = "Gahz'rilla's Electrified Scale" },
            { text = "Turn in: Wizzle Brassbolts, Shimmering Flats, Thousand Needles", kind = "turnin" },
        },
        items = {
            { id = 8707, name = "Gahz'rilla's Electrified Scale", role = "required" },
        },
        pins = {
            { mapID = 1441, x = 0.7800, y = 0.7700, label = "Wizzle Brassbolts — Thousand Needles", kind = "start" },
        },
    },
    [2841] = {
        name = "Rig Wars",
        pickup = "Nogg, Valley of Honor, Orgrimmar",
        turnin = "Nogg, Orgrimmar",
        pins = {
            { mapID = 1454, x = 0.7600, y = 0.2500, label = "Nogg — Valley of Honor, Orgrimmar", kind = "location", detail = "Accept Rig Wars here" },
        },
    },
    [2842] = {
        pickup = "Sovik, Valley of Honor, Orgrimmar",
        turnin = "Scooty, Booty Bay, Stranglethorn Vale",
        summary = "Required before Gnomer-gooooone!",
        steps = {
            { text = "Required before Gnomer-gooooone!", kind = "guide", mapID = 1454, x = 0.7560, y = 0.2520 },
        },
        pins = {
            { mapID = 1454, x = 0.7560, y = 0.2520, label = "Sovik — Valley of Honor, Orgrimmar", kind = "location", detail = "Start Chief Engineer Scooty here" },
        },
    },
    [2843] = {
        name = "Gnomer-gooooone!",
        pickup = "Scooty, Booty Bay, Stranglethorn Vale",
        turnin = "Scooty, Booty Bay, Stranglethorn Vale",
        steps = {
            { text = "Prereq chain (1): Chief Engineer Scooty", kind = "quest" },
        },
        pins = {
            { mapID = 1434, x = 0.2800, y = 0.7700, label = "Scooty — Booty Bay", kind = "start" },
        },
    },
    [2846] = {
        name = "Tiara of the Deep",
        pickup = "Tabetha, Dustwallow Marsh",
        turnin = "Tabetha, Dustwallow Marsh",
        summary = "The Tiara drops from Hydromancer Velratha.  Optional introductory quest:",
        steps = {
            { text = "Get [Tiara of the Deep]", kind = "item", itemID = 9234, itemName = "Tiara of the Deep" },
            { text = "Turn in: Tabetha, Dustwallow Marsh", kind = "turnin" },
        },
        items = {
            { id = 9234, name = "Tiara of the Deep", role = "required" },
        },
        pins = {
            { mapID = 1445, x = 0.4600, y = 0.5700, label = "Tabetha — Dustwallow Marsh", kind = "start" },
        },
    },
    [2861] = {
        name = "Tabetha's Task",
        pickup = "Mage trainers (mages only)",
        turnin = "Tabetha, Dustwallow Marsh",
        summary = "Introductory step leading to Tiara of the Deep.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Tiara of the Deep.", kind = "guide" },
        },
    },
    [2864] = {
        name = "Tran'rek",
        pickup = "Krazek, Booty Bay, Stranglethorn Vale",
        turnin = "Tran'rek, Gadgetzan, Tanaris",
        summary = "Introductory step leading to Scarab Shells.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Scarab Shells.", kind = "guide", mapID = 1434, x = 0.2690, y = 0.7720 },
        },
        pins = {
            { mapID = 1434, x = 0.2690, y = 0.7720, label = "Krazek — upper floor", kind = "start", detail = "Krazek: Booty Bay inn, upper floor" },
        },
    },
    [2865] = {
        name = "Scarab Shells",
        pickup = "Tran'rek, Gadgetzan, Tanaris",
        turnin = "Tran'rek, Gadgetzan, Tanaris",
        summary = "Optional introductory quest:",
        warning = "Have Tran'rek in your quest log? Hand it in to Tran'rek first: until then you can't accept Scarab Shells, not even when someone shares it.",
        steps = {
            { text = "Get [Uncracked Scarab Shell]: Need x5", kind = "item", itemID = 9238, itemName = "Uncracked Scarab Shell" },
            { text = "Turn in: Tran'rek, Gadgetzan, Tanaris", kind = "turnin" },
        },
        items = {
            { id = 9238, name = "Uncracked Scarab Shell", role = "required", source = "Need x5" },
        },
        pins = {
            { mapID = 1446, x = 0.5140, y = 0.2680, label = "Tran'rek — Tanaris", kind = "start" },
        },
    },
    [2922] = {
        name = "Save Techbot's Brain!",
        pickup = "Tinkmaster Overspark, Ironforge",
        turnin = "Tinkmaster Overspark, Ironforge",
        pins = {
            { mapID = 1455, x = 0.6900, y = 0.5000, label = "Tinkmaster Overspark — Tinker Town, Ironforge", kind = "start" },
        },
    },
    [2924] = {
        name = "Essential Artificials",
        pickup = "Klockmort Spannerspan, Ironforge",
        turnin = "Klockmort Spannerspan, Ironforge",
        pins = {
            { mapID = 1455, x = 0.6700, y = 0.4600, label = "Klockmort Spannerspan — Tinker Town, Ironforge", kind = "start" },
        },
    },
    [2926] = {
        name = "Gnogaine",
        pickup = "Ozzie Togglevolt, Kharanos, Dun Morogh",
        turnin = "Ozzie Togglevolt, Kharanos, Dun Morogh",
        summary = "Required before The Only Cure is More Green Glow.",
        steps = {
            { text = "Get [Full Leaden Collection Phial]: Use the Vial on an Irradiated Invader just outside the instance", kind = "item", itemID = 9284, itemName = "Full Leaden Collection Phial", mapID = 1426, x = 0.2430, y = 0.3980 },
            { text = "Turn in: Ozzie Togglevolt, Kharanos, Dun Morogh", kind = "turnin" },
        },
        items = {
            { id = 9284, name = "Full Leaden Collection Phial", role = "required", source = "Use the Vial on an Irradiated Invader just outside the instance" },
        },
        pins = {
            { mapID = 1426, x = 0.4500, y = 0.4900, label = "Ozzie Togglevolt — Kharanos", kind = "location", detail = "Start Gnogaine here" },
            { mapID = 1426, x = 0.2430, y = 0.3980, label = "Irradiated Invaders — outside Gnomeregan", kind = "item", detail = "Use the Vial on an Irradiated Invader just outside the instance" },
        },
    },
    [2928] = {
        name = "Gyrodrillmatic Excavationators",
        pickup = "Shoni the Shilent, Stormwind City",
        turnin = "Shoni the Shilent, Stormwind City",
        pins = {
            { mapID = 1453, x = 0.6300, y = 0.3400, label = "Shoni the Shilent — Dwarven District, Stormwind", kind = "start" },
        },
    },
    [2929] = {
        name = "The Grand Betrayal",
        pickup = "High Tinker Mekkatorque, Ironforge",
        turnin = "High Tinker Mekkatorque, Ironforge",
        pins = {
            { mapID = 1455, x = 0.6800, y = 0.4900, label = "High Tinker Mekkatorque — Tinker Town, Ironforge", kind = "start" },
        },
    },
    [2930] = {
        name = "Data Rescue",
        pickup = "Master Mechanic Castpipe, Ironforge",
        turnin = "Master Mechanic Castpipe, Ironforge",
        steps = {
            { text = "Prereq chain (5): White Punch Card -> Yellow Punch Card (Punchograph 3005-A) -> Blue Punch Card (Punchograph 3005-B) (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1455, x = 0.6900, y = 0.4800, label = "Master Mechanic Castpipe — Tinker Town, Ironforge", kind = "start" },
        },
    },
    [2933] = {
        pickup = "Venom Bottle",
        turnin = "Apothecary Lydon, Hillsbrad Foothills",
        steps = {
            { text = "Interact with: table: 00FAF950", kind = "object", mapID = 1425, x = 0.2300, y = 0.5780 },
        },
        pins = {
            { mapID = 1425, x = 0.2300, y = 0.5780, label = "Venom Bottles — The Hinterlands", kind = "location" },
        },
    },
    [2934] = {
        pickup = "Apothecary Lydon, Hillsbrad Foothills",
        turnin = "Apothecary Lydon, Hillsbrad Foothills",
        steps = {
            { text = "Get [Undamaged Venom Sac]: Dropped by spiders in the Hinterlands around 35, 64 (not every one has it; everyone in the group can loot it)", kind = "item", itemID = 9322, itemName = "Undamaged Venom Sac" },
            { text = "Turn in: Apothecary Lydon, Hillsbrad Foothills", kind = "turnin" },
        },
        items = {
            { id = 9322, name = "Undamaged Venom Sac", role = "required", source = "Dropped by spiders in the Hinterlands around 35, 64 (not every one has it; everyone in the group can loot it)" },
        },
        pins = {
            { mapID = 1424, x = 0.6140, y = 0.1920, label = "Apothecary Lydon — Hillsbrad Foothills", kind = "location" },
        },
    },
    [2935] = {
        pickup = "Apothecary Lydon, Hillsbrad Foothills",
        turnin = "Master Gadrin",
        pins = {
            { mapID = 1424, x = 0.6140, y = 0.1920, label = "Apothecary Lydon — Hillsbrad Foothills", kind = "location" },
        },
    },
    [2936] = {
        name = "The Spider God",
        pickup = "Master Gadrin, Sen'jin Village, Durotar",
        turnin = "Master Gadrin, Sen'jin Village, Durotar",
        summary = "The Tablet of Theka is in Theka the Martyr's room.",
        steps = {
            { text = "Prereq chain (3): Venom Bottles -> Undamaged Venom Sac -> Consult Master Gadrin", kind = "quest" },
        },
        pins = {
            { mapID = 1411, x = 0.5580, y = 0.7440, label = "Master Gadrin — Durotar", kind = "start" },
        },
    },
    [2945] = {
        pickup = "Grime-Encrusted Ring, dropped by Dark Iron dwarves in Gnomeregan",
        turnin = "The Sparklematic 5200, inside Gnomeregan",
        steps = {
            { text = "Start with [Grime-Encrusted Ring] (Dropped by Dark Iron dwarves in Gnomeregan)", kind = "starter", itemID = 9326, itemName = "Grime-Encrusted Ring" },
        },
        items = {
            { id = 9326, name = "Grime-Encrusted Ring", role = "starter", source = "Dropped by Dark Iron dwarves in Gnomeregan" },
        },
    },
    [2947] = {
        pickup = "The Sparklematic 5200, inside Gnomeregan",
        turnin = "Talvash del Kissel, Mystic Ward, Ironforge",
        summary = "Alliance step required before Gnome Improvement.",
        steps = {
            { text = "Alliance step required before Gnome Improvement.", kind = "guide" },
        },
    },
    [2948] = {
        name = "Gnome Improvement",
        pickup = "Talvash del Kissel, Mystic Ward, Ironforge",
        turnin = "Talvash del Kissel, Mystic Ward, Ironforge",
        steps = {
            { text = "Prereq chain (2): Grime-Encrusted Ring -> Return of the Ring", kind = "quest" },
        },
        pins = {
            { mapID = 1455, x = 0.3570, y = 0.0400, label = "Talvash del Kissel — Mystic Ward, Ironforge", kind = "start" },
        },
    },
    [2949] = {
        pickup = "The Sparklematic 5200, inside Gnomeregan",
        turnin = "Nogg, Valley of Honor, Orgrimmar",
        summary = "Horde step required before Nogg's Ring Redo.",
        steps = {
            { text = "Horde step required before Nogg's Ring Redo.", kind = "guide" },
        },
    },
    [2950] = {
        name = "Nogg's Ring Redo",
        pickup = "Nogg, Valley of Honor, Orgrimmar",
        turnin = "Nogg, Valley of Honor, Orgrimmar",
        steps = {
            { text = "Prereq chain (2): Grime-Encrusted Ring -> Return of the Ring", kind = "quest" },
        },
        pins = {
            { mapID = 1454, x = 0.7600, y = 0.2500, label = "Nogg — Valley of Honor, Orgrimmar", kind = "start" },
        },
    },
    [2962] = {
        name = "The Only Cure is More Green Glow",
        pickup = "Ozzie Togglevolt, Kharanos, Dun Morogh",
        turnin = "Ozzie Togglevolt, Kharanos, Dun Morogh",
        warning = "It might take several tries: keep using it on a living Slime until it works.",
        steps = {
            { text = "Prereq chain (1): Gnogaine", kind = "quest" },
            { text = "Use provided [Heavy Leaden Collection Phial] (Use on an alive Irradiated Slime or Corrosive Lurker)", kind = "provided", itemID = 9364, itemName = "Heavy Leaden Collection Phial" },
            { text = "Turn in: Ozzie Togglevolt, Kharanos, Dun Morogh", kind = "turnin" },
        },
        items = {
            { id = 9364, name = "Heavy Leaden Collection Phial", role = "provided", source = "Use on an alive Irradiated Slime or Corrosive Lurker" },
        },
        pins = {
            { mapID = 1426, x = 0.4500, y = 0.4900, label = "Ozzie Togglevolt — Kharanos", kind = "start" },
        },
    },
    [2988] = {
        pickup = "Gryphon Master Talonaxe, The Hinterlands",
        turnin = "Gryphon Master Talonaxe, The Hinterlands",
        pins = {
            { mapID = 1425, x = 0.0980, y = 0.4440, label = "Gryphon Master Talonaxe — The Hinterlands", kind = "location" },
        },
    },
    [2989] = {
        pickup = "Gryphon Master Talonaxe, The Hinterlands",
        turnin = "Gryphon Master Talonaxe, The Hinterlands",
        pins = {
            { mapID = 1425, x = 0.0980, y = 0.4440, label = "Gryphon Master Talonaxe — The Hinterlands", kind = "location" },
        },
    },
    [2990] = {
        pickup = "Gryphon Master Talonaxe, The Hinterlands",
        turnin = "Thadius Grimshade",
        steps = {
            { text = "Use provided [Sharpbeak's Feather] (Given by Gryphon Master Talonaxe when you accept the quest)", kind = "provided", itemID = 9468, itemName = "Sharpbeak's Feather" },
            { text = "Turn in: Thadius Grimshade", kind = "turnin" },
        },
        items = {
            { id = 9468, name = "Sharpbeak's Feather", role = "provided", source = "Given by Gryphon Master Talonaxe when you accept the quest" },
        },
        pins = {
            { mapID = 1425, x = 0.0980, y = 0.4440, label = "Gryphon Master Talonaxe — The Hinterlands", kind = "location" },
        },
    },
    [2991] = {
        name = "Nekrum's Medallion",
        pickup = "Thadius Grimshade, Blasted Lands",
        turnin = "Thadius Grimshade, Blasted Lands",
        summary = "The medallion drops from Nekrum Gutchewer.",
        steps = {
            { text = "Prereq chain (3): Witherbark Cages -> The Altar of Zul -> Thadius Grimshade", kind = "quest" },
            { text = "Get [Nekrum's Medallion]", kind = "item", itemID = 9471, itemName = "Nekrum's Medallion" },
            { text = "Turn in: Thadius Grimshade, Blasted Lands", kind = "turnin" },
        },
        items = {
            { id = 9471, name = "Nekrum's Medallion", role = "required" },
        },
        pins = {
            { mapID = 1419, x = 0.6700, y = 0.1940, label = "Thadius Grimshade — Blasted Lands", kind = "start" },
        },
    },
    [3042] = {
        name = "Troll Temper",
        pickup = "Trenton Lighthammer, Gadgetzan, Tanaris",
        turnin = "Trenton Lighthammer, Gadgetzan, Tanaris",
        steps = {
            { text = "Get [Troll Temper]: Need x20", kind = "item", itemID = 9523, itemName = "Troll Temper" },
            { text = "Turn in: Trenton Lighthammer, Gadgetzan, Tanaris", kind = "turnin" },
        },
        items = {
            { id = 9523, name = "Troll Temper", role = "required", source = "Need x20" },
        },
        pins = {
            { mapID = 1446, x = 0.5140, y = 0.2860, label = "Trenton Lighthammer — Tanaris", kind = "start" },
        },
    },
    [3341] = {
        name = "Bring the End",
        pickup = "Andrew Brownell, Undercity",
        turnin = "Andrew Brownell, Undercity",
        pins = {
            { mapID = 1458, x = 0.7400, y = 0.3240, label = "Andrew Brownell — Undercity", kind = "start" },
        },
    },
    [3373] = {
        name = "The Essence of Eranikus",
        pickup = "Essence of Eranikus (drops from the Shade of Eranikus)",
        turnin = "Essence Font, Sunken Temple",
        steps = {
            { text = "Start with [Essence of Eranikus] (Dropped by the Shade of Eranikus)", kind = "starter", itemID = 10454, itemName = "Essence of Eranikus" },
        },
        items = {
            { id = 10454, name = "Essence of Eranikus", role = "starter", source = "Dropped by the Shade of Eranikus" },
        },
    },
    [3380] = {
        pickup = "Witch Doctor Uzer'i, Camp Mojache, Feralas (74.4, 43.4)",
        turnin = "Marvon Rivetseeker, Broken Pillar, Tanaris (52.6, 45.8)",
        pins = {
            { mapID = 1444, x = 0.7440, y = 0.4340, label = "Witch Doctor Uzer'i — Camp Mojache", kind = "location" },
        },
    },
    [3444] = {
        pickup = "Marvon Rivetseeker, Tanaris",
        turnin = "Marvon Rivetseeker, Tanaris",
        pins = {
            { mapID = 1446, x = 0.5260, y = 0.4580, label = "Marvon Rivetseeker — Tanaris", kind = "location" },
        },
    },
    [3445] = {
        pickup = "Angelas Moonbreeze, Feathermoon Stronghold, Feralas (31.8, 45.6)",
        turnin = "Marvon Rivetseeker, Broken Pillar, Tanaris (52.6, 45.8)",
        pins = {
            { mapID = 1444, x = 0.3180, y = 0.4560, label = "Angelas Moonbreeze — Feathermoon Stronghold", kind = "location" },
        },
    },
    [3446] = {
        name = "Into the Depths",
        pickup = "Marvon Rivetseeker, Tanaris",
        turnin = "Altar of Hakkar, Sunken Temple",
        summary = "Examine the Altar of Hakkar in the temple basement. Started from Marvon Rivetseeker after The Stone Circle.",
        steps = {
            { text = "Prereq chain (2): The Sunken Temple -> The Stone Circle", kind = "quest" },
        },
        pins = {
            { mapID = 1446, x = 0.5260, y = 0.4580, label = "Marvon Rivetseeker — Tanaris", kind = "start" },
        },
    },
    [3447] = {
        name = "Secret of the Circle",
        pickup = "Marvon Rivetseeker, Tanaris",
        turnin = "Altar of Hakkar, Sunken Temple",
        summary = "Light the statues around the circle in the right order to summon Atal'alarion.",
        steps = {
            { text = "Prereq chain (2): The Sunken Temple -> The Stone Circle", kind = "quest" },
        },
        pins = {
            { mapID = 1446, x = 0.5260, y = 0.4580, label = "Marvon Rivetseeker — Tanaris", kind = "start" },
        },
    },
    [3462] = {
        pickup = "Velarok Windblade, Searing Gorge (39.0, 39.0)",
        turnin = "Squire Maltrake, Searing Gorge (39.0, 39.0)",
        pins = {
            { mapID = 1427, x = 0.3900, y = 0.3900, label = "Velarok Windblade — Searing Gorge", kind = "location" },
        },
    },
    [3463] = {
        pickup = "Squire Maltrake, Searing Gorge (39.0, 39.0)",
        turnin = "Squire Maltrake, Searing Gorge (39.0, 39.0)",
        summary = "Elite quest.",
        steps = {
            { text = "Use provided [Torch of Retribution] (Given by Squire Maltrake when you accept the quest: use it on the Sentry Brazier inside each tower)", kind = "provided", itemID = 10515, itemName = "Torch of Retribution" },
            { text = "Turn in: Squire Maltrake, Searing Gorge (39.0, 39.0)", kind = "turnin" },
        },
        items = {
            { id = 10515, name = "Torch of Retribution", role = "provided", source = "Given by Squire Maltrake when you accept the quest: use it on the Sentry Brazier inside each tower" },
        },
        pins = {
            { mapID = 1427, x = 0.3900, y = 0.3900, label = "Squire Maltrake — Searing Gorge", kind = "location" },
        },
    },
    [3481] = {
        pickup = "Hoard of the Black Dragonflight, Searing Gorge (39.0, 38.9)",
        turnin = "Hoard of the Black Dragonflight, Searing Gorge (39.0, 38.9)",
        steps = {
            { text = "Interact with: table: 0119FD78", kind = "object", mapID = 1427, x = 0.3900, y = 0.3890 },
        },
        pins = {
            { mapID = 1427, x = 0.3900, y = 0.3890, label = "Hoard of the Black Dragonflight — Searing Gorge", kind = "location" },
        },
    },
    [3520] = {
        pickup = "Yeh'kinya, Tanaris",
        turnin = "Yeh'kinya, Tanaris",
        pins = {
            { mapID = 1446, x = 0.6700, y = 0.2240, label = "Yeh'kinya — Tanaris", kind = "location" },
        },
    },
    [3525] = {
        name = "Extinguishing the Idol",
        pickup = "Belnistrasz, Razorfen Downs",
        turnin = "Belnistrasz's Brazier, Razorfen Downs",
        summary = "Waves of undead attack during the ritual. Talk to the brazier near the idol afterwards to finish.",
        steps = {
            { text = "Prereq chain (1): Scourge of the Downs", kind = "quest" },
        },
    },
    [3527] = {
        name = "The Prophecy of Mosh'aru",
        pickup = "Yeh'kinya, Steamwheedle Port, Tanaris",
        turnin = "Yeh'kinya, Steamwheedle Port, Tanaris",
        summary = "The tablets drop from Theka the Martyr and Hydromancer Velratha.",
        steps = {
            { text = "Prereq chain (1): Screecher Spirits", kind = "quest" },
            { text = "Get [First Mosh'aru Tablet]: Dropped by Theka the Martyr", kind = "item", itemID = 10660, itemName = "First Mosh'aru Tablet" },
            { text = "Get [Second Mosh'aru Tablet]: Dropped by Hydromancer Velratha", kind = "item", itemID = 10661, itemName = "Second Mosh'aru Tablet" },
            { text = "Turn in: Yeh'kinya, Steamwheedle Port, Tanaris", kind = "turnin" },
        },
        items = {
            { id = 10660, name = "First Mosh'aru Tablet", role = "required", source = "Dropped by Theka the Martyr" },
            { id = 10661, name = "Second Mosh'aru Tablet", role = "required", source = "Dropped by Hydromancer Velratha" },
        },
        pins = {
            { mapID = 1446, x = 0.6700, y = 0.2240, label = "Yeh'kinya — Tanaris", kind = "start" },
        },
    },
    [3528] = {
        name = "The God Hakkar",
        pickup = "Yeh'kinya, Steamwheedle Port, Tanaris",
        turnin = "Yeh'kinya, Steamwheedle Port, Tanaris",
        summary = "Fill the Egg of Hakkar from the Hakkari Bloodkeepers to summon the Avatar of Hakkar.",
        steps = {
            { text = "Prereq chain (3): Screecher Spirits -> The Prophecy of Mosh'aru -> The Ancient Egg", kind = "quest" },
        },
        pins = {
            { mapID = 1446, x = 0.6700, y = 0.2240, label = "Yeh'kinya — Tanaris", kind = "start" },
        },
    },
    [3636] = {
        name = "Bring the Light",
        pickup = "Archbishop Benedictus, Stormwind",
        turnin = "Archbishop Benedictus, Stormwind",
        pins = {
            { mapID = 1453, x = 0.4960, y = 0.4480, label = "Archbishop Benedictus — Stormwind", kind = "start" },
        },
    },
    [3701] = {
        pickup = "Royal Historian Archesonus, Ironforge",
        turnin = "Royal Historian Archesonus, Ironforge",
        pins = {
            { mapID = 1455, x = 0.3840, y = 0.5540, label = "Royal Historian Archesonus — Ironforge", kind = "location" },
        },
    },
    [3702] = {
        pickup = "Royal Historian Archesonus, Ironforge",
        turnin = "Royal Historian Archesonus, Ironforge",
        pins = {
            { mapID = 1455, x = 0.3840, y = 0.5540, label = "Royal Historian Archesonus — Ironforge", kind = "location" },
        },
    },
    [3765] = {
        name = "The Corruption Abroad",
        pickup = "Argos Nightwhisper, The Park, Stormwind",
        turnin = "Gershala Nightwhisper, Auberdine, Darkshore",
        summary = "Optional Alliance breadcrumb leading to Researching the Corruption.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Optional Alliance breadcrumb leading to Researching the Corruption.", kind = "guide", mapID = 1453, x = 0.3630, y = 0.6740 },
        },
        pins = {
            { mapID = 1453, x = 0.3630, y = 0.6740, label = "Argos Nightwhisper — The Park", kind = "location", detail = "Argos Nightwhisper is in The Park, beside the moonwell area." },
        },
    },
    [3801] = {
        pickup = "Franclorn Forgewright, Blackrock Mountain",
        turnin = "Franclorn Forgewright, Blackrock Mountain",
        warning = "You have to be dead to talk to this guy. He's in Blackrock Mountain, in a room while walking the chain down to BRD.",
    },
    [3802] = {
        name = "Dark Iron Legacy",
        pickup = "Franclorn Forgewright, Blackrock Mountain",
        turnin = "Franclorn Forgewright, Blackrock Mountain",
        summary = "Speak to Franclorn's ghost while dead. Kill Fineous Darkvire for Ironfel and place it on Franclorn's monument by the Ring of Law. The Shadowforge Key opens shortcuts inside BRD.",
        steps = {
            { text = "Prereq chain (1): Dark Iron Legacy", kind = "quest" },
        },
    },
    [3906] = {
        pickup = "Thunderheart, Badlands",
        turnin = "Thunderheart, Badlands",
        pins = {
            { mapID = 1418, x = 0.0340, y = 0.4820, label = "Thunderheart — Badlands", kind = "location" },
        },
    },
    [3907] = {
        name = "Disharmony of Fire",
        pickup = "Thunderheart, Kargath, Badlands",
        turnin = "Thunderheart, Kargath, Badlands",
        summary = "Kill Lord Incendius at the Black Anvil inside BRD and bring back the Tablet of Kurniya.",
        steps = {
            { text = "Prereq chain (1): Disharmony of Flame", kind = "quest" },
        },
        pins = {
            { mapID = 1418, x = 0.0340, y = 0.4820, label = "Thunderheart — Badlands", kind = "start" },
        },
    },
    [3981] = {
        pickup = "Galamav the Marksman, Badlands",
        turnin = "Commander Gor'shak",
        pins = {
            { mapID = 1418, x = 0.0580, y = 0.4740, label = "Galamav the Marksman — Badlands", kind = "location" },
        },
    },
    [3982] = {
        name = "What Is Going On?",
        pickup = "Commander Gor'shak, Blackrock Depths",
        turnin = "Commander Gor'shak, Blackrock Depths",
        summary = "Open his cell with the Prison Cell Key from High Interrogator Gerstahn, then defend him.",
        steps = {
            { text = "Prereq chain (2): Disharmony of Flame -> Commander Gor'shak", kind = "quest" },
        },
    },
    [4002] = {
        pickup = "Thrall, Orgrimmar",
        turnin = "Thrall, Orgrimmar",
        pins = {
            { mapID = 1454, x = 0.3200, y = 0.3780, label = "Thrall — Orgrimmar", kind = "location" },
        },
    },
    [4003] = {
        name = "The Royal Rescue",
        pickup = "Thrall, Grommash Hold, Orgrimmar",
        turnin = "Princess Moira Bronzebeard, Blackrock Depths",
        summary = "Keep Princess Moira alive and speak to her after Emperor Thaurissan dies. Her The Princess Saved? sends you back to Thrall for the reward.",
        steps = {
            { text = "Prereq chain (5): Disharmony of Flame -> Commander Gor'shak -> What Is Going On? (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1454, x = 0.3200, y = 0.3780, label = "Thrall — Orgrimmar", kind = "start" },
        },
    },
    [4022] = {
        pickup = "Cyrus Therepentous, Burning Steppes (94.8, 31.6)",
        turnin = "Cyrus Therepentous, Burning Steppes (94.8, 31.6)",
        summary = "No molt? Cyrus has another A Taste of Flame (elite): after accepting it, ask him how to prove your worth and kill the Frenzied Black Drake he summons for its molt. It opens the Blackrock Depths quest too.",
        steps = {
            { text = "Get [Black Dragonflight Molt]: Inside the Hoard of the Black Dragonflight (Trinkets...)", kind = "item", itemID = 10575, itemName = "Black Dragonflight Molt" },
            { text = "Turn in: Cyrus Therepentous, Burning Steppes (94.8, 31.6)", kind = "turnin" },
        },
        items = {
            { id = 10575, name = "Black Dragonflight Molt", role = "required", source = "Inside the Hoard of the Black Dragonflight (Trinkets...)" },
        },
        pins = {
            { mapID = 1428, x = 0.9480, y = 0.3160, label = "Cyrus Therepentous — Burning Steppes", kind = "location" },
        },
    },
    [4024] = {
        name = "A Taste of Flame",
        pickup = "Cyrus Therepentous, Burning Steppes",
        turnin = "Cyrus Therepentous, Burning Steppes",
        summary = "Kill Bael'Gar, then use the Altered Black Dragonflight Molt on his remains to collect the Encased Fiery Essence.",
        steps = {
            { text = "Prereq chain (4): Squire Maltrake -> Set Them Ablaze! -> Trinkets... (+1 more)", kind = "quest" },
            { text = "Use provided [Altered Black Dragonflight Molt] (Given by Cyrus Therepentous when you accept the quest)", kind = "provided", itemID = 11231, itemName = "Altered Black Dragonflight Molt" },
            { text = "Get [Encased Fiery Essence]", kind = "item", itemID = 11230, itemName = "Encased Fiery Essence" },
            { text = "Turn in: Cyrus Therepentous, Burning Steppes", kind = "turnin" },
        },
        items = {
            { id = 11231, name = "Altered Black Dragonflight Molt", role = "provided", source = "Given by Cyrus Therepentous when you accept the quest" },
            { id = 11230, name = "Encased Fiery Essence", role = "required" },
        },
        pins = {
            { mapID = 1428, x = 0.9480, y = 0.3160, label = "Cyrus Therepentous — Burning Steppes", kind = "start" },
        },
    },
    [4061] = {
        pickup = "Hierophant Theodora Mulvadania, Badlands",
        turnin = "Hierophant Theodora Mulvadania, Badlands",
        pins = {
            { mapID = 1418, x = 0.0300, y = 0.4780, label = "Hierophant Theodora Mulvadania — Badlands", kind = "location" },
        },
    },
    [4062] = {
        pickup = "Hierophant Theodora Mulvadania, Badlands",
        turnin = "Lotwil Veriatus",
        pins = {
            { mapID = 1418, x = 0.0300, y = 0.4780, label = "Hierophant Theodora Mulvadania — Badlands", kind = "location" },
        },
    },
    [4063] = {
        name = "The Rise of the Machines",
        pickup = "Lotwil Veriatus, Badlands",
        turnin = "Lotwil Veriatus, Badlands",
        summary = "Kill Golem Lord Argelmach for his head and collect 10 Intact Elemental Cores from the constructs guarding him.",
        steps = {
            { text = "Prereq chain (2): The Rise of the Machines -> The Rise of the Machines", kind = "quest" },
        },
        pins = {
            { mapID = 1418, x = 0.2580, y = 0.4500, label = "Lotwil Veriatus — Badlands", kind = "start" },
        },
    },
    [4081] = {
        name = "KILL ON SIGHT: Dark Iron Dwarves",
        pickup = "Wanted poster, Kargath, Badlands",
        turnin = "Warlord Goretooth, Kargath, Badlands",
        steps = {
            { text = "Interact with: table: 00FB0D50", kind = "object", mapID = 1418, x = 0.0380, y = 0.4750 },
        },
        pins = {
            { mapID = 1418, x = 0.0380, y = 0.4750, label = "WANTED poster — Kargath, Badlands", kind = "location" },
        },
    },
    [4082] = {
        name = "KILL ON SIGHT: High Ranking Dark Iron Officials",
        pickup = "Wanted poster, Kargath, Badlands",
        turnin = "Warlord Goretooth, Kargath, Badlands",
        steps = {
            { text = "Interact with: table: 00FB0E40", kind = "object", mapID = 1418, x = 0.0400, y = 0.4680 },
        },
        pins = {
            { mapID = 1418, x = 0.0400, y = 0.4680, label = "KILL ON SIGHT poster — Kargath, Badlands", kind = "location" },
        },
    },
    [4083] = {
        name = "The Spectral Chalice",
        pickup = "Gloom'rel, Blackrock Depths",
        turnin = "Gloom'rel, Blackrock Depths",
        summary = "Mining 230. Talk to Gloom'rel before the Seven fight; give the Spectral Chalice 2 Star Rubies, 20 Gold Bars and 10 Truesilver Bars to learn Smelt Dark Iron.",
        steps = {
            { text = "Mining 230. Talk to Gloom'rel before the Seven fight; give the Spectral Chalice 2 Star Rubies, 20 Gold Bars and 10 Truesilver Bars to learn Smelt Dark Iron.", kind = "guide" },
        },
    },
    [4121] = {
        pickup = "Grark Lorkrub, Burning Steppes",
        turnin = "Lexlort, Badlands",
        pins = {
            { mapID = 1428, x = 0.4000, y = 0.3460, label = "Grark Lorkrub — Burning Steppes", kind = "location" },
        },
    },
    [4122] = {
        pickup = "Lexlort, Badlands",
        turnin = "Grark Lorkrub, Burning Steppes",
        pins = {
            { mapID = 1418, x = 0.0580, y = 0.4740, label = "Lexlort — Badlands", kind = "location" },
        },
    },
    [4123] = {
        name = "The Heart of the Mountain",
        pickup = "Maxwort Uberglint, Burning Steppes",
        turnin = "Maxwort Uberglint, Burning Steppes",
        summary = "The Heart of the Mountain is in the vault safe after the Dark Keepers.",
        steps = {
            { text = "The Heart of the Mountain is in the vault safe after the Dark Keepers.", kind = "guide", mapID = 1428, x = 0.6520, y = 0.2380 },
        },
        pins = {
            { mapID = 1428, x = 0.6520, y = 0.2380, label = "Maxwort Uberglint — Burning Steppes", kind = "start" },
        },
    },
    [4126] = {
        name = "Hurley Blackbreath",
        pickup = "Ragnar Thunderbrew, Kharanos, Dun Morogh",
        turnin = "Ragnar Thunderbrew, Kharanos, Dun Morogh",
        summary = "Break the three kegs in the Grim Guzzler storeroom to spawn Hurley Blackbreath and his guards.  Optional introductory quest:",
        steps = {
            { text = "Break the three kegs in the Grim Guzzler storeroom to spawn Hurley Blackbreath and his guards.  Optional introductory quest:", kind = "guide", mapID = 1426, x = 0.4680, y = 0.5240 },
        },
        pins = {
            { mapID = 1426, x = 0.4680, y = 0.5240, label = "Ragnar Thunderbrew — Dun Morogh", kind = "start" },
        },
    },
    [4128] = {
        name = "Ragnar Thunderbrew",
        pickup = "Enohar Thunderbrew, Nethergarde Keep, Blasted Lands",
        turnin = "Ragnar Thunderbrew, Kharanos, Dun Morogh",
        summary = "Introductory step leading to Hurley Blackbreath.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Hurley Blackbreath.", kind = "guide", mapID = 1419, x = 0.6360, y = 0.2060 },
        },
        pins = {
            { mapID = 1419, x = 0.6360, y = 0.2060, label = "Enohar Thunderbrew — Blasted Lands", kind = "start", detail = "Enohar Thunderbrew: Nethergarde Keep, Blasted Lands" },
        },
    },
    [4132] = {
        name = "Operation: Death to Angerforge",
        pickup = "Warlord Goretooth, Kargath, Badlands",
        turnin = "Warlord Goretooth, Kargath, Badlands",
        summary = "Needs both KILL ON SIGHT quests and the Grark Lorkrub escort first.",
        steps = {
            { text = "Prereq chain (4): KILL ON SIGHT: Dark Iron Dwarves -> KILL ON SIGHT: High Ranking Dark Iron Officials -> Grark Lorkrub (+1 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1418, x = 0.0580, y = 0.4740, label = "Warlord Goretooth — Badlands", kind = "start" },
        },
    },
    [4133] = {
        name = "Vivian Lagrave",
        pickup = "Apothecary Zinge, The Apothecarium, Undercity",
        turnin = "Shadowmage Vivian Lagrave, Kargath, Badlands",
        summary = "Introductory step leading to Lost Thunderbrew Recipe.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Lost Thunderbrew Recipe.", kind = "guide", mapID = 1458, x = 0.5010, y = 0.6800 },
        },
        pins = {
            { mapID = 1458, x = 0.5010, y = 0.6800, label = "Apothecary Zinge — Undercity", kind = "start", detail = "Apothecary Zinge: The Apothecarium, Undercity" },
        },
    },
    [4134] = {
        name = "Lost Thunderbrew Recipe",
        pickup = "Shadowmage Vivian Lagrave, Kargath, Badlands",
        turnin = "Shadowmage Vivian Lagrave, Kargath, Badlands",
        summary = "Break the three kegs in the Grim Guzzler storeroom to spawn Hurley Blackbreath and his guards.  Optional introductory quest:",
        steps = {
            { text = "Break the three kegs in the Grim Guzzler storeroom to spawn Hurley Blackbreath and his guards.  Optional introductory quest:", kind = "guide", mapID = 1418, x = 0.0300, y = 0.4760 },
        },
        pins = {
            { mapID = 1418, x = 0.0300, y = 0.4760, label = "Shadowmage Vivian Lagrave — Badlands", kind = "start" },
        },
    },
    [4136] = {
        name = "Ribbly Screwspigot",
        pickup = "Yuka Screwspigot, Flame Crest, Burning Steppes",
        turnin = "Yuka Screwspigot, Flame Crest, Burning Steppes",
        summary = "Optional introductory quest:",
        steps = {
            { text = "Optional introductory quest:", kind = "guide", mapID = 1428, x = 0.6600, y = 0.2200 },
        },
        pins = {
            { mapID = 1428, x = 0.6600, y = 0.2200, label = "Yuka Screwspigot — Burning Steppes", kind = "start" },
        },
    },
    [4141] = {
        pickup = "Muigin, Un'Goro Crater",
        turnin = "Muigin, Un'Goro Crater",
        pins = {
            { mapID = 1449, x = 0.4300, y = 0.0940, label = "Muigin — Un'Goro Crater", kind = "location" },
        },
    },
    [4142] = {
        pickup = "Muigin, Un'Goro Crater",
        turnin = "Gregan Brewspewer, Feralas",
        pins = {
            { mapID = 1449, x = 0.4300, y = 0.0940, label = "Muigin — Un'Goro Crater", kind = "location" },
        },
    },
    [4143] = {
        name = "Haze of Evil",
        pickup = "Gregan Brewspewer, Twin Colossals, Feralas",
        turnin = "Muigin, Marshal's Refuge, Un'Goro Crater",
        summary = "Atal'ai Haze drops from the temple's worms, lurkers and oozes.",
        steps = {
            { text = "Prereq chain (2): Muigin and Larion -> A Visit to Gregan", kind = "quest" },
        },
        pins = {
            { mapID = 1444, x = 0.4500, y = 0.2540, label = "Gregan Brewspewer — Feralas", kind = "start" },
        },
    },
    [4145] = {
        pickup = "Larion, Un'Goro Crater",
        turnin = "Larion, Un'Goro Crater",
        pins = {
            { mapID = 1449, x = 0.4540, y = 0.0860, label = "Larion — Un'Goro Crater", kind = "location" },
        },
    },
    [4146] = {
        name = "Zapper Fuel",
        pickup = "Liv Rizzlefix, Ratchet, The Barrens",
        turnin = "Larion, Marshal's Refuge, Un'Goro Crater",
        summary = "Atal'ai Haze drops from the temple's worms, lurkers and oozes.",
        steps = {
            { text = "Prereq chain (2): Larion and Muigin -> Marvon's Workshop", kind = "quest" },
        },
        pins = {
            { mapID = 1413, x = 0.6240, y = 0.3860, label = "Liv Rizzlefix — The Barrens", kind = "start" },
        },
    },
    [4147] = {
        pickup = "Larion, Un'Goro Crater",
        turnin = "Liv Rizzlefix, The Barrens",
        pins = {
            { mapID = 1449, x = 0.4540, y = 0.0860, label = "Larion — Un'Goro Crater", kind = "location" },
        },
    },
    [4182] = {
        pickup = "Helendis Riverhorn, Burning Steppes",
        turnin = "Helendis Riverhorn, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.8540, y = 0.6880, label = "Helendis Riverhorn — Burning Steppes", kind = "location" },
        },
    },
    [4183] = {
        pickup = "Helendis Riverhorn, Burning Steppes",
        turnin = "Magistrate Solomon, Redridge Mountains",
        pins = {
            { mapID = 1428, x = 0.8540, y = 0.6880, label = "Helendis Riverhorn — Burning Steppes", kind = "location" },
        },
    },
    [4184] = {
        pickup = "Magistrate Solomon, Redridge Mountains",
        turnin = "Highlord Bolvar Fordragon, Stormwind",
        pins = {
            { mapID = 1433, x = 0.2980, y = 0.4460, label = "Magistrate Solomon — Redridge Mountains", kind = "location" },
        },
    },
    [4185] = {
        pickup = "Highlord Bolvar Fordragon, Stormwind",
        turnin = "Highlord Bolvar Fordragon, Stormwind",
        pins = {
            { mapID = 1453, x = 0.8020, y = 0.3830, label = "Highlord Bolvar Fordragon — Stormwind", kind = "location" },
        },
    },
    [4186] = {
        pickup = "Highlord Bolvar Fordragon, Stormwind",
        turnin = "Magistrate Solomon, Redridge Mountains",
        pins = {
            { mapID = 1453, x = 0.8020, y = 0.3830, label = "Highlord Bolvar Fordragon — Stormwind", kind = "location" },
        },
    },
    [4201] = {
        name = "The Love Potion",
        pickup = "Mistress Nagmara, Blackrock Depths",
        turnin = "Mistress Nagmara, Blackrock Depths",
        summary = "Gromsblood, Giant Silver Veins (Azshara cliff giants) and the vial filled at Golakka Hot Springs in Un'Goro. Opens a peaceful way through the bar on later visits.",
        steps = {
            { text = "Gromsblood, Giant Silver Veins (Azshara cliff giants) and the vial filled at Golakka Hot Springs in Un'Goro. Opens a peaceful way through the bar on later visits.", kind = "guide" },
        },
    },
    [4223] = {
        pickup = "Magistrate Solomon, Redridge Mountains",
        turnin = "Marshal Maxwell, Burning Steppes",
        pins = {
            { mapID = 1433, x = 0.2980, y = 0.4460, label = "Magistrate Solomon — Redridge Mountains", kind = "location" },
        },
    },
    [4224] = {
        pickup = "Marshal Maxwell, Burning Steppes",
        turnin = "Marshal Maxwell, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.8460, y = 0.6880, label = "Marshal Maxwell — Burning Steppes", kind = "location" },
        },
    },
    [4241] = {
        pickup = "Marshal Maxwell, Burning Steppes",
        turnin = "Marshal Windsor",
        pins = {
            { mapID = 1428, x = 0.8460, y = 0.6880, label = "Marshal Maxwell — Burning Steppes", kind = "location" },
        },
    },
    [4262] = {
        pickup = "Jalinda Sprig, Burning Steppes",
        turnin = "Jalinda Sprig, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.8540, y = 0.7000, label = "Jalinda Sprig — Burning Steppes", kind = "location" },
        },
    },
    [4263] = {
        name = "Incendius!",
        pickup = "Jalinda Sprig, Morgan's Vigil, Burning Steppes",
        turnin = "Jalinda Sprig, Morgan's Vigil, Burning Steppes",
        summary = "Kill Lord Incendius at the Black Anvil inside BRD.",
        steps = {
            { text = "Prereq chain (1): Overmaster Pyron", kind = "quest" },
        },
        pins = {
            { mapID = 1428, x = 0.8540, y = 0.7000, label = "Jalinda Sprig — Burning Steppes", kind = "start" },
        },
    },
    [4264] = {
        pickup = "A Crumpled Up Note (drops from Dark Iron dwarves)",
        turnin = "Marshal Windsor",
        steps = {
            { text = "Start with [A Crumpled Up Note] (Drops from Dark Iron dwarves in Blackrock Depths once Abandoned Hope is turned in)", kind = "starter", itemID = 11446, itemName = "A Crumpled Up Note" },
        },
        items = {
            { id = 11446, name = "A Crumpled Up Note", role = "starter", source = "Drops from Dark Iron dwarves in Blackrock Depths once Abandoned Hope is turned in" },
        },
    },
    [4286] = {
        name = "The Good Stuff",
        pickup = "Oralius, Morgan's Vigil, Burning Steppes",
        turnin = "Oralius, Morgan's Vigil, Burning Steppes",
        summary = "Dark Iron Fanny Packs drop from Dark Iron dwarves in BRD.",
        steps = {
            { text = "Dark Iron Fanny Packs drop from Dark Iron dwarves in BRD.", kind = "guide", mapID = 1428, x = 0.8440, y = 0.6840 },
        },
        pins = {
            { mapID = 1428, x = 0.8440, y = 0.6840, label = "Oralius — Burning Steppes", kind = "start" },
        },
    },
    [4322] = {
        name = "Jail Break!",
        pickup = "Marshal Windsor, Blackrock Depths",
        turnin = "Marshal Maxwell, Morgan's Vigil, Burning Steppes",
        summary = "Escort Marshal Windsor through the prison. Clear the patrols first and have everyone ready before you start.",
        steps = {
            { text = "Prereq chain (11): Dragonkin Menace -> The True Masters -> The True Masters (+8 more)", kind = "quest" },
        },
    },
    [4324] = {
        name = "Yuka Screwspigot",
        pickup = "Yorba Screwspigot, Steamwheedle Port, Tanaris",
        turnin = "Yuka Screwspigot, Flame Crest, Burning Steppes",
        summary = "Introductory step leading to Ribbly Screwspigot.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Ribbly Screwspigot.", kind = "guide", mapID = 1446, x = 0.6700, y = 0.2400 },
        },
        pins = {
            { mapID = 1446, x = 0.6700, y = 0.2400, label = "Yorba Screwspigot — Tanaris", kind = "start", detail = "Yorba Screwspigot: Steamwheedle Port, Tanaris" },
        },
    },
    [4341] = {
        pickup = "King Magni Bronzebeard, Ironforge",
        turnin = "Kharan Mighthammer",
        pins = {
            { mapID = 1455, x = 0.3940, y = 0.5580, label = "King Magni Bronzebeard — Ironforge", kind = "location" },
        },
    },
    [4362] = {
        name = "The Fate of the Kingdom",
        pickup = "King Magni Bronzebeard, Ironforge",
        turnin = "Princess Moira Bronzebeard, Blackrock Depths",
        summary = "Keep Princess Moira alive and speak to her after Emperor Thaurissan dies. Her The Princess's Surprise sends you back to Magni for the reward.",
        steps = {
            { text = "Prereq chain (5): The Smoldering Ruins of Thaurissan -> The Smoldering Ruins of Thaurissan -> Kharan Mighthammer (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1455, x = 0.3940, y = 0.5580, label = "King Magni Bronzebeard — Ironforge", kind = "start" },
        },
    },
    [4701] = {
        name = "Put Her Down",
        pickup = "Helendis Riverhorn, Morgan's Vigil, Burning Steppes",
        turnin = "Helendis Riverhorn, Morgan's Vigil, Burning Steppes",
        summary = "Kill Halycon, the worg den mother. Be ready for Gizrul the Slavener, who comes for you right after.",
        steps = {
            { text = "Kill Halycon, the worg den mother. Be ready for Gizrul the Slavener, who comes for you right after.", kind = "guide", mapID = 1428, x = 0.8540, y = 0.6880 },
        },
        pins = {
            { mapID = 1428, x = 0.8540, y = 0.6880, label = "Helendis Riverhorn — Burning Steppes", kind = "start" },
        },
    },
    [4724] = {
        name = "The Pack Mistress",
        pickup = "Galamav the Marksman, Kargath, Badlands",
        turnin = "Galamav the Marksman, Kargath, Badlands",
        summary = "Kill Halycon, the worg den mother. Be ready for Gizrul the Slavener, who comes for you right after.",
        steps = {
            { text = "Kill Halycon, the worg den mother. Be ready for Gizrul the Slavener, who comes for you right after.", kind = "guide", mapID = 1418, x = 0.0580, y = 0.4740 },
        },
        pins = {
            { mapID = 1418, x = 0.0580, y = 0.4740, label = "Galamav the Marksman — Badlands", kind = "start" },
        },
    },
    [4726] = {
        pickup = "Tinkee Steamboil, Burning Steppes",
        turnin = "Tinkee Steamboil, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.6520, y = 0.2380, label = "Tinkee Steamboil — Burning Steppes", kind = "location" },
        },
    },
    [4729] = {
        name = "Kibler's Exotic Pets",
        pickup = "Kibler, Flame Crest, Burning Steppes",
        turnin = "Kibler, Flame Crest, Burning Steppes",
        summary = "Use the supplied cage on a Bloodaxe Worg Pup in the worg area.",
        steps = {
            { text = "Use the supplied cage on a Bloodaxe Worg Pup in the worg area.", kind = "guide", mapID = 1428, x = 0.6580, y = 0.2200 },
        },
        pins = {
            { mapID = 1428, x = 0.6580, y = 0.2200, label = "Kibler — Burning Steppes", kind = "start" },
        },
    },
    [4734] = {
        pickup = "Tinkee Steamboil, Burning Steppes",
        turnin = "Tinkee Steamboil, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.6520, y = 0.2380, label = "Tinkee Steamboil — Burning Steppes", kind = "location" },
        },
    },
    [4735] = {
        name = "Egg Collection",
        pickup = "Tinkee Steamboil, Flame Crest, Burning Steppes",
        turnin = "Tinkee Steamboil, Flame Crest, Burning Steppes",
        summary = "Using the module on the eggs in the Rookery can hatch whelps.",
        steps = {
            { text = "Prereq chain (6): Broodling Essence -> Felnok Steelspring -> Chillwind Horns (+3 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1428, x = 0.6520, y = 0.2380, label = "Tinkee Steamboil — Burning Steppes", kind = "start" },
        },
    },
    [4742] = {
        name = "Seal of Ascension",
        pickup = "Vaelan (Scarshield Infiltrator), Lower Blackrock Spire",
        turnin = "Vaelan (Scarshield Infiltrator), Lower Blackrock Spire",
        steps = {
            { text = "Get [Gemstone of Spirestone]: Dropped by Highlord Omokk, Lower Blackrock Spire", kind = "item", itemID = 12336, itemName = "Gemstone of Spirestone" },
            { text = "Get [Gemstone of Smolderthorn]: Dropped by War Master Voone, Lower Blackrock Spire", kind = "item", itemID = 12335, itemName = "Gemstone of Smolderthorn" },
            { text = "Get [Gemstone of Bloodaxe]: Dropped by Overlord Wyrmthalak, Lower Blackrock Spire", kind = "item", itemID = 12337, itemName = "Gemstone of Bloodaxe" },
            { text = "Get [Unadorned Seal of Ascension]: Random drop from Blackrock Spire trash", kind = "item", itemID = 12219, itemName = "Unadorned Seal of Ascension" },
            { text = "Turn in: Vaelan (Scarshield Infiltrator), Lower Blackrock Spire", kind = "turnin" },
        },
        items = {
            { id = 12336, name = "Gemstone of Spirestone", role = "required", source = "Dropped by Highlord Omokk, Lower Blackrock Spire" },
            { id = 12335, name = "Gemstone of Smolderthorn", role = "required", source = "Dropped by War Master Voone, Lower Blackrock Spire" },
            { id = 12337, name = "Gemstone of Bloodaxe", role = "required", source = "Dropped by Overlord Wyrmthalak, Lower Blackrock Spire" },
            { id = 12219, name = "Unadorned Seal of Ascension", role = "required", source = "Random drop from Blackrock Spire trash" },
        },
    },
    [4743] = {
        name = "Seal of Ascension",
        pickup = "Vaelan, Lower Blackrock Spire",
        turnin = "Vaelan, Lower Blackrock Spire",
        summary = "Take the Unforged Seal and the Orb of Draconic Energy to Emberstrife in the Wyrmbog, Dustwallow Marsh. The forged seal opens the UBRS door.",
        steps = {
            { text = "Prereq chain (1): Seal of Ascension", kind = "quest" },
        },
    },
    [4764] = {
        name = "Doomrigger's Clasp",
        pickup = "Mayara Brightwing, Morgan's Vigil, Burning Steppes",
        turnin = "Mayara Brightwing, Morgan's Vigil, Burning Steppes",
        summary = "Doomrigger's Coffer is in the Rookery. Then take Delivery to Ridgewell to Count Remington Ridgewell in Stormwind Keep for the reward.  Optional introductory quest:",
        steps = {
            { text = "Doomrigger's Coffer is in the Rookery. Then take Delivery to Ridgewell to Count Remington Ridgewell in Stormwind Keep for the reward.  Optional introductory quest:", kind = "guide", mapID = 1428, x = 0.8480, y = 0.6900 },
        },
        pins = {
            { mapID = 1428, x = 0.8480, y = 0.6900, label = "Mayara Brightwing — Burning Steppes", kind = "start" },
        },
    },
    [4766] = {
        name = "Mayara Brightwing",
        pickup = "Count Remington Ridgewell, Stormwind Keep",
        turnin = "Mayara Brightwing, Morgan's Vigil, Burning Steppes",
        summary = "Introductory step leading to Doomrigger's Clasp.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Doomrigger's Clasp.", kind = "guide", mapID = 1453, x = 0.7690, y = 0.4780 },
        },
        pins = {
            { mapID = 1453, x = 0.7690, y = 0.4780, label = "Count Remington Ridgewell — Stormwind Keep", kind = "start", detail = "Count Remington Ridgewell: Stormwind Keep" },
        },
    },
    [4768] = {
        name = "The Darkstone Tablet",
        pickup = "Shadowmage Vivian Lagrave, Kargath, Badlands",
        turnin = "Shadowmage Vivian Lagrave, Kargath, Badlands",
        summary = "The Darkstone Tablet lies on the ground in the Rookery.  Optional introductory quest:",
        steps = {
            { text = "The Darkstone Tablet lies on the ground in the Rookery.  Optional introductory quest:", kind = "guide", mapID = 1418, x = 0.0300, y = 0.4760 },
        },
        pins = {
            { mapID = 1418, x = 0.0300, y = 0.4760, label = "Shadowmage Vivian Lagrave — Badlands", kind = "start" },
        },
    },
    [4769] = {
        name = "Vivian Lagrave and the Darkstone Tablet",
        pickup = "Apothecary Zinge, The Apothecarium, Undercity",
        turnin = "Shadowmage Vivian Lagrave, Kargath, Badlands",
        summary = "Introductory step leading to The Darkstone Tablet.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to The Darkstone Tablet.", kind = "guide", mapID = 1458, x = 0.5010, y = 0.6800 },
        },
        pins = {
            { mapID = 1458, x = 0.5010, y = 0.6800, label = "Apothecary Zinge — Undercity", kind = "start", detail = "Apothecary Zinge: The Apothecarium, Undercity" },
        },
    },
    [4771] = {
        name = "Dawn's Gambit",
        pickup = "Betina Bigglezink, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Betina Bigglezink, Light's Hope Chapel, Eastern Plaguelands",
        summary = "Use Dawn's Gambit in the Viewing Room and defeat Vectus.",
        steps = {
            { text = "Prereq chain (9): Broodling Essence -> Felnok Steelspring -> Chillwind Horns (+6 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1423, x = 0.7370, y = 0.5050, label = "Betina Bigglezink — Eastern Plaguelands", kind = "start" },
        },
    },
    [4787] = {
        pickup = "Yeh'kinya, Tanaris",
        turnin = "Yeh'kinya, Tanaris",
        pins = {
            { mapID = 1446, x = 0.6700, y = 0.2240, label = "Yeh'kinya — Tanaris", kind = "location" },
        },
    },
    [4788] = {
        name = "The Final Tablets",
        pickup = "Prospector Ironboot, Steamwheedle Port, Tanaris",
        turnin = "Prospector Ironboot, Steamwheedle Port, Tanaris",
        summary = "The fifth and sixth Mosh'aru tablets are in the Smolderthorn troll area. Continues with Confront Yeh'kinya and The Hand of Rastakhan.",
        steps = {
            { text = "Prereq chain (5): Screecher Spirits -> The Prophecy of Mosh'aru -> The Ancient Egg (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1446, x = 0.6680, y = 0.2400, label = "Prospector Ironboot — Tanaris", kind = "start" },
        },
    },
    [4808] = {
        pickup = "Tinkee Steamboil, Burning Steppes",
        turnin = "Felnok Steelspring, Winterspring",
        pins = {
            { mapID = 1428, x = 0.6520, y = 0.2380, label = "Tinkee Steamboil — Burning Steppes", kind = "location" },
        },
    },
    [4809] = {
        pickup = "Felnok Steelspring, Winterspring",
        turnin = "Felnok Steelspring, Winterspring",
        pins = {
            { mapID = 1452, x = 0.6140, y = 0.3840, label = "Felnok Steelspring — Winterspring", kind = "location" },
        },
    },
    [4810] = {
        pickup = "Felnok Steelspring, Winterspring",
        turnin = "Tinkee Steamboil, Burning Steppes",
        pins = {
            { mapID = 1452, x = 0.6140, y = 0.3840, label = "Felnok Steelspring — Winterspring", kind = "location" },
        },
    },
    [4862] = {
        name = "En-Ay-Es-Tee-Why",
        pickup = "Kibler, Flame Crest, Burning Steppes",
        turnin = "Kibler, Flame Crest, Burning Steppes",
        summary = "Spire Spider Eggs are in the spider tunnels.",
        steps = {
            { text = "Spire Spider Eggs are in the spider tunnels.", kind = "guide", mapID = 1428, x = 0.6580, y = 0.2200 },
        },
        pins = {
            { mapID = 1428, x = 0.6580, y = 0.2200, label = "Kibler — Burning Steppes", kind = "start" },
        },
    },
    [4866] = {
        name = "Mother's Milk",
        pickup = "Ragged John, Flame Crest, Burning Steppes",
        turnin = "Ragged John, Flame Crest, Burning Steppes",
        summary = "Get poisoned by Mother Smolderweb and reach Ragged John while still poisoned. Don't let anyone cleanse it.",
        steps = {
            { text = "Get poisoned by Mother Smolderweb and reach Ragged John while still poisoned. Don't let anyone cleanse it.", kind = "guide", mapID = 1428, x = 0.6500, y = 0.2360 },
        },
        pins = {
            { mapID = 1428, x = 0.6500, y = 0.2360, label = "Ragged John — Burning Steppes", kind = "start" },
        },
    },
    [4867] = {
        name = "Urok Doomhowl",
        pickup = "Warosh, Lower Blackrock Spire",
        turnin = "Warosh, Lower Blackrock Spire",
        summary = "Bring Highlord Omokk's Head and a Roughshod Pike to Urok's Tribute Pile beyond the spiders to start the waves.",
        steps = {
            { text = "Bring Highlord Omokk's Head and a Roughshod Pike to Urok's Tribute Pile beyond the spiders to start the waves.", kind = "guide" },
        },
    },
    [4903] = {
        name = "Warlord's Command",
        pickup = "Warlord Goretooth, Kargath, Badlands",
        turnin = "Warlord Goretooth, Kargath, Badlands",
        summary = "Talk to Goretooth to receive his Command item and click it to start the quest. The Important Blackrock Documents spawn near the three generals.",
        steps = {
            { text = "Prereq chain (1): Blood and Thunder", kind = "quest" },
        },
        pins = {
            { mapID = 1418, x = 0.0580, y = 0.4740, label = "Warlord Goretooth — Badlands", kind = "start" },
        },
    },
    [4907] = {
        pickup = "Felnok Steelspring, Winterspring",
        turnin = "Tinkee Steamboil, Burning Steppes",
        pins = {
            { mapID = 1452, x = 0.6140, y = 0.3840, label = "Felnok Steelspring — Winterspring", kind = "location" },
        },
    },
    [4941] = {
        pickup = "Warlord Goretooth, Badlands",
        turnin = "Thrall, Orgrimmar",
        pins = {
            { mapID = 1418, x = 0.0580, y = 0.4740, label = "Warlord Goretooth — Badlands", kind = "location" },
        },
    },
    [4974] = {
        name = "For The Horde!",
        pickup = "Thrall, Orgrimmar",
        turnin = "Thrall, Orgrimmar",
        steps = {
            { text = "Prereq chain (3): Blood and Thunder -> Warlord's Command -> Eitrigg's Wisdom", kind = "quest" },
        },
        pins = {
            { mapID = 1454, x = 0.3200, y = 0.3780, label = "Thrall — Orgrimmar", kind = "location" },
        },
    },
    [4981] = {
        name = "Operative Bijou",
        pickup = "Lexlort, Badlands",
        turnin = "Bijou",
        pins = {
            { mapID = 1418, x = 0.0580, y = 0.4740, label = "Lexlort — Badlands", kind = "start" },
        },
    },
    [4982] = {
        name = "Bijou's Belongings",
        pickup = "Bijou, Lower Blackrock Spire",
        turnin = "Bijou, Lower Blackrock Spire",
        summary = "Then take Bijou's Reconnaissance Report to Lexlort in Kargath for the reward.",
        steps = {
            { text = "Then take Bijou's Reconnaissance Report to Lexlort in Kargath for the reward.", kind = "guide" },
        },
    },
    [5001] = {
        name = "Bijou's Belongings",
        pickup = "Bijou, Lower Blackrock Spire",
        turnin = "Bijou, Lower Blackrock Spire",
        summary = "Bijou hides in a recess beyond the early bridges. Her belongings spawn in one of several places around the troll and orc rooms.",
        steps = {
            { text = "Bijou hides in a recess beyond the early bridges. Her belongings spawn in one of several places around the troll and orc rooms.", kind = "guide" },
        },
    },
    [5047] = {
        name = "Finkle Einhorn, At Your Service!",
        pickup = "From The Beast's corpse, Upper Blackrock Spire",
        turnin = "Malyfous Darkhammer, Everlook, Winterspring",
        summary = "He appears from The Beast's corpse after the fight. Malyfous then offers the Pristine Hide of the Beast exchanges.",
        steps = {
            { text = "He appears from The Beast's corpse after the fight. Malyfous then offers the Pristine Hide of the Beast exchanges.", kind = "guide" },
        },
    },
    [5065] = {
        pickup = "Prospector Ironboot, Tanaris",
        turnin = "Prospector Ironboot, Tanaris",
        pins = {
            { mapID = 1446, x = 0.6680, y = 0.2400, label = "Prospector Ironboot — Tanaris", kind = "location" },
        },
    },
    [5081] = {
        name = "Maxwell's Mission",
        pickup = "Marshal Maxwell, Morgan's Vigil, Burning Steppes",
        turnin = "Marshal Maxwell, Morgan's Vigil, Burning Steppes",
        steps = {
            { text = "Prereq chain (2): Bijou's Belongings -> Message to Maxwell", kind = "quest" },
        },
        pins = {
            { mapID = 1428, x = 0.8460, y = 0.6880, label = "Marshal Maxwell — Burning Steppes", kind = "start" },
        },
    },
    [5089] = {
        name = "General Drakkisath's Command",
        pickup = "General Drakkisath's Command (drops from Overlord Wyrmthalak)",
        turnin = "Marshal Maxwell, Burning Steppes",
        summary = "Leads to General Drakkisath's Demise in Upper Blackrock Spire.",
        steps = {
            { text = "Start with [General Drakkisath's Command] (Dropped by Overlord Wyrmthalak in Lower Blackrock Spire)", kind = "starter", itemID = 12780, itemName = "General Drakkisath's Command" },
        },
        items = {
            { id = 12780, name = "General Drakkisath's Command", role = "starter", source = "Dropped by Overlord Wyrmthalak in Lower Blackrock Spire" },
        },
    },
    [5102] = {
        name = "General Drakkisath's Demise",
        pickup = "Marshal Maxwell, Morgan's Vigil, Burning Steppes",
        turnin = "Marshal Maxwell, Morgan's Vigil, Burning Steppes",
        summary = "Kill General Drakkisath at the end of UBRS.",
        steps = {
            { text = "Prereq chain (1): General Drakkisath's Command", kind = "quest" },
        },
        pins = {
            { mapID = 1428, x = 0.8460, y = 0.6880, label = "Marshal Maxwell — Burning Steppes", kind = "start" },
        },
    },
    [5122] = {
        name = "The Medallion of Faith",
        pickup = "Aurius, Stratholme",
        turnin = "Aurius, Stratholme",
        summary = "Malor's Strongbox in the Scarlet Bastion holds the medallion. Give it to Aurius in the chapel before fighting the Baron.",
        steps = {
            { text = "Malor's Strongbox in the Scarlet Bastion holds the medallion. Give it to Aurius in the chapel before fighting the Baron.", kind = "guide" },
        },
    },
    [5125] = {
        name = "Aurius' Reckoning",
        pickup = "Aurius, Stratholme",
        turnin = "Aurius, Stratholme",
        summary = "Give Aurius the Medallion of Faith before the Baron fight; speak to him after Baron Rivendare dies.",
        steps = {
            { text = "Prereq chain (1): The Medallion of Faith", kind = "quest" },
        },
    },
    [5127] = {
        name = "The Demon Forge",
        pickup = "Lorax, Winterspring",
        turnin = "Lorax, Winterspring",
        summary = "Blacksmithing 270 (Armorsmith). Use the Blood Stained Pike on Goraluk's corpse and loot the Unforged Rune Covered Breastplate nearby.",
        steps = {
            { text = "Blacksmithing 270 (Armorsmith). Use the Blood Stained Pike on Goraluk's corpse and loot the Unforged Rune Covered Breastplate nearby.", kind = "guide", mapID = 1452, x = 0.6380, y = 0.7380 },
        },
        pins = {
            { mapID = 1452, x = 0.6380, y = 0.7380, label = "Lorax — Winterspring", kind = "start" },
        },
    },
    [5160] = {
        name = "The Matron Protectorate",
        pickup = "Awbee, Upper Blackrock Spire",
        turnin = "Haleh, Mazthoril, Winterspring",
        summary = "Awbee is the wounded blue dragon near the arena route after Rend. Use the rune deep in the Mazthoril cave to reach Haleh.",
        steps = {
            { text = "Awbee is the wounded blue dragon near the arena route after Rend. Use the rune deep in the Mazthoril cave to reach Haleh.", kind = "guide" },
        },
    },
    [5212] = {
        name = "The Flesh Does Not Lie",
        pickup = "Betina Bigglezink, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Betina Bigglezink, Light's Hope Chapel, Eastern Plaguelands",
        summary = "Any undead in Stratholme can drop Plagued Flesh Samples.",
        steps = {
            { text = "Any undead in Stratholme can drop Plagued Flesh Samples.", kind = "guide", mapID = 1423, x = 0.7370, y = 0.5050 },
        },
        pins = {
            { mapID = 1423, x = 0.7370, y = 0.5050, label = "Betina Bigglezink — Eastern Plaguelands", kind = "start" },
        },
    },
    [5213] = {
        name = "The Active Agent",
        pickup = "Betina Bigglezink, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Betina Bigglezink, Light's Hope Chapel, Eastern Plaguelands",
        steps = {
            { text = "Prereq chain (1): The Flesh Does Not Lie", kind = "quest" },
        },
        pins = {
            { mapID = 1423, x = 0.7370, y = 0.5050, label = "Betina Bigglezink — Eastern Plaguelands", kind = "start" },
        },
    },
    [5214] = {
        name = "The Great Fras Siabi",
        pickup = "Smokey LaRue, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Smokey LaRue, Light's Hope Chapel, Eastern Plaguelands",
        summary = "Newer Classic records call him Ezra Grimm. Clear the smoke shop, touch the tobacco box and kill the shopkeeper.",
        steps = {
            { text = "Newer Classic records call him Ezra Grimm. Clear the smoke shop, touch the tobacco box and kill the shopkeeper.", kind = "guide", mapID = 1423, x = 0.7280, y = 0.4920 },
        },
        pins = {
            { mapID = 1423, x = 0.7280, y = 0.4920, label = "Smokey LaRue — Eastern Plaguelands", kind = "start" },
        },
    },
    [5243] = {
        name = "Houses of the Holy",
        pickup = "Leonid Barthalomew the Revered, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Leonid Barthalomew the Revered, Light's Hope Chapel, Eastern Plaguelands",
        summary = "Collect 5 Stratholme Holy Water from the supply crates in the streets; some crates spawn enemies.",
        steps = {
            { text = "Collect 5 Stratholme Holy Water from the supply crates in the streets; some crates spawn enemies.", kind = "guide", mapID = 1423, x = 0.7390, y = 0.4900 },
        },
        pins = {
            { mapID = 1423, x = 0.7390, y = 0.4900, label = "Leonid Barthalomew the Revered — Eastern Plaguelands", kind = "start" },
        },
    },
    [5244] = {
        pickup = "Wynd Nightchaser, Winterspring",
        turnin = "Jaron Stoneshaper, Winterspring",
        pins = {
            { mapID = 1452, x = 0.5200, y = 0.3020, label = "Wynd Nightchaser — Winterspring", kind = "location" },
        },
    },
    [5245] = {
        pickup = "Jaron Stoneshaper, Winterspring",
        turnin = "Aurora Skycaller, Eastern Plaguelands",
        pins = {
            { mapID = 1452, x = 0.5200, y = 0.3040, label = "Jaron Stoneshaper — Winterspring", kind = "location" },
        },
    },
    [5246] = {
        pickup = "Aurora Skycaller, Eastern Plaguelands",
        turnin = "Aurora Skycaller, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.4750, y = 0.1680, label = "Aurora Skycaller — Eastern Plaguelands", kind = "location" },
        },
    },
    [5247] = {
        name = "Fragments of the Past",
        pickup = "Aurora Skycaller, Northpass Tower, Eastern Plaguelands",
        turnin = "Aurora Skycaller, Northpass Tower, Eastern Plaguelands",
        summary = "Fill her vial at the dire pool along Eldreth Row in Dire Maul West; also bring 1 Enchanted Thorium Bar and 5 Crystal Restore.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (3): The Ruins of Kel'Theril -> Troubled Spirits of Kel'Theril -> Fragments of the Past", kind = "quest" },
        },
        pins = {
            { mapID = 1423, x = 0.4750, y = 0.1680, label = "Aurora Skycaller — Eastern Plaguelands", kind = "start" },
        },
    },
    [5250] = {
        name = "Starfall",
        pickup = "Daryn Lightwind, Rut'theran Village, Teldrassil",
        turnin = "Wynd Nightchaser, Starfall Village, Winterspring",
        summary = "Introductory step leading to Fragments of the Past.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Fragments of the Past.", kind = "guide", mapID = 1438, x = 0.5540, y = 0.9220 },
        },
        pins = {
            { mapID = 1438, x = 0.5540, y = 0.9220, label = "Daryn Lightwind — Teldrassil", kind = "start", detail = "Daryn Lightwind: Rut'theran Village, Teldrassil" },
        },
    },
    [5251] = {
        name = "The Archivist",
        pickup = "Duke Nicholas Zverenhoff, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Duke Nicholas Zverenhoff, Light's Hope Chapel, Eastern Plaguelands",
        summary = "Kill Archivist Galford in the Scarlet Bastion and burn the archives.",
        steps = {
            { text = "Kill Archivist Galford in the Scarlet Bastion and burn the archives.", kind = "guide", mapID = 1423, x = 0.7370, y = 0.5080 },
        },
        pins = {
            { mapID = 1423, x = 0.7370, y = 0.5080, label = "Duke Nicholas Zverenhoff — Eastern Plaguelands", kind = "location" },
        },
    },
    [5262] = {
        name = "The Truth Comes Crashing Down",
        pickup = "Head of Balnazzar (drops from Balnazzar)",
        turnin = "Duke Nicholas Zverenhoff, Light's Hope Chapel, Eastern Plaguelands",
        summary = "Hand in The Archivist first, or Balnazzar's head will not start this quest.",
        steps = {
            { text = "Start with [Head of Balnazzar] (Dropped by Balnazzar (hand in The Archivist first))", kind = "starter", itemID = 13250, itemName = "Head of Balnazzar" },
        },
        items = {
            { id = 13250, name = "Head of Balnazzar", role = "starter", source = "Dropped by Balnazzar (hand in The Archivist first)" },
        },
    },
    [5263] = {
        name = "Above and Beyond",
        pickup = "Duke Nicholas Zverenhoff, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Duke Nicholas Zverenhoff, Light's Hope Chapel, Eastern Plaguelands",
        summary = "Then Lord Maxwell Tyrosus and The Argent Hold, in Light's Hope Chapel, give the weapon or shield reward.",
        steps = {
            { text = "Prereq chain (2): The Archivist -> The Truth Comes Crashing Down", kind = "quest" },
        },
        pins = {
            { mapID = 1423, x = 0.7370, y = 0.5080, label = "Duke Nicholas Zverenhoff — Eastern Plaguelands", kind = "start" },
        },
    },
    [5281] = {
        name = "The Restless Souls",
        pickup = "Caretaker Alen, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Egan, Terrordale, Eastern Plaguelands",
        summary = "Introductory step leading to The Restless Souls.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to The Restless Souls.", kind = "guide", mapID = 1423, x = 0.7180, y = 0.5440 },
        },
        pins = {
            { mapID = 1423, x = 0.7180, y = 0.5440, label = "Caretaker Alen — Eastern Plaguelands", kind = "start" },
        },
    },
    [5282] = {
        name = "The Restless Souls",
        pickup = "Egan, Terrordale, Eastern Plaguelands",
        turnin = "Egan, Terrordale, Eastern Plaguelands",
        summary = "Optional introductory quest:",
        steps = {
            { text = "Optional introductory quest:", kind = "guide", mapID = 1423, x = 0.1090, y = 0.2720 },
        },
        pins = {
            { mapID = 1423, x = 0.1090, y = 0.2720, label = "Egan — Eastern Plaguelands", kind = "start" },
        },
    },
    [5341] = {
        name = "Barov Family Fortune",
        pickup = "Alexi Barov, The Bulwark, Tirisfal Glades",
        turnin = "Alexi Barov, The Bulwark, Tirisfal Glades",
        summary = "The four deeds: Southshore in the first large chamber, Tarren Mill before the hatchlings, Brill by Ras Frostwhisper, Caer Darrow by Lord Alexei Barov. The follow-up The Last Barov sends you to kill the rival brother.",
        steps = {
            { text = "The four deeds: Southshore in the first large chamber, Tarren Mill before the hatchlings, Brill by Ras Frostwhisper, Caer Darrow by Lord Alexei Barov. The follow-up The Last Barov sends you to kill the rival brother.", kind = "guide", mapID = 1420, x = 0.8300, y = 0.7140 },
        },
        pins = {
            { mapID = 1420, x = 0.8300, y = 0.7140, label = "Alexi Barov — Tirisfal Glades", kind = "start" },
        },
    },
    [5343] = {
        name = "Barov Family Fortune",
        pickup = "Weldon Barov, Chillwind Camp, Western Plaguelands",
        turnin = "Weldon Barov, Chillwind Camp, Western Plaguelands",
        summary = "The four deeds: Southshore in the first large chamber, Tarren Mill before the hatchlings, Brill by Ras Frostwhisper, Caer Darrow by Lord Alexei Barov. The follow-up The Last Barov sends you to kill the rival brother.",
        steps = {
            { text = "The four deeds: Southshore in the first large chamber, Tarren Mill before the hatchlings, Brill by Ras Frostwhisper, Caer Darrow by Lord Alexei Barov. The follow-up The Last Barov sends you to kill the rival brother.", kind = "guide", mapID = 1422, x = 0.4340, y = 0.8340 },
        },
        pins = {
            { mapID = 1422, x = 0.4340, y = 0.8340, label = "Weldon Barov — Western Plaguelands", kind = "start" },
        },
    },
    [5382] = {
        name = "Doctor Theolen Krastinov, the Butcher",
        pickup = "Eva Sarkhoff, Caer Darrow, Western Plaguelands",
        turnin = "Eva Sarkhoff, Caer Darrow, Western Plaguelands",
        pins = {
            { mapID = 1422, x = 0.7020, y = 0.7380, label = "Eva Sarkhoff — Western Plaguelands", kind = "start" },
        },
    },
    [5384] = {
        name = "Kirtonos the Herald",
        pickup = "Eva Sarkhoff, Caer Darrow, Western Plaguelands",
        turnin = "Eva Sarkhoff, Caer Darrow, Western Plaguelands",
        summary = "Use the Blood of Innocents at the brazier on the Scholomance porch. Rewards the Spectral Essence.",
        steps = {
            { text = "Prereq chain (2): Doctor Theolen Krastinov, the Butcher -> Krastinov's Bag of Horrors", kind = "quest" },
        },
        pins = {
            { mapID = 1422, x = 0.7020, y = 0.7380, label = "Eva Sarkhoff — Western Plaguelands", kind = "start" },
        },
    },
    [5461] = {
        pickup = "Magistrate Marduke, Western Plaguelands",
        turnin = "Magistrate Marduke, Western Plaguelands",
        pins = {
            { mapID = 1422, x = 0.7040, y = 0.7400, label = "Magistrate Marduke — Western Plaguelands", kind = "location" },
        },
    },
    [5462] = {
        pickup = "Magistrate Marduke, Western Plaguelands",
        turnin = "Leonid Barthalomew the Revered, Eastern Plaguelands",
        pins = {
            { mapID = 1422, x = 0.7040, y = 0.7400, label = "Magistrate Marduke — Western Plaguelands", kind = "location" },
        },
    },
    [5463] = {
        name = "Menethil's Gift",
        pickup = "Leonid Barthalomew the Revered, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Menethil's Gift, Stratholme",
        summary = "After Baron Rivendare dies, use the glowing rune on the floor of his room, then take the follow-up back to Leonid.",
        steps = {
            { text = "Prereq chain (5): Doctor Theolen Krastinov, the Butcher -> Krastinov's Bag of Horrors -> Kirtonos the Herald (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1423, x = 0.7390, y = 0.4900, label = "Leonid Barthalomew the Revered — Eastern Plaguelands", kind = "location" },
        },
    },
    [5464] = {
        pickup = "Menethil's Gift",
        turnin = "Leonid Barthalomew the Revered, Eastern Plaguelands",
        steps = {
            { text = "Interact with: table: 00FB1E08", kind = "object" },
        },
    },
    [5465] = {
        pickup = "Leonid Barthalomew the Revered, Eastern Plaguelands",
        turnin = "Magistrate Marduke, Western Plaguelands",
        pins = {
            { mapID = 1423, x = 0.7390, y = 0.4900, label = "Leonid Barthalomew the Revered — Eastern Plaguelands", kind = "location" },
        },
    },
    [5466] = {
        name = "The Lich, Ras Frostwhisper",
        pickup = "Magistrate Marduke, Caer Darrow, Western Plaguelands",
        turnin = "Magistrate Marduke, Caer Darrow, Western Plaguelands",
        summary = "Use the Soulbound Keepsake on Ras Frostwhisper to make him human, then kill him and bring back his human head.",
        steps = {
            { text = "Prereq chain (8): Doctor Theolen Krastinov, the Butcher -> Krastinov's Bag of Horrors -> Kirtonos the Herald (+5 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1422, x = 0.7040, y = 0.7400, label = "Magistrate Marduke — Western Plaguelands", kind = "start" },
        },
    },
    [5515] = {
        name = "Krastinov's Bag of Horrors",
        pickup = "Eva Sarkhoff, Caer Darrow, Western Plaguelands",
        turnin = "Eva Sarkhoff, Caer Darrow, Western Plaguelands",
        summary = "The bag drops from Jandice Barov.",
        steps = {
            { text = "Prereq chain (1): Doctor Theolen Krastinov, the Butcher", kind = "quest" },
        },
        pins = {
            { mapID = 1422, x = 0.7020, y = 0.7380, label = "Eva Sarkhoff — Western Plaguelands", kind = "start" },
        },
    },
    [5518] = {
        name = "The Gordok Ogre Suit",
        pickup = "Knot Thimblejack, Dire Maul",
        turnin = "Knot Thimblejack, Dire Maul",
        summary = "Bring 4 Bolts of Runecloth, 8 Rugged Leather, 2 Rune Threads and 1 Ogre Tannin (basket on the upper level beyond Knot). Make any suits and learn the pattern before freeing Knot, because he leaves.",
        steps = {
            { text = "Bring 4 Bolts of Runecloth, 8 Rugged Leather, 2 Rune Threads and 1 Ogre Tannin (basket on the upper level beyond Knot). Make any suits and learn the pattern before freeing Knot, because he leaves.", kind = "guide" },
        },
    },
    [5522] = {
        pickup = "Tinkee Steamboil, Burning Steppes",
        turnin = "Leonid Barthalomew the Revered, Eastern Plaguelands",
        pins = {
            { mapID = 1428, x = 0.6520, y = 0.2380, label = "Tinkee Steamboil — Burning Steppes", kind = "location" },
        },
    },
    [5525] = {
        name = "Free Knot!",
        pickup = "Knot Thimblejack, Dire Maul",
        turnin = "Knot Thimblejack, Dire Maul",
        summary = "Get a Gordok Shackle Key from the North ogres and free Knot; his cache has loot.",
        steps = {
            { text = "Get a Gordok Shackle Key from the North ogres and free Knot; his cache has loot.", kind = "guide" },
        },
    },
    [5526] = {
        name = "Shards of the Felvine",
        pickup = "Rabine Saturna, Nighthaven, Moonglade",
        turnin = "Rabine Saturna, Nighthaven, Moonglade",
        summary = "Kill Alzzin the Wildshaper, pick up a Felvine Shard near the vine and seal it in the Reliquary of Purity.",
        steps = {
            { text = "Prereq chain (1): A Reliquary of Purity", kind = "quest" },
        },
        pins = {
            { mapID = 1450, x = 0.5160, y = 0.4440, label = "Rabine Saturna — Moonglade", kind = "start" },
        },
    },
    [5527] = {
        pickup = "Rabine Saturna, Moonglade",
        turnin = "Rabine Saturna, Moonglade",
        pins = {
            { mapID = 1450, x = 0.5160, y = 0.4440, label = "Rabine Saturna — Moonglade", kind = "location" },
        },
    },
    [5529] = {
        name = "Plagued Hatchlings",
        pickup = "Betina Bigglezink, Light's Hope Chapel, Eastern Plaguelands",
        turnin = "Betina Bigglezink, Light's Hope Chapel, Eastern Plaguelands",
        summary = "Kill 20 Plagued Hatchlings. After turning this in, hatchlings can drop Healthy Dragon Scales, which start a repeatable turn-in to Betina.",
        steps = {
            { text = "Kill 20 Plagued Hatchlings. After turning this in, hatchlings can drop Healthy Dragon Scales, which start a repeatable turn-in to Betina.", kind = "guide", mapID = 1423, x = 0.7370, y = 0.5050 },
        },
        pins = {
            { mapID = 1423, x = 0.7370, y = 0.5050, label = "Betina Bigglezink — Eastern Plaguelands", kind = "start" },
        },
    },
    [5531] = {
        pickup = "Leonid Barthalomew the Revered, Eastern Plaguelands",
        turnin = "Betina Bigglezink",
        pins = {
            { mapID = 1423, x = 0.7390, y = 0.4900, label = "Leonid Barthalomew the Revered — Eastern Plaguelands", kind = "location" },
        },
    },
    [5542] = {
        pickup = "Tirion Fordring, Eastern Plaguelands",
        turnin = "Tirion Fordring, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.0430, y = 0.3610, label = "Tirion Fordring — Eastern Plaguelands", kind = "location" },
        },
    },
    [5543] = {
        pickup = "Tirion Fordring, Eastern Plaguelands",
        turnin = "Tirion Fordring, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.0430, y = 0.3610, label = "Tirion Fordring — Eastern Plaguelands", kind = "location" },
        },
    },
    [5544] = {
        pickup = "Tirion Fordring, Eastern Plaguelands",
        turnin = "Tirion Fordring, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.0430, y = 0.3610, label = "Tirion Fordring — Eastern Plaguelands", kind = "location" },
        },
    },
    [5722] = {
        name = "Searching for the Lost Satchel",
        pickup = "Rahauro, Elder Rise, Thunder Bluff",
        turnin = "Maur Grimtotem's corpse inside Ragefire Chasm. From the first major three-way junction, take the right-hand tunnel, follow it uphill toward the dead end, then enter the small side room on the left. Interact with Maur's corpse there.",
        summary = "From the first major three-way junction, take the right-hand tunnel, follow it uphill toward the dead end, then enter the small side room on the left. Interact with Maur's corpse there.",
        steps = {
            { text = "From the first major three-way junction, take the right-hand tunnel, follow it uphill toward the dead end, then enter the small side room on the left. Interact with Maur's corpse there.", kind = "guide", mapID = 1456, x = 0.7040, y = 0.3220 },
        },
        pins = {
            { mapID = 1456, x = 0.7040, y = 0.3220, label = "Rahauro", kind = "start" },
            { mapID = 1456, x = 0.7010, y = 0.2950, label = "Rahauro", kind = "start" },
        },
    },
    [5723] = {
        name = "Testing an Enemy's Strength",
        pickup = "Rahauro, Elder Rise, Thunder Bluff",
        turnin = "Rahauro, Elder Rise, Thunder Bluff",
        pins = {
            { mapID = 1456, x = 0.7010, y = 0.2950, label = "Rahauro", kind = "start" },
        },
    },
    [5725] = {
        name = "The Power to Destroy...",
        pickup = "Varimathras, Royal Quarter, Undercity",
        turnin = "Varimathras, Royal Quarter, Undercity",
        pins = {
            { mapID = 1458, x = 0.5620, y = 0.9260, label = "Varimathras", kind = "start" },
        },
    },
    [5726] = {
        pickup = "Thrall, Valley of Wisdom, Orgrimmar",
        turnin = "Thrall, Valley of Wisdom, Orgrimmar",
        summary = "First required Hidden Enemies step for the Ragefire Chasm chain.",
        steps = {
            { text = "First required Hidden Enemies step for the Ragefire Chasm chain.", kind = "guide", mapID = 1454, x = 0.3200, y = 0.3780 },
        },
        pins = {
            { mapID = 1454, x = 0.3200, y = 0.3780, label = "Thrall — Orgrimmar", kind = "location", detail = "Start Hidden Enemies here" },
        },
    },
    [5727] = {
        pickup = "Thrall, Valley of Wisdom, Orgrimmar",
        turnin = "Thrall, Valley of Wisdom, Orgrimmar",
        summary = "Neeru is in the Cleft of Shadow near the Ragefire Chasm entrance.",
        steps = {
            { text = "Neeru is in the Cleft of Shadow near the Ragefire Chasm entrance.", kind = "guide", mapID = 1454, x = 0.3170, y = 0.3780 },
        },
        pins = {
            { mapID = 1454, x = 0.3170, y = 0.3780, label = "Thrall — Orgrimmar", kind = "start", detail = "Thrall: Grommash Hold, Orgrimmar" },
        },
    },
    [5728] = {
        name = "Hidden Enemies",
        pickup = "Thrall, Valley of Wisdom, Orgrimmar",
        turnin = "Thrall, Valley of Wisdom, Orgrimmar",
        summary = "Requires the earlier Hidden Enemies chain steps in Orgrimmar. The next Hidden Enemies step later offers:",
        steps = {
            { text = "Prereq chain (2): Hidden Enemies -> Hidden Enemies", kind = "quest" },
        },
        pins = {
            { mapID = 1454, x = 0.3200, y = 0.3780, label = "Thrall", kind = "start" },
        },
    },
    [5742] = {
        pickup = "Tirion Fordring, Eastern Plaguelands",
        turnin = "Tirion Fordring, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.0430, y = 0.3610, label = "Tirion Fordring — Eastern Plaguelands", kind = "location" },
        },
    },
    [5761] = {
        name = "Slaying the Beast",
        pickup = "Neeru Fireblade, Cleft of Shadow, Orgrimmar",
        turnin = "Neeru Fireblade, Cleft of Shadow, Orgrimmar",
        pins = {
            { mapID = 1454, x = 0.4960, y = 0.5060, label = "Neeru Fireblade", kind = "start" },
        },
    },
    [5781] = {
        pickup = "Tirion Fordring, Eastern Plaguelands",
        turnin = "Tirion Fordring, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.0430, y = 0.3610, label = "Tirion Fordring — Eastern Plaguelands", kind = "location" },
        },
    },
    [5845] = {
        pickup = "Tirion Fordring, Eastern Plaguelands",
        turnin = "Tirion Fordring, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.0430, y = 0.3610, label = "Tirion Fordring — Eastern Plaguelands", kind = "location" },
        },
    },
    [5846] = {
        pickup = "Tirion Fordring, Eastern Plaguelands",
        turnin = "Artist Renfray",
        pins = {
            { mapID = 1423, x = 0.0430, y = 0.3610, label = "Tirion Fordring — Eastern Plaguelands", kind = "location" },
        },
    },
    [5848] = {
        name = "Of Love and Family",
        pickup = "Artist Renfray, Caer Darrow, Western Plaguelands",
        turnin = "Tirion Fordring, Eastern Plaguelands",
        summary = "Take the painting hidden behind the twin-moons picture in Archivist Galford's room before you burn the archives.",
        steps = {
            { text = "Prereq chain (7): Demon Dogs -> Blood Tinged Skies -> Carrion Grubbage (+4 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1422, x = 0.6560, y = 0.7540, label = "Artist Renfray — Western Plaguelands", kind = "start" },
        },
    },
    [5961] = {
        name = "The Champion of the Banshee Queen",
        pickup = "Lady Sylvanas Windrunner, Royal Quarter, Undercity",
        turnin = "Nathanos Blightcaller, Marris Stead, Eastern Plaguelands",
        summary = "Introductory step leading to Ramstein.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Ramstein.", kind = "guide", mapID = 1458, x = 0.5800, y = 0.9160 },
        },
        pins = {
            { mapID = 1458, x = 0.5800, y = 0.9160, label = "Lady Sylvanas Windrunner — Undercity", kind = "start" },
        },
    },
    [6022] = {
        pickup = "Nathanos Blightcaller, Eastern Plaguelands",
        turnin = "Nathanos Blightcaller, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.2220, y = 0.6430, label = "Nathanos Blightcaller — Eastern Plaguelands", kind = "location" },
        },
    },
    [6042] = {
        pickup = "Nathanos Blightcaller, Eastern Plaguelands",
        turnin = "Nathanos Blightcaller, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.2220, y = 0.6430, label = "Nathanos Blightcaller — Eastern Plaguelands", kind = "location" },
        },
    },
    [6133] = {
        pickup = "Nathanos Blightcaller, Eastern Plaguelands",
        turnin = "Nathanos Blightcaller, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.2220, y = 0.6430, label = "Nathanos Blightcaller — Eastern Plaguelands", kind = "location" },
        },
    },
    [6135] = {
        pickup = "Nathanos Blightcaller, Eastern Plaguelands",
        turnin = "Nathanos Blightcaller, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.2220, y = 0.6430, label = "Nathanos Blightcaller — Eastern Plaguelands", kind = "location" },
        },
    },
    [6136] = {
        pickup = "Nathanos Blightcaller, Eastern Plaguelands",
        turnin = "Nathanos Blightcaller, Eastern Plaguelands",
        pins = {
            { mapID = 1423, x = 0.2220, y = 0.6430, label = "Nathanos Blightcaller — Eastern Plaguelands", kind = "location" },
        },
    },
    [6141] = {
        name = "Brother Anton",
        pickup = "Brother Crowley, Cathedral of Light, Stormwind",
        turnin = "Brother Anton, Nijel's Point, Desolace",
        summary = "Introductory step leading to In the Name of the Light.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to In the Name of the Light.", kind = "guide", mapID = 1453, x = 0.5260, y = 0.4320 },
        },
        pins = {
            { mapID = 1453, x = 0.5260, y = 0.4320, label = "Brother Crowley — Stormwind", kind = "start", detail = "Brother Crowley: Cathedral of Light, Stormwind" },
        },
    },
    [6163] = {
        name = "Ramstein",
        pickup = "Nathanos Blightcaller, Marris Stead, Eastern Plaguelands",
        turnin = "Nathanos Blightcaller, Marris Stead, Eastern Plaguelands",
        summary = "Optional introductory quest:",
        steps = {
            { text = "Prereq chain (5): The Ranger Lord's Behest -> Un-Life's Little Annoyances -> To Kill With Purpose (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1423, x = 0.2220, y = 0.6430, label = "Nathanos Blightcaller — Eastern Plaguelands", kind = "start" },
        },
    },
    [6402] = {
        pickup = "Marshal Maxwell, Burning Steppes",
        turnin = "Reginald Windsor, Elwynn Forest",
        pins = {
            { mapID = 1428, x = 0.8460, y = 0.6880, label = "Marshal Maxwell — Burning Steppes", kind = "location" },
        },
    },
    [6403] = {
        pickup = "Reginald Windsor, Elwynn Forest",
        turnin = "Highlord Bolvar Fordragon, Stormwind",
        pins = {
            { mapID = 1429, x = 0.3200, y = 0.4920, label = "Reginald Windsor — Elwynn Forest", kind = "location" },
        },
    },
    [6501] = {
        pickup = "Highlord Bolvar Fordragon, Stormwind",
        turnin = "Haleh, Winterspring",
        pins = {
            { mapID = 1453, x = 0.8020, y = 0.3830, label = "Highlord Bolvar Fordragon — Stormwind", kind = "location" },
        },
    },
    [6502] = {
        name = "Drakefire Amulet",
        pickup = "Haleh, Mazthoril, Winterspring",
        turnin = "Haleh, Mazthoril, Winterspring",
        summary = "Part of the Onyxia attunement.",
        steps = {
            { text = "Prereq chain (15): Dragonkin Menace -> The True Masters -> The True Masters (+12 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1452, x = 0.5440, y = 0.5120, label = "Haleh — Winterspring", kind = "start" },
        },
    },
    [6521] = {
        name = "An Unholy Alliance",
        pickup = "Varimathras, Royal Quarter, Undercity",
        turnin = "Varimathras, Royal Quarter, Undercity",
        summary = "Final step. Ambassador Malcin is outside Razorfen Downs.",
        warning = "This quest is done OUTSIDE Razorfen Downs, do it before entering the dungeon.",
        steps = {
            { text = "Prereq chain (1): An Unholy Alliance", kind = "quest" },
        },
        pins = {
            { mapID = 1458, x = 0.5620, y = 0.9260, label = "Varimathras — Royal Quarter, Undercity", kind = "start" },
        },
    },
    [6522] = {
        name = "An Unholy Alliance",
        pickup = "Small Scroll, dropped by Charlga Razorflank",
        turnin = "Varimathras, Royal Quarter, Undercity",
        steps = {
            { text = "Start with [Small Scroll] (Dropped by: Charlga Razorflank)", kind = "starter", itemID = 17008, itemName = "Small Scroll", mapID = 1458, x = 0.5620, y = 0.9260 },
        },
        items = {
            { id = 17008, name = "Small Scroll", role = "starter", source = "Dropped by: Charlga Razorflank" },
        },
        pins = {
            { mapID = 1458, x = 0.5620, y = 0.9260, label = "Varimathras — Royal Quarter, Undercity", kind = "turnin" },
        },
    },
    [6562] = {
        name = "Trouble in the Deeps",
        pickup = "Tsunaman, Stonetalon Mountains",
        turnin = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale",
        summary = "Introductory step leading to The Essence of Aku'Mai.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to The Essence of Aku'Mai.", kind = "guide", mapID = 1442, x = 0.4720, y = 0.6420 },
        },
        pins = {
            { mapID = 1442, x = 0.4720, y = 0.6420, label = "Tsunaman — Sun Rock Retreat", kind = "start" },
        },
    },
    [6563] = {
        name = "The Essence of Aku'Mai",
        pickup = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale (12, 34)",
        turnin = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale",
        summary = "Optional introductory quest:",
        steps = {
            { text = "Optional introductory quest:", kind = "guide", mapID = 1440, x = 0.1200, y = 0.3400 },
        },
        pins = {
            { mapID = 1440, x = 0.1200, y = 0.3400, label = "Je'neu Sancrea", kind = "start" },
        },
    },
    [6564] = {
        name = "Allegiance to the Old Gods",
        pickup = "Damp Note",
        turnin = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale",
        steps = {
            { text = "Start with [Damp Note] (Drops from Blackfathom Tide Priestess in the entrance tunnels leading to Blackfathom Deeps.)", kind = "starter", itemID = 16790, itemName = "Damp Note" },
        },
        items = {
            { id = 16790, name = "Damp Note", role = "starter", source = "Drops from Blackfathom Tide Priestess in the entrance tunnels leading to Blackfathom Deeps." },
        },
    },
    [6565] = {
        name = "Allegiance to the Old Gods",
        pickup = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale (12, 34)",
        turnin = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale",
        summary = "Follows the Damp Note version of Allegiance to the Old Gods.",
        steps = {
            { text = "Prereq chain (1): Allegiance to the Old Gods", kind = "quest" },
        },
        pins = {
            { mapID = 1440, x = 0.1200, y = 0.3400, label = "Je'neu Sancrea", kind = "start" },
        },
    },
    [6566] = {
        pickup = "Thrall, Orgrimmar",
        turnin = "Thrall, Orgrimmar",
        pins = {
            { mapID = 1454, x = 0.3200, y = 0.3780, label = "Thrall — Orgrimmar", kind = "location" },
        },
    },
    [6567] = {
        pickup = "Thrall, Orgrimmar",
        turnin = "Rexxar, Feralas",
        pins = {
            { mapID = 1454, x = 0.3200, y = 0.3780, label = "Thrall — Orgrimmar", kind = "location" },
        },
    },
    [6568] = {
        pickup = "Rexxar, Feralas",
        turnin = "Myranda the Hag, Western Plaguelands",
        pins = {
            { mapID = 1444, x = 0.4480, y = 0.0740, label = "Rexxar — Feralas", kind = "location" },
        },
    },
    [6569] = {
        name = "Oculus Illusions",
        pickup = "Myranda the Hag, Sorrow Hill, Western Plaguelands",
        turnin = "Myranda the Hag, Sorrow Hill, Western Plaguelands",
        summary = "Part of the Horde Onyxia chain. Black Dragonspawn Eyes drop from the dragonspawn in UBRS.",
        steps = {
            { text = "Prereq chain (7): Blood and Thunder -> Warlord's Command -> Eitrigg's Wisdom (+4 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1422, x = 0.5080, y = 0.7780, label = "Myranda the Hag — Western Plaguelands", kind = "location" },
        },
    },
    [6570] = {
        pickup = "Myranda the Hag, Western Plaguelands",
        turnin = "Emberstrife, Dustwallow Marsh",
        pins = {
            { mapID = 1422, x = 0.5080, y = 0.7780, label = "Myranda the Hag — Western Plaguelands", kind = "location" },
        },
    },
    [6582] = {
        pickup = "Emberstrife, Dustwallow Marsh",
        turnin = "Emberstrife, Dustwallow Marsh",
        pins = {
            { mapID = 1445, x = 0.5620, y = 0.8800, label = "Emberstrife — Dustwallow Marsh", kind = "location" },
        },
    },
    [6583] = {
        pickup = "Emberstrife, Dustwallow Marsh",
        turnin = "Emberstrife, Dustwallow Marsh",
        pins = {
            { mapID = 1445, x = 0.5620, y = 0.8800, label = "Emberstrife — Dustwallow Marsh", kind = "location" },
        },
    },
    [6584] = {
        pickup = "Emberstrife, Dustwallow Marsh",
        turnin = "Emberstrife, Dustwallow Marsh",
        pins = {
            { mapID = 1445, x = 0.5620, y = 0.8800, label = "Emberstrife — Dustwallow Marsh", kind = "location" },
        },
    },
    [6585] = {
        pickup = "Emberstrife, Dustwallow Marsh",
        turnin = "Emberstrife, Dustwallow Marsh",
        pins = {
            { mapID = 1445, x = 0.5620, y = 0.8800, label = "Emberstrife — Dustwallow Marsh", kind = "location" },
        },
    },
    [6601] = {
        pickup = "Emberstrife, Dustwallow Marsh",
        turnin = "Rexxar, Feralas",
        pins = {
            { mapID = 1445, x = 0.5620, y = 0.8800, label = "Emberstrife — Dustwallow Marsh", kind = "location" },
        },
    },
    [6602] = {
        name = "Blood of the Black Dragon Champion",
        pickup = "Rexxar, Desolace",
        turnin = "Rexxar, Desolace",
        summary = "Part of the Onyxia attunement.",
        steps = {
            { text = "Prereq chain (14): Blood and Thunder -> Warlord's Command -> Eitrigg's Wisdom (+11 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1444, x = 0.4480, y = 0.0740, label = "Rexxar — Feralas", kind = "start" },
        },
    },
    [6626] = {
        name = "A Host of Evil",
        pickup = "Myriam Moonsinger, Razorfen Downs thorn maze, The Barrens",
        turnin = "Myriam Moonsinger, Razorfen Downs thorn maze, The Barrens",
        summary = "These mobs are outside the instance, around the entrance.",
        steps = {
            { text = "These mobs are outside the instance, around the entrance.", kind = "guide", mapID = 1413, x = 0.4900, y = 0.9480 },
        },
        pins = {
            { mapID = 1413, x = 0.4900, y = 0.9480, label = "Myriam Moonsinger — The Barrens", kind = "start" },
        },
    },
    [6627] = {
        pickup = "Braug Dimspirit, Talondeep Path, Stonetalon Mountains",
        turnin = "Braug Dimspirit, Talondeep Path, Stonetalon Mountains",
        warning = "ANSWER: Neltharion",
        pins = {
            { mapID = 1442, x = 0.7860, y = 0.4540, label = "Braug Dimspirit — Stonetalon Mountains", kind = "location", detail = "Near the entrance to Talondeep Path" },
        },
    },
    [6628] = {
        pickup = "Parqual Fintallas, Undercity",
        turnin = "Parqual Fintallas, Undercity",
        warning = "ANSWER: Ner'zhul",
        pins = {
            { mapID = 1458, x = 0.5760, y = 0.6520, label = "Parqual Fintallas — Undercity", kind = "location", detail = "Parqual Fintallas in Undercity" },
        },
    },
    [6921] = {
        name = "Amongst the Ruins",
        pickup = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale (12, 34)",
        turnin = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale",
        summary = "The Fathom Stone is also associated with the optional Baron Aquanis encounter.",
        steps = {
            { text = "The Fathom Stone is also associated with the optional Baron Aquanis encounter.", kind = "guide", mapID = 1440, x = 0.1200, y = 0.3400 },
        },
        pins = {
            { mapID = 1440, x = 0.1200, y = 0.3400, label = "Je'neu Sancrea", kind = "start" },
        },
    },
    [6922] = {
        name = "Baron Aquanis",
        pickup = "Strange Water Globe, dropped by Baron Aquanis inside Blackfathom Deeps",
        turnin = "Je'neu Sancrea, Zoram'gar Outpost, Ashenvale",
        warning = "Baron Aquanis spawns by looting the Fathom Core from the 'Amongst the Ruins' quest.",
        steps = {
            { text = "Start with [Strange Water Globe] (Drops from Baron Aquanis inside Blackfathom Deeps.)", kind = "starter", itemID = 16782, itemName = "Strange Water Globe" },
        },
        items = {
            { id = 16782, name = "Strange Water Globe", role = "starter", source = "Drops from Baron Aquanis inside Blackfathom Deeps." },
        },
    },
    [6981] = {
        name = "The Glowing Shard",
        pickup = "Item start: Glowing Shard, dropped by Mutanus the Devourer",
        turnin = "Falla Sagewind, on top of the mountain above Wailing Caverns, The Barrens (48.2, 32.8)",
        summary = "The direct quest has no item reward. Its follow-up, In Nightmares, later offers:",
        steps = {
            { text = "Start with [Glowing Shard] (Dropped by: Mutanus the Devourer)", kind = "starter", itemID = 10441, itemName = "Glowing Shard", mapID = 1413, x = 0.4820, y = 0.3280 },
        },
        items = {
            { id = 10441, name = "Glowing Shard", role = "starter", source = "Dropped by: Mutanus the Devourer" },
        },
        pins = {
            { mapID = 1413, x = 0.4820, y = 0.3280, label = "Falla Sagewind — above Wailing Caverns", kind = "turnin", detail = "In a tent on top of the mountain above Wailing Caverns" },
        },
    },
    [7028] = {
        name = "Twisted Evils",
        pickup = "Willow, Desolace",
        turnin = "Willow, Desolace",
        summary = "Any Maraudon creature can drop the Theradric Crystal Carvings.",
        steps = {
            { text = "Any Maraudon creature can drop the Theradric Crystal Carvings.", kind = "guide", mapID = 1443, x = 0.6200, y = 0.3940 },
        },
        pins = {
            { mapID = 1443, x = 0.6200, y = 0.3940, label = "Willow — Desolace", kind = "start" },
        },
    },
    [7029] = {
        name = "Vyletongue Corruption",
        pickup = "Vark Battlescar, Shadowprey Village, Desolace",
        turnin = "Vark Battlescar, Shadowprey Village, Desolace",
        summary = "Fill the Coated Cerulean Vial at the orange crystal pool in the outer caves, then use it on Vylestem Vines inside (orange side) and kill the Noxxious Scions to heal 8 plants.",
        steps = {
            { text = "Fill the Coated Cerulean Vial at the orange crystal pool in the outer caves, then use it on Vylestem Vines inside (orange side) and kill the Noxxious Scions to heal 8 plants.", kind = "guide", mapID = 1443, x = 0.2320, y = 0.7020 },
        },
        pins = {
            { mapID = 1443, x = 0.2320, y = 0.7020, label = "Vark Battlescar — Desolace", kind = "start" },
        },
    },
    [7041] = {
        name = "Vyletongue Corruption",
        pickup = "Talendria, Nijel's Point, Desolace",
        turnin = "Talendria, Nijel's Point, Desolace",
        summary = "Fill the Coated Cerulean Vial at the orange crystal pool in the outer caves, then use it on Vylestem Vines inside (orange side) and kill the Noxxious Scions to heal 8 plants.",
        steps = {
            { text = "Fill the Coated Cerulean Vial at the orange crystal pool in the outer caves, then use it on Vylestem Vines inside (orange side) and kill the Noxxious Scions to heal 8 plants.", kind = "guide", mapID = 1443, x = 0.6840, y = 0.0880 },
        },
        pins = {
            { mapID = 1443, x = 0.6840, y = 0.0880, label = "Talendria — Desolace", kind = "start" },
        },
    },
    [7044] = {
        name = "Legends of Maraudon",
        pickup = "Cavindra, Maraudon Orange Entrance, Desolace",
        turnin = "Celebras the Redeemed, Maraudon",
        summary = "The Celebrian Rod drops from Noxxion and the Celebrian Diamond from Lord Vyletongue.",
        steps = {
            { text = "The Celebrian Rod drops from Noxxion and the Celebrian Diamond from Lord Vyletongue.", kind = "guide", mapID = 1443, x = 0.3210, y = 0.6400 },
        },
        pins = {
            { mapID = 1443, x = 0.3210, y = 0.6400, label = "Cavindra — Desolace", kind = "start", detail = "Cavindra: Maraudon orange-side caverns, Desolace" },
        },
    },
    [7046] = {
        name = "The Scepter of Celebras",
        pickup = "Celebras the Redeemed, Maraudon",
        turnin = "Celebras the Redeemed, Maraudon",
        summary = "Defeat Celebras the Cursed where the paths meet and turn in Legends of Maraudon to Celebras the Redeemed, then help with his ritual and speak to him again for the scepter.",
        steps = {
            { text = "Defeat Celebras the Cursed where the paths meet and turn in Legends of Maraudon to Celebras the Redeemed, then help with his ritual and speak to him again for the scepter.", kind = "guide" },
        },
    },
    [7064] = {
        name = "Corruption of Earth and Seed",
        pickup = "Selendra, Shadowprey Village, Desolace",
        turnin = "Selendra, Shadowprey Village, Desolace",
        summary = "Kill Princess Theradras in the inner cavern.",
        steps = {
            { text = "Kill Princess Theradras in the inner cavern.", kind = "guide", mapID = 1443, x = 0.2680, y = 0.7760 },
        },
        pins = {
            { mapID = 1443, x = 0.2680, y = 0.7760, label = "Selendra — Desolace", kind = "start" },
        },
    },
    [7065] = {
        name = "Corruption of Earth and Seed",
        pickup = "Keeper Marandis, Nijel's Point, Desolace",
        turnin = "Keeper Marandis, Nijel's Point, Desolace",
        summary = "Kill Princess Theradras in the inner cavern.",
        steps = {
            { text = "Kill Princess Theradras in the inner cavern.", kind = "guide", mapID = 1443, x = 0.6380, y = 0.1060 },
        },
        pins = {
            { mapID = 1443, x = 0.6380, y = 0.1060, label = "Keeper Marandis — Desolace", kind = "start" },
        },
    },
    [7066] = {
        name = "Seed of Life",
        pickup = "Zaetar's Spirit, Maraudon",
        turnin = "Keeper Remulos, Moonglade",
        summary = "Zaetar's Spirit appears after Princess Theradras dies.",
        steps = {
            { text = "Zaetar's Spirit appears after Princess Theradras dies.", kind = "guide" },
        },
    },
    [7067] = {
        name = "The Pariah's Instructions",
        pickup = "Centaur Pariah, southern Desolace",
        turnin = "Centaur Pariah, southern Desolace",
        summary = "Loot the Amulet of Spirits from the Nameless Prophet in the outer caves, then use it to fight the five Khans: three in the outer caves, one on the purple route and one on the orange route. Combine their gems with the amulet.",
        steps = {
            { text = "Loot the Amulet of Spirits from the Nameless Prophet in the outer caves, then use it to fight the five Khans: three in the outer caves, one on the purple route and one on the orange route. Combine their gems with the amulet.", kind = "guide", mapID = 1443, x = 0.4340, y = 0.8480 },
        },
        pins = {
            { mapID = 1443, x = 0.4340, y = 0.8480, label = "Centaur Pariah — Desolace", kind = "start" },
        },
    },
    [7068] = {
        name = "Shadowshard Fragments",
        pickup = "Uthel'nay, Orgrimmar",
        turnin = "Uthel'nay, Orgrimmar",
        summary = "Shadowshard elementals in the outer purple-crystal caves. It can be done without entering the instance.",
        steps = {
            { text = "Shadowshard elementals in the outer purple-crystal caves. It can be done without entering the instance.", kind = "guide", mapID = 1454, x = 0.3880, y = 0.8540 },
        },
        pins = {
            { mapID = 1454, x = 0.3880, y = 0.8540, label = "Uthel'nay — Orgrimmar", kind = "start" },
        },
    },
    [7070] = {
        name = "Shadowshard Fragments",
        pickup = "Archmage Tervosh, Theramore, Dustwallow Marsh",
        turnin = "Archmage Tervosh, Theramore, Dustwallow Marsh",
        summary = "Shadowshard elementals in the outer purple-crystal caves. It can be done without entering the instance.",
        steps = {
            { text = "Shadowshard elementals in the outer purple-crystal caves. It can be done without entering the instance.", kind = "guide", mapID = 1445, x = 0.6640, y = 0.4930 },
        },
        pins = {
            { mapID = 1445, x = 0.6640, y = 0.4930, label = "Archmage Tervosh — Dustwallow Marsh", kind = "start" },
        },
    },
    [7201] = {
        name = "The Last Element",
        pickup = "Shadowmage Vivian Lagrave, Kargath, Badlands",
        turnin = "Shadowmage Vivian Lagrave, Kargath, Badlands",
        summary = "Essence of the Elements drops from BRD elementals and golems.",
        steps = {
            { text = "Prereq chain (1): Disharmony of Flame", kind = "quest" },
        },
        pins = {
            { mapID = 1418, x = 0.0300, y = 0.4760, label = "Shadowmage Vivian Lagrave — Badlands", kind = "start" },
        },
    },
    [7441] = {
        name = "Pusillin and the Elder Azj'Tordin",
        pickup = "Azj'Tordin, Lariss Pavilion, Feralas",
        turnin = "Azj'Tordin, Lariss Pavilion, Feralas",
        summary = "Chase and talk to Pusillin through the wing until he fights, then kill him for the book. He also drops the Crescent Key.",
        steps = {
            { text = "Chase and talk to Pusillin through the wing until he fights, then kill him for the book. He also drops the Crescent Key.", kind = "guide", mapID = 1444, x = 0.7680, y = 0.3740 },
        },
        pins = {
            { mapID = 1444, x = 0.7680, y = 0.3740, label = "Azj'Tordin — Feralas", kind = "start" },
        },
    },
    [7461] = {
        name = "The Madness Within",
        pickup = "Shen'dralar Ancient, Dire Maul",
        turnin = "Shen'dralar Ancient, Dire Maul",
        summary = "Kill the guardians of all five pylons, then Immol'thar, then Prince Tortheldrin. Return to the Ancient, take The Treasure of the Shen'dralar and open the chest under the library stairs for the reward.",
        steps = {
            { text = "Kill the guardians of all five pylons, then Immol'thar, then Prince Tortheldrin. Return to the Ancient, take The Treasure of the Shen'dralar and open the chest under the library stairs for the reward.", kind = "guide" },
        },
    },
    [7463] = {
        name = "Arcane Refreshment",
        pickup = "Lorekeeper Lydros, Dire Maul",
        turnin = "Lorekeeper Lydros, Dire Maul",
        summary = "Mage class quest. Lydros is in the Athenaeum (North/West); Hydrospawn Essence drops from Hydrospawn in East. Rewards Conjure Water (Rank 7).",
        steps = {
            { text = "Mage class quest. Lydros is in the Athenaeum (North/West); Hydrospawn Essence drops from Hydrospawn in East. Rewards Conjure Water (Rank 7).", kind = "guide" },
        },
    },
    [7481] = {
        name = "Elven Legends",
        pickup = "Sage Korolusk, Camp Mojache, Feralas",
        turnin = "Sage Korolusk, Camp Mojache, Feralas",
        summary = "Interact with the Skeletal Remains of Telmius Dreamseeker beside Lorekeeper Lydros in the Athenaeum. Unlocks Lydros's libram exchanges.",
        steps = {
            { text = "Interact with the Skeletal Remains of Telmius Dreamseeker beside Lorekeeper Lydros in the Athenaeum. Unlocks Lydros's libram exchanges.", kind = "guide", mapID = 1444, x = 0.7440, y = 0.4400 },
        },
        pins = {
            { mapID = 1444, x = 0.7440, y = 0.4400, label = "Sage Korolusk — Feralas", kind = "start" },
        },
    },
    [7482] = {
        name = "Elven Legends",
        pickup = "Scholar Runethorn, Feathermoon Stronghold, Feralas",
        turnin = "Scholar Runethorn, Feathermoon Stronghold, Feralas",
        summary = "Interact with the Skeletal Remains of Telmius Dreamseeker beside Lorekeeper Lydros in the Athenaeum. Unlocks Lydros's libram exchanges.",
        steps = {
            { text = "Interact with the Skeletal Remains of Telmius Dreamseeker beside Lorekeeper Lydros in the Athenaeum. Unlocks Lydros's libram exchanges.", kind = "guide", mapID = 1444, x = 0.3100, y = 0.4420 },
        },
        pins = {
            { mapID = 1444, x = 0.3100, y = 0.4420, label = "Scholar Runethorn — Feralas", kind = "start" },
        },
    },
    [7483] = {
        name = "Libram of Rapidity",
        pickup = "Lorekeeper Lydros, Athenaeum, Dire Maul",
        turnin = "Lorekeeper Lydros, Athenaeum, Dire Maul",
        summary = "Repeatable. Needs your faction's Elven Legends turned in first.",
        steps = {
            { text = "Repeatable. Needs your faction's Elven Legends turned in first.", kind = "guide" },
        },
    },
    [7484] = {
        name = "Libram of Focus",
        pickup = "Lorekeeper Lydros, Athenaeum, Dire Maul",
        turnin = "Lorekeeper Lydros, Athenaeum, Dire Maul",
        summary = "Repeatable. Needs your faction's Elven Legends turned in first.",
        steps = {
            { text = "Repeatable. Needs your faction's Elven Legends turned in first.", kind = "guide" },
        },
    },
    [7485] = {
        name = "Libram of Protection",
        pickup = "Lorekeeper Lydros, Athenaeum, Dire Maul",
        turnin = "Lorekeeper Lydros, Athenaeum, Dire Maul",
        summary = "Repeatable. Needs your faction's Elven Legends turned in first.",
        steps = {
            { text = "Repeatable. Needs your faction's Elven Legends turned in first.", kind = "guide" },
        },
    },
    [7488] = {
        name = "Lethtendris's Web",
        pickup = "Latronicus Moonspear, Feathermoon Stronghold, Feralas",
        turnin = "Latronicus Moonspear, Feathermoon Stronghold, Feralas",
        summary = "The web drops from Lethtendris.  Optional introductory quest:",
        steps = {
            { text = "The web drops from Lethtendris.  Optional introductory quest:", kind = "guide", mapID = 1444, x = 0.3040, y = 0.4600 },
        },
        pins = {
            { mapID = 1444, x = 0.3040, y = 0.4600, label = "Latronicus Moonspear — Feralas", kind = "start" },
        },
    },
    [7489] = {
        name = "Lethtendris's Web",
        pickup = "Talo Thornhoof, Camp Mojache, Feralas",
        turnin = "Talo Thornhoof, Camp Mojache, Feralas",
        summary = "The web drops from Lethtendris.  Optional introductory quest:",
        steps = {
            { text = "The web drops from Lethtendris.  Optional introductory quest:", kind = "guide", mapID = 1444, x = 0.7600, y = 0.4380 },
        },
        pins = {
            { mapID = 1444, x = 0.7600, y = 0.4380, label = "Talo Thornhoof — Feralas", kind = "start" },
        },
    },
    [7492] = {
        name = "Camp Mojache",
        pickup = "Harbinger Balthazad, Undercity (or Warcaller Gorlach, Orgrimmar / Bluff Runner Windstrider, Thunder Bluff)",
        turnin = "Talo Thornhoof, Camp Mojache, Feralas",
        summary = "Introductory step leading to Lethtendris's Web.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Lethtendris's Web.", kind = "guide", mapID = 1458, x = 0.6390, y = 0.4410 },
        },
        pins = {
            { mapID = 1458, x = 0.6390, y = 0.4410, label = "Harbinger Balthazad — Undercity (walks around)", kind = "start", detail = "Harbinger Balthazad: Trade Quarter, Undercity (walks around)" },
        },
    },
    [7494] = {
        name = "Feathermoon Stronghold",
        pickup = "Crier Goodman, Stormwind (or Courier Hammerfall, Ironforge / Herald Moonstalker, Darnassus)",
        turnin = "Latronicus Moonspear, Feathermoon Stronghold, Feralas",
        summary = "Introductory step leading to Lethtendris's Web.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Lethtendris's Web.", kind = "guide", mapID = 1453, x = 0.5640, y = 0.7410 },
        },
        pins = {
            { mapID = 1453, x = 0.5640, y = 0.7410, label = "Crier Goodman — Stormwind (walks around)", kind = "start", detail = "Crier Goodman: Trade District, Stormwind (walks around)" },
        },
    },
    [7498] = {
        name = "Garona: A Study on Stealth and Treachery",
        pickup = "Garona: A Study on Stealth and Treachery (book, Dire Maul drop)",
        turnin = "Lorekeeper Kildrath, Dire Maul",
        summary = "Rogue class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [Garona: A Study on Stealth and Treachery] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18356, itemName = "Garona: A Study on Stealth and Treachery" },
        },
        items = {
            { id = 18356, name = "Garona: A Study on Stealth and Treachery", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7499] = {
        name = "Codex of Defense",
        pickup = "Codex of Defense (book, Dire Maul drop)",
        turnin = "Lorekeeper Kildrath, Dire Maul",
        summary = "Warrior class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [Codex of Defense] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18357, itemName = "Codex of Defense" },
        },
        items = {
            { id = 18357, name = "Codex of Defense", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7500] = {
        name = "The Arcanist's Cookbook",
        pickup = "The Arcanist's Cookbook (book, Dire Maul drop)",
        turnin = "Lorekeeper Kildrath, Dire Maul",
        summary = "Mage class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [The Arcanist's Cookbook] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18358, itemName = "The Arcanist's Cookbook" },
        },
        items = {
            { id = 18358, name = "The Arcanist's Cookbook", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7501] = {
        name = "The Light and How To Swing It",
        pickup = "The Light and How To Swing It (book, Dire Maul drop)",
        turnin = "Lorekeeper Mykos, Dire Maul",
        summary = "Paladin class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [The Light and How to Swing It] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18359, itemName = "The Light and How to Swing It" },
        },
        items = {
            { id = 18359, name = "The Light and How to Swing It", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7502] = {
        name = "Harnessing Shadows",
        pickup = "Harnessing Shadows (book, Dire Maul drop)",
        turnin = "Lorekeeper Mykos, Dire Maul",
        summary = "Warlock class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [Harnessing Shadows] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18360, itemName = "Harnessing Shadows" },
        },
        items = {
            { id = 18360, name = "Harnessing Shadows", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7503] = {
        name = "The Greatest Race of Hunters",
        pickup = "The Greatest Race of Hunters (book, Dire Maul drop)",
        turnin = "Lorekeeper Mykos, Dire Maul",
        summary = "Hunter class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [The Greatest Race of Hunters] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18361, itemName = "The Greatest Race of Hunters" },
        },
        items = {
            { id = 18361, name = "The Greatest Race of Hunters", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7504] = {
        name = "Holy Bologna: What the Light Won't Tell You",
        pickup = "Holy Bologna: What the Light Won't Tell You (book, Dire Maul drop)",
        turnin = "Lorekeeper Javon, Dire Maul",
        summary = "Priest class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [Holy Bologna: What the Light Won't Tell You] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18362, itemName = "Holy Bologna: What the Light Won't Tell You" },
        },
        items = {
            { id = 18362, name = "Holy Bologna: What the Light Won't Tell You", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7505] = {
        name = "Frost Shock and You",
        pickup = "Frost Shock and You (book, Dire Maul drop)",
        turnin = "Lorekeeper Javon, Dire Maul",
        summary = "Shaman class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [Frost Shock and You] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18363, itemName = "Frost Shock and You" },
        },
        items = {
            { id = 18363, name = "Frost Shock and You", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7506] = {
        name = "The Emerald Dream...",
        pickup = "The Emerald Dream (book, Dire Maul drop)",
        turnin = "Lorekeeper Javon, Dire Maul",
        summary = "Druid class book. Click the book to start the quest.",
        steps = {
            { text = "Start with [The Emerald Dream] (Drops in Dire Maul; also tradeable)", kind = "starter", itemID = 18364, itemName = "The Emerald Dream" },
        },
        items = {
            { id = 18364, name = "The Emerald Dream", role = "starter", source = "Drops in Dire Maul; also tradeable" },
        },
    },
    [7507] = {
        name = "Nostro's Compendium",
        pickup = "Nostro's Compendium of Dragon Slaying (rare Dire Maul drop)",
        turnin = "Lorekeeper Lydros, Athenaeum, Dire Maul",
        summary = "Warriors and Paladins. Lydros then gives The Forging of Quel'Serrar, which is finished in Onyxia's Lair.",
        steps = {
            { text = "Warriors and Paladins. Lydros then gives The Forging of Quel'Serrar, which is finished in Onyxia's Lair.", kind = "guide" },
        },
    },
    [7563] = {
        pickup = "Mor'zul Bloodbringer, Burning Steppes",
        turnin = "Mor'zul Bloodbringer, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.1260, y = 0.3140, label = "Mor'zul Bloodbringer — Burning Steppes", kind = "location" },
        },
    },
    [7564] = {
        pickup = "Mor'zul Bloodbringer, Burning Steppes",
        turnin = "Gorzeeki Wildeyes, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.1260, y = 0.3140, label = "Mor'zul Bloodbringer — Burning Steppes", kind = "location" },
        },
    },
    [7604] = {
        name = "A Binding Contract",
        pickup = "Thorium Brotherhood Contract (from Lokhtos Darkbargainer with a Sulfuron Ingot)",
        turnin = "Lokhtos Darkbargainer, Grim Guzzler, Blackrock Depths",
        summary = "Blacksmithing. Bring a Sulfuron Ingot (Golemagg, Molten Core) to Lokhtos in the Grim Guzzler to get the contract, then hand it back for the Sulfuron Hammer plans.",
        steps = {
            { text = "Blacksmithing. Bring a Sulfuron Ingot (Golemagg, Molten Core) to Lokhtos in the Grim Guzzler to get the contract, then hand it back for the Sulfuron Hammer plans.", kind = "guide" },
        },
    },
    [7623] = {
        pickup = "Gorzeeki Wildeyes, Burning Steppes",
        turnin = "Lord Banehollow, Felwood",
        pins = {
            { mapID = 1428, x = 0.1240, y = 0.3140, label = "Gorzeeki Wildeyes — Burning Steppes", kind = "location" },
        },
    },
    [7624] = {
        pickup = "Lord Banehollow, Felwood",
        turnin = "Lord Banehollow, Felwood",
        pins = {
            { mapID = 1448, x = 0.3600, y = 0.4440, label = "Lord Banehollow — Felwood", kind = "location" },
        },
    },
    [7625] = {
        pickup = "Lord Banehollow, Felwood",
        turnin = "Gorzeeki Wildeyes, Burning Steppes",
        pins = {
            { mapID = 1448, x = 0.3600, y = 0.4440, label = "Lord Banehollow — Felwood", kind = "location" },
        },
    },
    [7626] = {
        pickup = "Mor'zul Bloodbringer, Burning Steppes",
        turnin = "Gorzeeki Wildeyes, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.1260, y = 0.3140, label = "Mor'zul Bloodbringer — Burning Steppes", kind = "location" },
        },
    },
    [7627] = {
        pickup = "Mor'zul Bloodbringer, Burning Steppes",
        turnin = "Gorzeeki Wildeyes, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.1260, y = 0.3140, label = "Mor'zul Bloodbringer — Burning Steppes", kind = "location" },
        },
    },
    [7628] = {
        pickup = "Mor'zul Bloodbringer, Burning Steppes",
        turnin = "Gorzeeki Wildeyes, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.1260, y = 0.3140, label = "Mor'zul Bloodbringer — Burning Steppes", kind = "location" },
        },
    },
    [7629] = {
        name = "Imp Delivery",
        pickup = "Gorzeeki Wildeyes, Altar of Storms, Burning Steppes",
        turnin = "Gorzeeki Wildeyes, Altar of Storms, Burning Steppes",
        summary = "Warlock dreadsteed quest. Release the Imp in a Jar at the alchemy lab in Ras Frostwhisper's room and wait for the parchment.",
        steps = {
            { text = "Prereq chain (5): Rage of Blood -> Wildeyes -> Lord Banehollow (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1428, x = 0.1240, y = 0.3140, label = "Gorzeeki Wildeyes — Burning Steppes", kind = "location" },
        },
    },
    [7630] = {
        pickup = "Gorzeeki Wildeyes, Burning Steppes",
        turnin = "Gorzeeki Wildeyes, Burning Steppes",
        pins = {
            { mapID = 1428, x = 0.1240, y = 0.3140, label = "Gorzeeki Wildeyes — Burning Steppes", kind = "location" },
        },
    },
    [7631] = {
        name = "Dreadsteed of Xoroth",
        pickup = "Mor'zul Bloodbringer, Altar of Storms, Burning Steppes",
        turnin = "Dreadsteed Spirit, Dire Maul",
        summary = "Warlock dreadsteed quest. After Immol'thar dies, run the ritual in his prison with J'eevee's Jar, the Black Lodestone and the Xorothian Glyphs. Bring Soul Shards.",
        steps = {
            { text = "Prereq chain (10): Rage of Blood -> Wildeyes -> Lord Banehollow (+7 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1428, x = 0.1260, y = 0.3140, label = "Mor'zul Bloodbringer — Burning Steppes", kind = "start" },
        },
    },
    [7637] = {
        pickup = "Lord Grayson Shadowbreaker, Stormwind",
        turnin = "High Priest Rohan, Ironforge",
        pins = {
            { mapID = 1453, x = 0.4840, y = 0.5020, label = "Lord Grayson Shadowbreaker — Stormwind", kind = "location" },
        },
    },
    [7639] = {
        pickup = "High Priest Rohan, Ironforge",
        turnin = "Lord Grayson Shadowbreaker, Stormwind",
        pins = {
            { mapID = 1455, x = 0.2470, y = 0.0820, label = "High Priest Rohan — Ironforge", kind = "location" },
        },
    },
    [7640] = {
        pickup = "Lord Grayson Shadowbreaker, Stormwind",
        turnin = "Lord Grayson Shadowbreaker, Stormwind",
        pins = {
            { mapID = 1453, x = 0.4840, y = 0.5020, label = "Lord Grayson Shadowbreaker — Stormwind", kind = "location" },
        },
    },
    [7641] = {
        pickup = "Lord Grayson Shadowbreaker, Stormwind",
        turnin = "Grimand Elmore, Stormwind",
        pins = {
            { mapID = 1453, x = 0.4840, y = 0.5020, label = "Lord Grayson Shadowbreaker — Stormwind", kind = "location" },
        },
    },
    [7642] = {
        pickup = "Grimand Elmore, Stormwind",
        turnin = "Grimand Elmore, Stormwind",
        pins = {
            { mapID = 1453, x = 0.5970, y = 0.3380, label = "Grimand Elmore — Stormwind", kind = "location" },
        },
    },
    [7643] = {
        name = "Ancient Equine Spirit",
        pickup = "Lord Grayson Shadowbreaker, Cathedral of Light, Stormwind",
        turnin = "Ancient Equine Spirit, Dire Maul",
        summary = "Paladin charger quest. Kill Tendris Warpwood, then feed the Ancient Equine Spirit and give it the Arcanite Barding. Bring the Manna-Enriched Horse Feed from Merideth Carlson in Southshore.",
        steps = {
            { text = "Prereq chain (7): Emphasis on Sacrifice -> To Show Due Judgment -> Exorcising Terrordale (+4 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1453, x = 0.4840, y = 0.5020, label = "Lord Grayson Shadowbreaker — Stormwind", kind = "location" },
        },
    },
    [7645] = {
        pickup = "Merideth Carlson, Hillsbrad Foothills",
        turnin = "Merideth Carlson, Hillsbrad Foothills",
        pins = {
            { mapID = 1424, x = 0.5200, y = 0.5560, label = "Merideth Carlson — Hillsbrad Foothills", kind = "location" },
        },
    },
    [7646] = {
        pickup = "Lord Grayson Shadowbreaker, Stormwind",
        turnin = "Lord Grayson Shadowbreaker, Stormwind",
        pins = {
            { mapID = 1453, x = 0.4840, y = 0.5020, label = "Lord Grayson Shadowbreaker — Stormwind", kind = "location" },
        },
    },
    [7647] = {
        name = "Judgment and Redemption",
        pickup = "Lord Grayson Shadowbreaker, Cathedral of Light, Stormwind",
        turnin = "Darkreaver's Fallen Charger, Scholomance",
        summary = "Paladin charger quest. Clear Rattlegore's basement in the Great Ossuary, use the Divination Scryer and defeat the spirits and Death Knight Darkreaver.",
        steps = {
            { text = "Prereq chain (10): Emphasis on Sacrifice -> To Show Due Judgment -> Exorcising Terrordale (+7 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1453, x = 0.4840, y = 0.5020, label = "Lord Grayson Shadowbreaker — Stormwind", kind = "start" },
        },
    },
    [7648] = {
        pickup = "Grimand Elmore, Stormwind",
        turnin = "Lord Grayson Shadowbreaker, Stormwind",
        pins = {
            { mapID = 1453, x = 0.5970, y = 0.3380, label = "Grimand Elmore — Stormwind", kind = "location" },
        },
    },
    [7667] = {
        pickup = "Sagorne Creststrider, Orgrimmar",
        turnin = "Sagorne Creststrider, Orgrimmar",
        pins = {
            { mapID = 1454, x = 0.3840, y = 0.3600, label = "Sagorne Creststrider — Orgrimmar", kind = "location" },
        },
    },
    [7668] = {
        name = "The Darkreaver Menace",
        pickup = "Sagorne Creststrider, Valley of Wisdom, Orgrimmar",
        turnin = "Sagorne Creststrider, Valley of Wisdom, Orgrimmar",
        summary = "Shaman quest. Clear Rattlegore's basement, use the scryer and defeat Death Knight Darkreaver; return his head.",
        steps = {
            { text = "Prereq chain (1): Material Assistance", kind = "quest" },
        },
        pins = {
            { mapID = 1454, x = 0.3840, y = 0.3600, label = "Sagorne Creststrider — Orgrimmar", kind = "start" },
        },
    },
    [7703] = {
        name = "Unfinished Gordok Business",
        pickup = "Captain Kromcrush, Dire Maul",
        turnin = "Captain Kromcrush, Dire Maul",
        summary = "Talk to a friendly Captain Kromcrush after you become the Gordok king. The Gauntlet of Gordok Might is in a chest near Prince Tortheldrin in Dire Maul West.",
        steps = {
            { text = "Talk to a friendly Captain Kromcrush after you become the Gordok king. The Gauntlet of Gordok Might is in a chest near Prince Tortheldrin in Dire Maul West.", kind = "guide" },
        },
    },
    [7761] = {
        name = "Blackhand's Command",
        pickup = "Blackhand's Command (letter from the Scarshield Quartermaster, Blackrock Mountain)",
        turnin = "Drakkisath's Brand, Upper Blackrock Spire",
        summary = "The Scarshield Quartermaster is in the hallway outside the Spire portal. Touch Drakkisath's Brand behind General Drakkisath; this unlocks the Orb of Command shortcut to Blackwing Lair.",
        steps = {
            { text = "Start with [Blackhand's Command] (Dropped by the Scarshield Quartermaster in the hallway outside the Spire portal)", kind = "starter", itemID = 18987, itemName = "Blackhand's Command" },
        },
        items = {
            { id = 18987, name = "Blackhand's Command", role = "starter", source = "Dropped by the Scarshield Quartermaster in the hallway outside the Spire portal" },
        },
    },
    [7848] = {
        name = "Attunement to the Core",
        pickup = "Lothos Riftwaker, Blackrock Mountain",
        turnin = "Lothos Riftwaker, Blackrock Mountain",
        summary = "The Core Fragment is on the rock beside the Molten Core portal deep inside BRD. Unlocks Lothos's teleport to Molten Core.",
        steps = {
            { text = "The Core Fragment is on the rock beside the Molten Core portal deep inside BRD. Unlocks Lothos's teleport to Molten Core.", kind = "guide" },
        },
    },
    [8151] = {
        name = "The Hunter's Charm",
        pickup = "Hunter trainers",
        turnin = "Ogtinc, Azshara",
        summary = "Introductory step leading to The Green Drake.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to The Green Drake.", kind = "guide" },
        },
    },
    [8153] = {
        pickup = "Ogtinc, Azshara",
        turnin = "Ogtinc, Azshara",
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.4260, label = "Ogtinc — Azshara", kind = "location" },
        },
    },
    [8231] = {
        pickup = "Ogtinc, Azshara",
        turnin = "Ogtinc, Azshara",
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.4260, label = "Ogtinc — Azshara", kind = "location" },
        },
    },
    [8232] = {
        name = "The Green Drake",
        pickup = "Ogtinc, Azshara",
        turnin = "Ogtinc, Azshara",
        summary = "Hunter class quest. The Tooth of Morphaz drops from Morphaz.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Courser Antlers -> Wavethrashing", kind = "quest" },
        },
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.4260, label = "Ogtinc — Azshara", kind = "start" },
        },
    },
    [8233] = {
        name = "A Simple Request",
        pickup = "Rogue trainers",
        turnin = "Lord Jorach Ravenholdt, Ravenholdt Manor, Alterac Mountains",
        summary = "Introductory step leading to The Azure Key.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to The Azure Key.", kind = "guide" },
        },
    },
    [8234] = {
        pickup = "Lord Jorach Ravenholdt, Alterac Mountains",
        turnin = "Archmage Xylem, Azshara",
        pins = {
            { mapID = 1416, x = 0.8600, y = 0.7900, label = "Lord Jorach Ravenholdt — Alterac Mountains", kind = "location" },
        },
    },
    [8235] = {
        pickup = "Archmage Xylem, Azshara",
        turnin = "Archmage Xylem, Azshara",
        pins = {
            { mapID = 1447, x = 0.2920, y = 0.4020, label = "Archmage Xylem — Azshara", kind = "location" },
        },
    },
    [8236] = {
        name = "The Azure Key",
        pickup = "Archmage Xylem, Azshara",
        turnin = "Lord Jorach Ravenholdt, Ravenholdt Manor, Alterac Mountains",
        summary = "Rogue class quest. The Azure Key drops from Morphaz.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Sealed Azure Bag -> Encoded Fragments", kind = "quest" },
        },
        pins = {
            { mapID = 1447, x = 0.2920, y = 0.4020, label = "Archmage Xylem — Azshara", kind = "start" },
        },
    },
    [8250] = {
        name = "Magecraft",
        pickup = "Mage trainers",
        turnin = "Sanath Lim-yo, Azshara",
        summary = "Introductory step leading to Destroy Morphaz.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Destroy Morphaz.", kind = "guide" },
        },
    },
    [8251] = {
        pickup = "Archmage Xylem, Azshara",
        turnin = "Archmage Xylem, Azshara",
        pins = {
            { mapID = 1447, x = 0.2920, y = 0.4020, label = "Archmage Xylem — Azshara", kind = "location" },
        },
    },
    [8252] = {
        pickup = "Archmage Xylem, Azshara",
        turnin = "Archmage Xylem, Azshara",
        pins = {
            { mapID = 1447, x = 0.2920, y = 0.4020, label = "Archmage Xylem — Azshara", kind = "location" },
        },
    },
    [8253] = {
        name = "Destroy Morphaz",
        pickup = "Archmage Xylem, Azshara",
        turnin = "Archmage Xylem, Azshara",
        summary = "Mage class quest. The Arcane Shard drops from Morphaz.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Magic Dust -> The Siren's Coral", kind = "quest" },
        },
        pins = {
            { mapID = 1447, x = 0.2920, y = 0.4020, label = "Archmage Xylem — Azshara", kind = "start" },
        },
    },
    [8254] = {
        name = "Cenarion Aid",
        pickup = "Priest trainers",
        turnin = "Ogtinc, Azshara",
        summary = "Introductory step leading to Blood of Morphaz.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Blood of Morphaz.", kind = "guide" },
        },
    },
    [8255] = {
        pickup = "Ogtinc, Azshara",
        turnin = "Ogtinc, Azshara",
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.4260, label = "Ogtinc — Azshara", kind = "location" },
        },
    },
    [8256] = {
        pickup = "Ogtinc, Azshara",
        turnin = "Ogtinc, Azshara",
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.4260, label = "Ogtinc — Azshara", kind = "location" },
        },
    },
    [8257] = {
        name = "Blood of Morphaz",
        pickup = "Ogtinc, Azshara",
        turnin = "Greta Mosshoof, Emerald Sanctuary, Felwood",
        summary = "Priest class quest. Morphaz's blood is turned in to Greta Mosshoof, not Ogtinc.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Of Coursers We Know -> The Ichor of Undeath", kind = "quest" },
        },
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.4260, label = "Ogtinc — Azshara", kind = "start" },
        },
    },
    [8410] = {
        pickup = "Beram Skychaser, Thunder Bluff",
        turnin = "Bath'rah the Windwatcher, Alterac Mountains",
        steps = {
            { text = "Get [Elemental Air]", kind = "item", itemID = 7069, itemName = "Elemental Air" },
            { text = "Get [Elemental Fire]", kind = "item", itemID = 7068, itemName = "Elemental Fire" },
            { text = "Get [Elemental Earth]", kind = "item", itemID = 7067, itemName = "Elemental Earth" },
            { text = "Get [Elemental Water]", kind = "item", itemID = 7070, itemName = "Elemental Water" },
            { text = "Turn in: Bath'rah the Windwatcher, Alterac Mountains", kind = "turnin" },
        },
        items = {
            { id = 7069, name = "Elemental Air", role = "required" },
            { id = 7068, name = "Elemental Fire", role = "required" },
            { id = 7067, name = "Elemental Earth", role = "required" },
            { id = 7070, name = "Elemental Water", role = "required" },
        },
        pins = {
            { mapID = 1456, x = 0.2220, y = 0.1900, label = "Beram Skychaser — Thunder Bluff", kind = "location" },
        },
    },
    [8411] = {
        pickup = "Bath'rah the Windwatcher, Alterac Mountains",
        turnin = "Bath'rah the Windwatcher, Alterac Mountains",
        steps = {
            { text = "Get [Elemental Air]", kind = "item", itemID = 7069, itemName = "Elemental Air" },
            { text = "Get [Elemental Earth]", kind = "item", itemID = 7067, itemName = "Elemental Earth" },
            { text = "Get [Elemental Fire]", kind = "item", itemID = 7068, itemName = "Elemental Fire" },
            { text = "Get [Elemental Water]", kind = "item", itemID = 7070, itemName = "Elemental Water" },
            { text = "Turn in: Bath'rah the Windwatcher, Alterac Mountains", kind = "turnin" },
        },
        items = {
            { id = 7069, name = "Elemental Air", role = "required" },
            { id = 7067, name = "Elemental Earth", role = "required" },
            { id = 7068, name = "Elemental Fire", role = "required" },
            { id = 7070, name = "Elemental Water", role = "required" },
        },
        pins = {
            { mapID = 1416, x = 0.8040, y = 0.6680, label = "Bath'rah the Windwatcher — Alterac Mountains", kind = "location" },
        },
    },
    [8412] = {
        pickup = "Bath'rah the Windwatcher, Alterac Mountains",
        turnin = "Bath'rah the Windwatcher, Alterac Mountains",
        pins = {
            { mapID = 1416, x = 0.8040, y = 0.6680, label = "Bath'rah the Windwatcher — Alterac Mountains", kind = "location" },
        },
    },
    [8413] = {
        name = "Da Voodoo",
        pickup = "Bath'rah the Windwatcher, Alterac Mountains",
        turnin = "Bath'rah the Windwatcher, Alterac Mountains",
        summary = "Shaman class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.",
        steps = {
            { text = "Prereq chain (2): Elemental Mastery -> Spirit Totem", kind = "quest" },
        },
        pins = {
            { mapID = 1416, x = 0.8040, y = 0.6680, label = "Bath'rah the Windwatcher — Alterac Mountains", kind = "start" },
        },
    },
    [8414] = {
        pickup = "Commander Ashlam Valorfist, Western Plaguelands",
        turnin = "High Priest Thel'danis, Western Plaguelands",
        pins = {
            { mapID = 1422, x = 0.4280, y = 0.8400, label = "Commander Ashlam Valorfist — Western Plaguelands", kind = "location" },
        },
    },
    [8415] = {
        name = "Chillwind Point",
        pickup = "Lord Grayson Shadowbreaker, Cathedral of Light, Stormwind",
        turnin = "Commander Ashlam Valorfist, Chillwind Camp, Western Plaguelands",
        summary = "Introductory step leading to Forging the Mightstone.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Forging the Mightstone.", kind = "guide", mapID = 1453, x = 0.4840, y = 0.5020 },
        },
        pins = {
            { mapID = 1453, x = 0.4840, y = 0.5020, label = "Lord Grayson Shadowbreaker — Stormwind", kind = "start" },
        },
    },
    [8416] = {
        pickup = "High Priest Thel'danis, Western Plaguelands",
        turnin = "Commander Ashlam Valorfist, Western Plaguelands",
        pins = {
            { mapID = 1422, x = 0.5180, y = 0.8240, label = "High Priest Thel'danis — Western Plaguelands", kind = "location" },
        },
    },
    [8417] = {
        name = "A Troubled Spirit",
        pickup = "Warrior trainers",
        turnin = "Fallen Hero of the Horde, Swamp of Sorrows",
        summary = "Introductory step leading to Voodoo Feathers.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to Voodoo Feathers.", kind = "guide" },
        },
    },
    [8418] = {
        name = "Forging the Mightstone",
        pickup = "Commander Ashlam Valorfist, Chillwind Camp, Western Plaguelands",
        turnin = "Commander Ashlam Valorfist, Chillwind Camp, Western Plaguelands",
        summary = "Paladin class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Dispelling Evil -> Inert Scourgestones", kind = "quest" },
        },
        pins = {
            { mapID = 1422, x = 0.4280, y = 0.8400, label = "Commander Ashlam Valorfist — Western Plaguelands", kind = "start" },
        },
    },
    [8420] = {
        pickup = "Impsy, Felwood",
        turnin = "Impsy, Felwood",
        pins = {
            { mapID = 1448, x = 0.4140, y = 0.4480, label = "Impsy — Felwood", kind = "location" },
        },
    },
    [8421] = {
        pickup = "Impsy, Felwood",
        turnin = "Impsy, Felwood",
        pins = {
            { mapID = 1448, x = 0.4140, y = 0.4480, label = "Impsy — Felwood", kind = "location" },
        },
    },
    [8422] = {
        name = "Trolls of a Feather",
        pickup = "Impsy, Bloodvenom Falls, Felwood",
        turnin = "Impsy, Bloodvenom Falls, Felwood",
        summary = "Warlock class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.",
        steps = {
            { text = "Prereq chain (3): An Imp's Request -> Hot and Itchy -> The Wrong Stuff", kind = "quest" },
        },
        pins = {
            { mapID = 1448, x = 0.4140, y = 0.4480, label = "Impsy — Felwood", kind = "start" },
        },
    },
    [8423] = {
        pickup = "Fallen Hero of the Horde, Swamp of Sorrows",
        turnin = "Fallen Hero of the Horde, Swamp of Sorrows",
        pins = {
            { mapID = 1435, x = 0.3420, y = 0.6600, label = "Fallen Hero of the Horde — Swamp of Sorrows", kind = "location" },
        },
    },
    [8424] = {
        pickup = "Fallen Hero of the Horde, Swamp of Sorrows",
        turnin = "Fallen Hero of the Horde, Swamp of Sorrows",
        pins = {
            { mapID = 1435, x = 0.3420, y = 0.6600, label = "Fallen Hero of the Horde — Swamp of Sorrows", kind = "location" },
        },
    },
    [8425] = {
        name = "Voodoo Feathers",
        pickup = "Fallen Hero of the Horde, Swamp of Sorrows",
        turnin = "Fallen Hero of the Horde, Swamp of Sorrows",
        summary = "Warrior class quest for both factions. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Warrior Kinship -> War on the Shadowsworn", kind = "quest" },
        },
        pins = {
            { mapID = 1435, x = 0.3420, y = 0.6600, label = "Fallen Hero of the Horde — Swamp of Sorrows", kind = "start" },
        },
    },
    [8945] = {
        name = "Dead Man's Plea",
        pickup = "Anthion Harmon, Eastern Plaguelands",
        turnin = "Anthion Harmon, Eastern Plaguelands",
        summary = "Timed: rescue Ysida Harmon by killing Baron Rivendare within 45 minutes. Use the Extra-Dimensional Ghost Revealer to see Anthion.",
        steps = {
            { text = "Timed: rescue Ysida Harmon by killing Baron Rivendare within 45 minutes. Use the Extra-Dimensional Ghost Revealer to see Anthion.", kind = "guide", mapID = 1423, x = 0.2610, y = 0.1130 },
        },
        pins = {
            { mapID = 1423, x = 0.2610, y = 0.1130, label = "Anthion Harmon — outside the Stratholme main gate (needs the Ghost Revealer)", kind = "start", detail = "Anthion Harmon: outside the Stratholme main gate (needs the Ghost Revealer)" },
        },
    },
    [8948] = {
        pickup = "Anthion Harmon, outside Stratholme, Eastern Plaguelands",
        turnin = "Falrin Treeshaper, the Athenaeum, Dire Maul (West)",
        summary = "Part of Anthion Harmon's Dungeon Set 2 quests: the earlier ones unlock this step.",
        steps = {
            { text = "Use provided [Incomplete Banner of Provocation] (Given by Anthion Harmon)", kind = "provided", itemID = 21983, itemName = "Incomplete Banner of Provocation" },
            { text = "Turn in: Falrin Treeshaper, the Athenaeum, Dire Maul (West)", kind = "turnin" },
        },
        items = {
            { id = 21983, name = "Incomplete Banner of Provocation", role = "provided", source = "Given by Anthion Harmon" },
        },
    },
    [8949] = {
        pickup = "Falrin Treeshaper, the Athenaeum, Dire Maul (West)",
        turnin = "Falrin Treeshaper, the Athenaeum, Dire Maul (West)",
        steps = {
            { text = "Get [Ogre Warbeads]: From ogres in Dire Maul or Blackrock Spire (25 needed)", kind = "item", itemID = 21982, itemName = "Ogre Warbeads" },
            { text = "Turn in: Falrin Treeshaper, the Athenaeum, Dire Maul (West)", kind = "turnin" },
        },
        items = {
            { id = 21982, name = "Ogre Warbeads", role = "required", source = "From ogres in Dire Maul or Blackrock Spire (25 needed)" },
        },
    },
    [8950] = {
        pickup = "Falrin Treeshaper, the Athenaeum, Dire Maul (West)",
        turnin = "Falrin Treeshaper, the Athenaeum, Dire Maul (West)",
        steps = {
            { text = "Get [Jeering Spectre's Essence]: From Eldreth Phantasms, Spectres, Spirits and Apparitions in Dire Maul (1 needed)", kind = "item", itemID = 22224, itemName = "Jeering Spectre's Essence" },
            { text = "Get [Dark Rune]: From undead in the Plaguelands, Scholomance and Stratholme (4 needed)", kind = "item", itemID = 20520, itemName = "Dark Rune" },
            { text = "Get [Large Brilliant Shard]: Enchanting: disenchant rare items, or buy one (8 needed)", kind = "item", itemID = 14344, itemName = "Large Brilliant Shard" },
            { text = "Turn in: Falrin Treeshaper, the Athenaeum, Dire Maul (West)", kind = "turnin" },
        },
        items = {
            { id = 22224, name = "Jeering Spectre's Essence", role = "required", source = "From Eldreth Phantasms, Spectres, Spirits and Apparitions in Dire Maul (1 needed)" },
            { id = 20520, name = "Dark Rune", role = "required", source = "From undead in the Plaguelands, Scholomance and Stratholme (4 needed)" },
            { id = 14344, name = "Large Brilliant Shard", role = "required", source = "Enchanting: disenchant rare items, or buy one (8 needed)" },
        },
    },
    [9015] = {
        steps = {
            { text = "Prereq chain (3): Anthion's Old Friend -> Falrin's Vendetta -> The Instigator's Enchantment", kind = "quest" },
        },
    },
    [9051] = {
        pickup = "Torwa Pathfinder, Un'Goro Crater",
        turnin = "Torwa Pathfinder, Un'Goro Crater",
        pins = {
            { mapID = 1449, x = 0.7160, y = 0.7600, label = "Torwa Pathfinder — Un'Goro Crater", kind = "location" },
        },
    },
    [9052] = {
        pickup = "Torwa Pathfinder, Un'Goro Crater",
        turnin = "Torwa Pathfinder, Un'Goro Crater",
        pins = {
            { mapID = 1449, x = 0.7160, y = 0.7600, label = "Torwa Pathfinder — Un'Goro Crater", kind = "location" },
        },
    },
    [9053] = {
        name = "A Better Ingredient",
        pickup = "Torwa Pathfinder, Un'Goro Crater",
        turnin = "Torwa Pathfinder, Un'Goro Crater",
        summary = "Druid class quest. The Putrid Vine drops from Atal'alarion in the temple basement.  Optional introductory quest:",
        steps = {
            { text = "Prereq chain (2): Bloodpetal Poison -> Toxic Test", kind = "quest" },
        },
        pins = {
            { mapID = 1449, x = 0.7160, y = 0.7600, label = "Torwa Pathfinder — Un'Goro Crater", kind = "start" },
        },
    },
    [9063] = {
        name = "Torwa Pathfinder",
        pickup = "Druid trainers",
        turnin = "Torwa Pathfinder, Un'Goro Crater",
        summary = "Introductory step leading to A Better Ingredient.",
        warning = "OPTIONAL, not required",
        steps = {
            { text = "Introductory step leading to A Better Ingredient.", kind = "guide" },
        },
    },
    [78088] = {
        pickup = "Strange Orb, top of the Tower of Althalaxx, Darkshore",
        turnin = "Delgren the Purifier, Maestra's Post, Ashenvale",
        steps = {
            { text = "Interact with: table: 00FAF018", kind = "object", mapID = 1439, x = 0.5620, y = 0.2640 },
        },
        pins = {
            { mapID = 1439, x = 0.5620, y = 0.2640, label = "Strange Orb — Tower of Althalaxx, Darkshore", kind = "location", detail = "On top of the tower" },
            { mapID = 1440, x = 0.2620, y = 0.3870, label = "Delgren the Purifier — Ashenvale", kind = "turnin" },
        },
    },
    [78089] = {
        pickup = "Delgren the Purifier, Ashenvale",
        turnin = "Katherine the Pure, Cathedral of Light, Stormwind",
        pins = {
            { mapID = 1440, x = 0.2620, y = 0.3870, label = "Delgren the Purifier — Ashenvale", kind = "location" },
            { mapID = 1453, x = 0.4850, y = 0.4910, label = "Katherine the Pure — Cathedral of Light, Stormwind", kind = "turnin" },
        },
    },
    [78090] = {
        pickup = "Katherine the Pure, Cathedral of Light, Stormwind",
        turnin = "Ursula Deline, Mage Quarter, Stormwind",
        pins = {
            { mapID = 1453, x = 0.4850, y = 0.4910, label = "Katherine the Pure — Cathedral of Light, Stormwind", kind = "location" },
        },
    },
    [78092] = {
        pickup = "Ursula Deline, Mage Quarter, Stormwind",
        turnin = "Spear of Mannoroth, Demon Fall Canyon, Ashenvale",
        pins = {
            { mapID = 1440, x = 0.8900, y = 0.7700, label = "Spear of Mannoroth — Demon Fall Canyon, Ashenvale", kind = "objective" },
        },
    },
    [78093] = {
        pickup = "Shattered Orb, Demon Fall Canyon, Ashenvale",
        turnin = "Delgren the Purifier, Ashenvale",
        pins = {
            { mapID = 1440, x = 0.8900, y = 0.7700, label = "Shattered Orb — Demon Fall Canyon, Ashenvale", kind = "location" },
            { mapID = 1440, x = 0.2620, y = 0.3870, label = "Delgren the Purifier — Ashenvale", kind = "turnin" },
        },
    },
    [78261] = {
        pickup = "Dead Drop, Pyrewood Village, Silverpine Forest",
        turnin = "Dead Drop, Pyrewood Village, Silverpine Forest",
        warning = "Solo job: you must do it alone, outside any group.",
        steps = {
            { text = "Interact with: table: 010DB4E8", kind = "object", mapID = 1421, x = 0.4710, y = 0.7110 },
            { text = "Get [Breaching Charge]: From Veenix, Stonetalon Mountains, for a Venture Co. Work Order. Blows open the courtyard gate of Shadowfang Keep", kind = "item", itemID = 210186, itemName = "Breaching Charge", mapID = 1442, x = 0.5820, y = 0.5170 },
            { text = "Get [Twin Key]: Combine the Sister's Half-Key and the Brother's Half-Key, picked from the sister (dining hall) and the brother (upstairs) in Shadowfang Keep. Combining them breaks stealth", kind = "item", itemID = 210209, itemName = "Twin Key" },
            { text = "Get [Horn of Xelthos]: Found in: a locked chest in the courtyard stables of Shadowfang Keep. Open it with the Twin Key", kind = "item", itemID = 210183, itemName = "Horn of Xelthos" },
            { text = "Turn in: Dead Drop, Pyrewood Village, Silverpine Forest", kind = "turnin" },
        },
        items = {
            { id = 210186, name = "Breaching Charge", role = "required", source = "From Veenix, Stonetalon Mountains, for a Venture Co. Work Order. Blows open the courtyard gate of Shadowfang Keep" },
            { id = 210209, name = "Twin Key", role = "required", source = "Combine the Sister's Half-Key and the Brother's Half-Key, picked from the sister (dining hall) and the brother (upstairs) in Shadowfang Keep. Combining them breaks stealth" },
            { id = 210183, name = "Horn of Xelthos", role = "required", source = "Found in: a locked chest in the courtyard stables of Shadowfang Keep. Open it with the Twin Key" },
        },
        pins = {
            { mapID = 1421, x = 0.4710, y = 0.7110, label = "Dead Drop — Pyrewood Village", kind = "location", detail = "A chest in a hut beside Pyrewood Village" },
            { mapID = 1442, x = 0.5820, y = 0.5170, label = "Veenix — Stonetalon Mountains", kind = "item", detail = "From Veenix, Stonetalon Mountains, for a Venture Co. Work Order. Blows open the courtyard gate of Shadowfang Keep" },
        },
    },
    [78307] = {
        name = "The Horn of Xelthos",
        pickup = "Dead Drop, Pyrewood Village, Silverpine Forest",
        turnin = "Dead Drop, Pyrewood Village, Silverpine Forest",
        summary = "Offered after C's next letter reaches you in a capital city.",
        warning = "Solo job: you must do it alone, outside any group.",
        steps = {
            { text = "Interact with: table: 010DB4E8", kind = "object", mapID = 1421, x = 0.4710, y = 0.7110 },
        },
        pins = {
            { mapID = 1421, x = 0.4710, y = 0.7110, label = "Dead Drop — Pyrewood Village", kind = "start", detail = "A chest in a hut beside Pyrewood Village" },
        },
    },
    [78676] = {
        pickup = "Dead Drop, Pyrewood Village, Silverpine Forest",
        turnin = "Dead Drop, Pyrewood Village, Silverpine Forest",
        warning = "Solo job: you must do it alone, outside any group.",
        steps = {
            { text = "Interact with: table: 010DB4E8", kind = "object", mapID = 1421, x = 0.4710, y = 0.7110 },
            { text = "Get [Scarlet Initiate's Uniform]: Found in: the Supply Locker in the stables behind the Scarlet Monastery. Wear it to pass the Scarlet Crusade", kind = "item", itemID = 210955, itemName = "Scarlet Initiate's Uniform" },
            { text = "Get [Scryer's Key]: Pick pocket a Scarlet Scryer in the first big room of the Scarlet Monastery Graveyard", kind = "item", itemID = 210963, itemName = "Scryer's Key" },
            { text = "Get [Confidential Message]: Found in: the Personal Letterbox in Arcanist Doan's room, Scarlet Monastery Library. Open it with the Scryer's Key", kind = "item", itemID = 210967, itemName = "Confidential Message" },
            { text = "Get [Reliquary Key]: Found in: the Stone Coffer in the mausoleum on the north side of the Scarlet Monastery Graveyard. It opens after you sit on both benches between the two statues", kind = "item", itemID = 210968, itemName = "Reliquary Key" },
            { text = "Get [Eye of Bhossca]: Found in: the Padlocked Reliquary in the first small room on the left of the Scarlet Monastery Library. Open it with the Reliquary Key", kind = "item", itemID = 210953, itemName = "Eye of Bhossca" },
            { text = "Turn in: Dead Drop, Pyrewood Village, Silverpine Forest", kind = "turnin" },
        },
        items = {
            { id = 210955, name = "Scarlet Initiate's Uniform", role = "required", source = "Found in: the Supply Locker in the stables behind the Scarlet Monastery. Wear it to pass the Scarlet Crusade" },
            { id = 210963, name = "Scryer's Key", role = "required", source = "Pick pocket a Scarlet Scryer in the first big room of the Scarlet Monastery Graveyard" },
            { id = 210967, name = "Confidential Message", role = "required", source = "Found in: the Personal Letterbox in Arcanist Doan's room, Scarlet Monastery Library. Open it with the Scryer's Key" },
            { id = 210968, name = "Reliquary Key", role = "required", source = "Found in: the Stone Coffer in the mausoleum on the north side of the Scarlet Monastery Graveyard. It opens after you sit on both benches between the two statues" },
            { id = 210953, name = "Eye of Bhossca", role = "required", source = "Found in: the Padlocked Reliquary in the first small room on the left of the Scarlet Monastery Library. Open it with the Reliquary Key" },
        },
        pins = {
            { mapID = 1421, x = 0.4710, y = 0.7110, label = "Dead Drop — Pyrewood Village", kind = "location", detail = "A chest in a hut beside Pyrewood Village" },
        },
    },
    [78699] = {
        name = "The Eye of Bhossca",
        pickup = "Dead Drop, Pyrewood Village, Silverpine Forest",
        turnin = "Dead Drop, Pyrewood Village, Silverpine Forest",
        summary = "Offered after C's next letter reaches you in a capital city.",
        warning = "Solo job: you must do it alone, outside any group.",
        steps = {
            { text = "Interact with: table: 010DB4E8", kind = "object", mapID = 1421, x = 0.4710, y = 0.7110 },
        },
        pins = {
            { mapID = 1421, x = 0.4710, y = 0.7110, label = "Dead Drop — Pyrewood Village", kind = "start", detail = "A chest in a hut beside Pyrewood Village" },
        },
    },
    [79007] = {
        pickup = "Burned-Out Remains at the burnt tower on the road south of Camp Taurajo, The Barrens (46.3, 73.9)",
        turnin = "Burned-Out Remains in the cart wreckage at the Alexston Farmstead, Westfall (37.3, 50.6)",
        pins = {
            { mapID = 1413, x = 0.4630, y = 0.7390, label = "Burned-Out Remains — The Barrens", kind = "location", detail = "The burnt tower on the road south of Camp Taurajo" },
            { mapID = 1436, x = 0.3730, y = 0.5060, label = "Burned-Out Remains — Westfall", kind = "turnin", detail = "The cart wreckage at the Alexston Farmstead" },
        },
    },
    [79008] = {
        pickup = "Burned-Out Remains in the cart wreckage at the Alexston Farmstead, Westfall (37.3, 50.6)",
        turnin = "Burned-Out Remains at the burnt tower on the road south of Camp Taurajo, The Barrens (46.3, 73.9)",
        pins = {
            { mapID = 1436, x = 0.3730, y = 0.5060, label = "Burned-Out Remains — Westfall", kind = "location", detail = "The cart wreckage at the Alexston Farmstead" },
            { mapID = 1413, x = 0.4630, y = 0.7390, label = "Burned-Out Remains — The Barrens", kind = "turnin", detail = "The burnt tower on the road south of Camp Taurajo" },
        },
    },
    [79192] = {
        pickup = "Nailed Plank on the side of the burnt tower south of Camp Taurajo, The Barrens (46.4, 73.8)",
        turnin = "Pocket Litter on a box at the abandoned camp, Stonetalon Mountains (40.8, 52.6)",
        summary = "Take the path north-east of Sun Rock Retreat (50.9, 52.3) up to the abandoned camp; the Pocket Litter lies on a box. Optional: light the Firepit in the middle of the camp with the Simple Wood and Flint and Tinder from this quest (Rekindle).",
        steps = {
            { text = "Take the path north-east of Sun Rock Retreat (50.9, 52.3) up to the abandoned camp; the Pocket Litter lies on a box. Optional: light the Firepit in the middle of the camp with the Simple Wood and Flint and Tinder from this quest (Rekindle).", kind = "guide", mapID = 1413, x = 0.4640, y = 0.7380 },
        },
        pins = {
            { mapID = 1413, x = 0.4640, y = 0.7380, label = "Nailed Plank — The Barrens", kind = "location", detail = "Beside the Burned-Out Remains, south of Camp Taurajo" },
            { mapID = 1442, x = 0.4080, y = 0.5260, label = "Pocket Litter — Stonetalon Mountains", kind = "turnin", detail = "On a box at the abandoned camp" },
        },
    },
    [79358] = {
        pickup = "Veyric Thunderhame, Arathi Highlands (59.6, 27.6)",
        turnin = "Veyric Thunderhame, Arathi Highlands (59.6, 27.6)",
        summary = "Twisted Totems only drop while this quest is in your log. Water: Mirefin murlocs, northeast coast of Dustwallow Marsh. Air: Maraudine centaurs, Desolace. Earth: Lost Ones, Swamp of Sorrows. Fire: Dustbelcher ogres and Stonevault troggs, Badlands.",
        steps = {
            { text = "Twisted Totems only drop while this quest is in your log. Water: Mirefin murlocs, northeast coast of Dustwallow Marsh. Air: Maraudine centaurs, Desolace. Earth: Lost Ones, Swamp of Sorrows. Fire: Dustbelcher ogres and Stonevault troggs, Badlands.", kind = "guide", mapID = 1417, x = 0.5960, y = 0.2760 },
        },
        pins = {
            { mapID = 1417, x = 0.5960, y = 0.2760, label = "Veyric Thunderhame — Arathi Highlands", kind = "location" },
        },
    },
    [79360] = {
        pickup = "Rau Cliffrunner, Freewind Post, Thousand Needles (46.0, 51.6)",
        turnin = "Rau Cliffrunner, Freewind Post, Thousand Needles (46.0, 51.6)",
        summary = "The Razorfen Kraul step. After Call of Air, Prate Cloudseer sends you to Rau Cliffrunner. It can't be shared on the Horde side.",
        steps = {
            { text = "Get [Tattered Note]: Drops from Charlga Razorflank in Razorfen Kraul, for every Shaman on the quest", kind = "item", itemID = 274463, itemName = "Tattered Note" },
            { text = "Turn in: Rau Cliffrunner, Freewind Post, Thousand Needles (46.0, 51.6)", kind = "turnin" },
        },
        items = {
            { id = 274463, name = "Tattered Note", role = "required", source = "Drops from Charlga Razorflank in Razorfen Kraul, for every Shaman on the quest" },
        },
        pins = {
            { mapID = 1441, x = 0.4600, y = 0.5160, label = "Rau Cliffrunner — Freewind Post", kind = "location" },
        },
    },
    [79361] = {
        pickup = "Prate Cloudseer, The Weathered Nook, Thousand Needles (53, 42)",
        turnin = "Prate Cloudseer, The Weathered Nook, Thousand Needles (53, 42)",
        summary = "Twisted Totems only drop while this quest is in your log. Water: Mirefin murlocs, northeast coast of Dustwallow Marsh. Air: Maraudine centaurs, Desolace. Earth: Lost Ones, Swamp of Sorrows. Fire: Dustbelcher ogres and Stonevault troggs, Badlands.",
        steps = {
            { text = "Twisted Totems only drop while this quest is in your log. Water: Mirefin murlocs, northeast coast of Dustwallow Marsh. Air: Maraudine centaurs, Desolace. Earth: Lost Ones, Swamp of Sorrows. Fire: Dustbelcher ogres and Stonevault troggs, Badlands.", kind = "guide", mapID = 1441, x = 0.5300, y = 0.4200 },
        },
        pins = {
            { mapID = 1441, x = 0.5300, y = 0.4200, label = "Prate Cloudseer — The Weathered Nook", kind = "location", detail = "In the cave up the ledge on the north wall, northeast of Freewind Post" },
        },
    },
    [79364] = {
        pickup = "Rau Cliffrunner, Freewind Post, Thousand Needles (46.0, 51.6)",
        turnin = "Prate Cloudseer, The Weathered Nook, Thousand Needles (53, 42)",
        pins = {
            { mapID = 1441, x = 0.4600, y = 0.5160, label = "Rau Cliffrunner — Freewind Post", kind = "location" },
            { mapID = 1441, x = 0.5300, y = 0.4200, label = "Prate Cloudseer — The Weathered Nook", kind = "turnin", detail = "In the cave up the ledge on the north wall, northeast of Freewind Post" },
        },
    },
    [79366] = {
        pickup = "Prate Cloudseer, The Weathered Nook, Thousand Needles (53, 42)",
        turnin = "Prate Cloudseer, The Weathered Nook, Thousand Needles (53, 42)",
        summary = "Elite, level 40: bring a group. At the steam pools in Thousand Needles, stand on the rune circle and use the Corrupted Totems. Waves of elementals come, then an elite quilboar and the Ravaging Tempest, which drops the Eye of the Tempest for every Shaman on the quest. Horde: givers not confirmed yet, follow your quest log.",
        steps = {
            { text = "Elite, level 40: bring a group. At the steam pools in Thousand Needles, stand on the rune circle and use the Corrupted Totems. Waves of elementals come, then an elite quilboar and the Ravaging Tempest, which drops the Eye of the Tempest for every Shaman on the quest. Horde: givers not confirmed yet, follow your quest log.", kind = "guide", mapID = 1441, x = 0.5300, y = 0.4200 },
        },
        pins = {
            { mapID = 1441, x = 0.5300, y = 0.4200, label = "Prate Cloudseer — The Weathered Nook", kind = "location", detail = "In the cave up the ledge on the north wall, northeast of Freewind Post" },
        },
    },
    [79442] = {
        name = "The Tempest's Weapons",
        pickup = "Prate Cloudseer, Thousand Needles (follow your quest log)",
        turnin = "Bath'rah the Windwatcher, Alterac Mountains (80.4, 66.8)",
        summary = "Final step. Choose Rage of the Storm, Lightning's Grasp or Tidebringer's Claw.",
        warning = "This is a chain quest with a step in Razorfen Kraul",
        steps = {
            { text = "Prereq chain (4): Elemental Aid -> Eyes on the Sky -> Storm, Earth, and Fire (+1 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1441, x = 0.5300, y = 0.4200, label = "Prate Cloudseer — The Weathered Nook", kind = "start", detail = "In the cave up the ledge on the north wall, northeast of Freewind Post" },
        },
    },
    [79939] = {
        pickup = "Broken Warhammer, Mannoroc Coven, Desolace",
        turnin = "Katherine the Pure, Cathedral of Light, Stormwind",
        pins = {
            { mapID = 1443, x = 0.5270, y = 0.8480, label = "Broken Warhammer — Mannoroc Coven, Desolace", kind = "location" },
            { mapID = 1453, x = 0.4850, y = 0.4910, label = "Katherine the Pure — Cathedral of Light, Stormwind", kind = "turnin" },
        },
    },
    [79940] = {
        pickup = "Katherine the Pure, Cathedral of Light, Stormwind",
        turnin = "Katherine the Pure, Cathedral of Light, Stormwind",
        pins = {
            { mapID = 1453, x = 0.4850, y = 0.4910, label = "Katherine the Pure — Cathedral of Light, Stormwind", kind = "location" },
        },
    },
    [79945] = {
        pickup = "Orders, looted from the assassin at Aeonas's hut, Wetlands coast",
        turnin = "Katherine the Pure, Cathedral of Light, Stormwind",
        pins = {
            { mapID = 1453, x = 0.4850, y = 0.4910, label = "Katherine the Pure — Cathedral of Light, Stormwind", kind = "turnin" },
        },
    },
    [79946] = {
        name = "A Brother In Need",
        pickup = "Katherine the Pure, Cathedral of Light, Stormwind",
        turnin = "Aeonas, rear chamber of the Cathedral, inside the dungeon",
        summary = "Aeonas is in the rear chamber of the Cathedral. Finish Katherine's talk about Aeonas before you leave: players report that skipping it can block the next step. The chain before it (players' reports): the Strange Orb chain from Darkshore, then Katherine's quests from level 35.  Next, from Aeonas inside the dungeon:",
        warning = "Long chain quest: it starts with the Strange Orb in Darkshore",
        steps = {
            { text = "Prereq chain (10): A Strange Artifact -> Advice From Stormwind -> A Second Opinion (+7 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1453, x = 0.4850, y = 0.4910, label = "Katherine the Pure — Cathedral of Light, Stormwind", kind = "start" },
        },
    },
    [79963] = {
        name = "By The Light's Grace",
        pickup = "Aeonas, rear chamber of the Cathedral, inside the dungeon",
        turnin = "Aeonas, inside the dungeon",
        summary = "Follows A Brother In Need, inside the Cathedral.  Then, in Stormwind:",
        steps = {
            { text = "Follows A Brother In Need, inside the Cathedral.  Then, in Stormwind:", kind = "guide" },
        },
    },
    [79970] = {
        name = "Aeonas the Vindicated",
        pickup = "Aeonas, inside the dungeon",
        turnin = "Aeonas, Cathedral of Light, Stormwind",
        summary = "The end of the chain, after By The Light's Grace.",
        steps = {
            { text = "The end of the chain, after By The Light's Grace.", kind = "guide" },
        },
    },
    [79974] = {
        pickup = "Mound of Dirt below the cliff north of the camp, Stonetalon Mountains (39.6, 49.9)",
        turnin = "Carved Figurine on the carved heads of the Stonewrought Dam, Loch Modan (49.4, 12.9)",
        summary = "Jump onto the carved heads of the dam, on the side facing the Wetlands, to reach the figurine. Getting there is tricky for the Horde.",
        steps = {
            { text = "Jump onto the carved heads of the dam, on the side facing the Wetlands, to reach the figurine. Getting there is tricky for the Horde.", kind = "guide", mapID = 1442, x = 0.3960, y = 0.4990 },
        },
        pins = {
            { mapID = 1442, x = 0.3960, y = 0.4990, label = "Mound of Dirt — Stonetalon Mountains", kind = "location", detail = "Below the cliff north of the abandoned camp" },
            { mapID = 1432, x = 0.4940, y = 0.1290, label = "Carved Figurine — Stonewrought Dam", kind = "turnin", detail = "On the carved heads of the dam, facing the Wetlands" },
        },
    },
    [79975] = {
        pickup = "Carved Figurine on the carved heads of the Stonewrought Dam, Loch Modan (49.4, 12.9)",
        turnin = "Messenger Bag hanging at Thoradin's Wall, Hillsbrad Foothills (85.7, 52.2)",
        summary = "Climb into Thoradin's Wall from the cart on the Hillsbrad side (87.3, 49.6), go through the room in the wall and look outside to the right: the bag hangs there.",
        steps = {
            { text = "Climb into Thoradin's Wall from the cart on the Hillsbrad side (87.3, 49.6), go through the room in the wall and look outside to the right: the bag hangs there.", kind = "guide", mapID = 1432, x = 0.4940, y = 0.1290 },
        },
        pins = {
            { mapID = 1432, x = 0.4940, y = 0.1290, label = "Carved Figurine — Stonewrought Dam", kind = "location", detail = "On the carved heads of the dam, facing the Wetlands" },
            { mapID = 1424, x = 0.8570, y = 0.5220, label = "Messenger Bag — Thoradin's Wall", kind = "turnin", detail = "Hanging outside the room in Thoradin's Wall" },
        },
    },
    [79976] = {
        name = "This Must Be The Place",
        pickup = "Messenger Bag hanging at Thoradin's Wall, Hillsbrad Foothills (85.7, 52.2)",
        turnin = "Hastily Rolled-Up Satchel, right under the Messenger Bag",
        steps = {
            { text = "Prereq chain (5): ... and that note you found -> Stepping Stones -> Scramble (+2 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1424, x = 0.8570, y = 0.5220, label = "Messenger Bag — Thoradin's Wall", kind = "start", detail = "Hanging outside the room in Thoradin's Wall" },
        },
    },
    [79980] = {
        pickup = "Pocket Litter on a box at the abandoned camp, Stonetalon Mountains (40.8, 52.6)",
        turnin = "Mound of Dirt below the cliff north of the camp, Stonetalon Mountains (39.6, 49.9)",
        summary = "Head straight north from the camp, climb the hill and jump down from its edge to the Mound of Dirt. Watch your step.",
        steps = {
            { text = "Head straight north from the camp, climb the hill and jump down from its edge to the Mound of Dirt. Watch your step.", kind = "guide", mapID = 1442, x = 0.4080, y = 0.5260 },
        },
        pins = {
            { mapID = 1442, x = 0.4080, y = 0.5260, label = "Pocket Litter — Stonetalon Mountains", kind = "location", detail = "On a box at the abandoned camp" },
            { mapID = 1442, x = 0.3960, y = 0.4990, label = "Mound of Dirt — Stonetalon Mountains", kind = "turnin", detail = "Below the cliff north of the abandoned camp" },
        },
    },
    [82062] = {
        name = "Ever After",
        pickup = "Rugged Traveler, on a hidden ledge above the lava, Blackrock Depths",
        turnin = "Rugged Traveler, Blackrock Depths",
        summary = "Take the bridge just east of the Ring of Law that runs north over the lava and clear it. On its left side, by the small brazier, jump from the railing onto the platform against the wall, follow it to the corner and keep your left shoulder on the wall until you drop onto the rock ledge below: the Rugged Traveler is there. The door on the ledge takes you to a ledge above Lord Incendius; there is no way back. Not shareable.",
        steps = {
            { text = "Take the bridge just east of the Ring of Law that runs north over the lava and clear it. On its left side, by the small brazier, jump from the railing onto the platform against the wall, follow it to the corner and keep your left shoulder on the wall until you drop onto the rock ledge below: the Rugged Traveler is there. The door on the ledge takes you to a ledge above Lord Incendius; there is no way back. Not shareable.", kind = "guide" },
        },
    },
    [82084] = {
        name = "A Lesson in Literacy",
        pickup = "Garion Wendell, Stormwind (Alliance) or Owen Thadd, Undercity (Horde)",
        turnin = "Garion Wendell, Stormwind (Alliance) or Owen Thadd, Undercity (Horde)",
        summary = "Mage class quest.",
        steps = {
            { text = "Get [Pristine Owlbeast Quill]: Dropped by Vicious, Primitive and Savage Owlbeasts in The Hinterlands", kind = "item", itemID = 221359, itemName = "Pristine Owlbeast Quill", mapID = 1425, x = 0.5400, y = 0.4520 },
            { text = "Get [Zukk'ash Resin]: Dropped by the Zukk'ash silithid in Feralas, south of Camp Mojache (around 73, 63)", kind = "item", itemID = 221361, itemName = "Zukk'ash Resin", mapID = 1444, x = 0.7300, y = 0.6300 },
            { text = "Get [Farraki Papyrus]: Dropped by the Zul'Farrak Zombies that rise from the graves in Zul'Farrak", kind = "item", itemID = 221360, itemName = "Farraki Papyrus" },
            { text = "Turn in: Garion Wendell, Stormwind (Alliance) or Owen Thadd, Undercity (Horde)", kind = "turnin" },
        },
        items = {
            { id = 221359, name = "Pristine Owlbeast Quill", role = "required", source = "Dropped by Vicious, Primitive and Savage Owlbeasts in The Hinterlands" },
            { id = 221361, name = "Zukk'ash Resin", role = "required", source = "Dropped by the Zukk'ash silithid in Feralas, south of Camp Mojache (around 73, 63)" },
            { id = 221360, name = "Farraki Papyrus", role = "required", source = "Dropped by the Zul'Farrak Zombies that rise from the graves in Zul'Farrak" },
        },
        pins = {
            { mapID = 1453, x = 0.4880, y = 0.8660, label = "Garion Wendell — Stormwind", kind = "start" },
        },
    },
    [86777] = {
        pickup = "Korsa, outside Legashi Stronghold, Azshara (63.0, 23.3)",
        turnin = "Korsa, outside Legashi Stronghold, Azshara (63.0, 23.3)",
        steps = {
            { text = "Get [Feardred's Amulet]: From Master Feardred", kind = "item", itemID = 235334, itemName = "Feardred's Amulet" },
            { text = "Turn in: Korsa, outside Legashi Stronghold, Azshara (63.0, 23.3)", kind = "turnin" },
        },
        items = {
            { id = 235334, name = "Feardred's Amulet", role = "required", source = "From Master Feardred" },
        },
        pins = {
            { mapID = 1447, x = 0.6300, y = 0.2330, label = "Korsa — Legashi Stronghold, Azshara", kind = "location" },
        },
    },
    [86792] = {
        pickup = "Korsa, outside Legashi Stronghold, Azshara (63.0, 23.3)",
        turnin = "Korsa, outside Legashi Stronghold, Azshara (63.0, 23.3)",
        pins = {
            { mapID = 1447, x = 0.6300, y = 0.2330, label = "Korsa — Legashi Stronghold, Azshara", kind = "location" },
        },
    },
    [86796] = {
        pickup = "Graal, caged in Legashi Stronghold, Azshara (65.9, 14.4)",
        turnin = "Korsa, outside Legashi Stronghold, Azshara (63.0, 23.3)",
        pins = {
            { mapID = 1447, x = 0.6590, y = 0.1440, label = "Graal — Legashi Stronghold, Azshara", kind = "location" },
            { mapID = 1447, x = 0.6300, y = 0.2330, label = "Korsa — Legashi Stronghold, Azshara", kind = "turnin" },
        },
    },
    [86797] = {
        pickup = "Korsa, outside Legashi Stronghold, Azshara (63.0, 23.3)",
        turnin = "Gatekeeper Rageroar, Ursolan, Azshara (42.4, 20.2)",
        pins = {
            { mapID = 1447, x = 0.6300, y = 0.2330, label = "Korsa — Legashi Stronghold, Azshara", kind = "location" },
            { mapID = 1447, x = 0.4240, y = 0.2020, label = "Gatekeeper Rageroar — Ursolan, Azshara", kind = "turnin" },
        },
    },
    [86798] = {
        pickup = "Gatekeeper Rageroar, Ursolan, Azshara (42.4, 20.2)",
        turnin = "Gorn One Eye, Timbermaw Hold",
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.2020, label = "Gatekeeper Rageroar — Ursolan, Azshara", kind = "location" },
            { mapID = 1448, x = 0.6520, y = 0.0260, label = "Gorn One Eye — Timbermaw Hold, Felwood", kind = "turnin" },
        },
    },
    [86814] = {
        pickup = "Gorn One Eye, Timbermaw Hold",
        turnin = "Gatekeeper Rageroar, Ursolan, Azshara (42.4, 20.2)",
        summary = "Elite quest: bring a group for Prince Halanox.",
        steps = {
            { text = "Use provided [Timbermaw War Banner] (Given by Gorn One Eye when you accept the quest)", kind = "provided", itemID = 235518, itemName = "Timbermaw War Banner" },
            { text = "Turn in: Gatekeeper Rageroar, Ursolan, Azshara (42.4, 20.2)", kind = "turnin", mapID = 1447, x = 0.4240, y = 0.2020 },
        },
        items = {
            { id = 235518, name = "Timbermaw War Banner", role = "provided", source = "Given by Gorn One Eye when you accept the quest" },
        },
        pins = {
            { mapID = 1448, x = 0.6520, y = 0.0260, label = "Gorn One Eye — Timbermaw Hold, Felwood", kind = "location" },
            { mapID = 1447, x = 0.4240, y = 0.2020, label = "Gatekeeper Rageroar — Ursolan, Azshara", kind = "turnin" },
        },
    },
    [87346] = {
        pickup = "Gorn One Eye, Timbermaw Hold",
        turnin = "Gorn One Eye, Timbermaw Hold",
        summary = "Chieftain Bloodmaw is in Felwood, south of Timbermaw Hold.",
        steps = {
            { text = "Get [Bloodmaw's Basher]: From Chieftain Bloodmaw", kind = "item", itemID = 236631, itemName = "Bloodmaw's Basher" },
            { text = "Turn in: Gorn One Eye, Timbermaw Hold", kind = "turnin" },
        },
        items = {
            { id = 236631, name = "Bloodmaw's Basher", role = "required", source = "From Chieftain Bloodmaw" },
        },
        pins = {
            { mapID = 1448, x = 0.6520, y = 0.0260, label = "Gorn One Eye — Timbermaw Hold, Felwood", kind = "location" },
        },
    },
    [91858] = {
        pickup = "Danitha Morr, Bandarion Keep, Tirisfal Glades",
        turnin = "Trevan Rol, The Sepulcher, Silverpine Forest",
        pins = {
            { mapID = 1420, x = 0.2200, y = 0.4460, label = "Danitha Morr — Bandarion Keep, Tirisfal Glades", kind = "location" },
            { mapID = 1421, x = 0.4340, y = 0.4100, label = "Trevan Rol — The Sepulcher", kind = "turnin" },
        },
    },
    [91859] = {
        pickup = "Trevan Rol, The Sepulcher, Silverpine Forest",
        turnin = "Deathguard Baldren, The Sepulcher, Silverpine Forest",
        pins = {
            { mapID = 1421, x = 0.4340, y = 0.4100, label = "Trevan Rol — The Sepulcher", kind = "location" },
            { mapID = 1421, x = 0.4560, y = 0.4180, label = "Deathguard Baldren — The Sepulcher", kind = "turnin" },
        },
    },
    [91860] = {
        pickup = "Deathguard Baldren, The Sepulcher, Silverpine Forest",
        turnin = "Charred Remains, Fenris Isle, Silverpine Forest",
        pins = {
            { mapID = 1421, x = 0.4560, y = 0.4180, label = "Deathguard Baldren — The Sepulcher", kind = "location" },
            { mapID = 1421, x = 0.6500, y = 0.3420, label = "Charred Remains — Fenris Isle", kind = "turnin" },
        },
    },
    [91861] = {
        pickup = "Charred Remains, Fenris Isle, Silverpine Forest",
        turnin = "Lumina Windsinger, Fenris Keep, Silverpine Forest",
        pins = {
            { mapID = 1421, x = 0.6500, y = 0.3420, label = "Charred Remains — Fenris Isle", kind = "location" },
            { mapID = 1421, x = 0.6570, y = 0.2740, label = "Lumina Windsinger — Fenris Keep", kind = "turnin" },
        },
    },
    [91862] = {
        pickup = "Lumina Windsinger, Fenris Keep, Silverpine Forest",
        turnin = "Lumina Windsinger, Fenris Keep, Silverpine Forest",
        steps = {
            { text = "Get [Fenris Isle Key]: Dropped by the Rot Hide gnolls on Fenris Isle (Rot Hide Savage, Raging Rot Hide, Rot Hide Bruiser, Snarlmane)", kind = "item", itemID = 267412, itemName = "Fenris Isle Key", mapID = 1421, x = 0.6560, y = 0.2380 },
            { text = "Turn in: Lumina Windsinger, Fenris Keep, Silverpine Forest", kind = "turnin" },
        },
        items = {
            { id = 267412, name = "Fenris Isle Key", role = "required", source = "Dropped by the Rot Hide gnolls on Fenris Isle (Rot Hide Savage, Raging Rot Hide, Rot Hide Bruiser, Snarlmane)" },
        },
        pins = {
            { mapID = 1421, x = 0.6570, y = 0.2740, label = "Lumina Windsinger — Fenris Keep", kind = "location" },
            { mapID = 1421, x = 0.6560, y = 0.2380, label = "Rot Hide gnolls — Fenris Isle", kind = "item", detail = "Dropped by the Rot Hide gnolls on Fenris Isle (Rot Hide Savage, Raging Rot Hide, Rot Hide Bruiser, Snarlmane)" },
        },
    },
    [92065] = {
        name = "Blackmaw Reclamation",
        pickup = "Gatekeeper Rageroar, Ursolan, Azshara (42.4, 20.2)",
        turnin = "Gatekeeper Rageroar, Ursolan, Azshara (42.4, 20.2)",
        summary = "Varrox Bleakhoof, the last boss, has the head. Comes after the Blackmaw Counter-Offensive chain. Players report it needs Timbermaw Hold reputation Friendly.",
        steps = {
            { text = "Prereq chain (7): Master Feardred -> Thinning Their Forces -> Later, Satyr (+4 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.2020, label = "Gatekeeper Rageroar — Ursolan, Azshara", kind = "start" },
        },
    },
    [92066] = {
        name = "The Twin Bears",
        pickup = "Lorekeeper Nok, Ursolan, Azshara (41.4, 20.0)",
        turnin = "Lorekeeper Nok, Ursolan, Azshara (41.4, 20.0)",
        summary = "Needs Timbermaw Hold reputation Neutral or better.",
        steps = {
            { text = "Needs Timbermaw Hold reputation Neutral or better.", kind = "guide", mapID = 1447, x = 0.4140, y = 0.2000 },
        },
        pins = {
            { mapID = 1447, x = 0.4140, y = 0.2000, label = "Lorekeeper Nok — Ursolan, Azshara", kind = "start" },
        },
    },
    [92067] = {
        name = "Feeding Time!",
        pickup = "Not known yet",
        turnin = "Not known yet",
        summary = "Repeatable. By its completion text you feed the flesh to a hungry lasher, which spits out a seed pod. Where it is isn't known yet; please report it on Discord.",
        steps = {
            { text = "Repeatable. By its completion text you feed the flesh to a hungry lasher, which spits out a seed pod. Where it is isn't known yet; please report it on Discord.", kind = "guide" },
        },
    },
    [92069] = {
        name = "Claws That Rend, Tusks that Gore",
        pickup = "Ogtinc, Azshara (42.4, 42.7)",
        turnin = "Ogtinc, Azshara (42.4, 42.7)",
        summary = "Withermaw and Bonesnout are on different paths: take both.",
        steps = {
            { text = "Get [Claws of the Great Bear]: From Withermaw in Blackmaw Hold", kind = "item", itemID = 249697, itemName = "Claws of the Great Bear" },
            { text = "Get [Tusks of the Unbroken]: From Bonesnout the Unbroken in Blackmaw Hold", kind = "item", itemID = 249696, itemName = "Tusks of the Unbroken" },
            { text = "Turn in: Ogtinc, Azshara (42.4, 42.7)", kind = "turnin", mapID = 1447, x = 0.4240, y = 0.4270 },
        },
        items = {
            { id = 249697, name = "Claws of the Great Bear", role = "required", source = "From Withermaw in Blackmaw Hold" },
            { id = 249696, name = "Tusks of the Unbroken", role = "required", source = "From Bonesnout the Unbroken in Blackmaw Hold" },
        },
        pins = {
            { mapID = 1447, x = 0.4240, y = 0.4270, label = "Ogtinc — Azshara", kind = "turnin" },
        },
    },
    [92070] = {
        name = "A Lost Memento",
        pickup = "Item start: Feathered Charm Necklace, looted in Blackmaw Hold",
        turnin = "Unele, Ursolan, Azshara (43.4, 17.4)",
        steps = {
            { text = "Start with [Feathered Charm Necklace] (Looted from satyrs and imps in Blackmaw Hold)", kind = "starter", itemID = 249698, itemName = "Feathered Charm Necklace", mapID = 1447, x = 0.4340, y = 0.1740 },
        },
        items = {
            { id = 249698, name = "Feathered Charm Necklace", role = "starter", source = "Looted from satyrs and imps in Blackmaw Hold" },
        },
        pins = {
            { mapID = 1447, x = 0.4340, y = 0.1740, label = "Unele — Ursolan, Azshara", kind = "turnin" },
        },
    },
    [92343] = {
        name = "Get to the Roots of It",
        pickup = "Nara Wildmane, Elder Rise, Thunder Bluff (75.6, 31.0)",
        turnin = "Nara Wildmane, Elder Rise, Thunder Bluff (75.6, 31.0)",
        steps = {
            { text = "Prereq chain (1): Beneath Nordrassil", kind = "quest" },
            { text = "Get [Nordrassil Root Cap]: Looted inside Blackmaw Hold; everyone in the party can loot them (10 needed)", kind = "item", itemID = 250773, itemName = "Nordrassil Root Cap" },
            { text = "Turn in: Nara Wildmane, Elder Rise, Thunder Bluff (75.6, 31.0)", kind = "turnin", mapID = 1456, x = 0.7560, y = 0.3100 },
        },
        items = {
            { id = 250773, name = "Nordrassil Root Cap", role = "required", source = "Looted inside Blackmaw Hold; everyone in the party can loot them (10 needed)" },
        },
        pins = {
            { mapID = 1456, x = 0.7560, y = 0.3100, label = "Nara Wildmane — Elder Rise, Thunder Bluff", kind = "turnin" },
        },
    },
    [92344] = {
        name = "Get to the Roots of It",
        pickup = "Mathrengyl Bearwalker, Cenarion Enclave, Darnassus (35.4, 8.4)",
        turnin = "Mathrengyl Bearwalker, Cenarion Enclave, Darnassus (35.4, 8.4)",
        steps = {
            { text = "Prereq chain (1): Beneath Nordrassil", kind = "quest" },
            { text = "Get [Nordrassil Root Cap]: Looted inside Blackmaw Hold; everyone in the party can loot them (10 needed)", kind = "item", itemID = 250773, itemName = "Nordrassil Root Cap" },
            { text = "Turn in: Mathrengyl Bearwalker, Cenarion Enclave, Darnassus (35.4, 8.4)", kind = "turnin", mapID = 1457, x = 0.3540, y = 0.0840 },
        },
        items = {
            { id = 250773, name = "Nordrassil Root Cap", role = "required", source = "Looted inside Blackmaw Hold; everyone in the party can loot them (10 needed)" },
        },
        pins = {
            { mapID = 1457, x = 0.3540, y = 0.0840, label = "Mathrengyl Bearwalker — Cenarion Enclave, Darnassus", kind = "turnin" },
        },
    },
    [92345] = {
        pickup = "Commander Truesong, Azshara (11.8, 78.3)",
        turnin = "Mathrengyl Bearwalker, Cenarion Enclave, Darnassus",
        pins = {
            { mapID = 1447, x = 0.1180, y = 0.7830, label = "Commander Truesong — Azshara", kind = "location" },
            { mapID = 1457, x = 0.3540, y = 0.0840, label = "Mathrengyl Bearwalker — Cenarion Enclave, Darnassus", kind = "turnin" },
        },
    },
    [92346] = {
        pickup = "Jediga, Valormok, Azshara (22.5, 51.4)",
        turnin = "Nara Wildmane, Elder Rise, Thunder Bluff",
        pins = {
            { mapID = 1447, x = 0.2250, y = 0.5140, label = "Jediga — Valormok, Azshara", kind = "location" },
            { mapID = 1456, x = 0.7560, y = 0.3100, label = "Nara Wildmane — Elder Rise, Thunder Bluff", kind = "turnin" },
        },
    },
    [92401] = {
        name = "A Frightened Request",
        pickup = "Tabitha Heartweaver, Silverpine Forest / The Sepulcher",
        turnin = "Tabitha Heartweaver, The Sepulcher, Silverpine Forest",
        pins = {
            { mapID = 1421, x = 0.4450, y = 0.4300, label = "Tabitha Heartweaver — The Sepulcher", kind = "start" },
        },
    },
    [92415] = {
        name = "Remember That I Love You",
        pickup = "Item start: Blood-Stained Letter, graveyard inside Ruins of Lordaeron",
        turnin = "Orphan Matron Nightingale, Stormwind City",
        summary = "Item-start quest from the Blood-Stained Letter.",
        steps = {
            { text = "Start with [Blood-Stained Letter] (Found in the graveyard inside Ruins of Lordaeron)", kind = "starter", itemID = 251522, itemName = "Blood-Stained Letter" },
        },
        items = {
            { id = 251522, name = "Blood-Stained Letter", role = "starter", source = "Found in the graveyard inside Ruins of Lordaeron" },
        },
    },
    [92421] = {
        name = "Light's Justice",
        pickup = "Morbin Lightbane, Undercity",
        turnin = "Morbin Lightbane, Undercity",
        pins = {
            { mapID = 1458, x = 0.5790, y = 0.8950, label = "Morbin Lightbane — Royal Quarter", kind = "start" },
        },
    },
    [92422] = {
        name = "The Wrath of Rath'mael",
        pickup = "Deathguard Kristof, Brill, Tirisfal Glades",
        turnin = "Deathguard Kristof, Brill",
        steps = {
            { text = "Prereq chain (2): Rear Guard Patrol -> Rear Guard Patrol", kind = "quest" },
        },
        pins = {
            { mapID = 1420, x = 0.6520, y = 0.6020, label = "Deathguard Kristof — southeast of Brill", kind = "start" },
        },
    },
    [92432] = {
        pickup = "Emissary Jacques, Southshore, Hillsbrad Foothills",
        turnin = "Image of Archmage Modera, Lordamere Lake near Dalaran",
        summary = "Introductory quest leading to Heart of Disruption and Starving Arcane.",
        steps = {
            { text = "Introductory quest leading to Heart of Disruption and Starving Arcane.", kind = "guide", mapID = 1424, x = 0.4840, y = 0.6020 },
        },
        pins = {
            { mapID = 1424, x = 0.4840, y = 0.6020, label = "Emissary Jacques — Southshore", kind = "location", detail = "Emissary Jacques in Southshore, Hillsbrad Foothills" },
        },
    },
    [92434] = {
        pickup = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
        turnin = "Image of Archmage Modera, Lordamere Lake near Dalaran",
        summary = "Requires Magus Wordeen Voidglare's Dalaran quests. Stone Tokens and Bracers of Binding from Keeper Bel'varil are optional and are not required for attunement.",
        steps = {
            { text = "Use provided [Grimy Key] (Provided for Blood in the Streets)", kind = "provided", itemID = 279469, itemName = "Grimy Key" },
            { text = "Turn in: Image of Archmage Modera, Lordamere Lake near Dalaran", kind = "turnin", mapID = 1416, x = 0.0770, y = 0.5880 },
        },
        items = {
            { id = 279469, name = "Grimy Key", role = "provided", source = "Provided for Blood in the Streets" },
        },
        pins = {
            { mapID = 1424, x = 0.6150, y = 0.2070, label = "Magus Wordeen Voidglare — Tarren Mill", kind = "location", detail = "Inside the building in Tarren Mill" },
            { mapID = 1416, x = 0.0770, y = 0.5880, label = "Image of Archmage Modera — Lordamere Lake near Dalaran", kind = "turnin", detail = "Outside Dalaran near Lordamere Lake" },
        },
    },
    [92456] = {
        name = "A Green Sample",
        pickup = "Shylamiir, Stormwind City",
        turnin = "Shylamiir, Stormwind City",
        summary = "Quest data is recorded in the beta; dungeon access may be unavailable.",
        steps = {
            { text = "Quest data is recorded in the beta; dungeon access may be unavailable.", kind = "guide", mapID = 1453, x = 0.3140, y = 0.6280 },
        },
        pins = {
            { mapID = 1453, x = 0.3140, y = 0.6280, label = "Shylamiir — Stormwind City", kind = "start" },
            { mapID = 1453, x = 0.3150, y = 0.6260, label = "Shylamiir — Stormwind", kind = "start" },
        },
    },
    [92457] = {
        name = "Starving Arcane",
        pickup = "Image of Archmage Modera, Lordamere Lake near Dalaran",
        turnin = "Image of Archmage Modera, Lordamere Lake near Dalaran",
        summary = "There may not be enough of these mobs inside to finish it in one run.",
        steps = {
            { text = "Prereq chain (1): An Alarming Request", kind = "quest" },
        },
        pins = {
            { mapID = 1416, x = 0.0770, y = 0.5880, label = "Image of Archmage Modera — Lordamere Lake near Dalaran", kind = "start" },
            { mapID = 1421, x = 0.6840, y = 0.4520, label = "Image of Archmage Modera — Silverpine Forest", kind = "start" },
        },
    },
    [92458] = {
        name = "Heart of Disruption",
        pickup = "Image of Archmage Modera, Lordamere Lake near Dalaran",
        turnin = "Image of Archmage Modera, Lordamere Lake near Dalaran",
        steps = {
            { text = "Prereq chain (1): An Alarming Request", kind = "quest" },
            { text = "Use provided [Dalaran Sewer Key] (Provided when Heart of Disruption is accepted)", kind = "provided", itemID = 277507, itemName = "Dalaran Sewer Key" },
            { text = "Get [Arcane Mote]", kind = "item", itemID = 251961, itemName = "Arcane Mote" },
            { text = "Turn in: Image of Archmage Modera, Lordamere Lake near Dalaran", kind = "turnin" },
        },
        items = {
            { id = 277507, name = "Dalaran Sewer Key", role = "provided", source = "Provided when Heart of Disruption is accepted" },
            { id = 251961, name = "Arcane Mote", role = "required" },
        },
        pins = {
            { mapID = 1416, x = 0.0770, y = 0.5880, label = "Image of Archmage Modera — Lordamere Lake", kind = "start" },
            { mapID = 1421, x = 0.6840, y = 0.4520, label = "Image of Archmage Modera — Silverpine Forest", kind = "start" },
        },
    },
    [92489] = {
        name = "Power Overwhelming",
        pickup = "High Sorcerer Andromath, Stormwind City",
        turnin = "High Sorcerer Andromath, Stormwind City",
        summary = "Quest data is recorded in the beta; dungeon access may be unavailable.",
        steps = {
            { text = "Quest data is recorded in the beta; dungeon access may be unavailable.", kind = "guide", mapID = 1453, x = 0.4880, y = 0.8760 },
        },
        pins = {
            { mapID = 1453, x = 0.4880, y = 0.8760, label = "High Sorcerer Andromath — Stormwind City", kind = "start" },
            { mapID = 1453, x = 0.4880, y = 0.8740, label = "High Sorcerer Andromath — Stormwind", kind = "start" },
        },
    },
    [92742] = {
        pickup = "table: 00CF0B60",
        turnin = "table: 00CF0B60",
        summary = "First quest of the Toxic Soil chain.",
        steps = {
            { text = "First quest of the Toxic Soil chain.", kind = "guide", mapID = 1436, x = 0.5300, y = 0.5330 },
        },
        pins = {
            { mapID = 1436, x = 0.5300, y = 0.5330, label = "Alba Fairmoon — Sentinel Hill inn", kind = "location", detail = "Start Testing the Wells here" },
        },
    },
    [92744] = {
        pickup = "table: 00CF0B60",
        turnin = "table: 00CF0B60",
        summary = "Second quest of the Toxic Soil chain.",
        steps = {
            { text = "Second quest of the Toxic Soil chain.", kind = "guide", mapID = 1436, x = 0.5300, y = 0.5330 },
        },
        pins = {
            { mapID = 1436, x = 0.5300, y = 0.5330, label = "Alba Fairmoon — Sentinel Hill inn", kind = "location", detail = "Alba Fairmoon is inside the Sentinel Hill inn" },
        },
    },
    [92745] = {
        pickup = "table: 00CF0B60",
        turnin = "table: 00CF0B60",
        summary = "Investigate whether Westfall's mines are causing the contamination.",
        steps = {
            { text = "Investigate whether Westfall's mines are causing the contamination.", kind = "guide", mapID = 1436, x = 0.5300, y = 0.5330 },
        },
        pins = {
            { mapID = 1436, x = 0.5300, y = 0.5330, label = "Alba Fairmoon — Sentinel Hill inn", kind = "location", detail = "Alba Fairmoon is inside the Sentinel Hill inn" },
        },
    },
    [92747] = {
        pickup = "table: 00CF0B60",
        turnin = "table: 00CF0B60",
        summary = "The supplies are found in the caves leading toward the Deadmines entrance.",
        steps = {
            { text = "The supplies are found in the caves leading toward the Deadmines entrance.", kind = "guide", mapID = 1436, x = 0.5300, y = 0.5330 },
        },
        pins = {
            { mapID = 1436, x = 0.5300, y = 0.5330, label = "Alba Fairmoon — Sentinel Hill inn", kind = "location", detail = "Alba Fairmoon is inside the Sentinel Hill inn" },
        },
    },
    [92748] = {
        pickup = "table: 00CF0B60",
        turnin = "Sprite Jumpsprocket, Dwarven District, Stormwind",
        summary = "Begins the explosives portion of the Toxic Soil chain.",
        steps = {
            { text = "Begins the explosives portion of the Toxic Soil chain.", kind = "guide", mapID = 1436, x = 0.5300, y = 0.5330 },
        },
        pins = {
            { mapID = 1436, x = 0.5300, y = 0.5330, label = "Alba Fairmoon — Sentinel Hill inn", kind = "location", detail = "Alba Fairmoon is inside the Sentinel Hill inn" },
        },
    },
    [92749] = {
        pickup = "Sprite Jumpsprocket, Dwarven District, Stormwind",
        turnin = "Sprite Jumpsprocket, Dwarven District, Stormwind",
        summary = "Rough Dynamite can be crafted, traded or bought from the auction house.",
        steps = {
            { text = "Rough Dynamite can be crafted, traded or bought from the auction house.", kind = "guide", mapID = 1453, x = 0.6190, y = 0.3060 },
        },
        pins = {
            { mapID = 1453, x = 0.6190, y = 0.3060, label = "Sprite Jumpsprocket — Stormwind", kind = "start", detail = "Sprite Jumpsprocket: Dwarven District, Stormwind" },
        },
    },
    [92750] = {
        pickup = "Sprite Jumpsprocket, Dwarven District, Stormwind",
        turnin = "Jasper Fel, SI:7, Old Town, Stormwind",
        summary = "You need a remote detonator for the planned explosion.",
        steps = {
            { text = "You need a remote detonator for the planned explosion.", kind = "guide", mapID = 1453, x = 0.6190, y = 0.3060 },
        },
        pins = {
            { mapID = 1453, x = 0.6190, y = 0.3060, label = "Sprite Jumpsprocket — Stormwind", kind = "start", detail = "Sprite Jumpsprocket: Dwarven District, Stormwind" },
        },
    },
    [92751] = {
        pickup = "Jasper Fel, SI:7, Old Town, Stormwind",
        turnin = "Sprite Jumpsprocket, Dwarven District, Stormwind",
        summary = "Returns the remote detonator to the engineer.",
        steps = {
            { text = "Returns the remote detonator to the engineer.", kind = "guide", mapID = 1453, x = 0.8030, y = 0.7010 },
        },
        pins = {
            { mapID = 1453, x = 0.8030, y = 0.7010, label = "Jasper Fel — Stormwind", kind = "start", detail = "Jasper Fel: SI:7, Old Town, Stormwind" },
        },
    },
    [92752] = {
        pickup = "Sprite Jumpsprocket, Dwarven District, Stormwind",
        turnin = "table: 00CF0B60",
        summary = "Final preparation before Destruction in Deadmines.",
        steps = {
            { text = "Final preparation before Destruction in Deadmines.", kind = "guide", mapID = 1453, x = 0.6190, y = 0.3060 },
        },
        pins = {
            { mapID = 1453, x = 0.6190, y = 0.3060, label = "Sprite Jumpsprocket — Stormwind", kind = "start", detail = "Sprite Jumpsprocket: Dwarven District, Stormwind" },
        },
    },
    [92753] = {
        name = "Destruction in Deadmines",
        pickup = "Extra-Destructive Explosives quest-start item",
        turnin = "Alba Fairmoon, in the hills behind Moonbrook (at the Deadmines exit), Westfall",
        summary = "Plant the explosives beside the forge, then meet Alba Fairmoon at the Deadmines exit.",
        steps = {
            { text = "Start with [Extra-Destructive Explosives] (Supplied by Sprite Jumpsprocket during Explosive Consultation; plant it at the Deadmines forge)", kind = "starter", itemID = 254553, itemName = "Extra-Destructive Explosives" },
        },
        items = {
            { id = 254553, name = "Extra-Destructive Explosives", role = "starter", source = "Supplied by Sprite Jumpsprocket during Explosive Consultation; plant it at the Deadmines forge" },
        },
    },
    [92914] = {
        pickup = "Shen'dralar Pylon, Shen'dralas (43.6, 34.2)",
        turnin = "Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)",
        summary = "The other pylons: east at 73, 23 (more arcane elementals, you get dismounted there) and south at 47, 78 inside the big Shen'dralas building.",
        steps = {
            { text = "Interact with: table: 011987A8", kind = "object", mapID = 2652, x = 0.4360, y = 0.3420 },
        },
        pins = {
            { mapID = 2652, x = 0.4360, y = 0.3420, label = "Shen'dralar Pylon — Shen'dralas", kind = "location" },
            { mapID = 2652, x = 0.3500, y = 0.4640, label = "Mordent Evenshade — Evenshade's Overlook, Shen'dralas", kind = "turnin" },
        },
    },
    [93016] = {
        pickup = "Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)",
        turnin = "Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)",
        pins = {
            { mapID = 2652, x = 0.3500, y = 0.4640, label = "Mordent Evenshade — Evenshade's Overlook, Shen'dralas", kind = "location" },
        },
    },
    [93030] = {
        pickup = "Knight of Mourning, Tirisfal Glades (17.6, 67.4)",
        turnin = "Knight of Mourning, Tirisfal Glades (17.6, 67.4)",
        pins = {
            { mapID = 1420, x = 0.1760, y = 0.6740, label = "Knight of Mourning — Tirisfal Glades", kind = "location" },
        },
    },
    [93341] = {
        pickup = "Mithera, by the Forlorn Gardens, Shen'dralas (52.8, 76.0)",
        turnin = "Mithera, by the Forlorn Gardens, Shen'dralas (52.8, 76.0)",
        pins = {
            { mapID = 2652, x = 0.5280, y = 0.7600, label = "Mithera — by the Forlorn Gardens, Shen'dralas", kind = "location" },
        },
    },
    [93394] = {
        pickup = "Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)",
        turnin = "Magister Kirandis, in the temple of Shen'dralas (47.2, 75.8)",
        summary = "This opens the Shen'dralas quests, Mithera's included.",
        steps = {
            { text = "This opens the Shen'dralas quests, Mithera's included.", kind = "guide", mapID = 2652, x = 0.3500, y = 0.4640 },
        },
        pins = {
            { mapID = 2652, x = 0.3500, y = 0.4640, label = "Mordent Evenshade — Evenshade's Overlook, Shen'dralas", kind = "location" },
            { mapID = 2652, x = 0.4720, y = 0.7580, label = "Magister Kirandis — temple of Shen'dralas", kind = "turnin" },
        },
    },
    [93404] = {
        name = "Rot and Regret",
        pickup = "Woodwyrd, Forlorn Gardens, Shen'dralas (just east of Mithera, about 53, 76)",
        turnin = "Woodwyrd, Forlorn Gardens, Shen'dralas (just east of Mithera, about 53, 76)",
        summary = "A Maraudon dungeon quest (see Maraudon). Use the vial on the burning tree next to Woodwyrd, not on Woodwyrd himself.",
        warning = "Yes, this step is in MARAUDON. It's needed to unlock this Razorfen quest.",
        steps = {
            { text = "Prereq chain (7): Strange Pylons -> Fragments of the Pylons -> Powering the Pylons (+4 more)", kind = "quest" },
            { text = "Get [Vial of Earth Song Water]: From the small geyser in the pools Rotgrip swims around in, Maraudon", kind = "item", itemID = 258296, itemName = "Vial of Earth Song Water" },
            { text = "Turn in: Woodwyrd, Forlorn Gardens, Shen'dralas (just east of Mithera, about 53, 76)", kind = "turnin" },
        },
        items = {
            { id = 258296, name = "Vial of Earth Song Water", role = "required", source = "From the small geyser in the pools Rotgrip swims around in, Maraudon" },
        },
        pins = {
            { mapID = 2652, x = 0.5350, y = 0.7600, label = "Woodwyrd — Forlorn Gardens, Shen'dralas (just east of Mithera)", kind = "start" },
        },
    },
    [93594] = {
        pickup = "Mithera, by the Forlorn Gardens, Shen'dralas (52.8, 76.0)",
        turnin = "Woodwyrd, Forlorn Gardens, Shen'dralas (just east of Mithera, about 53, 76)",
        summary = "Mithera offers it once Forlorn Gardens is handed in.",
        steps = {
            { text = "Mithera offers it once Forlorn Gardens is handed in.", kind = "guide", mapID = 2652, x = 0.5280, y = 0.7600 },
        },
        pins = {
            { mapID = 2652, x = 0.5280, y = 0.7600, label = "Mithera — by the Forlorn Gardens, Shen'dralas", kind = "location" },
            { mapID = 2652, x = 0.5350, y = 0.7600, label = "Woodwyrd — Forlorn Gardens, Shen'dralas (just east of Mithera)", kind = "turnin" },
        },
    },
    [93601] = {
        pickup = "Woodwyrd, Forlorn Gardens, Shen'dralas (just east of Mithera, about 53, 76)",
        turnin = "Kog'thug the Brave, Bristleback Retreat, Shen'dralas (72.6, 31.4)",
        pins = {
            { mapID = 2652, x = 0.5350, y = 0.7600, label = "Woodwyrd — Forlorn Gardens, Shen'dralas (just east of Mithera)", kind = "location" },
            { mapID = 2652, x = 0.7260, y = 0.3140, label = "Kog'thug the Brave — Bristleback Retreat, Shen'dralas", kind = "turnin" },
        },
    },
    [93604] = {
        name = "Agamaggan's Blood",
        pickup = "Kog'thug the Brave, Bristleback Retreat, Shen'dralas (72.6, 31.4)",
        turnin = "Kog'thug the Brave, Bristleback Retreat, Shen'dralas (72.6, 31.4)",
        summary = "Click a Cauldron of Agamaggan's Blood to summon the Virulent Blood of Agamaggan and kill it for the blood. One cauldron is in the tent nearest the last boss (it may also be in other tents). Blood from Razorfen Kraul doesn't count.",
        warning = "WARNING: This chain has a step in Maraudon",
        steps = {
            { text = "Prereq chain (9): Strange Pylons -> Fragments of the Pylons -> Powering the Pylons (+6 more)", kind = "quest" },
            { text = "Get [Virulent Blood of Agamaggan]", kind = "item", itemID = 260237, itemName = "Virulent Blood of Agamaggan" },
            { text = "Turn in: Kog'thug the Brave, Bristleback Retreat, Shen'dralas (72.6, 31.4)", kind = "turnin" },
        },
        items = {
            { id = 260237, name = "Virulent Blood of Agamaggan", role = "required" },
        },
        pins = {
            { mapID = 2652, x = 0.7260, y = 0.3140, label = "Kog'thug the Brave — Bristleback Retreat, Shen'dralas", kind = "start" },
        },
    },
    [93680] = {
        pickup = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
        turnin = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
        summary = "This quest can be accepted alongside Prison Break In.",
        steps = {
            { text = "Get [Grimy Key]: Found while investigating the Dalaran forces around the Lordamere Internment Camp", kind = "item", itemID = 279469, itemName = "Grimy Key" },
            { text = "Turn in: Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills", kind = "turnin" },
        },
        items = {
            { id = 279469, name = "Grimy Key", role = "required", source = "Found while investigating the Dalaran forces around the Lordamere Internment Camp" },
        },
        pins = {
            { mapID = 1424, x = 0.6150, y = 0.2070, label = "Magus Wordeen Voidglare — Tarren Mill", kind = "location", detail = "Inside the building in Tarren Mill" },
        },
    },
    [93786] = {
        pickup = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.6)",
        turnin = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.6)",
        summary = "Done alongside Food for the Taking.",
        steps = {
            { text = "Done alongside Food for the Taking.", kind = "guide", mapID = 2548, x = 0.5940, y = 0.4560 },
        },
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4560, label = "Krom'rosh — Rog'mar, Riverglades", kind = "location" },
        },
    },
    [93787] = {
        pickup = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.6)",
        turnin = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.6)",
        summary = "Done alongside A Message in Blood. Krom'rosh offers Show Them How It's Done once this is handed in.",
        steps = {
            { text = "Done alongside A Message in Blood. Krom'rosh offers Show Them How It's Done once this is handed in.", kind = "guide", mapID = 2548, x = 0.5940, y = 0.4560 },
        },
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4560, label = "Krom'rosh — Rog'mar, Riverglades", kind = "location" },
        },
    },
    [94483] = {
        pickup = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.6)",
        turnin = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.6)",
        summary = "Needed before the Twilight's Hammer quests (a player's report on the Discord).",
        steps = {
            { text = "Needed before the Twilight's Hammer quests (a player's report on the Discord).", kind = "guide", mapID = 2548, x = 0.5940, y = 0.4560 },
        },
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4560, label = "Krom'rosh — Rog'mar, Riverglades", kind = "location" },
        },
    },
    [94672] = {
        pickup = "Tran'gul, Rog'mar, Riverglades (59.4, 44.0)",
        turnin = "Tran'gul, Rog'mar, Riverglades",
        summary = "Done alongside Twilight Missives; Tran'gul gives Digging for Answers once both are handed in.",
        steps = {
            { text = "Done alongside Twilight Missives; Tran'gul gives Digging for Answers once both are handed in.", kind = "guide", mapID = 2548, x = 0.5940, y = 0.4400 },
        },
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4400, label = "Tran'gul — Rog'mar, Riverglades", kind = "location" },
        },
    },
    [94680] = {
        pickup = "Tran'gul, Rog'mar, Riverglades (59.5, 44.0)",
        turnin = "Tran'gul, Rog'mar, Riverglades (59.5, 44.0)",
        summary = "Done alongside Encroaching Twilight; Tran'gul gives Digging for Answers once both are handed in.",
        steps = {
            { text = "Done alongside Encroaching Twilight; Tran'gul gives Digging for Answers once both are handed in.", kind = "guide", mapID = 2548, x = 0.5940, y = 0.4400 },
        },
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4400, label = "Tran'gul — Rog'mar, Riverglades", kind = "location" },
        },
    },
    [94727] = {
        pickup = "Tran'gul, Rog'mar, Riverglades (59.5, 44.0)",
        turnin = "Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)",
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4400, label = "Tran'gul — Rog'mar, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.5000, y = 0.4700, label = "Clubtoe — Sunnyglade cave, Riverglades", kind = "turnin" },
        },
    },
    [94744] = {
        pickup = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.6)",
        turnin = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4560, label = "Krom'rosh — Rog'mar, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.3340, y = 0.3800, label = "Da'grosh — Twilight's Shroud, Riverglades", kind = "turnin" },
        },
    },
    [94745] = {
        pickup = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        turnin = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        summary = "Done alongside Break Their Chains; both are needed for Bring Me His Head.",
        steps = {
            { text = "Done alongside Break Their Chains; both are needed for Bring Me His Head.", kind = "guide", mapID = 2548, x = 0.3340, y = 0.3800 },
        },
        pins = {
            { mapID = 2548, x = 0.3340, y = 0.3800, label = "Da'grosh — Twilight's Shroud, Riverglades", kind = "location" },
        },
    },
    [94748] = {
        pickup = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        turnin = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        summary = "Done alongside Carving a Path; both are needed for Bring Me His Head.",
        steps = {
            { text = "Done alongside Carving a Path; both are needed for Bring Me His Head.", kind = "guide", mapID = 2548, x = 0.3340, y = 0.3800 },
        },
        pins = {
            { mapID = 2548, x = 0.3340, y = 0.3800, label = "Da'grosh — Twilight's Shroud, Riverglades", kind = "location" },
        },
    },
    [94768] = {
        pickup = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        turnin = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        summary = "Horde version. Handing it in to Da'grosh opens A Token of Vengeance.",
        steps = {
            { text = "Get [Kilgar's Head]: From Overlord Kilgar at Twilight's Shroud", kind = "item", itemID = 265837, itemName = "Kilgar's Head" },
            { text = "Turn in: Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)", kind = "turnin" },
        },
        items = {
            { id = 265837, name = "Kilgar's Head", role = "required", source = "From Overlord Kilgar at Twilight's Shroud" },
        },
        pins = {
            { mapID = 2548, x = 0.3340, y = 0.3800, label = "Da'grosh — Twilight's Shroud, Riverglades", kind = "location" },
        },
    },
    [94877] = {
        pickup = "Demar Brant, Farholde Keep, Riverglades (66.6, 81.0)",
        turnin = "Demar Brant, Farholde Keep, Riverglades (66.6, 81.0)",
        summary = "First step of the Twilight Mementos chain (Mobalytics); what leads from it to The Western Front is not confirmed yet.",
        steps = {
            { text = "First step of the Twilight Mementos chain (Mobalytics); what leads from it to The Western Front is not confirmed yet.", kind = "guide", mapID = 2548, x = 0.6660, y = 0.8100 },
        },
        pins = {
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Demar Brant — Farholde Keep, Riverglades", kind = "location" },
        },
    },
    [94879] = {
        pickup = "Ashe Amberhall, Farholde Keep, Riverglades",
        turnin = "Ashe Amberhall, Farholde Keep, Riverglades",
        summary = "First step of the Eye of Mugg chain (Mobalytics). Done alongside Curious Trinkets; what leads from Ashe's quests to The Western Front is not confirmed yet.",
        steps = {
            { text = "Get [Twilight Page]: From the Twilight's Hammer in Sunnyglade (5 needed)", kind = "item", itemID = 266424, itemName = "Twilight Page" },
            { text = "Turn in: Ashe Amberhall, Farholde Keep, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 266424, name = "Twilight Page", role = "required", source = "From the Twilight's Hammer in Sunnyglade (5 needed)" },
        },
        pins = {
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Ashe Amberhall — Farholde Keep, Riverglades", kind = "location" },
        },
    },
    [94881] = {
        pickup = "Ashe Amberhall, Farholde Keep, Riverglades",
        turnin = "Ashe Amberhall, Farholde Keep, Riverglades",
        summary = "Done alongside Scraps of Knowledge.",
        steps = {
            { text = "Get [Twilight Charm]: Dropped by Twilight Shadowmancers and Twilight Neophytes in Sunnyglade (25 needed)", kind = "item", itemID = 266425, itemName = "Twilight Charm" },
            { text = "Turn in: Ashe Amberhall, Farholde Keep, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 266425, name = "Twilight Charm", role = "required", source = "Dropped by Twilight Shadowmancers and Twilight Neophytes in Sunnyglade (25 needed)" },
        },
        pins = {
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Ashe Amberhall — Farholde Keep, Riverglades", kind = "location" },
        },
    },
    [94886] = {
        pickup = "Demar Brant, Farholde Keep, Riverglades (66.6, 81.0)",
        turnin = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        pins = {
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Demar Brant — Farholde Keep, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.3060, y = 0.4900, label = "Sergeant Riftan — Farholde Lookouts, Twilight's Shroud", kind = "turnin" },
        },
    },
    [94888] = {
        pickup = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        turnin = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        summary = "Done alongside Carving a Path.",
        steps = {
            { text = "Done alongside Carving a Path.", kind = "guide", mapID = 2548, x = 0.3060, y = 0.4900 },
        },
        pins = {
            { mapID = 2548, x = 0.3060, y = 0.4900, label = "Sergeant Riftan — Farholde Lookouts, Twilight's Shroud", kind = "location" },
        },
    },
    [94889] = {
        pickup = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        turnin = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        summary = "Done alongside No Soldier Left Behind.",
        steps = {
            { text = "Done alongside No Soldier Left Behind.", kind = "guide", mapID = 2548, x = 0.3060, y = 0.4900 },
        },
        pins = {
            { mapID = 2548, x = 0.3060, y = 0.4900, label = "Sergeant Riftan — Farholde Lookouts, Twilight's Shroud", kind = "location" },
        },
    },
    [94890] = {
        pickup = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        turnin = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        summary = "Alliance version. Handing it in to Sergeant Riftan gives News to Farholde and opens Twilight Mementos.",
        steps = {
            { text = "Get [Kilgar's Head]: From Overlord Kilgar in the Twilight's Shroud, Riverglades", kind = "item", itemID = 265837, itemName = "Kilgar's Head" },
            { text = "Turn in: Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)", kind = "turnin" },
        },
        items = {
            { id = 265837, name = "Kilgar's Head", role = "required", source = "From Overlord Kilgar in the Twilight's Shroud, Riverglades" },
        },
        pins = {
            { mapID = 2548, x = 0.3060, y = 0.4900, label = "Sergeant Riftan — Farholde Lookouts, Twilight's Shroud", kind = "location" },
        },
    },
    [94891] = {
        pickup = "Given when you hand in Bring Me His Head to Sergeant Riftan",
        turnin = "Ashe Amberhall, Farholde Keep, Riverglades (66.6, 81.0)",
        summary = "Handing it in opens Eye of Mugg (Demar Brant).",
        steps = {
            { text = "Use provided [Kilgar's Head] (Given when you accept the quest)", kind = "provided", itemID = 265837, itemName = "Kilgar's Head" },
            { text = "Turn in: Ashe Amberhall, Farholde Keep, Riverglades (66.6, 81.0)", kind = "turnin", mapID = 2548, x = 0.6660, y = 0.8100 },
        },
        items = {
            { id = 265837, name = "Kilgar's Head", role = "provided", source = "Given when you accept the quest" },
        },
        pins = {
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Ashe Amberhall — Farholde Keep, Riverglades", kind = "turnin" },
        },
    },
    [94907] = {
        pickup = "Ashe Amberhall, Farholde Keep, Riverglades",
        turnin = "Ashe Amberhall, Farholde Keep, Riverglades",
        steps = {
            { text = "Use provided [Amberhall's Soulstone] (Given by Ashe Amberhall when you accept the quest)", kind = "provided", itemID = 0, itemName = "Amberhall's Soulstone" },
            { text = "Turn in: Ashe Amberhall, Farholde Keep, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 0, name = "Amberhall's Soulstone", role = "provided", source = "Given by Ashe Amberhall when you accept the quest" },
        },
        pins = {
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Ashe Amberhall — Farholde Keep, Riverglades", kind = "location" },
        },
    },
    [94968] = {
        name = "Eye of Mugg",
        pickup = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.5)",
        turnin = "Krom'rosh, Riverglades",
        steps = {
            { text = "Prereq chain (22): A Message in Blood -> Food for the Taking -> Show Them How It's Done (+19 more)", kind = "quest" },
            { text = "Get [Eye of Mugg]", kind = "item", itemID = 267086, itemName = "Eye of Mugg" },
            { text = "Turn in: Krom'rosh, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 267086, name = "Eye of Mugg", role = "required" },
        },
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4550, label = "Krom'rosh — Rog'mar, Riverglades", kind = "start", detail = "Eye of Mugg (Horde): pick up and return to Krom'rosh at Rog'mar." },
        },
    },
    [94972] = {
        name = "Tome of Twilight",
        pickup = "Tran'gul, Rog'mar, Riverglades (59.4, 44.0)",
        turnin = "Tran'gul, Rog'mar, Riverglades",
        steps = {
            { text = "Prereq chain (22): A Message in Blood -> Food for the Taking -> Show Them How It's Done (+19 more)", kind = "quest" },
            { text = "Get [Tome of Twilight]", kind = "item", itemID = 267104, itemName = "Tome of Twilight" },
            { text = "Turn in: Tran'gul, Rog'mar, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 267104, name = "Tome of Twilight", role = "required" },
        },
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4400, label = "Tran'gul — Rog'mar, Riverglades", kind = "start" },
        },
    },
    [94973] = {
        pickup = "Krol'dok Moulding, dropped by Tunk in Krol'dok Stronghold",
        turnin = "Kreza Darkthorn, Rog'mar, Riverglades (59.8, 46.0)",
        steps = {
            { text = "Start with [Krol'dok Moulding] (Dropped by Tunk, at the forge beside War Handler Ashka in Krol'dok Stronghold; everyone in the group can loot it)", kind = "starter", itemID = 267137, itemName = "Krol'dok Moulding", mapID = 2548, x = 0.5980, y = 0.4600 },
        },
        items = {
            { id = 267137, name = "Krol'dok Moulding", role = "starter", source = "Dropped by Tunk, at the forge beside War Handler Ashka in Krol'dok Stronghold; everyone in the group can loot it" },
        },
        pins = {
            { mapID = 2548, x = 0.5980, y = 0.4600, label = "Kreza Darkthorn — Rog'mar, Riverglades", kind = "turnin" },
        },
    },
    [94974] = {
        name = "Key Ingredients",
        pickup = "Kreza Darkthorn, Rog'mar, Riverglades (59.8, 46.0)",
        turnin = "Kreza Darkthorn, Rog'mar, Riverglades",
        summary = "Keep any Krol'dok Moulding you loot: it starts the quest before this one.",
        warning = "The key from this quest unlocks the upper side of the dungeon.",
        steps = {
            { text = "Prereq chain (1): Krol'dok Moulding", kind = "quest" },
            { text = "Get [Thick Leather]: Leatherworking material: skinning, trade or the auction house (4 needed)", kind = "item", itemID = 4304, itemName = "Thick Leather" },
            { text = "Get [Iron Bar]: Smelted from Iron Ore: mining, trade or the auction house (12 needed)", kind = "item", itemID = 3575, itemName = "Iron Bar" },
            { text = "Turn in: Kreza Darkthorn, Rog'mar, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 4304, name = "Thick Leather", role = "required", source = "Leatherworking material: skinning, trade or the auction house (4 needed)" },
            { id = 3575, name = "Iron Bar", role = "required", source = "Smelted from Iron Ore: mining, trade or the auction house (12 needed)" },
        },
        pins = {
            { mapID = 2548, x = 0.5980, y = 0.4600, label = "Kreza Darkthorn — Rog'mar, Riverglades", kind = "start" },
        },
    },
    [94975] = {
        name = "A Token of Vengeance",
        pickup = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        turnin = "Da'grosh, Twilight's Shroud, Riverglades",
        steps = {
            { text = "Prereq chain (21): A Message in Blood -> Food for the Taking -> Show Them How It's Done (+18 more)", kind = "quest" },
            { text = "Get [Cultist Ear]: Need x15", kind = "item", itemID = 267091, itemName = "Cultist Ear" },
            { text = "Turn in: Da'grosh, Twilight's Shroud, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 267091, name = "Cultist Ear", role = "required", source = "Need x15" },
        },
        pins = {
            { mapID = 2548, x = 0.3340, y = 0.3800, label = "Da'grosh — Twilight's Shroud, Riverglades", kind = "start" },
        },
    },
    [94980] = {
        pickup = "Krol'dok Moulding, dropped by Tunk in Krol'dok Stronghold",
        turnin = "Alphonse Dumas, Farholde Keep, Riverglades (64.4, 82.0)",
        steps = {
            { text = "Start with [Krol'dok Moulding] (Dropped by Tunk, at the forge beside War Handler Ashka in Krol'dok Stronghold; everyone in the group can loot it)", kind = "starter", itemID = 267138, itemName = "Krol'dok Moulding", mapID = 2548, x = 0.6440, y = 0.8200 },
        },
        items = {
            { id = 267138, name = "Krol'dok Moulding", role = "starter", source = "Dropped by Tunk, at the forge beside War Handler Ashka in Krol'dok Stronghold; everyone in the group can loot it" },
        },
        pins = {
            { mapID = 2548, x = 0.6440, y = 0.8200, label = "Alphonse Dumas — Farholde Keep, Riverglades", kind = "turnin" },
        },
    },
    [94981] = {
        name = "Key Ingredients",
        pickup = "Alphonse Dumas, Farholde Keep, Riverglades (64.4, 82.0)",
        turnin = "Alphonse Dumas, Farholde Keep, Riverglades",
        summary = "Keep any Krol'dok Moulding you loot: it starts the quest before this one.",
        warning = "The key from this quest unlocks the upper side of the dungeon.",
        steps = {
            { text = "Prereq chain (1): Krol'dok Moulding", kind = "quest" },
            { text = "Get [Thick Leather]: Leatherworking material: skinning, trade or the auction house (4 needed)", kind = "item", itemID = 4304, itemName = "Thick Leather" },
            { text = "Get [Iron Bar]: Smelted from Iron Ore: mining, trade or the auction house (12 needed)", kind = "item", itemID = 3575, itemName = "Iron Bar" },
            { text = "Turn in: Alphonse Dumas, Farholde Keep, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 4304, name = "Thick Leather", role = "required", source = "Leatherworking material: skinning, trade or the auction house (4 needed)" },
            { id = 3575, name = "Iron Bar", role = "required", source = "Smelted from Iron Ore: mining, trade or the auction house (12 needed)" },
        },
        pins = {
            { mapID = 2548, x = 0.6440, y = 0.8200, label = "Alphonse Dumas — Farholde Keep, Riverglades", kind = "start" },
        },
    },
    [94982] = {
        name = "Eye of Mugg",
        pickup = "Commander Demar Brant, Farholde Keep, Riverglades (66.6, 81.0)",
        turnin = "Commander Demar Brant, Farholde Keep, Riverglades",
        steps = {
            { text = "Prereq chain (6): Scraps of Knowledge -> The Western Front -> No Soldier Left Behind (+3 more)", kind = "quest" },
            { text = "Get [Eye of Mugg]", kind = "item", itemID = 267086, itemName = "Eye of Mugg" },
            { text = "Turn in: Commander Demar Brant, Farholde Keep, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 267086, name = "Eye of Mugg", role = "required" },
        },
        pins = {
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Commander Demar Brant — Farholde Keep, Riverglades", kind = "start", detail = "Eye of Mugg (Alliance): pick up and return to Commander Demar Brant at Farholde Keep." },
        },
    },
    [94983] = {
        name = "Twilight Mementos",
        pickup = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        turnin = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades",
        summary = "Unlocked by handing in Bring Me His Head to Sergeant Riftan.",
        steps = {
            { text = "Get [Twilight Bangle]: Dropped by the Twilight's Hammer cultists in Krol'dok Stronghold (8 needed)", kind = "item", itemID = 267234, itemName = "Twilight Bangle" },
            { text = "Turn in: Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 267234, name = "Twilight Bangle", role = "required", source = "Dropped by the Twilight's Hammer cultists in Krol'dok Stronghold (8 needed)" },
        },
        pins = {
            { mapID = 2548, x = 0.3060, y = 0.4900, label = "Sergeant Riftan — Farholde Lookouts, Twilight's Shroud", kind = "start" },
        },
    },
    [94984] = {
        name = "Tome of Twilight",
        pickup = "Ashe Amberhall, Farholde Keep, Riverglades (66.6, 81.0)",
        turnin = "Ashe Amberhall, Farholde Keep, Riverglades",
        steps = {
            { text = "Prereq chain (3): Scraps of Knowledge -> Curious Trinkets -> A Small Favor", kind = "quest" },
            { text = "Get [Tome of Twilight]", kind = "item", itemID = 267104, itemName = "Tome of Twilight" },
            { text = "Turn in: Ashe Amberhall, Farholde Keep, Riverglades", kind = "turnin" },
        },
        items = {
            { id = 267104, name = "Tome of Twilight", role = "required" },
        },
        pins = {
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Ashe Amberhall — Farholde Keep, Riverglades", kind = "start" },
        },
    },
    [94997] = {
        pickup = "Sergeant Riftan, Farholde Lookouts, Twilight's Shroud, Riverglades (30.6, 49.0)",
        turnin = "Ashe Amberhall, Farholde Keep, Riverglades",
        steps = {
            { text = "Use provided [Satchel of Cursed Mementos] (Given when you accept the quest)", kind = "provided", itemID = 268035, itemName = "Satchel of Cursed Mementos" },
            { text = "Turn in: Ashe Amberhall, Farholde Keep, Riverglades", kind = "turnin", mapID = 2548, x = 0.6660, y = 0.8100 },
        },
        items = {
            { id = 268035, name = "Satchel of Cursed Mementos", role = "provided", source = "Given when you accept the quest" },
        },
        pins = {
            { mapID = 2548, x = 0.3060, y = 0.4900, label = "Sergeant Riftan — Farholde Lookouts, Twilight's Shroud", kind = "location" },
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Ashe Amberhall — Farholde Keep, Riverglades", kind = "turnin" },
        },
    },
    [94998] = {
        name = "Curios of Curiosity",
        pickup = "Ashe Amberhall, Farholde Keep, Riverglades (66.6, 81.0)",
        turnin = "Melanie Sable, Farholde Keep, Riverglades (66.2, 83.2)",
        steps = {
            { text = "Prereq chain (7): Saving Sunnyglade -> The Western Front -> No Soldier Left Behind (+4 more)", kind = "quest" },
        },
        pins = {
            { mapID = 2548, x = 0.6620, y = 0.8320, label = "Melanie Sable — Farholde Keep, Riverglades", kind = "turnin" },
            { mapID = 2548, x = 0.6660, y = 0.8100, label = "Ashe Amberhall — Farholde Keep, Riverglades", kind = "start" },
        },
    },
    [95034] = {
        pickup = "Lumina Windsinger, The Sepulcher, Silverpine Forest",
        turnin = "Lumina Windsinger, The Sepulcher, Silverpine Forest",
        summary = "The questline starts at level 18 with Diplomatic Incident from Danitha Morr at Bandarion Keep, Tirisfal Glades. It takes you to Fenris Isle, where you free Lumina Windsinger from Fenris Keep.",
        steps = {
            { text = "The questline starts at level 18 with Diplomatic Incident from Danitha Morr at Bandarion Keep, Tirisfal Glades. It takes you to Fenris Isle, where you free Lumina Windsinger from Fenris Keep.", kind = "guide", mapID = 1421, x = 0.4330, y = 0.4100 },
        },
        pins = {
            { mapID = 1421, x = 0.4330, y = 0.4100, label = "Lumina Windsinger — The Sepulcher", kind = "location" },
        },
    },
    [95036] = {
        pickup = "Lumina Windsinger, The Sepulcher, Silverpine Forest",
        turnin = "Trevan Rol, The Sepulcher, Silverpine Forest",
        steps = {
            { text = "Use provided [Trevan's Weapon Notes] (Given by Trevan Rol in the Sepulcher)", kind = "provided", itemID = 267454, itemName = "Trevan's Weapon Notes" },
            { text = "Get [Whitestone Oak Lumber]: Dropped by: Goblin Woodcarver, The Deadmines", kind = "item", itemID = 6994, itemName = "Whitestone Oak Lumber" },
            { text = "Get [Enchanted Silver Ingot]: Found on a table in Archmage Arugal's room at the end of Shadowfang Keep, after you kill him", kind = "item", itemID = 267361, itemName = "Enchanted Silver Ingot" },
            { text = "Get [Purified Kor Gem]: Reward from the quest Seeking the Kor Gem: Ulric Frostveil, Zoram'gar Outpost, Ashenvale. The Corrupted Kor Gem he asks for drops from Blackfathom Tide Priestesses and Oracles at the Blackfathom Deeps entrance and from Blackfathom Sea Witches inside, once you have his quest.", kind = "item", itemID = 272448, itemName = "Purified Kor Gem" },
            { text = "Turn in: Trevan Rol, The Sepulcher, Silverpine Forest", kind = "turnin" },
        },
        items = {
            { id = 267454, name = "Trevan's Weapon Notes", role = "provided", source = "Given by Trevan Rol in the Sepulcher" },
            { id = 6994, name = "Whitestone Oak Lumber", role = "required", source = "Dropped by: Goblin Woodcarver, The Deadmines" },
            { id = 267361, name = "Enchanted Silver Ingot", role = "required", source = "Found on a table in Archmage Arugal's room at the end of Shadowfang Keep, after you kill him" },
            { id = 272448, name = "Purified Kor Gem", role = "required", source = "Reward from the quest Seeking the Kor Gem: Ulric Frostveil, Zoram'gar Outpost, Ashenvale. The Corrupted Kor Gem he asks for drops from Blackfathom Tide Priestesses and Oracles at the Blackfathom Deeps entrance and from Blackfathom Sea Witches inside, once you have his quest." },
        },
        pins = {
            { mapID = 1421, x = 0.4330, y = 0.4100, label = "Lumina Windsinger — The Sepulcher", kind = "location" },
        },
    },
    [95111] = {
        pickup = "Trevan Rol, The Sepulcher, Silverpine Forest",
        turnin = "Ott, Tarren Mill, Hillsbrad Foothills",
        pins = {
            { mapID = 1421, x = 0.4340, y = 0.4100, label = "Trevan Rol — The Sepulcher", kind = "location" },
            { mapID = 1424, x = 0.6040, y = 0.2620, label = "Ott — Tarren Mill", kind = "turnin" },
        },
    },
    [95125] = {
        pickup = "Ott, Tarren Mill, Hillsbrad Foothills",
        turnin = "Ott, Tarren Mill, Hillsbrad Foothills",
        pins = {
            { mapID = 1424, x = 0.6040, y = 0.2620, label = "Ott — Tarren Mill", kind = "location" },
        },
    },
    [95126] = {
        pickup = "Ott, Tarren Mill, Hillsbrad Foothills",
        turnin = "Trevan Rol, The Sepulcher, Silverpine Forest",
        pins = {
            { mapID = 1424, x = 0.6040, y = 0.2620, label = "Ott — Tarren Mill", kind = "location" },
            { mapID = 1421, x = 0.4340, y = 0.4100, label = "Trevan Rol — The Sepulcher", kind = "turnin" },
        },
    },
    [95140] = {
        name = "Old Fire-Eye",
        pickup = "Lumina Windsinger, The Sepulcher, Silverpine Forest",
        turnin = "Lumina Windsinger, The Sepulcher, Silverpine Forest",
        summary = "Final step. Old Fire-Eye is at the Greymane Wall in southern Silverpine Forest. Rewards Wolfsbane.",
        warning = "This is a chain quest with a step in Shadowfang Keep",
        steps = {
            { text = "Prereq chain (11): Diplomatic Incident -> A Curious Pair -> A Grim Fate (+8 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1421, x = 0.4330, y = 0.4100, label = "Lumina Windsinger — The Sepulcher", kind = "start" },
        },
    },
    [95189] = {
        name = "Crest of Lordaeron",
        pickup = "Item start: Crest of Lordaeron, inside Ruins of Lordaeron",
        turnin = "Lady Dena Kennedy, Stormwind City",
        summary = "Community reports indicate the Crest can spawn at one of several locations inside the dungeon. Reported spots include upper floors of towers, side/crypt rooms near The Baron, and the area around Bjork.",
        steps = {
            { text = "Start with [Crest of Lordaeron] (Reported random spawn inside Ruins of Lordaeron; check towers, side rooms and the Bjork area)", kind = "starter", itemID = 268579, itemName = "Crest of Lordaeron" },
        },
        items = {
            { id = 268579, name = "Crest of Lordaeron", role = "starter", source = "Reported random spawn inside Ruins of Lordaeron; check towers, side rooms and the Bjork area" },
        },
    },
    [95194] = {
        pickup = "Master Mathias Shaw, SI:7, Old Town, Stormwind City (78.3, 70.7)",
        turnin = "Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)",
        pins = {
            { mapID = 1453, x = 0.7830, y = 0.7070, label = "Master Mathias Shaw — SI:7, Old Town, Stormwind", kind = "location" },
            { mapID = 1445, x = 0.6620, y = 0.4520, label = "Sully McCleary — inn, Theramore", kind = "turnin" },
        },
    },
    [95195] = {
        name = "Bloodied Insignia",
        pickup = "Item start: Bloodied Insignia, inside Ruins of Lordaeron",
        turnin = "General Marcus Jonathan, Stormwind City",
        steps = {
            { text = "Start with [Bloodied Insignia] (Dropped by: undead enemies inside Ruins of Lordaeron)", kind = "starter", itemID = 268535, itemName = "Bloodied Insignia" },
        },
        items = {
            { id = 268535, name = "Bloodied Insignia", role = "starter", source = "Dropped by: undead enemies inside Ruins of Lordaeron" },
        },
    },
    [95196] = {
        pickup = "Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)",
        turnin = "Sully McCleary, outside Theramore across the bridge, Dustwallow Marsh (63.4, 42.4)",
        pins = {
            { mapID = 1445, x = 0.6620, y = 0.4520, label = "Sully McCleary — inn, Theramore", kind = "location" },
            { mapID = 1445, x = 0.6340, y = 0.4240, label = "Sully McCleary — outside Theramore, across the bridge", kind = "turnin" },
        },
    },
    [95198] = {
        pickup = "Sully McCleary, outside Theramore across the bridge, Dustwallow Marsh (63.4, 42.4)",
        turnin = "Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)",
        summary = "Up the tower, talk to the guard next to Archmage Tervosh (he looks like you in the disguise) and relieve him; don't get close to Jaina or she dispels it. You stay stuck a while after it completes: use Exit Vehicle.",
        steps = {
            { text = "Use provided [SI:7 Disguise Kit] (Given when you accept the quest)", kind = "provided", itemID = 269000, itemName = "SI:7 Disguise Kit" },
            { text = "Turn in: Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)", kind = "turnin", mapID = 1445, x = 0.6620, y = 0.4520 },
        },
        items = {
            { id = 269000, name = "SI:7 Disguise Kit", role = "provided", source = "Given when you accept the quest" },
        },
        pins = {
            { mapID = 1445, x = 0.6340, y = 0.4240, label = "Sully McCleary — outside Theramore, across the bridge", kind = "location" },
            { mapID = 1445, x = 0.6620, y = 0.4520, label = "Sully McCleary — inn, Theramore", kind = "turnin" },
        },
    },
    [95204] = {
        name = "Crest of Lordaeron",
        pickup = "Item start: Crest of Lordaeron, inside Ruins of Lordaeron",
        turnin = "Oran Snakewrithe, Undercity",
        summary = "Community reports indicate the Crest can spawn at one of several locations inside the dungeon. Reported spots include upper floors of towers, side/crypt rooms near The Baron, and the area around Bjork.",
        steps = {
            { text = "Start with [Crest of Lordaeron] (Reported random spawn inside Ruins of Lordaeron; check towers, side rooms and the Bjork area)", kind = "starter", itemID = 268579, itemName = "Crest of Lordaeron" },
        },
        items = {
            { id = 268579, name = "Crest of Lordaeron", role = "starter", source = "Reported random spawn inside Ruins of Lordaeron; check towers, side rooms and the Bjork area" },
        },
    },
    [95216] = {
        name = "The New Plague",
        pickup = "Theodore Griffs, Undercity",
        turnin = "Theodore Griffs, Undercity",
        steps = {
            { text = "Prereq chain (3): A Recipe For Death -> A Recipe For Death -> A Recipe For Death", kind = "quest" },
        },
        pins = {
            { mapID = 1458, x = 0.4650, y = 0.7160, label = "Theodore Griffs — Apothecarium", kind = "start" },
        },
    },
    [95262] = {
        pickup = "Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)",
        turnin = "Inside Alcaz Prison (who takes it is not known yet)",
        pins = {
            { mapID = 1445, x = 0.6620, y = 0.4520, label = "Sully McCleary — inn, Theramore", kind = "location" },
        },
    },
    [95263] = {
        name = "Somber News",
        pickup = "Inside Alcaz Prison, once you learn what became of King Varian Wrynn",
        turnin = "Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)",
        steps = {
            { text = "Prereq chain (4): Our Man in Theramore -> Watch Yer Back -> The Return of the King? (+1 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1445, x = 0.6620, y = 0.4520, label = "Sully McCleary — inn, Theramore", kind = "turnin" },
        },
    },
    [95278] = {
        pickup = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        turnin = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.5)",
        summary = "Handing it in opens Eye of Mugg (Krom'rosh) and Tome of Twilight (Tran'gul).",
        steps = {
            { text = "Use provided [Blood and Battle] (Given by Da'grosh when you accept the quest)", kind = "provided", itemID = 268705, itemName = "Blood and Battle" },
            { text = "Turn in: Krom'rosh, Rog'mar, Riverglades (59.4, 45.5)", kind = "turnin", mapID = 2548, x = 0.5940, y = 0.4550 },
        },
        items = {
            { id = 268705, name = "Blood and Battle", role = "provided", source = "Given by Da'grosh when you accept the quest" },
        },
        pins = {
            { mapID = 2548, x = 0.3340, y = 0.3800, label = "Da'grosh — Twilight's Shroud, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.5940, y = 0.4550, label = "Krom'rosh — Rog'mar, Riverglades", kind = "turnin", detail = "Eye of Mugg (Horde): pick up and return to Krom'rosh at Rog'mar." },
        },
    },
    [95283] = {
        pickup = "Eitrigg, Grommash Hold (Thrall's room), Orgrimmar",
        turnin = "Nazeer Bloodspike, Brackenwall Village, Dustwallow Marsh",
        pins = {
            { mapID = 1454, x = 0.3440, y = 0.3860, label = "Eitrigg — Grommash Hold, Orgrimmar", kind = "location" },
            { mapID = 1445, x = 0.3600, y = 0.3100, label = "Nazeer Bloodspike — Brackenwall Village, Dustwallow Marsh", kind = "turnin" },
        },
    },
    [95284] = {
        pickup = "Nazeer Bloodspike, Brackenwall Village, Dustwallow Marsh",
        turnin = "Sergeant Ulka, outside Alcaz Prison, Alcaz Island, Dustwallow Marsh (70.2, 18.8)",
        summary = "Nazeer offers it even before you hand in The Missing Kor'kron.",
        steps = {
            { text = "Nazeer offers it even before you hand in The Missing Kor'kron.", kind = "guide", mapID = 1445, x = 0.3600, y = 0.3100 },
        },
        pins = {
            { mapID = 1445, x = 0.3600, y = 0.3100, label = "Nazeer Bloodspike — Brackenwall Village, Dustwallow Marsh", kind = "location" },
            { mapID = 1445, x = 0.7020, y = 0.1880, label = "Sergeant Ulka — Alcaz Island, Dustwallow Marsh", kind = "turnin" },
        },
    },
    [95285] = {
        pickup = "Sergeant Ulka, outside Alcaz Prison, Alcaz Island, Dustwallow Marsh (70.2, 18.8)",
        turnin = "Sergeant Ulka, outside Alcaz Prison, Alcaz Island, Dustwallow Marsh (70.2, 18.8)",
        summary = "Sergeant Ulka then offers No Orc Left Behind, A Little Payback and Blood Red Bandanas.",
        steps = {
            { text = "Sergeant Ulka then offers No Orc Left Behind, A Little Payback and Blood Red Bandanas.", kind = "guide", mapID = 1445, x = 0.7020, y = 0.1880 },
        },
        pins = {
            { mapID = 1445, x = 0.7020, y = 0.1880, label = "Sergeant Ulka — Alcaz Island, Dustwallow Marsh", kind = "location" },
        },
    },
    [95309] = {
        pickup = "Sergeant Ulka, outside Alcaz Prison, Dustwallow Marsh (70.2, 18.8)",
        turnin = "Commander Folkar, inside Alcaz Prison",
        pins = {
            { mapID = 1445, x = 0.7020, y = 0.1880, label = "Sergeant Ulka — Dustwallow Marsh", kind = "location", detail = "Sergeant Ulka, outside Alcaz Prison on Alcaz Island" },
        },
    },
    [95417] = {
        pickup = "Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)",
        turnin = "Twilight Brute, in the cave under Sunnyglade, Riverglades (49.2, 46.7)",
        summary = "The first of two quests called The Purple Ones. Clubtoe gives Sickening Lights at the same time.",
        steps = {
            { text = "The first of two quests called The Purple Ones. Clubtoe gives Sickening Lights at the same time.", kind = "guide", mapID = 2548, x = 0.5000, y = 0.4700 },
        },
        pins = {
            { mapID = 2548, x = 0.5000, y = 0.4700, label = "Clubtoe — Sunnyglade cave, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.4920, y = 0.4670, label = "Twilight Brute — Sunnyglade cave, Riverglades", kind = "turnin" },
        },
    },
    [95418] = {
        pickup = "Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)",
        turnin = "Tran'gul, Rog'mar, Riverglades (59.5, 44.0)",
        pins = {
            { mapID = 2548, x = 0.5000, y = 0.4700, label = "Clubtoe — Sunnyglade cave, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.5940, y = 0.4400, label = "Tran'gul — Rog'mar, Riverglades", kind = "turnin" },
        },
    },
    [95420] = {
        pickup = "Tran'gul, Rog'mar, Riverglades (59.5, 44.0)",
        turnin = "Clugfist, Bolder'ok, Riverglades (64.4, 14.8)",
        pins = {
            { mapID = 2548, x = 0.5940, y = 0.4400, label = "Tran'gul — Rog'mar, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.6440, y = 0.1480, label = "Clugfist — Riverglades", kind = "turnin" },
        },
    },
    [95424] = {
        pickup = "Clugfist, Bolder'ok, Riverglades (64.4, 14.8)",
        turnin = "Clugfist, Bolder'ok, Riverglades (64.4, 14.8)",
        summary = "Done alongside Unworthy Champion; both are needed for Clugfist's Decree.",
        steps = {
            { text = "Done alongside Unworthy Champion; both are needed for Clugfist's Decree.", kind = "guide", mapID = 2548, x = 0.6440, y = 0.1480 },
        },
        pins = {
            { mapID = 2548, x = 0.6440, y = 0.1480, label = "Clugfist — Riverglades", kind = "location" },
        },
    },
    [95425] = {
        pickup = "Clugfist, Bolder'ok, Riverglades (64.4, 14.8)",
        turnin = "Clugfist, Bolder'ok, Riverglades (64.4, 14.8)",
        summary = "Done alongside Might Makes Right; both are needed for Clugfist's Decree. Skullthumper is reported to drop near 75, 27.",
        steps = {
            { text = "Done alongside Might Makes Right; both are needed for Clugfist's Decree. Skullthumper is reported to drop near 75, 27.", kind = "guide", mapID = 2548, x = 0.6440, y = 0.1480 },
        },
        pins = {
            { mapID = 2548, x = 0.6440, y = 0.1480, label = "Clugfist — Riverglades", kind = "location" },
        },
    },
    [95427] = {
        pickup = "Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)",
        turnin = "Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)",
        summary = "Chogg'Zac is an elite.",
        steps = {
            { text = "Get [Chogg's Head]: From Chogg'Zac in the Sunnyglade cave", kind = "item", itemID = 265750, itemName = "Chogg's Head" },
            { text = "Get [Zac's Head]: From Chogg'Zac in the Sunnyglade cave", kind = "item", itemID = 265751, itemName = "Zac's Head" },
            { text = "Turn in: Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)", kind = "turnin" },
        },
        items = {
            { id = 265750, name = "Chogg's Head", role = "required", source = "From Chogg'Zac in the Sunnyglade cave" },
            { id = 265751, name = "Zac's Head", role = "required", source = "From Chogg'Zac in the Sunnyglade cave" },
        },
        pins = {
            { mapID = 2548, x = 0.5000, y = 0.4700, label = "Clubtoe — Sunnyglade cave, Riverglades", kind = "location" },
        },
    },
    [95428] = {
        pickup = "Clugfist, Riverglades (64.4, 14.8)",
        turnin = "Krom'rosh, Rog'mar, Riverglades (59.4, 45.6)",
        pins = {
            { mapID = 2548, x = 0.6440, y = 0.1480, label = "Clugfist — Riverglades", kind = "location" },
            { mapID = 2548, x = 0.5940, y = 0.4560, label = "Krom'rosh — Rog'mar, Riverglades", kind = "turnin" },
        },
    },
    [95431] = {
        pickup = "Da'grosh, Twilight's Shroud, Riverglades (33.4, 38.0)",
        turnin = "Crag'rog, Riverglades (27.4, 37.0)",
        summary = "Leads to Rise Up!. Not confirmed as needed for Bring Me His Head: a player reports it, the quest databases don't list it.",
        steps = {
            { text = "Leads to Rise Up!. Not confirmed as needed for Bring Me His Head: a player reports it, the quest databases don't list it.", kind = "guide", mapID = 2548, x = 0.3340, y = 0.3800 },
        },
        pins = {
            { mapID = 2548, x = 0.3340, y = 0.3800, label = "Da'grosh — Twilight's Shroud, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.2740, y = 0.3700, label = "Crag'rog — Riverglades", kind = "turnin" },
        },
    },
    [95432] = {
        pickup = "Crag'rog, Riverglades (27.4, 37.0)",
        turnin = "Crag'rog, Riverglades (27.4, 37.0)",
        summary = "Comes after Rumblings of Discontent. Not confirmed as needed for Bring Me His Head: a player reports it, the quest databases don't list it.",
        steps = {
            { text = "Comes after Rumblings of Discontent. Not confirmed as needed for Bring Me His Head: a player reports it, the quest databases don't list it.", kind = "guide", mapID = 2548, x = 0.2740, y = 0.3700 },
        },
        pins = {
            { mapID = 2548, x = 0.2740, y = 0.3700, label = "Crag'rog — Riverglades", kind = "location" },
        },
    },
    [95483] = {
        name = "Thrall Needs to Know",
        pickup = "Commander Folkar, inside Alcaz Prison",
        turnin = "Thrall, Valley of Wisdom, Orgrimmar (32.0, 37.8)",
        steps = {
            { text = "Prereq chain (6): The Missing Kor'kron -> The Elite of the Elite -> Right Place, Wrong Time (+3 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1454, x = 0.3200, y = 0.3780, label = "Thrall — Orgrimmar", kind = "turnin" },
        },
    },
    [95601] = {
        pickup = "Twilight Brute, in the cave under Sunnyglade, Riverglades (49.2, 46.7)",
        turnin = "Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)",
        summary = "The second of two quests called The Purple Ones. Done alongside Sickening Lights; both are needed for Twilight No More!.",
        steps = {
            { text = "The second of two quests called The Purple Ones. Done alongside Sickening Lights; both are needed for Twilight No More!.", kind = "guide", mapID = 2548, x = 0.4920, y = 0.4670 },
        },
        pins = {
            { mapID = 2548, x = 0.4920, y = 0.4670, label = "Twilight Brute — Sunnyglade cave, Riverglades", kind = "location" },
            { mapID = 2548, x = 0.5000, y = 0.4700, label = "Clubtoe — Sunnyglade cave, Riverglades", kind = "turnin" },
        },
    },
    [95602] = {
        pickup = "Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)",
        turnin = "Clubtoe, in the cave under Sunnyglade, Riverglades (50.0, 47.0; the cave's entrance is near 50, 46)",
        summary = "Done alongside The Purple Ones; both are needed for Twilight No More!.",
        steps = {
            { text = "Done alongside The Purple Ones; both are needed for Twilight No More!.", kind = "guide", mapID = 2548, x = 0.5000, y = 0.4700 },
        },
        pins = {
            { mapID = 2548, x = 0.5000, y = 0.4700, label = "Clubtoe — Sunnyglade cave, Riverglades", kind = "location" },
        },
    },
    [95646] = {
        name = "Horrors in the Highland",
        pickup = "Rethiel the Greenwarden, Wetlands",
        turnin = "Rethiel the Greenwarden, Wetlands",
        steps = {
            { text = "Prereq chain (3): Tramping Paws -> Fire Taboo -> Blisters on The Land", kind = "quest" },
        },
        pins = {
            { mapID = 1437, x = 0.5620, y = 0.4060, label = "Rethiel the Greenwarden — Wetlands", kind = "start" },
            { mapID = 1437, x = 0.5620, y = 0.4040, label = "Rethiel the Greenwarden — Wetlands", kind = "start" },
        },
    },
    [95647] = {
        name = "Lost in the Thicket Things",
        pickup = "Caitlin Grassman, Menethil Harbor, Wetlands",
        turnin = "Ardin Grassman, inside Excavation Site: Wetlands",
        summary = "Required before Heartwoven.",
        steps = {
            { text = "Required before Heartwoven.", kind = "guide", mapID = 1437, x = 0.1190, y = 0.5880 },
        },
        pins = {
            { mapID = 1437, x = 0.1190, y = 0.5880, label = "Caitlin Grassman — Menethil Harbor", kind = "start", detail = "Start Lost in the Thicket Things here" },
        },
    },
    [95663] = {
        pickup = "Zaruk, Hammerfall, Arathi Highlands",
        turnin = "Deathstalker Agent, hills above the Dragonmaw camp, Wetlands",
        summary = "Required before Open the Maw.",
        steps = {
            { text = "Required before Open the Maw.", kind = "guide", mapID = 1417, x = 0.7454, y = 0.3563 },
        },
        pins = {
            { mapID = 1417, x = 0.7454, y = 0.3563, label = "Zaruk — Hammerfall", kind = "location", detail = "Start Dragonmaw Rumors here" },
        },
    },
    [95664] = {
        pickup = "Titan Relic (dropped by Relic Guardian)",
        turnin = "Bashana Runetotem, Elder Rise, Thunder Bluff",
        steps = {
            { text = "Start with [Titan Relic] (Dropped by: Relic Guardian)", kind = "starter", itemID = 270866, itemName = "Titan Relic" },
        },
        items = {
            { id = 270866, name = "Titan Relic", role = "starter", source = "Dropped by: Relic Guardian" },
        },
    },
    [95682] = {
        name = "Open the Maw",
        pickup = "Deathstalker Agent, just outside Excavation Site: Wetlands",
        turnin = "Deathstalker Agent, just outside Excavation Site: Wetlands",
        summary = "Related lead-in: Dragonmaw Rumors. The Dragonmaw Dispatch is recovered from the Dragonmaw forces inside the dungeon.",
        steps = {
            { text = "Prereq chain (1): Dragonmaw Rumors", kind = "quest" },
        },
        pins = {
            { mapID = 1437, x = 0.5140, y = 0.5920, label = "Deathstalker Agent — Wetlands", kind = "start" },
        },
    },
    [95697] = {
        name = "Changing Tastes",
        pickup = "Borstan, The Drag, Orgrimmar",
        turnin = "Borstan, The Drag, Orgrimmar",
        summary = "Thicket Raptor Meat comes from the Thicket raptors (Thicket Lurker, Thicket Hunter, Thicket Matriarch) in Stalker's Thicket, the area of Shadetooth.",
        steps = {
            { text = "Thicket Raptor Meat comes from the Thicket raptors (Thicket Lurker, Thicket Hunter, Thicket Matriarch) in Stalker's Thicket, the area of Shadetooth.", kind = "guide", mapID = 1454, x = 0.5720, y = 0.5330 },
        },
        pins = {
            { mapID = 1454, x = 0.5720, y = 0.5330, label = "Borstan — The Drag, Orgrimmar", kind = "start" },
            { mapID = 1454, x = 0.5740, y = 0.5340, label = "Borstan — Orgrimmar", kind = "start" },
        },
    },
    [95748] = {
        pickup = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        turnin = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        steps = {
            { text = "Get [The Third Troll Legend]: Rubbing of the tablet Fall of Gurubashi, in the troll ruins on the coast north of the Vile Reef (around 23, 12)", kind = "item", itemID = 2007, itemName = "The Third Troll Legend", mapID = 1434, x = 0.2300, y = 0.1200 },
            { text = "Turn in: Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale", kind = "turnin" },
        },
        items = {
            { id = 2007, name = "The Third Troll Legend", role = "required", source = "Rubbing of the tablet Fall of Gurubashi, in the troll ruins on the coast north of the Vile Reef (around 23, 12)" },
        },
        pins = {
            { mapID = 1434, x = 0.3230, y = 0.2770, label = "Kin'weelay — Grom'gol Base Camp", kind = "location", detail = "Kin'weelay at Grom'gol Base Camp, Stranglethorn Vale" },
            { mapID = 1434, x = 0.2300, y = 0.1200, label = "Fall of Gurubashi — troll ruins north of the Vile Reef", kind = "item", detail = "The tablet in the troll ruins on the coast (around 23, 12)" },
        },
    },
    [95770] = {
        pickup = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        turnin = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        summary = "The cave is in Sunken Hollow, underwater around 21, 28: the entrance to the Drowned City.",
        steps = {
            { text = "The cave is in Sunken Hollow, underwater around 21, 28: the entrance to the Drowned City.", kind = "guide", mapID = 1434, x = 0.3230, y = 0.2770 },
        },
        pins = {
            { mapID = 1434, x = 0.3230, y = 0.2770, label = "Kin'weelay — Grom'gol Base Camp", kind = "location", detail = "Kin'weelay at Grom'gol Base Camp, Stranglethorn Vale" },
        },
    },
    [95772] = {
        name = "Songblade Search",
        pickup = "Dorin Songblade, Redridge Mountains",
        turnin = "Daewyn Songblade, inside Excavation Site: Wetlands",
        pins = {
            { mapID = 1433, x = 0.2560, y = 0.4660, label = "Dorin Songblade — Redridge Mountains", kind = "start" },
            { mapID = 1433, x = 0.2560, y = 0.4640, label = "Dorin Songblade — Redridge Mountains", kind = "start" },
        },
    },
    [95773] = {
        pickup = "Commander Aggro'gosh, Grom'gol Base Camp, Stranglethorn Vale",
        turnin = "Commander Aggro'gosh, Grom'gol Base Camp, Stranglethorn Vale",
        summary = "Commander Aggro'gosh offers it once The Gurubashi Legends of Old is handed in.",
        steps = {
            { text = "Get [Brinescale Trident]: Dropped by Brinescale Skirmishers around the Vile Reef, west of Grom'gol (around 22, 26)", kind = "item", itemID = 270305, itemName = "Brinescale Trident", mapID = 1434, x = 0.2250, y = 0.2560 },
            { text = "Turn in: Commander Aggro'gosh, Grom'gol Base Camp, Stranglethorn Vale", kind = "turnin" },
        },
        items = {
            { id = 270305, name = "Brinescale Trident", role = "required", source = "Dropped by Brinescale Skirmishers around the Vile Reef, west of Grom'gol (around 22, 26)" },
        },
        pins = {
            { mapID = 1434, x = 0.3220, y = 0.2880, label = "Commander Aggro'gosh — Grom'gol Base Camp", kind = "location", detail = "Commander Aggro'gosh at Grom'gol Base Camp, Stranglethorn Vale" },
            { mapID = 1434, x = 0.2250, y = 0.2560, label = "Brinescale Skirmishers — around the Vile Reef", kind = "item", detail = "Brinescale Skirmishers on the sea floor west of Grom'gol (around 22, 26)" },
        },
    },
    [95775] = {
        name = "The Drowned City",
        pickup = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        turnin = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        steps = {
            { text = "Prereq chain (3): The Vile Reef -> The Gurubashi Legends of Old -> Locating the Lost City", kind = "quest" },
            { text = "Get [The First Tablet of I'lalai]: A rubbing of the tablet inside the Drowned City", kind = "item", itemID = 270308, itemName = "The First Tablet of I'lalai" },
            { text = "Get [The Second Tablet of I'lalai]: A rubbing of the tablet inside the Drowned City", kind = "item", itemID = 270309, itemName = "The Second Tablet of I'lalai" },
            { text = "Get [The Third Tablet of I'lalai]: A rubbing of the tablet inside the Drowned City", kind = "item", itemID = 270310, itemName = "The Third Tablet of I'lalai" },
            { text = "Get [The Fourth Tablet of I'lalai]: A rubbing of the tablet inside the Drowned City", kind = "item", itemID = 270311, itemName = "The Fourth Tablet of I'lalai" },
            { text = "Turn in: Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale", kind = "turnin" },
        },
        items = {
            { id = 270308, name = "The First Tablet of I'lalai", role = "required", source = "A rubbing of the tablet inside the Drowned City" },
            { id = 270309, name = "The Second Tablet of I'lalai", role = "required", source = "A rubbing of the tablet inside the Drowned City" },
            { id = 270310, name = "The Third Tablet of I'lalai", role = "required", source = "A rubbing of the tablet inside the Drowned City" },
            { id = 270311, name = "The Fourth Tablet of I'lalai", role = "required", source = "A rubbing of the tablet inside the Drowned City" },
        },
        pins = {
            { mapID = 1434, x = 0.3230, y = 0.2770, label = "Kin'weelay — Grom'gol Base Camp", kind = "location", detail = "Kin'weelay at Grom'gol Base Camp, Stranglethorn Vale" },
        },
    },
    [95776] = {
        name = "The Only Good Brinescale...",
        pickup = "Commander Aggro'gosh, Grom'gol Base Camp, Stranglethorn Vale",
        turnin = "Commander Aggro'gosh, Grom'gol Base Camp, Stranglethorn Vale",
        summary = "Commander Aggro'gosh offers it once Enemies in the Water and Locating the Lost City (Kin'weelay) are both handed in.",
        steps = {
            { text = "Prereq chain (4): The Vile Reef -> The Gurubashi Legends of Old -> Enemies in the Water (+1 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1434, x = 0.3220, y = 0.2880, label = "Commander Aggro'gosh — Grom'gol Base Camp", kind = "turnin", detail = "Commander Aggro'gosh at Grom'gol Base Camp, Stranglethorn Vale" },
        },
    },
    [95786] = {
        pickup = "Brother Nimetz, Rebel Camp, Stranglethorn Vale",
        turnin = "Loremaster Dibbs, Southshore, Hillsbrad Foothills",
        steps = {
            { text = "Use provided [Savage Coast Report Bundle] (Given by Brother Nimetz when you accept the quest)", kind = "provided", itemID = 270340, itemName = "Savage Coast Report Bundle" },
            { text = "Turn in: Loremaster Dibbs, Southshore, Hillsbrad Foothills", kind = "turnin", mapID = 1424, x = 0.5060, y = 0.5710 },
        },
        items = {
            { id = 270340, name = "Savage Coast Report Bundle", role = "provided", source = "Given by Brother Nimetz when you accept the quest" },
        },
        pins = {
            { mapID = 1434, x = 0.3780, y = 0.0360, label = "Brother Nimetz — Rebel Camp", kind = "location", detail = "Brother Nimetz at the Rebel Camp, northern Stranglethorn Vale" },
            { mapID = 1424, x = 0.5060, y = 0.5710, label = "Loremaster Dibbs — Southshore", kind = "turnin", detail = "Loremaster Dibbs in Southshore, Hillsbrad Foothills" },
        },
    },
    [95787] = {
        name = "Take Two With Water",
        pickup = "Loremaster Dibbs, Southshore, Hillsbrad Foothills",
        turnin = "Loremaster Dibbs, Southshore, Hillsbrad Foothills",
        summary = "Quest giver not confirmed yet. Lead-in: An Acquaintance in Southshore, taking the Savage Coast Report Bundle to Loremaster Dibbs.",
        steps = {
            { text = "Get [The First Tablet of I'lalai]: A rubbing of the tablet inside the Drowned City", kind = "item", itemID = 270308, itemName = "The First Tablet of I'lalai" },
            { text = "Get [The Second Tablet of I'lalai]: A rubbing of the tablet inside the Drowned City", kind = "item", itemID = 270309, itemName = "The Second Tablet of I'lalai" },
            { text = "Get [The Third Tablet of I'lalai]: A rubbing of the tablet inside the Drowned City", kind = "item", itemID = 270310, itemName = "The Third Tablet of I'lalai" },
            { text = "Get [The Fourth Tablet of I'lalai]: A rubbing of the tablet inside the Drowned City", kind = "item", itemID = 270311, itemName = "The Fourth Tablet of I'lalai" },
            { text = "Turn in: Loremaster Dibbs, Southshore, Hillsbrad Foothills", kind = "turnin" },
        },
        items = {
            { id = 270308, name = "The First Tablet of I'lalai", role = "required", source = "A rubbing of the tablet inside the Drowned City" },
            { id = 270309, name = "The Second Tablet of I'lalai", role = "required", source = "A rubbing of the tablet inside the Drowned City" },
            { id = 270310, name = "The Third Tablet of I'lalai", role = "required", source = "A rubbing of the tablet inside the Drowned City" },
            { id = 270311, name = "The Fourth Tablet of I'lalai", role = "required", source = "A rubbing of the tablet inside the Drowned City" },
        },
        pins = {
            { mapID = 1424, x = 0.5060, y = 0.5710, label = "Loremaster Dibbs — Southshore", kind = "location", detail = "Loremaster Dibbs in Southshore, Hillsbrad Foothills" },
        },
    },
    [95788] = {
        name = "Magics of the Drowned City",
        pickup = "Loremaster Dibbs, Southshore, Hillsbrad Foothills",
        turnin = "Loremaster Dibbs, Southshore, Hillsbrad Foothills",
        steps = {
            { text = "Get [I'lalai Fetish]: Dropped by the trolls in the Drowned City (5 needed)", kind = "item", itemID = 270343, itemName = "I'lalai Fetish" },
            { text = "Turn in: Loremaster Dibbs, Southshore, Hillsbrad Foothills", kind = "turnin" },
        },
        items = {
            { id = 270343, name = "I'lalai Fetish", role = "required", source = "Dropped by the trolls in the Drowned City (5 needed)" },
        },
        pins = {
            { mapID = 1424, x = 0.5060, y = 0.5710, label = "Loremaster Dibbs — Southshore", kind = "location", detail = "Loremaster Dibbs in Southshore, Hillsbrad Foothills" },
        },
    },
    [95789] = {
        name = "Shady Saltseers",
        pickup = "Krazek, Booty Bay, Stranglethorn Vale",
        turnin = "Krazek, Booty Bay, Stranglethorn Vale",
        steps = {
            { text = "Get [Voodoo-Infused Artifact]: Need x10", kind = "item", itemID = 270333, itemName = "Voodoo-Infused Artifact" },
            { text = "Turn in: Krazek, Booty Bay, Stranglethorn Vale", kind = "turnin" },
        },
        items = {
            { id = 270333, name = "Voodoo-Infused Artifact", role = "required", source = "Need x10" },
        },
        pins = {
            { mapID = 1434, x = 0.2690, y = 0.7720, label = "Krazek — Booty Bay", kind = "start", detail = "Krazek, upstairs in Booty Bay, Stranglethorn Vale" },
        },
    },
    [95790] = {
        name = "Digestible Research",
        pickup = "The Partially Digested Journal lying on the ground inside Shaper's Terrace (the Verdant Plains): click it to get the quest",
        turnin = "Curator Thorius, Hall of Explorers, Ironforge (71.5, 15.7)",
        summary = "Starts from the Partially Digested Journal on the ground inside the dungeon.",
        steps = {
            { text = "Starts from the Partially Digested Journal on the ground inside the dungeon.", kind = "guide", mapID = 1455, x = 0.7150, y = 0.1570 },
        },
        pins = {
            { mapID = 1455, x = 0.7150, y = 0.1570, label = "Curator Thorius — Hall of Explorers, Ironforge", kind = "turnin" },
        },
    },
    [95791] = {
        name = "The Saltseer Captain",
        pickup = "Krazek, Booty Bay, Stranglethorn Vale",
        turnin = "Krazek, Booty Bay, Stranglethorn Vale",
        pins = {
            { mapID = 1434, x = 0.2690, y = 0.7720, label = "Krazek — Booty Bay", kind = "start", detail = "Krazek, upstairs in Booty Bay, Stranglethorn Vale" },
        },
    },
    [95798] = {
        name = "The Web of Magic",
        pickup = "Loremaster Dibbs, Southshore, Hillsbrad Foothills",
        turnin = "Abra Cadabra, Dalaran",
        summary = "The Kirin Tor only let noteworthy visitors into Dalaran.",
        steps = {
            { text = "Prereq chain (6): The Second Rebellion -> Bad Medicine -> Kurzen's Mystery (+3 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1416, x = 0.1320, y = 0.6960, label = "Abra Cadabra — Dalaran", kind = "turnin", detail = "Abra Cadabra in Dalaran, Alterac Mountains" },
            { mapID = 1424, x = 0.5060, y = 0.5710, label = "Loremaster Dibbs — Southshore", kind = "start", detail = "Loremaster Dibbs in Southshore, Hillsbrad Foothills" },
        },
    },
    [95799] = {
        name = "Findings for the Explorer's League",
        pickup = "Loremaster Dibbs, Southshore, Hillsbrad Foothills",
        turnin = "Historian Karnik, Hall of Explorers, Ironforge",
        steps = {
            { text = "Prereq chain (6): The Second Rebellion -> Bad Medicine -> Kurzen's Mystery (+3 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1455, x = 0.7750, y = 0.1180, label = "Historian Karnik — Hall of Explorers", kind = "turnin", detail = "Historian Karnik in the Hall of Explorers, Ironforge" },
            { mapID = 1424, x = 0.5060, y = 0.5710, label = "Loremaster Dibbs — Southshore", kind = "start", detail = "Loremaster Dibbs in Southshore, Hillsbrad Foothills" },
        },
    },
    [95810] = {
        pickup = "Titan Relic (dropped by Relic Guardian)",
        turnin = "Prospector Whelgar, Whelgar's Excavation Site, Wetlands",
        steps = {
            { text = "Start with [Titan Relic] (Dropped by: Relic Guardian)", kind = "starter", itemID = 270866, itemName = "Titan Relic" },
        },
        items = {
            { id = 270866, name = "Titan Relic", role = "starter", source = "Dropped by: Relic Guardian" },
        },
    },
    [95924] = {
        name = "Panic at the Digsite",
        pickup = "Curator Thorius, Hall of Explorers, Ironforge (71.5, 15.7)",
        turnin = "Curator Thorius, Hall of Explorers, Ironforge (71.5, 15.7)",
        summary = "The quest text asks for 9 Ironhide Ravasaurs, its objective counts 8.",
        steps = {
            { text = "The quest text asks for 9 Ironhide Ravasaurs, its objective counts 8.", kind = "guide", mapID = 1455, x = 0.7150, y = 0.1570 },
        },
        pins = {
            { mapID = 1455, x = 0.7150, y = 0.1570, label = "Curator Thorius — Hall of Explorers, Ironforge", kind = "start" },
        },
    },
    [95925] = {
        name = "Mapping the Way Forward",
        pickup = "Curator Thorius, Hall of Explorers, Ironforge (71.5, 15.7)",
        turnin = "Curator Thorius, Hall of Explorers, Ironforge (71.5, 15.7)",
        summary = "You map them with an Explorers' League Cartographer's Kit.",
        steps = {
            { text = "You map them with an Explorers' League Cartographer's Kit.", kind = "guide", mapID = 1455, x = 0.7150, y = 0.1570 },
        },
        pins = {
            { mapID = 1455, x = 0.7150, y = 0.1570, label = "Curator Thorius — Hall of Explorers, Ironforge", kind = "start" },
        },
    },
    [95926] = {
        name = "The Dark Crystal",
        pickup = "Master Apothecary Faranell, The Apothecarium, Undercity (48.8, 69.3)",
        turnin = "Master Apothecary Faranell, The Apothecarium, Undercity (48.8, 69.3)",
        steps = {
            { text = "Get [Drained Crystal Fragment]", kind = "item", itemID = 271771, itemName = "Drained Crystal Fragment" },
            { text = "Turn in: Master Apothecary Faranell, The Apothecarium, Undercity (48.8, 69.3)", kind = "turnin" },
        },
        items = {
            { id = 271771, name = "Drained Crystal Fragment", role = "required" },
        },
        pins = {
            { mapID = 1458, x = 0.4880, y = 0.6930, label = "Master Apothecary Faranell — Undercity", kind = "start" },
        },
    },
    [95928] = {
        name = "Crystalline Elements",
        pickup = "Mayena Earthseeker, Mulgore (34.8, 22.2)",
        turnin = "Mayena Earthseeker, Mulgore (34.8, 22.2)",
        steps = {
            { text = "Get [Moist Crystal]: Inside Shaper's Terrace", kind = "item", itemID = 271912, itemName = "Moist Crystal" },
            { text = "Get [Charged Crystal]: Inside Shaper's Terrace", kind = "item", itemID = 271898, itemName = "Charged Crystal" },
            { text = "Get [Noxious Crystal]: Inside Shaper's Terrace", kind = "item", itemID = 271902, itemName = "Noxious Crystal" },
            { text = "Get [Fiery Crystal]: Inside Shaper's Terrace", kind = "item", itemID = 271894, itemName = "Fiery Crystal" },
            { text = "Turn in: Mayena Earthseeker, Mulgore (34.8, 22.2)", kind = "turnin" },
        },
        items = {
            { id = 271912, name = "Moist Crystal", role = "required", source = "Inside Shaper's Terrace" },
            { id = 271898, name = "Charged Crystal", role = "required", source = "Inside Shaper's Terrace" },
            { id = 271902, name = "Noxious Crystal", role = "required", source = "Inside Shaper's Terrace" },
            { id = 271894, name = "Fiery Crystal", role = "required", source = "Inside Shaper's Terrace" },
        },
        pins = {
            { mapID = 1412, x = 0.3480, y = 0.2220, label = "Mayena Earthseeker — Mulgore", kind = "start" },
        },
    },
    [96010] = {
        pickup = "Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)",
        turnin = "Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)",
        summary = "One crystal at each centaur camp in Desolace.",
        steps = {
            { text = "Get [Pylon Fragment]: Guarded in one of the centaur villages (Magram or Gelkis), Desolace", kind = "item", itemID = 255656, itemName = "Pylon Fragment" },
            { text = "Get [Pylon Shard]: Guarded in the other centaur village (Magram or Gelkis), Desolace", kind = "item", itemID = 255657, itemName = "Pylon Shard" },
            { text = "Turn in: Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)", kind = "turnin" },
        },
        items = {
            { id = 255656, name = "Pylon Fragment", role = "required", source = "Guarded in one of the centaur villages (Magram or Gelkis), Desolace" },
            { id = 255657, name = "Pylon Shard", role = "required", source = "Guarded in the other centaur village (Magram or Gelkis), Desolace" },
        },
        pins = {
            { mapID = 2652, x = 0.3500, y = 0.4640, label = "Mordent Evenshade — Evenshade's Overlook, Shen'dralas", kind = "location" },
        },
    },
    [96016] = {
        name = "The Tempest's Weapons",
        pickup = "Veyric Thunderhame, Arathi Highlands (59.6, 27.6)",
        turnin = "Bath'rah the Windwatcher, Alterac Mountains (80.4, 66.8)",
        summary = "Final step. Choose Rage of the Storm, Lightning's Grasp or Tidebringer's Claw; Alliance Shamans also get Elementalist's Guard.",
        warning = "This is a chain quest with a step in Razorfen Kraul",
        steps = {
            { text = "Prereq chain (3): Elemental Aid -> Storm, Earth, and Fire -> Heed My Call", kind = "quest" },
        },
        pins = {
            { mapID = 1417, x = 0.5960, y = 0.2760, label = "Veyric Thunderhame — Arathi Highlands", kind = "start" },
        },
    },
    [96018] = {
        pickup = "Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)",
        turnin = "Mordent Evenshade, Evenshade's Overlook, Shen'dralas (35.0, 46.4)",
        summary = "The Mana Sieve is on the top floor of the big temple. Take 8 mana from the arcane orbs around Shen'dralas, then use the pylon parts with 4 mana on each pylon.",
        steps = {
            { text = "The Mana Sieve is on the top floor of the big temple. Take 8 mana from the arcane orbs around Shen'dralas, then use the pylon parts with 4 mana on each pylon.", kind = "guide", mapID = 2652, x = 0.3500, y = 0.4640 },
        },
        pins = {
            { mapID = 2652, x = 0.3500, y = 0.4640, label = "Mordent Evenshade — Evenshade's Overlook, Shen'dralas", kind = "location" },
        },
    },
    [96078] = {
        name = "A Tale Spun Around the Fire",
        pickup = "Kin'weelay, Grom'gol Base Camp, Stranglethorn Vale",
        turnin = "Master Gadrin, Sen'jin Village, Durotar",
        steps = {
            { text = "Prereq chain (4): The Vile Reef -> The Gurubashi Legends of Old -> Locating the Lost City (+1 more)", kind = "quest" },
        },
        pins = {
            { mapID = 1411, x = 0.5580, y = 0.7440, label = "Master Gadrin — Sen'jin Village", kind = "turnin", detail = "Master Gadrin in Sen'jin Village, Durotar" },
            { mapID = 1434, x = 0.3230, y = 0.2770, label = "Kin'weelay — Grom'gol Base Camp", kind = "start", detail = "Kin'weelay at Grom'gol Base Camp, Stranglethorn Vale" },
        },
    },
    [96135] = {
        pickup = "Veyric Thunderhame, Arathi Highlands (59.6, 27.6)",
        turnin = "Veyric Thunderhame, Arathi Highlands (59.6, 27.6)",
        summary = "Elite, level 40: bring a group. At the steam pools in Thousand Needles, stand on the rune circle and use the Corrupted Totems. Waves of elementals come, then an elite quilboar and the Ravaging Tempest, which drops the Eye of the Tempest for every Shaman on the quest.",
        steps = {
            { text = "Elite, level 40: bring a group. At the steam pools in Thousand Needles, stand on the rune circle and use the Corrupted Totems. Waves of elementals come, then an elite quilboar and the Ravaging Tempest, which drops the Eye of the Tempest for every Shaman on the quest.", kind = "guide", mapID = 1417, x = 0.5960, y = 0.2760 },
        },
        pins = {
            { mapID = 1417, x = 0.5960, y = 0.2760, label = "Veyric Thunderhame — Arathi Highlands", kind = "location" },
        },
    },
    [96204] = {
        pickup = "Lumina Windsinger, Fenris Keep, Silverpine Forest",
        turnin = "Lumina Windsinger, The Sepulcher, Silverpine Forest",
        pins = {
            { mapID = 1421, x = 0.6570, y = 0.2740, label = "Lumina Windsinger — Fenris Keep", kind = "location" },
            { mapID = 1421, x = 0.4330, y = 0.4100, label = "Lumina Windsinger — The Sepulcher", kind = "turnin" },
        },
    },
    [96246] = {
        name = "Blackmaw Pouches",
        pickup = "Ekkal, Ruins of Eldarath, Azshara (42.0, 38.9)",
        turnin = "Ekkal, Ruins of Eldarath, Azshara (42.0, 38.9)",
        summary = "Repeatable, after the first Blackmaw Pouches.",
        steps = {
            { text = "Get [Blackmaw Pouch]: Need x5", kind = "item", itemID = 273050, itemName = "Blackmaw Pouch" },
            { text = "Turn in: Ekkal, Ruins of Eldarath, Azshara (42.0, 38.9)", kind = "turnin" },
        },
        items = {
            { id = 273050, name = "Blackmaw Pouch", role = "required", source = "Need x5" },
        },
        pins = {
            { mapID = 1447, x = 0.4200, y = 0.3890, label = "Ekkal — Ruins of Eldarath, Azshara", kind = "start" },
        },
    },
    [96264] = {
        pickup = "Veyric Thunderhame, Arathi Highlands (59.6, 27.6)",
        turnin = "Veyric Thunderhame, Arathi Highlands (59.6, 27.6)",
        summary = "The Razorfen Kraul step. Call of Air (from Eldrun Stormbreaker in Ironforge) sends you to Veyric. Alliance Shamans can share this quest.",
        steps = {
            { text = "Get [Tattered Note]: Drops from Charlga Razorflank in Razorfen Kraul, for every Shaman on the quest", kind = "item", itemID = 274463, itemName = "Tattered Note" },
            { text = "Turn in: Veyric Thunderhame, Arathi Highlands (59.6, 27.6)", kind = "turnin" },
        },
        items = {
            { id = 274463, name = "Tattered Note", role = "required", source = "Drops from Charlga Razorflank in Razorfen Kraul, for every Shaman on the quest" },
        },
        pins = {
            { mapID = 1417, x = 0.5960, y = 0.2760, label = "Veyric Thunderhame — Arathi Highlands", kind = "location" },
        },
    },
    [96332] = {
        name = "A Little Payback",
        pickup = "Sergeant Ulka, outside Alcaz Prison, Alcaz Island, Dustwallow Marsh (70.2, 18.8)",
        turnin = "Sergeant Ulka, outside Alcaz Prison, Alcaz Island, Dustwallow Marsh (70.2, 18.8)",
        steps = {
            { text = "Prereq chain (3): The Missing Kor'kron -> The Elite of the Elite -> Right Place, Wrong Time", kind = "quest" },
            { text = "Get [Ca'zass's Head]", kind = "item", itemID = 273883, itemName = "Ca'zass's Head" },
            { text = "Turn in: Sergeant Ulka, outside Alcaz Prison, Alcaz Island, Dustwallow Marsh (70.2, 18.8)", kind = "turnin" },
        },
        items = {
            { id = 273883, name = "Ca'zass's Head", role = "required" },
        },
        pins = {
            { mapID = 1445, x = 0.7020, y = 0.1880, label = "Sergeant Ulka — Alcaz Island, Dustwallow Marsh", kind = "start" },
        },
    },
    [96334] = {
        name = "Blood Red Bandanas",
        pickup = "Sergeant Ulka, outside Alcaz Prison, Alcaz Island, Dustwallow Marsh (70.2, 18.8)",
        turnin = "Eitrigg, Grommash Hold, Orgrimmar",
        steps = {
            { text = "Prereq chain (3): The Missing Kor'kron -> The Elite of the Elite -> Right Place, Wrong Time", kind = "quest" },
            { text = "Get [Blood Red Bandana]: Need x8", kind = "item", itemID = 274028, itemName = "Blood Red Bandana" },
            { text = "Turn in: Eitrigg, Grommash Hold, Orgrimmar", kind = "turnin", mapID = 1454, x = 0.3440, y = 0.3860 },
        },
        items = {
            { id = 274028, name = "Blood Red Bandana", role = "required", source = "Need x8" },
        },
        pins = {
            { mapID = 1445, x = 0.7020, y = 0.1880, label = "Sergeant Ulka — Alcaz Island, Dustwallow Marsh", kind = "start" },
            { mapID = 1454, x = 0.3440, y = 0.3860, label = "Eitrigg — Grommash Hold, Orgrimmar", kind = "turnin" },
        },
    },
    [96335] = {
        pickup = "Mason Connery, the man in iron chains, inside Alcaz Prison",
        turnin = "Mason Connery, inside Alcaz Prison",
        steps = {
            { text = "Get [Ornate Shackle Key]: From The Questioner in Alcaz Prison", kind = "item", itemID = 274029, itemName = "Ornate Shackle Key" },
            { text = "Turn in: Mason Connery, inside Alcaz Prison", kind = "turnin" },
        },
        items = {
            { id = 274029, name = "Ornate Shackle Key", role = "required", source = "From The Questioner in Alcaz Prison" },
        },
    },
    [96337] = {
        name = "More Valuable Than Gold",
        pickup = "Mason Connery, inside Alcaz Prison, once you free him",
        turnin = "Mason Connery's treasure: a loose floorboard upstairs in the middle room of the Moonbrook inn, Westfall (43.4, 67.8)",
        summary = "The Document Box sells for 25g, and it starts State Secrets (a Horde, an Alliance and a Steamwheedle Cartel version); who takes it is not known yet.",
        warning = "Don't kill The Questioner before the last boss, or you can't get this quest.",
        steps = {
            { text = "Prereq chain (1): The Man in the Iron Chains", kind = "quest" },
            { text = "Use provided [Mason's Note] (Given by Mason Connery when you accept the quest)", kind = "provided", itemID = 274077, itemName = "Mason's Note" },
            { text = "Turn in: Mason Connery's treasure: a loose floorboard upstairs in the middle room of the Moonbrook inn, Westfall (43.4, 67.8)", kind = "turnin", mapID = 1436, x = 0.4340, y = 0.6780 },
        },
        items = {
            { id = 274077, name = "Mason's Note", role = "provided", source = "Given by Mason Connery when you accept the quest" },
        },
        pins = {
            { mapID = 1436, x = 0.4340, y = 0.6780, label = "Mason Connery's treasure — Moonbrook inn, Westfall", kind = "turnin" },
        },
    },
    [96381] = {
        name = "A Bit of Wet Work",
        pickup = "Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)",
        turnin = "Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)",
        steps = {
            { text = "Prereq chain (3): Our Man in Theramore -> Watch Yer Back -> The Return of the King?", kind = "quest" },
            { text = "Get [Ca'zass's Head]", kind = "item", itemID = 273883, itemName = "Ca'zass's Head" },
            { text = "Turn in: Sully McCleary, in the inn in Theramore, Dustwallow Marsh (66.2, 45.2)", kind = "turnin" },
        },
        items = {
            { id = 273883, name = "Ca'zass's Head", role = "required" },
        },
        pins = {
            { mapID = 1445, x = 0.6620, y = 0.4520, label = "Sully McCleary — inn, Theramore", kind = "start" },
        },
    },
    [96391] = {
        pickup = "Dark Iron Map, dropped by Dark Iron Spies at Ironband's Compound, Dun Morogh",
        turnin = "Earthseer Farsen, Dun Morogh",
        summary = "The Dark Iron Map starts this quest and leads directly into Old Ironforge Incursion.",
        steps = {
            { text = "The Dark Iron Map starts this quest and leads directly into Old Ironforge Incursion.", kind = "guide", mapID = 1426, x = 0.7700, y = 0.6000 },
        },
        pins = {
            { mapID = 1426, x = 0.7700, y = 0.6000, label = "Dark Iron Spies — Ironband's Compound", kind = "location", detail = "Farm Dark Iron Spies here for the Dark Iron Map" },
        },
    },
    [96393] = {
        name = "Old Ironforge Incursion",
        pickup = "Earthseer Farsen, Dun Morogh (after Underground Map)",
        turnin = "King Magni Bronzebeard, Ironforge",
        summary = "The chain begins by dropping Dark Iron Map from Dark Iron Spies in Dun Morogh.",
        steps = {
            { text = "Prereq chain (1): Underground Map", kind = "quest" },
        },
        items = {
            { id = 274268, name = "Dark Iron Map", role = "objective", source = "Dropped by: Dark Iron Spies in Dun Morogh" },
        },
        pins = {
            { mapID = 1426, x = 0.7620, y = 0.6080, label = "Dark Iron Spies — Ironband's Compound", kind = "objective", detail = "Dark Iron Map drops from Dark Iron Spies around Ironband's Compound" },
            { mapID = 1426, x = 0.6470, y = 0.5840, label = "Earthseer Farsen — Gol'Bolar Quarry, Dun Morogh", kind = "start" },
        },
    },
    [96394] = {
        name = "The Restless Dead",
        pickup = "Afadra Dunwall, top of Old Ironforge, outside the dungeon",
        turnin = "Afadra Dunwall, Ironforge",
        pins = {
            { mapID = 1455, x = 0.3330, y = 0.4810, label = "Afadra Dunwall — top of Old Ironforge", kind = "start", detail = "Top of Old Ironforge, outside the dungeon" },
        },
    },
    [96403] = {
        name = "Important Heirlooms",
        pickup = "Thom Filch, by the bridge / vault entrance in Ironforge",
        turnin = "Thom Filch, near the dungeon entrance",
        pins = {
            { mapID = 1455, x = 0.4350, y = 0.5200, label = "Thom Filch — Hall of Thanes portal, Ironforge", kind = "start" },
        },
    },
    [96438] = {
        pickup = "Katherine the Pure, Cathedral of Light, Stormwind",
        turnin = "Broken Warhammer, Mannoroc Coven, Desolace",
        pins = {
            { mapID = 1453, x = 0.4850, y = 0.4910, label = "Katherine the Pure — Cathedral of Light, Stormwind", kind = "location" },
            { mapID = 1443, x = 0.5270, y = 0.8480, label = "Broken Warhammer — Mannoroc Coven, Desolace", kind = "turnin" },
        },
    },
    [96770] = {
        name = "The Witch Doctor's Head",
        pickup = "Archmage Lan'dalock, Dalaran, Alterac Mountains",
        turnin = "Archmage Lan'dalock, Dalaran, Alterac Mountains",
        steps = {
            { text = "Get [Zum'rah's Head]", kind = "item", itemID = 277112, itemName = "Zum'rah's Head" },
            { text = "Turn in: Archmage Lan'dalock, Dalaran, Alterac Mountains", kind = "turnin" },
        },
        items = {
            { id = 277112, name = "Zum'rah's Head", role = "required" },
        },
        pins = {
            { mapID = 1416, x = 0.1540, y = 0.7380, label = "Archmage Lan'dalock — Dalaran", kind = "start" },
        },
    },
    [96771] = {
        name = "Vengeance of the Highborne",
        pickup = "Ranath Nightstride, in the inn in Dalaran, Alterac Mountains",
        turnin = "Ranath Nightstride, in the inn in Dalaran, Alterac Mountains",
        summary = "Zalfan Moonshadow, a highborne among the Twilight's Hammer inside the stronghold: groups meet him after Tunk, on the way to the bridge.",
        steps = {
            { text = "Zalfan Moonshadow, a highborne among the Twilight's Hammer inside the stronghold: groups meet him after Tunk, on the way to the bridge.", kind = "guide", mapID = 1416, x = 0.1780, y = 0.6600 },
        },
        pins = {
            { mapID = 1416, x = 0.1780, y = 0.6600, label = "Ranath Nightstride — Dalaran", kind = "turnin", detail = "Ranath Nightstride, in the inn in Dalaran, Alterac Mountains" },
        },
    },
    [96772] = {
        name = "The Dragon's Journal",
        pickup = "Archmage Lan'dalock, at the Violet Hold entrance in Dalaran, Alterac Mountains (15.4, 73.8)",
        turnin = "Archmage Lan'dalock, at the Violet Hold entrance in Dalaran, Alterac Mountains",
        steps = {
            { text = "Get [Zarla's Journal]", kind = "item", itemID = 276890, itemName = "Zarla's Journal" },
            { text = "Turn in: Archmage Lan'dalock, at the Violet Hold entrance in Dalaran, Alterac Mountains", kind = "turnin" },
        },
        items = {
            { id = 276890, name = "Zarla's Journal", role = "required" },
        },
        pins = {
            { mapID = 1416, x = 0.1540, y = 0.7380, label = "Archmage Lan'dalock — Violet Hold entrance, Dalaran", kind = "start" },
        },
    },
    [96773] = {
        name = "The Coldbringer's Eye",
        pickup = "Archmage Lan'dalock, at the Violet Hold entrance in Dalaran, Alterac Mountains (15.4, 73.8)",
        turnin = "Archmage Lan'dalock, at the Violet Hold entrance in Dalaran, Alterac Mountains (15.4, 73.8)",
        steps = {
            { text = "Get [The Coldbringer's Eye]", kind = "item", itemID = 276916, itemName = "The Coldbringer's Eye" },
            { text = "Turn in: Archmage Lan'dalock, at the Violet Hold entrance in Dalaran, Alterac Mountains (15.4, 73.8)", kind = "turnin" },
        },
        items = {
            { id = 276916, name = "The Coldbringer's Eye", role = "required" },
        },
        pins = {
            { mapID = 1416, x = 0.1540, y = 0.7380, label = "Archmage Lan'dalock — Violet Hold entrance, Dalaran", kind = "start" },
        },
    },
    [96774] = {
        name = "Ancient Gurubashi Idol",
        pickup = "Mazu'kon, Mulgore",
        turnin = "Mazu'kon, Mulgore",
        steps = {
            { text = "Get [Ancient Gurubashi Idol]", kind = "item", itemID = 276894, itemName = "Ancient Gurubashi Idol" },
            { text = "Turn in: Mazu'kon, Mulgore", kind = "turnin" },
        },
        items = {
            { id = 276894, name = "Ancient Gurubashi Idol", role = "required" },
        },
        pins = {
            { mapID = 1412, x = 0.3250, y = 0.2060, label = "Mazu'kon — Mulgore", kind = "start", detail = "Mazu'kon of the Earthen Ring, north-west Mulgore" },
        },
    },
    [96775] = {
        name = "Zum'rah's Head",
        pickup = "Mazu'kon, Skywatcher Plateau, Mulgore",
        turnin = "Mazu'kon, Skywatcher Plateau, Mulgore",
        steps = {
            { text = "Get [Zum'rah's Head]", kind = "item", itemID = 277112, itemName = "Zum'rah's Head" },
            { text = "Turn in: Mazu'kon, Skywatcher Plateau, Mulgore", kind = "turnin" },
        },
        items = {
            { id = 277112, name = "Zum'rah's Head", role = "required" },
        },
        pins = {
            { mapID = 1412, x = 0.3250, y = 0.2060, label = "Mazu'kon — Mulgore", kind = "start", detail = "Mazu'kon of the Earthen Ring, north-west Mulgore" },
        },
    },
    [96776] = {
        name = "An'she's Radiance",
        pickup = "Olana Brighthoof, Skywatcher Plateau, Mulgore",
        turnin = "Olana Brighthoof, Skywatcher Plateau, Mulgore",
        summary = "Beyond Earth Song Falls, find the chamber of brilliant white crystals guarded by giants. Retrieve An'she's Radiance from the crystal near the highest part of the chamber. Rewards 300 Earthen Ring and 200 Thunder Bluff reputation.",
        steps = {
            { text = "Beyond Earth Song Falls, find the chamber of brilliant white crystals guarded by giants. Retrieve An'she's Radiance from the crystal near the highest part of the chamber. Rewards 300 Earthen Ring and 200 Thunder Bluff reputation.", kind = "guide", mapID = 1412, x = 0.3380, y = 0.2370 },
        },
        pins = {
            { mapID = 1412, x = 0.3380, y = 0.2370, label = "Olana Brighthoof - Skywatcher Plateau, Mulgore", kind = "start", detail = "Olana Brighthoof: Camp Gev'rek, Skywatcher Plateau, Mulgore (33.8, 23.7)" },
        },
    },
    [96800] = {
        name = "Past Due",
        pickup = "Magus Olvek, Dalaran, Alterac Mountains",
        turnin = "Magus Olvek, Dalaran, Alterac Mountains",
        summary = "New in Forever. The book is held by Arcanist Doan.",
        steps = {
            { text = "New in Forever. The book is held by Arcanist Doan.", kind = "guide", mapID = 1416, x = 0.0970, y = 0.6190 },
        },
        pins = {
            { mapID = 1416, x = 0.0970, y = 0.6190, label = "Magus Olvek — Dalaran", kind = "start" },
            { mapID = 1416, x = 0.0940, y = 0.6260, label = "Magus Olvek — Dalaran", kind = "start" },
        },
    },
    [96984] = {
        name = "Heart of Disruption",
        pickup = "Image of Archmage Modera, Lordamere Lake near Dalaran",
        turnin = "Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills",
        summary = "Horde Dalaran attunement. Stone Tokens and Bracers of Binding can be done alongside the chain, but they are optional and are not required for attunement.",
        steps = {
            { text = "Prereq chain (4): Prison Break In -> Key to the City -> Dalaran Patrols (+1 more)", kind = "quest" },
            { text = "Use provided [Dalaran Sewer Key] (Provided when Heart of Disruption is accepted)", kind = "provided", itemID = 277507, itemName = "Dalaran Sewer Key" },
            { text = "Get [Arcane Mote]", kind = "item", itemID = 251961, itemName = "Arcane Mote" },
            { text = "Turn in: Magus Wordeen Voidglare, Tarren Mill, Hillsbrad Foothills", kind = "turnin" },
        },
        items = {
            { id = 277507, name = "Dalaran Sewer Key", role = "provided", source = "Provided when Heart of Disruption is accepted" },
            { id = 251961, name = "Arcane Mote", role = "required" },
        },
        pins = {
            { mapID = 1416, x = 0.0770, y = 0.5880, label = "Image of Archmage Modera — Lordamere Lake near Dalaran", kind = "start" },
            { mapID = 1421, x = 0.6840, y = 0.4520, label = "Image of Archmage Modera — Silverpine Forest", kind = "start" },
        },
    },
    [96986] = {
        name = "The Grave Knight",
        pickup = "Melisara, Tarren Mill, Hillsbrad Foothills",
        turnin = "Melisara, Tarren Mill, Hillsbrad Foothills",
        summary = "Quest data is recorded in the beta; dungeon access may be unavailable.",
        steps = {
            { text = "Quest data is recorded in the beta; dungeon access may be unavailable.", kind = "guide", mapID = 1424, x = 0.6260, y = 0.2060 },
        },
        pins = {
            { mapID = 1424, x = 0.6260, y = 0.2060, label = "Melisara — Tarren Mill", kind = "start" },
            { mapID = 1424, x = 0.6240, y = 0.2040, label = "Melisara — Hillsbrad Foothills", kind = "start" },
        },
    },
    [96987] = {
        name = "Opportunistic Education",
        pickup = "Rexxie Copperclutch, inside the dungeon, near the sewer entrance",
        turnin = "Rexxie Copperclutch, inside the dungeon, near the sewer entrance",
        summary = "Quest data is recorded in the beta; dungeon access may be unavailable.",
        steps = {
            { text = "Quest data is recorded in the beta; dungeon access may be unavailable.", kind = "guide" },
        },
    },
    [96988] = {
        name = "Source of Power",
        pickup = "Doctor Martin Felben, Undercity",
        turnin = "Doctor Martin Felben, Undercity",
        summary = "Quest data is recorded in the beta; dungeon access may be unavailable.",
        steps = {
            { text = "Quest data is recorded in the beta; dungeon access may be unavailable.", kind = "guide", mapID = 1458, x = 0.4660, y = 0.7410 },
        },
        pins = {
            { mapID = 1458, x = 0.4660, y = 0.7410, label = "Doctor Martin Felben — Undercity", kind = "start" },
            { mapID = 1458, x = 0.4580, y = 0.7320, label = "Doctor Martin Felben — Undercity", kind = "start" },
        },
    },
    [97049] = {
        name = "Essence of Seeping Slimes",
        pickup = "Chemist Fuely, The Apothecarium, Undercity (47.5, 73.3)",
        turnin = "Chemist Fuely, The Apothecarium, Undercity (47.5, 73.3)",
        steps = {
            { text = "Get [Seeping Slime Essence]: Need x8", kind = "item", itemID = 276235, itemName = "Seeping Slime Essence" },
            { text = "Turn in: Chemist Fuely, The Apothecarium, Undercity (47.5, 73.3)", kind = "turnin" },
        },
        items = {
            { id = 276235, name = "Seeping Slime Essence", role = "required", source = "Need x8" },
        },
        pins = {
            { mapID = 1458, x = 0.4750, y = 0.7330, label = "Chemist Fuely — Undercity", kind = "start" },
        },
    },
    [97130] = {
        name = "Ancient Gurubashi Secrets",
        pickup = "Archmage Timear, outside where the Violet Hold stood, Dalaran, Alterac Mountains",
        turnin = "Archmage Timear, outside where the Violet Hold stood, Dalaran, Alterac Mountains",
        steps = {
            { text = "Get [Ancient Gurubashi Idol]", kind = "item", itemID = 276894, itemName = "Ancient Gurubashi Idol" },
            { text = "Turn in: Archmage Timear, outside where the Violet Hold stood, Dalaran, Alterac Mountains", kind = "turnin", mapID = 1416, x = 0.1540, y = 0.7400 },
        },
        items = {
            { id = 276894, name = "Ancient Gurubashi Idol", role = "required" },
        },
        pins = {
            { mapID = 1416, x = 0.1540, y = 0.7400, label = "Archmage Timear — Dalaran", kind = "turnin", detail = "Archmage Timear, outside where the Violet Hold stood in Dalaran, Alterac Mountains" },
        },
    },
    [97173] = {
        name = "Blackmaw Magic",
        pickup = "Archmage Timear, Dalaran (15.4, 74.0)",
        turnin = "Archmage Timear, Dalaran (15.4, 74.0)",
        steps = {
            { text = "Get [Blackmaw Ritual Totem]", kind = "item", itemID = 276893, itemName = "Blackmaw Ritual Totem" },
            { text = "Turn in: Archmage Timear, Dalaran (15.4, 74.0)", kind = "turnin", mapID = 1416, x = 0.1540, y = 0.7400 },
        },
        items = {
            { id = 276893, name = "Blackmaw Ritual Totem", role = "required" },
        },
        pins = {
            { mapID = 1416, x = 0.1540, y = 0.7400, label = "Archmage Timear — Dalaran", kind = "turnin" },
        },
    },
    [97196] = {
        name = "The Coldbringer's Eye",
        pickup = "Sutara Plainstalker, Skywatcher Plateau, Mulgore",
        turnin = "Sutara Plainstalker, Skywatcher Plateau, Mulgore",
        steps = {
            { text = "Get [The Coldbringer's Eye]", kind = "item", itemID = 276916, itemName = "The Coldbringer's Eye" },
            { text = "Turn in: Sutara Plainstalker, Skywatcher Plateau, Mulgore", kind = "turnin" },
        },
        items = {
            { id = 276916, name = "The Coldbringer's Eye", role = "required" },
        },
        pins = {
            { mapID = 1412, x = 0.3440, y = 0.2280, label = "Sutara Plainstalker — Mulgore", kind = "start", detail = "Sutara Plainstalker of the Earthen Ring, north-west Mulgore" },
        },
    },
    [97197] = {
        name = "Fragment of the Firelands",
        pickup = "Alaana Stormwalker, Skywatcher Plateau, Mulgore (33.4, 22.5)",
        turnin = "Alaana Stormwalker, Skywatcher Plateau, Mulgore (33.4, 22.5)",
        summary = "The Fragment of the Firelands drops from Magmus, the guardian at the door to the Imperial Seat in Blackrock Depths. Seen picked up at level 49.",
        steps = {
            { text = "Get [Fragment of the Firelands]: Drops from Magmus in Blackrock Depths", kind = "item", itemID = 277129, itemName = "Fragment of the Firelands" },
            { text = "Turn in: Alaana Stormwalker, Skywatcher Plateau, Mulgore (33.4, 22.5)", kind = "turnin" },
        },
        items = {
            { id = 277129, name = "Fragment of the Firelands", role = "required", source = "Drops from Magmus in Blackrock Depths" },
        },
        pins = {
            { mapID = 1412, x = 0.3340, y = 0.2250, label = "Alaana Stormwalker — Skywatcher Plateau", kind = "start", detail = "Where the skycutter lands, northwest of Thunder Bluff" },
        },
    },
    [97198] = {
        name = "Blackmaw Magic",
        pickup = "Muln Earthfury, Mulgore (33.4, 22.5)",
        turnin = "Muln Earthfury, Mulgore (33.4, 22.5)",
        steps = {
            { text = "Get [Blackmaw Ritual Totem]", kind = "item", itemID = 276893, itemName = "Blackmaw Ritual Totem" },
            { text = "Turn in: Muln Earthfury, Mulgore (33.4, 22.5)", kind = "turnin", mapID = 1412, x = 0.3340, y = 0.2250 },
        },
        items = {
            { id = 276893, name = "Blackmaw Ritual Totem", role = "required" },
        },
        pins = {
            { mapID = 1412, x = 0.3340, y = 0.2250, label = "Muln Earthfury — Skywatcher Plateau, Mulgore", kind = "turnin" },
        },
    },
    [97288] = {
        name = "Unending Torment",
        pickup = "Item start: Abominable Head, inside Ruins of Lordaeron",
        turnin = "Master Apothecary Faranell, Undercity",
        summary = "The item choice is awarded on the follow-up Unending Torment step in Undercity.",
        steps = {
            { text = "Start with [Abominable Head] (Dropped by: The Baron)", kind = "starter", itemID = 280438, itemName = "Abominable Head" },
        },
        items = {
            { id = 280438, name = "Abominable Head", role = "starter", source = "Dropped by: The Baron" },
        },
    },
    [97327] = {
        name = "Blackmaw Pouches",
        pickup = "Ekkal, Ruins of Eldarath, Azshara (42.0, 38.9)",
        turnin = "Ekkal, Ruins of Eldarath, Azshara (42.0, 38.9)",
        summary = "Afterwards Ekkal takes more pouches as a repeatable quest (Timbermaw Hold +100).",
        steps = {
            { text = "Get [Blackmaw Pouch]: Need x5", kind = "item", itemID = 273050, itemName = "Blackmaw Pouch" },
            { text = "Turn in: Ekkal, Ruins of Eldarath, Azshara (42.0, 38.9)", kind = "turnin" },
        },
        items = {
            { id = 273050, name = "Blackmaw Pouch", role = "required", source = "Need x5" },
        },
        pins = {
            { mapID = 1447, x = 0.4200, y = 0.3890, label = "Ekkal — Ruins of Eldarath, Azshara", kind = "start" },
        },
    },
    [98325] = {
        pickup = "Warlord Goretooth, Kargath, Badlands (5.8, 47.4)",
        turnin = "Warlord Goretooth, Kargath, Badlands (5.8, 47.4)",
        summary = "New in WoW Forever: it comes before Warlord's Command.",
        steps = {
            { text = "New in WoW Forever: it comes before Warlord's Command.", kind = "guide", mapID = 1418, x = 0.0580, y = 0.4740 },
        },
        pins = {
            { mapID = 1418, x = 0.0580, y = 0.4740, label = "Warlord Goretooth — Kargath, Badlands", kind = "location" },
        },
    },
    [98423] = {
        name = "The Treaty of Understanding",
        pickup = "Stone tablet inside a vault in the Reliquary of Kings (Durgen Dirgehammer's room)",
        turnin = "King Magni Bronzebeard, Ironforge",
        summary = "The tablet is inside one of the vaults in the Reliquary of Kings, in Durgen Dirgehammer's final boss room. Open the vaults and interact with the tablet before leaving the dungeon.",
        steps = {
            { text = "The tablet is inside one of the vaults in the Reliquary of Kings, in Durgen Dirgehammer's final boss room. Open the vaults and interact with the tablet before leaving the dungeon.", kind = "guide" },
        },
    },
    [98815] = {
        name = "Highland Hides",
        pickup = "James Halloran, Menethil Harbor, Wetlands",
        turnin = "James Halloran, Menethil Harbor, Wetlands",
        steps = {
            { text = "Prereq chain (1): Young Crocolisk Skins", kind = "quest" },
        },
        pins = {
            { mapID = 1437, x = 0.0800, y = 0.5500, label = "James Halloran — Menethil Harbor", kind = "start" },
            { mapID = 1437, x = 0.0840, y = 0.5580, label = "James Halloran — Wetlands", kind = "start" },
        },
    },
    [98823] = {
        name = "Earthen Echo",
        pickup = "Bashana Runetotem, Elder Rise, Thunder Bluff",
        turnin = "Muln Earthfury, Skywatcher Plateau, Mulgore",
        steps = {
            { text = "Prereq chain (1): Elder Knowledge", kind = "quest" },
        },
        pins = {
            { mapID = 1456, x = 0.7080, y = 0.3340, label = "Bashana Runetotem — Elder Rise, Thunder Bluff", kind = "start" },
            { mapID = 1412, x = 0.3340, y = 0.2240, label = "Muln Earthfury — Skywatcher Plateau, Mulgore", kind = "turnin" },
            { mapID = 1456, x = 0.7020, y = 0.3360, label = "Bashana Runetotem — Thunder Bluff", kind = "start" },
        },
    },
    [98824] = {
        name = "Prehistoric Prism",
        pickup = "Prospector Whelgar, Whelgar's Excavation Site, Wetlands",
        turnin = "High Explorer Magellas, Hall of Explorers, Ironforge",
        steps = {
            { text = "Prereq chain (1): Lost Relic Carry", kind = "quest" },
        },
        pins = {
            { mapID = 1437, x = 0.3880, y = 0.5220, label = "Prospector Whelgar — Wetlands", kind = "start" },
        },
    },
    [99156] = {
        pickup = "Deathguard Linnea, camp south-east of Brill, Tirisfal Glades",
        turnin = "Deathguard Linnea, camp south-east of Brill, Tirisfal Glades",
        warning = "Group quest: Riptear is a level 13 elite.",
        steps = {
            { text = "Get [Riptear's Heart]: Dropped by Riptear (level 13 elite) in Venomweb Vale, north-east Tirisfal Glades (around 84, 44)", kind = "item", itemID = 286326, itemName = "Riptear's Heart", mapID = 1420, x = 0.8390, y = 0.4400 },
            { text = "Turn in: Deathguard Linnea, camp south-east of Brill, Tirisfal Glades", kind = "turnin" },
        },
        items = {
            { id = 286326, name = "Riptear's Heart", role = "required", source = "Dropped by Riptear (level 13 elite) in Venomweb Vale, north-east Tirisfal Glades (around 84, 44)" },
        },
        pins = {
            { mapID = 1420, x = 0.6550, y = 0.6030, label = "Deathguard Linnea — Tirisfal Glades", kind = "location" },
            { mapID = 1420, x = 0.8390, y = 0.4400, label = "Riptear — Venomweb Vale", kind = "item", detail = "Dropped by Riptear (level 13 elite) in Venomweb Vale, north-east Tirisfal Glades (around 84, 44)" },
        },
    },
    [99187] = {
        name = "The Reliquary of Tyr",
        pickup = "Knight of Mourning, Tirisfal Glades (17.6, 67.4)",
        turnin = "Knight of Mourning, Tirisfal Glades (17.6, 67.4)",
        summary = "Forsaken paladin class quest. The Reliquary of Tyr drops from Elder Shaman Bloodmane.",
        steps = {
            { text = "Prereq chain (1): The Knight of Mourning", kind = "quest" },
            { text = "Get [Reliquary of Tyr]", kind = "item", itemID = 286415, itemName = "Reliquary of Tyr" },
            { text = "Turn in: Knight of Mourning, Tirisfal Glades (17.6, 67.4)", kind = "turnin" },
        },
        items = {
            { id = 286415, name = "Reliquary of Tyr", role = "required" },
        },
        pins = {
            { mapID = 1420, x = 0.1760, y = 0.6740, label = "Knight of Mourning — Tirisfal Glades", kind = "start" },
        },
    },
    [2930001] = {
        pickup = "Caverndeep Pillagers, Caverndeep Invaders, Irradiated Invaders and Addled Lepers, outside the instance",
        turnin = "Keep the card for Matrix Punchograph 3005-A",
        summary = "Random drop; you usually get it during your first clear of the outer area.",
        steps = {
            { text = "Start with [White Punch Card] (Random drop from mobs outside the Gnomeregan instance)", kind = "starter", itemID = 9279, itemName = "White Punch Card", mapID = 1426, x = 0.2430, y = 0.3930 },
        },
        items = {
            { id = 9279, name = "White Punch Card", role = "starter", source = "Random drop from mobs outside the Gnomeregan instance" },
        },
        pins = {
            { mapID = 1426, x = 0.2430, y = 0.3930, label = "Gnomeregan — outer area", kind = "location", detail = "White Punch Cards drop from the mobs here" },
        },
    },
    [2930002] = {
        pickup = "Matrix Punchograph 3005-A, Workshop area of the Train Depot, outside the instance",
        turnin = "You receive a Yellow Punch Card",
        summary = "The only punchographs outside the instance: on the raised platform in the Train Depot and by the Workshop (back door) entrance.",
        steps = {
            { text = "Start with [Yellow Punch Card] (From Matrix Punchograph 3005-A)", kind = "starter", itemID = 9280, itemName = "Yellow Punch Card" },
        },
        items = {
            { id = 9280, name = "Yellow Punch Card", role = "starter", source = "From Matrix Punchograph 3005-A" },
        },
    },
    [2930003] = {
        pickup = "Matrix Punchograph 3005-B, The Dormitory (just past the Clean Zone), inside the instance",
        turnin = "You receive a Blue Punch Card",
        summary = "Inside the instance, in the Dormitory.",
        steps = {
            { text = "Start with [Blue Punch Card] (From Matrix Punchograph 3005-B)", kind = "starter", itemID = 9282, itemName = "Blue Punch Card" },
        },
        items = {
            { id = 9282, name = "Blue Punch Card", role = "starter", source = "From Matrix Punchograph 3005-B" },
        },
    },
    [2930004] = {
        pickup = "Matrix Punchograph 3005-C, upper platform of the Launch Bay with Electrocutioner 6000",
        turnin = "You receive a Red Punch Card",
        summary = "On Electrocutioner 6000's platform.",
        steps = {
            { text = "Start with [Red Punch Card] (From Matrix Punchograph 3005-C)", kind = "starter", itemID = 9281, itemName = "Red Punch Card" },
        },
        items = {
            { id = 9281, name = "Red Punch Card", role = "starter", source = "From Matrix Punchograph 3005-C" },
        },
    },
    [2930005] = {
        pickup = "Matrix Punchograph 3005-D, west side of the lower level of the Engineering Labs",
        turnin = "Master Mechanic Castpipe, Tinker Town, Ironforge",
        summary = "Take the elevator down; the terminal is in the first passage on the right.",
        steps = {
            { text = "Start with [Prismatic Punch Card] (From Matrix Punchograph 3005-D)", kind = "starter", itemID = 9316, itemName = "Prismatic Punch Card" },
        },
        items = {
            { id = 9316, name = "Prismatic Punch Card", role = "starter", source = "From Matrix Punchograph 3005-D" },
        },
    },
}
