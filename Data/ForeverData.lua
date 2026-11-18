--[[
    WorthIt / QuestWorth - Data/ForeverData.lua
    Comprehensive WoW Forever Expansion Quest, Chain & Dungeon Database.
    Generated directly from WoW Forever data archives and live journal caches.
    Includes 140+ multi-step chains, custom dungeon quests, secret item drops, and payoffs.
]]

local addonName, addon = ...
addon.Data = addon.Data or {}
local Data = addon.Data

-- =========================================================================
-- 1. WoW Forever Custom Leveling & Dungeon Zones
-- =========================================================================
local FOREVER_ZONES = {
    ["Hall of Thanes"]            = { min = 13, max = 20, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "Ironforge / Wetlands",
        summary = "WoW Forever custom early dungeon with multi-step dwarf/trogg chains and blue upgrades." },
    ["Ruins of Lordaeron"]        = { min = 15, max = 22, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Tirisfal Glades",
        summary = "WoW Forever custom 15-22 dungeon with Scourge lore quests and rare item drops." },
    ["Excavation Site: Wetlands"] = { min = 26, max = 33, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "Wetlands",
        summary = "WoW Forever custom 26-33 dungeon in Wetlands with excavation lore quests and rare gear." },
    ["City of Dalaran"]           = { min = 28, max = 33, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "Alterac / Hillsbrad",
        summary = "WoW Forever custom 28-33 instance featuring Kirin Tor/Dalaran storylines and strong caster/melee gear." },
    ["The Drowned City"]          = { min = 35, max = 40, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "Sunken Hollow (STV)",
        summary = "WoW Forever custom 35-40 sunken instance with naga/pirate chains and rare upgrades." },
    ["Krol'dok Stronghold"]       = { min = 40, max = 45, faction = "Contested", continent = 1, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Kalimdor",
        summary = "WoW Forever custom 40-45 dungeon stronghold with multi-step chains and item-started quests." },
    ["Alcaz Prison"]              = { min = 48, max = 53, faction = "Contested", continent = 2, isDungeon = true,
        density = "High", hubMod = 0.02, hub = "Dustwallow / Alcaz",
        summary = "WoW Forever custom 48-53 prison instance with high-XP quests and rare armor drops." },
    ["Blackmaw Hold"]             = { min = 55, max = 60, faction = "Contested", continent = 1, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "Kalimdor",
        summary = "WoW Forever custom 55-60 endgame dungeon with Furbolg/Corruption chains and Pre-BiS drops." },
    ["Shaper's Terrace"]          = { min = 58, max = 60, faction = "Contested", continent = 1, isDungeon = true,
        density = "High", hubMod = 0.03, hub = "Kalimdor",
        summary = "WoW Forever custom 58-60 Titan endgame dungeon with top Pre-BiS quest rewards." },
    ["Shen'dralas"]               = { min = 38, max = 45, faction = "Contested", continent = 1,
        density = "High", hubMod = 0.02, hub = "Desolace / Feralas",
        summary = "WoW Forever custom 38-45 Kalimdor zone featuring 39 Highborne & Bone Valley quests and rare gear upgrades." },
    ["Elderwild"]                 = { min = 54, max = 58, faction = "Contested", continent = 1, mapID = 1459,
        isAlias = true, density = "Medium", hubMod = 0.01, hub = "Mount Hyjal",
        summary = "WoW Forever Mount Hyjal sub-hub featuring Level 56-57 quests." },
    ["South Seas"]                = { min = 55, max = 62, faction = "Contested", continent = 1,
        isAlias = true, density = "Low", hub = "Azshara / Tanaris",
        summary = "High-level WoW Forever coastal encounters and bonus quests." },
    ["Stonewrought Dam"]          = { min = 14, max = 35, faction = "Alliance", continent = 2, mapID = 1432,
        isAlias = true, density = "Medium", hub = "Loch Modan",
        summary = "Loch Modan sub-hub featuring Forever's updated level 32 breadcrumb." },
    ["Thoradin's Wall"]           = { min = 14, max = 35, faction = "Contested", continent = 2, mapID = 1417,
        isAlias = true, density = "Medium", hub = "Arathi Highlands",
        summary = "Arathi/Hillsbrad border sub-hub featuring Forever's Cozy Sleeping Bag quest." },
    ["Darkspear Islands"]         = { min = 30, max = 60, faction = "Contested", continent = 1, isCity = true,
        density = "Medium", summary = "WoW Forever PvP Battleground (Levels 30-60) featuring honor quests & care packages." },
}

for zName, zData in pairs(FOREVER_ZONES) do
    Data.Zones[zName] = zData
end

-- =========================================================================
-- 2. WoW Forever Secret / Item Quest Starters
-- =========================================================================
Data.SecretQuestStarters = Data.SecretQuestStarters or {}
local FOREVER_ITEM_STARTERS = {
    [11446] = { questID = 4264, name = "A Crumpled Up Note", drop = "Drops from Dark Iron dwarves in Blackrock Depths once Abandoned Hope is turned in" },
    [267137] = { questID = 94973, name = "Krol'dok Moulding", drop = "Dropped by Tunk, at the forge beside War Handler Ashka in Krol'dok Stronghold; everyone in the group can loot it" },
    [18356] = { questID = 7498, name = "Garona: A Study on Stealth and Treachery", drop = "Drops in Dire Maul; also tradeable" },
    [18357] = { questID = 7499, name = "Codex of Defense", drop = "Drops in Dire Maul; also tradeable" },
    [10441] = { questID = 6981, name = "Glowing Shard", drop = "Dropped by: Mutanus the Devourer" },
    [18359] = { questID = 7501, name = "The Light and How to Swing It", drop = "Drops in Dire Maul; also tradeable" },
    [18360] = { questID = 7502, name = "Harnessing Shadows", drop = "Drops in Dire Maul; also tradeable" },
    [18361] = { questID = 7503, name = "The Greatest Race of Hunters", drop = "Drops in Dire Maul; also tradeable" },
    [18362] = { questID = 7504, name = "Holy Bologna: What the Light Won't Tell You", drop = "Drops in Dire Maul; also tradeable" },
    [18363] = { questID = 7505, name = "Frost Shock and You", drop = "Drops in Dire Maul; also tradeable" },
    [251522] = { questID = 92415, name = "Blood-Stained Letter", drop = "Found in the graveyard inside Ruins of Lordaeron" },
    [16790] = { questID = 6564, name = "Damp Note", drop = "Drops from Blackfathom Tide Priestess in the entrance tunnels leading to Blackfathom Deeps." },
    [9280] = { questID = 2930002, name = "Yellow Punch Card", drop = "From Matrix Punchograph 3005-A" },
    [13250] = { questID = 5262, name = "Head of Balnazzar", drop = "Dropped by Balnazzar (hand in The Archivist first)" },
    [9282] = { questID = 2930003, name = "Blue Punch Card", drop = "From Matrix Punchograph 3005-B" },
    [12780] = { questID = 5089, name = "General Drakkisath's Command", drop = "Dropped by Overlord Wyrmthalak in Lower Blackrock Spire" },
    [9316] = { questID = 2930005, name = "Prismatic Punch Card", drop = "From Matrix Punchograph 3005-D" },
    [2874] = { questID = 373, name = "An Unsent Letter", drop = "Looted from Edwin VanCleef" },
    [10454] = { questID = 3373, name = "Essence of Eranikus", drop = "Dropped by the Shade of Eranikus" },
    [280438] = { questID = 97288, name = "Abominable Head", drop = "Dropped by: The Baron" },
    [249698] = { questID = 92070, name = "Feathered Charm Necklace", drop = "Looted in Blackmaw Hold; specific drop source not yet confirmed" },
    [268579] = { questID = 95204, name = "Crest of Lordaeron", drop = "Reported random spawn inside Ruins of Lordaeron; check towers, side rooms and the Bjork area" },
    [17008] = { questID = 6522, name = "Small Scroll", drop = "Drops from Charlga Razorflank in Razorfen Kraul" },
    [9326] = { questID = 2945, name = "Grime-Encrusted Ring", drop = "Dropped by Dark Iron dwarves in Gnomeregan" },
    [9281] = { questID = 2930004, name = "Red Punch Card", drop = "From Matrix Punchograph 3005-C" },
    [16782] = { questID = 6922, name = "Strange Water Globe", drop = "Drops from Baron Aquanis inside Blackfathom Deeps." },
    [270866] = { questID = 95810, name = "Titan Relic", drop = "Dropped by: Relic Guardian" },
    [18364] = { questID = 7506, name = "The Emerald Dream", drop = "Drops in Dire Maul; also tradeable" },
    [268535] = { questID = 95195, name = "Bloodied Insignia", drop = "Dropped by: undead enemies inside Ruins of Lordaeron" },
    [7666] = { questID = 2198, name = "Shattered Necklace", drop = "Drops from the dwarves and troggs in Uldaman" },
    [18987] = { questID = 7761, name = "Blackhand's Command", drop = "Dropped by the Scarshield Quartermaster in the hallway outside the Spire portal" },
    [9279] = { questID = 2930001, name = "White Punch Card", drop = "Random drop from mobs outside the Gnomeregan instance" },
    [254553] = { questID = 92753, name = "Extra-Destructive Explosives", drop = "Supplied by Sprite Jumpsprocket during Explosive Consultation; plant it at the Deadmines forge" },
    [18358] = { questID = 7500, name = "The Arcanist's Cookbook", drop = "Drops in Dire Maul; also tradeable" },
    [267138] = { questID = 94980, name = "Krol'dok Moulding", drop = "Dropped by Tunk, at the forge beside War Handler Ashka in Krol'dok Stronghold; everyone in the group can loot it" },
}
Data.ItemQuestMap = Data.ItemQuestMap or {}
for itID, itData in pairs(FOREVER_ITEM_STARTERS) do
    Data.SecretQuestStarters[itID] = itData
    if itData.questID and itData.questID > 0 then
        Data.ItemQuestMap[itID] = itData.questID
    end
end

-- =========================================================================
-- 3. WoW Forever Quest Tips & Objective Guidance
-- =========================================================================
Data.QuestTips = Data.QuestTips or {}
local FOREVER_QUEST_TIPS = {
    [5525] = "Get a Gordok Shackle Key from the North ogres and free Knot; his cache has loot.",
    [5529] = "Kill 20 Plagued Hatchlings. After turning this in, hatchlings can drop Healthy Dragon Scales, which start a repeatable turn-in to Betina.",
    [7064] = "Kill Princess Theradras in the inner cavern.",
    [7066] = "Zaetar's Spirit appears after Princess Theradras dies.",
    [79361] = "Twisted Totems only drop while this quest is in your log. Water: Mirefin murlocs, northeast coast of Dustwallow Marsh. Air: Maraudine centaurs, Desolace. Earth: Lost Ones, Swamp of Sorrows. Fire: Dustbelcher ogres and Stonevault troggs, Badlands.",
    [7070] = "Shadowshard elementals in the outer purple-crystal caves. It can be done without entering the instance.",
    [95809] = "Follow-up of Lost in the Thicket Things.",
    [6565] = "Follows the Damp Note version of Allegiance to the Old Gods.",
    [6569] = "Part of the Horde Onyxia chain. Black Dragonspawn Eyes drop from the dragonspawn in UBRS.",
    [92456] = "City of Dalaran (Alliance): Picked up from Shylamiir in Stormwind City. Retrieve a Fel Infused Blossom from Dalaran's central garden.",
    [4063] = "Kill Golem Lord Argelmach for his head and collect 10 Intact Elemental Cores from the constructs guarding him.",
    [95682] = "Related lead-in: Dragonmaw Rumors. The Dragonmaw Dispatch is recovered from the Dragonmaw forces inside the dungeon.",
    [96800] = "New in Forever. The book is held by Arcanist Doan.",
    [92744] = "Second quest of the Toxic Soil chain.",
    [1782] = "Final step. Rewards Fire Hardened Hauberk.",
    [7629] = "Warlock dreadsteed quest. Release the Imp in a Jar at the alchemy lab in Ras Frostwhisper's room and wait for the parchment.",
    [7631] = "Warlock dreadsteed quest. After Immol'thar dies, run the ritual in his prison with J'eevee's Jar, the Black Lodestone and the Xorothian Glyphs. Bring Soul Shards.",
    [2040] = "Follows Speak with Shoni.",
    [2041] = "This leads directly into Underground Assault.",
    [95140] = "Final step. Old Fire-Eye is at the Greymane Wall in southern Silverpine Forest. Rewards Wolfsbane.",
    [7643] = "Paladin charger quest. Kill Tendris Warpwood, then feed the Ancient Equine Spirit and give it the Arcanite Barding. Bring the Manna-Enriched Horse Feed from Merideth Carlson in Southshore.",
    [7647] = "Paladin charger quest. Clear Rattlegore's basement in the Great Ossuary, use the Divination Scryer and defeat the spirits and Death Knight Darkreaver.",
    [92745] = "Investigate whether Westfall's mines are causing the contamination.",
    [5102] = "Kill General Drakkisath at the end of UBRS.",
    [94981] = "Keep any Krol'dok Moulding you loot: it starts the quest before this one.",
    [2930002] = "The only punchographs outside the instance: on the raised platform in the Train Depot and by the Workshop (back door) entrance.",
    [2930004] = "On Electrocutioner 6000's platform.",
    [5122] = "Malor's Strongbox in the Scarlet Bastion holds the medallion. Give it to Aurius in the chapel before fighting the Baron.",
    [65] = "First step of the required Defias Brotherhood chain.",
    [2930001] = "Random drop; you usually get it during your first clear of the outer area.",
    [2930003] = "Inside the instance, in the Dormitory.",
    [2930005] = "Take the elevator down; the terminal is in the first passage on the right.",
    [8232] = "Hunter class quest. The Tooth of Morphaz drops from Morphaz in Sunken Temple (follows The Hunter's Charm).",
    [4126] = "Break the three kegs in the Grim Guzzler storeroom to spawn Hurley Blackbreath and his guards.",
    [4128] = "Introductory step leading to Hurley Blackbreath.",
    [4132] = "Needs both KILL ON SIGHT quests and the Grark Lorkrub escort first.",
    [4134] = "Break the three kegs in the Grim Guzzler storeroom to spawn Hurley Blackbreath and his guards.",
    [4136] = "Kill Ribbly Screwspigot in Blackrock Depths' Grim Guzzler tavern (after speaking with Yuka Screwspigot at Flame Crest).",
    [5160] = "Awbee is the wounded blue dragon near the arena route after Rend. Use the rune deep in the Mazthoril cave to reach Haleh.",
    [1806] = "Final step. Rewards Verigan's Fist.",
    [4146] = "Atal'ai Haze drops from the temple's worms, lurkers and oozes.",
    [389] = "Second required step leading to The Stockade Riots.",
    [79366] = "Elite, level 40: bring a group. At the steam pools in Thousand Needles, stand on the rune circle and use the Corrupted Totems to defeat the Ravaging Tempest for Eye of the Tempest.",
    [92748] = "Begins the explosives portion of the Toxic Soil chain.",
    [1048] = "Herod is in the Armory; Loksey in the Library; Mograine and Whitemane in the Cathedral.",
    [391] = "Part of the chain that begins with The Unsent Letter from Edwin VanCleef in The Deadmines.",
    [7761] = "The Scarshield Quartermaster is in the hallway outside the Spire portal. Touch Drakkisath's Brand behind General Drakkisath; this unlocks the Orb of Command shortcut to Blackwing Lair.",
    [4701] = "Kill Halycon, the worg den mother. Be ready for Gizrul the Slavener, who comes for you right after.",
    [5214] = "Newer Classic records call him Ezra Grimm. Clear the smoke shop, touch the tobacco box and kill the shopkeeper.",
    [5727] = "Neeru is in the Cleft of Shadow near the Ragefire Chasm entrance.",
    [1053] = "Herod is in the Armory; Loksey in the Library; Mograine and Whitemane in the Cathedral.",
    [92749] = "Rough Dynamite can be crafted, traded or bought from the auction house.",
    [1824] = "Your warrior trainer (Sorek in Orgrimmar) sends you to Ruga first. Timed: 30 minutes. The antennae come from the silithids at the Field of Giants, south of Camp Taurajo.",
    [4729] = "Use the supplied cage on a Bloodaxe Worg Pup in the worg area.",
    [96135] = "Elite, level 40: bring a group. At the steam pools in Thousand Needles, stand on the rune circle and use the Corrupted Totems. Waves of elementals come, then an elite quilboar and the Ravaging Tempest, which drops the Eye of the Tempest for every Shaman on the quest.",
    [914] = "Requires the Barrens oasis quest chain. Complete The Barrens Oases, The Forgotten Pools, The Stagnant Oasis and Altered Beings, then Hamuul Runetotem and Nara Wildmane before Leaders of the Fang becomes available.",
    [4735] = "Using the module on the eggs in the Rookery can hatch whelps.",
    [5250] = "Introductory step leading to Fragments of the Past.",
    [92750] = "You need a remote detonator for the planned explosion.",
    [96391] = "The Dark Iron Map starts this quest and leads directly into Old Ironforge Incursion.",
    [5262] = "Hand in The Archivist first, or Balnazzar's head will not start this quest.",
    [166] = "Final dungeon step of the Defias Brotherhood chain; complete the earlier steps first.",
    [4769] = "Introductory step leading to The Darkstone Tablet.",
    [5282] = "Free the Restless Souls of Stratholme (Egan's Blaster used on ghostly citizens before killing them; starts outside Undead gate).",
    [92751] = "Returns the remote detonator to the engineer.",
    [82084] = "Mage class quest.",
    [1838] = "The Razorfen Kraul step.",
    [92432] = "Introductory quest leading to Heart of Disruption and Starving Arcane.",
    [135] = "Shaw investigates the connection between the Defias and the Stonemasons.",
    [167] = "The foreman is in the tunnels before the instance portal.",
    [9063] = "Introductory step leading to A Better Ingredient.",
    [4286] = "Dark Iron Fanny Packs drop from Dark Iron dwarves in BRD.",
    [96776] = "Beyond Earth Song Falls, find the chamber of brilliant white crystals guarded by giants. Retrieve An'she's Radiance from the crystal near the highest part of the chamber. Rewards 300 Earthen Ring and 200 Thunder Bluff reputation.",
    [92752] = "Final preparation before Destruction in Deadmines.",
    [96393] = "The chain begins by dropping Dark Iron Map from Dark Iron Spies in Dun Morogh.",
    [1848] = "Final step. Rewards Brutal Hauberk.",
    [168] = "The undead side tunnel is before the instance portal.",
    [4322] = "Escort Marshal Windsor through the prison. Clear the patrols first and have everyone ready before you start.",
    [4324] = "Introductory step leading to Ribbly Screwspigot.",
    [95787] = "Lead-in: An Acquaintance in Southshore (Savage Coast Report Bundle to Loremaster Dibbs). Use the hide and charcoal on the four Tablets of I'lalai inside The Drowned City.",
    [92753] = "Plant the explosives beside the forge, then meet Alba Fairmoon at the Deadmines exit.",
    [545] = "Available after completing Prison Break In.",
    [4867] = "Bring Highlord Omokk's Head and a Roughshod Pike to Urok's Tribute Pile beyond the spiders to start the waves.",
    [5384] = "Use the Blood of Innocents at the brazier on the Scholomance porch. Rewards the Spectral Essence.",
    [6921] = "The Fathom Stone is also associated with the optional Baron Aquanis encounter.",
    [275] = "Final required step before Horrors in the Highland.",
    [8233] = "Introductory step leading to The Azure Key.",
    [276] = "Second required step before Horrors in the Highland.",
    [8253] = "Mage class quest. The Arcane Shard drops from Morphaz in Sunken Temple.",
    [4903] = "Talk to Goretooth to receive his Command item and click it to start the quest. The Important Blackrock Documents spawn near the three generals.",
    [2201] = "The sapphire drops from Grimlok.",
    [2204] = "The power source drops from Archaedas. Finishing it unlocks Talvash's Enhancing Necklace.",
    [7482] = "Interact with the Skeletal Remains of Telmius Dreamseeker beside Lorekeeper Lydros in the Athenaeum. Unlocks Lydros's libram exchanges.",
    [7484] = "Repeatable. Needs your faction's Elven Legends turned in first.",
    [1109] = "Required before Hearts of Zeal.",
    [7488] = "Lethtendris's Web drops from Lethtendris in Dire Maul: East.",
    [7492] = "Introductory step leading to Lethtendris's Web.",
    [5961] = "Introductory step leading to Ramstein.",
    [7498] = "Rogue class book. Click the book to start the quest.",
    [7500] = "Mage class book. Click the book to start the quest.",
    [7502] = "Warlock class book. Click the book to start the quest.",
    [7504] = "Priest class book. Click the book to start the quest.",
    [7506] = "Druid class book. Click the book to start the quest.",
    [5466] = "Use the Soulbound Keepsake on Ras Frostwhisper to make him human, then kill him and bring back his human head.",
    [95663] = "Required before Open the Maw.",
    [3765] = "Optional Alliance breadcrumb leading to Researching the Corruption.",
    [6502] = "Part of the Onyxia attunement.",
    [8413] = "Shaman class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.",
    [8417] = "Introductory step leading to Voodoo Feathers.",
    [7029] = "Fill the Coated Cerulean Vial at the orange crystal pool in the outer caves, then use it on Vylestem Vines inside (orange side) and kill the Noxxious Scions to heal 8 plants.",
    [8425] = "Warrior class quest for both factions. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.",
    [8948] = "Part of Anthion Harmon's Dungeon Set 2 quests: the earlier ones unlock this step.",
    [7041] = "Fill the Coated Cerulean Vial at the orange crystal pool in the outer caves, then use it on Vylestem Vines inside (orange side) and kill the Noxxious Scions to heal 8 plants.",
    [5001] = "Bijou hides in a recess beyond the early bridges. Her belongings spawn in one of several places around the troll and orc rooms.",
    [5518] = "Bring 4 Bolts of Runecloth, 8 Rugged Leather, 2 Rune Threads and 1 Ogre Tannin (basket on the upper level beyond Knot). Make any suits and learn the pattern before freeing Knot, because he leaves.",
    [96016] = "Final step. Choose Rage of the Storm, Lightning's Grasp or Tidebringer's Claw; Alliance Shamans also get Elementalist's Guard.",
    [5526] = "Kill Alzzin the Wildshaper, pick up a Felvine Shard near the vine and seal it in the Reliquary of Purity.",
    [2768] = "The rod drops from Sergeant Bly after the pyramid event.",
    [2769] = "Introductory step leading to Gahz'rilla.",
    [97198] = "Horde Blackmaw Hold: Picked up from Muln Earthfury in Mulgore (33.4, 22.5). Obtain a Blackmaw Ritual Totem from Elder Shaman Bloodmane inside Blackmaw Hold.",
    [95697] = "Thicket Raptor Meat comes from the Thicket raptors (Thicket Lurker, Thicket Hunter, Thicket Matriarch) in Stalker's Thicket, the area of Shadetooth.",
    [6562] = "Introductory step leading to The Essence of Aku'Mai.",
    [3802] = "Speak to Franclorn's ghost while dead. Kill Fineous Darkvire for Ironfel and place it on Franclorn's monument by the Ring of Law. The Shadowforge Key opens shortcuts inside BRD.",
    [5047] = "He appears from The Beast's corpse after the fight. Malyfous then offers the Pristine Hide of the Beast exchanges.",
    [7604] = "Blacksmithing. Bring a Sulfuron Ingot (Golemagg, Molten Core) to Lokhtos in the Grim Guzzler to get the contract, then hand it back for the Sulfuron Hammer plans.",
    [2278] = "The discs are in the Map Chamber, past Ironaya.",
    [2279] = "Speak with the Stone Watcher and activate the discs first. Then hand the reward voucher to Dinita Stonemantle in the Ironforge vault and choose your reward.",
    [2280] = "Speak with the Stone Watcher and activate the discs first. Then hand the reward voucher to Bena Winterhoof in Thunder Bluff and choose your reward.",
    [6602] = "Part of the Onyxia attunement.",
    [8151] = "Introductory step leading to The Green Drake.",
    [5089] = "Leads to General Drakkisath's Demise in Upper Blackrock Spire.",
    [6626] = "These mobs are outside the instance, around the entrance.",
    [704] = "The four Urns of Agmond are in the outer Uldaman trogg cave before the instance portal (after Ironband Wants You!).",
    [7668] = "Shaman quest. Clear Rattlegore's basement, use the scryer and defeat Death Knight Darkreaver; return his head.",
    [6141] = "Introductory step leading to In the Name of the Light.",
    [707] = "Introductory step leading to Agmond's Fate.",
    [5125] = "Give Aurius the Medallion of Faith before the Baron fight; speak to him after Baron Rivendare dies.",
    [5127] = "Blacksmithing 270 (Armorsmith). Use the Blood Stained Pike on Goraluk's corpse and loot the Unforged Rune Covered Breastplate nearby.",
    [1160] = "The book is inside Scarlet Monastery: Library.",
    [6163] = "Defeat Ramstein the Gorger outside the Slaughter House before entering Baron Rivendare's room in Stratholme Undead.",
    [4123] = "The Heart of the Mountain is in the vault safe after the Dark Keepers.",
    [356] = "Both are at the Balnir Farmstead, east of Linnea's camp.",
    [4133] = "Introductory step leading to Lost Thunderbrew Recipe.",
    [8254] = "Introductory step leading to Blood of Morphaz.",
    [2841] = "Rig Wars must be in progress to unlock the transporter chain in Forever.",
    [4143] = "Atal'ai Haze drops from the temple's worms, lurkers and oozes.",
    [2846] = "The Tiara of the Deep drops from Hydromancer Velratha in Zul'Farrak (follows Tabetha's Task).",
    [2339] = "The sapphire drops from Grimlok and the power source from Archaedas.",
    [95798] = "The Kirin Tor only let noteworthy visitors into Dalaran.",
    [2861] = "Introductory step leading to Tiara of the Deep.",
    [2864] = "Introductory step leading to Scarab Shells.",
    [2865] = "Collect Uncracked Scarab Shells from Scarabs around Zul'Farrak (wait until graves open or kill dungeon scarabs; follows Tran'rek).",
    [5726] = "First required Hidden Enemies step for the Ragefire Chasm chain.",
    [5728] = "Slay Bazzalan and Jergosh the Invoker inside Ragefire Chasm (unlocks In Ruin / Thrall's reward step).",
    [4201] = "Gromsblood, Giant Silver Veins (Azshara cliff giants) and the vial filled at Golakka Hot Springs in Un'Goro. Opens a peaceful way through the bar on later visits.",
    [93404] = "The quest tracks two objectives: 1 Vial of Earth Song Water and Woodwyrd extinguished. Complete Word of the Woods to encounter Woodwyrd at the Forlorn Gardens. Recover the vial inside Maraudon, then return to Woodwyrd.",
    [1951] = "Mage class quest.",
    [4724] = "Kill Halycon, the worg den mother. Be ready for Gizrul the Slavener, who comes for you right after.",
    [8418] = "Paladin class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.",
    [8422] = "Warlock class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.",
    [5243] = "Collect 5 Stratholme Holy Water from the supply crates in the streets; some crates spawn enemies.",
    [8945] = "Timed: rescue Ysida Harmon by killing Baron Rivendare within 45 minutes. Use the Extra-Dimensional Ghost Revealer to see Anthion.",
    [5251] = "Kill Archivist Galford in the Scarlet Bastion and burn the archives.",
    [1445] = "Collect 20 Fetishes of Hakkar from Atal'ai trolls; outer-temple trolls also drop them.",
    [1701] = "The Razorfen Kraul step.",
    [1446] = "Kill the six troll guardians on the balconies to drop Jammal'an's barrier, then bring back his head.",
    [1702] = "Furen rewards you with a shield, Furen's Favor.",
    [5263] = "Then Lord Maxwell Tyrosus and The Argent Hold, in Light's Hope Chapel, give the weapon or shield reward.",
    [92415] = "Item-start quest from the Blood-Stained Letter.",
    [95034] = "The questline starts at level 18 with Diplomatic Incident from Danitha Morr at Bandarion Keep, Tirisfal Glades. It takes you to Fenris Isle, where you free Lumina Windsinger from Fenris Keep.",
    [4764] = "Doomrigger's Coffer is in the Rookery (UBRS). Then take Delivery to Ridgewell to Count Remington Ridgewell in Stormwind Keep.",
    [4766] = "Introductory step leading to Doomrigger's Clasp.",
    [4768] = "The Darkstone Tablet lies on the ground in the Rookery inside Upper Blackrock Spire.",
    [5281] = "Introductory step leading to The Restless Souls.",
    [4263] = "Kill Lord Incendius at the Black Anvil inside BRD.",
    [1198] = "Optional lead-in to the Alliance version of Blackfathom Villainy: hand it in before accepting Blackfathom Villainy, or it can no longer be completed.",
    [92742] = "First quest of the Toxic Soil chain.",
    [78307] = "Offered after C's next letter reaches you in a capital city.",
    [7848] = "The Core Fragment is on the rock beside the Molten Core portal deep inside BRD. Unlocks Lothos's teleport to Molten Core.",
    [95647] = "Required before Heartwoven.",
    [877] = "The next required oasis investigation after The Forgotten Pools.",
    [4788] = "The fifth and sixth Mosh'aru tablets are in the Smolderthorn troll area. Continues with Confront Yeh'kinya and The Hand of Rastakhan.",
    [9053] = "Druid class quest. The Putrid Vine drops from Atal'alarion in the Sunken Temple basement.",
    [1100] = "Required before The Crone of the Kraul.",
    [97173] = "Alliance Blackmaw Hold: Picked up from Archmage Timear in Dalaran (15.4, 74.0). Obtain a Blackmaw Ritual Totem from Elder Shaman Bloodmane inside Blackmaw Hold.",
    [7499] = "Warrior class book. Click the book to start the quest.",
    [2991] = "The medallion drops from Nekrum Gutchewer.",
    [7494] = "Introductory step leading to Lethtendris's Web.",
    [96264] = "The Razorfen Kraul step. Call of Air (from Eldrun Stormbreaker in Ironforge) sends you to Veyric. Alliance Shamans can share this quest.",
    [95770] = "The cave is in Sunken Hollow, underwater around 21, 28: the entrance to the Drowned City.",
    [4295] = "Buy Dark Iron Ale Mugs from Plugger Spazzring and keep handing them to Rocknot. The drunken event opens the bar route and can turn Phalanx hostile.",
    [2949] = "Horde step required before Nogg's Ring Redo.",
    [5247] = "Fill her vial at the dire pool along Eldreth Row in Dire Maul West; also bring 1 Enchanted Thorium Bar and 5 Crystal Restore.",
    [141] = "Returns Shaw's findings about Edwin VanCleef to Gryan.",
    [92747] = "The supplies are found in the caves leading toward the Deadmines entrance.",
    [96984] = "Horde Dalaran attunement. Stone Tokens and Bracers of Binding can be done alongside the chain, but they are optional and are not required for attunement.",
    [303] = "Complete The Dark Iron War to unlock The Fury Runs Deep.",
    [277] = "Third required step before Horrors in the Highland.",
    [2926] = "Required before The Only Cure is More Green Glow.",
    [1699] = "Your warrior trainer (Wu Shen in Stormwind, or the trainers in Ironforge and Darnassus) sends you to Yorus Barleybrew in Lakeshire first. The run is timed.",
    [5848] = "Take the painting hidden behind the twin-moons picture in Archivist Galford's room before you burn the archives.",
    [2418] = "The power stones drop from Shadowforge dwarves in the outer cave.",
    [5341] = "The four deeds: Southshore in the first large chamber, Tarren Mill before the hatchlings, Brill by Ras Frostwhisper, Caer Darrow by Lord Alexei Barov. The follow-up The Last Barov sends you to kill the rival brother.",
    [5343] = "The four deeds: Southshore in the first large chamber, Tarren Mill before the hatchlings, Brill by Ras Frostwhisper, Caer Darrow by Lord Alexei Barov. The follow-up The Last Barov sends you to kill the rival brother.",
    [92457] = "City of Dalaran: Defeat 8 Seeking Remnants, 8 Saturated Remnants, and 8 Mana Echoes inside Dalaran (may require clearing extra pulls or two runs).",
    [79358] = "Twisted Totems only drop while this quest is in your log. Water: Mirefin murlocs, northeast coast of Dustwallow Marsh. Air: Maraudine centaurs, Desolace. Earth: Lost Ones, Swamp of Sorrows. Fire: Dustbelcher ogres and Stonevault troggs, Badlands.",
    [79442] = "Final step. Choose Rage of the Storm, Lightning's Grasp or Tidebringer's Claw.",
    [3446] = "Examine the Altar of Hakkar in the temple basement. Started from Marvon Rivetseeker after The Stone Circle.",
    [3447] = "Light the statues around the circle in the right order to summon Atal'alarion.",
    [2842] = "Required before Gnomer-gooooone!",
    [484] = "Required before Highland Hides. Daily Delivery is not required in Forever.",
    [214] = "Requires the Defias Brotherhood escort step.",
    [142] = "The messenger travels the roads between Moonbrook, Gold Coast Quarry and Jangolode Mine.",
    [865] = "Required before Smart Drinks becomes available.",
    [96771] = "Zalfan Moonshadow, a highborne among the Twilight's Hammer inside the stronghold: groups meet him after Tunk, on the way to the bridge.",
    [153] = "Required before Red Silk Bandanas.",
    [1113] = "Monastery-wide collection: any Scarlet humanoid on the way to the Armory can drop Hearts of Zeal.",
    [132] = "Second step of the Defias Brotherhood chain.",
    [4862] = "Spire Spider Eggs are in the spider tunnels.",
    [2947] = "Alliance step required before Gnome Improvement.",
    [4866] = "Get poisoned by Mother Smolderweb and reach Ragged John while still poisoned. Don't let anyone cleanse it.",
    [95772] = "Find Daewyn inside the dungeon. Fallen in the Fen sends you back to Dorin Songblade in Lakeshire.",
    [7703] = "Talk to a friendly Captain Kromcrush after you become the Gordok king. The Gauntlet of Gordok Might is in a chest near Prince Tortheldrin in Dire Maul West.",
    [8236] = "Rogue class quest. The Azure Key drops from Morphaz in Sunken Temple.",
    [98423] = "The tablet is inside one of the vaults in the Reliquary of Kings, in Durgen Dirgehammer's final boss room. Open the vaults and interact with the tablet before leaving the dungeon.",
    [3527] = "The tablets drop from Theka the Martyr and Hydromancer Velratha.",
    [78699] = "Offered after C's next letter reaches you in a capital city.",
    [96986] = "City of Dalaran (Horde): Picked up from Melisara in Tarren Mill. Defeat Atrexis the Grave Knight in the Dalaran Underbelly.",
    [94974] = "Keep any Krol'dok Moulding you loot: it starts the quest before this one.",
    [8250] = "Introductory step leading to Destroy Morphaz.",
    [7441] = "Chase and talk to Pusillin through the wing until he fights, then kill him for the book. He also drops the Crescent Key.",
    [5212] = "Any undead in Stratholme can drop Plagued Flesh Samples.",
    [3982] = "Open his cell with the Prison Cell Key from High Interrogator Gerstahn, then defend him.",
    [870] = "Investigate the fissure beneath the Forgotten Pools.",
    [92489] = "City of Dalaran (Alliance): Picked up from High Sorcerer Andromath in Stormwind. Slay Arcanic Enigma, the Mana Elemental in Dalaran.",
    [971] = "The Lorgalis Manuscript is inside a Pitted Iron Chest underwater in the Pool of Ask'ar, in the northern alcove just past Ghamoo-ra's turtle room.",
    [1275] = "Researching the Corruption in Blackfathom Deeps: Collect 8 Corrupted Brain Stems from Blackfathom Tide Priestesses and nagas.",
    [1740] = "Warlock class quest. The fragments come from Shadowfang Keep and Blackfathom Deeps.",
    [7201] = "Essence of the Elements drops from BRD elementals and golems.",
    [1956] = "Mage class quest. The Obsidian Sentinel guards the back entrance of Uldaman. Continues with Mana Surges for the Celestial Orb or Celestial Stave.",
    [7461] = "Kill the guardians of all five pylons, then Immol'thar, then Prince Tortheldrin. Return to the Ancient, take The Treasure of the Shen'dralar and open the chest under the library stairs for the reward.",
    [7463] = "Mage class quest. Lydros is in the Athenaeum (North/West); Hydrospawn Essence drops from Hydrospawn in East. Rewards Conjure Water (Rank 7).",
    [6981] = "Dropped by Mutanus the Devourer in Wailing Caverns. Return to Thunder Bluff / Ratchet -> unlocks follow-up 'In Nightmares' for Talbar Mantle (Rare Shoulders)!",
    [96987] = "City of Dalaran (Horde): Inside the dungeon near the sewer entrance (Rexxie Copperclutch). Recover The Founding of Dalaran.",
    [373] = "First required step leading to The Stockade Riots.",
    [2398] = "Introductory step leading to The Hidden Chamber.",
    [1489] = "Tonga sends you to Hamuul after Altered Beings.",
    [155] = "Final prerequisite before the dungeon step of The Defias Brotherhood.",
    [1490] = "Nara Wildmane is the final prerequisite before Leaders of the Fang becomes available.",
    [92069] = "Withermaw and Bonesnout are on different paths: take both.",
    [7481] = "Interact with the Skeletal Remains of Telmius Dreamseeker beside Lorekeeper Lydros in the Athenaeum. Unlocks Lydros's libram exchanges.",
    [7483] = "Repeatable. Needs your faction's Elven Legends turned in first.",
    [7485] = "Repeatable. Needs your faction's Elven Legends turned in first.",
    [4003] = "Keep Princess Moira alive and speak to her after Emperor Thaurissan dies. Her The Princess Saved? sends you back to Thrall for the reward.",
    [7489] = "Lethtendris's Web drops from Lethtendris in Dire Maul: East.",
    [4362] = "Keep Princess Moira alive and speak to her after Emperor Thaurissan dies. Her The Princess's Surprise sends you back to Magni for the reward.",
    [2770] = "Gahz'rilla in Zul'Farrak: Bring Mallet of Zul'Farrak to strike the gong at the Sacred Pool and summon Gahz'rilla for her Electrified Scale (rewards Carrot on a Stick!).",
    [2240] = "The Hidden Chamber in Uldaman: Enter the Map Chamber past Ironaya and examine the Discs of Norgannon / Ironaya's Treasure Chest (follows The Lost Dwarves).",
    [4982] = "Then take Bijou's Reconnaissance Report to Lexlort in Kargath for the reward.",
    [96988] = "City of Dalaran (Horde): Picked up from Doctor Martin Felben in Undercity. Collect 6 Cracked Sentry Cores from Arcane constructs in Dalaran.",
    [7501] = "Paladin class book. Click the book to start the quest.",
    [7503] = "Hunter class book. Click the book to start the quest.",
    [7505] = "Shaman class book. Click the book to start the quest.",
    [7507] = "Warriors and Paladins. Lydros then gives The Forging of Quel'Serrar, which is finished in Onyxia's Lair.",
    [5463] = "After Baron Rivendare dies, use the glowing rune on the floor of his room, then take the follow-up back to Leonid.",
    [92070] = "Item-start quest from Feathered Charm Necklace in Blackmaw Hold (handmade furbolg keepsake).",
    [3907] = "Kill Lord Incendius at the Black Anvil inside BRD and bring back the Tablet of Kurniya.",
    [8257] = "Priest class quest. Morphaz's blood is turned in to Greta Mosshoof in Felwood, not Ogtinc.",
    [97288] = "The item choice is awarded on the follow-up Unending Torment step in Undercity.",
    [4743] = "Take the Unforged Seal and the Orb of Draconic Energy to Emberstrife in the Wyrmbog, Dustwallow Marsh. The forged seal opens the UBRS door.",
    [3528] = "Fill the Egg of Hakkar from the Hakkari Bloodkeepers to summon the Avatar of Hakkar.",
    [1014] = "The current Forever quest data also lists Arcane Intellect as a learned reward.",
    [2936] = "The Tablet of Theka is in Theka the Martyr's room.",
    [880] = "Completing Altered Beings unlocks Hamuul Runetotem.",
    [4024] = "Show Cyrus a Black Dragonflight Molt first (A Taste of Flame, or kill the drake he summons). Then kill Bael'Gar and use the Altered Black Dragonflight Molt on his remains to collect the Encased Fiery Essence.",
    [7065] = "Kill Princess Theradras in the inner cavern.",
    [4771] = "Use Dawn's Gambit in the Viewing Room and defeat Vectus.",
    [7067] = "Loot the Amulet of Spirits from the Nameless Prophet in the outer caves, then use it to fight the five Khans: three in the outer caves, one on the purple route and one on the orange route. Combine their gems with the amulet.",
    [8415] = "Introductory step leading to Forging the Mightstone.",
    [7028] = "Any Maraudon creature can drop the Theradric Crystal Carvings.",
    [7068] = "Shadowshard elementals in the outer purple-crystal caves. It can be done without entering the instance.",
    [6521] = "Final step. Ambassador Malcin is outside Razorfen Downs.",
    [6563] = "The Essence of Aku'Mai in Blackfathom Deeps: Collect 20 Sapphires of Aku'Mai along the subterranean caverns (optional followup after Trouble in the Deeps).",
    [79360] = "The Razorfen Kraul step. After Call of Air, Prate Cloudseer sends you to Rau Cliffrunner. It can't be shared on the Horde side.",
    [378] = "Requires The Dark Iron War before this quest becomes available.",
    [95776] = "Commander Aggro'gosh offers it once Enemies in the Water and Locating the Lost City (Kin'weelay) are both handed in.",
    [3525] = "Waves of undead attack during the ritual. Talk to the brazier near the idol afterwards to finish.",
    [7044] = "The Celebrian Rod drops from Noxxion and the Celebrian Diamond from Lord Vyletongue.",
    [7046] = "Defeat Celebras the Cursed where the paths meet and turn in Legends of Maraudon to Celebras the Redeemed, then help with his ritual and speak to him again for the scepter.",
    [5515] = "The bag drops from Jandice Barov.",
    [463] = "First required step before Horrors in the Highland.",
    [95204] = "Community reports indicate the Crest can spawn at one of several locations inside the dungeon. Reported spots include upper floors of towers, side/crypt rooms near The Baron, and the area around Bjork.",
    [95189] = "Community reports indicate the Crest can spawn at one of several locations inside the dungeon. Reported spots include upper floors of towers, side/crypt rooms near The Baron, and the area around Bjork.",
    [4083] = "Mining 230. Talk to Gloom'rel before the Seven fight; give the Spectral Chalice 2 Star Rubies, 20 Gold Bars and 10 Truesilver Bars to learn Smelt Dark Iron.",
    [1475] = "Collect 10 Atal'ai Tablets around the temple; tablets in the outer temple also count.",

    -- Riverglades (Custom 35-45 Zone) & Krol'dok Stronghold Prequests
    [93443] = "Powderfuse Port (Talk-To): Deliver the Lost Shipping Crate to Friz Frazzlespark at Powderfuse Port in Riverglades.",
    [94483] = "Horde Riverglades: Slay 8 Farholde Priests and 12 Farholde Scouts south of the river.",
    [94613] = "A Grim Discovery (Talk-To): Go to Wheeler's Grange in Riverglades to inquire about the missing horses.",
    [94614] = "Kill 8 Mudfin Oracles and 8 Mudfin Warriors along the river near Wheeler's Grange in Riverglades.",
    [94672] = "Horde Krol'dok Prequest: Defeat 8 Twilight Raiders, 8 Twilight Shadowmancers, and 8 Twilight Neophytes in Sunnyglade for Tran'gul in Rog'mar (59.4, 44.0).",
    [94744] = "Horde Krol'dok Prequest: Find Da'grosh in the hills west of Rog'mar in Riverglades.",
    [94745] = "Defeat 8 Twilight Fanatics, 8 Twilight Corrupters, and 8 Twilight Champions in Twilight's Shroud for Da'grosh (33.4, 38.0).",
    [94748] = "Rescue 5 Rog'mar Scouts within the Twilight's Shroud for Da'grosh (33.4, 38.0).",
    [94768] = "Defeat Overlord Kilgar within the Twilight's Shroud and bring his head to Da'grosh (33.4, 38.0). Continues to Krol'dok Stronghold!",
    [94877] = "Alliance Krol'dok Prequest: Defeat 8 Twilight Raiders, 8 Twilight Shadowmancers, and 8 Twilight Neophytes in Sunnyglade for Demar Brant in Farholde Keep (66.6, 81.0).",
    [94879] = "Collect 5 Twilight Pages inside Sunnyglade for Ashe Amberhall in Farholde Keep. Part of the Krol'dok Stronghold prequest chain.",
    [94881] = "Retrieve 25 Twilight Charms from Twilight Shadowmancers and Neophytes in Sunnyglade for Ashe Amberhall in Farholde Keep.",
    [94886] = "Find Sergeant Riftan near the Twilight's Shroud to the west (30.6, 49.0).",
    [94888] = "Rescue 5 Farholde Scouts within the Twilight's Shroud for Sergeant Riftan (30.6, 49.0).",
    [94889] = "Defeat 8 Twilight Fanatics, 8 Twilight Corrupters, and 8 Twilight Champions in Twilight's Shroud for Sergeant Riftan.",
    [94890] = "Defeat Overlord Kilgar within the Twilight's Shroud and bring his head to Sergeant Riftan (30.6, 49.0). Unlocks Krol'dok Stronghold!",
    [94891] = "Return to Ashe Amberhall in Farholde Keep after defeating Overlord Kilgar.",
    [94907] = "Summon a Twilight's Thrall from a conduit in Twilight's Shroud and capture it with Amberhall's Soulstone. Leads to Krol'dok Stronghold.",
    [94968] = "Krol'dok Stronghold (Horde): Infiltrate Krol'dok Stronghold and return to Krom'rosh with the Eye of Mugg.",
    [94972] = "Krol'dok Stronghold (Horde): Recover the Tome of Twilight from Krol'dok Stronghold.",
    [94973] = "Krol'dok Moulding drops from Tunk beside War Handler Ashka in Krol'dok Stronghold; find someone in Rog'mar who knows about the mould.",
    [94975] = "Krol'dok Stronghold (Horde): Collect 15 Cultist Ears from the Twilight's Hammer inside Krol'dok Stronghold.",
    [94980] = "Krol'dok Moulding drops from Tunk inside Krol'dok Stronghold; find someone in Farholde Keep who knows about the mould.",
    [94982] = "Krol'dok Stronghold (Alliance): Infiltrate Krol'dok Stronghold and return to Commander Brant with the Eye of Mugg.",
    [94983] = "Krol'dok Stronghold (Alliance): Collect 8 Twilight Bangles inside Krol'dok Stronghold for Sergeant Riftan.",
    [94984] = "Krol'dok Stronghold (Alliance): Kill Nar'gurk inside Krol'dok Stronghold for the Tome of Twilight.",
    [94997] = "Bring the Satchel of Cursed Mementos to Ashe Amberhall in Farholde Keep.",
    [94998] = "Krol'dok Stronghold Finale: Bring the Satchel of Mementos to Melanie Sable for Curio-Adorned Necklace.",
    [95147] = "Riverglades Courier (Talk-To): Deliver Bolain's message to Captain Dalton at Southern Watch.",
    [95156] = "Collect 3 Bundles of Hay around Farholde for Ember at the training grounds.",
    [95330] = "Riverglades Delivery (Talk-To): Deliver Cassandra's surplus farm goods to Halligan Turner at Turner's Logging Camp.",
    [95428] = "Report to Krom'rosh in Rog'mar (Riverglades Horde hub).",
    [95432] = "Recruit 5 Ogre Miners for Crag'rog in Riverglades (27.4, 37.0).",
    [95603] = "Kill 5 Roosting Duskbats in the Farholde Cathedral for Sister Rowland.",
    [95613] = "Bring 5 Holy Candles to Sister Rowland in Farholde Keep.",
    [95615] = "Place 3 Memorial Candles on graves in the Farholde chapel graveyard for Sister Rowland.",
    [95912] = "Recover the Blademaster's Banner and bring it to Ember Bladewhisper in Farholde Keep.",
    [95943] = "Foreman's Plight: Locate the Foreman's Crate in Riverglades and return it to Bertrand Ironbrow in Farholde Keep.",
    [95991] = "Slay the rare/elite beast Ghostmaw in Riverglades and bring Ghostmaw's Fang to Wheatley in Farholde Keep.",

    -- Wetlands Custom Quests & Excavation Site: Wetlands
    [87491] = "Escort the captive fire elemental out of Dun Modr in northern Wetlands to its freedom.",
    [88756] = "Retrieve 3 Stolen Explosives from the Dark Iron Dwarf camps around Dun Modr in northern Wetlands.",
    [95646] = "Excavation Site: Wetlands: Kill a Highland Horror inside the dungeon and bring its root core to Rethiel the Greenwarden.",
    [95795] = "Excavation Site: Wetlands: Report Daewyn's fate back to Dorin Songblade in Lakeshire (Redridge).",
    [95810] = "Item-start quest from Titan Relic (Relic Guardian): Bring the Titan Relic to Prospector Whelgar at Whelgar's Excavation Site.",
    [98072] = "Collect 8 Pristine Crimson Scales from Wetlands whelps and bring them to James Halloran in Menethil Harbor.",
    [98189] = "Bring the Menethil Statuette to Captain Stoutfist in Menethil Keep.",
    [98190] = "Deliver the Menethil Statuette to Highlord Bolvar Fordragon in Stormwind Keep.",
    [98191] = "Deliver the Menethil Statuette to Lord Grayson Shadowbreaker in the Cathedral of Light (Stormwind).",
    [98197] = "Recover 6 Khaz Modan Timber and 30 Khaz Modan Iron around Menethil Harbor for Valstag Ironjaw.",
    [98208] = "Recover Nord'el from Wetlands enemies for Sylessa Duskwhisper in Menethil Harbor.",
    [98209] = "Boat from Menethil Harbor to Auberdine (Darkshore) and deliver Nord'el to Thundris Windweaver.",
    [98216] = "Use the Goaz Stone near the Goaz Warder at Whelgar's Excavation Site and return its Titanic Keystone to Prospector Whelgar.",
    [98219] = "Breadcrumb (Talk-To): Speak to Lieutenant Farren Orinelle in Southshore (Hillsbrad Foothills).",
    [98221] = "Destroy 4 sets of Attack Plans in the Angerfang Encampment for Captain Stoutfist in Menethil Keep.",
    [98223] = "Recover the Tattered Spellbook and return it to Captain Stoutfist in Menethil Keep.",
    [98230] = "Talk-To Breadcrumb: Find Howin Kindfeather along the road east of Menethil Harbor.",
    [98245] = "Collect 10 Razormaw Incisors from Wetlands raptors for Howin Kindfeather.",
    [98246] = "Gather 12 Perfect Razormaw Eggs in eastern Wetlands for Howin Kindfeather.",
    [98282] = "Collect an Unruptured Stalker Gland from Thelgen Rock spiders for Caitlin Grassman in Menethil Harbor.",
    [98283] = "Slay Carnage and bring Carnage's Head to Rethiel the Greenwarden in The Green Belt (Wetlands).",
    [98291] = "Kill 8 Dragonmaw Reclaimers, 5 Dragonmaw Soulbinders, and 3 Dragonmaw Infiltrators in Dragonmaw Retreat for Howin Kindfeather.",
    [98293] = "Collect 30 Dragonmaw Armaments in Dragonmaw Retreat and bring them to Captain Stoutfist in Menethil Keep.",
    [98297] = "Slay the Subdued Dragonspawn at the Dragonmaw Gates for Howin Kindfeather.",
    [98300] = "Grim Batol Chain Delivery: Deliver Howin's Missive to King Magni Bronzebeard in Ironforge.",
    [98310] = "Use the Goaz Stone near Ados, Modr, Golm, and Neru in Wetlands and return their hearts to Prospector Whelgar.",
    [98313] = "Deliver the Whelgar Relic Package to Historian Karnik in Ironforge's Hall of Explorers.",
    [98815] = "Excavation Site: Wetlands: Collect 4 Thicket Raptor Hides and return them to James Halloran in Menethil Harbor.",
    [98823] = "Excavation Site: Wetlands (Horde): Deliver the Titan Relic to Muln Earthfury on Skywatcher Plateau in Mulgore.",
    [98824] = "Excavation Site: Wetlands (Alliance): Deliver the Titan Relic to High Explorer Magellas in Ironforge's Hall of Explorers.",

    -- Redridge, Duskwood, Hillsbrad, Silverpine, Tirisfal, STV & Cozy Sleeping Bag
    [79976] = "Cozy Sleeping Bag Finale: Search the Hastily Rolled-Up Satchel under the Messenger Bag at Thoradin's Wall (Hillsbrad/Arathi border).",
    [91858] = "Paladin Silverpine Chain 1/6: Travel to The Sepulcher and speak with Trevan Rol (starts from Danitha Morr in Tirisfal).",
    [91859] = "Paladin Silverpine Chain 2/6: Speak with Deathguard Baldren in The Sepulcher.",
    [91860] = "Paladin Silverpine Chain 3/6: Investigate Charred Remains on Fenris Isle (65.0, 34.2).",
    [91861] = "Paladin Silverpine Chain 4/6: Investigate Fenris Keep to the north to find Lumina Windsinger.",
    [91862] = "Paladin Silverpine Chain 5/6: Loot the Fenris Isle Key from Rot Hide gnolls on Fenris Isle to free Lumina.",
    [95036] = "Speak with Trevan Rol at The Sepulcher with the materials for your Wolfsbane paladin blade.",
    [95111] = "Speak with Ott in Tarren Mill (Hillsbrad) and ask him to forge your blade.",
    [95125] = "Watch Ott forge the Moonsilver Blade at the forge in Tarren Mill.",
    [95126] = "Deliver Ott's Masterwork (Moonsilver Blade) from Tarren Mill back to Trevan Rol at The Sepulcher.",
    [95384] = "STV Breadcrumb: Deliver the partial scroll to Dudd Fizzlescroll in Booty Bay.",
    [95999] = "Redridge Wanted Finale: Deliver the Broken Staff of Incinerator Gar'im (Render's Valley) to Magistrate Solomon in Lakeshire.",
    [96139] = "Search Raven Hill in Duskwood for anything of interest and return to Sirra Von'Indi in Darkshire.",
    [96204] = "Paladin Silverpine Escort: Help Lumina Windsinger escape Fenris Keep, then return to The Sepulcher.",
    [97047] = "STV Kurzen Compound: Find a key to Wendel's cage and a disguise inside Kurzen's Compound.",
    [97048] = "Speak to Captain Aransas in Booty Bay after escaping Kurzen's Compound.",
    [97328] = "Recover 8 Stolen Shipments from the Ruins of Zul'Kunda in northern STV and return to Booty Bay.",
    [97894] = "Check on Gorbold Steelhand in Auberdine (Darkshore) — take the boat from Stormwind Harbor's southern dock.",
    [98059] = "Place the Sealed Company Request on the bookkeeping table inside the Hillsbrad town hall (Hillsbrad Fields).",
    [98071] = "Deliver Fallrook Varietal to Dun Garok in southeast Hillsbrad Foothills and bring back Homebrew Hops.",
    [98387] = "Bring 8 Stolen Weapons and 10 Blackrock Supplies from Redridge orcs to Marshal Marris in Lakeshire.",
    [98459] = "Deliver Tom's Gift to Bart Tidewater in Menethil Harbor (Wetlands).",
    [98463] = "Visit Nixxrax Fillamug in the Salty Sailor Tavern in Booty Bay.",
    [99156] = "Kill Riptear in northeast Tirisfal Glades and return Riptear's Heart to Deathguard Linnea.",

    -- City of Dalaran (Additional Step)
    [92458] = "City of Dalaran (Alliance): Use the provided Dalaran Sewer Key and collect the Arcane Mote inside Dalaran for Archmage Modera.",
    [92459] = "City of Dalaran: Speak with Archmage Celindra inside the City of Dalaran.",

    -- The Drowned City (35-40)
    [95748] = "Use the hide and charcoal to make a rubbing of the Third Troll Legend tablet in northern STV (Kin'weelay).",
    [95773] = "Gather 10 Brinescale Tridents from Brinescale Skirmishers along the STV coast for Commander Aggro'gosh.",
    [95775] = "The Drowned City (Horde): Use the hide and charcoal to make rubbings of the four Tablets of I'lalai inside the dungeon.",
    [95786] = "Bring the Savage Coast Report Bundle (from Brother Nimetz at Rebel Camp) to Loremaster Dibbs in Southshore.",
    [95788] = "The Drowned City: Collect 5 I'lalai Fetishes from the trolls inside The Drowned City.",
    [95789] = "The Drowned City: Collect 10 Voodoo-Infused Artifacts from Saltseer pirates inside The Drowned City.",
    [95791] = "The Drowned City Finale: Slay Captain Dreadrise and 3 Saltseer Coroners inside The Drowned City.",
    [95799] = "The Drowned City Finale (Alliance): Bring Loremaster Dibbs' I'lalai Translations to Historian Karnik in Ironforge for rare rewards.",
    [96078] = "The Drowned City Finale (Horde): Take the tablet etchings to Master Gadrin in Sen'jin Village (Durotar).",
    [96774] = "The Drowned City: Recover an Ancient Gurubashi Idol inside The Drowned City.",
    [97130] = "The Drowned City (Alliance): Recover an Ancient Gurubashi Idol inside The Drowned City.",

    -- Hall of Thanes (13-20), Ruins of Lordaeron (15-22), Razorfen Downs (33-40)
    [92401] = "Ruins of Lordaeron: Investigate the disappearance of Edward Heartweaver inside Ruins of Lordaeron.",
    [92421] = "Ruins of Lordaeron: Collect 25 Intact Limbs from undead enemies inside Ruins of Lordaeron.",
    [92422] = "Ruins of Lordaeron Finale: Slay Rath'mael inside Ruins of Lordaeron.",
    [95195] = "Ruins of Lordaeron: Collect 10 Bloodied Insignias inside Ruins of Lordaeron (starts from item drop).",
    [95216] = "Ruins of Lordaeron: Collect the Highly Toxic Strain from Witherfang inside Ruins of Lordaeron.",
    [95250] = "Ruins of Lordaeron Finale: Collect the Head of the Baron inside Ruins of Lordaeron.",
    [96394] = "Hall of Thanes: Kill 15 Enraged Apparitions and 10 Tormented Souls, then put Faldrim Anvilmar's spirit to rest.",
    [96395] = "Hall of Thanes Boss: Put the spirit of Faldrim Anvilmar to rest inside Hall of Thanes.",
    [96403] = "Hall of Thanes: Collect 8 Dwarven Heirlooms inside Hall of Thanes.",
    [3341]  = "Razorfen Downs Finale (Horde): Slay Amnennar the Coldbringer and return his skull to Andrew Brownell (rewards Vanquisher's Sword follow-up!).",
    [3636]  = "Razorfen Downs Finale (Alliance): Slay Amnennar the Coldbringer for Archbishop Benedictus in Stormwind (rewards Vanquisher's Sword!).",
    [93604] = "Razorfen Downs Finale (Horde): Acquire Virulent Blood of Agamaggan inside RFD for Kog'thug the Brave at Bristleback Retreat.",
    [96773] = "Razorfen Downs: Recover The Coldbringer's Eye from Amnennar inside Razorfen Downs.",
    [97196] = "Razorfen Downs: Recover The Coldbringer's Eye inside Razorfen Downs.",

    -- Shen'dralas, Azshara, Alcaz Prison, Blackmaw Hold & Shaper's Terrace
    [86777] = "Azshara: Kill Master Feardred and bring his amulet to Korsa outside Legashi Stronghold (63.0, 23.3).",
    [86792] = "Azshara: Kill 6 Legashi Hellraisers, 4 Legashi Soulstealers, and 2 Legashi Blackguards for Korsa.",
    [86796] = "Azshara: Escort Graal out of Legashi Stronghold (65.9, 14.4) and report to Korsa.",
    [86797] = "Azshara: Return to Gatekeeper Rageroar at Ursolan.",
    [86798] = "Azshara: Speak to Gorn One Eye in Timbermaw Hold for reinforcements.",
    [86814] = "Azshara Finale: Plant the Timbermaw War Banner at Legashi Stronghold and slay Prince Halanox.",
    [87346] = "Kill Chieftain Bloodmaw and bring his mace to Gorn One Eye in Timbermaw Hold.",
    [92914] = "Shen'dralas (Desolace/Maraudon): Explore Shen'dralas (43.6, 34.2) to locate other Shen'dralar Pylons.",
    [93016] = "Speak with Mordent Evenshade at Evenshade's Overlook (35.0, 46.4) in Shen'dralas.",
    [93341] = "Investigate the Forlorn Gardens near Shen'dralas and return to Mithera (52.8, 76.0).",
    [93394] = "Locate Magister Kirandis inside the temple of Shen'dralas.",
    [93594] = "Find Woodwyrd in the Forlorn Gardens at Shen'dralas (just east of Mithera, ~53, 76).",
    [93601] = "Seek out the quilboar at Bristleback Retreat (leads to Razorfen Downs Agamaggan's Blood).",
    [96010] = "Recover pylon shards guarded at the Magram and Gelkis centaur villages in Desolace for Mordent Evenshade.",
    [96018] = "Acquire the Mana Sieve inside Shen'dralas, collect Ancient Mana Crystals, and empower the pylons.",
    [95194] = "Alcaz Prison Prequest (Alliance): Speak with Sully McCleary in Theramore (66.2, 45.2) for Mathias Shaw.",
    [95196] = "Meet Sully McCleary in Dustwallow Marsh to learn about your Alcaz Prison mission.",
    [95198] = "Use the SI:7 Disguise Kit outside Theramore (63.4, 42.4) to eavesdrop at the Theramore Mage Tower.",
    [95262] = "Alcaz Prison (Alliance): Enter Alcaz Prison and uncover King Varian Wrynn's fate.",
    [95263] = "Alcaz Prison: Return to Sully McCleary in Dustwallow Marsh.",
    [95283] = "Alcaz Prison Prequest (Horde): Speak with Nazeer Bloodspike in Brackenwall Village for Eitrigg.",
    [95284] = "Find the missing Kor'kron Elites in Dustwallow Marsh for Nazeer Bloodspike.",
    [95285] = "Speak with Sergeant Ulka outside Alcaz Prison (70.2, 18.8).",
    [95309] = "Alcaz Prison (Horde): Find Commander Folkar inside Alcaz Prison.",
    [95454] = "Alcaz Prison (Horde): Search Alcaz Prison for King Varian Wrynn.",
    [95483] = "Alcaz Prison Finale (Horde): Bring word of Varian Wrynn's fate to Thrall in Orgrimmar.",
    [96332] = "Alcaz Prison (Horde): Slay 15 Strashaz Soldiers, 8 Strashaz Enchantresses, and Tidemistress Ca'zass for Sergeant Ulka.",
    [96334] = "Alcaz Prison: Collect 8 Blood Red Bandanas from human guards inside Alcaz Prison.",
    [96335] = "Alcaz Prison: Recover the Alcaz Shackle Key from The Questioner for Mason Connery inside Alcaz Prison.",
    [96337] = "Alcaz Prison: Use Mason Connery's note to uncover his hidden treasure inside Alcaz Prison.",
    [96369] = "Alcaz Prison: Deliver the Perfumed Note (after Blazeroar) to Commander Folkar inside Alcaz Prison.",
    [96381] = "Alcaz Prison (Alliance): Slay 15 Strashaz Soldiers, 8 Strashaz Enchantresses, and Tidemistress Ca'zass for Sully McCleary.",
    [96772] = "Alcaz Prison: Recover Zarla's Journal from deep inside Alcaz Prison.",
    [92065] = "Blackmaw Hold: Bring Varrox Bleakhoof's Head to Gatekeeper Rageroar at Ursolan.",
    [92066] = "Blackmaw Hold: Recover the Totem of Ursoc and Totem of Ursol inside Blackmaw Hold for Lorekeeper Nok at Ursolan.",
    [92067] = "Blackmaw Hold: Bring Fel-Tainted Flesh inside Blackmaw Hold.",
    [92343] = "Blackmaw Hold (Horde): Collect 10 Nordrassil Root Caps inside Blackmaw Hold.",
    [92344] = "Blackmaw Hold (Alliance): Collect 10 Nordrassil Root Caps inside Blackmaw Hold.",
    [92345] = "Blackmaw Hold Prequest (Alliance): Speak with Mathrengyl Bearwalker in Darnassus.",
    [92346] = "Blackmaw Hold Prequest (Horde): Speak with Nara Wildmane on Elder Rise in Thunder Bluff.",
    [96246] = "Blackmaw Hold: Collect 5 Blackmaw Pouches for Ekkal at the Ruins of Eldarath in Azshara.",
    [97327] = "Blackmaw Hold: Recover 5 Blackmaw Pouches for Ekkal at the Ruins of Eldarath in Azshara.",
    [95790] = "Shaper's Terrace: Collect 15 Partially Digested Journal Pages inside Shaper's Terrace.",
    [95924] = "Shaper's Terrace: Slay Venomridge, 6 Ravasaur Matriarchs, and 8 Ironhide Ravasaurs inside Shaper's Terrace.",
    [95925] = "Shaper's Terrace: Survey all 5 landmarks (Pillar of Assimilation, Achromatic Crystal, Western Gates, Regrowth Vestibule, Unearthed Stone Watcher).",
    [95926] = "Shaper's Terrace: Gather the colorless Drained Crystal Fragment near the Achromatic Crystal.",
    [95928] = "Shaper's Terrace: Bring a Moist Crystal, Charged Crystal, Noxious Crystal, and Fiery Crystal to Mayena Earthseeker.",
    [97049] = "Shaper's Terrace: Gather 8 Seeping Slime Essence from slimes inside Shaper's Terrace.",

    -- Classic Dungeon Gaps (Gnomeregan, SM, Uldaman, WC, RFC, RFD, Stockade, LBRS, UBRS, ZF, Strat, Scholo)
    [377]   = "The Stockade Finale: Slay Dextren Ward in the southern prison wing and return his hand to Councilman Millstipe.",
    [386]   = "The Stockade: Slay Targorr the Dread in the northern cell block for Guard Berton outside the entrance.",
    [387]   = "The Stockade: Kill 10 Defias Prisoners, 8 Defias Convicts, and 8 Defias Insurgents inside The Stockade.",
    [388]   = "The Stockade: Collect 10 Red Wool Bandanas from Defias inmates inside The Stockade.",
    [959]   = "Wailing Caverns (Ratchet): Loot 99-Year-Old Port from Mad Magglish in the outer/early Wailing Caverns.",
    [962]   = "Wailing Caverns (Outside & Inside): Collect 10 Serpentbloom — many grow in the outer cavern before the portal.",
    [1486]  = "Wailing Caverns: Collect 20 Deviate Hides from serpents, raptors, and turtles in Wailing Caverns (Leatherworking pattern / 10-slot bag!).",
    [1487]  = "Wailing Caverns: Kill 7 Deviate Ravagers, Vipers, Shamblers, and Dreadfangs inside Wailing Caverns.",
    [1491]  = "Wailing Caverns: Collect 6 Wailing Essence from Nightmare Ectoplasms inside Wailing Caverns for Mebok Mizzyrix.",
    [1049]  = "SM Library (Horde): Loot Compendium of the Fallen in the inner library shelves before Arcanist Doan.",
    [1050]  = "SM Library (Alliance): Loot Mythology of the Titans on the tables in SM Library before Arcanist Doan.",
    [1051]  = "SM Graveyard (Horde): Loot Vorrel's Wedding Ring from Nancy Vishas near Interrogator Vishas, then deliver to Monika in Tarren Mill.",
    [1394]  = "Final Passage: Speak to Dorn Plainstalker in Thousand Needles after finishing the SM Library lore step.",
    [2843]  = "Gnomeregan: Wait for Scooty in Booty Bay to finish calibrating the Goblin Transponder (quick port to Gnomeregan back door!).",
    [2904]  = "Gnomeregan Escort: Escort Kernobee out to the Clockwerk Run exit, then report to Scooty in Booty Bay.",
    [2922]  = "Gnomeregan: Slay Techbot outside the instance in New Tinkertown and return Techbot's Memory Core to Ironforge.",
    [2924]  = "Gnomeregan: Collect 12 Essential Artificials from Leprous Gnomes and Mechanized Guardians inside Gnomeregan.",
    [2928]  = "Gnomeregan: Collect 24 Robo-mechanical Guts from mechanical mobs inside Gnomeregan for Shoni in Stormwind.",
    [2929]  = "Gnomeregan Finale: Slay Mekgineer Thermaplugg at the Tinker's Court (rewards BiS Triprunner Dungarees!).",
    [2930]  = "Gnomeregan Punchograph finale: Collect Prismatic Punch Card inside Gnomeregan for Master Mechanic Castpipe in Ironforge.",
    [2948]  = "Gnomeregan (Alliance): Bring Brilliant Gold Ring, Silver Bar, Moss Agate, and 30s to Talvash del Kissel in Ironforge.",
    [2950]  = "Gnomeregan (Horde): Bring Brilliant Gold Ring, Silver Bar, Moss Agate, and 30s to Nogg in Orgrimmar.",
    [2951]  = "Gnomeregan Clean Room: Insert Grime-Encrusted Object + 3s into the Sparklematic 5200 machine.",
    [2962]  = "Gnomeregan TIMED (20m): Collect 8 High Potency Radioactive Fallout near Irradiated Slimes; return immediately before the fallout expires!",
    [17]    = "Uldaman Reagent Run (Alliance): Collect 12 Magenta Fungus Caps from the outer/inner Uldaman mushroom halls for Ghak in Thelsamar.",
    [709]   = "Uldaman Finale: Loot Tablet of Ryun'eh near Ironaya / Map Chamber and return to Theldurin in Badlands for Fists of Impending Doom!",
    [721]   = "Uldaman: Locate Hammertoe Grez deep inside the dig chambers of Uldaman.",
    [722]   = "Uldaman: Recover Hammertoe's Amulet from Magregan Deepshadow in the outer Uldaman caves (can drop outside the portal!).",
    [1139]  = "Uldaman Finale: Recover the Lost Tablets of Will past Galgann Firehammer and return to Ironforge.",
    [1360]  = "Uldaman (Alliance): Open Krom Stoutarm's Chest in the North Common Hall and return to Ironforge.",
    [2200]  = "Uldaman: Examine the Remains of a Paladin past the North Common Hall in Uldaman.",
    [2202]  = "Uldaman Reagent Run (Horde): Collect 12 Magenta Fungus Caps from Uldaman for Jarkal Mossmeld in Kargath.",
    [2283]  = "Uldaman (Horde): Recover the Shattered Necklace from dwarves/troggs inside Uldaman for Dran Droffers in Orgrimmar.",
    [2284]  = "Uldaman (Horde): Inspect the Paladin Remains inside Uldaman for the gem whereabouts.",
    [2341]  = "Uldaman (Horde Finale): Return to Jarkal Mossmeld in Kargath (Badlands) for your necklace reward.",
    [2342]  = "Uldaman (Horde): Open the Garrett Family Chest in the South Common Hall and return to Undercity.",
    [2361]  = "Uldaman (Alliance Finale): Wait for Talvash del Kissel in Ironforge to finish restoring the necklace.",
    [2439]  = "Uldaman Finale: Bring your Platinum Discs voucher to Dinita Stonemantle in Ironforge Vault (14-slot Thawpelt Sack or potions).",
    [5722]  = "Ragefire Chasm: Examine Maur Grimtotem's corpse near Jergosh's bridge in Ragefire Chasm.",
    [5723]  = "Ragefire Chasm: Kill 8 Ragefire Troggs and 8 Ragefire Shamans inside Ragefire Chasm.",
    [5724]  = "Ragefire Chasm: Bring the Grimtotem Satchel from inside RFC to Rahauro in Thunder Bluff.",
    [5725]  = "Ragefire Chasm: Collect Spells of Shadow and Incantations from the Nether inside RFC.",
    [5761]  = "Ragefire Chasm: Slay Taragaman the Hungerer inside RFC and return his heart to Neeru Fireblade.",
    [1101]  = "Razorfen Kraul (Alliance): Slay Charlga Razorflank and bring Razorflank's Medallion to Falfindel Waywarder in Thalanaar.",
    [1102]  = "Razorfen Kraul (Horde): Slay Charlga Razorflank and bring Razorflank's Heart to Auld Stonespire in Thunder Bluff.",
    [1142]  = "Razorfen Kraul (Alliance): Loot Treshala's Pendant in Razorfen Kraul and return to Darnassus.",
    [1144]  = "Razorfen Kraul Escort: Protect Willix the Importer until he reaches the RFK entrance (rewards rare BoE/BoP ring!).",
    [1221]  = "Razorfen Kraul: Use the Crate with Holes + Command Stick near dirt mounds inside RFK to summon a Snufflenose Gopher for 6 Blueleaf Tubers.",
    [3042]  = "Zul'Farrak: Collect 20 Vials of Troll Temper from Zul'Farrak trolls for Trenton Lighthammer in Gadgetzan.",
    [96770] = "Zul'Farrak (Alliance): Slay Witch Doctor Zum'rah and bring his head to Archmage Lan'dalock in Dalaran.",
    [96775] = "Zul'Farrak (Horde): Slay Witch Doctor Zum'rah and bring his head to Mazu'kon in Mulgore.",
    [5382]  = "Scholomance: Slay Doctor Theolen Krastinov in the Butcher's Sanctum and burn both Sarkhoff remains!",
    [5213]  = "Stratholme Undead: Gather Scourge Data from the Scourge ziggurats inside Stratholme Undead (rewards Argent Dawn Seal/Rune!).",
    [4081]  = "Blackrock Depths (Horde): Slay 15 Anvilrage Guardsmen, 10 Wardens, and 5 Footmen inside BRD for Warlord Goretooth.",
    [9015]  = "BRD Dungeon Set 2 Arena: Plant the Banner of Provocation inside Ring of Law, defeat Theldren & gladiators, and return Lord Valthalak's Amulet piece.",
    [97197] = "Blackrock Depths: Recover a Fragment of the Firelands from Magmus in BRD for Alaana Stormwalker in Mulgore.",
    [4742]  = "LBRS UBRS Key 1/2: Collect Spirestone, Smolderthorn, and Bloodaxe gemstones from Highlord Omokk, War Master Voone, and Overlord Wyrmthalak.",
    [4974]  = "UBRS Finale (Horde): Slay Warchief Rend Blackhand in UBRS and return his head to Thrall in Orgrimmar (rewards Blackhand's Breadth / Mark of Tyranny!).",
    [4981]  = "Lower Blackrock Spire: Locate Bijou hidden in a small recess past the early LBRS bridges.",
    [5081]  = "Lower Blackrock Spire (Alliance Finale): Slay Voone, Omokk, and Wyrmthalak and return to Marshal Maxwell in Burning Steppes.",
    [-97100] = "Mallet of Zul'Farrak: Climb to the altar at the top of Jintha'Alor (The Hinterlands) and USE the Sacred Mallet to forge Mallet of Zul'Farrak.",
}
for qid, tipStr in pairs(FOREVER_QUEST_TIPS) do
    if not Data.QuestTips[qid] then
        Data.QuestTips[qid] = tipStr
    end
end

-- =========================================================================
-- 4. WoW Forever Quest Payoffs & Dungeon Key Rewards
-- =========================================================================
Data.QuestPayoffs = Data.QuestPayoffs or {}
Data.QuestPayoffsByTitle = Data.QuestPayoffsByTitle or {}
local FOREVER_PAYOFFS = {
    [2040] = { unlock = "Dungeon: The Deadmines", reward = "Polar Gauntlets / Sable Wand / Bravo's Armbands / Dreamer's Leggings", note = "Follows Speak with Shoni.", summary = "Underground Assault • The Deadmines" },
    [2041] = { note = "This leads directly into Underground Assault." },
    [4082] = { unlock = "Dungeon: Blackrock Depths", summary = "KILL ON SIGHT: High Ranking Dark Iron Officials • Blackrock Depths" },
    [5127] = { unlock = "Dungeon: Upper Blackrock Spire", reward = "Plans: Demon Forged Breastplate / Demon Kissed Sack / Elixir of Demonslaying", note = "Blacksmithing 270 (Armorsmith). Use the Blood Stained Pike on Goraluk's corpse and loot the Unforged Rune Covered Breastplate nearby.", summary = "The Demon Forge • Upper Blackrock Spire" },
    [92070] = { unlock = "Dungeon: Blackmaw Hold", reward = "Nama's Cherished Necklace", note = "Item-start quest. The necklace is a handmade furbolg keepsake. The exact NPC and hand-in location are still being verified.", summary = "A Lost Memento • Blackmaw Hold" },
    [8232] = { unlock = "Dungeon: Sunken Temple", reward = "Hunting Spear / Devilsaur Eye / Devilsaur Tooth", note = "Hunter class quest. The Tooth of Morphaz drops from Morphaz.", summary = "The Green Drake • Sunken Temple" },
    [4128] = { unlock = "Dungeon: Blackrock Depths", note = "Introductory step leading to Hurley Blackbreath.", summary = "Ragnar Thunderbrew • Blackrock Depths" },
    [7201] = { unlock = "Dungeon: Blackrock Depths", reward = "Lagrave's Seal", note = "Essence of the Elements drops from BRD elementals and golems.", summary = "The Last Element • Blackrock Depths" },
    [4136] = { unlock = "Dungeon: Blackrock Depths", reward = "Rancor Boots / Penance Spaulders / Splintsteel Armor", summary = "Ribbly Screwspigot • Blackrock Depths" },
    [95140] = { unlock = "Dungeon: Shadowfang Keep", reward = "Wolfsbane", note = "Paladin class quest for undead and tauren. In this dungeon: the Enchanted Silver Ingot lies on a table in Archmage Arugal's room, after you kill him. The other parts are Whitestone Oak Lumber (The Deadmines) and the Purified Kor Gem (Blackfathom Deeps).", summary = "Old Fire-Eye • Shadowfang Keep" },
    [95204] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Small Sack of Gems", note = "Community reports indicate the Crest can spawn at one of several locations inside the dungeon. Reported spots include upper floors of towers, side/crypt rooms near The Baron, and the area around Bjork.", summary = "Crest of Lordaeron • Ruins of Lordaeron" },
    [1048] = { unlock = "Dungeon: Scarlet Monastery: Armory", reward = "Sword of Omen / Prophetic Cane / Dragon's Blood Necklace", note = "Herod is in the Armory; Loksey in the Library; Mograine and Whitemane in the Cathedral.", summary = "Into The Scarlet Monastery • Scarlet Monastery: Armory" },
    [1049] = { unlock = "Dungeon: Scarlet Monastery: Library", reward = "Vile Protector / Forcestone Buckler / Omega Orb", summary = "Compendium of the Fallen • Scarlet Monastery: Library" },
    [1050] = { unlock = "Dungeon: Scarlet Monastery: Library", reward = "Explorers' League Commendation", summary = "Mythology of the Titans • Scarlet Monastery: Library" },
    [1051] = { unlock = "Dungeon: Scarlet Monastery: Graveyard", reward = "Mantle of Woe / Grimsteel Cape", summary = "Vorrel's Revenge • Scarlet Monastery: Graveyard" },
    [132] = { note = "Second step of the Defias Brotherhood chain." },
    [5243] = { unlock = "Dungeon: Stratholme: Living", reward = "Crown of the Penitent / Band of the Penitent", note = "Collect 5 Stratholme Holy Water from the supply crates in the streets; some crates spawn enemies.", summary = "Houses of the Holy • Stratholme: Living" },
    [5247] = { unlock = "Dungeon: Dire Maul: West", note = "Fill her vial at the dire pool along Eldreth Row in Dire Maul West; also bring 1 Enchanted Thorium Bar and 5 Crystal Restore.", summary = "Fragments of the Past • Dire Maul: West" },
    [5251] = { unlock = "Dungeon: Stratholme: Living", note = "Kill Archivist Galford in the Scarlet Bastion and burn the archives.", summary = "The Archivist • Stratholme: Living" },
    [5263] = { unlock = "Dungeon: Stratholme: Undead", note = "Then Lord Maxwell Tyrosus and The Argent Hold, in Light's Hope Chapel, give the weapon or shield reward.", summary = "Above and Beyond • Stratholme: Undead" },
    [92456] = { unlock = "Dungeon: City of Dalaran", reward = "Vine Pruner's Cloak / Thorn Protecting Girdle", summary = "A Green Sample • City of Dalaran" },
    [135] = { note = "Shaw investigates the connection between the Defias and the Stonemasons." },
    [5343] = { unlock = "Dungeon: Scholomance", note = "The four deeds: Southshore in the first large chamber, Tarren Mill before the hatchlings, Brill by Ras Frostwhisper, Caer Darrow by Lord Alexei Barov. The follow-up The Last Barov sends you to kill the rival brother.", summary = "Barov Family Fortune • Scholomance" },
    [92457] = { unlock = "Dungeon: City of Dalaran", reward = "Fallen Guard's Pendant / Arcane Infused Rod", note = "There may not be enough of these mobs inside to finish it in one run.", summary = "Starving Arcane • City of Dalaran" },
    [545] = { note = "Available after completing Prison Break In." },
    [7441] = { unlock = "Dungeon: Dire Maul: East", reward = "Spry Boots / Sprinter's Sword", note = "Chase and talk to Pusillin through the wing until he fights, then kill him for the book. He also drops the Crescent Key.", summary = "Pusillin and the Elder Azj'Tordin • Dire Maul: East" },
    [1098] = { unlock = "Dungeon: Shadowfang Keep", reward = "Ghostly Mantle / Tanned Shoulderpads / Bronzed Shoulderguards", summary = "Deathstalkers in Shadowfang • Shadowfang Keep" },
    [2930002] = { note = "The only punchographs outside the instance: on the raised platform in the Train Depot and by the Workshop (back door) entrance." },
    [7461] = { unlock = "Dungeon: Dire Maul: West", reward = "Bonecrusher / Backwood Helm / Sedge Boots", note = "Kill the guardians of all five pylons, then Immol'thar, then Prince Tortheldrin. Return to the Ancient, take The Treasure of the Shen'dralar and open the chest under the library stairs for the reward.", summary = "The Madness Within • Dire Maul: West" },
    [2200] = { unlock = "Dungeon: Uldaman", summary = "Back to Uldaman • Uldaman" },
    [1102] = { unlock = "Dungeon: Razorfen Kraul", reward = "Berylline Pads / Stonefist Girdle / Marbled Buckler", summary = "A Vengeful Fate • Razorfen Kraul" },
    [2204] = { unlock = "Dungeon: Uldaman", note = "The power source drops from Archaedas. Finishing it unlocks Talvash's Enhancing Necklace.", summary = "Restoring the Necklace • Uldaman" },
    [7481] = { unlock = "Dungeon: Dire Maul: North", note = "Interact with the Skeletal Remains of Telmius Dreamseeker beside Lorekeeper Lydros in the Athenaeum. Unlocks Lydros's libram exchanges.", summary = "Elven Legends • Dire Maul: North" },
    [7485] = { unlock = "Dungeon: Dire Maul: North", reward = "Arcanum of Protection", note = "Repeatable. Needs your faction's Elven Legends turned in first.", summary = "Libram of Protection • Dire Maul: North" },
    [7489] = { unlock = "Dungeon: Dire Maul: East", reward = "Lorespinner", note = "The web drops from Lethtendris.", summary = "Lethtendris's Web • Dire Maul: East" },
    [1109] = { unlock = "Dungeon: Razorfen Kraul", summary = "Going, Going, Guano! • Razorfen Kraul" },
    [7501] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Paladin class book. Click the book to start the quest.", summary = "The Light and How To Swing It • Dire Maul: North" },
    [7505] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Shaman class book. Click the book to start the quest.", summary = "Frost Shock and You • Dire Maul: North" },
    [5463] = { unlock = "Dungeon: Stratholme: Undead", note = "After Baron Rivendare dies, use the glowing rune on the floor of his room, then take the follow-up back to Leonid.", summary = "Menethil's Gift • Stratholme: Undead" },
    [1113] = { unlock = "Dungeon: Scarlet Monastery: Armory", note = "Monastery-wide collection: any Scarlet humanoid on the way to the Armory can drop Hearts of Zeal.", summary = "Hearts of Zeal • Scarlet Monastery: Armory" },
    [6502] = { unlock = "Dungeon: Upper Blackrock Spire", reward = "Drakefire Amulet", note = "Part of the Onyxia attunement.", summary = "Drakefire Amulet • Upper Blackrock Spire" },
    [2240] = { unlock = "Dungeon: Uldaman", reward = "Dwarven Charge / Explorer's League Lodestar", summary = "The Hidden Chamber • Uldaman" },
    [5515] = { unlock = "Dungeon: Scholomance", note = "The bag drops from Jandice Barov.", summary = "Krastinov's Bag of Horrors • Scholomance" },
    [6562] = { unlock = "Dungeon: Blackfathom Deeps", note = "Introductory step leading to The Essence of Aku'Mai.", summary = "Trouble in the Deeps • Blackfathom Deeps" },
    [1139] = { unlock = "Dungeon: Uldaman", reward = "Medal of Courage", summary = "The Lost Tablets of Will • Uldaman" },
    [2278] = { unlock = "Dungeon: Uldaman", note = "The discs are in the Map Chamber, past Ironaya.", summary = "The Platinum Discs • Uldaman" },
    [6602] = { unlock = "Dungeon: Upper Blackrock Spire", reward = "Drakefire Amulet", note = "Part of the Onyxia attunement.", summary = "Blood of the Black Dragon Champion • Upper Blackrock Spire" },
    [1142] = { unlock = "Dungeon: Razorfen Kraul", reward = "Mourning Shawl / Lancer Boots / Sentinel's Boots", summary = "Mortality Wanes • Razorfen Kraul" },
    [2284] = { unlock = "Dungeon: Uldaman", summary = "Necklace Recovery, Take 2 • Uldaman" },
    [1144] = { unlock = "Dungeon: Razorfen Kraul", reward = "Monkey Ring / Snake Hoop / Tiger Band / Boar Signet", summary = "Willix the Importer • Razorfen Kraul" },
    [6626] = { unlock = "Dungeon: Razorfen Downs", note = "These mobs are outside the instance, around the entrance.", summary = "A Host of Evil • Razorfen Downs" },
    [3341] = { unlock = "Dungeon: Razorfen Downs", reward = "Amberglow Talisman / Purified Ring", summary = "Bring the End • Razorfen Downs" },
    [8257] = { unlock = "Dungeon: Sunken Temple", reward = "Blessed Prayer Beads / Woestave / Circle of Hope", note = "Priest class quest. Morphaz's blood is turned in to Greta Mosshoof, not Ogtinc.", summary = "Blood of Morphaz • Sunken Temple" },
    [95787] = { unlock = "Dungeon: The Drowned City", note = "Lead-in: An Acquaintance in Southshore, taking the Savage Coast Report Bundle to Loremaster Dibbs.", summary = "Take Two With Water • The Drowned City" },
    [2342] = { unlock = "Dungeon: Uldaman", summary = "Reclaimed Treasures • Uldaman" },
    [7761] = { unlock = "Dungeon: Upper Blackrock Spire", note = "The Scarshield Quartermaster is in the hallway outside the Spire portal. Touch Drakkisath's Brand behind General Drakkisath; this unlocks the Orb of Command shortcut to Blackwing Lair.", summary = "Blackhand's Command • Upper Blackrock Spire" },
    [3373] = { unlock = "Dungeon: Sunken Temple", reward = "Chained Essence of Eranikus", summary = "The Essence of Eranikus • Sunken Temple" },
    [5723] = { unlock = "Dungeon: Ragefire Chasm", summary = "Testing an Enemy's Strength • Ragefire Chasm" },
    [5727] = { note = "Neeru is in the Cleft of Shadow near the Ragefire Chasm entrance." },
    [4724] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Astoria Robes / Traphook Jerkin / Jadescale Breastplate", note = "Kill Halycon, the worg den mother. Be ready for Gizrul the Slavener, who comes for you right after.", summary = "The Pack Mistress • Lower Blackrock Spire" },
    [8425] = { unlock = "Dungeon: Sunken Temple", reward = "Fury Visor / Diamond Flask / Razorsteel Shoulders", note = "Warrior class quest for both factions. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.", summary = "Voodoo Feathers • Sunken Temple" },
    [4764] = { unlock = "Dungeon: Upper Blackrock Spire", reward = "Swiftfoot Treads / Blinkstrike Armguards", note = "Doomrigger's Coffer is in the Rookery. Then take Delivery to Ridgewell to Count Remington Ridgewell in Stormwind Keep for the reward.", summary = "Doomrigger's Clasp • Upper Blackrock Spire" },
    [4768] = { unlock = "Dungeon: Upper Blackrock Spire", reward = "Swiftfoot Treads / Blinkstrike Armguards", note = "The Darkstone Tablet lies on the ground in the Rookery.", summary = "The Darkstone Tablet • Upper Blackrock Spire" },
    [1198] = { unlock = "Dungeon: Blackfathom Deeps", summary = "In Search of Thaelrid • Blackfathom Deeps" },
    [4788] = { unlock = "Dungeon: Lower Blackrock Spire", note = "The fifth and sixth Mosh'aru tablets are in the Smolderthorn troll area. Continues with Confront Yeh'kinya and The Hand of Rastakhan.", summary = "The Final Tablets • Lower Blackrock Spire" },
    [2398] = { unlock = "Dungeon: Uldaman", note = "Introductory step leading to The Hidden Chamber.", summary = "The Lost Dwarves • Uldaman" },
    [2418] = { unlock = "Dungeon: Uldaman", reward = "Energized Stone Circle / Duracin Bracers / Everlast Boots / Charged Leather Bracers", note = "The power stones drop from Shadowforge dwarves in the outer cave.", summary = "Power Stones • Uldaman" },
    [3447] = { unlock = "Dungeon: Sunken Temple", reward = "Hakkari Urn", note = "Light the statues around the circle in the right order to summon Atal'alarion.", summary = "Secret of the Circle • Sunken Temple" },
    [6922] = { unlock = "Dungeon: Blackfathom Deeps", reward = "Outlaw Sabre / Witch's Finger / Dreamer's Chestguard", summary = "Baron Aquanis • Blackfathom Deeps" },
    [95663] = { note = "Required before Open the Maw." },
    [95791] = { unlock = "Dungeon: The Drowned City", reward = "Mutinous Cuffs / South Seas Shroud", summary = "The Saltseer Captain • The Drowned City" },
    [97198] = { unlock = "Dungeon: Blackmaw Hold", summary = "Blackmaw Magic • Blackmaw Hold" },
    [95216] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Plaguefang / Blight Gloves", summary = "The New Plague • Ruins of Lordaeron" },
    [79360] = { note = "The Razorfen Kraul step. After Call of Air, Prate Cloudseer sends you to Rau Cliffrunner. It can't be shared on the Horde side." },
    [8945] = { unlock = "Dungeon: Stratholme: Undead", reward = "Ysida's Satchel", note = "Timed: rescue Ysida Harmon by killing Baron Rivendare within 45 minutes. Use the Extra-Dimensional Ghost Revealer to see Anthion.", summary = "Dead Man's Plea • Stratholme: Undead" },
    [7046] = { unlock = "Dungeon: Maraudon", reward = "Scepter of Celebras", note = "Defeat Celebras the Cursed where the paths meet and turn in Legends of Maraudon to Celebras the Redeemed, then help with his ritual and speak to him again for the scepter.", summary = "The Scepter of Celebras • Maraudon" },
    [3527] = { unlock = "Dungeon: Zul'Farrak", note = "The tablets drop from Theka the Martyr and Hydromancer Velratha.", summary = "The Prophecy of Mosh'aru • Zul'Farrak" },
    [7070] = { unlock = "Dungeon: Maraudon", reward = "Zealous Shadowshard Pendant / Prodigious Shadowshard Pendant", note = "Shadowshard elementals in the outer purple-crystal caves. It can be done without entering the instance.", summary = "Shadowshard Fragments • Maraudon" },
    [79361] = { note = "Twisted Totems only drop while this quest is in your log. Water: Mirefin murlocs, northeast coast of Dustwallow Marsh. Air: Maraudine centaurs, Desolace. Earth: Lost Ones, Swamp of Sorrows. Fire: Dustbelcher ogres and Stonevault troggs, Badlands." },
    [1275] = { unlock = "Dungeon: Blackfathom Deeps", reward = "Beetle Clasps / Prelacy Cape / Staghide Armguards", summary = "Researching the Corruption • Blackfathom Deeps" },
    [6163] = { unlock = "Dungeon: Stratholme: Undead", reward = "Royal Seal of Alexis / Elemental Circle", summary = "Ramstein • Stratholme: Undead" },
    [8250] = { unlock = "Dungeon: Sunken Temple", note = "Introductory step leading to Destroy Morphaz.", summary = "Magecraft • Sunken Temple" },
    [4133] = { unlock = "Dungeon: Blackrock Depths", note = "Introductory step leading to Lost Thunderbrew Recipe.", summary = "Vivian Lagrave • Blackrock Depths" },
    [5160] = { unlock = "Dungeon: Upper Blackrock Spire", note = "Awbee is the wounded blue dragon near the arena route after Rend. Use the rune deep in the Mazthoril cave to reach Haleh.", summary = "The Matron Protectorate • Upper Blackrock Spire" },
    [95795] = { unlock = "Dungeon: Excavation Site: Wetlands", reward = "Daewyn's Girdle / Songblade Stabilizer", summary = "Fallen in the Fen • Excavation Site: Wetlands" },
    [92343] = { unlock = "Dungeon: Blackmaw Hold", summary = "Get to the Roots of It • Blackmaw Hold" },
    [4201] = { unlock = "Dungeon: Blackrock Depths", reward = "Nagmara's Whipping Belt / Manacle Cuffs", note = "Gromsblood, Giant Silver Veins (Azshara cliff giants) and the vial filled at Golakka Hot Springs in Un'Goro. Opens a peaceful way through the bar on later visits.", summary = "The Love Potion • Blackrock Depths" },
    [8418] = { unlock = "Dungeon: Sunken Temple", reward = "Lightforged Blade / Sanctified Orb / Chivalrous Signet / Holy Mightstone", note = "Paladin class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.", summary = "Forging the Mightstone • Sunken Temple" },
    [92344] = { unlock = "Dungeon: Blackmaw Hold", summary = "Get to the Roots of It • Blackmaw Hold" },
    [166] = { unlock = "Dungeon: The Deadmines", reward = "Chausses of Westfall / Tunic of Westfall / Staff of Westfall", note = "Final dungeon step of the Defias Brotherhood chain; complete the earlier steps first.", summary = "The Defias Brotherhood • The Deadmines" },
    [167] = { unlock = "Dungeon: The Deadmines", reward = "Miner's Revenge / Miner's Workgloves / Miner's Workboots", note = "The foreman is in the tunnels before the instance portal.", summary = "Oh Brother... • The Deadmines" },
    [168] = { unlock = "Dungeon: The Deadmines", reward = "Tunneler's Boots / Dusty Mining Gloves / Worn Miner's Waistcord", note = "The undead side tunnel is before the instance portal.", summary = "Collecting Memories • The Deadmines" },
    [79366] = { note = "Elite, level 40: bring a group. At the steam pools in Thousand Needles, stand on the rune circle and use the Corrupted Totems. Waves of elementals come, then an elite quilboar and the Ravaging Tempest, which drops the Eye of the Tempest for every Shaman on the quest. Horde: follow your quest log." },
    [95798] = { unlock = "Dungeon: The Drowned City", reward = "Rune-Etched Epaulets / Apprentice Sorcerer's Slacks", note = "The Kirin Tor only let noteworthy visitors into Dalaran.", summary = "The Web of Magic • The Drowned City" },
    [5384] = { unlock = "Dungeon: Scholomance", reward = "Penelope's Rose / Mirah's Song", note = "Use the Blood of Innocents at the brazier on the Scholomance porch. Rewards the Spectral Essence.", summary = "Kirtonos the Herald • Scholomance" },
    [95799] = { unlock = "Dungeon: The Drowned City", reward = "Ancient Voodoo Pouch / Intrepid Explorer's Chainmail", summary = "Findings for the Explorer's League • The Drowned City" },
    [1360] = { unlock = "Dungeon: Uldaman", summary = "Reclaimed Treasures • Uldaman" },
    [7482] = { unlock = "Dungeon: Dire Maul: North", note = "Interact with the Skeletal Remains of Telmius Dreamseeker beside Lorekeeper Lydros in the Athenaeum. Unlocks Lydros's libram exchanges.", summary = "Elven Legends • Dire Maul: North" },
    [94968] = { unlock = "Dungeon: Krol'dok Stronghold", reward = "Rock on Stick / Bigger Rock on Bigger Stick / Stick No Rock", summary = "Eye of Mugg • Krol'dok Stronghold" },
    [7494] = { unlock = "Dungeon: Dire Maul: East", note = "Introductory step leading to Lethtendris's Web.", summary = "Feathermoon Stronghold • Dire Maul: East" },
    [7498] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Rogue class book. Click the book to start the quest.", summary = "Garona: A Study on Stealth and Treachery • Dire Maul: North" },
    [7502] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Warlock class book. Click the book to start the quest.", summary = "Harnessing Shadows • Dire Maul: North" },
    [7506] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Druid class book. Click the book to start the quest.", summary = "The Emerald Dream... • Dire Maul: North" },
    [3765] = { unlock = "Dungeon: Blackfathom Deeps", note = "Introductory step leading to Researching the Corruption.", summary = "The Corruption Abroad • Blackfathom Deeps" },
    [95928] = { unlock = "Dungeon: Shaper's Terrace", reward = "Crystalline Pauldrons / Potent Treads", summary = "Crystalline Elements • Shaper's Terrace" },
    [2768] = { unlock = "Dungeon: Zul'Farrak", reward = "Masons Fraternity Ring / Engineer's Guild Headpiece", note = "The rod drops from Sergeant Bly after the pyramid event.", summary = "Divino-matic Rod • Zul'Farrak" },
    [2770] = { unlock = "Dungeon: Zul'Farrak", reward = "Carrot on a Stick", summary = "Gahz'rilla • Zul'Farrak" },
    [6563] = { unlock = "Dungeon: Blackfathom Deeps", summary = "The Essence of Aku'Mai • Blackfathom Deeps" },
    [1394] = { unlock = "Dungeon: Scarlet Monastery: Library", reward = "Windstorm Hammer / Dancing Flame", summary = "Final Passage • Scarlet Monastery: Library" },
    [95034] = { note = "The questline starts at level 18 with Diplomatic Incident from Danitha Morr at Bandarion Keep, Tirisfal Glades. It takes you to Fenris Isle, where you free Lumina Windsinger from Fenris Keep." },
    [98423] = { unlock = "Dungeon: Hall of Thanes", note = "The tablet is inside one of the vaults in the Reliquary of Kings, in Durgen Dirgehammer's final boss room. Open the vaults and interact with the tablet before leaving the dungeon.", summary = "The Treaty of Understanding • Hall of Thanes" },
    [704] = { unlock = "Dungeon: Uldaman", reward = "Prospector Gloves / Restorer's Fine Gloves / Excavator Gauntlets", note = "The urns are in the outer Uldaman cave, before the instance portal.", summary = "Agmond's Fate • Uldaman" },
    [707] = { unlock = "Dungeon: Uldaman", note = "Introductory step leading to Agmond's Fate.", summary = "Ironband Wants You! • Uldaman" },
    [709] = { unlock = "Dungeon: Uldaman", reward = "Doomsayer's Robe / Doomcaller's Pants / Fists of Impending Doom", summary = "Solution to Doom • Uldaman" },
    [356] = { note = "Both are at the Balnir Farmstead, east of Linnea's camp." },
    [2846] = { unlock = "Dungeon: Zul'Farrak", reward = "Spellshifter Rod / Gemshale Pauldrons", note = "The Tiara drops from Hydromancer Velratha.", summary = "Tiara of the Deep • Zul'Farrak" },
    [94972] = { unlock = "Dungeon: Krol'dok Stronghold", reward = "Indoctrinated Choker / Convert's Bindings", summary = "Tome of Twilight • Krol'dok Stronghold" },
    [5724] = { unlock = "Dungeon: Ragefire Chasm", reward = "Featherbead Bracers / Savannah Bracers / Garrison Cuffs", summary = "Returning the Lost Satchel • Ragefire Chasm" },
    [92415] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Tarnished Locket", note = "Item-start quest from the Blood-Stained Letter.", summary = "Remember That I Love You • Ruins of Lordaeron" },
    [4729] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Worg Carrier", note = "Use the supplied cage on a Bloodaxe Worg Pup in the worg area.", summary = "Kibler's Exotic Pets • Lower Blackrock Spire" },
    [721] = { unlock = "Dungeon: Uldaman", summary = "A Sign of Hope • Uldaman" },
    [722] = { unlock = "Dungeon: Uldaman", summary = "Amulet of Secrets • Uldaman" },
    [1445] = { unlock = "Dungeon: Sunken Temple", reward = "Guardian Talisman", note = "Collect 20 Fetishes of Hakkar from Atal'ai trolls; outer-temple trolls also drop them.", summary = "The Temple of Atal'Hakkar • Sunken Temple" },
    [1446] = { unlock = "Dungeon: Sunken Temple", reward = "Rainstrider Leggings / Helm of Exile", note = "Kill the six troll guardians on the balconies to drop Jammal'an's barrier, then bring back his head.", summary = "Jammal'an the Prophet • Sunken Temple" },
    [4769] = { unlock = "Dungeon: Upper Blackrock Spire", note = "Introductory step leading to The Darkstone Tablet.", summary = "Vivian Lagrave and the Darkstone Tablet • Upper Blackrock Spire" },
    [2904] = { unlock = "Dungeon: Gnomeregan", reward = "Fire-welded Bracers / Fairywing Mantle / Technician's Bracers", summary = "A Fine Mess • Gnomeregan" },
    [94974] = { unlock = "Dungeon: Krol'dok Stronghold", reward = "Krol'dok Compound Key", note = "Keep any Krol'dok Moulding you loot: it starts the quest before this one.", summary = "Key Ingredients • Krol'dok Stronghold" },
    [2922] = { unlock = "Dungeon: Gnomeregan", summary = "Save Techbot's Brain! • Gnomeregan" },
    [2924] = { unlock = "Dungeon: Gnomeregan", summary = "Essential Artificials • Gnomeregan" },
    [5848] = { unlock = "Dungeon: Stratholme: Living", note = "Take the painting hidden behind the twin-moons picture in Archivist Galford's room before you burn the archives.", summary = "Of Love and Family • Stratholme: Living" },
    [2928] = { unlock = "Dungeon: Gnomeregan", reward = "Shoni's Disarming Tool / Shilly Mitts / Operator's Gloves", summary = "Gyrodrillmatic Excavationators • Gnomeregan" },
    [2930] = { unlock = "Dungeon: Gnomeregan", reward = "Repairman's Cape / Mechanic's Pipehammer", summary = "Data Rescue • Gnomeregan" },
    [2936] = { unlock = "Dungeon: Zul'Farrak", note = "The Tablet of Theka is in Theka the Martyr's room.", summary = "The Spider God • Zul'Farrak" },
    [94975] = { unlock = "Dungeon: Krol'dok Stronghold", reward = "Semblance of Twilight", summary = "A Token of Vengeance • Krol'dok Stronghold" },
    [2948] = { unlock = "Dungeon: Gnomeregan", reward = "Talvash's Gold Ring", summary = "Gnome Improvement • Gnomeregan" },
    [2950] = { unlock = "Dungeon: Gnomeregan", reward = "Nogg's Gold Ring", summary = "Nogg's Ring Redo • Gnomeregan" },
    [2962] = { unlock = "Dungeon: Gnomeregan", summary = "The Only Cure is More Green Glow • Gnomeregan" },
    [1486] = { unlock = "Dungeon: Wailing Caverns", reward = "Slick Deviate Leggings / Deviate Hide Pack", summary = "Deviate Hides • Wailing Caverns" },
    [1487] = { unlock = "Dungeon: Wailing Caverns", reward = "Pattern: Deviate Scale Belt / Sizzle Stick / Dagmire Gauntlets", summary = "Deviate Eradication • Wailing Caverns" },
    [1489] = { note = "Tonga sends you to Hamuul after Altered Beings." },
    [373] = { unlock = "Dungeon: The Deadmines", note = "Starts a follow-up chain that continues with Bazil Thredd.", summary = "The Unsent Letter • The Deadmines" },
    [4003] = { unlock = "Dungeon: Blackrock Depths", reward = "Thrall's Resolve / Eye of Orgrimmar", note = "Keep Princess Moira alive and speak to her after Emperor Thaurissan dies. Her The Princess Saved? sends you back to Thrall for the reward.", summary = "The Royal Rescue • Blackrock Depths" },
    [377] = { unlock = "Dungeon: The Stockade", reward = "Ambassador's Boots / Darkshire Mail Leggings / Town Clerk's Mittens", summary = "Crime and Punishment • The Stockade" },
    [5001] = { unlock = "Dungeon: Lower Blackrock Spire", note = "Bijou hides in a recess beyond the early bridges. Her belongings spawn in one of several places around the troll and orc rooms.", summary = "Bijou's Belongings • Lower Blackrock Spire" },
    [378] = { unlock = "Dungeon: The Stockade", reward = "Belt of Vindication / Headbasher / Magistrate's Pantaloons", note = "Requires The Dark Iron War before this quest becomes available.", summary = "The Fury Runs Deep • The Stockade" },
    [7067] = { unlock = "Dungeon: Maraudon", reward = "Mark of the Chosen", note = "Loot the Amulet of Spirits from the Nameless Prophet in the outer caves, then use it to fight the five Khans: three in the outer caves, one on the purple route and one on the orange route. Combine their gems with the amulet.", summary = "The Pariah's Instructions • Maraudon" },
    [95809] = { unlock = "Dungeon: Excavation Site: Wetlands", reward = "Greater Healing Potion / Mana Potion", note = "Follow-up of Lost in the Thicket Things.", summary = "Heartwoven • Excavation Site: Wetlands" },
    [4063] = { unlock = "Dungeon: Blackrock Depths", reward = "Azure Moon Amice / Raincaster Drape / Basaltscale Armor / Lavaplate Gauntlets", note = "Kill Golem Lord Argelmach for his head and collect 10 Intact Elemental Cores from the constructs guarding him.", summary = "The Rise of the Machines • Blackrock Depths" },
    [3042] = { unlock = "Dungeon: Zul'Farrak", summary = "Troll Temper • Zul'Farrak" },
    [5081] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Wyrmthalak's Shackles / Omokk's Girth Restrainer / Halycon's Muzzle / Vosh'gajin's Strand / Voone's Vice Grips", summary = "Maxwell's Mission • Lower Blackrock Spire" },
    [92421] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "The Stitcher / Spare Part Bindings", summary = "Light's Justice • Ruins of Lordaeron" },
    [4083] = { unlock = "Dungeon: Blackrock Depths", note = "Mining 230. Talk to Gloom'rel before the Seven fight; give the Spectral Chalice 2 Star Rubies, 20 Gold Bars and 10 Truesilver Bars to learn Smelt Dark Iron.", summary = "The Spectral Chalice • Blackrock Depths" },
    [95682] = { unlock = "Dungeon: Excavation Site: Wetlands", reward = "Knife-Polishing Rag / Dirt-Heavy Bracers", note = "Related lead-in: Dragonmaw Rumors. The Dragonmaw Dispatch is recovered from the Dragonmaw forces inside the dungeon.", summary = "Open the Maw • Excavation Site: Wetlands" },
    [98815] = { unlock = "Dungeon: Excavation Site: Wetlands", summary = "Highland Hides • Excavation Site: Wetlands" },
    [79442] = { note = "Final step. Choose Rage of the Storm, Lightning's Grasp or Tidebringer's Claw." },
    [5125] = { unlock = "Dungeon: Stratholme: Undead", reward = "Will of the Martyr / Blood of the Martyr", note = "Give Aurius the Medallion of Faith before the Baron fight; speak to him after Baron Rivendare dies.", summary = "Aurius' Reckoning • Stratholme: Undead" },
    [386] = { unlock = "Dungeon: The Stockade", reward = "Lucine Longsword / Hardened Root Staff / Unknown Reward", summary = "What Comes Around... • The Stockade" },
    [8236] = { unlock = "Dungeon: Sunken Temple", reward = "Ebon Mask / Whisperwalk Boots / Duskbat Drape", note = "Rogue class quest. The Azure Key drops from Morphaz.", summary = "The Azure Key • Sunken Temple" },
    [4126] = { unlock = "Dungeon: Blackrock Depths", note = "Break the three kegs in the Grim Guzzler storeroom to spawn Hurley Blackbreath and his guards.", summary = "Hurley Blackbreath • Blackrock Depths" },
    [92422] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Forsaken Greataxe / Gnarled Necromancer's Staff", summary = "The Wrath of Rath'mael • Ruins of Lordaeron" },
    [4134] = { unlock = "Dungeon: Blackrock Depths", note = "Break the three kegs in the Grim Guzzler storeroom to spawn Hurley Blackbreath and his guards.", summary = "Lost Thunderbrew Recipe • Blackrock Depths" },
    [388] = { unlock = "Dungeon: The Stockade", summary = "The Color of Blood • The Stockade" },
    [92742] = { note = "First quest of the Toxic Soil chain." },
    [389] = { note = "Second required step leading to The Stockade Riots." },
    [5213] = { unlock = "Dungeon: Stratholme: Undead", reward = "Seal of the Dawn / Rune of the Dawn", summary = "The Active Agent • Stratholme: Undead" },
    [391] = { unlock = "Dungeon: The Stockade", note = "Part of the chain that begins with The Unsent Letter from Edwin VanCleef in The Deadmines.", summary = "The Stockade Riots • The Stockade" },
    [96771] = { unlock = "Dungeon: Krol'dok Stronghold", note = "Zalfan Moonshadow, a highborne among the Twilight's Hammer inside the stronghold: groups meet him after Tunk, on the way to the bridge.", summary = "Vengeance of the Highborne • Krol'dok Stronghold" },
    [94981] = { unlock = "Dungeon: Krol'dok Stronghold", reward = "Krol'dok Compound Key", note = "Keep any Krol'dok Moulding you loot: it starts the quest before this one.", summary = "Key Ingredients • Krol'dok Stronghold" },
    [5281] = { unlock = "Dungeon: Stratholme: Undead", note = "Introductory step leading to The Restless Souls.", summary = "The Restless Souls • Stratholme: Undead" },
    [96772] = { unlock = "Dungeon: Alcaz Prison", summary = "The Dragon's Journal • Alcaz Prison" },
    [92744] = { note = "Second quest of the Toxic Soil chain." },
    [4286] = { unlock = "Dungeon: Blackrock Depths", reward = "A Dingy Fanny Pack", note = "Dark Iron Fanny Packs drop from Dark Iron dwarves in BRD.", summary = "The Good Stuff • Blackrock Depths" },
    [94982] = { unlock = "Dungeon: Krol'dok Stronghold", reward = "Rock on Stick / Stick No Rock / Bigger Rock on Bigger Stick", summary = "Eye of Mugg • Krol'dok Stronghold" },
    [5341] = { unlock = "Dungeon: Scholomance", note = "The four deeds: Southshore in the first large chamber, Tarren Mill before the hatchlings, Brill by Ras Frostwhisper, Caer Darrow by Lord Alexei Barov. The follow-up The Last Barov sends you to kill the rival brother.", summary = "Barov Family Fortune • Scholomance" },
    [4322] = { unlock = "Dungeon: Blackrock Depths", note = "Escort Marshal Windsor through the prison. Clear the patrols first and have everyone ready before you start.", summary = "Jail Break! • Blackrock Depths" },
    [92489] = { unlock = "Dungeon: City of Dalaran", reward = "Violet Sash / Runebound Gloves", summary = "Power Overwhelming • City of Dalaran" },
    [94983] = { unlock = "Dungeon: Krol'dok Stronghold", summary = "Twilight Mementos • Krol'dok Stronghold" },
    [4362] = { unlock = "Dungeon: Blackrock Depths", reward = "Magni's Will / Songstone of Ironforge", note = "Keep Princess Moira alive and speak to her after Emperor Thaurissan dies. Her The Princess's Surprise sends you back to Magni for the reward.", summary = "The Fate of the Kingdom • Blackrock Depths" },
    [7463] = { unlock = "Dungeon: Dire Maul: East", note = "Mage class quest. Lydros is in the Athenaeum (North/West); Hydrospawn Essence drops from Hydrospawn in East. Rewards Conjure Water (Rank 7).", summary = "Arcane Refreshment • Dire Maul: East" },
    [2201] = { unlock = "Dungeon: Uldaman", note = "The sapphire drops from Grimlok.", summary = "Find the Gems • Uldaman" },
    [96774] = { unlock = "Dungeon: The Drowned City", summary = "Ancient Gurubashi Idol • The Drowned City" },
    [7483] = { unlock = "Dungeon: Dire Maul: North", reward = "Arcanum of Rapidity", note = "Repeatable. Needs your faction's Elven Legends turned in first.", summary = "Libram of Rapidity • Dire Maul: North" },
    [94984] = { unlock = "Dungeon: Krol'dok Stronghold", reward = "Twilight Initiate's Belt / Torn Cultist Cloak", summary = "Tome of Twilight • Krol'dok Stronghold" },
    [96135] = { note = "Elite, level 40: bring a group. At the steam pools in Thousand Needles, stand on the rune circle and use the Corrupted Totems. Waves of elementals come, then an elite quilboar and the Ravaging Tempest, which drops the Eye of the Tempest for every Shaman on the quest." },
    [7499] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Warrior class book. Click the book to start the quest.", summary = "Codex of Defense • Dire Maul: North" },
    [7503] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Hunter class book. Click the book to start the quest.", summary = "The Greatest Race of Hunters • Dire Maul: North" },
    [7507] = { unlock = "Dungeon: Dire Maul: North", note = "Warriors and Paladins. Lydros then gives The Forging of Quel'Serrar, which is finished in Onyxia's Lair.", summary = "Nostro's Compendium • Dire Maul: North" },
    [96391] = { note = "The Dark Iron Map starts this quest and leads directly into Old Ironforge Incursion." },
    [92747] = { note = "The supplies are found in the caves leading toward the Deadmines entrance." },
    [8948] = { note = "Part of Anthion Harmon's Dungeon Set 2 quests: the earlier ones unlock this step." },
    [96264] = { note = "The Razorfen Kraul step. Call of Air (from Eldrun Stormbreaker in Ironforge) sends you to Veyric. Alliance Shamans can share this quest." },
    [5525] = { unlock = "Dungeon: Dire Maul: North", note = "Get a Gordok Shackle Key from the North ogres and free Knot; his cache has loot.", summary = "Free Knot! • Dire Maul: North" },
    [5529] = { unlock = "Dungeon: Scholomance", note = "Kill 20 Plagued Hatchlings. After turning this in, hatchlings can drop Healthy Dragon Scales, which start a repeatable turn-in to Betina.", summary = "Plagued Hatchlings • Scholomance" },
    [6564] = { unlock = "Dungeon: Blackfathom Deeps", summary = "Allegiance to the Old Gods • Blackfathom Deeps" },
    [92748] = { note = "Begins the explosives portion of the Toxic Soil chain." },
    [2279] = { unlock = "Dungeon: Uldaman", reward = "Superior Healing Potion / Greater Mana Potion / Thawpelt Sack", note = "Speak with the Stone Watcher and activate the discs first. Then hand the reward voucher to Dinita Stonemantle in the Ironforge vault and choose your reward.", summary = "The Platinum Discs • Uldaman" },
    [2283] = { unlock = "Dungeon: Uldaman", summary = "Necklace Recovery • Uldaman" },
    [7643] = { unlock = "Dungeon: Dire Maul: West", note = "Paladin charger quest. Kill Tendris Warpwood, then feed the Ancient Equine Spirit and give it the Arcanite Barding. Bring the Manna-Enriched Horse Feed from Merideth Carlson in Southshore.", summary = "Ancient Equine Spirit • Dire Maul: West" },
    [7647] = { unlock = "Dungeon: Scholomance", note = "Paladin charger quest. Clear Rattlegore's basement in the Great Ossuary, use the Divination Scryer and defeat the spirits and Death Knight Darkreaver.", summary = "Judgment and Redemption • Scholomance" },
    [98823] = { unlock = "Dungeon: Excavation Site: Wetlands", reward = "Heavehammer / Healer's Staff / Furs of the Earthen Ring", summary = "Earthen Echo • Excavation Site: Wetlands" },
    [92749] = { note = "Rough Dynamite can be crafted, traded or bought from the auction house." },
    [7703] = { unlock = "Dungeon: Dire Maul: North", reward = "Gordok's Handguards / Gordok's Gauntlets / Gordok's Gloves / Gordok's Handwraps", note = "Talk to a friendly Captain Kromcrush after you become the Gordok king. The Gauntlet of Gordok Might is in a chest near Prince Tortheldrin in Dire Maul West.", summary = "Unfinished Gordok Business • Dire Maul: North" },
    [8253] = { unlock = "Dungeon: Sunken Temple", reward = "Glacial Spike / Arcane Crystal Pendant / Fire Ruby", note = "Mage class quest. The Arcane Shard drops from Morphaz.", summary = "Destroy Morphaz • Sunken Temple" },
    [98824] = { unlock = "Dungeon: Excavation Site: Wetlands", reward = "Explorer's League Dustcover / Healer's Staff / Heavehammer", summary = "Prehistoric Prism • Excavation Site: Wetlands" },
    [92750] = { note = "You need a remote detonator for the planned explosion." },
    [2339] = { unlock = "Dungeon: Uldaman", note = "The sapphire drops from Grimlok and the power source from Archaedas.", summary = "Find the Gems and Power Source • Uldaman" },
    [96395] = { unlock = "Dungeon: Hall of Thanes", reward = "Catacomb Cloak / Deepgrave Trousers", summary = "An Ancient Grudge • Hall of Thanes" },
    [5725] = { unlock = "Dungeon: Ragefire Chasm", reward = "Ghastly Trousers / Dredgemire Leggings / Gargoyle Leggings", summary = "The Power to Destroy... • Ragefire Chasm" },
    [8413] = { unlock = "Dungeon: Sunken Temple", reward = "Azurite Fists / Enamored Water Spirit / Wildstaff", note = "Shaman class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.", summary = "Da Voodoo • Sunken Temple" },
    [5761] = { unlock = "Dungeon: Ragefire Chasm", summary = "Slaying the Beast • Ragefire Chasm" },
    [4742] = { unlock = "Dungeon: Lower Blackrock Spire", summary = "Seal of Ascension • Lower Blackrock Spire" },
    [1701] = { note = "The Razorfen Kraul step." },
    [1702] = { note = "Furen rewards you with a shield, Furen's Favor." },
    [4766] = { unlock = "Dungeon: Upper Blackrock Spire", note = "Introductory step leading to Doomrigger's Clasp.", summary = "Mayara Brightwing • Upper Blackrock Spire" },
    [92432] = { note = "Introductory quest leading to Heart of Disruption and Starving Arcane." },
    [214] = { unlock = "Dungeon: The Deadmines", reward = "Solid Shortblade / Scrimshaw Dagger / Piercing Axe / Monastic Hammer", note = "Requires the Defias Brotherhood escort step.", summary = "Red Silk Bandanas • The Deadmines" },
    [92752] = { note = "Final preparation before Destruction in Deadmines." },
    [3446] = { unlock = "Dungeon: Sunken Temple", note = "Examine the Altar of Hakkar in the temple basement. Started from Marvon Rivetseeker after The Stone Circle.", summary = "Into the Depths • Sunken Temple" },
    [92753] = { unlock = "Dungeon: The Deadmines", summary = "Destruction in Deadmines • The Deadmines" },
    [4862] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Smolderweb Carrier", note = "Spire Spider Eggs are in the spider tunnels.", summary = "En-Ay-Es-Tee-Why • Lower Blackrock Spire" },
    [4866] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Ragged John's Neverending Cup", note = "Get poisoned by Mother Smolderweb and reach Ragged John while still poisoned. Don't let anyone cleanse it.", summary = "Mother's Milk • Lower Blackrock Spire" },
    [96078] = { unlock = "Dungeon: The Drowned City", reward = "Ceremonial Mallet / Sacrificial Sword / I'lalai Flayer", summary = "A Tale Spun Around the Fire • The Drowned City" },
    [275] = { note = "Final required step before Horrors in the Highland." },
    [95647] = { note = "Required before Heartwoven." },
    [870] = { note = "Investigate the fissure beneath the Forgotten Pools." },
    [1740] = { unlock = "Dungeon: Shadowfang Keep", reward = "Orb of Soran'ruk / Staff of Soran'ruk", note = "Warlock class quest. The fragments come from Shadowfang Keep and Blackfathom Deeps.", summary = "The Orb of Soran'ruk • Shadowfang Keep" },
    [2864] = { unlock = "Dungeon: Zul'Farrak", note = "Introductory step leading to Scarab Shells.", summary = "Tran'rek • Zul'Farrak" },
    [5961] = { unlock = "Dungeon: Stratholme: Undead", note = "Introductory step leading to Ramstein.", summary = "The Champion of the Banshee Queen • Stratholme: Undead" },
    [1221] = { unlock = "Dungeon: Razorfen Kraul", summary = "Blueleaf Tubers • Razorfen Kraul" },
    [880] = { note = "Completing Altered Beings unlocks Hamuul Runetotem." },
    [4974] = { unlock = "Dungeon: Upper Blackrock Spire", reward = "Mark of Tyranny / Eye of the Beast / Blackhand's Breadth", summary = "For The Horde! • Upper Blackrock Spire" },
    [7028] = { unlock = "Dungeon: Maraudon", reward = "Acumen Robes / Sprightring Helm / Relentless Chain / Hulkstone Pauldrons", note = "Any Maraudon creature can drop the Theradric Crystal Carvings.", summary = "Twisted Evils • Maraudon" },
    [96016] = { note = "Final step. Choose Rage of the Storm, Lightning's Grasp or Tidebringer's Claw; Alliance Shamans also get Elementalist's Guard." },
    [7044] = { unlock = "Dungeon: Maraudon", note = "The Celebrian Rod drops from Noxxion and the Celebrian Diamond from Lord Vyletongue.", summary = "Legends of Maraudon • Maraudon" },
    [3528] = { unlock = "Dungeon: Sunken Temple", reward = "Avenguard Helm / Lifeforce Dirk / Gemburst Circlet", note = "Fill the Egg of Hakkar from the Hakkari Bloodkeepers to summon the Avatar of Hakkar.", summary = "The God Hakkar • Sunken Temple" },
    [7064] = { unlock = "Dungeon: Maraudon", reward = "Thrash Blade / Resurgence Rod / Verdant Keeper's Aim", note = "Kill Princess Theradras in the inner cavern.", summary = "Corruption of Earth and Seed • Maraudon" },
    [7068] = { unlock = "Dungeon: Maraudon", reward = "Zealous Shadowshard Pendant / Prodigious Shadowshard Pendant", note = "Shadowshard elementals in the outer purple-crystal caves. It can be done without entering the instance.", summary = "Shadowshard Fragments • Maraudon" },
    [877] = { note = "The next required oasis investigation after The Forgotten Pools." },
    [2930004] = { note = "On Electrocutioner 6000's platform." },
    [1100] = { note = "Required before The Crone of the Kraul." },
    [95697] = { unlock = "Dungeon: Excavation Site: Wetlands", reward = "Satchel of Potions / Serrated Raptor Claw", note = "Thicket Raptor Meat comes from the Thicket raptors (Thicket Lurker, Thicket Hunter, Thicket Matriarch) in Stalker's Thicket, the area of Shadetooth.", summary = "Changing Tastes • Excavation Site: Wetlands" },
    [9053] = { unlock = "Dungeon: Sunken Temple", reward = "Grizzled Pelt / Forest's Embrace / Moonshadow Stave", note = "Druid class quest. The Putrid Vine drops from Atal'alarion in the temple basement.", summary = "A Better Ingredient • Sunken Temple" },
    [865] = { note = "Required before Smart Drinks becomes available." },
    [5518] = { unlock = "Dungeon: Dire Maul: North", reward = "Gordok Ogre Suit", note = "Bring 4 Bolts of Runecloth, 8 Rugged Leather, 2 Rune Threads and 1 Ogre Tannin (basket on the upper level beyond Knot). Make any suits and learn the pattern before freeing Knot, because he leaves.", summary = "The Gordok Ogre Suit • Dire Maul: North" },
    [1490] = { note = "Nara Wildmane is the final prerequisite before Leaders of the Fang becomes available." },
    [155] = { note = "Final prerequisite before the dungeon step of The Defias Brotherhood." },
    [95250] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Monstrous Cleaver / Grave Shroud / Slain Baron's Signet", summary = "Abominable Creatures • Ruins of Lordaeron" },
    [92751] = { note = "Returns the remote detonator to the engineer." },
    [8151] = { unlock = "Dungeon: Sunken Temple", note = "Introductory step leading to The Green Drake.", summary = "The Hunter's Charm • Sunken Temple" },
    [78307] = { unlock = "Dungeon: Shadowfang Keep", reward = "Pyrewood Signet Ring", note = "Rogue class quest. C's letter arrives at level 20 in a capital city; take the job at the Dead Drop near Pyrewood Village. Keep a bag slot free.", summary = "The Horn of Xelthos • Shadowfang Keep" },
    [97288] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Monstrous Cleaver / Grave Shroud / Slain Baron's Signet", note = "The item choice is awarded on the follow-up Unending Torment step in Undercity.", summary = "Unending Torment • Ruins of Lordaeron" },
    [6141] = { unlock = "Dungeon: Scarlet Monastery: Armory", note = "Introductory step leading to In the Name of the Light.", summary = "Brother Anton • Scarlet Monastery: Armory" },
    [5122] = { unlock = "Dungeon: Stratholme: Living", note = "Malor's Strongbox in the Scarlet Bastion holds the medallion. Give it to Aurius in the chapel before fighting the Baron.", summary = "The Medallion of Faith • Stratholme: Living" },
    [1806] = { unlock = "Dungeon: Shadowfang Keep", reward = "Verigan's Fist", note = "Paladin class quest for humans and dwarves. In this dungeon: Jordan's Smithing Hammer is picked up from the object Jordan's Hammer in the courtyard. The other parts are Whitestone Oak Lumber (The Deadmines), the Kor Gem (Blackfathom Deeps) and Jordan's ore shipment (Loch Modan).", summary = "The Test of Righteousness • Shadowfang Keep" },
    [4123] = { unlock = "Dungeon: Blackrock Depths", note = "The Heart of the Mountain is in the vault safe after the Dark Keepers.", summary = "The Heart of the Mountain • Blackrock Depths" },
    [8254] = { unlock = "Dungeon: Sunken Temple", note = "Introductory step leading to Blood of Morphaz.", summary = "Cenarion Aid • Sunken Temple" },
    [4143] = { unlock = "Dungeon: Sunken Temple", note = "Atal'ai Haze drops from the temple's worms, lurkers and oozes.", summary = "Haze of Evil • Sunken Temple" },
    [2947] = { note = "Alliance step required before Gnome Improvement." },
    [97130] = { unlock = "Dungeon: The Drowned City", summary = "Ancient Gurubashi Secrets • The Drowned City" },
    [153] = { note = "Required before Red Silk Bandanas." },
    [96403] = { unlock = "Dungeon: Hall of Thanes", reward = "Dwarven Tome / Tomb Robber's Gloves", summary = "Important Heirlooms • Hall of Thanes" },
    [5214] = { unlock = "Dungeon: Stratholme: Living", reward = "Smokey's Lighter", note = "Newer Classic records call him Ezra Grimm. Clear the smoke shop, touch the tobacco box and kill the shopkeeper.", summary = "The Great Fras Siabi • Stratholme: Living" },
    [3636] = { unlock = "Dungeon: Razorfen Downs", reward = "Amberglow Talisman / Purified Ring", summary = "Bring the Light • Razorfen Downs" },
    [8422] = { unlock = "Dungeon: Sunken Temple", reward = "Soul Harvester / Abyss Shard / Robes of Servitude", note = "Warlock class quest. Needs 2 amber, 2 blue and 2 green Voodoo Feathers from the six troll guardians: Gasher, Mijan, Zolo, Hukku, Zul'Lor and Loro.", summary = "Trolls of a Feather • Sunken Temple" },
    [1824] = { note = "Your warrior trainer (Sorek in Orgrimmar) sends you to Ruga first. Timed: 30 minutes. The antennae come from the silithids at the Field of Giants, south of Camp Taurajo." },
    [914] = { unlock = "Dungeon: Wailing Caverns", reward = "Crescent Staff / Wingblade / Hammerbone", note = "Requires the Barrens oasis quest chain. Complete The Barrens Oases, The Forgotten Pools, The Stagnant Oasis and Altered Beings, then Hamuul Runetotem and Nara Wildmane before Leaders of the Fang becomes available.", summary = "Leaders of the Fang • Wailing Caverns" },
    [95189] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Small Sack of Gems", note = "Community reports indicate the Crest can spawn at one of several locations inside the dungeon. Reported spots include upper floors of towers, side/crypt rooms near The Baron, and the area around Bjork.", summary = "Crest of Lordaeron • Ruins of Lordaeron" },
    [303] = { note = "Complete The Dark Iron War to unlock The Fury Runs Deep." },
    [5282] = { unlock = "Dungeon: Stratholme: Undead", reward = "Testament of Hope", summary = "The Restless Souls • Stratholme: Undead" },
    [4263] = { unlock = "Dungeon: Blackrock Depths", reward = "Sunborne Cape / Nightfall Gloves / Crypt Demon Bracers / Stalwart Clutch", note = "Kill Lord Incendius at the Black Anvil inside BRD.", summary = "Incendius! • Blackrock Depths" },
    [277] = { note = "Third required step before Horrors in the Highland." },
    [4132] = { unlock = "Dungeon: Blackrock Depths", note = "Needs both KILL ON SIGHT quests and the Grark Lorkrub escort first.", summary = "Operation: Death to Angerforge • Blackrock Depths" },
    [1838] = { note = "The Razorfen Kraul step." },
    [94998] = { unlock = "Dungeon: Krol'dok Stronghold", reward = "Curio-Adorned Necklace", summary = "Curios of Curiosity • Krol'dok Stronghold" },
    [4295] = { unlock = "Dungeon: Blackrock Depths", note = "Buy Dark Iron Ale Mugs from Plugger Spazzring and keep handing them to Rocknot. The drunken event opens the bar route and can turn Phalanx hostile.", summary = "Rocknot's Ale • Blackrock Depths" },
    [1848] = { note = "Final step. Rewards Brutal Hauberk." },
    [463] = { note = "First required step before Horrors in the Highland." },
    [1699] = { note = "Your warrior trainer (Wu Shen in Stormwind, or the trainers in Ironforge and Darnassus) sends you to Yorus Barleybrew in Lakeshire first. The run is timed." },
    [5382] = { unlock = "Dungeon: Scholomance", summary = "Doctor Theolen Krastinov, the Butcher • Scholomance" },
    [97173] = { unlock = "Dungeon: Blackmaw Hold", summary = "Blackmaw Magic • Blackmaw Hold" },
    [82084] = { unlock = "Dungeon: Zul'Farrak", reward = "Personal Spellbook", note = "Mage class quest.", summary = "A Lesson in Literacy • Zul'Farrak" },
    [2280] = { unlock = "Dungeon: Uldaman", reward = "Superior Healing Potion / Greater Mana Potion / Thawpelt Sack", note = "Speak with the Stone Watcher and activate the discs first. Then hand the reward voucher to Bena Winterhoof in Thunder Bluff and choose your reward.", summary = "The Platinum Discs • Uldaman" },
    [5250] = { unlock = "Dungeon: Dire Maul: West", note = "Introductory step leading to Fragments of the Past.", summary = "Starfall • Dire Maul: West" },
    [5726] = { note = "First required Hidden Enemies step for the Ragefire Chasm chain." },
    [92401] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Edward's Knife / Tabitha's Cuffs", summary = "A Frightened Request • Ruins of Lordaeron" },
    [1199] = { unlock = "Dungeon: Blackfathom Deeps", reward = "Nimbus Boots / Heartwood Girdle / Silvered Gauntlets", summary = "Twilight Falls • Blackfathom Deeps" },
    [7484] = { unlock = "Dungeon: Dire Maul: North", reward = "Arcanum of Focus", note = "Repeatable. Needs your faction's Elven Legends turned in first.", summary = "Libram of Focus • Dire Maul: North" },
    [7488] = { unlock = "Dungeon: Dire Maul: East", reward = "Lorespinner", note = "The web drops from Lethtendris.", summary = "Lethtendris's Web • Dire Maul: East" },
    [7492] = { unlock = "Dungeon: Dire Maul: East", note = "Introductory step leading to Lethtendris's Web.", summary = "Camp Mojache • Dire Maul: East" },
    [387] = { unlock = "Dungeon: The Stockade", summary = "Quell the Uprising • The Stockade" },
    [7500] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Mage class book. Click the book to start the quest.", summary = "The Arcanist's Cookbook • Dire Maul: North" },
    [7504] = { unlock = "Dungeon: Dire Maul: North", reward = "Royal Seal of Eldre'Thalas", note = "Priest class book. Click the book to start the quest.", summary = "Holy Bologna: What the Light Won't Tell You • Dire Maul: North" },
    [5466] = { unlock = "Dungeon: Scholomance", reward = "Warblade of Caer Darrow / Crown of Caer Darrow / Darrowspike / Darrowshire Strongguard", note = "Use the Soulbound Keepsake on Ras Frostwhisper to make him human, then kill him and bring back his human head.", summary = "The Lich, Ras Frostwhisper • Scholomance" },
    [6565] = { unlock = "Dungeon: Blackfathom Deeps", reward = "Band of the Fist / Chestnut Mantle", note = "Follows the Damp Note version of Allegiance to the Old Gods.", summary = "Allegiance to the Old Gods • Blackfathom Deeps" },
    [5212] = { unlock = "Dungeon: Stratholme: Living", note = "Any undead in Stratholme can drop Plagued Flesh Samples.", summary = "The Flesh Does Not Lie • Stratholme: Living" },
    [6521] = { unlock = "Dungeon: Razorfen Kraul", reward = "Skullbreaker / Nail Spitter / Zealot's Robe / Cultist's Chestguard", summary = "An Unholy Alliance • Razorfen Kraul" },
    [1101] = { unlock = "Dungeon: Razorfen Kraul", reward = "Berylline Pads / Stonefist Girdle / Marbled Buckler", summary = "The Crone of the Kraul • Razorfen Kraul" },
    [5526] = { unlock = "Dungeon: Dire Maul: East", reward = "Milli's Shield / Milli's Lexicon", note = "Kill Alzzin the Wildshaper, pick up a Felvine Shard near the vine and seal it in the Reliquary of Purity.", summary = "Shards of the Felvine • Dire Maul: East" },
    [2769] = { unlock = "Dungeon: Zul'Farrak", note = "Introductory step leading to Gahz'rilla.", summary = "The Brassbolts Brothers • Zul'Farrak" },
    [6561] = { unlock = "Dungeon: Blackfathom Deeps", reward = "Gravestone Scepter / Arctic Buckler / Dark Ritual Leggings / Cultist's Armguards", summary = "Blackfathom Villainy • Blackfathom Deeps" },
    [6569] = { unlock = "Dungeon: Upper Blackrock Spire", note = "Part of the Horde Onyxia chain. Black Dragonspawn Eyes drop from the dragonspawn in UBRS.", summary = "Oculus Illusions • Upper Blackrock Spire" },
    [7629] = { unlock = "Dungeon: Scholomance", note = "Warlock dreadsteed quest. Release the Imp in a Jar at the alchemy lab in Ras Frostwhisper's room and wait for the parchment.", summary = "Imp Delivery • Scholomance" },
    [3802] = { unlock = "Dungeon: Blackrock Depths", reward = "Shadowforge Key", note = "Speak to Franclorn's ghost while dead. Kill Fineous Darkvire for Ironfel and place it on Franclorn's monument by the Ring of Law. The Shadowforge Key opens shortcuts inside BRD.", summary = "Dark Iron Legacy • Blackrock Depths" },
    [7604] = { unlock = "Dungeon: Blackrock Depths", reward = "Plans: Sulfuron Hammer", note = "Blacksmithing. Bring a Sulfuron Ingot (Golemagg, Molten Core) to Lokhtos in the Grim Guzzler to get the contract, then hand it back for the Sulfuron Hammer plans.", summary = "A Binding Contract • Blackrock Depths" },
    [96984] = { unlock = "Dungeon: City of Dalaran", reward = "Battle Spaulders / Enchanted Sandals / Striking Staff", note = "Horde Dalaran attunement. Stone Tokens and Bracers of Binding can be done alongside the chain, but they are optional and are not required for attunement.", summary = "Heart of Disruption • City of Dalaran" },
    [7631] = { unlock = "Dungeon: Dire Maul: West", note = "Warlock dreadsteed quest. After Immol'thar dies, run the ritual in his prison with J'eevee's Jar, the Black Lodestone and the Xorothian Glyphs. Bring Soul Shards.", summary = "Dreadsteed of Xoroth • Dire Maul: West" },
    [92745] = { note = "Investigate whether Westfall's mines are causing the contamination." },
    [5102] = { unlock = "Dungeon: Upper Blackrock Spire", reward = "Mark of Tyranny / Eye of the Beast / Blackhand's Breadth", note = "Kill General Drakkisath at the end of UBRS.", summary = "General Drakkisath's Demise • Upper Blackrock Spire" },
    [79358] = { note = "Twisted Totems only drop while this quest is in your log. Water: Mirefin murlocs, northeast coast of Dustwallow Marsh. Air: Maraudine centaurs, Desolace. Earth: Lost Ones, Swamp of Sorrows. Fire: Dustbelcher ogres and Stonevault troggs, Badlands." },
    [93404] = { unlock = "Dungeon: Maraudon", reward = "Overgrown Cuffs / Thornplated Cord", note = "The quest tracks two objectives: 1 Vial of Earth Song Water and Woodwyrd extinguished. Complete Word of the Woods to encounter Woodwyrd at the Forlorn Gardens. Recover the vial inside Maraudon, then return to Woodwyrd.", summary = "Rot and Regret • Maraudon" },
    [92458] = { unlock = "Dungeon: City of Dalaran", reward = "Spellguard Pauldrons / Renewing Footpads / Defender of Dalaran", summary = "Heart of Disruption • City of Dalaran" },
    [959] = { unlock = "Dungeon: Wailing Caverns", summary = "Trouble at the Docks • Wailing Caverns" },
    [95770] = { note = "The cave is in Sunken Hollow, underwater around 21, 28: the entrance to the Drowned City." },
    [7668] = { unlock = "Dungeon: Scholomance", reward = "Helm of Latent Power", note = "Shaman quest. Clear Rattlegore's basement, use the scryer and defeat Death Knight Darkreaver; return his head.", summary = "The Darkreaver Menace • Scholomance" },
    [65] = { note = "First step of the required Defias Brotherhood chain." },
    [2930001] = { note = "Random drop; you usually get it during your first clear of the outer area." },
    [2930003] = { note = "Inside the instance, in the Dormitory." },
    [962] = { unlock = "Dungeon: Wailing Caverns", reward = "Apothecary Gloves / Heat Resistant Mitts / Safety Boots", summary = "Serpentbloom • Wailing Caverns" },
    [2930005] = { note = "Take the elevator down; the terminal is in the first passage on the right." },
    [95195] = { unlock = "Dungeon: Ruins of Lordaeron", reward = "Duty Bound Leggings / Remembrance Armor", summary = "Bloodied Insignia • Ruins of Lordaeron" },
    [2842] = { note = "Required before Gnomer-gooooone!" },
    [4146] = { unlock = "Dungeon: Sunken Temple", note = "Atal'ai Haze drops from the temple's worms, lurkers and oozes.", summary = "Zapper Fuel • Sunken Temple" },
    [3907] = { unlock = "Dungeon: Blackrock Depths", note = "Kill Lord Incendius at the Black Anvil inside BRD and bring back the Tablet of Kurniya.", summary = "Disharmony of Fire • Blackrock Depths" },
    [484] = { note = "Required before Highland Hides. Daily Delivery is not required in Forever." },
    [2841] = { unlock = "Dungeon: Gnomeregan", reward = "Civinad Robes / Triprunner Dungarees / Dual Reinforced Leggings", summary = "Rig Wars • Gnomeregan" },
    [1782] = { note = "Final step. Rewards Fire Hardened Hauberk." },
    [96986] = { unlock = "Dungeon: City of Dalaran", reward = "Gravewalker Boots / Undead Knight's Bracers", summary = "The Grave Knight • City of Dalaran" },
    [4701] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Astoria Robes / Traphook Jerkin / Jadescale Breastplate", note = "Kill Halycon, the worg den mother. Be ready for Gizrul the Slavener, who comes for you right after.", summary = "Put Her Down • Lower Blackrock Spire" },
    [1053] = { unlock = "Dungeon: Scarlet Monastery: Armory", reward = "Sword of Serenity / Bonebiter / Black Menace / Orb of Lorica", note = "Herod is in the Armory; Loksey in the Library; Mograine and Whitemane in the Cathedral.", summary = "In the Name of the Light • Scarlet Monastery: Armory" },
    [971] = { unlock = "Dungeon: Blackfathom Deeps", reward = "Sustaining Ring", note = "The Lorgalis Manuscript is inside a Pitted Iron Chest underwater in the Pool of Ask'ar, in the northern alcove just past Ghamoo-ra's turtle room.", summary = "Knowledge in the Deeps • Blackfathom Deeps" },
    [2861] = { unlock = "Dungeon: Zul'Farrak", note = "Introductory step leading to Tiara of the Deep.", summary = "Tabetha's Task • Zul'Farrak" },
    [2865] = { unlock = "Dungeon: Zul'Farrak", summary = "Scarab Shells • Zul'Farrak" },
    [4735] = { unlock = "Dungeon: Upper Blackrock Spire", note = "Using the module on the eggs in the Rookery can hatch whelps.", summary = "Egg Collection • Upper Blackrock Spire" },
    [8415] = { unlock = "Dungeon: Sunken Temple", note = "Introductory step leading to Forging the Mightstone.", summary = "Chillwind Point • Sunken Temple" },
    [1951] = { unlock = "Dungeon: Scarlet Monastery: Library", note = "Mage class quest.", summary = "Rituals of Power • Scarlet Monastery: Library" },
    [96987] = { unlock = "Dungeon: City of Dalaran", reward = "City of Dalaran Rare Gear", summary = "Opportunistic Education • City of Dalaran" },
    [4743] = { unlock = "Dungeon: Upper Blackrock Spire", reward = "Seal of Ascension", note = "Take the Unforged Seal and the Orb of Draconic Energy to Emberstrife in the Wyrmbog, Dustwallow Marsh. The forged seal opens the UBRS door.", summary = "Seal of Ascension • Upper Blackrock Spire" },
    [1956] = { unlock = "Dungeon: Uldaman", note = "Mage class quest. The Obsidian Sentinel guards the back entrance of Uldaman. Continues with Mana Surges for the Celestial Orb or Celestial Stave.", summary = "Power in Uldaman • Uldaman" },
    [5262] = { unlock = "Dungeon: Stratholme: Living", note = "Hand in The Archivist first, or Balnazzar's head will not start this quest.", summary = "The Truth Comes Crashing Down • Stratholme: Living" },
    [4771] = { unlock = "Dungeon: Scholomance", reward = "Windreaper / Dancing Sliver", note = "Use Dawn's Gambit in the Viewing Room and defeat Vectus.", summary = "Dawn's Gambit • Scholomance" },
    [7848] = { unlock = "Dungeon: Blackrock Depths", note = "The Core Fragment is on the rock beside the Molten Core portal deep inside BRD. Unlocks Lothos's teleport to Molten Core.", summary = "Attunement to the Core • Blackrock Depths" },
    [78699] = { unlock = "Dungeon: Scarlet Monastery: Graveyard", reward = "Ruby-Adorned Blade", note = "Rogue class quest after The Horn of Xelthos; C's next letter (around level 30) sends you back to the Dead Drop. Wear the Scarlet Initiate's Uniform in every wing: stealth or attacking removes it.", summary = "The Eye of Bhossca • Scarlet Monastery: Graveyard" },
    [9063] = { unlock = "Dungeon: Sunken Temple", note = "Introductory step leading to A Better Ingredient.", summary = "Torwa Pathfinder • Sunken Temple" },
    [17] = { unlock = "Dungeon: Uldaman", reward = "Restorative Potion", summary = "Uldaman Reagent Run • Uldaman" },
    [96988] = { unlock = "Dungeon: City of Dalaran", reward = "Unstable Power Core / Construct Cloak", summary = "Source of Power • City of Dalaran" },
    [96776] = { unlock = "Dungeon: Maraudon", note = "Beyond Earth Song Falls, find the chamber of brilliant white crystals guarded by giants. Retrieve An'she's Radiance from the crystal near the highest part of the chamber. Rewards 300 Earthen Ring and 200 Thunder Bluff reputation.", summary = "An'she's Radiance • Maraudon" },
    [96393] = { unlock = "Dungeon: Hall of Thanes", reward = "Calibrated Blunderbuss / Ironforge Greathammer / Deepblaze", note = "The chain begins by dropping Dark Iron Map from Dark Iron Spies in Dun Morogh.", summary = "Old Ironforge Incursion • Hall of Thanes" },
    [2929] = { unlock = "Dungeon: Gnomeregan", reward = "Civinad Robes / Triprunner Dungarees / Dual Reinforced Leggings", summary = "The Grand Betrayal • Gnomeregan" },
    [96394] = { unlock = "Dungeon: Hall of Thanes", reward = "Dusty Belt / Cryptwalker Bracers", summary = "The Restless Dead • Hall of Thanes" },
    [95646] = { unlock = "Dungeon: Excavation Site: Wetlands", reward = "Ironwood Destroyer / Curl of Life / Hornbeam Heft", summary = "Horrors in the Highland • Excavation Site: Wetlands" },
    [8233] = { unlock = "Dungeon: Sunken Temple", note = "Introductory step leading to The Azure Key.", summary = "A Simple Request • Sunken Temple" },
    [95788] = { unlock = "Dungeon: The Drowned City", summary = "Magics of the Drowned City • The Drowned City" },
    [6921] = { unlock = "Dungeon: Blackfathom Deeps", note = "The Fathom Stone is also associated with the optional Baron Aquanis encounter.", summary = "Amongst the Ruins • Blackfathom Deeps" },
    [4867] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Prismcharm", note = "Bring Highlord Omokk's Head and a Roughshod Pike to Urok's Tribute Pile beyond the spiders to start the waves.", summary = "Urok Doomhowl • Lower Blackrock Spire" },
    [2949] = { note = "Horde step required before Nogg's Ring Redo." },
    [2951] = { unlock = "Dungeon: Gnomeregan", reward = "Sparklematic-Wrapped Box", summary = "The Sparklematic 5200! • Gnomeregan" },
    [276] = { note = "Second required step before Horrors in the Highland." },
    [2202] = { unlock = "Dungeon: Uldaman", reward = "Restorative Potion", summary = "Uldaman Reagent Run • Uldaman" },
    [3982] = { unlock = "Dungeon: Blackrock Depths", note = "Open his cell with the Prison Cell Key from High Interrogator Gerstahn, then defend him.", summary = "What Is Going On? • Blackrock Depths" },
    [4903] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Wyrmthalak's Shackles / Omokk's Girth Restrainer / Halycon's Muzzle / Vosh'gajin's Strand / Voone's Vice Grips", note = "Talk to Goretooth to receive his Command item and click it to start the quest. The Important Blackrock Documents spawn near the three generals.", summary = "Warlord's Command • Lower Blackrock Spire" },
    [95775] = { unlock = "Dungeon: The Drowned City", summary = "The Drowned City • The Drowned City" },
    [2843] = { unlock = "Dungeon: Gnomeregan", reward = "Goblin Transponder", summary = "Gnomer-gooooone! • Gnomeregan" },
    [142] = { note = "The messenger travels the roads between Moonbrook, Gold Coast Quarry and Jangolode Mine." },
    [95789] = { unlock = "Dungeon: The Drowned City", reward = "Rusted Troll War Belt / Saltseer's Helm", summary = "Shady Saltseers • The Drowned City" },
    [6981] = { unlock = "Dungeon: Wailing Caverns", note = "The direct quest has no item reward; unlocks follow-up quest In Nightmares for dungeon gear.", summary = "The Glowing Shard • Wailing Caverns" },
    [1475] = { unlock = "Dungeon: Sunken Temple", reward = "Guardian Talisman", note = "Collect 10 Atal'ai Tablets around the temple; tablets in the outer temple also count.", summary = "Into The Temple of Atal'Hakkar • Sunken Temple" },
    [141] = { note = "Returns Shaw's findings about Edwin VanCleef to Gryan." },
    [2991] = { unlock = "Dungeon: Zul'Farrak", note = "The medallion drops from Nekrum Gutchewer.", summary = "Nekrum's Medallion • Zul'Farrak" },
    [5089] = { unlock = "Dungeon: Lower Blackrock Spire", note = "Leads to General Drakkisath's Demise in Upper Blackrock Spire.", summary = "General Drakkisath's Command • Lower Blackrock Spire" },
    [1160] = { note = "The book is inside Scarlet Monastery: Library." },
    [4024] = { unlock = "Dungeon: Blackrock Depths", note = "Show Cyrus a Black Dragonflight Molt first (A Taste of Flame, or kill the drake he summons). Then kill Bael'Gar and use the Altered Black Dragonflight Molt on his remains to collect the Encased Fiery Essence.", summary = "A Taste of Flame • Blackrock Depths" },
    [95776] = { unlock = "Dungeon: The Drowned City", reward = "Tidesoaked Leggings / Naga Priestess's Mantle", note = "Commander Aggro'gosh offers it once Enemies in the Water and Locating the Lost City (Kin'weelay) are both handed in.", summary = "The Only Good Brinescale... • The Drowned City" },
    [7029] = { unlock = "Dungeon: Maraudon", reward = "Woodseed Hoop / Sagebrush Girdle / Branchclaw Gauntlets", note = "Fill the Coated Cerulean Vial at the orange crystal pool in the outer caves, then use it on Vylestem Vines inside (orange side) and kill the Noxxious Scions to heal 8 plants.", summary = "Vyletongue Corruption • Maraudon" },
    [7041] = { unlock = "Dungeon: Maraudon", reward = "Woodseed Hoop / Sagebrush Girdle / Branchclaw Gauntlets", note = "Fill the Coated Cerulean Vial at the orange crystal pool in the outer caves, then use it on Vylestem Vines inside (orange side) and kill the Noxxious Scions to heal 8 plants.", summary = "Vyletongue Corruption • Maraudon" },
    [5728] = { unlock = "Dungeon: Ragefire Chasm", note = "Requires the earlier Hidden Enemies chain steps in Orgrimmar; unlocks Thrall's follow-up reward step.", summary = "Hidden Enemies • Ragefire Chasm" },
    [4081] = { unlock = "Dungeon: Blackrock Depths", summary = "KILL ON SIGHT: Dark Iron Dwarves • Blackrock Depths" },
    [8417] = { unlock = "Dungeon: Sunken Temple", note = "Introductory step leading to Voodoo Feathers.", summary = "A Troubled Spirit • Sunken Temple" },
    [4324] = { unlock = "Dungeon: Blackrock Depths", note = "Introductory step leading to Ribbly Screwspigot.", summary = "Yuka Screwspigot • Blackrock Depths" },
    [7065] = { unlock = "Dungeon: Maraudon", reward = "Thrash Blade / Resurgence Rod / Verdant Keeper's Aim", note = "Kill Princess Theradras in the inner cavern.", summary = "Corruption of Earth and Seed • Maraudon" },
    [1013] = { unlock = "Dungeon: Shadowfang Keep", reward = "Grizzled Boots / Steel-clasped Bracers / Tattered Mittens", summary = "The Book of Ur • Shadowfang Keep" },
    [1200] = { unlock = "Dungeon: Blackfathom Deeps", reward = "Gravestone Scepter / Arctic Buckler / Dark Ritual Leggings / Cultist's Armguards", summary = "Blackfathom Villainy • Blackfathom Deeps" },
    [1014] = { unlock = "Dungeon: Shadowfang Keep", reward = "Seal of Sylvanas", note = "The current Forever quest data also lists Arcane Intellect as a learned reward.", summary = "Arugal Must Die • Shadowfang Keep" },
    [2926] = { unlock = "Dungeon: Gnomeregan", summary = "Gnogaine • Gnomeregan" },
    [7066] = { unlock = "Dungeon: Maraudon", note = "Zaetar's Spirit appears after Princess Theradras dies.", summary = "Seed of Life • Maraudon" },
    [96800] = { unlock = "Dungeon: Scarlet Monastery: Library", reward = "Salve and Salvation / Knucklebound Thimble", note = "New in Forever. The book is held by Arcanist Doan.", summary = "Past Due • Scarlet Monastery: Library" },
    [5047] = { unlock = "Dungeon: Upper Blackrock Spire", note = "He appears from The Beast's corpse after the fight. Malyfous then offers the Pristine Hide of the Beast exchanges.", summary = "Finkle Einhorn, At Your Service! • Upper Blackrock Spire" },
    [1491] = { unlock = "Dungeon: Wailing Caverns", summary = "Smart Drinks • Wailing Caverns" },
    [95772] = { unlock = "Dungeon: Excavation Site: Wetlands", note = "Find Daewyn inside the dungeon. Fallen in the Fen sends you back to Dorin Songblade in Lakeshire.", summary = "Songblade Search • Excavation Site: Wetlands" },
    [4982] = { unlock = "Dungeon: Lower Blackrock Spire", reward = "Freewind Gloves / Seapost Girdle", note = "Then take Bijou's Reconnaissance Report to Lexlort in Kargath for the reward.", summary = "Bijou's Belongings • Lower Blackrock Spire" },
    [92069] = { unlock = "Dungeon: Blackmaw Hold", reward = "Great Bear Claw / Staff of Wild Beasts / Wild Malleus", note = "Withermaw and Bonesnout are on different paths: take both.", summary = "Claws That Rend, Tusks that Gore • Blackmaw Hold" },
    [3525] = { unlock = "Dungeon: Razorfen Downs", reward = "Dragonclaw Ring", note = "Waves of undead attack during the ritual. Talk to the brazier near the idol afterwards to finish.", summary = "Extinguishing the Idol • Razorfen Downs" },
    [93443] = { isTalkTo = true, summary = "Deliver Crate to Friz Frazzlespark • Riverglades" },
    [94613] = { isTalkTo = true, summary = "A Grim Discovery (Wheeler's Grange) • Riverglades" },
    [94614] = { summary = "Mudfin Murlocs at Wheeler's Grange • Riverglades" },
    [94877] = { unlock = "Krol'dok Stronghold Prequest Chain", summary = "Sunnyglade Twilight Forces • Riverglades" },
    [94879] = { unlock = "Krol'dok Stronghold Prequest Chain", summary = "Sunnyglade Twilight Pages • Riverglades" },
    [94881] = { unlock = "Krol'dok Stronghold Prequest Chain", summary = "Sunnyglade Twilight Charms • Riverglades" },
    [94907] = { unlock = "Dungeon: Krol'dok Stronghold", summary = "Capture Twilight's Thrall • Riverglades" },
    [95147] = { isTalkTo = true, summary = "Courier to Captain Dalton (Southern Watch) • Riverglades" },
    [95330] = { isTalkTo = true, summary = "Delivery to Turner's Logging Camp • Riverglades" },
    [95943] = { summary = "Foreman's Plight (Farholde Keep) • Riverglades", note = "Locate the Foreman's Crate in Riverglades and return it to Bertrand Ironbrow in Farholde Keep." },
    [95991] = { isGroup = true, summary = "Slay Ghostmaw (Elite) • Riverglades" },
    [95810] = { unlock = "Dungeon: Excavation Site: Wetlands", summary = "Titan Relic (Whelgar's Excavation Site) • Wetlands" },
    [98189] = { isTalkTo = true, summary = "Menethil Statuette 1/3 (Captain Stoutfist) • Wetlands" },
    [98190] = { isTalkTo = true, summary = "Menethil Statuette 2/3 (Highlord Bolvar) • Stormwind" },
    [98191] = { isTalkTo = true, summary = "Menethil Statuette 3/3 (Cathedral of Light) • Stormwind" },
    [98208] = { summary = "Recover Nord'el • Wetlands" },
    [98209] = { isTalkTo = true, summary = "Deliver Nord'el to Auberdine • Darkshore" },
    [98216] = { unlock = "Whelgar Titan Relic Chain", summary = "Use Goaz Stone on Goaz Warder • Wetlands" },
    [98219] = { isTalkTo = true, summary = "Breadcrumb to Southshore • Hillsbrad Foothills" },
    [98230] = { isTalkTo = true, unlock = "Howin Kindfeather / Grim Batol Chain", summary = "Find Howin Kindfeather • Wetlands" },
    [98245] = { summary = "Razormaw Incisors • Wetlands" },
    [98246] = { summary = "Perfect Razormaw Eggs • Wetlands" },
    [98283] = { isGroup = true, summary = "Slay Carnage • Wetlands" },
    [98291] = { summary = "Dragonmaw Retreat Forces • Wetlands" },
    [98297] = { isGroup = true, summary = "Slay Subdued Dragonspawn • Wetlands" },
    [98300] = { isTalkTo = true, summary = "Deliver Howin's Missive to King Magni • Ironforge" },
    [98310] = { unlock = "Whelgar Titan Relic Chain", summary = "Use Goaz Stone on Four Warders • Wetlands" },
    [98313] = { isTalkTo = true, summary = "Deliver Whelgar Relic Package to Historian Karnik • Ironforge" },
    [79976] = { isKeyUnlock = true, reward = "Cozy Sleeping Bag (+3 Rested XP Item)", summary = "Cozy Sleeping Bag Finale • Thoradin's Wall" },
    [95384] = { isTalkTo = true, summary = "Deliver Partial Scroll to Booty Bay • Stranglethorn Vale" },
    [95999] = { isGroup = true, summary = "Incinerator Gar'im (Render's Valley) • Redridge Mountains" },
    [97047] = { summary = "Rescue Wendel in Kurzen's Compound • Stranglethorn Vale" },
    [97048] = { isTalkTo = true, summary = "Report to Captain Aransas in Booty Bay • Stranglethorn Vale" },
    [97328] = { summary = "Stolen Shipments in Zul'Kunda • Stranglethorn Vale" },
    [97894] = { isTalkTo = true, summary = "Check on Gorbold Steelhand in Auberdine • Darkshore" },
    [98459] = { isTalkTo = true, summary = "Deliver Tom's Gift to Menethil Harbor • Wetlands" },
    [98463] = { isTalkTo = true, summary = "Visit Nixxrax Fillamug in Booty Bay • Stranglethorn Vale" },
    [92459] = { isTalkTo = true, unlock = "Dungeon: City of Dalaran", summary = "Speak with Archmage Celindra • City of Dalaran" },
    [93604] = { unlock = "Dungeon: Razorfen Downs", summary = "Virulent Blood of Agamaggan • Razorfen Downs" },
    [96773] = { unlock = "Dungeon: Razorfen Downs", summary = "The Coldbringer's Eye • Razorfen Downs" },
    [97196] = { unlock = "Dungeon: Razorfen Downs", summary = "The Coldbringer's Eye • Razorfen Downs" },
    [95790] = { unlock = "Dungeon: Shaper's Terrace", summary = "Partially Digested Journal Pages • Shaper's Terrace" },
    [95924] = { unlock = "Dungeon: Shaper's Terrace", summary = "Venomridge & Ravasaurs • Shaper's Terrace" },
    [95925] = { unlock = "Dungeon: Shaper's Terrace", summary = "Survey Five Landmarks • Shaper's Terrace" },
    [95926] = { unlock = "Dungeon: Shaper's Terrace", summary = "Drained Crystal Fragment • Shaper's Terrace" },
    [97049] = { unlock = "Dungeon: Shaper's Terrace", summary = "Seeping Slime Essence • Shaper's Terrace" },
    [95262] = { unlock = "Dungeon: Alcaz Prison", summary = "King Varian Wrynn's Fate • Alcaz Prison" },
    [95263] = { isTalkTo = true, unlock = "Dungeon: Alcaz Prison", summary = "Return to Sully McCleary • Dustwallow Marsh" },
    [95483] = { isTalkTo = true, unlock = "Dungeon: Alcaz Prison", summary = "Report Varian's Fate to Thrall • Orgrimmar" },
    [96332] = { unlock = "Dungeon: Alcaz Prison", summary = "Tidemistress Ca'zass & Strashaz Naga • Alcaz Prison" },
    [96334] = { unlock = "Dungeon: Alcaz Prison", summary = "Blood Red Bandanas • Alcaz Prison" },
    [96335] = { unlock = "Dungeon: Alcaz Prison", summary = "Alcaz Shackle Key • Alcaz Prison" },
    [96337] = { unlock = "Dungeon: Alcaz Prison", summary = "Mason Connery's Hidden Treasure • Alcaz Prison" },
    [96381] = { unlock = "Dungeon: Alcaz Prison", summary = "Tidemistress Ca'zass & Strashaz Naga • Alcaz Prison" },
    [92065] = { unlock = "Dungeon: Blackmaw Hold", summary = "Varrox Bleakhoof's Head • Blackmaw Hold" },
    [92066] = { unlock = "Dungeon: Blackmaw Hold", summary = "Totems of Ursoc and Ursol • Blackmaw Hold" },
    [92067] = { unlock = "Dungeon: Blackmaw Hold", summary = "Fel-Tainted Flesh • Blackmaw Hold" },
    [96246] = { unlock = "Dungeon: Blackmaw Hold", summary = "Blackmaw Pouches • Blackmaw Hold" },
    [97327] = { unlock = "Dungeon: Blackmaw Hold", summary = "Blackmaw Pouches • Blackmaw Hold" },
    [-97100] = { isKeyUnlock = true, unlock = "Zul'Farrak: Gahz'rilla Gong", reward = "Mallet of Zul'Farrak", summary = "Forge Mallet of Zul'Farrak • Jintha'Alor Altar" },
}
for qid, pData in pairs(FOREVER_PAYOFFS) do
    if not Data.QuestPayoffs[qid] then
        Data.QuestPayoffs[qid] = pData
    else
        for k, v in pairs(pData) do
            if not Data.QuestPayoffs[qid][k] then Data.QuestPayoffs[qid][k] = v end
        end
    end
    if not Data.QuestPayoffs[qid].tip and Data.QuestTips[qid] then
        Data.QuestPayoffs[qid].tip = Data.QuestTips[qid]
    elseif Data.QuestPayoffs[qid].tip and not Data.QuestTips[qid] then
        Data.QuestTips[qid] = Data.QuestPayoffs[qid].tip
    end
end

-- =========================================================================
-- 5. WoW Forever Multi-Step Quest Chains
-- =========================================================================
local FOREVER_CHAINS = {
    [3001] = { quests = { 1100, 1101 }, isImportant = true },
    [3002] = { quests = { 2926, 2962 }, isImportant = true },
    [3003] = { quests = { 2198, 2199, 2200, 2201 }, isImportant = true },
    [3004] = { quests = { 8153, 8231, 8232 }, isImportant = true },
    [3005] = { quests = { 2258, 2202 }, isImportant = true },
    [3006] = { quests = { 8234, 8235, 8236 }, isImportant = true },
    [3007] = { quests = { 2198, 2199, 2200, 2201, 2204 }, isImportant = true },
    [3008] = { quests = { 78261, 78307, 78676, 78699 }, isImportant = true },
    [3009] = { quests = { 2841, 2842, 2843 }, isImportant = true },
    [3010] = { quests = { 3906, 7201 }, isImportant = true },
    [3011] = { quests = { 4141, 4142, 4143 }, isImportant = true },
    [3012] = { quests = { 4145, 4147, 4146 }, isImportant = true },
    [3013] = { quests = { 865, 1491 }, isImportant = true },
    [3014] = { quests = { 356, 99156, 92422 }, isImportant = true },
    [3015] = { quests = { 373, 389, 391 }, isImportant = true },
    [3016] = { quests = { 2283, 2284, 2318, 2338, 2339, 2340, 2341 }, isImportant = true },
    [3018] = { quests = { 9052, 9051, 9053 }, isImportant = true },
    [3019] = { quests = { 92346, 92343 }, isImportant = true },
    [3020] = { quests = { 3906, 3981, 3982, 4001, 4002, 4003 }, isImportant = true },
    [3021] = { quests = { 95283, 95284, 95285, 95309, 95454, 96369, 95483 }, isImportant = true },
    [3022] = { quests = { 79008, 79192, 79980, 79974, 79975, 79976 }, isImportant = true },
    [3023] = { quests = { 92345, 92344 }, isImportant = true },
    [3024] = { quests = { 261, 1052, 1053 }, isImportant = true },
    [3025] = { quests = { 2988, 2989, 2990, 2991 }, isImportant = true },
    [3026] = { quests = { 94973, 94974 }, isImportant = true },
    [3027] = { quests = { 484, 98815 }, isImportant = true },
    [3028] = { quests = { 5382, 5515, 5384, 5461, 5462, 5463 }, isImportant = true },
    [3029] = { quests = { 5382, 5515, 5384, 5461, 5462, 5463, 5464, 5465, 5466 }, isImportant = true },
    [3030] = { quests = { 96391, 96393 }, isImportant = true },
    [3031] = { quests = { 92914, 96010, 96018, 93016, 93394, 93594, 93404, 93601, 93604 }, isImportant = true },
    [3032] = { quests = { 5722, 5724 }, isImportant = true },
    [3033] = { quests = { 2198, 2199, 2200, 2201, 2204, 2361 }, isImportant = true },
    [3034] = { quests = { 720, 721, 722 }, isImportant = true },
    [3035] = { quests = { 303, 378 }, isImportant = true },
    [3036] = { quests = { 92432, 92457 }, isImportant = true },
    [3037] = { quests = { 1949, 1950, 1951 }, isImportant = true },
    [3038] = { quests = { 870, 877, 880, 1489, 1490, 914 }, isImportant = true },
    [3039] = { quests = { 4182, 4183, 4184, 4185, 4186, 4223, 4224, 4241, 4242, 4264, 4282, 4322, 6402, 6403, 6501, 6502 }, isImportant = true },
    [3040] = { quests = { 4903, 4941, 4974 }, isImportant = true },
    [3041] = { quests = { 65, 132, 135, 141, 142, 155, 166 }, isImportant = true },
    [3042] = { quests = { 544, 93680, 545, 92434, 96984 }, isImportant = true },
    [3043] = { quests = { 95194, 95196, 95198, 95262, 95263 }, isImportant = true },
    [3044] = { quests = { 65, 132, 135, 141, 142, 155, 214 }, isImportant = true },
    [3045] = { quests = { 1954, 1955, 1956 }, isImportant = true },
    [3046] = { quests = { 2500, 17 }, isImportant = true },
    [3047] = { quests = { 463, 276, 277, 275, 95646 }, isImportant = true },
    [3048] = { quests = { 6522, 6521 }, isImportant = true },
    [3049] = { quests = { 5244, 5245, 5246, 5247 }, isImportant = true },
    [3050] = { quests = { 3906, 3907 }, isImportant = true },
    [3051] = { quests = { 3523, 3525 }, isImportant = true },
    [3052] = { quests = { 447, 450, 451, 95216 }, isImportant = true },
    [3053] = { quests = { 4742, 4743 }, isImportant = true },
    [3054] = { quests = { 3520, 3527, 4787, 3528 }, isImportant = true },
    [3055] = { quests = { 95283, 95284, 95285, 96332 }, isImportant = true },
    [3056] = { quests = { 5382, 5515 }, isImportant = true },
    [3057] = { quests = { 7044, 7046 }, isImportant = true },
    [3058] = { quests = { 5251, 5262 }, isImportant = true },
    [3059] = { quests = { 5251, 5262, 5263 }, isImportant = true },
    [3060] = { quests = { 629, 95748, 95770, 95775 }, isImportant = true },
    [3061] = { quests = { 5527, 5526 }, isImportant = true },
    [3062] = { quests = { 629, 95748, 95770, 95775, 96078 }, isImportant = true },
    [3063] = { quests = { 95194, 95196, 95198, 96381 }, isImportant = true },
    [3064] = { quests = { 4726, 4808, 4809, 4810, 4907, 4734, 4735, 5522, 5531, 4771 }, isImportant = true },
    [3065] = { quests = { 4262, 4263 }, isImportant = true },
    [3066] = { quests = { 629, 95748, 95773, 95770, 95776 }, isImportant = true },
    [3067] = { quests = { 95283, 95284, 95285, 96334 }, isImportant = true },
    [3068] = { quests = { 1149, 1150, 1151, 1152, 1154, 6627, 1159, 1160, 6628, 1394 }, isImportant = true },
    [3069] = { quests = { 8251, 8252, 8253 }, isImportant = true },
    [3070] = { quests = { 8255, 8256, 8257 }, isImportant = true },
    [3071] = { quests = { 3801, 3802 }, isImportant = true },
    [3072] = { quests = { 4903, 4941, 4974, 6566, 6567, 6568, 6569 }, isImportant = true },
    [3073] = { quests = { 3520, 3527, 4787, 3528, 5065, 4788 }, isImportant = true },
    [3074] = { quests = { 96264, 79358, 96135, 96016 }, isImportant = true },
    [3075] = { quests = { 95647, 95809 }, isImportant = true },
    [3076] = { quests = { 4061, 4062, 4063 }, isImportant = true },
    [3077] = { quests = { 2278, 2279 }, isImportant = true },
    [3078] = { quests = { 91858, 91859, 91860, 91861, 91862, 96204, 95034, 95036, 95111, 95125, 95126, 95140 }, isImportant = true },
    [3079] = { quests = { 95663, 95682 }, isImportant = true },
    [3080] = { quests = { 94980, 94981 }, isImportant = true },
    [3081] = { quests = { 79360, 79364, 79361, 79366, 79442 }, isImportant = true },
    [3082] = { quests = { 1824, 1825, 1838, 1848 }, isImportant = true },
    [3083] = { quests = { 4903, 4941, 4974, 6566, 6567, 6568, 6569, 6570, 6582, 6583, 6584, 6585, 6601, 6602 }, isImportant = true },
    [3084] = { quests = { 92914, 96010, 96018, 93016, 93394, 93594, 93404 }, isImportant = true },
    [3085] = { quests = { 738, 739, 704 }, isImportant = true },
    [3086] = { quests = { 94879, 94886, 94888, 94889, 94890, 94891, 94982 }, isImportant = true },
    [3087] = { quests = { 95664, 98823 }, isImportant = true },
    [3088] = { quests = { 94483, 94672, 95428, 94744, 94748, 94745, 95432, 94768, 94975 }, isImportant = true },
    [3089] = { quests = { 94483, 94672, 95428, 94744, 94748, 94745, 95432, 94768, 95278, 94972 }, isImportant = true },
    [3090] = { quests = { 5001, 5002, 5081 }, isImportant = true },
    [3091] = { quests = { 203, 204, 207, 205, 95786, 95787, 95799 }, isImportant = true },
    [3092] = { quests = { 5542, 5543, 5544, 5742, 5781, 5845, 5846, 5848 }, isImportant = true },
    [3093] = { quests = { 94877, 94886, 94888, 94889, 94890, 94983, 94997, 94998 }, isImportant = true },
    [3094] = { quests = { 5726, 5727, 5728 }, isImportant = true },
    [3095] = { quests = { 1699, 1702, 1701, 1782 }, isImportant = true },
    [3096] = { quests = { 4182, 4183, 4184, 4185, 4186, 4223, 4224, 4241, 4242, 4264, 4282, 4322 }, isImportant = true },
    [3097] = { quests = { 4081, 4082 }, isImportant = true },
    [3098] = { quests = { 8948, 8949, 8950, 9015 }, isImportant = true },
    [3099] = { quests = { 78261, 78307 }, isImportant = true },
    [3100] = { quests = { 3445, 3444, 3446 }, isImportant = true },
    [3101] = { quests = { 2933, 2934, 2935, 2936 }, isImportant = true },
    [3102] = { quests = { 7637, 7639, 7640, 7641, 7642, 7648, 7645, 7643 }, isImportant = true },
    [3103] = { quests = { 1424, 1429, 1444, 1445 }, isImportant = true },
    [3104] = { quests = { 7563, 7564, 7623, 7624, 7625, 7629 }, isImportant = true },
    [3105] = { quests = { 96335, 96337 }, isImportant = true },
    [3106] = { quests = { 7637, 7639, 7640, 7641, 7642, 7648, 7645, 7643, 7644, 7646, 7647 }, isImportant = true },
    [3107] = { quests = { 6133, 6042, 6022, 6135, 6136, 6163 }, isImportant = true },
    [3108] = { quests = { 3445, 3444, 3447 }, isImportant = true },
    [3109] = { quests = { 4081, 4082, 4122, 4121, 4132 }, isImportant = true },
    [3110] = { quests = { 1109, 1113 }, isImportant = true },
    [3111] = { quests = { 5089, 5102 }, isImportant = true },
    [3112] = { quests = { 1448, 1449, 1450, 1451, 1452, 1469, 1475 }, isImportant = true },
    [3113] = { quests = { 2283, 2284, 2318, 2338, 2339 }, isImportant = true },
    [3114] = { quests = { 7563, 7564, 7623, 7624, 7625, 7626, 7627, 7628, 7629, 7630, 7631 }, isImportant = true },
    [3115] = { quests = { 203, 204, 207, 205, 95786, 95788, 95798 }, isImportant = true },
    [3116] = { quests = { 94483, 94672, 95428, 94744, 94748, 94745, 95432, 94768, 95278, 94968 }, isImportant = true },
    [3117] = { quests = { 94879, 94881, 94907, 94984 }, isImportant = true },
    [3118] = { quests = { 3520, 3527 }, isImportant = true },
    [3119] = { quests = { 92432, 92458 }, isImportant = true },
    [3120] = { quests = { 95810, 98824 }, isImportant = true },
    [3121] = { quests = { 92742, 92744, 92745, 92747, 92748, 92749, 92750, 92751, 92752, 92753 }, isImportant = true },
    [3122] = { quests = { 2278, 2280 }, isImportant = true },
    [3123] = { quests = { 8419, 8420, 8421, 8422 }, isImportant = true },
    [3124] = { quests = { 8410, 8412, 8413 }, isImportant = true },
    [3125] = { quests = { 2945, 2947, 2948 }, isImportant = true },
    [3126] = { quests = { 2278, 2279, 2439 }, isImportant = true },
    [3127] = { quests = { 7667, 7668 }, isImportant = true },
    [3128] = { quests = { 2945, 2949, 2950 }, isImportant = true },
    [3129] = { quests = { 6564, 6565 }, isImportant = true },
    [3130] = { quests = { 8423, 8424, 8425 }, isImportant = true },
    [3131] = { quests = { 4981, 4982 }, isImportant = true },
    [3132] = { quests = { 1651, 1652, 1653, 1654, 1806 }, isImportant = true },
    [3133] = { quests = { 5212, 5213 }, isImportant = true },
    [3134] = { quests = { 5122, 5125 }, isImportant = true },
    [3135] = { quests = { 4726, 4808, 4809, 4810, 4907, 4734, 4735 }, isImportant = true },
    [3136] = { quests = { 3702, 3701, 4341, 4342, 4361, 4362 }, isImportant = true },
    [3137] = { quests = { 3906, 3981, 3982 }, isImportant = true },
    [3138] = { quests = { 5382, 5515, 5384 }, isImportant = true },
    [3139] = { quests = { 720, 721, 722, 723, 724, 725, 726, 762, 1139 }, isImportant = true },
    [3140] = { quests = { 8414, 8416, 8418 }, isImportant = true },
    [3141] = { quests = { 98189, 98190, 98191 }, isImportant = false },
    [3142] = { quests = { 98208, 98209 }, isImportant = false },
    [3143] = { quests = { 98216, 98310, 98313 }, isImportant = true },
    [3144] = { quests = { 98230, 98245, 98291, 98297, 98300 }, isImportant = true },
    [3145] = { quests = { 94613, 94614 }, isImportant = false },
    [3146] = { quests = { 97047, 97048 }, isImportant = false },
    [3147] = { quests = { 91858, 91859, 91860, 91861, 91862, 96204, 95034, 95036, 95111, 95125, 95126, 95140 }, isImportant = true },
    [3148] = { quests = { 86777, 86792, 86796, 86797, 86798, 86814 }, isImportant = true },
}

for cID, cData in pairs(FOREVER_CHAINS) do
    Data.KnownChains[cID] = cData
end

-- Rebuild reverse chain index with WoW Forever chains included
if Data.BuildChainIndex then
    Data.BuildChainIndex()
end

-- =========================================================================
-- 5B. Static Quest XP Fallback Table (from ForeverDungeonJournal & live captures)
-- =========================================================================
Data.QuestXPFallback = {
    [17] = 6050, [65] = 1350, [132] = 680, [135] = 680, [141] = 340, [142] = 1350, [155] = 1700, [166] = 2600,
    [167] = 1550, [168] = 1350, [203] = 1950, [204] = 2700, [205] = 3150, [207] = 3550, [214] = 1250, [303] = 2450,
    [356] = 650, [373] = 870, [378] = 5750, [389] = 440, [447] = 900, [450] = 1350, [451] = 2050, [544] = 3350,
    [545] = 2050, [629] = 2850, [704] = 5000, [707] = 710, [709] = 6150, [721] = 4800, [722] = 5500, [865] = 1350,
    [870] = 680, [877] = 1150, [880] = 1150, [914] = 2200, [959] = 1350, [962] = 1700, [971] = 2750, [1013] = 2100,
    [1014] = 3300, [1098] = 2000, [1139] = 10250, [1144] = 3050, [1149] = 1050, [1150] = 2450, [1151] = 3050, [1152] = 1200,
    [1154] = 1850, [1159] = 1200, [1160] = 2100, [1198] = 2400, [1199] = 2550, [1200] = 3300, [1275] = 2400, [1360] = 6300,
    [1424] = 4450, [1429] = 3750, [1444] = 3750, [1445] = 10600, [1446] = 12750, [1448] = 3600, [1449] = 1800, [1450] = 900,
    [1451] = 1800, [1452] = 3600, [1469] = 2700, [1475] = 13850, [1486] = 1600, [1489] = 290, [1490] = 115, [1491] = 1350,
    [1701] = 2300, [1740] = 2550, [1806] = 5500, [1838] = 3650, [1848] = 3050, [1956] = 7800, [2040] = 1550, [2198] = 5800,
    [2199] = 2450, [2200] = 4450, [2201] = 6300, [2202] = 6750, [2204] = 1650, [2240] = 6850, [2278] = 8200, [2279] = 5250,
    [2280] = 5250, [2283] = 4800, [2284] = 4800, [2318] = 6750, [2338] = 350, [2339] = 7300, [2340] = 1850, [2341] = 5600,
    [2342] = 7000, [2361] = 5600, [2398] = 550, [2418] = 3500, [2439] = 420, [2768] = 12600, [2769] = 405, [2770] = 14200,
    [2846] = 12100, [2861] = 410, [2864] = 390, [2865] = 7800, [2936] = 9700, [2991] = 10500, [3042] = 7800, [3341] = 9050,
    [3373] = 5450, [3380] = 6550, [3444] = 4900, [3445] = 3650, [3446] = 9550, [3447] = 11900, [3520] = 3750, [3523] = 675,
    [3525] = 10100, [3527] = 10500, [3528] = 15400, [3636] = 10200, [3765] = 1450, [3801] = 500, [3802] = 9450, [3907] = 13500,
    [3981] = 9450, [3982] = 10100, [4001] = 12600, [4002] = 550, [4003] = 16100, [4004] = 2200, [4024] = 11450, [4063] = 12400,
    [4081] = 9950, [4082] = 10650, [4083] = 5650, [4121] = 7750, [4122] = 6200, [4123] = 10450, [4126] = 14800, [4128] = 550,
    [4132] = 15500, [4133] = 550, [4134] = 11300, [4136] = 5550, [4141] = 5100, [4142] = 3800, [4143] = 9950, [4145] = 5100,
    [4146] = 9200, [4147] = 2550, [4201] = 10900, [4241] = 11450, [4242] = 9800, [4263] = 10450, [4264] = 11150, [4282] = 11150,
    [4286] = 10450, [4322] = 13950, [4341] = 11500, [4342] = 2900, [4361] = 6400, [4362] = 16900, [4363] = 20250, [4787] = 5900,
    [5722] = 880, [5723] = 1050, [5724] = 1450, [5725] = 1450, [5726] = 910, [5727] = 460, [5728] = 1150, [5761] = 1150,
    [6521] = 7350, [6522] = 5900, [6561] = 3300, [6562] = 435, [6563] = 1750, [6564] = 1300, [6565] = 6489, [6626] = 8200,
    [6627] = 245, [6921] = 6746, [6922] = 7468, [6981] = 2650, [7028] = 10250, [7029] = 10250, [7041] = 10250, [7044] = 6650,
    [7046] = 11100, [7064] = 11900, [7065] = 11900, [7066] = 11900, [7067] = 10650, [7068] = 6750, [7070] = 6750, [7201] = 10100,
    [7604] = 725, [8151] = 500, [8153] = 5100, [8231] = 5100, [8232] = 12400, [8233] = 500, [8234] = 5100, [8235] = 5100,
    [8236] = 12400, [8250] = 500, [8251] = 5100, [8252] = 5100, [8253] = 12400, [8254] = 500, [8255] = 5100, [8256] = 5100,
    [8257] = 12400, [8410] = 3800, [8412] = 5100, [8413] = 12400, [8414] = 5100, [8415] = 500, [8416] = 2550, [8417] = 500,
    [8418] = 12400, [8419] = 3800, [8420] = 3800, [8421] = 5100, [8422] = 12400, [8423] = 5100, [8424] = 5100, [8425] = 12400,
    [8948] = 1450, [8949] = 1450, [8950] = 1450, [9015] = 1450, [9052] = 5100, [9053] = 12400, [9063] = 500, [78261] = 1850,
    [78307] = 6900, [78676] = 3450, [78699] = 6900, [79007] = 1750, [79008] = 1750, [79192] = 1950, [79974] = 2550, [79975] = 2550,
    [79976] = 1950, [79980] = 200, [86777] = 5250, [86792] = 5450, [86796] = 5450, [86797] = 525, [86798] = 550, [86814] = 7050,
    [87346] = 5650, [92065] = 13200, [92066] = 11300, [92069] = 12400, [92070] = 11300, [92343] = 11300, [92344] = 11300, [92345] = 560,
    [92346] = 560, [92401] = 2200, [92415] = 2600, [92421] = 2200, [92434] = 270, [92456] = 3950, [92457] = 9400, [92458] = 9400,
    [92489] = 3950, [92742] = 460, [92744] = 460, [92745] = 490, [92747] = 580, [92749] = 575, [92752] = 580, [92753] = 1350,
    [92819] = 680, [92914] = 3600, [93016] = 360, [93341] = 1800, [93394] = 360, [93404] = 11100, [93594] = 360, [93601] = 390,
    [93604] = 10200, [94483] = 3000, [94672] = 3300, [94744] = 360, [94745] = 3750, [94748] = 3750, [94768] = 5050, [94877] = 3150,
    [94879] = 3150, [94881] = 2850, [94886] = 380, [94888] = 3750, [94889] = 3750, [94890] = 5050, [94891] = 4050, [94907] = 3750,
    [94968] = 11500, [94972] = 11050, [94973] = 3300, [94974] = 3300, [94975] = 8200, [94980] = 3300, [94981] = 3300, [94982] = 11500,
    [94983] = 10200, [94984] = 11050, [94997] = 3450, [94998] = 3450, [95140] = 2650, [95189] = 2600, [95194] = 1300, [95195] = 2600,
    [95196] = 1300, [95198] = 1300, [95204] = 2600, [95216] = 2600, [95250] = 1650, [95262] = 14400, [95263] = 2850, [95278] = 390,
    [95283] = 1300, [95284] = 1300, [95285] = 1300, [95309] = 12100, [95428] = 330, [95432] = 1800, [95454] = 12100, [95647] = 4900,
    [95664] = 1400, [95748] = 3150, [95770] = 3150, [95773] = 2850, [95775] = 8450, [95776] = 9500, [95786] = 3150, [95787] = 8450,
    [95788] = 8450, [95790] = 17650, [95810] = 630, [95924] = 17650, [95925] = 17650, [95926] = 17650, [95928] = 17650, [96010] = 2450,
    [96016] = 3900, [96018] = 3600, [96078] = 2350, [96135] = 3150, [96264] = 6950, [96335] = 2850, [96337] = 11550, [96369] = 2400,
    [96381] = 11550, [96391] = 1050, [96393] = 1450, [96394] = 1050, [96395] = 1050, [96403] = 1350, [96770] = 10100, [96771] = 11500,
    [96772] = 14400, [96773] = 8600, [96774] = 8800, [96775] = 10100, [96776] = 11900, [96984] = 9400, [96986] = 3950, [96987] = 3950,
    [96988] = 3950, [97049] = 17650, [97130] = 10450, [97173] = 12800, [97196] = 8600, [97197] = 14800, [97198] = 16100, [97288] = 1650,
    [97327] = 13200, [98325] = 660, [98423] = 1150, [99156] = 900,
}

-- =========================================================================
-- 5C. Complete Wowhead Forever Catalog (New, Custom & Updated Quests)
-- Entry format: [questID] = { category, level, xp, side, tag, rewards }
-- =========================================================================
local FOREVER_CATALOG = {
    [9] = { "Westfall", 15, 1050, "A", nil, "Pick one: harvesters pants, harvesters robe, harvesters pestslayer" }, -- The Killing Fields
    [11] = { "Elwynn Forest", 10, 840, "A", nil, "Pick one: militia buckler, urchins pants, footmans pocketknife" }, -- Riverpaw Gnoll Bounty
    [14] = { "Westfall", 17, 1600, "A", nil, "Pick one: edge of the peoples militia, fist of the peoples militia, spark of the peoples militia, boots of the peoples militia" }, -- The People's Militia
    [17] = { "Uldaman", 42, 3450, "A", "Dungeon", "Greater Mender's Potion" }, -- Uldaman Reagent Run
    [23] = { "Ashenvale", 24, 1950, "H" }, -- Ursangous's Paw
    [31] = { "Druid", 16, 1150, "H", nil, "aquarius belt, idol of shifting tides" }, -- Aquatic Form
    [46] = { "Elwynn Forest", 10, 840, "A", nil, "Pick one: long bayonet, solid metal club, well used sword, juniors hunting bow" }, -- Bounty on Murlocs
    [61] = { "Elwynn Forest", 7, 790, "A", nil, "Pick one: explosive rocket, oil of olaf, elixir of minor strength" }, -- Shipment to Stormwind
    [90] = { "Duskwood", 25, 2000, "A", nil, "seasoned wolf kabob, recipe seasoned wolf kabob" }, -- Seasoned Wolf Kabobs
    [98] = { "Duskwood", 35, 4100, "A", nil, "Pick one: crescent of forlorn spirits, ring of forlorn spirits, ring of ruin" }, -- The Legend of Stalvan
    [100] = { "Shaman", 23, 190, "H" }, -- Call of Water
    [116] = { "Redridge Mountains", 15, 1050, "A", nil, "finely woven cloak, a bulging coin purse" }, -- Dry Times
    [140] = { "Westfall", 16, 1150, nil, nil, "silver bar, captain sanders shirt, captain sanders sash, captain sanders locker" }, -- Captain Sander's Hidden Treasure
    [155] = { "Westfall", 18, 1700, "A" }, -- The Defias Brotherhood
    [167] = { "The Deadmines", 20, 1550, "A", "Dungeon", "Pick one: miners revenge, miners workgloves, miners workboots" }, -- Oh Brother...
    [168] = { "The Deadmines", 18, 1350, "A", "Dungeon", "Pick one: tunnelers boots, dusty mining gloves, worn miners waistcord" }, -- Collecting Memories
    [169] = { "Redridge Mountains", 26, 2650, "A", "Elite" }, -- WANTED: Gath'Ilzogg
    [174] = { "Duskwood", 25, 2000, "A" }, -- Look to the Stars
    [175] = { "Duskwood", 25, 1000, "A" }, -- Look to the Stars
    [176] = { "Elwynn Forest", 11, 880, "A", "Elite", "Pick one: footman tunic, stormwind guard leggings, balanced fighting stick, apprentice wizards gown" }, -- WANTED: "Hogger"
    [177] = { "Duskwood", 25, 1500, "A" }, -- Look to the Stars
    [180] = { "Redridge Mountains", 26, 2650, "A" }, -- WANTED: Lieutenant Fangore
    [181] = { "Duskwood", 30, 2450, "A", nil, "Pick one: zodiac gloves, belt of the stars" }, -- Look to the Stars
    [202] = { "Stranglethorn Vale", 40, 3150, "A", "Elite", "Pick one: shrapnel blaster, madmans blade, dark hearted hammer" }, -- Colonel Kurzen
    [206] = { "Stranglethorn Vale", 46, 5050, "A", "Elite", "Pick one: tranquil orb, rebel breastplate, archers leggings" }, -- Mai'Zoth
    [208] = { "Stranglethorn Vale", 43, 5350, nil, "Elite", "Pick one: master hunters bow, master hunters rifle, master hunters wand, master hunters spellsword" }, -- Big Game Hunter
    [212] = { "Stormwind City", 40, 3900, "A" }, -- A Meal Served Cold
    [214] = { "The Deadmines", 17, 1250, "A", "Dungeon", "Pick one: solid shortblade, scrimshaw dagger, piercing axe, monastic hammer" }, -- Red Silk Bandanas
    [224] = { "Loch Modan", 12, 910, "A", nil, "dalaran sharp, cheese knife" }, -- In Defense of the King's Lands
    [228] = { "Duskwood", 35, 2750, "A", "Elite" }, -- Mor'Ladim
    [231] = { "Duskwood", 35, 1350, "A", nil, "archeus, ladimore heirloom ring" }, -- A Daughter's Love
    [234] = { "Dun Morogh", 4, 270, "A", nil, "Pick one: mining for dummies, wild harvest, pelt collecting for beginners" }, -- Coldridge Valley Mail Delivery
    [249] = { "Redridge Mountains", 27, 2750, "A", "Elite", "Pick one: rose mantle, demonhide bracers, shadow gauntlets" }, -- Morganth
    [253] = { "Duskwood", 30, 3650, "A", "Elite", "Pick one: mantle of honor, darkshire shoulderguards, Crest of Darkshire" }, -- Bride of the Embalmer
    [256] = { "Loch Modan", 22, 1750, "A", "Elite", "Pick one: durable chain shoulders, kimbra boots, loch walkers, Minor Channeling Ring" }, -- WANTED: Chok'sul
    [275] = { "Wetlands", 26, 2650, "A", nil, "Pick one: fen keeper robe, forest chain, phytoblade" }, -- Blisters on the Land
    [295] = { "Wetlands", 27, 2200, "A" }, -- Ormer's Revenge
    [296] = { "Wetlands", 29, 2950, "A", nil, "Pick one: raptors end, raptorbane armor, excavation rod, raptorclaw shoulders, Recipe: Curiously Tasty Omelet" }, -- Ormer's Revenge
    [299] = { "Wetlands", 27, 2200, "A", nil, "Silk Mantle of Gamn" }, -- Uncovering the Past
    [303] = { "Wetlands", 30, 2450, "A", "Elite" }, -- The Dark Iron War
    [304] = { "Wetlands", 34, 3350, "A", "Elite", "Pick one: gold lion shield, tranquil ring, fury ring" }, -- A Grim Task
    [305] = { "Wetlands", 24, 970, "A" }, -- In Search of the Excavation Team
    [306] = { "Wetlands", 24, 490, "A" }, -- In Search of the Excavation Team
    [353] = { "Stormwind City", 15, 1050, "A" }, -- Stormpike's Delivery
    [367] = { "Tirisfal Glades", 6, 540, "H", nil, "Minor Troll's Blood Elixir" }, -- A New Plague
    [377] = { "The Stockade", 26, 2100, "A", "Dungeon", "Pick one: ambassadors boots, darkshire mail leggings, town clerks mittens" }, -- Crime and Punishment
    [378] = { "The Stockade", 27, 2750, "A", "Dungeon", "Pick one: belt of vindication, headbasher, magistrates pantaloons" }, -- The Fury Runs Deep
    [386] = { "The Stockade", 25, 2000, "A", "Dungeon", "Pick one: lucine longsword, hardened root staff, ursine hammer" }, -- What Comes Around...
    [387] = { "The Stockade", 26, 2650, "A", "Dungeon" }, -- Quell the Uprising
    [398] = { "Tirisfal Glades", 10, 840, "H", nil, "Pick one: brass scale pants, tillers vest" }, -- WANTED: Maggot Eye
    [421] = { "Silverpine Forest", 11, 880, "H" }, -- Prove Your Worth
    [429] = { "Silverpine Forest", 11, 440, "H" }, -- Wild Hearts
    [430] = { "Silverpine Forest", 11, 660, "H" }, -- Return to Quinn
    [442] = { "Silverpine Forest", 24, 1950, "H", "Elite", "Pick one: high robe of the adjudicator, talonstrike, gnollhide pants, gnoll shackles" }, -- Assault on Fenris Isle
    [451] = { "Silverpine Forest", 18, 2050, "H", nil, "Pick one: nightglow concoction, acidproof cloak, wise gauntlets, elixir of minor fortitude, swiftness potion" }, -- A Recipe For Death
    [458] = { "Teldrassil", 1, 40, "A", nil, "Pick one: mining for dummies, wild harvest, pelt collecting for beginners" }, -- The Woodland Protector
    [465] = { "Wetlands", 31, 1900, "A" }, -- Nek'rosh's Gambit
    [472] = { "Wetlands", 30, 1200, "A" }, -- Fall of Dun Modr
    [474] = { "Wetlands", 32, 2550, "A", "Elite", "Pick one: ancient war sword, barreling reaper, dragonmaw skinflayer" }, -- Defeat Nek'rosh
    [484] = { "Wetlands", 22, 1750, "A" }, -- Young Crocolisk Skins
    [490] = { "Teldrassil", 8, 700, "A" }, -- Bounty: Gnarlpine Furbolg
    [501] = { "Hillsbrad Foothills", 24, 1950, "H", nil, "Pick one: gloves of brawn, stomping boots, firewalker boots, trophy belt, Recipe: Hot Lion Chops" }, -- Elixir of Pain
    [504] = { "Alterac Mountains", 40, 4700, "A", "Elite", "Pick one: burning sliver, lunar buckler, alterac assassins gloves" }, -- Crushridge Warmongers
    [515] = { "Hillsbrad Foothills", 30, 3050, "H", nil, "Pick one: high apothecary cloak, meditative sash, glistening stompers" }, -- Elixir of Agony
    [516] = { "Silverpine Forest", 21, 1250, "H", nil, "Wand of Decay" }, -- Beren's Peril
    [531] = { "Loch Modan", 20, 1550, "A", "Elite", "Pick one: hunting ammo sack, hunting quiver, Hunting Satchel" }, -- Vyrin's Revenge
    [544] = { "Hillsbrad Foothills", 33, 3300, "H" }, -- Prison Break In
    [545] = { "Alterac Mountains", 35, 2050, "H" }, -- Dalaran Patrols
    [547] = { "Hillsbrad Foothills", 30, 3050, "H", "Elite", "Pick one: ribbed breastplate, mercenary leggings, ethereal mantle" }, -- Humbert's Sword
    [549] = { "Hillsbrad Foothills", 22, 1750, "H", nil, "Criminal's Pauldrons" }, -- WANTED: Syndicate Personnel
    [556] = { "Hillsbrad Foothills", 33, 2650, "H" }, -- Stone Tokens
    [557] = { "Hillsbrad Foothills", 33, 2650, "H" }, -- Bracers of Binding
    [565] = { "Hillsbrad Foothills", 34, 2700, "A", nil, "Pick one: yeti fur cloak, yeti skinner" }, -- Bartolo's Yeti Fur Cloak
    [600] = { "Stranglethorn Vale", 41, 3300, nil, nil, "Pick one: goblin igniter, silver spade, goblin switchblade" }, -- Venture Company Mining
    [606] = { "Stranglethorn Vale", 41, 3300 }, -- Scaring Shaky
    [608] = { "Stranglethorn Vale", 45, 4850, nil, nil, "Pick one: blackwater tunic, blackwater scimitar, blackwater cap" }, -- The Bloodsail Buccaneers
    [611] = { "Stranglethorn Vale", 40, 3150, "A", "Elite", "Pick one: robe of crystal waters, tidal bracers, undertow legguards" }, -- The Curse of the Tides
    [613] = { "Stranglethorn Vale", 44, 4650, nil, "Elite", "Pick one: collection plate, beggars leggings, seadogs battered cuffs" }, -- Cracking Maury's Foot
    [614] = { "Stranglethorn Vale", 47, 3150, nil, "Elite", "Pick one: bloodband bracers, freebooters armband" }, -- The Captain's Chest
    [628] = { "Stranglethorn Vale", 38, 2850, nil, "Elite", "excelsior boots, mystic heavy armor kit" }, -- Excelsior
    [630] = { "Stranglethorn Vale", 51, 7350, nil, "Elite", "Pick one: poobahs nose ring, golden banana" }, -- Message in a Bottle
    [631] = { "Wetlands", 31, 2500, "A", "Elite" }, -- The Thandol Span
    [632] = { "Wetlands", 31, 2500, "A" }, -- The Thandol Span
    [633] = { "Wetlands", 31, 2500, "A", nil, "Pick one: dwarven guard cloak, swampland trousers" }, -- The Thandol Span
    [634] = { "Wetlands", 31, 1250, "A" }, -- Plea to the Alliance
    [635] = { "Arathi Highlands", 35, 1350 }, -- Crystal in the Mountains
    [642] = { "Arathi Highlands", 37, 2850 }, -- The Princess Trapped
    [646] = { "Arathi Highlands", 42, 4300, "H", "Elite", "Pick one: blood tinged armor, pit fighters shield, ceremonial gown, blooded pants" }, -- Trol'kalar
    [648] = { "Tanaris", 48, 5450, nil, nil, "Pick one: optomatic deflector, thermotastic egg timer, projectile redirectors, reloading assist armbands" }, -- Rescue OOX-17/TN!
    [651] = { "Arathi Highlands", 38, 2850 }, -- Stones of Binding
    [656] = { "Arathi Highlands", 50, 7100, nil, "Elite", "Pulsating Crystalline Shard" }, -- Summoning the Princess
    [673] = { "Arathi Highlands", 40, 3150, "H", "Elite", "Pick one: white drakeskin cap, radiant silver bracers, stromgarde cuffs" }, -- Foul Magics
    [679] = { "Arathi Highlands", 40, 3150, "H", "Elite", "Pick one: silent hunter, skullsplitter, mindslicer" }, -- Call to Arms
    [680] = { "Arathi Highlands", 40, 3900, "H", "Elite", "Pick one: mistspray kilt, sword of hammerfall, witchdoctors dress" }, -- The Real Threat
    [682] = { "Arathi Highlands", 37, 3550, "A", "Elite", "Pick one: stromgarde cavalry leggings, stromgarde librarian leggings, stromgarde operative pants, Stromgarde Cavalry Leggings" }, -- Stromgarde Badges
    [684] = { "Arathi Highlands", 39, 3750, "A", "Elite", "Pick one: arcane runed bracers, wild headdress, stromgarde bracers" }, -- WANTED: Marez Cowl
    [685] = { "Arathi Highlands", 40, 3900, "A", "Elite", "Pick one: rod of sorrow, war rider bracers, arathi armbands" }, -- WANTED: Otto and Falconcrest
    [688] = { "Arathi Highlands", 40, 320, "H" }, -- Myzrael's Allies
    [692] = { "Badlands", 41, 3300 }, -- The Lost Fragments
    [697] = { "Arathi Highlands", 39, 3750, "A", "Elite", "Pick one: vigilant buckler, wingborne boots, tower boots" }, -- Malin's Request
    [704] = { "Uldaman", 38, 2850, "A", "Dungeon", "Pick one: prospector gloves, restorers fine gloves, excavator gauntlets" }, -- Agmond's Fate
    [708] = { "Badlands", 40, 2350, "A" }, -- The Black Box
    [709] = { "Uldaman", 40, 3150, nil, "Dungeon", "Pick one: doomsayers robe, doomcallers pants, fists of impending doom" }, -- Solution to Doom
    [745] = { "Mulgore", 8, 700, "H", nil, "Flash Pellet" }, -- Sharing the Land
    [752] = { "Mulgore", 2, 90, "H", nil, "Pick one: mining for dummies, wild harvest, pelt collecting for beginners" }, -- A Humble Task
    [762] = { "Badlands", 44, 4650, "A", "Elite", "Pick one: dwarf captains sword, thanes hammer, ironforge agents gloves" }, -- An Ambassador of Evil
    [772] = { "Mulgore", 7, 480, "H", nil, "Pick one: rainwalker boots, sun beaten cloak" }, -- Rite of Vision
    [836] = { "The Hinterlands", 48, 5450, nil, nil, "Pick one: gnomish inventor boots, gnomish water sinking device, gnomish floatation device" }, -- Rescue OOX-09/HL!
    [868] = { "The Barrens", 22, 1750, "H", nil, "Pick one: harlequin robes, violet scale armor" }, -- Egg Hunt
    [887] = { "The Barrens", 14, 740 }, -- Southsea Freebooters
    [888] = { "The Barrens", 16, 1150, nil, nil, "Pick one: wayfaring gloves, padded lamellar boots" }, -- Stolen Booty
    [890] = { "The Barrens", 14, 100 }, -- The Missing Shipment
    [892] = { "The Barrens", 14, 100 }, -- The Missing Shipment
    [894] = { "The Barrens", 14, 740 }, -- Samophlange
    [895] = { "The Barrens", 16, 1150 }, -- WANTED: Baron Longshore
    [898] = { "The Barrens", 20, 1950, "H", nil, "Pick one: buckled boots, riveted gauntlets, embroidered leggings" }, -- Free From the Hold
    [901] = { "The Barrens", 14, 740 }, -- Samophlange
    [902] = { "The Barrens", 16, 1150, nil, nil, "Pick one: engineers hammer, welding shield" }, -- Samophlange
    [905] = { "The Barrens", 17, 1250, "H" }, -- The Angry Scytheclaws
    [909] = { "Ashenvale", 30, 3050, "H", "Elite", "Pick one: outlaw sabre, witchs finger" }, -- Baron Aquanis
    [914] = { "Wailing Caverns", 22, 2200, "H", "Dungeon", "Pick one: crescent staff, wingblade, hammerbone" }, -- Leaders of the Fang
    [915] = { "Children's Week", 60, 660, "H" }, -- You Scream, I Scream...
    [922] = { "Teldrassil", 7, 320, "A" }, -- Rellian Greenspyre
    [932] = { "Teldrassil", 8, 700, "A", nil, "Pick one: feral bracers, viny wrappings" }, -- Twisted Hatred
    [940] = { "Teldrassil", 11, 440, "A", nil, "Forest Oracle's Cloak" }, -- Teldrassil
    [943] = { "Wetlands", 24, 2400, "A", nil, "Pick one: relic blade, skullchipper, archaeologists gown" }, -- The Absent Minded Prospector
    [950] = { "Darkshore", 17, 950, "A" }, -- Return to Onu
    [952] = { "Darkshore", 17, 1250, "A" }, -- Grove of the Ancients
    [960] = { "Darkshore", 1, 0, "A", nil, "Phial of Scrying" }, -- Onu is Meditating
    [961] = { "Darkshore", 1, 0, "A", nil, "Phial of Scrying" }, -- Onu is Meditating
    [962] = { "Wailing Caverns", 18, 1700, "H", "Dungeon", "Pick one: apothecary gloves, heat resistant mitts, safety boots, Apothecary Gloves" }, -- Serpentbloom
    [968] = { "Darkshore", 18, 1700, "A" }, -- The Powers Below
    [971] = { "Blackfathom Deeps", 23, 2750, "A", "Dungeon", "Sustaining Ring" }, -- Knowledge in the Deeps
    [982] = { "Darkshore", 17, 1250, "A", nil, "Pick one: welldrip gloves, noosegrip gauntlets, murloc hide gloves" }, -- Deep Ocean, Vast Sea
    [984] = { "Darkshore", 14, 740, "A" }, -- How Big a Threat?
    [1012] = { "Ashenvale", 32, 3200, "A", nil, "Pick one: emils brand, uthils cudgel, mavoriss warstaff" }, -- Insane Druids
    [1013] = { "Shadowfang Keep", 26, 2100, "H", "Dungeon", "Pick one: grizzled boots, steel clasped bracers, tattered mittens" }, -- The Book of Ur
    [1045] = { "Ashenvale", 30, 2450, "A" }, -- Raene's Cleansing
    [1046] = { "Ashenvale", 30, 3050, "A", nil, "Pick one: glacial stone, gutterblade, ring of pure silver, replica dartols rod of transformation" }, -- Raene's Cleansing
    [1057] = { "Stonetalon Mountains", 27, 2200, "A" }, -- Reclaiming the Charred Vale
    [1059] = { "Stonetalon Mountains", 27, 2200, "A", nil, "Pick one: tempered bracers, constable buckler, reclaimers robes" }, -- Reclaiming the Charred Vale
    [1090] = { "Stonetalon Mountains", 22, 2200, nil, "Elite" }, -- Gerenzo's Orders
    [1098] = { "Shadowfang Keep", 25, 2000, "H", "Dungeon", "Pick one: ghostly mantle, tanned shoulderpads, bronzed shoulderguards" }, -- Deathstalkers in Shadowfang
    [1101] = { "Razorfen Kraul", 34, 3350, "A", "Dungeon", "Pick one: berylline pads, stonefist girdle, marbled buckler, Quilboar Blaster" }, -- The Crone of the Kraul
    [1102] = { "Razorfen Kraul", 34, 4050, "H", "Dungeon", "Pick one: berylline pads, stonefist girdle, marbled buckler, Quilboar Blaster" }, -- A Vengeful Fate
    [1132] = { "Wetlands", 30, 1200, "A" }, -- Fiora Longears
    [1139] = { "Uldaman", 45, 5850, "A", "Dungeon", "Pick one: medal of courage, medal of valor" }, -- The Lost Tablets of Will
    [1142] = { "Razorfen Kraul", 30, 3050, "A", "Dungeon", "Pick one: mourning shawl, lancer boots, sentinels boots" }, -- Mortality Wanes
    [1144] = { "Razorfen Kraul", 30, 3050, nil, "Dungeon", "Pick one: monkey ring, snake hoop, tiger band, boar signet" }, -- Willix the Importer
    [1166] = { "Dustwallow Marsh", 43, 4450, "H", "Elite", "Pick one: enormous ogre boots, oversized ogres mittens, thick ogres belt" }, -- Overlord Mok'Morokk's Concern
    [1172] = { "Dustwallow Marsh", 45, 4850, "H", "Elite", "Pick one: encarmine boots, boots of zuatec, black whelp boots" }, -- The Brood of Onyxia
    [1199] = { "Blackfathom Deeps", 25, 2550, "A", "Dungeon", "Pick one: nimbus boots, heartwood girdle, silvered gauntlets, Silvered Gauntlets" }, -- Twilight Falls
    [1200] = { "Blackfathom Deeps", 27, 3300, "A", "Dungeon", "Pick one: gravestone scepter, arctic buckler, dark ritual leggings, cultists armguards" }, -- Blackfathom Villainy
    [1203] = { "Dustwallow Marsh", 35, 3450, nil, nil, "Pick one: reedknot ring, swamp ring, Artisan's Trousers" }, -- Jarl Needs a Blade
    [1221] = { "Razorfen Kraul", 26, 2100, nil, "Dungeon", "A Small Container of Gems" }, -- Blueleaf Tubers
    [1222] = { "Dustwallow Marsh", 37, 2850, "A", nil, "Elixir of Lesser Fortitude" }, -- Stinky's Escape
    [1250] = { "Stormwind City", 33, 270, "A" }, -- The Missing Diplomat
    [1267] = { "Stormwind City", 38, 4300, "A", nil, "Jaina's Signet Ring" }, -- The Missing Diplomat
    [1270] = { "Dustwallow Marsh", 37, 2850, "H", nil, "Elixir of Lesser Fortitude" }, -- Stinky's Escape
    [1275] = { "Blackfathom Deeps", 24, 2400, "A", "Dungeon", "Pick one: beetle clasps, prelacy cape, staghide armguards" }, -- Researching the Corruption
    [1367] = { "Desolace", 33, 660, "H" }, -- Magram Alliance
    [1368] = { "Desolace", 33, 660 }, -- Gelkis Alliance
    [1369] = { "Desolace", 33, 2650 }, -- Broken Tears
    [1370] = { "Desolace", 35, 1350, "A", nil, "Pick one: silver star, feathered arrow, exploding shot" }, -- Stealing Supplies
    [1371] = { "Desolace", 35, 2050, nil, nil, "Pick one: schematic hoof shaped foot pedal, schematic centaur banner deployment device" }, -- Gizmo for Warug
    [1373] = { "Desolace", 37, 2850, "A" }, -- Ongeku
    [1380] = { "Desolace", 42, 4300, "A", "Elite", "Pick one: kolkar marauder chain, traitors finger" }, -- Khan Hratha
    [1381] = { "Desolace", 42, 4300, nil, "Elite", "Pick one: kolkar hunters belt, ceremonial centaur blanket" }, -- Khan Hratha
    [1382] = { "Desolace", 35, 2050, "A" }, -- Strange Alliance
    [1384] = { "Desolace", 32, 2550, "A" }, -- Raid on the Kolkar
    [1385] = { "Desolace", 35, 2050, "A" }, -- Brutal Politics
    [1386] = { "Desolace", 32, 2550, "A" }, -- Assault on the Kolkar
    [1425] = { "Swamp of Sorrows", 42, 2550, "A" }, -- Deliver the First Shipment
    [1446] = { "The Temple of Atal'Hakkar", 53, 6550, nil, "Dungeon", "Pick one: rainstrider leggings, helm of exile, leggings of freedom and sorrow" }, -- Jammal'an the Prophet
    [1472] = { "Warlock", 20, 160, "H" }, -- Devourer of Souls
    [1476] = { "Warlock", 20, 1550, "H" }, -- Hearts of the Pure
    [1486] = { "Wailing Caverns", 17, 1600, nil, "Dungeon", "Pick one: deviate hide pack, slick deviate leggings, deviate hide pack, slick deviate leggings" }, -- Deviate Hides
    [1498] = { "Warrior", 10, 630, "H" }, -- Path of Defense
    [1505] = { "Warrior", 10, 90, "H" }, -- Veteran Uzzek
    [1507] = { "Warlock", 20, 160, "H" }, -- Devourer of Souls
    [1508] = { "Warlock", 20, 390, "H" }, -- Blind Cazul
    [1527] = { "Shaman", 13, 1150, "H", nil, "fire totem, totem of charged flames" }, -- Call of Fire
    [1578] = { "Blacksmithing", 12, 910, "A", nil, "Plans: Copper Chain Vest" }, -- Supplying the Front
    [1581] = { "Alchemy", 8, 700, "A", nil, "earthroot, mageroyal" }, -- Elixirs for the Bladeleafs
    [1618] = { "Blacksmithing", 16, 1150, "A", nil, "Plans: Ironforge Breastplate" }, -- Gearing Redridge
    [1665] = { "Warrior", 10, 420, "A" }, -- Bartleby's Mug
    [1678] = { "Warrior", 11, 1100, "A" }, -- Vejrek
    [1683] = { "Warrior", 10, 840, "A" }, -- Vorlus Vilehoof
    [1716] = { "Warlock", 20, 780, "A" }, -- Devourer of Souls
    [1719] = { "Warrior", 30, 2450 }, -- The Affray
    [1818] = { "Warrior", 10, 90, "H" }, -- Speak with Dillinger
    [1819] = { "Warrior", 10, 840, "H" }, -- Ulag the Cleaver
    [2040] = { "The Deadmines", 20, 1550, "A", "Dungeon", "Pick one: polar gauntlets, sable wand, bravos armbands, dreamers leggings" }, -- Underground Assault
    [2078] = { "Darkshore", 20, 1150, "A", "Elite", "Draught of Water Breathing" }, -- Gyromast's Revenge
    [2139] = { "Darkshore", 18, 1350, "A", nil, "Pick one: evergreen gloves, timberland cape" }, -- Tharnariun's Hope
    [2202] = { "Uldaman", 42, 3450, "H", "Dungeon", "Greater Mender's Potion" }, -- Uldaman Reagent Run
    [2240] = { "Uldaman", 40, 3900, "A", "Dungeon", "Pick one: dwarven charge, explorers league lodestar, guardian staff" }, -- The Hidden Chamber
    [2359] = { "Rogue", 24, 1950, "A", "Elite", "Recipe: Thistle Tea" }, -- Klaven's Tower
    [2418] = { "Uldaman", 36, 3500, nil, "Dungeon", "Pick one: energized stone circle, duracin bracers, everlast boots, charged leather bracers" }, -- Power Stones
    [2480] = { "Rogue", 20, 160, "H", nil, "Hinott's Oil" }, -- Hinott's Assistance
    [2501] = { "Loch Modan", 44, 3750, "A", "Elite" }, -- Badlands Reagent Run II
    [2756] = { "Blacksmithing", 40, 3150, "H" }, -- The Old Ways
    [2763] = { "Blacksmithing", 45, 3900, nil, nil, "Plans: Ornate Mithril Shoulders" }, -- The Art of the Imbue
    [2768] = { "Zul'Farrak", 47, 6300, nil, "Dungeon", "Pick one: masons fraternity ring, engineers guild headpiece, magister cowl" }, -- Divino-matic Rod
    [2771] = { "Blacksmithing", 45, 3900 }, -- A Good Head On Your Shoulders
    [2841] = { "Gnomeregan", 35, 3450, "H", "Dungeon", "Pick one: civinad robes, triprunner dungarees, dual reinforced leggings" }, -- Rig Wars
    [2846] = { "Zul'Farrak", 46, 6050, nil, "Dungeon", "Pick one: gemshale pauldrons, dank shoulderpads, Spellshifter Rod" }, -- Tiara of the Deep
    [2881] = { "The Hinterlands", 45, 0, "A" }, -- Troll Necklace Bounty
    [2904] = { "Gnomeregan", 30, 2450, nil, "Dungeon", "Pick one: fire welded bracers, fairywing mantle, technicians bracers" }, -- A Fine Mess
    [2928] = { "Gnomeregan", 30, 2450, "A", "Dungeon", "Pick one: shonis disarming tool, shilly mitts, operators gloves" }, -- Gyrodrillmatic Excavationators
    [2929] = { "Gnomeregan", 35, 3450, "A", "Dungeon", "Pick one: civinad robes, triprunner dungarees, dual reinforced leggings" }, -- The Grand Betrayal
    [2987] = { "Feralas", 43, 3600, "H", nil, "Pick one: boots of the maharishi, stargazer cloak, orwins axe" }, -- Gordunni Cobalt
    [2994] = { "The Hinterlands", 51, 7350, "A", "Elite", "Pick one: gryphon riders stormhammer, gryphon riders leggings, gryphon riders crop, cleansed vilebranch icon, cleansed vilebranch medallion" }, -- Saving Sharpbeak
    [3062] = { "Feralas", 50, 5900, "H", "Elite", "Pick one: wingcrest gloves, stronghorn girdle, stonewalkers slippers, protectors armguards" }, -- Dark Heart
    [3341] = { "Razorfen Downs", 42, 4300, "H", "Dungeon", "Pick one: amberglow talisman, purified ring, Vanquisher's Sword" }, -- Bring the End
    [3463] = { "Searing Gorge", 52, 7600, nil, "Elite", "Pick one: dragonflight leggings, drakefire headguard, axe of the ebon drake, dragonscale pants" }, -- Set Them Ablaze!
    [3504] = { "Orgrimmar", 53, 2650, "H" }, -- Betrayed
    [3505] = { "Azshara", 53, 3950, "H" }, -- Betrayed
    [3514] = { "The Barrens", 29, 2950, "H", "Elite", "Pick one: trailblazer boots, jutebraid gloves, runed gauntlets" }, -- Horde Presence
    [3517] = { "Azshara", 52, 5100, "H" }, -- Stealing Knowledge
    [3518] = { "Azshara", 52, 2550, "H" }, -- Delivery to Magatha Grimtotem
    [3528] = { "The Temple of Atal'Hakkar", 53, 7900, nil, "Dungeon", "Pick one: avenguard helm, lifeforce dirk, gemburst circlet, shapeshifters helm" }, -- The God Hakkar
    [3562] = { "Azshara", 52, 6350, "H" }, -- Magatha's Payment to Jediga
    [3563] = { "Azshara", 52, 6350, "H" }, -- Jes'rimon's Payment to Jediga
    [3564] = { "Azshara", 52, 6350, "H" }, -- Andron's Payment to Jediga
    [3636] = { "Razorfen Downs", 42, 4300, "A", "Dungeon", "Pick one: amberglow talisman, purified ring, Vanquisher's Sword" }, -- Bring the Light
    [3842] = { "Feralas", 47, 2100, "A" }, -- A Short Incubation
    [3911] = { "Blackrock Depths", 54, 5450, nil, "Elite", "Lagrave's Seal" }, -- The Last Element
    [3912] = { "Un'Goro Crater", 52, 5100 }, -- Meet at the Grave
    [4003] = { "Blackrock Depths", 59, 8050, nil, "Dungeon" }, -- The Royal Rescue
    [4004] = { "Blackrock Depths", 60, 9950, nil, "Dungeon", "Pick one: thralls resolve, eye of orgrimmar" }, -- The Princess Saved?
    [4126] = { "Blackrock Depths", 55, 7050, "A", "Dungeon", "Pick one: swiftstrike cudgel, limb cleaver, ragnars favorite hat, Dark Dwarven Lager" }, -- Hurley Blackbreath
    [4132] = { "Blackrock Depths", 58, 7750, "H", "Dungeon", "Pick one: conquerors medallion, conquerors pendant" }, -- Operation: Death to Angerforge
    [4134] = { "Blackrock Depths", 55, 5650, "H", "Dungeon", "Pick one: swiftstrike cudgel, limb cleaver, ragnars favorite hat, superior healing potion, greater mana potion" }, -- Lost Thunderbrew Recipe
    [4185] = { "Burning Steppes", 54, 540, "A" }, -- The True Masters
    [4201] = { "Blackrock Depths", 54, 5450, nil, "Dungeon", "Pick one: manacle cuffs, nagmaras whipping belt, boots of requite, private rocknots spare bracers" }, -- The Love Potion
    [4224] = { "Burning Steppes", 54, 540, "A" }, -- The True Masters
    [4242] = { "Blackrock Depths", 54, 5450, "A", "Dungeon", "Pick one: conservator helm, shieldplate sabatons, windshear leggings, cindercloth gown" }, -- Abandoned Hope
    [4402] = { "Durotar", 3, 380, "H", nil, "Pick one: mining for dummies, wild harvest, pelt collecting for beginners, Cactus Apple Surprise" }, -- Galgar's Cactus Apple Surprise
    [4491] = { "Un'Goro Crater", 55, 5650, nil, nil, "Pick one: bejeweled legguards, treetop leggings, clayridge helm, yesterdays pants" }, -- A Little Help From My Friends
    [4641] = { "Durotar", 1, 40, "H" }, -- Your Place in the World
    [4771] = { "Scholomance", 60, 9950, nil, "Dungeon", "Pick one: windreaper, dancing sliver" }, -- Dawn's Gambit
    [4822] = { "Children's Week", 60, 660, "A" }, -- You Scream, I Scream...
    [5061] = { "Druid", 16, 1150, "A", nil, "aquarius belt, idol of shifting tides" }, -- Aquatic Form
    [5063] = { "Winterspring", 60, 0, nil, "Elite", "null" }, -- Cap of the Scarlet Savant
    [5064] = { "Thousand Needles", 28, 2300, "H", nil, "Pick one: desert shoulders, tundra boots, grimtoll wristguards" }, -- Grimtotem Spying
    [5067] = { "Winterspring", 60, 0, nil, "Elite", "null" }, -- Leggings of Arcana
    [5068] = { "Winterspring", 60, 0, nil, "Elite", "null" }, -- Breastplate of Bloodthirst
    [5088] = { "Thousand Needles", 28, 2300, "H", "Elite", "Pick one: brute hammer, stingshot wand, clink shield, smouldering leggings" }, -- Arikara
    [5127] = { "Blackrock Spire", 60, 8300, nil, "Dungeon", "plans demon forged breastplate, potion of demon slaying, demon kissed sack" }, -- The Demon Forge
    [5147] = { "Thousand Needles", 29, 2350, "H", nil, "Pick one: brawnhide armor, plainsguard leggings" }, -- WANTED: Arnak Grimtotem
    [5151] = { "Thousand Needles", 30, 3050, "H", "Elite", "Pick one: inventors league ring, wizlos tuning wrench, Inventor's League Ring" }, -- Hypercapacitor Gizmo
    [5166] = { "Western Plaguelands", 60, 9950, nil, "Elite", "Breastplate of the Chromatic Flight" }, -- Breastplate of the Chromatic Flight
    [5167] = { "Western Plaguelands", 60, 9950, nil, "Elite", "Pick one: legguards of the chromatic defier, legplates of the chromatic defier" }, -- Legplates of the Chromatic Defier
    [5250] = { "Rut'theran Village", 56, 580, "A" }, -- Starfall
    [5283] = { "Blacksmithing", 40, 3150, "A" }, -- The Art of the Armorsmith
    [5284] = { "Blacksmithing", 40, 3150, "A" }, -- The Way of the Weaponsmith
    [5321] = { "Darkshore", 20, 1550, "A", nil, "Pick one: owlsight rifle, jadefinger baton, steelcap shield, deerhide pants" }, -- The Sleeper Has Awakened
    [5383] = { "Scholomance", 60, 6600, nil, "Dungeon" }, -- Krastinov's Bag of Horrors
    [5634] = { "Priest", 10, 0, "A" }, -- Desperate Prayer
    [5635] = { "Priest", 10, 210, "A" }, -- Desperate Prayer
    [5636] = { "Priest", 10, 210, "A" }, -- Desperate Prayer
    [5637] = { "Priest", 10, 210, "A" }, -- Desperate Prayer
    [5638] = { "Priest", 10, 210, "A" }, -- Desperate Prayer
    [5639] = { "Priest", 10, 0, "A" }, -- Desperate Prayer
    [5640] = { "Priest", 10, 210, "A" }, -- Desperate Prayer
    [5641] = { "Priest", 20, 0, "A" }, -- Chastise
    [5644] = { "Priest", 20, 390, "H" }, -- Dark Sacrifice
    [5645] = { "Priest", 20, 390, "A" }, -- Chastise
    [5646] = { "Priest", 20, 390, "H" }, -- Dark Sacrifice
    [5647] = { "Priest", 20, 390, "A" }, -- Chastise
    [5653] = { "Priest", 10, 210, "H" }, -- Hex of Weakness
    [5659] = { "Priest", 10, 210, "H" }, -- Touch of Weakness
    [5669] = { "Priest", 15, 270, "A" }, -- A Blessing of Light
    [5670] = { "Priest", 15, 270, "A" }, -- A Blessing of Light
    [5671] = { "Priest", 15, 270, "A" }, -- A Blessing of Light
    [5674] = { "Priest", 20, 390, "A" }, -- Elune's Grace
    [5679] = { "Priest", 20, 0, "H" }, -- Dark Sacrifice
    [5686] = { "Priest", 25, 510, "A" }, -- The Light Protects You
    [5687] = { "Priest", 25, 510, "A" }, -- The Light Protects You
    [5691] = { "Priest", 15, 0, "H" }, -- In the Dark it was Created
    [5692] = { "Priest", 15, 270, "H" }, -- In the Dark It was Created
    [5693] = { "Priest", 15, 270, "H" }, -- In the Dark It was Created
    [5704] = { "Priest", 25, 0, "H" }, -- Undead Priest Robe
    [5705] = { "Priest", 25, 510, "H" }, -- No Longer a Shadow
    [5706] = { "Priest", 25, 510, "H" }, -- No Longer a Shadow
    [5707] = { "Priest", 35, 0, "H" }, -- Flirting With Darkness
    [5708] = { "Priest", 35, 690, "H" }, -- Flirting With Darkness
    [5709] = { "Priest", 35, 690, "H" }, -- Flirting With Darkness
    [5724] = { "Ragefire Chasm", 16, 1450, "H", "Dungeon", "Pick one: featherbead bracers, savannah bracers, garrison cuffs" }, -- Returning the Lost Satchel
    [5727] = { "Orgrimmar", 12, 460, "H" }, -- Hidden Enemies
    [5943] = { "Desolace", 38, 2850, nil, nil, "Pick one: sidegunner shottie, kodo brander, studded ring shield, farseers forgotten shield" }, -- Gizelton Caravan
    [6001] = { "Druid", 10, 840, "A" }, -- Body and Heart
    [6002] = { "Druid", 10, 840, "H" }, -- Body and Heart
    [6003] = { "Undercity", 39, 3750 }, -- Green With Envy
    [6031] = { "Blackmaw Hold", 55, 5650, nil, nil, "Pick one:shadowskin spaulders, bricksteel gauntlets" }, -- Runecloth
    [6032] = { "Blackmaw Hold", 55, 5650 }, -- Sacred Cloth
    [6061] = { "Hunter", 10, 840, "H" }, -- Taming the Beast
    [6062] = { "Hunter", 10, 840, "H" }, -- Taming the Beast
    [6063] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [6064] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [6072] = { "Hunter", 10, 90, "A" }, -- The Hunter's Path
    [6081] = { "Hunter", 10, 420, "H" }, -- Training the Beast
    [6082] = { "Hunter", 10, 840, "H" }, -- Taming the Beast
    [6083] = { "Hunter", 10, 840, "H" }, -- Taming the Beast
    [6084] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [6085] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [6086] = { "Hunter", 10, 420, "A" }, -- Training the Beast
    [6087] = { "Hunter", 10, 840, "H" }, -- Taming the Beast
    [6088] = { "Hunter", 10, 840, "H" }, -- Taming the Beast
    [6089] = { "Hunter", 10, 420, "H" }, -- Training the Beast
    [6101] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [6102] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [6103] = { "Hunter", 10, 420, "A" }, -- Training the Beast
    [6121] = { "Druid", 14, 100, "A" }, -- Lessons Anew
    [6125] = { "Druid", 14, 980, "A" }, -- Power over Poison
    [6126] = { "Druid", 14, 100, "H" }, -- Lessons Anew
    [6130] = { "Druid", 14, 980, "H" }, -- Power over Poison
    [6134] = { "Desolace", 39, 2250, nil, nil, "Pick one: condor bracers, anchorhold buckler" }, -- Ghost-o-plasm Round Up
    [6163] = { "Stratholme", 60, 6600, "H", "Dungeon", "Pick one: elemental circle, royal seal of alexis, royal seal of alexis, elemental circle" }, -- Ramstein
    [6201] = { "Stratholme", 65, 0 }, -- The Legacy of the Ashbringer
    [6282] = { "Stonetalon Mountains", 26, 2100, "H" }, -- Harpies Threaten
    [6283] = { "Stonetalon Mountains", 26, 2100, "H", "Elite", "Pick one: spritekin cloak, screecher belt, harpy bangles" }, -- Bloodfury Bloodline
    [6386] = { "The Barrens", 10, 1050, "H" }, -- Return to the Crossroads
    [6395] = { "Tirisfal Glades", 5, 450, "H", nil, "Pick one: mining for dummies, wild harvest, pelt collecting for beginners" }, -- Marla's Last Wish
    [6402] = { "Stormwind City", 60, 660, "A", "Raid" }, -- Stormwind Rendezvous
    [6403] = { "Stormwind City", 60, 9950, "A", "Raid" }, -- The Great Masquerade
    [6481] = { "Stonetalon Mountains", 20, 1550, "H", "Elite", "Pick one: owlbeard bracers, wolfmane wristguards, raptorcrest bracers" }, -- Earthen Arise
    [6521] = { "Razorfen Downs", 36, 3500, "H", "Dungeon", "Pick one: skullbreaker, nail spitter, zealots robe, cultists chestguard" }, -- An Unholy Alliance
    [6561] = { "Blackfathom Deeps", 27, 3300, "H", "Dungeon", "Pick one: gravestone scepter, arctic buckler, dark ritual leggings, cultists armguards" }, -- Blackfathom Villainy
    [6562] = { "Blackfathom Deeps", 22, 440, "H", "Dungeon" }, -- Trouble in the Deeps
    [6563] = { "Blackfathom Deeps", 22, 1750, "H", "Dungeon" }, -- The Essence of Aku'Mai
    [6565] = { "Blackfathom Deeps", 26, 2650, "H", "Dungeon", "Pick one: band of the fist, chestnut mantle" }, -- Allegiance to the Old Gods
    [6606] = { "Winterspring", 60, 660, "H" }, -- A Little Luck
    [6861] = { "Alterac Valley", 60, 0, "H", "PvP", "Zinfizzlex's Portable Shredder Unit" }, -- Zinfizzlex's Portable Shredder Unit
    [6921] = { "Blackfathom Deeps", 27, 2750, "H", "Dungeon" }, -- Amongst the Ruins
    [6922] = { "Ashenvale", 30, 3050, "H", "Dungeon", "Pick one: outlaw sabre, witchs finger, dreamers chestguard" }, -- Baron Aquanis
    [7201] = { "Blackrock Depths", 54, 5450, "H", "Dungeon", "Pick one: lagraves seal, dark iron signet" }, -- The Last Element
    [7441] = { "Dire Maul", 58, 7750, nil, "Dungeon", "Pick one: spry boots, sprinters sword, incanters pantaloons" }, -- Pusillin and the Elder Azj'Tordin
    [7483] = { "Dire Maul", 60, 1650, nil, "Dungeon", "Arcanum of Rapidity" }, -- Libram of Rapidity
    [7488] = { "Dire Maul", 57, 7550, "A", "Dungeon", "Pick one: lorespinner, warpwood bracers, satyrhide armbands" }, -- Lethtendris's Web
    [7489] = { "Dire Maul", 57, 7550, "H", "Dungeon", "Pick one: lorespinner, warpwood bracers, satyrhide armbands" }, -- Lethtendris's Web
    [7494] = { "Dire Maul", 57, 1500, "A", "Dungeon" }, -- Feathermoon Stronghold
    [7504] = { "Dire Maul", 60, 6600, nil, "Dungeon", "Royal Seal of Eldre'Thalas" }, -- Holy Bologna: What the Light Won't Tell You
    [7509] = { "Onyxia's Lair", 60, 9950, nil, "Raid", "Quel'Serrar" }, -- The Forging of Quel'Serrar
    [7701] = { "Searing Gorge", 50, 4700, nil, "Elite", "Pick one: seared mail vest, charred leather tunic, singed cloth robe" }, -- WANTED: Overseer Maltorius
    [7724] = { "Searing Gorge", 49, 4550, nil, nil, "Seared Mail Girdle" }, -- Fiery Menace!
    [7741] = { "Felwood", 59, 6400, nil, nil, "Emerald Circle" }, -- Praise from the Emerald Circle
    [7782] = { "Stormwind City", 60, 9950, "A", nil, "Pick one: master dragonslayers medallion, master dragonslayers orb, master dragonslayers ring" }, -- The Lord of Blackrock
    [7790] = { "Eastern Plaguelands", 57, 600 }, -- River Ends
    [7840] = { "The Hinterlands", 49, 4550, "H", nil, "lards special picnic basket, lards lunch slicer" }, -- Lard Lost His Lunch
    [7841] = { "The Hinterlands", 48, 4400, "H", "PvP" }, -- Message to the Wildhammer
    [7842] = { "The Hinterlands", 48, 5450, "H", "PvP" }, -- Another Message to the Wildhammer
    [7843] = { "The Hinterlands", 50, 5900, "H", "PvP", "Owlbeast Hide Gloves" }, -- The Final Message to the Wildhammer
    [7847] = { "The Hinterlands", 51, 4900, "H", "Elite", "Pick one: highland bow, flask of forest mojo, forest troll leggings" }, -- Return to Primal Torntusk
    [7850] = { "The Hinterlands", 50, 5900, "H", "Elite", "Pick one: natures breath, vicious throwing stars, bloodstained longbow, bloodied longmace" }, -- Dark Vessels
    [7861] = { "The Hinterlands", 51, 6100, "H", "Elite", "Pick one: woven ivy necklace, deep woodlands cloak" }, -- WANTED: Vile Priestess Hexx and Her Minions
    [7862] = { "The Hinterlands", 51, 6100, "H", "Elite", "rune of the guard captain, jewel of the guard captain" }, -- Job Opening: Guard Captain of Revantusk Village
    [7881] = { "Darkmoon Faire", 60, 0 }, -- Carnival Boots
    [7882] = { "Darkmoon Faire", 60, 0 }, -- Carnival Jerkins
    [7883] = { "Darkmoon Faire", 60, 0 }, -- The World's Largest Gnome!
    [7884] = { "Darkmoon Faire", 60, 0 }, -- Crocolisk Boy and the Bearded Murloc
    [7885] = { "Darkmoon Faire", 60, 0 }, -- Armor Kits
    [7889] = { "Darkmoon Faire", 60, 0 }, -- Coarse Weightstone
    [7890] = { "Darkmoon Faire", 60, 0 }, -- Heavy Grinding Stone
    [7891] = { "Darkmoon Faire", 60, 0 }, -- Green Iron Bracers
    [7892] = { "Darkmoon Faire", 60, 0 }, -- Big Black Mace
    [7893] = { "Darkmoon Faire", 60, 0 }, -- Rituals of Strength
    [7894] = { "Darkmoon Faire", 60, 0 }, -- Copper Modulator
    [7895] = { "Darkmoon Faire", 60, 0 }, -- Whirring Bronze Gizmo
    [7896] = { "Darkmoon Faire", 60, 0 }, -- Green Fireworks
    [7897] = { "Darkmoon Faire", 60, 0 }, -- Mechanical Repair Kits
    [7898] = { "Darkmoon Faire", 60, 0 }, -- Thorium Widget
    [7899] = { "Darkmoon Faire", 60, 0 }, -- Small Furry Paws
    [7900] = { "Darkmoon Faire", 60, 0 }, -- Torn Bear Pelts
    [7901] = { "Darkmoon Faire", 60, 0 }, -- Soft Bushy Tails
    [7902] = { "Darkmoon Faire", 60, 0 }, -- Vibrant Plumes
    [7903] = { "Darkmoon Faire", 60, 0 }, -- Evil Bat Eyes
    [7905] = { "Ironforge", 60, 660, "A" }, -- The Darkmoon Faire
    [7906] = { "Darkmoon Faire", 1, 0 }, -- Darkmoon Cards - Beasts (turn-in)
    [7926] = { "Orgrimmar", 60, 660, "H" }, -- The Darkmoon Faire
    [7930] = { "Darkmoon Faire", 60, 0, nil, nil, "Darkmoon Flower" }, -- 5 Tickets - Darkmoon Flower
    [7931] = { "Darkmoon Faire", 60, 0, nil, nil, "Minor Darkmoon Prize" }, -- 5 Tickets - Minor Darkmoon Prize
    [7932] = { "Darkmoon Faire", 60, 0, nil, nil, "Lesser Darkmoon Prize" }, -- 12 Tickets - Lesser Darkmoon Prize
    [7933] = { "Darkmoon Faire", 60, 0, nil, nil, "Greater Darkmoon Prize" }, -- 40 Tickets - Greater Darkmoon Prize
    [7934] = { "Darkmoon Faire", 60, 0, nil, nil, "Darkmoon Storage Box" }, -- 50 Tickets - Darkmoon Storage Box
    [7935] = { "Darkmoon Faire", 60, 0, nil, nil, "Last Month's Mutton" }, -- 10 Tickets - Last Month's Mutton
    [7936] = { "Darkmoon Faire", 60, 0, nil, nil, "Last Year's Mutton" }, -- 50 Tickets - Last Year's Mutton
    [7939] = { "Darkmoon Faire", 60, 0 }, -- More Dense Grinding Stones
    [7940] = { "Darkmoon Faire", 60, 0, nil, nil, "Orb of the Darkmoon" }, -- 1200 Tickets - Orb of the Darkmoon
    [7941] = { "Darkmoon Faire", 60, 0 }, -- More Armor Kits
    [7942] = { "Darkmoon Faire", 60, 0 }, -- More Thorium Widgets
    [7943] = { "Darkmoon Faire", 60, 0 }, -- More Bat Eyes
    [7981] = { "Darkmoon Faire", 60, 0, nil, nil, "Amulet of the Darkmoon" }, -- 1200 Tickets - Amulet of the Darkmoon
    [8114] = { "Arathi Basin", 60, 9950, "A", "PvP" }, -- Control Four Bases
    [8115] = { "Arathi Basin", 60, 9950, "A", "PvP", "Arathor Battle Tabard" }, -- Control Five Bases
    [8121] = { "Arathi Basin", 60, 9950, "H", "PvP" }, -- Take Four Bases
    [8122] = { "Arathi Basin", 60, 9950, "H", "PvP", "Battle Tabard of the Defilers" }, -- Take Five Bases
    [8152] = { "Eastern Plaguelands", 57, 3000 }, -- Rapid Escape
    [8193] = { "Fishing", 60, 0, nil, nil, "Pick one: arcanite fishing pole, hook of the master angler" }, -- Master Angler
    [8222] = { "Darkmoon Faire", 60, 0 }, -- Glowing Scorpid Blood
    [8223] = { "Darkmoon Faire", 60, 0 }, -- More Glowing Scorpid Blood
    [8232] = { "Hunter", 52, 6350, nil, "Dungeon", "Pick one: devilsaur eye, devilsaur tooth, hunting spear, hunting spear, devilsaur eye, devilsaur tooth" }, -- The Green Drake
    [8236] = { "Rogue", 52, 6350, nil, "Dungeon", "Pick one: duskbat drape, ebon mask, whisperwalk boots, ebon mask, whisperwalk boots, duskbat drape" }, -- The Azure Key
    [8249] = { "Rogue", 60, 0, nil, nil, "Dusksteel Throwing Knife" }, -- Junkboxes Needed
    [8253] = { "Mage", 52, 6350, nil, "Dungeon", "Pick one: glacial spike, fire ruby, arcane crystal pendant, glacial spike, arcane crystal pendant, fire ruby" }, -- Destroy Morphaz
    [8257] = { "Priest", 52, 6350, nil, "Dungeon", "Pick one: blessed prayer beads, circle of hope, woestave, blessed prayer beads, woestave, circle of hope" }, -- Blood of Morphaz
    [8283] = { "Silithus", 59, 8050, nil, "Elite", "Pick one: sandstriders mark, black crystal dagger" }, -- WANTED: Deathclasp, Terror of the Sands
    [8367] = { "Orgrimmar", 60, 8300, "H", "PvP" }, -- For Great Honor
    [8368] = { "Warsong Gulch", 19, 730, "H", "PvP" }, -- Battle of Warsong Gulch
    [8369] = { "Alterac Valley", 60, 8300, "H", "PvP" }, -- Invaders of Alterac Valley
    [8370] = { "Arathi Basin", 29, 2350, "H", "PvP" }, -- Conquering Arathi Basin
    [8371] = { "Arathi Basin", 60, 8300, "A", "PvP" }, -- Concerted Efforts
    [8372] = { "Warsong Gulch", 19, 1450, "A", "PvP" }, -- Fight for Warsong Gulch
    [8374] = { "Arathi Basin", 29, 2350, "A", "PvP" }, -- Claiming Arathi Basin
    [8375] = { "Alterac Valley", 60, 8300, "A", "PvP" }, -- Remember Alterac Valley!
    [8384] = { "Arathi Highlands", 29, 1200, "A", "PvP" }, -- Claiming Arathi Basin
    [8386] = { "Warsong Gulch", 19, 730, "A", "PvP" }, -- Fight for Warsong Gulch
    [8389] = { "Warsong Gulch", 19, 730, "H", "PvP" }, -- Battle of Warsong Gulch
    [8390] = { "Arathi Basin", 29, 1200, "H", "PvP" }, -- Conquering Arathi Basin
    [8391] = { "Arathi Basin", 39, 1500, "A", "PvP" }, -- Claiming Arathi Basin
    [8392] = { "Arathi Basin", 49, 0, "A", "PvP" }, -- Claiming Arathi Basin
    [8393] = { "Arathi Basin", 39, 3000, "A", "PvP" }, -- Claiming Arathi Basin
    [8394] = { "Arathi Basin", 49, 0, "A", "PvP" }, -- Claiming Arathi Basin
    [8395] = { "Arathi Basin", 59, 6400, "A", "PvP" }, -- Claiming Arathi Basin
    [8396] = { "Arathi Basin", 60, 6600, "A", "PvP" }, -- Claiming Arathi Basin
    [8397] = { "Arathi Basin", 59, 3200, "A", "PvP" }, -- Claiming Arathi Basin
    [8398] = { "Arathi Basin", 60, 3300, "A", "PvP" }, -- Claiming Arathi Basin
    [8399] = { "Warsong Gulch", 29, 2350, "A", "PvP" }, -- Fight for Warsong Gulch
    [8400] = { "Warsong Gulch", 39, 3000, "A", "PvP" }, -- Fight for Warsong Gulch
    [8401] = { "Warsong Gulch", 49, 0, "A", "PvP" }, -- Fight for Warsong Gulch
    [8402] = { "Warsong Gulch", 59, 6400, "A", "PvP" }, -- Fight for Warsong Gulch
    [8403] = { "Warsong Gulch", 60, 6600, "A", "PvP" }, -- Fight for Warsong Gulch
    [8404] = { nil, 29, 1200, "A" }, -- Fight for Warsong Gulch
    [8405] = { nil, 39, 3000, "A" }, -- Fight for Warsong Gulch
    [8406] = { nil, 49, 0, "A" }, -- Fight for Warsong Gulch
    [8407] = { "Warsong Gulch", 59, 3200, "A", "PvP" }, -- Fight for Warsong Gulch
    [8408] = { nil, 60, 3300, "A" }, -- Fight for Warsong Gulch
    [8413] = { "Shaman", 52, 6350, nil, "Dungeon", "Pick one: azurite fists, enamored water spirit, wildstaff, azurite fists, enamored water spirit, wildstaff" }, -- Da Voodoo
    [8418] = { "Paladin", 52, 6350, "A", "Dungeon", "Pick one: lightforged blade, chivalrous signet, sanctified orb, holy mightstone, lightforged blade, sanctified orb, chivalrous signet" }, -- Forging the Mightstone
    [8422] = { "Warlock", 52, 6350, nil, "Dungeon", "Pick one: robes of servitude, abyss shard, soul harvester, soul harvester, abyss shard, robes of servitude" }, -- Trolls of a Feather
    [8425] = { "Warrior", 52, 6350, nil, "Dungeon", "Pick one: diamond flask, razorsteel shoulders, fury visor, fury visor, diamond flask, razorsteel shoulders" }, -- Voodoo Feathers
    [8426] = { "Warsong Gulch", 29, 1200, "H", "PvP" }, -- Battle of Warsong Gulch
    [8427] = { "Warsong Gulch", 39, 1500, "H", "PvP" }, -- Battle of Warsong Gulch
    [8428] = { "Warsong Gulch", 49, 0, "H", "PvP" }, -- Battle of Warsong Gulch
    [8429] = { "Warsong Gulch", 59, 6400, "H", "PvP" }, -- Battle of Warsong Gulch
    [8430] = { "Warsong Gulch", 60, 6600, "H", "PvP" }, -- Battle of Warsong Gulch
    [8431] = { "Warsong Gulch", 29, 1200, "H", "PvP" }, -- Battle of Warsong Gulch
    [8432] = { "Warsong Gulch", 39, 1500, "H", "PvP" }, -- Battle of Warsong Gulch
    [8433] = { "Warsong Gulch", 49, 0, "H", "PvP" }, -- Battle of Warsong Gulch
    [8434] = { "Warsong Gulch", 59, 3200, "H", "PvP" }, -- Battle of Warsong Gulch
    [8435] = { "Warsong Gulch", 60, 3300, "H", "PvP" }, -- Battle of Warsong Gulch
    [8436] = { "Arathi Basin", 39, 3000, "H", "PvP" }, -- Conquering Arathi Basin
    [8437] = { "Arathi Basin", 49, 0, "H", "PvP" }, -- Conquering Arathi Basin
    [8438] = { "Arathi Highlands", 59, 6400, "H", "PvP" }, -- Conquering Arathi Basin
    [8439] = { "Arathi Basin", 60, 6600, "H", "PvP" }, -- Conquering Arathi Basin
    [8440] = { "Arathi Basin", 39, 1500, "H", "PvP" }, -- Conquering Arathi Basin
    [8441] = { "Arathi Basin", 49, 0, "H", "PvP" }, -- Conquering Arathi Basin
    [8442] = { "Arathi Basin", 59, 3200, "H", "PvP" }, -- Conquering Arathi Basin
    [8443] = { "Arathi Basin", 60, 3300, "H", "PvP" }, -- Conquering Arathi Basin
    [8461] = { "Blackmaw Hold", 55, 5650, nil, nil, "Pick one:leggings of the ursa, helm of the pathfinder" }, -- Deadwood of the North
    [8464] = { "Blackmaw Hold", 58, 6200, nil, nil, "Pick one:earth warders gloves, gloves of the pathfinder, vest of the den watcher, ursas embrace" }, -- Winterfall Activity
    [8481] = { "Blackmaw Hold", 60, 6600, nil, "Elite", "Defender of the Timbermawdefender of the timbermaw" }, -- The Root of All Evil
    [8484] = { "Blackmaw Hold", 60, 9950, "A" }, -- The Brokering of Peace
    [8485] = { "Blackmaw Hold", 60, 9950, "H" }, -- The Brokering of Peace
    [8551] = { "Stranglethorn Vale", 47, 3150, nil, "Elite", "Pick one: bloodband bracers, freebooters armband" }, -- The Captain's Chest
    [8554] = { "Stranglethorn Vale", 50, 7100, nil, "Elite", "Pick one: smotts compass, smotts pinky ring, first mates armguards" }, -- Facing Negolash
    [8579] = { "Ahn'Qiraj", 60, 6600, nil, "Raid" }, -- Mortal Champions
    [8595] = { "Ahn'Qiraj", 60, 3300, nil, "Raid" }, -- Mortal Champions
    [8784] = { "Ahn'Qiraj", 60, 6600 }, -- Secrets of the Qiraji
    [8788] = { "Winter Veil", 1, 0 }, -- A Gently Shaken Gift
    [8801] = { "Ahn'Qiraj", 60, 9950 }, -- C'Thun's Legacy
    [8802] = { "Ahn'Qiraj", 60, 9950, nil, nil, "Pick one: amulet of the fallen god, cloak of the fallen god, ring of the fallen god" }, -- The Savior of Kalimdor
    [8876] = { "Lunar Festival", 60, 0, nil, nil, "lunar festival fireworks pack" }, -- Small Rockets
    [8879] = { "Lunar Festival", 60, 0, nil, nil, "lunar festival fireworks pack" }, -- Large Rockets
    [8880] = { "Lunar Festival", 60, 0, nil, nil, "lunar festival fireworks pack" }, -- Cluster Rockets
    [8881] = { "Lunar Festival", 60, 0, nil, nil, "lunar festival fireworks pack" }, -- Large Cluster Rockets
    [8945] = { "Stratholme", 60, 8300, nil, "Dungeon", "Ysida's Satchel" }, -- Dead Man's Plea
    [9000] = { "Ironforge", 60, 1650, "A", "Dungeon", "beastmasters cap, beastmasters tunic" }, -- Saving the Best for Last
    [9014] = { "Orgrimmar", 60, 1650, "H", "Dungeon", "sorcerers crown, sorcerers robes" }, -- Saving the Best for Last
    [9053] = { "Druid", 52, 6350, nil, "Dungeon", "Pick one: forests embrace, grizzled pelt, moonshadow stave, grizzled pelt, forests embrace, moonshadow stave" }, -- A Better Ingredient
    [9065] = { "Dustwallow Marsh", 4, 540, nil, nil, "refreshing spring water, minor healing potion" }, -- The "Chow" Quest (123)aa
    [9205] = { "Eastern Plaguelands", 60, 0, nil, nil, "Pick one: insignia of the crusade, insignia of the dawn" }, -- Craftsman's Writ - Plated Armorfish
    [9249] = { "Darkmoon Faire", 60, 0, nil, nil, "Schematic: Steam Tonk Controller" }, -- 40 Tickets - Schematic: Steam Tonk Controller
    [9259] = { "Stranglethorn Vale", 60, 0, "H" }, -- Traitor to the Bloodsail
    [9266] = { "Stranglethorn Vale", 60, 0, "H" }, -- Making Amends
    [9267] = { "The Barrens", 60, 0, "H" }, -- Mending Old Wounds
    [9268] = { "Tanaris", 60, 0, "H" }, -- War at Sea
    [9411] = { nil, 60, 0, nil, nil, "null" }, -- Infused Bandages
    [9412] = { nil, 60, 0, nil, nil, "null" }, -- Crystal Flake Throat Lozenge
    [9413] = { nil, 60, 0, nil, nil, "null" }, -- Crystal Flake Throat Lozenge
    [9414] = { nil, 60, 0, nil, nil, "null" }, -- Infused Bandages
    [9458] = { nil, 60, 0, nil, nil, "PH Potion of Heightened Senses DEP" }, -- Potion of Heightened Senses
    [9459] = { nil, 60, 0, nil, nil, "PH Potion of Heightened Senses DEP" }, -- Anti-crit Potion
    [9477] = { nil, 60, 0, nil, nil, "PH Nature Resist Potion DEP" }, -- Potion of Nature's Armor
    [9478] = { nil, 60, 0, nil, nil, "PH Light Consumable DEP" }, -- Portable Healing Font
    [9479] = { nil, 60, 0, nil, nil, "PH Glorious Standard of the Alliance DEP" }, -- Glorious Standard of the Alliance
    [9480] = { nil, 60, 0, nil, nil, "PH Victorious Standard of the Horde DEP" }, -- Debuff Banner
    [9481] = { nil, 60, 0, nil, nil, "PH Light Consumable DEP" }, -- Light Consumable
    [9482] = { nil, 60, 0, nil, nil, "PH Nature Resist Potion DEP" }, -- Nature Resist Potion
    [65593] = { "Warlock", 20, 1550, "H" }, -- Hearts of the Lovers
    [65597] = { "Warlock", 20, 1550, "H", nil, "Small Soul Pouch" }, -- The Binding
    [65601] = { "Warlock", 20, 390, "H" }, -- Love Hurts
    [65602] = { "Warlock", 20, 1550, "A" }, -- What Is Love?
    [65603] = { "Warlock", 20, 1150, "A", nil, "Small Soul Pouch" }, -- The Binding
    [65604] = { "Warlock", 20, 1150, "H", nil, "Small Soul Pouch" }, -- The Binding
    [65610] = { "Warlock", 27, 2200, "H" }, -- Wish You Were Here
    [76156] = { "Mulgore", 10, 630, "H" }, -- Stalk With The Earthmother
    [76160] = { "Mulgore", 11, 660, "H", nil, "Pine Nut Butter" }, -- Stalk With The Earthmother
    [76240] = { "Mulgore", 11, 880, "H", nil, "Pick one: hoof holstered blade, valley cosh" }, -- Stalk With The Earthmother
    [78088] = { "Paladin", 30, 2450, "A" }, -- A Strange Artifact
    [78089] = { "Paladin", 30, 1850, "A" }, -- Advice From Stormwind
    [78090] = { "Paladin", 30, 0, "A" }, -- A Second Opinion
    [78091] = { "Paladin", 30, 2450, "A" }, -- Earning Your Salt
    [78092] = { "Paladin", 30, 3050, "A" }, -- It Must Be Destroyed
    [78093] = { "Paladin", 30, 3050, "A", nil, "Cloak of the Divine Storm" }, -- Return to Delgren
    [78124] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Nar'thalas Almanac
    [78127] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- The Dalaran Digest
    [78132] = { nil, 25, 2550 }, -- Dragonslayer's Helm
    [78133] = { nil, 25, 2550 }, -- Dragonslayer's Shield
    [78134] = { nil, 25, 2550 }, -- Dragonslayer's Lance
    [78142] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Bewitchments and Glamours
    [78143] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Secrets of the Dreamers
    [78145] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Arcanic Systems Manual
    [78146] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Goaz Scrolls
    [78147] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Crimes Against Anatomy
    [78148] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Runes of the Sorcerer-Kings
    [78149] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Fury of the Land
    [78150] = { "Special", 20, 160, nil, nil, "Pick one: scholarly pendant, erudites amulet" }, -- Friend of the Library
    [78261] = { "Rogue", 23, 1850 }, -- The Horn of Xelthos
    [78270] = { "Rogue", 23, 0, nil, nil, "Breaching Charge" }, -- Goblin Lockpicks
    [78307] = { "Rogue", 23, 2300, nil, nil, "pyrewood signet ring, rune of deadly brew" }, -- The Horn of Xelthos
    [78676] = { "Rogue", 35, 3450 }, -- The Eye of Bhossca
    [78699] = { "Rogue", 35, 3450, nil, nil, "ruby adorned blade, rune of shadowstep" }, -- The Eye of Bhossca
    [78823] = { "Badlands", 40, 1550 }, -- Terror of the Desert Skies
    [78830] = { "Badlands", 40, 3900, nil, nil, "Pick one: well weathered cloak, ponderous loop; Also get: Rune of Expose Weakness" }, -- Terror of the Desert Skies
    [78916] = { "Blackfathom Deeps", 25, 0, "A", "Raid" }, -- The Heart of the Void
    [78917] = { "Blackfathom Deeps", 25, 0, "H", "Raid" }, -- The Heart of the Void
    [79007] = { "The Barrens", 22, 1750, "H", nil, "swiftness potion, lesser trolls blood elixir" }, -- ... and that note you found
    [79008] = { "Westfall", 22, 1750, "A", nil, "swiftness potion, lesser trolls blood elixir" }, -- ... and that note you found
    [79090] = { "Ashenvale", 60, 0, "A", nil, "Silverwing Battle Hymn" }, -- Repelling Invaders
    [79091] = { "Special", 20, 160, "A", nil, "Comprehension Charm" }, -- Archmage Antonidas: The Unabridged Autobiography
    [79092] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Archmage Theocritus' Research Journal
    [79093] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Rumi of Gnomeregan: The Collected Works
    [79094] = { "Special", 20, 160, "H", nil, "Comprehension Charm" }, -- The Lessons of Ta'zo
    [79095] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- The Apothecary's Metaphysical Primer
    [79096] = { "Special", 20, 160, "H", nil, "Comprehension Charm" }, -- Ataeric: On Arcane Curiosities
    [79097] = { "Special", 20, 160, nil, nil, "Comprehension Charm" }, -- Baxtan: On Destructive Magics
    [79098] = { "Ashenvale", 60, 0, "H", nil, "Warsong Battle Drum" }, -- Clear the Forest!
    [79192] = { "The Barrens", 24, 1950, nil, nil, "Pick one: mining pick, farmers shovel; Also get: sturdy lunchbox, simple wood, flint and tinder, old toolbox" }, -- Stepping Stones
    [79229] = { "Desolace", 40, 1550 }, -- Highway Robbery
    [79235] = { "Desolace", 40, 1550 }, -- On the Lam
    [79236] = { "Desolace", 40, 1550 }, -- Cherry for Your Thoughts?
    [79242] = { "Desolace", 40, 3900, nil, nil, "Pick one: determined band, traveled gloves, soldiers visor" }, -- No Honor Among Thieves
    [79358] = { "Shaman", 43, 3600 }, -- Storm, Earth, and Fire
    [79360] = { "Shaman", 33, 3300, "H", "Dungeon" }, -- Elemental Aid
    [79361] = { "Shaman", 43, 3600, "H" }, -- Storm, Earth, and Fire
    [79362] = { "Duskwood", 25, 2000 }, -- Grant's Shield
    [79363] = { "Duskwood", 27, 2200 }, -- Silvia's Sword
    [79364] = { "Shaman", 33, 270, "H" }, -- Eyes on the Sky
    [79365] = { "Shaman", 40, 0, "H" }, -- With Wind Beneath Your Wings
    [79366] = { "Shaman", 40, 3150, "H", "Elite" }, -- Heed My Call
    [79442] = { "Shaman", 40, 3900, "H", nil, "Pick one: lightnings grasp, tidebringers claw, rage of the storm; Also get: elementalists guard, rune of the storm" }, -- The Tempest's Weapons
    [79482] = { "Seasonal", 60, 1650, "A", "Raid" }, -- Stolen Winter Veil Treats
    [79483] = { "Seasonal", 60, 1650, "H", "Raid" }, -- Stolen Winter Veil Treats
    [79492] = { "Seasonal", 60, 4950, "A", "Raid" }, -- Metzen the Reindeer
    [79495] = { "Seasonal", 60, 4950, "H", "Raid" }, -- Metzen the Reindeer
    [79535] = { "Special", 35, 280, nil, nil, "Comprehension Charm" }, -- Basilisks: Should Petrification be Feared?
    [79536] = { "Special", 35, 280, nil, nil, "Pick one: field researchers loop, philanthropists ring" }, -- Greater Friend of the Library
    [79624] = { "Arathi Highlands", 40, 1550 }, -- Anyone Can Cook
    [79637] = { "Seasonal", 40, 0 }, -- A Ticking Present
    [79677] = { "Arathi Highlands", 40, 3150 }, -- A Quick Grocery Run
    [79678] = { "Arathi Highlands", 40, 3150, nil, nil, "shawarmageddon, rune of blood surge" }, -- Taste Testing
    [79731] = { "Priest", 35, 2750 }, -- The Troll Scroll
    [79939] = { "Paladin", 40, 2350, "A" }, -- The Broken Hammer
    [79940] = { "Paladin", 40, 2350, "A" }, -- A Lost Brother
    [79945] = { "Paladin", 40, 2350, "A" }, -- Orders from the Grand Crusader
    [79946] = { "Paladin", 40, 3150, "A", "Dungeon" }, -- A Brother In Need
    [79947] = { "Special", 35, 280, nil, nil, "Comprehension Charm" }, -- Geomancy: The Stone-Cold Truth
    [79948] = { "Special", 35, 280, nil, nil, "Comprehension Charm" }, -- Defensive Magics 101
    [79949] = { "Special", 35, 280, nil, nil, "Comprehension Charm" }, -- A Web of Lies: Debunking Myths and Legends
    [79950] = { "Special", 35, 280, nil, nil, "Comprehension Charm" }, -- Demons and You
    [79951] = { "Special", 35, 280, nil, nil, "Comprehension Charm" }, -- Mummies: A Guide to the Unsavory Undead
    [79952] = { "Special", 35, 280, nil, nil, "Comprehension Charm" }, -- RwlRwlRwlRwl!
    [79963] = { "Paladin", 40, 2350, "A", "Dungeon" }, -- By The Light's Grace
    [79970] = { "Paladin", 40, 2350, "A", nil, "Pauldrons of Vindication" }, -- Aeonas the Vindicated
    [79974] = { "Stonetalon Mountains", 32, 2550, nil, nil, "hickory pipe, rumsey rum light" }, -- Wet Job
    [79975] = { "Stonewrought Dam", 32, 2550 }, -- Eagle's Fist
    [79976] = { "Thoradin's Wall", 32, 1950, nil, nil, "cozy sleeping bag, student fodder" }, -- This Must Be The Place
    [79980] = { "Stonetalon Mountains", 24, 200, nil, nil, "Pick one: silver star, moonsight rifle, precision bow; Also get: feathered arrow, exploding shot, student fodder" }, -- Scramble
    [80001] = { "Stonetalon Mountains", 40, 0, nil, nil, "Flint and Tinder" }, -- Rekindle
    [80241] = { "Blacksmithing", 40, 3150, "A", nil, "Plans: Golden Scale Gauntlets" }, -- The Origins of Smithing
    [80324] = { "Gnomeregan", 40, 0, "A", "Raid" }, -- The Mad King
    [80325] = { "Gnomeregan", 40, 0, "H", "Raid" }, -- The Mad King
    [80411] = { "Rogue", 50, 4700 }, -- The Talisman of Kazdor
    [80453] = { "Rogue", 50, 470 }, -- Best Laid Plans
    [80454] = { "Rogue", 50, 4700 }, -- One Last Drop
    [80455] = { "Rogue", 50, 5900, nil, nil, "rune of the coterie" }, -- Biding Our Time
    [80526] = { "Rogue", 50, 470 }, -- Fool Me Twice
    [81570] = { "Dustwallow Marsh", 35, 3450, nil, nil, "reedknot ring, artisans trousers" }, -- Jarl Needs a Blade
    [81762] = { "Paladin", 50, 2350, "A" }, -- Some Good News
    [81764] = { "Paladin", 50, 4700, "A" }, -- The Mysterious Merchant
    [81765] = { "Paladin", 50, 5900, "A" }, -- Elrick, Paladin of the Silver Hand
    [81766] = { "Paladin", 50, 4700, "A" }, -- The Bloody Missive
    [81790] = { "Paladin", 53, 6550, "A", "Dungeon" }, -- Materials of Significance
    [81885] = { "Paladin", 53, 6550, "A" }, -- The Ritual
    [81900] = { "Badlands", 54, 2700 }, -- The Burning Beast
    [81917] = { "Blasted Lands", 54, 5450 }, -- Chains That Bind
    [81919] = { "Blasted Lands", 54, 6800, nil, "Elite", "infernal lasso, rune of the ravenous" }, -- Brought to Heel
    [81924] = { "Druid", 50, 5900, nil, nil, "rune of efflorescence" }, -- Wisdom of the Guardians
    [81944] = { "Paladin", 53, 6550, "A", nil, "Symbol of Faith" }, -- A Newly Discovered Purpose...
    [81947] = { "Special", 45, 390, nil, nil, "Comprehension Charm" }, -- Sanguine Sorcery
    [81949] = { "Special", 45, 390, nil, nil, "Comprehension Charm" }, -- Legends of the Tidesages
    [81952] = { "Special", 45, 390, nil, nil, "Comprehension Charm" }, -- Everyday Etiquette
    [81953] = { "Special", 45, 390, nil, nil, "Comprehension Charm" }, -- Stonewrought Design
    [81954] = { "Special", 45, 390, nil, nil, "Comprehension Charm" }, -- Venomous Journeys
    [81955] = { "Special", 45, 390, nil, nil, "Comprehension Charm" }, -- A Mind of Metal
    [81956] = { "Special", 45, 390, nil, nil, "Comprehension Charm" }, -- Conjurer's Codex
    [82062] = { "Blackrock Depths", 56, 7300, nil, nil, "premos poise demanding uniform, student fodder, travelers symbols" }, -- Ever After
    [82068] = { "Nightmare Incursions", 52, 6350, nil, "Elite" }, -- Fight the Nightmare Incursions
    [82084] = { "Mage", 45, 3900, nil, nil, "Personal Spellbook" }, -- A Lesson in Literacy
    [82135] = { "Paladin", 53, 6550, "A", nil, "Whisper" }, -- The Price of Hope
    [82208] = { "Special", 45, 390, nil, nil, "Pick one: truthseekers bow, crest of elucidation, researchers night light" }, -- Greater Friend of the Library
    [82656] = { "Leatherworking", 45, 2900, "H", nil, "Pattern: Wild Leather Vest" }, -- Wild Leather Vest
    [82657] = { "Leatherworking", 45, 2900, "A", nil, "Pattern: Wild Leather Vest" }, -- Wild Leather Vest
    [82662] = { "Blacksmithing", 40, 3150, "A" }, -- The Way of the Weaponsmith
    [83934] = { "Stranglethorn Vale", 60, 8300 }, -- Show Me the Money!
    [84124] = { "Warrior", 60, 6600, nil, nil, "old guard retaliator, rune of the first warrior" }, -- Legacy of Valor
    [84135] = { "Land's End Beach", 60, 1650, nil, nil, "Guided Buoyancy Accelerant" }, -- Beach Bot
    [84137] = { "South Seas", 60, 4950 }, -- Mechanical Romance
    [84138] = { "South Seas", 60, 4950 }, -- Frosty Favors
    [84146] = { "Winterspring", 60, 6600, nil, nil, "Red Bag" }, -- Red Bag Blues
    [84147] = { "Ironforge", 60, 6600, "A", "Dungeon", "Pick one: feralheart wristguards, feralheart bands, feralheart bindings, feralheart wraps" }, -- An Earnest Proposition
    [84148] = { "Ironforge", 60, 6600, "A", "Dungeon", "Pick one: beastmasters bindings; Also get: Beastmaster's Bindings" }, -- An Earnest Proposition
    [84149] = { "Ironforge", 60, 6600, "A", "Dungeon", "Sorcerer's Bindings, Sorcerer's Bindings" }, -- An Earnest Proposition
    [84150] = { "Ironforge", 60, 6600, "A", "Dungeon", "Pick one: soulforge wristguards, soulforge bindings, soulforge bracers" }, -- An Earnest Proposition
    [84151] = { "Ironforge", 60, 6600, "A", "Dungeon", "Pick one: virtuous wraps, virtuous bracers" }, -- An Earnest Proposition
    [84152] = { "Ironforge", 60, 6600, "A", "Dungeon", "Pick one: darkmantle bracers; Also get: Darkmantle Bracers" }, -- An Earnest Proposition
    [84153] = { "Ironforge", 60, 6600, "A", "Dungeon", "Pick one: deathmist bracers; Also get: Deathmist Bracers" }, -- An Earnest Proposition
    [84154] = { "Ironforge", 60, 6600, "A", "Dungeon", "Pick one: wristguards of heroism, bracers of heroism" }, -- An Earnest Proposition
    [84155] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Pick one: feralheart wraps, feralheart bindings, feralheart bands, feralheart wristguards" }, -- An Earnest Proposition
    [84156] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Pick one: beastmasters bindings; Also get: Beastmaster's Bindings" }, -- An Earnest Proposition
    [84157] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Sorcerer's Bindings" }, -- An Earnest Proposition
    [84158] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Pick one: virtuous bracers, virtuous wraps" }, -- An Earnest Proposition
    [84159] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Pick one: darkmantle bracers; Also get: Darkmantle Bracers" }, -- An Earnest Proposition
    [84160] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Pick one: bindings of the five thunders, bracers of the five thunders, bands of the five thunders" }, -- An Earnest Proposition
    [84161] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Pick one: deathmist bracers; Also get: Deathmist Bracers" }, -- An Earnest Proposition
    [84162] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Pick one: bracers of heroism, wristguards of heroism" }, -- An Earnest Proposition
    [84163] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: feline gloves and belt set, astral gloves and belt set, guardians gloves and belt set, menders gloves and belt set" }, -- Just Compensation
    [84164] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: pursuers gloves and belt set; Also get: beastmasters gauntlets, beastmasters belt" }, -- Just Compensation
    [84165] = { "Ironforge", 60, 9950, "A", "Dungeon", "sorcerers belt, sorcerers gauntlets" }, -- Just Compensation
    [84166] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: merciful gloves and belt set, radiant gloves and belt set, divine will gloves and belt set" }, -- Just Compensation
    [84167] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: dawn gloves and belt set, twilight gloves and belt set" }, -- Just Compensation
    [84168] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: thrills gloves and belt set; Also get: darkmantle grips, darkmantle belt" }, -- Just Compensation
    [84169] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: corrupted gloves and belt set; Also get: deathmist wraps, deathmist belt" }, -- Just Compensation
    [84170] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: immoveable gloves and belt set, unstoppable gloves and belt set" }, -- Just Compensation
    [84171] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: feline gloves and belt set, astral gloves and belt set, guardians gloves and belt set, menders gloves and belt set" }, -- Just Compensation
    [84172] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: pursuers gloves and belt set; Also get: beastmasters gauntlets, beastmasters belt" }, -- Just Compensation
    [84173] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "sorcerers belt, sorcerers gauntlets" }, -- Just Compensation
    [84174] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: dawn gloves and belt set, twilight gloves and belt set" }, -- Just Compensation
    [84175] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: thrills gloves and belt set; Also get: darkmantle grips, darkmantle belt" }, -- Just Compensation
    [84176] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: reliefs gloves and belt set, eruptions gloves and belt set, impacts gloves and belt set" }, -- Just Compensation
    [84177] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: corrupted gloves and belt set; Also get: deathmist wraps, deathmist belt" }, -- Just Compensation
    [84178] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: immoveable gloves and belt set, unstoppable gloves and belt set" }, -- Just Compensation
    [84179] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: feline boots legs and shoulders set, astral boots legs and shoulders set, guardians boots legs and shoulders set, menders boots legs and shoulders set" }, -- Anthion's Parting Words
    [84180] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: pursuers boots legs and shoulders set; Also get: beastmasters treads, beastmasters pants, beastmasters mantle" }, -- Anthion's Parting Words
    [84181] = { "Ironforge", 60, 9950, "A", "Dungeon", "sorcerers sandals, sorcerers leggings, sorcerers mantle" }, -- Anthion's Parting Words
    [84182] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: merciful boots legs and shoulders set, radiant boots legs and shoulders set, divine will boots legs and shoulders set" }, -- Anthion's Parting Words
    [84183] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: dawn boots legs and shoulders set, twilight boots legs and shoulders set" }, -- Anthion's Parting Words
    [84184] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: thrills boots legs and shoulders set; Also get: darkmantle footpads, darkmantle pants, darkmantle spaulders" }, -- Anthion's Parting Words
    [84186] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: immoveable boots legs and shoulders set, unstoppable boots legs and shoulders set" }, -- Anthion's Parting Words
    [84187] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: feline boots legs and shoulders set, astral boots legs and shoulders set, guardians boots legs and shoulders set, menders boots legs and shoulders set" }, -- Anthion's Parting Words
    [84188] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: pursuers boots legs and shoulders set; Also get: beastmasters treads, beastmasters pants, beastmasters mantle" }, -- Anthion's Parting Words
    [84189] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "sorcerers sandals, sorcerers leggings, sorcerers mantle" }, -- Anthion's Parting Words
    [84190] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: dawn boots legs and shoulders set, twilight boots legs and shoulders set" }, -- Anthion's Parting Words
    [84191] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: thrills boots legs and shoulders set; Also get: darkmantle footpads, darkmantle pants, darkmantle spaulders" }, -- Anthion's Parting Words
    [84192] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: reliefs boots legs and shoulders set, eruptions boots legs and shoulders set, impacts boots legs and shoulders set" }, -- Anthion's Parting Words
    [84193] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: corrupted boots legs and shoulders set; Also get: deathmist sandals, deathmist leggings, deathmist mantle" }, -- Anthion's Parting Words
    [84194] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: immoveable boots legs and shoulders set, unstoppable boots legs and shoulders set" }, -- Anthion's Parting Words
    [84195] = { "Ironforge", 60, 1650, "A", "Dungeon", "Pick one: feline helm and chestpiece set, astral helm and chestpiece set, guardians helm and chestpiece set, menders helm and chestpiece set" }, -- Saving the Best for Last
    [84196] = { "Ironforge", 60, 1650, "A", "Dungeon", "Pick one: pursuers helm and chestpiece set; Also get: beastmasters cap, beastmasters tunic" }, -- Saving the Best for Last
    [84200] = { "Ironforge", 60, 1650, "A", "Dungeon", "Pick one: thrills helm and chestpiece set; Also get: darkmantle cap, darkmantle tunic" }, -- Saving the Best for Last
    [84202] = { "Ironforge", 60, 1650, "A", "Dungeon", "Pick one: immoveable helm and chestpiece set, unstoppable helm and chestpiece set" }, -- Saving the Best for Last
    [84203] = { "Orgrimmar", 60, 1650, "H", "Dungeon", "Pick one: feline helm and chestpiece set, astral helm and chestpiece set, guardians helm and chestpiece set, menders helm and chestpiece set" }, -- Saving the Best for Last
    [84208] = { "Orgrimmar", 60, 1650, "H", "Dungeon", "Pick one: reliefs helm and chestpiece set, eruptions helm and chestpiece set, impacts helm and chestpiece set" }, -- Saving the Best for Last
    [84210] = { "Orgrimmar", 60, 1650, "H", "Dungeon", "Pick one: immoveable helm and chestpiece set, unstoppable helm and chestpiece set" }, -- Saving the Best for Last
    [84211] = { "Burning Steppes", 60, 6600, nil, nil, "Fantastic Inventions" }, -- Poacher's Den
    [84212] = { "Winterspring", 60, 6600 }, -- Bookin' it Back
    [84213] = { "South Seas", 62, 10550, nil, "Elite", "sun shades, premonition and combat foresight" }, -- Rift Away
    [84318] = { "Paladin", 57, 6000, "A" }, -- Oi!
    [84319] = { "Paladin", 58, 6200, "A" }, -- Oh No Ye Don't!
    [84330] = { "Paladin", 59, 8050, "A", "Dungeon" }, -- A Wee Bit O' Necromancy
    [84332] = { "Paladin", 59, 8050, "A", nil, "Hammer of the Fallen Thane, Hammer of the Fallen Thane" }, -- A Thane's Gratitude
    [84377] = { "Stormwind City", 60, 9950, "A" }, -- End of the Dark Horde
    [84394] = { "Special", 58, 620, nil, nil, "Pick one: antique bulwark, museum keepers chain, artifact seekers pendant" }, -- Greater Friend of the Library
    [84395] = { "Special", 60, 660, nil, nil, "Comprehension Charm" }, -- Undead Potatoes
    [84396] = { "Special", 60, 660, nil, nil, "Comprehension Charm" }, -- Magma or Lava?
    [84397] = { "Special", 60, 660, nil, nil, "Comprehension Charm" }, -- Northern Kalimdor - A Comprehensive Guide
    [84398] = { "Special", 60, 660, nil, nil, "Comprehension Charm" }, -- A Study of the Light
    [84399] = { "Special", 60, 660, nil, nil, "Comprehension Charm" }, -- Ka-Boom!
    [84400] = { "Special", 60, 660, nil, nil, "Comprehension Charm" }, -- The Knight and the Lady
    [84401] = { "Special", 60, 660, nil, nil, "Comprehension Charm" }, -- Scourge: Undead Menace or Misunderstood?
    [84402] = { "Special", 60, 660, nil, nil, "Comprehension Charm" }, -- Necromancy 101
    [84414] = { "Paladin", 59, 3200, "A" }, -- Send Me On Me Way
    [84555] = { "Dire Maul", 60, 9950, "A", "Dungeon" }, -- Nostro's Compendium
    [85712] = { "Blacksmithing", 40, 3150, "H" }, -- The Art of the Armorsmith
    [85713] = { "Blacksmithing", 40, 3150, "A" }, -- The Art of the Armorsmith
    [86574] = { "Stonetalon Mountains", 24, 1950, "A", nil, "Courier's Wristguards" }, -- Stonetalon Supply Run
    [86576] = { "Stonetalon Mountains", 26, 2100, "H", nil, "Harpy Claw Ring" }, -- Bloodfury Trinkets
    [86577] = { "Felwood", 55, 5650 }, -- A Sampling of Putrescence
    [86585] = { "Loch Modan", 17, 1250, "A", nil, "Pick one: mountaineers greataxe, invaders mace" }, -- Banner of the Fallen
    [86611] = { "Felwood", 55, 2800, "A" }, -- Stag Lord's Bauble
    [86612] = { "Felwood", 55, 2800, "H" }, -- Stag Lord's Bauble
    [86613] = { "Loch Modan", 18, 1350, "A" }, -- Excavation Tools
    [86614] = { "Loch Modan", 20, 1550, "A", nil, "Repurposed Hair Band" }, -- Silver of the Waves
    [86615] = { "Aerie Peak", 51, 490, "A" }, -- Treaty Obligations
    [86616] = { "The Hinterlands", 48, 4400, "A" }, -- Repurposed Totems
    [86620] = { "Aerie Peak", 51, 4900, "A" }, -- Fledgling Rescue
    [86667] = { "Loch Modan", 10, 420, "A" }, -- Snowbound
    [86746] = { "Azshara", 53, 5250 }, -- The Legashi Threat
    [86747] = { "Azshara", 53, 530 }, -- Legashi Horns
    [86752] = { "Azshara", 53, 530 }, -- Report to Rageroar
    [86757] = { "Ashenvale", 30, 2450, "A" }, -- Slowing the Orc Advance
    [86758] = { "Loch Modan", 16, 1150, "A", nil, "Daggerfang's Daggerfang" }, -- Twisting the Knife
    [86776] = { "Loch Modan", 30, 2450, "A", nil, "Tin Bar" }, -- Ingredients for the Forge
    [86777] = { "Azshara", 53, 5250, "H", nil, "Pick one: feardreds cleansed amulet, rageroars best club, adventurers lost boots" }, -- Master Feardred
    [86784] = { "Tirisfal Glades", 7, 630, "H", nil, "Collecting Basket" }, -- Sticks and Bones
    [86791] = { "Azshara", 53, 530, "H" }, -- Missing Blackmaw Scouts
    [86792] = { "Azshara", 54, 5450, "H" }, -- Thinning Their Forces
    [86796] = { "Azshara", 54, 5450, "H" }, -- Later, Satyr
    [86797] = { "Azshara", 53, 530, "H" }, -- Return to Rageroar
    [86798] = { "Blackmaw Hold", 55, 560 }, -- Timbermaw Reinforcements
    [86799] = { "Azshara", 53, 530 }, -- Encroaching Corruption
    [86804] = { "Azshara", 53, 3950 }, -- An Unlikely Source
    [86812] = { "Azshara", 53, 3950, nil, nil, "Manual: Powerful Poultice" }, -- Transmuted Tincture
    [86813] = { "Azshara", 53, 2650, nil, nil, "Pick one: timbermaw prayer beads, mourners shroud, amice of sorrow" }, -- Potential Panacea
    [86814] = { "Azshara", 55, 7050, nil, "Elite", "Pick one: sacred bangle, cliff walkers cinch, hippogryph hide boots" }, -- Blackmaw Counter-Offensive
    [86925] = { "Azshara", 53, 5250 }, -- Toil and Trouble
    [86926] = { "Azshara", 53, 5250 }, -- Felfire Burn, Cauldron Bubble
    [86927] = { "Azshara", 53, 5250, nil, nil, "Recipe: Distilled Firewater" }, -- Running Firewater
    [87288] = { "Teldrassil", 7, 630, "A", nil, "Soft Saber Sack" }, -- Soft Saber Pelts
    [87295] = { "Blasted Lands", 52, 5100, "A" }, -- Deflective Surface
    [87318] = { "Wetlands", 33, 2650, "A", "Elite" }, -- Hearts of the Lost
    [87346] = { "Azshara", 55, 5650 }, -- Chieftain Bloodmaw
    [87451] = { "Blasted Lands", 55, 5650, "H", nil, "Pick one: stonard stompers, ancestral waistcord" }, -- Memories of Rockard
    [87491] = { "Wetlands", 30, 2450, "A", "Elite" }, -- Spark of Freedom
    [87492] = { "Un'Goro Crater", 55, 5650 }, -- Uncanny Crystal
    [87494] = { "Un'Goro Crater", 55, 5650, nil, nil, "Pick one: crystal flecked cord, crystal flecked waistguard" }, -- Microcrystal Contamination
    [87760] = { "Darkshore", 20, 1550, "A", nil, "draught of water breathing, swim speed potion" }, -- Holy Diver
    [88756] = { "Wetlands", 31, 2500, "A", "Elite", "Ez-Thro Dynamite" }, -- Bring Back a Bang
    [88757] = { "Wetlands", 33, 2650, "A", "Elite" }, -- Accessories of the Lost
    [88758] = { "Wetlands", 33, 2650, "A", "Elite", "Essene's Hope" }, -- Sentiments of the Lost
    [88807] = { "Azshara", 48, 4400, "A" }, -- Slay the Spitelash
    [88809] = { "Azshara", 52, 5100, "A" }, -- Preserving Eldarath
    [88812] = { "Azshara", 55, 5650, "A" }, -- Reclaiming Ravencrest
    [88813] = { "Azshara", 55, 5650, "A", nil, "Pick one: prelates orb, truesongs hammer" }, -- The Head of the Serpent
    [88821] = { "Azshara", 51, 490, "A" }, -- Making Contact
    [88857] = { "Azshara", 47, 4200, "A" }, -- Saving a Sentinel
    [88884] = { "Azshara", 52, 5100, "A" }, -- Highborne Tablets
    [88917] = { "Azshara", 52, 5100, "A" }, -- Slithering Looters
    [89001] = { "Azshara", 48, 4400, "A" }, -- Home on the Range
    [89013] = { "Azshara", 48, 4400, "A", nil, "berduns trusty rifle, recipe potion of beast slaying, potion of beast slaying" }, -- Gettin' Buzzed
    [89015] = { "Azshara", 56, 5800, "A", "Elite", "Pick one: a bigger shield, panic hands, bad hat" }, -- Deadliest Catch
    [89037] = { "Azshara", 52, 5100, "A", nil, "Pick one: scouts dagger, sentinels plate, elunar belt" }, -- Murloc Thieves
    [89038] = { "Azshara", 55, 5650, "A" }, -- A Monumental Task
    [89053] = { "Azshara", 55, 5650, "A", nil, "Pick one: highborne memory crystal, highborne research tablet, staff of archmage selwyn" }, -- Your Final Reward
    [89228] = { "Azshara", 48, 4400, "A" }, -- Winter Frontier Fishery
    [89470] = { "Azshara", 55, 2800, "A" }, -- Ill Tidings
    [90487] = { "Mount Hyjal", 56, 580 }, -- Ancient Allies
    [90647] = { "Mount Hyjal", 57, 6000 }, -- The Staff of the Mountain
    [90702] = { "Mount Hyjal", 58, 6200, "A" }, -- Disturbed Grave
    [90750] = { "Mount Hyjal", 55, 560, "A" }, -- More Work?
    [90789] = { "Mage", 60, 6600 }, -- Scalebeard
    [90813] = { "Azshara", 53, 6550, "A", nil, "Big Bag o' Gold" }, -- Pay Dirt!
    [90854] = { "Mount Hyjal", 57, 4500, "H", nil, "Pick one: forgotten trompers, abandoned boots; Also get: pattern tooled leather armor, pattern supple scorpid vest" }, -- Leather for Inclement Weather
    [90865] = { "Mount Hyjal", 58, 6200 }, -- Eyes of the Watchers
    [90902] = { "Paladin", 2, 90, "H" }, -- Rediscovering the Light
    [91208] = { "Paladin", 4, 180, "H" }, -- Coming to Terms
    [91209] = { "Paladin", 4, 90, "H" }, -- Continue Your Training
    [91282] = { "Paladin", 11, 220, "H" }, -- A Second Home
    [91285] = { "Paladin", 11, 880, "H", nil, "Pick one: skullthumper, driftwood smasher" }, -- Murlocs at the Gates
    [91294] = { "Paladin", 11, 440, "H" }, -- Touring the Grounds
    [91316] = { "Paladin", 11, 880, "H", nil, "Salvaged Wooden Tower Shield" }, -- Making Repairs
    [91317] = { "Paladin", 12, 910, "H" }, -- The Tarnished
    [91488] = { "Azshara", 48, 4400, "H" }, -- Home on the Range
    [91497] = { "Azshara", 53, 5250, "H" }, -- Seals of the Sin'dorei
    [91500] = { "Azshara", 55, 4200, "H" }, -- An Explosive Gambit
    [91531] = { "Orgrimmar", 55, 5650, "H", nil, "Pick one: pyrestone orb, belgroms hammer, belgroms revenge" }, -- Revenge Exacted
    [91538] = { "Azshara", 55, 560, "H" }, -- Sin'dorei Tome of Summoning
    [91547] = { "Azshara", 55, 560, "H" }, -- Sin'dorei Tome of Summoning
    [91548] = { "Blasted Lands", 55, 7050, "H", "Elite", "Pick one: darkblade, headdress of the damned, belt of shadows" }, -- Vek'zol
    [91564] = { "Mount Hyjal", 57, 3000, "A", nil, "thorium grenade, schematic dimensional transporter mt hyjal" }, -- Itching for a Fixing
    [91568] = { "Azshara", 51, 4900, "H" }, -- Long Walks on the Beach
    [91569] = { "Azshara", 53, 3950, "H" }, -- Blue Gold
    [91607] = { "Azshara", 53, 6550, "H", nil, "Big Bag o' Gold" }, -- Pay Dirt!
    [91608] = { "Azshara", 48, 4400, "H", nil, "berduns trusty rifle, recipe potion of beast slaying, potion of beast slaying" }, -- Gettin' Buzzed
    [91610] = { "Azshara", 48, 4400, "H", nil, "Deep-Sea Waders" }, -- Winter Frontier Fishery
    [91611] = { "Azshara", 56, 5800, "H", "Elite", "Pick one: a bigger shield, panic hands, bad hat" }, -- Deadliest Catch
    [91685] = { "Azshara", 54, 6800, "H", "Elite", "Pick one: assassins dagger, honor guards plate, barkwoven belt" }, -- Ley of the Land
    [91688] = { "Mount Hyjal", 59, 640, "A" }, -- To the Summit of Eternity
    [91696] = { "Mount Hyjal", 58, 6200, nil, nil, "Scented Runewood Brooch" }, -- Open Season
    [91697] = { "Mount Hyjal", 57, 600 }, -- Meet the Elders
    [91698] = { "Mount Hyjal", 58, 4650 }, -- Barkskin Breakout
    [91723] = { "Elwynn Forest", 8, 530, "A" }, -- Delicate Instruments
    [91724] = { "Elwynn Forest", 10, 840, "A" }, -- Delicate Instruments
    [91725] = { "Elwynn Forest", 10, 630, "A" }, -- Stolen Enchanting Supplies
    [91732] = { "Elwynn Forest", 7, 320, "A" }, -- Good Steel
    [91733] = { "Elwynn Forest", 10, 630, "A" }, -- Downstream
    [91734] = { "Azshara", 52, 510, "H" }, -- Remote Contact
    [91735] = { "Azshara", 52, 510, "H" }, -- Remote Contact
    [91736] = { "Elwynn Forest", 1, 0, "A", nil, "Thunder Applejack" }, -- Applejack Still
    [91737] = { "Azshara", 52, 510, "H" }, -- Remote Contact
    [91738] = { "Elwynn Forest", 10, 630, "A" }, -- An Apple Treat
    [91740] = { "Elwynn Forest", 11, 880, "A" }, -- Croaky's Head
    [91741] = { "Elwynn Forest", 2, 90, "A" }, -- Nibbled-On Book
    [91743] = { "Elwynn Forest", 2, 170, "A", nil, "Pick one: pelt collecting for beginners, wild harvest, mining for dummies" }, -- Rascally Rodents
    [91745] = { "Elwynn Forest", 3, 30, "A" }, -- Mining Consultant
    [91746] = { "Elwynn Forest", 12, 910, "A" }, -- Elmpaw's Head
    [91751] = { "Elwynn Forest", 8, 700, "A" }, -- Rough Wolf Pelts
    [91752] = { "Elwynn Forest", 3, 320, "A", "Elite" }, -- The Big Picture
    [91753] = { "Elwynn Forest", 7, 480, "A" }, -- An Enchanting Lesson
    [91754] = { "Mount Hyjal", 56, 2900 }, -- Rub Some Dirt In It
    [91755] = { "Mount Hyjal", 56, 5800 }, -- Leaves to Ligatures
    [91758] = { "Elwynn Forest", 4, 40, "A" }, -- Follow That Kobold!
    [91770] = { "Mount Hyjal", 56, 580, nil, nil, "Heavy Runecloth Bandage" }, -- Bark Bite
    [91772] = { "Elwynn Forest", 4, 360, "A" }, -- Shhh! We're Hunting Kobolds
    [91775] = { "Elwynn Forest", 6, 680, "A", "Elite", "Book Bag" }, -- Book Return
    [91777] = { "Elwynn Forest", 7, 790, "A", "Elite", "Pick one: apprentices spellstaff, militia shortblade, militia sword, northshire hammer, militia bow" }, -- Rare Books
    [91794] = { "Mount Hyjal", 59, 8050, "H", "Elite", "Pick one: demonbane blade, demonbane knife" }, -- Flags of Our Forebears
    [91858] = { "Paladin", 22, 440, "H" }, -- Diplomatic Incident
    [91859] = { "Paladin", 22, 440, "H" }, -- A Curious Pair
    [91860] = { "Paladin", 22, 440, "H" }, -- A Grim Fate
    [91861] = { "Paladin", 22, 440, "H" }, -- Into Fenris Keep
    [91862] = { "Paladin", 22, 1750, "H" }, -- Lumina Windsinger
    [91877] = { "Azshara", 55, 560 }, -- Demon Hunter's Hunter
    [91881] = { "Mount Hyjal", 57, 600, "A" }, -- The Western Post
    [91882] = { "Blasted Lands", 55, 560, "A" }, -- The Grand Alliance
    [91883] = { "Mount Hyjal", 59, 4800 }, -- Spear of the Skylord
    [91899] = { nil, 60, 0 }, -- A Sealed Crate
    [91900] = { nil, 60, 0 }, -- A Sealed Crate
    [91901] = { nil, 60, 0 }, -- A Sealed Crate
    [91902] = { nil, 60, 0 }, -- A Sealed Crate
    [91904] = { nil, 60, 0 }, -- A Sealed Crate
    [91905] = { nil, 60, 0 }, -- A Sealed Crate
    [91906] = { nil, 60, 0 }, -- A Sealed Crate
    [91907] = { nil, 60, 0 }, -- A Sealed Crate
    [91920] = { "Silverpine Forest", 11, 440, "H", nil, "recipe minor discolored healing potion, minor discolored healing potion" }, -- Wild Eyes
    [91921] = { "Silverpine Forest", 11, 660, "H" }, -- Return to Quinn (Again)
    [91923] = { "Mount Hyjal", 57, 7550, nil, "Elite", "Pick one: brush cutter, weed whacker, deadhead blade" }, -- Celastrus the Bitter
    [91952] = { "Felwood", 55, 560 }, -- The Source of the Corruption
    [92008] = { "Mount Hyjal", 56, 2900 }, -- Premiere Parts
    [92009] = { "Mount Hyjal", 56, 5800 }, -- Crate Expectations
    [92011] = { "Mount Hyjal", 58, 6200, nil, nil, "Power Recycler" }, -- Rubble Rummage
    [92014] = { "Mount Hyjal", 57, 6000, "A", nil, "Foxtail Ward" }, -- Fox Hole
    [92015] = { "Mount Hyjal", 56, 1450, "A" }, -- Area Denial Skunks
    [92016] = { "Mount Hyjal", 60, 3300 }, -- Rootwork
    [92017] = { "Mount Hyjal", 59, 4800 }, -- Cleansing Winds
    [92020] = { "Un'Goro Crater", 55, 560 }, -- Hol'anyee's Big Book of Big Lizards
    [92064] = { "Mount Hyjal", 56, 580, "A" }, -- Tree Free
    [92065] = { "Blackmaw Hold", 60, 6600, nil, "Dungeon" }, -- Blackmaw Reclamation
    [92066] = { "Blackmaw Hold", 55, 5650, nil, "Dungeon" }, -- The Twin Bears
    [92067] = { "Blackmaw Hold", 55, 0, nil, "Dungeon", "Regurgitated Seed Pod" }, -- Feeding Time!
    [92069] = { "Blackmaw Hold", 58, 6200, nil, "Dungeon" }, -- Claws That Rend, Tusks that Gore
    [92070] = { "Blackmaw Hold", 55, 5650, nil, "Dungeon", "Nama's Cherished Necklace" }, -- A Lost Memento
    [92094] = { "Mount Hyjal", 57, 600, "A" }, -- Rocket Gnomes
    [92100] = { "Mount Hyjal", 58, 4650 }, -- Anywhere But Here
    [92101] = { "Mount Hyjal", 58, 6200 }, -- Lifted by Legacy
    [92102] = { "Mount Hyjal", 58, 6200 }, -- Praise
    [92109] = { "Westfall", 10, 420, "A", nil, "Pick one: minor healing potion, scribbled i o u" }, -- My First Alchemy Set
    [92110] = { "Westfall", 10, 420, "A", nil, "recipe minor discolored healing potion, minor discolored healing potion" }, -- My First Real Potion
    [92111] = { "Mount Hyjal", 57, 600 }, -- Of Friend and Fur
    [92124] = { "Elwynn Forest", 2, 20, "A" }, -- Book Inventory
    [92147] = { "Mount Hyjal", 58, 6200 }, -- Highfeather Helper
    [92169] = { "Mount Hyjal", 59, 8050, nil, "Elite" }, -- Paying Back the Pact
    [92171] = { "Mount Hyjal", 58, 620 }, -- Taking to New Heights
    [92189] = { "Mount Hyjal", 57, 4500, "A", nil, "lost veterans sabatons, plans bold dirk" }, -- Back to the Grind
    [92317] = { "Mount Hyjal", 58, 4650 }, -- Stolen Life
    [92328] = { "Mount Hyjal", 56, 1450 }, -- Siegecraft
    [92329] = { "Mount Hyjal", 60, 8300, nil, "Elite", "Pick one: copper plated pipe, glaive thrower muffler, yaelys mending tool" }, -- Drum Up Trouble
    [92335] = { "Mount Hyjal", 59, 1600 }, -- Ashes of the Legion Ascent
    [92343] = { "Blackmaw Hold", 55, 5650, nil, "Dungeon" }, -- Get to the Roots of It
    [92344] = { "Blackmaw Hold", 55, 5650, nil, "Dungeon" }, -- Get to the Roots of It
    [92345] = { "Azshara", 55, 560, "A" }, -- Beneath Nordrassil
    [92346] = { "Azshara", 55, 560, "H" }, -- Beneath Nordrassil
    [92401] = { "Ruins of Lordaeron", 22, 2200, nil, "Dungeon" }, -- A Frightened Request
    [92415] = { "Ruins of Lordaeron", 22, 2600, nil, "Dungeon" }, -- Remember That I Love You
    [92421] = { "Ruins of Lordaeron", 22, 2200, nil, "Dungeon" }, -- Light's Justice
    [92422] = { "Ruins of Lordaeron", 22, 2200, nil, "Dungeon" }, -- The Wrath of Rath'mael
    [92432] = { "Alterac Mountains", 33, 660, "A" }, -- An Alarming Request
    [92433] = { "Mount Hyjal", 57, 3000, "A", nil, "recipe steaming stag steak, steaming stag steak" }, -- Now We're Cooking
    [92434] = { "Alterac Mountains", 34, 270, "H" }, -- Blood in the Streets
    [92446] = { "Mount Hyjal", 60, 8300, "H", "Elite", "Pick one: elderwild construction hammer, greatflank flayer, natures cull" }, -- Head Scratcher
    [92449] = { "Mount Hyjal", 58, 6200, "A", nil, "Greaves of Mourning" }, -- Blight No More
    [92454] = { "Zephras Isle", 1, 0, nil, nil, "Pick one: diablo stone, panda collar, zergling leash" }, -- Welcome!
    [92456] = { "City of Dalaran", 33, 3950, nil, "Dungeon" }, -- A Green Sample
    [92457] = { "City of Dalaran", 33, 3950, nil, "Dungeon" }, -- Starving Arcane
    [92458] = { "City of Dalaran", 33, 3950, nil, "Dungeon" }, -- Heart of Disruption
    [92459] = { "Alterac Mountains", 33, 270, "A" }, -- Friend of the Kirin Tor
    [92460] = { "Zephras Isle", 1, 40, nil, nil, "Ancient Heirloom" }, -- Coming of Age
    [92461] = { "Zephras Isle", 1, 80, nil, nil, "Pick one: fur lined shoes, vuldren hide bracers" }, -- Harmony in Balance
    [92462] = { "Zephras Isle", 2, 170 }, -- Infestation Investigation
    [92463] = { "Zephras Isle", 3, 320, nil, nil, "Pick one: exterminators vest, gardening pants, watchers mail chest" }, -- The Cirrusfly Queen
    [92464] = { "Zephras Isle", 3, 30 }, -- Elemental Unrest
    [92465] = { "Zephras Isle", 3, 250 }, -- Agitators
    [92466] = { "Zephras Isle", 4, 270, "H" }, -- Call of Earth
    [92467] = { "Zephras Isle", 4, 180, "H" }, -- Call of Earth
    [92468] = { "Zephras Isle", 4, 360, "H", nil, "Earth Totem" }, -- Call of Earth
    [92469] = { "Zephras Isle", 4, 40, nil, nil, "Pick one: windblown short cloak, skychain belt" }, -- Return to Rorian
    [92470] = { "Zephras Isle", 5, 560, nil, nil, "Pick one: worn greatsword, novices quarterstaff, scout rangers dagger, peacekeepers pickhammer, refined shortbow" }, -- Foul Matriarch
    [92471] = { "Zephras Isle", 4, 40 }, -- Aetheen of the Gales
    [92472] = { "Zephras Isle", 5, 230 }, -- The Next Step
    [92473] = { "Zephras Isle", 4, 360, nil, nil, "Pick one: thendal rangers shoes, thendal rangers gloves, thendal rangers belt" }, -- Aggressive Encroachment
    [92474] = { "Zephras Isle", 2, 90 }, -- Falling With Style
    [92479] = { "Warrior", 1, 40, "A" }, -- A Scribbled Letter
    [92481] = { "Mage", 2, 90, "A" }, -- A Student of the Arcane
    [92482] = { "Hunter", 2, 90 }, -- The Way of the Hunter
    [92483] = { "Rogue", 2, 90 }, -- At Home in the Shadows
    [92484] = { "Shaman", 2, 90, "H" }, -- Embracing the Elements
    [92485] = { "Druid", 2, 90 }, -- A Student of Nature
    [92489] = { "City of Dalaran", 33, 3950, nil, "Dungeon" }, -- Power Overwhelming
    [92500] = { "Mount Hyjal", 58, 620 }, -- A Bit of the Sky
    [92514] = { "Zephras Isle", 6, 140, "H" }, -- Welcome to Shen'dar Village
    [92515] = { "Zephras Isle", 6, 540, nil, nil, "Simple Leather Satchel" }, -- The Problem With Prideclaws
    [92516] = { "Zephras Isle", 7, 630 }, -- Hippogryph Harassment
    [92517] = { "Zephras Isle", 7, 480, nil, nil, "Pick one: bandits jerkin, patchwork leggings, highlands mail legguards" }, -- The Criminal Element
    [92519] = { "Arathi Highlands", 36, 2800, "H", nil, "Pick one: strong anti venom, leather tourniquet" }, -- Ward Restocking
    [92528] = { "Zephras Isle", 8, 350, nil, nil, "Pick one: stained ritual dagger, curved scimitar, windswept shortbow" }, -- Among the Faithful
    [92529] = { "Zephras Isle", 8, 350 }, -- Falaath Village
    [92532] = { "Warrior", 2, 90 }, -- The Warrior's Path
    [92533] = { "Mount Hyjal", 60, 6600, nil, nil, "Pick one: reforged spear, cleansed ritual kris, purified gnarlybark staff" }, -- Twisted Tools
    [92544] = { "Zephras Isle", 5, 560 }, -- Al'Aketh Thugs
    [92550] = { "Zephras Isle", 8, 700, nil, nil, "Pick one: wolfhide belt, elegant cuffs, ex commanders gauntlets" }, -- Havoc in the Highlands
    [92551] = { "Zephras Isle", 8, 530 }, -- Stolen Supplies
    [92553] = { "Zephras Isle", 6, 410, nil, nil, "recipe skywall souffle, skywall souffle" }, -- Restocking the Larders
    [92579] = { "Zephras Isle", 8, 180, "H", nil, "Pick one: travelers wraps, adventurers cloak, hiking boots" }, -- To Valanaar
    [92591] = { "Mount Hyjal", 59, 6400, "A", nil, "Lichbane" }, -- Final Death
    [92592] = { "Mount Hyjal", 59, 6400, "H", nil, "Lichbane" }, -- Final Death
    [92593] = { "Mount Hyjal", 59, 3200, "A" }, -- Avalanche of Corruption
    [92594] = { "Mount Hyjal", 56, 4350 }, -- Kindling, Kinda
    [92595] = { "Zephras Isle", 6, 140, "H" }, -- The Windshapers
    [92596] = { "Zephras Isle", 6, 140, "A" }, -- The High Order
    [92597] = { "Zephras Isle", 4, 180, "A" }, -- Reading the Leylines
    [92598] = { "Zephras Isle", 4, 180, "H" }, -- The Gift of Skysight
    [92609] = { "Mount Hyjal", 57, 6000, "H", nil, "Cremation Longbow" }, -- Feathers in Flight
    [92612] = { "Moonglade", 58, 620 }, -- Aid from Moonglade
    [92640] = { "Zephras Isle", 11, 660, nil, nil, "Pick one: skywatchers vestments, elite peacekeepers leggings, broken cultist gloves" }, -- Desperate Times
    [92642] = { "Zephras Isle", 11, 440 }, -- Disrupting Logistics
    [92643] = { "Zephras Isle", 11, 660 }, -- The Turncoat
    [92644] = { "Zephras Isle", 11, 440, nil, nil, "Pick one: trackers pants, elders tunic, peacekeepers mail" }, -- Unfortunate News
    [92645] = { "Zephras Isle", 11, 660, nil, nil, "Pick one: hunters cord, windsong bangles, breakers gauntlets" }, -- Breaking the Breaker
    [92646] = { "Zephras Isle", 12, 460, "H", nil, "Pick one: belt of blades, empyrean shoes, empyrean greatsword, empyrean treads" }, -- Confront Lorthuna
    [92679] = { "Zephras Isle", 9, 390 }, -- Blood Tithe
    [92682] = { "Zephras Isle", 9, 780, nil, nil, "Red Delicious Stormapple" }, -- Make Yourself Useful
    [92683] = { "Zephras Isle", 9, 590, nil, nil, "flutterfly swatter, minor mana potion" }, -- Flutterfly Dust
    [92684] = { "Zephras Isle", 9, 590, nil, nil, "Pick one: farmers field boots, brass banded bracers, well worn pants; Also get: Red Delicious Stormapple" }, -- Ornery Ornery Galestriders
    [92685] = { "Zephras Isle", 9, 780, nil, nil, "Red Delicious Stormapple" }, -- The Hills Have Eyes
    [92693] = { "Zephras Isle", 9, 200, nil, nil, "Red Delicious Stormapple" }, -- Standing Our Ground
    [92698] = { "Zephras Isle", 9, 200 }, -- What Is My Purpose?
    [92699] = { "Zephras Isle", 9, 80, "A" }, -- The Supreme Magister
    [92700] = { "Zephras Isle", 9, 80, "H" }, -- The Grand Skyseer
    [92701] = { "Zephras Isle", 9, 80, "A" }, -- To Valanaar
    [92702] = { "Mount Hyjal", 56, 580, "A" }, -- Branch Out
    [92703] = { "Zephras Isle", 9, 590, nil, nil, "Pick one: planting shovel, roofing hammer, trusty wrench" }, -- Deliver the News
    [92706] = { "The Barrens", 20, 1950, nil, "Elite" }, -- WANTED: Bruuz
    [92707] = { "Arathi Highlands", 33, 3300, "H" }, -- The Giant in the Den
    [92708] = { "Zephras Isle", 12, 90, "H" }, -- A Grand Adventure
    [92709] = { "Zephras Isle", 12, 90, "A" }, -- A Grand Adventure
    [92727] = { "Zephras Isle", 10, 210, "A" }, -- The Missing Scholar
    [92741] = { "Zephras Isle", 13, 910, "A" }, -- Unwelcome Visitors
    [92742] = { "Westfall", 12, 460, "A" }, -- Testing the Wells
    [92743] = { "Desolace", 40, 3150 }, -- A Conqueror's Crown
    [92744] = { "Westfall", 12, 460, "A" }, -- Murloc Gills
    [92745] = { "Westfall", 14, 490, "A" }, -- The State of the Mines
    [92747] = { "Westfall", 15, 800, "A" }, -- Moonbrook Espionage
    [92748] = { "Westfall", 16, 580, "A" }, -- Explosive Consultation
    [92749] = { "Westfall", 16, 580, "A" }, -- A Dynamite Plan
    [92750] = { "Westfall", 16, 120, "A" }, -- Detonation at a Distance
    [92751] = { "Westfall", 16, 120, "A" }, -- Detonation at a Distance
    [92752] = { "Westfall", 16, 580, "A" }, -- Explosive Consultation
    [92753] = { "The Deadmines", 18, 1350, "A", "Dungeon" }, -- Destruction in Deadmines
    [92754] = { "Desolace", 35, 2050, nil, nil, "Pick one: recipe greater spellblasting potion, recipe greater frenzy potion" }, -- A New Need for Shadow Protection
    [92755] = { "Desolace", 35, 2050, nil, nil, "Pick one: formula enchant bracer lesser agility, formula enchant bracer lesser healing power" }, -- Mysterious Mysticism
    [92811] = { "Desolace", 60, 0 }, -- Economic Warfare
    [92812] = { "Desolace", 60, 0 }, -- Economic Warfare
    [92814] = { "Desolace", 35, 2050, nil, nil, "Pick one: pattern stormcloth gloves, pattern silk reagent bag" }, -- I Need a Tailor
    [92817] = { "Desolace", 35, 2050, nil, nil, "Pick one: pattern mystic thick armor kit, pattern blue suede armor" }, -- Leather Technique
    [92818] = { "Desolace", 35, 2050, nil, nil, "Pick one: plans hard gold gauntlet, plans iron morningstar" }, -- Big, No, MASSIVE Iron Axes
    [92819] = { "Westfall", 18, 140, "A" }, -- Destruction in Deadmines
    [92833] = { "Mount Hyjal", 60, 8300, nil, "Elite" }, -- Ve'han's Fall
    [92834] = { "Zephras Isle", 11, 880, "A", nil, "Pick one: martyrs armor, sash of sorrow, cilice of regret" }, -- Avenged Tenfold
    [92840] = { "Zephras Isle", 11, 880, "A", nil, "bow of hours, minor trolls blood elixir" }, -- Catching Wind
    [92841] = { "Shen'dralas", 40, 320, "H" }, -- Valley of Bones
    [92842] = { "Western Plaguelands", 55, 560, "A" }, -- A Cousin Abroad
    [92844] = { "Shen'dralas", 42, 3450, "H" }, -- Mountain of Bones
    [92846] = { "Shen'dralas", 40, 2350, "H" }, -- Outcast Necromancers
    [92847] = { "Shen'dralas", 42, 3450, "H" }, -- Corrupting Tears
    [92849] = { "Zephras Isle", 10, 840, "A" }, -- The Missing Scholar
    [92850] = { "Zephras Isle", 10, 840, "A" }, -- The Missing Scholar
    [92858] = { "Feralas", 43, 4450, "A", "Elite", "Staff of Brutal Cunning" }, -- WANTED: Ohk'zi
    [92859] = { "Winterspring", 60, 3300, nil, nil, "Potion of Winterspring Shrouding" }, -- Shroud of the Winter Wilds
    [92860] = { "Zephras Isle", 12, 230, "A" }, -- In Service of Zephras
    [92867] = { "Arathi Highlands", 39, 3000, "A", "Elite", "Pick one: old leather jacket, stromgarde hood" }, -- Ground to Keep
    [92871] = { "Zephras Isle", 11, 220, "H" }, -- In Service of Zephras
    [92872] = { "Arathi Highlands", 38, 2850, "A" }, -- Dutiful Steps
    [92873] = { "Shen'dralas", 41, 2450, "H", nil, "Pick one:blade of the magram clan, staff of revelations, desperate barrier" }, -- Proof of Concept
    [92878] = { "Feralas", 43, 4450, "H", "Elite", "Pick one: shabby spaulders, cross stitched cord, grimtotem naturalists tunic" }, -- Lost for Words
    [92880] = { "Zephras Isle", 11, 440, nil, nil, "Pick one: honed greathammer, quickblades dagger, balanced quarterstaff" }, -- Return to Valanaar
    [92881] = { "Zephras Isle", 11, 90 }, -- The High Elder's Request
    [92893] = { "Shen'dralas", 42, 2550, "H" }, -- No Mercy for the Weak
    [92894] = { "Shen'dralas", 40, 2350, "H" }, -- Bone Raising
    [92909] = { "Westfall", 15, 800, "A" }, -- Harvesting the Harvesters
    [92910] = { "Westfall", 15, 800, "A" }, -- Harvesting the Harvesters
    [92911] = { "Westfall", 15, 1050, "A", nil, "harvester override signalcaster, schematic harvester override signalcaster" }, -- Harvesting the Harvesters
    [92914] = { "Shen'dralas", 43, 3600 }, -- Strange Pylons
    [92947] = { "Zephras Isle", 12, 910 }, -- Making Our Move
    [92959] = { "Mount Hyjal", 56, 7300, nil, "Elite", "Sunderbark Vigil" }, -- The Dying Ancients
    [92960] = { "Mount Hyjal", 59, 6400 }, -- Siphoned Ephemeral Essence
    [93016] = { "Shen'dralas", 43, 360 }, -- A Brief History Lesson
    [93030] = { "Tirisfal Glades", 58, 620, "H" }, -- The Knight of Mourning
    [93034] = { "Shen'dralas", 38, 290 }, -- Valley of Bones
    [93035] = { "Shen'dralas", 38, 1450, "H" }, -- Ravaging Ravagers
    [93036] = { "Zephras Isle", 8, 70 }, -- Infiltrating the Cult
    [93037] = { "Shen'dralas", 40, 2350, "H" }, -- Outing Outcasts
    [93041] = { "Shen'dralas", 38, 710 }, -- Facing the Truth
    [93044] = { "Desolace", 38, 2150, "A" }, -- A Cleansing Cry
    [93045] = { "Desolace", 38, 710, nil, nil, "Pick one: centaur spear, wanderers broadsword, desert crawlers claw" }, -- Test Your Theory
    [93058] = { "Shen'dralas", 42, 2550, "H" }, -- Saving Our Own
    [93062] = { "Shen'dralas", 42, 3450, "H" }, -- Bone Burying
    [93065] = { "Zephras Isle", 12, 460 }, -- Prepare for Battle
    [93066] = { "Shen'dralas", 43, 3600, "H" }, -- Bristleback Retreat
    [93072] = { "Shen'dralas", 43, 3600 }, -- Long-Term Solutions
    [93089] = { "Zephras Isle", 13, 90, "A" }, -- What Comes Next
    [93090] = { "Zephras Isle", 13, 460, "H" }, -- What Comes Next
    [93122] = { "Shen'dralas", 43, 360, "H" }, -- Checking Things Out
    [93125] = { "Shen'dralas", 43, 2700, "H" }, -- Going Home
    [93127] = { "Mount Hyjal", 60, 4950, nil, nil, "Pick one: whitemanes plateau, summit drape" }, -- Summit Sentries
    [93128] = { "Desolace", 42, 3450, nil, nil, "Pick one: abandoned ferocity, thrice damned effigy, bludgeon of betrayed virtues" }, -- Khan Jehn
    [93129] = { "Shen'dralas", 43, 1800 }, -- Threat of Starvation
    [93159] = { "Zephras Isle", 13, 230 }, -- The Strange Hermit
    [93160] = { "Zephras Isle", 13, 680 }, -- The Forest's Bounty
    [93161] = { "Zephras Isle", 60, 0, nil, nil, "Ancient Hilt" }, -- The Ancient Hilt
    [93162] = { "Searing Gorge", 50, 0 }, -- Head of the Obliterator
    [93163] = { "Searing Gorge", 50, 5900 }, -- Heart of the Obliterator
    [93165] = { "Zephras Isle", 13, 910, nil, nil, "Pick one: nightclaw gloves, shadowgale pants, cult hunters boots" }, -- Mercy Falls on Deaf Ears
    [93172] = { "Zephras Isle", 13, 680, nil, nil, "Pick one: freedom walkers, sorrowsong gloves, scuffed cuffs" }, -- Free the Hollows
    [93174] = { "Zephras Isle", 13, 90 }, -- The Malfunctioning Construct
    [93176] = { "Swamp of Sorrows", 35, 2750, nil, nil, "Weevil K. Neevil" }, -- My Little Friends
    [93188] = { "Shen'dralas", 43, 360, "H" }, -- Return to Orgrul
    [93196] = { "Desolace", 42, 3450, "H", nil, "Pick one: greatstaff of the necrokhans, soulsplatter mace, scavenged magram armament" }, -- Khan Jehn
    [93197] = { "Mount Hyjal", 58, 3100 }, -- Mending Communications
    [93224] = { "Desolace", 40, 2350, "A" }, -- Carved Centaur Totems
    [93225] = { "Desolace", 40, 2350, "H" }, -- Carved Centaur Totems
    [93226] = { "Desolace", 45, 390, "A" }, -- Buying Friendship: Magram
    [93227] = { "Desolace", 45, 390, "A" }, -- Buying Friendship: Gelkis
    [93269] = { "Mount Hyjal", 58, 620, nil, nil, "hyjal postal satchel, hyjal postal clasp" }, -- Top of the Post
    [93317] = { "Zephras Isle", 9, 590, nil, nil, "recipe pincer bites, pincer bites" }, -- Crab Season
    [93318] = { "Zephras Isle", 9, 780, nil, "Elite", "Pick one: hunters simple cloak, highlands defenders shield" }, -- WANTED: Vulgara the Insatiable
    [93319] = { "Zephras Isle", 7, 480 }, -- Pilfered Windstones
    [93320] = { "Zephras Isle", 11, 440, nil, nil, "Pick one: defenders bracers, windswept slippers, peacekeepers legguards" }, -- Tower Defense
    [93341] = { "Shen'dralas", 43, 1800 }, -- Forlorn Gardens
    [93362] = { "Shen'dralas", 43, 3600 }, -- What They've Done to My Peonies
    [93383] = { "Mount Hyjal", 57, 1500, "A", nil, "Pick one: rocket pilot gloves, rocketeer leggings, rusty propeller blade" }, -- Contents Under Pressure
    [93394] = { "Shen'dralas", 43, 360 }, -- Meeting the Magister
    [93404] = { "Maraudon", 49, 5700, nil, "Dungeon", "Pick one: overgrown cuffs, thornplated cord" }, -- Rot and Regret
    [93406] = { "Mount Hyjal", 56, 4350 }, -- Unfrozen Deliveries
    [93407] = { "Mount Hyjal", 60, 6600 }, -- A Thorn in the Paw
    [93422] = { "Mount Hyjal", 60, 8300, nil, "Elite" }, -- Blackthorne Blackout
    [93429] = { "Swamp of Sorrows", 35, 2750 }, -- Blood of My Blood
    [93430] = { "Swamp of Sorrows", 35, 2050 }, -- Taking the Bait Back
    [93443] = { "Stranglethorn Vale", 36, 280, "A" }, -- Lost Shipping Crate
    [93444] = { "Mount Hyjal", 60, 8300, nil, "Elite", "Pick one: ghansurok hide tunic, chimaera wing cape" }, -- Bait the Beast
    [93450] = { "Shen'dralas", 42, 860 }, -- Phantasmal Problems
    [93451] = { "Shen'dralas", 42, 860 }, -- Phantasmal Problems
    [93459] = { "Zephras Isle", 13, 0 }, -- More Al'Aketh Ears
    [93461] = { "Zephras Isle", 6, 140, "A" }, -- Welcome to Shen'dar Village
    [93464] = { "Swamp of Sorrows", 38, 1450 }, -- The Visiting Mage
    [93465] = { "Desolace", 40, 3150 }, -- Notes on Draenethyst
    [93510] = { "Mount Hyjal", 58, 6200 }, -- Wake Memories
    [93521] = { "Mount Hyjal", 60, 1650 }, -- Challenger of the Gods
    [93546] = { "Shen'dralas", 42, 2550 }, -- Spectral Iron Ore
    [93547] = { "Mount Hyjal", 60, 1650, nil, nil, "Bramblebark Barrier" }, -- A Thorny Solution
    [93551] = { "Mount Hyjal", 58, 6200 }, -- Praise
    [93552] = { "Zephras Isle", 4, 360, nil, nil, "Pick one: mining for dummies, wild harvest, pelt collecting for beginners; Also get: Windstone" }, -- Harvesting Windstones
    [93567] = { "Mount Hyjal", 58, 3100 }, -- Ends Meet
    [93568] = { "Shen'dralas", 45, 3900 }, -- Partially Digested Collar
    [93572] = { "Blasted Lands", 55, 5650, nil, nil, "Emerald Encrusted Chest" }, -- To Serve The Draenei
    [93574] = { "Shen'dralas", 45, 4850, nil, nil, "Pick one:corpsefeeders shedding, clacking carapace spaulders, discarded circlet" }, -- Corpsefeeder's Carapace
    [93584] = { "Mount Hyjal", 60, 6600 }, -- Cult Closure
    [93585] = { "Swamp of Sorrows", 34, 2700, "A" }, -- This Light of Mine
    [93594] = { "Shen'dralas", 43, 360 }, -- Word of the Woods
    [93601] = { "Shen'dralas", 45, 390 }, -- Passing the Blame
    [93604] = { "Razorfen Downs", 45, 4850, nil, "Dungeon" }, -- Agamaggan's Blood
    [93606] = { "Shen'dralas", 45, 3900, nil, nil, "forlorn necklace, rejected roses" }, -- Not on Squealing Terms
    [93609] = { "Shen'dralas", 45, 4850, nil, nil, "Pick one:amulet of vengeance, amulet of forgiveness" }, -- Forlorn Necklace
    [93615] = { "Mount Hyjal", 57, 4500, nil, nil, "Claw of Shalla'kal" }, -- Kits and Cats
    [93617] = { "Mount Hyjal", 57, 3000, nil, nil, "Cured Staghide Leggings" }, -- Prey and Predator
    [93644] = { "Shen'dralas", 45, 3900 }, -- Tattered Journal
    [93663] = { "Swamp of Sorrows", 35, 1350, "H" }, -- Lost in Transit
    [93678] = { "Desolace", 40, 1550 }, -- Abridged Notes on Draenethyst
    [93679] = { "Swamp of Sorrows", 55, 560 }, -- Visions of Another
    [93680] = { "Alterac Mountains", 33, 0, "H" }, -- Key to the City
    [93684] = { "Blasted Lands", 55, 2800 }, -- The Found One
    [93685] = { "Blasted Lands", 55, 8450, "H" }, -- To Serve Kum'isha
    [93686] = { "Blasted Lands", 55, 5650, nil, nil, "Emerald Encrusted Chest" }, -- Kum'isha's Endeavors
    [93689] = { "Alterac Mountains", 33, 270 }, -- Friend of the Kirin Tor
    [93735] = { "Zephras Isle", 9, 590, "H" }, -- The Broken Construct
    [93736] = { "Zephras Isle", 9, 780, "H" }, -- Unwelcome Spirits
    [93737] = { "Zephras Isle", 9, 780, "H" }, -- The Broken Construct
    [93738] = { "Zephras Isle", 9, 590, "H" }, -- The Broken Construct
    [93739] = { "Orgrimmar", 13, 1150, "H", nil, "Honorbound Cloak" }, -- Exploring the Horde
    [93740] = { "Zephras Isle", 11, 660, "H" }, -- Blood for Blood
    [93746] = { "Zephras Isle", 9, 590, "H", nil, "windshaped shield, minor mageblood elixir" }, -- A Firm Response
    [93747] = { "Mount Hyjal", 56, 1450 }, -- Violence Into Verdure
    [93759] = { "Mount Hyjal", 56, 4350, nil, nil, "Ketharas' Hyjal Stew" }, -- The Bounty of Nature
    [93773] = { "Mount Hyjal", 58, 3100 }, -- The Pact
    [93786] = { "Riverglades", 36, 2800, "H" }, -- A Message in Blood
    [93787] = { "Riverglades", 36, 2800, "H" }, -- Food for the Taking
    [93788] = { "Riverglades", 38, 2850, "H" }, -- Borrowed Blades
    [93791] = { "Mage", 10, 420, "A" }, -- Speak with Belann
    [93797] = { "Mage", 10, 840, "A", nil, "windbough wand, elixir of minor spirit" }, -- Boughs in the Wind
    [93825] = { "Mount Hyjal", 57, 6000 }, -- Barkbound Blessings
    [93826] = { "Mount Hyjal", 57, 6000 }, -- Deal Dread to Deadwood
    [93827] = { "Mount Hyjal", 58, 6200 }, -- Windswept Wards
    [93828] = { "Mount Hyjal", 57, 3000 }, -- Herbs of the Hollow
    [93830] = { "Mount Hyjal", 57, 3000 }, -- Water of Hyjal
    [93831] = { "Mount Hyjal", 57, 4500, nil, nil, "Sweetpaw Jam" }, -- Sweetpaw Jam
    [93832] = { "Mount Hyjal", 58, 4650 }, -- Shatter the Stonewatchers
    [93833] = { "Mount Hyjal", 57, 4500 }, -- Wicked Wisdom
    [93834] = { "Mount Hyjal", 57, 3000, nil, nil, "Major Rejuvenation Potion" }, -- Burrow Beetles
    [93835] = { "Zephras Isle", 12, 460, "A", nil, "Pick one: belt of blades, empyrean shoes, empyrean greatsword, empyrean treads" }, -- Confront Lorthuna
    [93836] = { "Zephras Isle", 12, 460, "H" }, -- The Fate of Zephras
    [93848] = { "Mount Hyjal", 60, 6600, nil, nil, "Pick one: wild wristguards, ring of natures cycles, ketharas linked belt, horn of vehan, hermits pauldron" }, -- Work Well Done
    [93862] = { nil, 60, 0 }, -- Crate Return
    [93925] = { "Felwood", 57, 600 }, -- Beads for Brerufa
    [93926] = { "Zephras Isle", 8, 350 }, -- The Western Watch
    [93927] = { "Zephras Isle", 8, 530 }, -- A Last Request
    [93928] = { "Westfall", 15, 110, "A" }, -- Of Mice and Milk
    [93948] = { "Zephras Isle", 9, 390 }, -- Deliver the Signet
    [93949] = { "Zephras Isle", 8, 700 }, -- Bugged
    [93951] = { "Zephras Isle", 7, 480 }, -- A Little Beauty
    [93952] = { "Mount Hyjal", 57, 4500 }, -- Balance Through Strength
    [93958] = { "Zephras Isle", 12, 910 }, -- The Inner Sanctum
    [93963] = { "Stormwind City", 13, 1150, "A", nil, "Cloak of the Honored Guest" }, -- Exploring the Alliance
    [93971] = { "Riverglades", 45, 4850, "H", nil, "Pick one: head harvest crossbow, bloodied sash" }, -- Farholde Scouting Report
    [93976] = { "Riverglades", 36, 280, "H" }, -- The Goblin Trader
    [94003] = { "Warrior", 10, 840, nil, nil, "Stormforged Protector" }, -- The Skybreaker Bulwark
    [94004] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Elixir of Ogre's Strength
    [94006] = { "Druid", 10, 840 }, -- The Great Ursera Spirit
    [94007] = { "Hunter", 10, 210 }, -- Taming the Beast
    [94013] = { "Hunter", 10, 840 }, -- Taming the Beast
    [94050] = { "Hunter", 10, 420 }, -- Training the Beast
    [94212] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Elixir of Wisdom
    [94213] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Lesser Mana Potion
    [94214] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Shadow Protection Potion
    [94215] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Free Action Potion
    [94216] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Elixir of Lesser Agility
    [94217] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Lesser Troll's Blood Elixir
    [94218] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Elixir of Defense
    [94219] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Draught of Water Breathing
    [94220] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Pearl-Handled Dagger
    [94221] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Golden Rod
    [94222] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Iridescent Hammer
    [94223] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Silver Skeleton Key
    [94224] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Heavy Bronze Mace
    [94225] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Rough Bronze Leggings
    [94226] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Green Iron Gauntlets
    [94227] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Big Bronze Knife
    [94228] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Green Iron Boots
    [94229] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Ornate Spyglass
    [94230] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Explosive Sheep
    [94231] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Moonsight Rifle
    [94232] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Minor Recombobulator
    [94233] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Practice Lock
    [94234] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Shadow Goggles
    [94235] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Gnomish Universal Remote
    [94236] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Big Bronze Bomb
    [94237] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Crafted Solid Shot
    [94238] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Heavy Leather Ball
    [94239] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Fine Leather Pants
    [94240] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Herbalist's Gloves
    [94241] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Dark Leather Tunic
    [94242] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Pilferer's Gloves
    [94243] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Heavy Quiver
    [94244] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Dark Leather Shoulders
    [94245] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Barbaric Gloves
    [94246] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Red Whelp Gloves
    [94247] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Lesser Wizard's Robe
    [94248] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Blue Overalls
    [94249] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Azure Silk Hood
    [94250] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Small Silk Pack
    [94251] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Phoenix Pants
    [94252] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Red Woolen Boots
    [94253] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Colorful Kilt
    [94254] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Greater Adept's Robe
    [94255] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Spider Silk Slippers
    [94256] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Frost Protection Potion
    [94257] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Lesser Invisibility Potion
    [94258] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Lesser Stoneshield Potion
    [94259] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Nature Protection Potion
    [94260] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Catseye Draught
    [94261] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Great Rage Potion
    [94262] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Mana Potion
    [94263] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Fire Protection Potion
    [94264] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Shadow Oil
    [94265] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Goblin Rocket Fuel
    [94266] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Elixir of Agility
    [94267] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Wildvine Potion
    [94268] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Steel Plate Helm
    [94269] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Inlaid Mithril Cylinder
    [94270] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Steel Weapon Chain
    [94271] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Ornate Mithril Shoulders
    [94272] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Blue Glittering Axe
    [94273] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Moonsteel Broadsword
    [94274] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Golden Scale Coif
    [94275] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Solid Sharpening Stone
    [94276] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Wicked Mithril Blade
    [94277] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Truesilver Rod
    [94278] = { "Crafting", 60, 0, "A" }, -- Craftsman's Writ: Golden Scale Gauntlets
    [94279] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Heavy Mithril Axe
    [94280] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Mechanical Dragonling
    [94281] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Advanced Target Dummy
    [94282] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Craftsman's Monocle
    [94283] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Goblin Land Mine
    [94284] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Catseye Ultra Goggles
    [94285] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Unstable Trigger
    [94286] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Flash Bomb
    [94287] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Fire Goggles
    [94288] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Mithril Frag Bomb
    [94289] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Gyromatic Micro-Adjuster
    [94290] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Mechanical Repair Kit
    [94291] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Dark Iron Bomb
    [94292] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Comfortable Leather Hat
    [94293] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Guardian Cloak
    [94294] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Dusky Bracers
    [94295] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Wild Leather Helmet
    [94296] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Wild Leather Shoulders
    [94297] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Quickdraw Quiver
    [94298] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Swift Boots
    [94299] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Nightscape Shoulders
    [94300] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Big Voodoo Mask
    [94301] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Big Voodoo Robe
    [94302] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Turtle Scale Breastplate
    [94303] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Thick Leather Ammo Pouch
    [94304] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Mageweave Bag
    [94305] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Shadoweave Gloves
    [94306] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Crimson Silk Robe
    [94307] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Shadoweave Robe
    [94308] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Enchanted Mageweave Pouch
    [94309] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Star Belt
    [94310] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Black Mageweave Vest
    [94311] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Red Mageweave Pants
    [94312] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Orange Martial Shirt
    [94313] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: White Bandit Mask
    [94314] = { "Crafting", 60, 0, "H" }, -- Craftsman's Writ: Cindercloth Robe
    [94315] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Earthen Silk Belt
    [94316] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Potion of Demonslaying
    [94317] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Dreamless Sleep Potion
    [94318] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Greater Fire Protection Potion
    [94319] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Draught of Detect Demon
    [94320] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Gift of Arthas
    [94321] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Flask of Chromatic Resistance
    [94322] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Limited Invulnerability Potion
    [94323] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Major Rejuvenation Potion
    [94324] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Distilled Firewater
    [94325] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Radiant Circlet
    [94326] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Radiant Belt
    [94327] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Orcish War Leggings
    [94328] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Mithril Spurs
    [94329] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Imperial Plate Chest
    [94330] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Darkrune Gauntlets
    [94331] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Huge Thorium Battleaxe
    [94332] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Arcanite Skeleton Key
    [94333] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Ebon Shiv
    [94334] = { "Crafting", 60, 0, "H" }, -- Craftsman's Writ: Masterwork Target Dummy
    [94335] = { "Crafting", 60, 0, "H" }, -- Craftsman's Writ: Green Lens
    [94336] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Lifelike Mechanical Toad
    [94337] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Gnomish Alarm-O-Bot
    [94338] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Goblin Jumper Cables XL
    [94339] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Field Repair Bot 74A
    [94340] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Truesilver Transformer
    [94341] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Sniper Scope
    [94342] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Tranquil Mechanical Yeti
    [94343] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Wicked Leather Pants
    [94344] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Gordok Ogre Suit
    [94345] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Volcanic Breastplate
    [94346] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Runic Leather Headband
    [94347] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Wicked Leather Bracers
    [94348] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Chimeric Vest
    [94349] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Heavy Scorpid Helm
    [94350] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Runic Leather Bracers
    [94351] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Frostsaber Boots
    [94352] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Wizardweave Turban
    [94353] = { "Crafting", 60, 0, nil, nil, "Coin Pouch" }, -- Craftsman's Writ: Runecloth Bag
    [94354] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Runecloth Boots
    [94355] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Tuxedo Jacket
    [94356] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Felcloth Boots
    [94357] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Cenarion Herb Bag
    [94358] = { "Crafting", 60, 0, "H" }, -- Craftsman's Writ: Shadoweave Mask
    [94359] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Ghostweave Vest
    [94360] = { "Crafting", 60, 0 }, -- Craftsman's Writ: Soul Pouch
    [94369] = { "Zephras Isle", 12, 90, "A" }, -- The Fate of Zephras
    [94373] = { "Shaman", 4, 270, "A" }, -- Call of Earth
    [94374] = { "Shaman", 4, 270, "A" }, -- Call of Earth
    [94375] = { "Shaman", 4, 450, "A", nil, "Earth Totem" }, -- Call of Earth
    [94399] = { "Un'Goro Crater", 60, 0, "H" }, -- Ravasaur Provisions
    [94411] = { "Zephras Isle", 6, 410, "H", nil, "Pick one: idol of shifting tides, totem of charged flames" }, -- Meddlesome Mages
    [94413] = { "Zephras Isle", 6, 540, "A", nil, "dowsing rod, elixir of minor strength" }, -- A Magical Affront
    [94414] = { "Zephras Isle", 2, 90 }, -- The Anchors of Zephras
    [94427] = { "Paladin", 12, 230, "H" }, -- A Lesson in Divinity
    [94434] = { "Paladin", 12, 910, "H" }, -- A Lesson in Divinity
    [94435] = { "Paladin", 12, 230, "H", nil, "Symbol of Life" }, -- A Lesson in Divinity
    [94436] = { "Paladin", 12, 90, "H" }, -- A Lesson in Divinity
    [94438] = { "Paladin", 12, 910, "H" }, -- A Lesson in Divinity
    [94440] = { "Paladin", 12, 680, "H" }, -- A Lesson in Divinity
    [94441] = { "Paladin", 12, 230, "H" }, -- A Lesson in Divinity
    [94449] = { "Shaman", 10, 420, "A" }, -- Call of Fire
    [94465] = { "Shaman", 11, 660, "A" }, -- Call of Fire
    [94466] = { "Shaman", 14, 980, "A", nil, "Fire Sapta" }, -- Call of Fire
    [94467] = { "Shaman", 14, 1250, "A", nil, "Torch of the Eternal Flame" }, -- Call of Fire
    [94468] = { "Shaman", 14, 1250, "A", nil, "fire totem, totem of charged flames" }, -- Call of Fire
    [94472] = { "Shaman", 4, 0, "A", nil, "Earth Sapta" }, -- Earth Sapta
    [94473] = { "Shaman", 13, 0, "A", nil, "Fire Sapta" }, -- Fire Sapta
    [94479] = { "Mount Hyjal", 56, 580 }, -- One Person's Trash
    [94480] = { "Riverglades", 36, 280, "H" }, -- A Gift From Our Enemies
    [94481] = { "Riverglades", 38, 2150, "H" }, -- A Serving of Strength
    [94483] = { "Riverglades", 39, 3000, "H" }, -- Show Them How It's Done
    [94484] = { "Zephras Isle", 11, 220 }, -- Unnerving Silence
    [94485] = { "Zephras Isle", 12, 230 }, -- Tears of the Lady
    [94486] = { "Zephras Isle", 11, 880 }, -- Feathers for Binding
    [94487] = { "Zephras Isle", 11, 880 }, -- Unwanted and Unworthy
    [94488] = { "Zephras Isle", 11, 880 }, -- The Ties That Bind
    [94489] = { "Zephras Isle", 12, 910 }, -- The Wounds of Betrayal
    [94490] = { "Zephras Isle", 12, 910 }, -- Ripped Missive
    [94491] = { "Zephras Isle", 12, 460 }, -- The Fate of the Den
    [94493] = { "Zephras Isle", 11, 220 }, -- A Sacrifice in Vain
    [94494] = { "Shaman", 20, 780, "A" }, -- Call of Water
    [94495] = { "Shaman", 22, 440, "A" }, -- Call of Water
    [94497] = { "Shaman", 22, 870, "A" }, -- Call of Water
    [94499] = { "Shaman", 22, 1300, "A" }, -- Call of Water
    [94500] = { "Shaman", 23, 1400, "A" }, -- Call of Water
    [94501] = { "Shaman", 23, 460, "A", nil, "Water Sapta" }, -- Call of Water
    [94502] = { "Shaman", 23, 1400, "A" }, -- Call of Water
    [94503] = { "Shaman", 23, 190, "A" }, -- Call of Water
    [94504] = { "Mount Hyjal", 57, 3000 }, -- Barkskin Beginnings
    [94505] = { "Shaman", 23, 2750, "A", nil, "Water Totem" }, -- Call of Water
    [94532] = { "Riverglades", 38, 2850, "H" }, -- Gnoll Infestation
    [94533] = { "Riverglades", 40, 3150, "H", "Elite", "Pick one: bristlepelt vest, gnoll crusher leggings, bloodsnout striker, gnollblood robe" }, -- Snargl's Snout
    [94535] = { "Riverglades", 38, 2850, "H" }, -- Bristle Hills Bandits
    [94556] = { "Riverglades", 42, 4300, "H", nil, "Pick one: jom joms gabbar, clobroks block rock" }, -- Jom-jom's Escape
    [94568] = { "Zephras Isle", 11, 440 }, -- The Cult's True Plans
    [94613] = { "Riverglades", 38, 290, "A" }, -- My Kingdom for a Horse
    [94614] = { "Riverglades", 38, 2850, "A" }, -- Freshwater Fiends
    [94615] = { "Riverglades", 38, 1450, "A" }, -- Foal Play
    [94616] = { "Shaman", 20, 0, "A", nil, "Water Sapta" }, -- Water Sapta
    [94617] = { "Riverglades", 38, 2850, "A" }, -- Coyote Huntin'
    [94618] = { "Riverglades", 38, 1450, "A" }, -- Wheeler's Fleeing Steeds
    [94638] = { "Druid", 10, 840 }, -- Strength and Mercy
    [94668] = { "Riverglades", 41, 330, "H" }, -- Bloodmaster's Ring
    [94669] = { "Riverglades", 41, 330, "H" }, -- Pay to Play
    [94670] = { "Riverglades", 41, 4100, "H", "Elite" }, -- Bloodmaster's Ring
    [94672] = { "Riverglades", 41, 3300, "H" }, -- Encroaching Twilight
    [94678] = { "Riverglades", 38, 2850, "A" }, -- Gnoll Infestation
    [94679] = { "Riverglades", 40, 3150, "A", "Elite", "Pick one: gnollhide tunic, southern watch leggings, unbalanced fighting stick, bristle hills mystic robe" }, -- Snargl's Snout
    [94680] = { "Riverglades", 41, 2450, "H" }, -- Twilight Missives
    [94727] = { "Riverglades", 40, 320, "H" }, -- Digging for Answers
    [94733] = { "Riverglades", 41, 330, "H" }, -- Our Ogre Friend
    [94734] = { "Riverglades", 41, 3300, "H" }, -- A Boar's Delight
    [94737] = { "Riverglades", 41, 330, "H" }, -- A Treat for a Friend
    [94739] = { "Riverglades", 42, 4300, "H", "Elite" }, -- Bloodmaster's Ring
    [94744] = { "Riverglades", 43, 360, "H" }, -- The Wayward Warrior
    [94745] = { "Riverglades", 44, 3750, "H" }, -- Carving a Path
    [94748] = { "Riverglades", 44, 3750, "H" }, -- Break Their Chains
    [94768] = { "Riverglades", 46, 5050, "H", "Elite", "Pick one: cloak of the cult, twilight barrier" }, -- Bring Me His Head
    [94773] = { "Priest", 10, 0, "A" }, -- Divine Grace
    [94774] = { "Priest", 10, 210, "A" }, -- Divine Grace
    [94775] = { "Priest", 10, 210, "A" }, -- Divine Grace
    [94776] = { "Priest", 10, 210, "A" }, -- Divine Grace
    [94777] = { "Priest", 10, 210, "A" }, -- Divine Grace
    [94778] = { "Priest", 10, 0, "A" }, -- Divine Grace
    [94779] = { "Priest", 10, 210, "A" }, -- Divine Grace
    [94782] = { "Mount Hyjal", 57, 600, "H" }, -- The Western Post
    [94789] = { "Shaman", 30, 2450, "A", nil, "Air Totem" }, -- Call of Air
    [94792] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [94793] = { "Hunter", 10, 420, "A" }, -- Training the Beast
    [94817] = { "Priest", 10, 0, "A" }, -- Confounding Flash
    [94818] = { "Priest", 20, 0, "A" }, -- Contingency Plan
    [94819] = { "Priest", 20, 390, "A" }, -- Contingency Plan
    [94820] = { "Priest", 20, 390, "A" }, -- Contingency Plan
    [94821] = { "Priest", 10, 210, "A" }, -- Confounding Flash
    [94822] = { "Priest", 10, 210, "A" }, -- Confounding Flash
    [94823] = { "Priest", 10, 210, "A" }, -- Confounding Flash
    [94824] = { "Priest", 10, 210, "A" }, -- Confounding Flash
    [94825] = { "Priest", 10, 210, "A" }, -- Confounding Flash
    [94826] = { "Priest", 10, 210, "A" }, -- Confounding Flash
    [94829] = { "Riverglades", 40, 2350, "A" }, -- What We Lost
    [94832] = { "Riverglades", 58, 620, "A" }, -- Belle's Ring
    [94841] = { "Desolace", 38, 290, "A" }, -- Lost Shipping Crate
    [94842] = { "Riverglades", 38, 2850, "A" }, -- Unsavory Plant Food
    [94843] = { "Riverglades", 38, 2150, "A" }, -- From Seed to Sprout
    [94857] = { "Riverglades", 39, 300, "A" }, -- If a Tree Falls, and No One Hears...
    [94858] = { "Riverglades", 40, 2350, "A" }, -- All That's Left
    [94861] = { "Riverglades", 39, 3000, "A", nil, "Pick one: curlys chopper, hurleys felling axe" }, -- Helping Hands
    [94863] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [94864] = { "Hunter", 10, 840, "A" }, -- Taming the Beast
    [94872] = { "Desolace", 45, 390, "H" }, -- Buying Friendship: Magram
    [94873] = { "Desolace", 45, 390, "H" }, -- Buying Friendship: Gelkis
    [94877] = { "Riverglades", 40, 3150, "A", nil, "Pick one: neophytes wand, twilight carver" }, -- Saving Sunnyglade
    [94879] = { "Riverglades", 40, 3150, "A" }, -- Scraps of Knowledge
    [94881] = { "Riverglades", 38, 2850, "A" }, -- Curious Trinkets
    [94884] = { "Riverglades", 41, 1650, "A" }, -- An Unsettling Discovery
    [94885] = { "Riverglades", 40, 3150, "A" }, -- Field Marshal's Log
    [94886] = { "Riverglades", 44, 380, "A" }, -- The Western Front
    [94887] = { "Riverglades", 47, 2100, "A" }, -- Saving Marshal Ryan
    [94888] = { "Riverglades", 44, 3750, "A" }, -- No Soldier Left Behind
    [94889] = { "Riverglades", 44, 3750, "A" }, -- Carving a Path
    [94890] = { "Riverglades", 46, 5050, "A", "Elite", "Pick one: twilight overlord drape, farholde bastion" }, -- Bring Me His Head
    [94891] = { "Riverglades", 46, 4050, "A", nil, "Farholde Keep Tabard" }, -- News to Farholde
    [94892] = { "Riverglades", 47, 4200, "A" }, -- Dying Wish
    [94893] = { "Riverglades", 47, 4200, "A" }, -- Delivering Closure
    [94894] = { "Riverglades", 45, 4850, "A" }, -- The Twilight Threat
    [94895] = { "Desolace", 38, 290, "H" }, -- Lost Shipping Crate
    [94896] = { "Zephras Isle", 11, 880 }, -- Aid For The Refugees
    [94897] = { "Zephras Isle", 11, 880 }, -- The Fate of a Loved One
    [94898] = { "Zephras Isle", 11, 880 }, -- Violent Winds (Temp Disabled)
    [94901] = { "Zephras Isle", 11, 880 }, -- Hopping Helpers
    [94902] = { "Zephras Isle", 11, 880 }, -- Valanaar Vintages
    [94907] = { "Riverglades", 44, 3750, "A" }, -- A Small Favor
    [94911] = { "Druid", 10, 840, "H" }, -- Child of Nature
    [94912] = { "Druid", 10, 840, "A" }, -- Child of Nature
    [94913] = { "Druid", 10, 210, "H" }, -- Moonglade
    [94914] = { "Druid", 10, 210, "A" }, -- Moonglade
    [94923] = { "Riverglades", 38, 2150, "A" }, -- Hats Off
    [94924] = { "Riverglades", 39, 3000, "A" }, -- Hunting the Hunters
    [94925] = { "Riverglades", 39, 3000, "A" }, -- A Fur Trade
    [94926] = { "Riverglades", 45, 4850, "A", "Elite", "Pauldron of Order" }, -- Drop the Hammer
    [94927] = { "Riverglades", 44, 4650, "A", nil, "Pick one: dunstons ogre duster, bolderok loincloth, prisoner handwraps" }, -- Dunston Checks Out
    [94928] = { "Riverglades", 39, 300, "A" }, -- A Few Furs for Friz
    [94929] = { "Swamp of Sorrows", 38, 290, "A" }, -- Deliver the Second Shipment
    [94930] = { "Thousand Needles", 38, 290, "H" }, -- Lost Shipping Crate
    [94931] = { "Riverglades", 38, 2850, "A" }, -- Stolen Saws
    [94946] = { "Zephras Isle", 13, 90, "A" }, -- The Magical City of Dalaran
    [94947] = { "Stormwind City", 13, 680, "A" }, -- Welcome to Azeroth
    [94961] = { "Riverglades", 40, 2350 }, -- Biting the Hand
    [94962] = { "Riverglades", 42, 4300, "H", "Elite" }, -- Bloodmaster's Ring
    [94963] = { "Riverglades", 40, 3150 }, -- Biting the Hand
    [94964] = { "Riverglades", 43, 4450, "H", "Elite" }, -- Bloodmaster's Ring
    [94965] = { "Riverglades", 44, 4650, "H", "Elite", "Pick one: superior healing potion, superior mana potion" }, -- Bloodmaster's Ring
    [94968] = { "Krol'dok Stronghold", 45, 4850, nil, "Dungeon" }, -- Eye of Mugg
    [94969] = { "Krol'dok Stronghold", 42, 3450, nil, "Dungeon" }, -- Krol'dok No More!
    [94971] = { "Paladin", 40, 780, "H" }, -- A Paladin's Steed
    [94972] = { "Krol'dok Stronghold", 44, 4650, nil, "Dungeon" }, -- Tome of Twilight
    [94973] = { "Krol'dok Stronghold", 41, 3300 }, -- Krol'dok Moulding
    [94974] = { "Krol'dok Stronghold", 41, 3300, nil, nil, "Krol'dok Compound Key" }, -- Key Ingredients
    [94975] = { "Krol'dok Stronghold", 42, 3450, nil, "Dungeon", "Semblance of Twilight" }, -- A Token of Vengeance
    [94978] = { "Hunter", 10, 840 }, -- Taming the Beast
    [94979] = { "Hunter", 10, 840 }, -- Taming the Beast
    [94980] = { "Krol'dok Stronghold", 41, 3300 }, -- Krol'dok Moulding
    [94981] = { "Krol'dok Stronghold", 41, 3300, nil, nil, "Krol'dok Compound Key" }, -- Key Ingredients
    [94982] = { "Krol'dok Stronghold", 45, 4850, nil, "Dungeon" }, -- Eye of Mugg
    [94983] = { "Krol'dok Stronghold", 42, 4300, nil, "Dungeon" }, -- Twilight Mementos
    [94984] = { "Krol'dok Stronghold", 44, 4650, nil, "Dungeon" }, -- Tome of Twilight
    [94992] = { "Riverglades", 38, 2850, "A" }, -- Rescue Roundup
    [94997] = { "Krol'dok Stronghold", 42, 3450 }, -- Lingering Essence
    [94998] = { "Krol'dok Stronghold", 42, 3450, nil, nil, "Curio-Adorned Necklace" }, -- Curios of Curiosity
    [94999] = { "Riverglades", 36, 700, "A" }, -- Eyes for the Watchman
    [95006] = { "Nighthaven", 58, 620 }, -- Stolen Power
    [95026] = { "Mount Hyjal", 58, 6200, "H", nil, "Plaguecrusher Greaves" }, -- Blight No More
    [95027] = { "Mount Hyjal", 57, 6000, "A", nil, "Blunderflame Bone Bow" }, -- Feathers in Flight
    [95033] = { "Riverglades", 41, 330, "H" }, -- On the Other Side
    [95034] = { "Paladin", 24, 200, "H" }, -- The Debt
    [95036] = { "Paladin", 25, 1000, "H", "Dungeon" }, -- A Moon-Kissed Blade
    [95041] = { "Dun Morogh", 10, 630, "A" }, -- Data Hoarders
    [95042] = { "Paladin", 25, 2000, "H", "Elite", "Purified Kor Gem" }, -- Seeking the Kor Gem
    [95056] = { "Krol'dok Stronghold", 42, 3450, nil, "Dungeon" }, -- Krol'dok No More!
    [95059] = { "Riverglades", 36, 280, "A" }, -- Frazzlespark's Crate
    [95062] = { "Riverglades", 36, 280, "H" }, -- Frazzlespark's Crate
    [95063] = { "Riverglades", 45, 4850, "H", "Elite", "Pick one: bloodmasters ring, bloodsport band, ogre horn ring" }, -- Bloodmaster's Ring
    [95064] = { "Riverglades", 39, 3000, "A", nil, "Pick one: farholde horns, brute slayer band" }, -- Preventative Measures
    [95065] = { "Stormwind City", 12, 680, "A", nil, "Pick one: brilliant smallfish, rainbow fin albacore" }, -- Fishin' Time
    [95066] = { "Riverglades", 39, 1500, "A", nil, "Orc Bone Bow" }, -- The Rog'mar Situation
    [95107] = { "Mount Hyjal", 58, 4650, nil, nil, "Pick one: staff of the deeproar, barkskin scepter, deadwood boomstick" }, -- Deeproar Down
    [95108] = { "Mount Hyjal", 58, 4650 }, -- Mystic Mix
    [95111] = { "Paladin", 25, 1000, "H" }, -- An Underrated Talent
    [95118] = { "Riverglades", 41, 3300 }, -- Saltwater Savages
    [95119] = { "Riverglades", 43, 3600 }, -- Unfriendly Competition
    [95120] = { "Riverglades", 42, 4300, nil, "Elite", "Rot-Covered Harpoon" }, -- WANTED: Old Rot-Chum
    [95121] = { "Riverglades", 40, 3150, nil, nil, "Recipe: Briny Seafood Stew" }, -- A Taste of the Sea
    [95122] = { "Riverglades", 44, 3750 }, -- Unchecked Expansion
    [95123] = { "Riverglades", 44, 3750 }, -- A Blast Ye Scurvy Dogs!
    [95124] = { "Riverglades", 45, 3900 }, -- Admiral Lamora
    [95125] = { "Paladin", 25, 1000, "H" }, -- Ott's Masterwork
    [95126] = { "Paladin", 25, 1000, "H", nil, "Moonsilver Blade" }, -- The Moonsilver Blade
    [95140] = { "Paladin", 26, 2650, "H", "Elite", "Wolfsbane" }, -- Old Fire-Eye
    [95141] = { "Stranglethorn Vale", 38, 290, "H" }, -- Report to Rog'mar
    [95143] = { "Arathi Highlands", 38, 290, "H" }, -- Finding Tan'jani
    [95144] = { "Tanaris", 38, 290 }, -- Overseas Delivery
    [95147] = { "Riverglades", 37, 290, "A" }, -- The Lost Scout
    [95148] = { "Riverglades", 37, 290, "A" }, -- Southern Watch Gnoll Report
    [95156] = { "Riverglades", 37, 2100, "A" }, -- Stuff 'Em and Stick 'Em
    [95161] = { "Duskwood", 22, 180, "A", nil, "Tarnished Locket" }, -- Remember That I Love You
    [95162] = { "Riverglades", 41, 3300, "H", nil, "Recipe: Plain Ol' Paletusk" }, -- Paletusk Harvesting
    [95163] = { "Riverglades", 40, 3150, "H" }, -- Drive Them Back
    [95165] = { "Riverglades", 44, 3750 }, -- See Ya, Scallywags!
    [95181] = { "Riverglades", 42, 350, "H" }, -- Twilight Scouting Report
    [95183] = { "Riverglades", 41, 1650, "H" }, -- Step One: Rock
    [95184] = { "Riverglades", 38, 2850, "A" }, -- The Sharpest of Blades
    [95189] = { "Ruins of Lordaeron", 22, 2600, nil, "Dungeon", "Small Sack of Gems" }, -- Crest of Lordaeron
    [95194] = { "Dustwallow Marsh", 53, 1300, "A" }, -- Our Man in Theramore
    [95195] = { "Ruins of Lordaeron", 22, 2600, nil, "Dungeon" }, -- Bloodied Insignia
    [95196] = { "Dustwallow Marsh", 53, 1300, "A" }, -- Watch Yer Back
    [95198] = { "Dustwallow Marsh", 53, 1300, "A" }, -- The Return of the King?
    [95204] = { "Ruins of Lordaeron", 22, 2600, nil, "Dungeon", "Small Sack of Gems" }, -- Crest of Lordaeron
    [95212] = { "Dun Morogh", 10, 630, "A" }, -- Never Saddle on Quality
    [95213] = { "Dun Morogh", 10, 90, "A" }, -- Stolen Blasting Powder
    [95214] = { "Dun Morogh", 10, 840, "A" }, -- Stolen Blasting Powder
    [95216] = { "Ruins of Lordaeron", 22, 2600, nil, "Dungeon" }, -- The New Plague
    [95217] = { "Dun Morogh", 10, 630, "A", nil, "Plans: Rough Copper Chain Boots" }, -- The Quarry's Smith
    [95218] = { "Mount Hyjal", 56, 580, "A" }, -- More of the Same
    [95219] = { "Riverglades", 41, 330, "A" }, -- From Port to Port
    [95248] = { "Mount Hyjal", 59, 640, "H" }, -- To the Summit of Eternity
    [95250] = { "Ruins of Lordaeron", 21, 1650, nil, "Dungeon" }, -- Abominable Creatures
    [95254] = { "Riverglades", 42, 3450, nil, nil, "Undermine Clam Chowder" }, -- WANTED: Trapclaw
    [95260] = { "Riverglades", 42, 350 }, -- Terrors From the Deep
    [95261] = { "Riverglades", 42, 3450 }, -- It Takes Guts
    [95262] = { "Alcaz Prison", 53, 6550, nil, "Dungeon" }, -- The Secret Prison
    [95263] = { "Alcaz Prison", 53, 1300, nil, "Dungeon" }, -- Somber News
    [95264] = { "Stormwind City", 53, 1300, "A", nil, "Pick one: couriers clasp, fatebound buckler, dustwallow dirk" }, -- Shaw Needs To Know
    [95267] = { "Riverglades", 42, 3450, nil, nil, "Bottle of Powderfuse Port" }, -- The Monster Surfaces
    [95273] = { "Mount Hyjal", 59, 6400, nil, "Elite", "Pick one: shallow bindings, murkborn girdle" }, -- Water of Hyjal
    [95278] = { "Riverglades", 45, 390, "H" }, -- It Is Time, Brother...
    [95283] = { "Dustwallow Marsh", 53, 1300, "H" }, -- The Missing Kor'kron
    [95284] = { "Dustwallow Marsh", 53, 1300, "H", "Elite" }, -- The Elite of the Elite
    [95285] = { "Dustwallow Marsh", 53, 1300, "H" }, -- Right Place, Wrong Time
    [95288] = { "Riverglades", 43, 3600 }, -- Smuggler's Paradise
    [95293] = { "Riverglades", 42, 1700 }, -- Smuggler's Special
    [95294] = { "Riverglades", 42, 350 }, -- Smuggler's Bargain
    [95295] = { "Riverglades", 40, 320 }, -- I Know a Guy
    [95296] = { "Riverglades", 40, 320 }, -- Shipping and Handling
    [95309] = { "Alcaz Prison", 53, 6550, nil, "Dungeon" }, -- No Orc Left Behind
    [95312] = { "Riverglades", 40, 320 }, -- Coming to Collect
    [95314] = { "Tirisfal Glades", 10, 840, "H" }, -- That Shadowvale Green Elixir
    [95315] = { "Arathi Highlands", 38, 290, "A" }, -- The Riverglades Report
    [95316] = { "Mount Hyjal", 57, 6000, nil, nil, "Pick one: crowfeather tunic, bristlecone cloak" }, -- The Experimental Method
    [95317] = { "Mount Hyjal", 57, 6000 }, -- Notation, Notation, Notation
    [95318] = { "Mount Hyjal", 57, 6000, nil, nil, "Acolyte Blade" }, -- Taste of Ash
    [95319] = { "Mount Hyjal", 57, 6000 }, -- Crystalline Collection
    [95320] = { "Mount Hyjal", 57, 600 }, -- A Curious Question
    [95321] = { "Riverglades", 40, 3150 }, -- Tazzik's Dues
    [95322] = { "Riverglades", 40, 2350 }, -- Get the Goods
    [95325] = { "Riverglades", 40, 2350 }, -- We've Been Robbed!
    [95326] = { "Riverglades", 39, 3000 }, -- The Big Payback
    [95327] = { "Riverglades", 40, 3150 }, -- All's Well That Ends Well
    [95328] = { "Tirisfal Glades", 13, 910, "H" }, -- Whispering Horror Residue
    [95329] = { "Riverglades", 38, 290, "A" }, -- Out in the Field
    [95330] = { "Riverglades", 37, 290, "A" }, -- Love Thy Neighbor
    [95349] = { "Zephras Isle", 13, 90, "H" }, -- The Earthen Ring
    [95350] = { "Orgrimmar", 13, 680, "H" }, -- Welcome to Azeroth
    [95378] = { "Mount Hyjal", 58, 6200 }, -- The Hydra's Head
    [95379] = { "Mount Hyjal", 58, 6200 }, -- A Revenge So Sweet
    [95380] = { "Mount Hyjal", 57, 6000 }, -- A Prolific Source
    [95383] = { "Riverglades", 40, 320 }, -- Shipping and Handling
    [95384] = { "Stranglethorn Vale", 40, 3150, nil, nil, "Dudd's Second-Favorite Wand" }, -- Partial Mystical Notes
    [95385] = { "Stranglethorn Vale", 43, 3600, nil, nil, "Dudd's Thinkin' Cap" }, -- Torn Mystical Scroll
    [95417] = { "Riverglades", 40, 320, "H" }, -- The Purple Ones
    [95418] = { "Riverglades", 40, 320, "H" }, -- Spread the Word
    [95420] = { "Riverglades", 40, 320, "H" }, -- Land of Giants
    [95424] = { "Riverglades", 41, 3300, "H" }, -- Might Makes Right
    [95425] = { "Riverglades", 42, 3450, "H" }, -- Unworthy Champion
    [95426] = { "Riverglades", 39, 3000, "A" }, -- Rog'mar Supplies
    [95427] = { "Riverglades", 41, 3300, "H", "Elite" }, -- Twilight No More!
    [95428] = { "Riverglades", 41, 330, "H" }, -- Clugfist's Decree
    [95431] = { "Riverglades", 41, 330, "H" }, -- Rumblings of Discontent
    [95432] = { "Riverglades", 43, 1800, "H" }, -- Rise Up!
    [95433] = { "Riverglades", 46, 5050, "H", "Elite", "Thud Hammer" }, -- Death to the Executioner
    [95454] = { "Alcaz Prison", 53, 6550, nil, "Dungeon" }, -- The Honor of the Kor'kron
    [95472] = { "Riverglades", 40, 2350, nil, nil, "Sweat-Stained Shirt" }, -- Consolation Prize
    [95483] = { "Alcaz Prison", 53, 1300, nil, "Dungeon" }, -- Thrall Needs to Know
    [95494] = { "The Barrens", 18, 1350, "H" }, -- Bruised Pride and Lion Hides
    [95495] = { "The Barrens", 18, 140, "H" }, -- The Hermit Tanner
    [95507] = { "The Barrens", 18, 1000, "H" }, -- Vrang's Game
    [95508] = { "The Barrens", 18, 1350, "H", nil, "Pick one: keen skinning knife, wildgore greatsword, waltons second favorite gun" }, -- Unwelcome Guests
    [95511] = { "Darnassus", 40, 1550, "A", nil, "Pick one: reins of the striped nightsaber, reins of the striped frostsaber, reins of the spotted frostsaber, reins of the striped dawnsaber" }, -- Your First Feline Friend
    [95534] = { "Alterac Mountains", 36, 2800, nil, nil, "Brilliant Cloak" }, -- Strahnbrad Mystery
    [95555] = { "Feralas", 50, 4700 }, -- Corrupted Nature
    [95561] = { "Riverglades", 38, 1450, "A", nil, "Goldenbark Apple" }, -- Apple of My Eye
    [95562] = { "Riverglades", 41, 3300, "A", "Elite" }, -- Cut Off the Heads
    [95568] = { "Mount Hyjal", 56, 4350 }, -- Seeds for a New Season
    [95569] = { "Mount Hyjal", 56, 5800 }, -- Hope for Hatchlings
    [95599] = { "Feralas", 42, 3450 }, -- The Old Key
    [95601] = { "Riverglades", 40, 3150, "H" }, -- The Purple Ones
    [95602] = { "Riverglades", 40, 3150, "H" }, -- Sickening Lights
    [95603] = { "Riverglades", 38, 2150, "A" }, -- Bats in the Belfry
    [95611] = { "Mount Hyjal", 56, 1450, nil, nil, "Staghide Drape" }, -- Rites of Respect
    [95613] = { "Riverglades", 38, 2150, "A" }, -- Keeping the Light On
    [95615] = { "Riverglades", 38, 2150, "A", nil, "Pick one: sacristan band, verger greaves; Also get: Warding Candle" }, -- In Memoriam
    [95621] = { "The Barrens", 18, 1000, "H" }, -- Trouble in the Valley
    [95642] = { "Riverglades", 40, 3150, "A" }, -- Abominable Magics
    [95643] = { "Riverglades", 40, 3150, "A" }, -- Indiscriminate Purge
    [95646] = { "Excavation Site: Wetlands", 31, 3150, nil, "Dungeon" }, -- Horrors in the Highland
    [95647] = { "Excavation Site: Wetlands", 31, 2500, nil, "Dungeon" }, -- Lost in the Thicket Things
    [95663] = { "Excavation Site: Wetlands", 31, 250, nil, "Dungeon" }, -- Dragonmaw Rumors
    [95664] = { "Excavation Site: Wetlands", 31, 630, nil, "Dungeon" }, -- Elder Knowledge
    [95682] = { "Excavation Site: Wetlands", 31, 3150, nil, "Dungeon", "Bloody Map" }, -- Open the Maw
    [95697] = { "Excavation Site: Wetlands", 31, 3150, nil, "Dungeon" }, -- Changing Tastes
    [95737] = { "Excavation Site: Wetlands", 31, 630, nil, "Dungeon" }, -- Seeking Caitlin
    [95748] = { "Stranglethorn Vale", 40, 3150, "H" }, -- The Gurubashi Legends of Old
    [95751] = { "Shaman", 50, 4700 }, -- Odd Totems
    [95753] = { "Shaman", 45, 1950 }, -- Challenge of the Desert Wolf
    [95766] = { "Mount Hyjal", 56, 580 }, -- Fine Feathered Friend
    [95769] = { "Mount Hyjal", 57, 3000, "H", nil, "tattered sandals, pattern runecloth cuffs" }, -- Threading a Solution
    [95770] = { "Stranglethorn Vale", 40, 3150, "H" }, -- Locating the Lost City
    [95771] = { "Elwynn Forest", 10, 840, "A", nil, "Unholy Icon" }, -- A Taste of Darkness
    [95772] = { "Excavation Site: Wetlands", 31, 3150, nil, "Dungeon" }, -- Songblade Search
    [95773] = { "Stranglethorn Vale", 37, 2850, "H" }, -- Enemies in the Water
    [95774] = { "The Barrens", 20, 1550, "H" }, -- Her Name Is Olgra
    [95775] = { "The Drowned City", 40, 3150, nil, "Dungeon" }, -- The Drowned City
    [95776] = { "The Drowned City", 38, 3550, nil, "Dungeon" }, -- The Only Good Brinescale...
    [95786] = { "Stranglethorn Vale", 40, 3150, "A" }, -- An Acquaintance in Southshore
    [95787] = { "The Drowned City", 40, 3150, nil, "Dungeon" }, -- Take Two With Water
    [95788] = { "The Drowned City", 40, 3150, nil, "Dungeon" }, -- Magics of the Drowned City
    [95789] = { "The Drowned City", 40, 3900, nil, "Dungeon" }, -- Shady Saltseers
    [95790] = { "Shaper's Terrace", 60, 6600, nil, "Dungeon" }, -- Digestible Research
    [95791] = { "The Drowned City", 40, 3900, nil, "Dungeon" }, -- The Saltseer Captain
    [95792] = { "Riverglades", 42, 3450 }, -- Clear 'em Out
    [95793] = { "Mount Hyjal", 59, 6400 }, -- Stemming the Demon Tide
    [95795] = { "Excavation Site: Wetlands", 31, 3150, nil, "Dungeon" }, -- Fallen in the Fen
    [95798] = { "Alterac Mountains", 40, 2350, "A", nil, "Pick one: rune etched epaulets, apprentice sorcerers slacks" }, -- The Web of Magic
    [95799] = { "Ironforge", 40, 2350, "A", nil, "Pick one: ancient voodoo pouch, intrepid explorers chainmail; Also get: Translated Tale of I'lalai" }, -- Findings for the Explorer's League
    [95803] = { "Paladin", 12, 910, "H" }, -- A Token of Good Faith
    [95805] = { "Mulgore", 4, 360, "H", nil, "Scorched Leather Pouch" }, -- Grace of An'she and Mu'sha
    [95809] = { "Excavation Site: Wetlands", 31, 3150, nil, "Dungeon" }, -- Heartwoven
    [95810] = { "Excavation Site: Wetlands", 31, 630, nil, "Dungeon" }, -- Lost Relic Carry
    [95816] = { "Redridge Mountains", 60, 660 }, -- Sign Me Up!
    [95817] = { "Ironforge", 60, 660 }, -- Rotgath Stonebeard
    [95818] = { "Ironforge", 60, 6600, nil, nil, "Pick one: alchemy sign, blacksmithing sign, enchanting sign, engineering sign, leatherworking sign, tailoring sign; Also get: Dwarven Tradeskill Signpost" }, -- A Quick Craft
    [95819] = { "The Barrens", 60, 660 }, -- Sign Me Up!
    [95820] = { "Orgrimmar", 60, 660 }, -- Karolek
    [95821] = { "Orgrimmar", 60, 6600, nil, nil, "Pick one: alchemy sign, blacksmithing sign, enchanting sign, engineering sign, leatherworking sign, tailoring sign; Also get: Orcish Tradeskill Signpost" }, -- A Quick Craft
    [95882] = { "Riverglades", 43, 4450, "H", "Elite", "Scoutmaster's Eyepatch" }, -- WANTED: Scoutmaster Vargas
    [95883] = { "Silverpine Forest", 23, 1400, "H" }, -- The Tortured Soul
    [95884] = { "Silverpine Forest", 23, 190, "H" }, -- The Offering Stone
    [95885] = { "Silverpine Forest", 23, 1850, "H", "Elite", "Loop of Sacrifice" }, -- The Offering of Blood
    [95912] = { "Riverglades", 42, 4300, "A", "Elite", "Pick one: bladewind, bladewhispers namesake" }, -- WANTED: Blademaster Kaijo
    [95913] = { "Riverglades", 38, 2850, "A", nil, "Pick one: fur lined bracers, coyote hide wraps" }, -- Fit for a Princess
    [95924] = { "Shaper's Terrace", 60, 6600, nil, "Dungeon" }, -- Panic at the Digsite
    [95925] = { "Shaper's Terrace", 60, 6600, nil, "Dungeon" }, -- Mapping the Way Forward
    [95926] = { "Shaper's Terrace", 60, 6600, nil, "Dungeon" }, -- The Dark Crystal
    [95928] = { "Shaper's Terrace", 60, 6600, nil, "Dungeon" }, -- Crystalline Elements
    [95934] = { "Riverglades", 42, 3450 }, -- Proof of Profit
    [95935] = { "Riverglades", 43, 4450, "A", "Elite" }, -- Hail the Dragonslayer
    [95936] = { "Riverglades", 43, 4450, "H", "Elite" }, -- Hail the Dragonslayer
    [95943] = { "Riverglades", 38, 2150, "A" }, -- Foreman's Plight
    [95951] = { "Riverglades", 38, 2850, "H" }, -- Fetch 'n' Fletch
    [95955] = { "Riverglades", 39, 3000, "H" }, -- Stick 'Em
    [95957] = { "Riverglades", 38, 290, "A" }, -- Drink Up!
    [95961] = { "Riverglades", 38, 290, "A" }, -- Stepped Out
    [95975] = { "Riverglades", 41, 3300, "A" }, -- Her World
    [95981] = { "Silverpine Forest", 20, 1550, "H", nil, "Roadwatcher's Confidence" }, -- Watching the Roads
    [95982] = { "Riverglades", 38, 2850 }, -- Not My Circus
    [95983] = { "Riverglades", 38, 710, "A" }, -- A Feast for Buzzards
    [95984] = { "Riverglades", 39, 3000, "A" }, -- Song of the Strider
    [95986] = { "Riverglades", 41, 3300, "A", "Elite" }, -- King of the Wild Plains
    [95988] = { "Riverglades", 38, 2850, "A", nil, "Tessa's Tonic" }, -- Goes Down Smooth
    [95991] = { "Riverglades", 42, 4300, "A", "Elite", "Crocskin Waders" }, -- WANTED: Ghostmaw
    [95992] = { "Riverglades", 42, 4300, "H", "Elite", "Crocskin Waders" }, -- WANTED: Ghostmaw
    [95998] = { "Camping", 6, 410, "A" }, -- The Great Outdoors
    [95999] = { "Redridge Mountains", 25, 2550, "A", "Elite", "Pick one: incinerators boots, alacritous treads, disjointed shoes" }, -- WANTED: Incinerator Gar'im
    [96003] = { "Mount Hyjal", 60, 6600, nil, nil, "Depleted Eye of Influence" }, -- Drawing Down the Malevolent
    [96009] = { "Riverglades", 38, 2150, "A", nil, "Lumber Luggers" }, -- High Stakes
    [96010] = { "Shen'dralas", 41, 2450 }, -- Fragments of the Pylons
    [96015] = { "Riverglades", 43, 3600, "A", nil, "Twilight Mine Light" }, -- A Miner Problem
    [96016] = { "Shaman", 40, 3900, "A", nil, "Pick one: lightnings grasp, tidebringers claw, rage of the storm; Also get: Elementalist's Guard" }, -- The Tempest's Weapons
    [96018] = { "Shen'dralas", 43, 3600 }, -- Powering the Pylons
    [96020] = { "Warlock", 35, 2750 }, -- Playing with Fire
    [96025] = { "Mount Hyjal", 59, 640 }, -- As the Crow Flies
    [96026] = { "Riverglades", 41, 2450, "H", nil, "Plans: Mithril Warhammer" }, -- Step Two: More Rock
    [96027] = { "Riverglades", 41, 3300, "H" }, -- Might Over Magic
    [96028] = { "Riverglades", 40, 3150, "H" }, -- Magic Over Might
    [96031] = { "Camping", 6, 270, "A" }, -- Camping 101: Leatherworking
    [96044] = { "Camping", 6, 270, "A" }, -- Camping 101: Blacksmithing
    [96045] = { "Camping", 6, 270, "A" }, -- Camping 101: Alchemy
    [96046] = { "Camping", 6, 270, "A" }, -- Camping 101: Mining
    [96047] = { "Camping", 6, 270, "A" }, -- Camping 101: First Aid
    [96050] = { "Camping", 6, 270, "A" }, -- Camping 101: Fishing
    [96055] = { "Camping", 6, 270, "A" }, -- Camping 101: Herbalism
    [96056] = { "Camping", 6, 270, "A" }, -- Camping 101: Skinning
    [96057] = { "Camping", 6, 270, "A" }, -- Camping 101: Tailoring
    [96058] = { "Camping", 6, 270, "A" }, -- Camping 101: Engineering
    [96059] = { "Camping", 6, 270, "A" }, -- Camping 101: Enchanting
    [96060] = { "Shen'dralas", 42, 3450, nil, nil, "Pick one:phantasmal shiv, spectral magisters commission, greatsword of great pasts" }, -- Tempered Expectations
    [96063] = { "Riverglades", 38, 2850, nil, nil, "Riverglades Marsh Gas" }, -- Gaseous Gold
    [96067] = { "Riverglades", 40, 2350 }, -- Rock 'em and Sock 'em
    [96075] = { "Stranglethorn Vale", 60, 0, nil, nil, "Undermine Satchel" }, -- In Demand - Blackrock Legal Records
    [96076] = { "Stranglethorn Vale", 60, 0, nil, nil, "Undermine Satchel" }, -- In Demand - Ancient Elven Curiosities
    [96077] = { "Mount Hyjal", 58, 6200, "A", nil, "Thomas's Ring" }, -- Belle's Ring
    [96078] = { "Stranglethorn Vale", 40, 2350, "H", nil, "Pick one: ceremonial mallet, sacrificial sword, ilalai flayer; Also get: translated tale of ilalai, tale of ilalai in zandali" }, -- A Tale Spun Around the Fire
    [96081] = { "Riverglades", 40, 1550, "A" }, -- Wound Dressings
    [96082] = { "Riverglades", 40, 1550, "A" }, -- Doctor's Orderly
    [96083] = { "Riverglades", 40, 320, "A" }, -- Clerical Quarantine
    [96084] = { "Riverglades", 40, 3150, "A" }, -- Something's in the Water
    [96085] = { "Riverglades", 42, 4300, "A", "Elite", "Superior Healing Potion" }, -- Upstream Contamination
    [96087] = { "Stranglethorn Vale", 60, 0, nil, nil, "Undermine Satchel" }, -- In Demand - Plague Records
    [96088] = { "Stranglethorn Vale", 60, 0, nil, nil, "Undermine Satchel" }, -- In Demand - Titan Relics
    [96101] = { "Camping", 6, 410 }, -- The Great Outdoors
    [96102] = { "Camping", 6, 270, "H" }, -- Camping 101: Tailoring
    [96103] = { "Riverglades", 38, 710, "H" }, -- A Feast for Buzzards
    [96104] = { "Riverglades", 39, 3000, "H" }, -- Song of the Strider
    [96105] = { "Riverglades", 41, 3300, "H", "Elite" }, -- King of the Wild Plains
    [96107] = { "Riverglades", 40, 3150, "H" }, -- Feathers for Fletching
    [96108] = { "Riverglades", 40, 2350, "H" }, -- Poison Tips
    [96109] = { "Riverglades", 40, 3150, "H", nil, "Matriarch Quiver" }, -- A Hunter's Quiver
    [96125] = { "Riverglades", 43, 360, "A" }, -- In Need of Relief
    [96126] = { "Riverglades", 44, 3750, "A" }, -- An Ogre's Captive
    [96130] = { "Mulgore", 5, 340, "H", nil, "Furred Belt" }, -- Chakuyak
    [96131] = { "Mount Hyjal", 58, 620 }, -- An Oldstone But An Old Friend
    [96135] = { "Shaman", 40, 3150, "A", "Elite" }, -- Heed My Call
    [96136] = { "Shaman", 35, 2750, "H", nil, "Air Totem" }, -- Call of Air
    [96137] = { "Duskwood", 25, 2000, "A" }, -- Ira's Dagger
    [96138] = { "Duskwood", 30, 2450, "A" }, -- Merrick's Bow
    [96139] = { "Duskwood", 23, 1400, "A", nil, "Memories of Valor" }, -- The Valor Family
    [96145] = { "Mount Hyjal", 58, 620 }, -- Past Wing and Claw
    [96204] = { "Paladin", 22, 1750, "H" }, -- The Windshaper's Wrath
    [96209] = { "Nighthaven", 58, 620 }, -- The Ancient, Orokai
    [96222] = { "Desolace", 42, 4300, nil, "Elite", "Pick one: kolkar marauder chain, traitors finger, kolkar hunters belt, ceremonial centaur blanket; Also get: Carved Centaur Totem" }, -- Khan Hratha
    [96241] = { "Mulgore", 29, 2350, "H" }, -- Talkin' bout Toxins, Mon
    [96243] = { "Shaman", 4, 180, "A" }, -- Call of Earth
    [96246] = { "Blackmaw Hold", 60, 0, nil, "Dungeon" }, -- Blackmaw Pouches
    [96252] = { "Mount Hyjal", 58, 3100, nil, nil, "Highfeather Bangle" }, -- Tarnished Treasures
    [96255] = { "Mount Hyjal", 58, 7750, nil, "Elite" }, -- Amalgamated Marrow
    [96259] = { "Mulgore", 29, 2350, "H" }, -- Defending the Dead
    [96260] = { "Mulgore", 29, 1750, "H", nil, "Pick one: spidersilk sack, spidersilk pouch; Also get: Crystal Thread Cloak" }, -- Stronger than Steel
    [96261] = { "Mulgore", 30, 3050, "H", "Elite", "Transformative Cocoon" }, -- The Broodmother
    [96262] = { "Mount Hyjal", 57, 4500 }, -- Prickly Pinecones
    [96264] = { "Shaman", 33, 3300, "A", "Dungeon" }, -- Elemental Aid
    [96265] = { "Winterspring", 60, 6600 }, -- Secret of the Barrow Deeps
    [96294] = { "Mulgore", 30, 1850, "H" }, -- A Darker Truth
    [96296] = { "Mount Hyjal", 58, 4650 }, -- Fetid Corruption
    [96301] = { "Mount Hyjal", 60, 1650 }, -- Power Wash
    [96302] = { "Mount Hyjal", 60, 3300 }, -- Arch Absolution
    [96303] = { "Mount Hyjal", 60, 3300 }, -- Memory Mist
    [96321] = { "Mount Hyjal", 58, 620 }, -- The Dying God
    [96322] = { "Mount Hyjal", 58, 7750, nil, nil, "Pick one: felflicks fire flicker, dirtwalker pendant" }, -- A Revenge Now Bitter
    [96332] = { "Alcaz Prison", 53, 5250, nil, "Dungeon" }, -- A Little Payback
    [96334] = { "Alcaz Prison", 53, 5250, nil, "Dungeon" }, -- Blood Red Bandanas
    [96335] = { "Alcaz Prison", 53, 1300, nil, "Dungeon" }, -- The Man in the Iron Chains
    [96337] = { "Alcaz Prison", 53, 5250, nil, "Dungeon", "Document Box" }, -- More Valuable Than Gold
    [96339] = { "The Barrens", 60, 0, nil, nil, "Holstered Replica Ironforge Air Rifle" }, -- Legacy Reward: Replica Ironforge Air Rifle
    [96369] = { "Alcaz Prison", 53, 1300, nil, "Dungeon" }, -- Bad News for Folkar
    [96376] = { "Alcaz Prison", 53, 6550, nil, nil, "Fractured Insignia" }, -- State Secrets
    [96377] = { "Alcaz Prison", 53, 6550, nil, nil, "Fractured Insignia" }, -- State Secrets
    [96379] = { "Alcaz Prison", 53, 6550, nil, nil, "Fractured Insignia" }, -- State Secrets
    [96381] = { "Alcaz Prison", 53, 5250, nil, "Dungeon" }, -- A Bit of Wet Work
    [96383] = { "The Barrens", 60, 0, nil, nil, "Spectral Bear Cub" }, -- Legacy Reward: Spectral Bear Cub
    [96390] = { "Dun Morogh", 13, 910, "A" }, -- Nip 'Em in the Bud
    [96391] = { "Dun Morogh", 15, 1050, "A" }, -- Underground Map
    [96392] = { "Dun Morogh", 13, 680, "A" }, -- Farsen's Watch
    [96393] = { "Hall of Thanes", 16, 1450, nil, "Dungeon" }, -- Old Ironforge Incursion
    [96394] = { "Hall of Thanes", 15, 1050, nil, "Dungeon" }, -- The Restless Dead
    [96395] = { "Hall of Thanes", 15, 1050, nil, "Dungeon" }, -- An Ancient Grudge
    [96403] = { "Hall of Thanes", 15, 1350, nil, "Dungeon" }, -- Important Heirlooms
    [96408] = { "Dun Morogh", 13, 680, "A" }, -- A Visitor to Dun Morogh
    [96435] = { "Mount Hyjal", 58, 620 }, -- A Fitting End
    [96438] = { "Paladin", 40, 2350, "A" }, -- Battle at the Mannoroc Coven
    [96449] = { "Paladin", 40, 2350, "A" }, -- Aeonas's Secret Refuge
    [96476] = { "Paladin", 53, 2650, "A" }, -- In Search of Aeonas
    [96494] = { "Mount Hyjal", 59, 640, "A" }, -- Gathering Storm
    [96529] = { "Mount Hyjal", 59, 6400, "A" }, -- A Shaw Deal
    [96550] = { "Mount Hyjal", 58, 1550 }, -- Battle Recall
    [96558] = { "Mount Hyjal", 60, 8300, nil, "Elite", "Pick one: kanais knife, toy soldier, illegible dogtags; Also get: Fishing Trip" }, -- Soldier's Solace
    [96559] = { "Mount Hyjal", 57, 3000, "A" }, -- Supply Drop
    [96561] = { "Mount Hyjal", 60, 3300 }, -- Last Wishes
    [96602] = { "City of Dalaran", 58, 0 }, -- More Unstable Magic
    [96603] = { "City of Dalaran", 60, 8300, nil, "Elite" }, -- Unstable Magic
    [96604] = { "Camping", 6, 410, "H" }, -- The Great Outdoors
    [96605] = { "Camping", 6, 410, "H" }, -- The Great Outdoors
    [96606] = { "Camping", 6, 410, "A" }, -- The Great Outdoors
    [96607] = { "Camping", 6, 410, "H" }, -- The Great Outdoors
    [96608] = { "Camping", 6, 410, "A" }, -- The Great Outdoors
    [96609] = { "City of Dalaran", 52, 5100, nil, nil, "Everlasting Silvermoon Shimmerwine" }, -- A Taste of Home
    [96616] = { "Mount Hyjal", 57, 4500, "H" }, -- Herbs for the Bruised and Weary
    [96622] = { "Elderwild", 57, 600, nil, nil, "Manual: Major Healing Potion" }, -- A Rest Without Pain
    [96626] = { "Camping", 6, 270, "A" }, -- Camping 101: Cooking
    [96627] = { "Camping", 6, 410, "A" }, -- The Adventurer
    [96628] = { "Camping", 6, 410, "A" }, -- The Adventurer
    [96629] = { "Camping", 6, 270, "A" }, -- Camping 101: Cooking
    [96630] = { "Camping", 6, 410, "A" }, -- The Adventurer
    [96634] = { "Camping", 6, 270, "A" }, -- Camping 101: Cooking
    [96638] = { "Camping", 6, 410 }, -- The Adventurer
    [96646] = { "Camping", 6, 270 }, -- Camping 101: Cooking
    [96652] = { "Camping", 6, 410, "H" }, -- The Adventurer
    [96655] = { "Camping", 6, 270, "H" }, -- Camping 101: Cooking
    [96656] = { "Camping", 6, 410, "H" }, -- The Adventurer
    [96658] = { "Camping", 6, 270, "H" }, -- Camping 101: Cooking
    [96659] = { "Camping", 6, 410, "H" }, -- The Adventurer
    [96661] = { "Camping", 6, 270, "H" }, -- Camping 101: Cooking
    [96666] = { "Mount Hyjal", 57, 3000 }, -- Burrow Bonding
    [96674] = { "Elderwild", 56, 2900, nil, nil, "Wool-Stitched Waistband" }, -- Ewe Wandered Off
    [96676] = { "Mount Hyjal", 59, 8050, "A", nil, "Pick one: punchys punchers, stormwind intelligence seal; Also get: Field Agent Beverage" }, -- Unsealing Blackthorne Pact
    [96770] = { "Zul'Farrak", 46, 5050, "A", "Dungeon" }, -- The Witch Doctor's Head
    [96771] = { "Krol'dok Stronghold", 45, 4850, nil, "Dungeon" }, -- Vengeance of the Highborne
    [96772] = { "Alcaz Prison", 53, 6550, nil, "Dungeon" }, -- The Dragon's Journal
    [96773] = { "Razorfen Downs", 41, 4100, "A", "Dungeon" }, -- The Coldbringer's Eye
    [96774] = { "The Drowned City", 40, 3900, nil, "Dungeon" }, -- Ancient Gurubashi Idol
    [96775] = { "Zul'Farrak", 46, 5050, "H", "Dungeon" }, -- Zum'rah's Head
    [96776] = { "Maraudon", 51, 6100, "H", "Dungeon" }, -- An'she's Radiance
    [96779] = { "Rogue", 24, 1950 }, -- Syndicate Sabotage
    [96781] = { "Rogue", 36, 2800 }, -- What's the Big Idea?
    [96782] = { "Rogue", 36, 2800 }, -- Covert Extraction
    [96783] = { "Rogue", 36, 2800 }, -- A Way In
    [96784] = { "Rogue", 36, 2800, "H" }, -- Master of Disguise
    [96785] = { "Rogue", 36, 2800, "H" }, -- Ain't No Telling
    [96786] = { "Rogue", 36, 3500, "H" }, -- The Syndicate Sting
    [96796] = { "Mount Hyjal", 56, 580 }, -- Woods Workshop
    [96797] = { "Blasted Lands", 54, 4100, "A" }, -- The Orphan
    [96798] = { "Blasted Lands", 54, 5450, "A" }, -- Into the Darkness
    [96799] = { "Blasted Lands", 54, 2700, "A" }, -- A Heavy Responsibility
    [96800] = { "Scarlet Monastery", 38, 2850, "A", "Dungeon", "Pick one: salve and salvation, knucklebound thimble" }, -- Past Due
    [96811] = { "Blasted Lands", 54, 5450, "A" }, -- Escaping the Shadows
    [96812] = { "City of Dalaran", 54, 5450 }, -- Thicker Than Water
    [96821] = { "Durotar", 6, 540, "H" }, -- Legging It
    [96822] = { "Durotar", 7, 480, "H" }, -- For Honor
    [96825] = { "Durotar", 6, 540, "H" }, -- This Fruit Could Bite Back
    [96830] = { "Mount Hyjal", 57, 3000, "H" }, -- Farsight Guided
    [96833] = { "Mount Hyjal", 56, 580, "A" }, -- Venom Maws
    [96873] = { "Durotar", 8, 530, "H" }, -- A Pain in the Neck
    [96874] = { "Durotar", 10, 840, "H", nil, "Plans: Rough Copper Chain Boots" }, -- This Is Spinal Axe
    [96875] = { "Durotar", 10, 840, "H", nil, "Pattern: Light Leather Reagent Bag" }, -- Beasts of Thunder Ridge
    [96876] = { "Durotar", 8, 880, "H", "Elite" }, -- Ukor's Lost Pack
    [96877] = { "Durotar", 12, 1150, "H" }, -- Halikor's Hoof
    [96895] = { "Tirisfal Glades", 12, 460, "H" }, -- The Argent Emissary
    [96896] = { "Tirisfal Glades", 12, 90, "H" }, -- A Righteous Cause
    [96897] = { "Tirisfal Glades", 12, 910, "H" }, -- The Cult of the Damned
    [96898] = { "Tirisfal Glades", 12, 910, "H" }, -- Remnants of War
    [96899] = { "Tirisfal Glades", 12, 460, "H" }, -- Bandarion Keep
    [96912] = { "Gadgetzan", 60, 0 }, -- Field of Honor: Week 1
    [96913] = { "Warsong Gulch", 60, 0 }, -- Field of Honor: Week 2
    [96930] = { "Mount Hyjal", 58, 620 }, -- The Capricious Corvid
    [96931] = { "Mount Hyjal", 58, 620 }, -- Heading Up the Mountain
    [96939] = { "Mount Hyjal", 58, 620 }, -- The Balance of Life and Death
    [96957] = { "Mount Hyjal", 58, 4650 }, -- Bone Sweet Bone
    [96959] = { "Mount Hyjal", 59, 3200 }, -- Blademaster's Bonfires
    [96964] = { "Mount Hyjal", 59, 640 }, -- A Clever Creature
    [96971] = { "Mount Hyjal", 59, 4800 }, -- To Outfox a Demon
    [96978] = { "Mount Hyjal", 57, 600 }, -- Violent Venison
    [96979] = { "Mount Hyjal", 57, 1500 }, -- Sacred Refreshment
    [96982] = { "Mulgore", 40, 0, "H", nil, "Pick one: white kodo, brown kodo, gray kodo" }, -- Your First Riding Kodo
    [96983] = { "Mount Hyjal", 60, 8300, nil, "Elite", "Pick one: polished doomguard edge, yashiros spirit bead" }, -- Yashiro's Windwalk
    [96984] = { "City of Dalaran", 33, 3950, nil, "Dungeon" }, -- Heart of Disruption
    [96986] = { "City of Dalaran", 33, 3950, nil, "Dungeon" }, -- The Grave Knight
    [96987] = { "City of Dalaran", 33, 3950, nil, "Dungeon" }, -- Opportunistic Education
    [96988] = { "City of Dalaran", 33, 3950, nil, "Dungeon" }, -- Source of Power
    [96989] = { "Durotar", 40, 0, "H", nil, "Pick one: whistle of the emerald raptor, whistle of the turquoise raptor, whistle of the violet raptor" }, -- Your First Riding Raptor
    [96991] = { "Mount Hyjal", 59, 4800 }, -- Trail Assist
    [96992] = { "Mount Hyjal", 57, 3000, "A" }, -- Resupply
    [96994] = { "Orgrimmar", 40, 0, "H", nil, "Pick one: horn of the brown wolf, horn of the dire wolf, horn of the timber wolf, horn of the black wolf" }, -- Your First Riding Wolf
    [96996] = { "Zephras Isle", 40, 3150, nil, nil, "Pick one: empyrean galestrider, umber galestrider, stormy galestrider" }, -- Your First Riding Galestrider
    [96997] = { "Tirisfal Glades", 40, 0, "H", nil, "Pick one: blue skeletal horse, red skeletal horse, brown skeletal horse, black skeletal horse" }, -- A Steed in Death as They Were in Life
    [96998] = { "Mount Hyjal", 58, 620, "H" }, -- Tribal Colors
    [96999] = { "Mount Hyjal", 58, 6200, "H", nil, "Pick one: plain handwraps, war painted cuffs" }, -- Wrap Return
    [97000] = { "Mount Hyjal", 57, 3000, "H" }, -- Grain of Memory
    [97001] = { "Mount Hyjal", 57, 6000, "H" }, -- Sawyer's Legacy
    [97003] = { "The Barrens", 21, 2050, "H", "Elite", "Pick one: cholaruks trophy sword, big bad basher, quilboar toothpick, thornwoven shield" }, -- Chol'aruk the Ravener
    [97005] = { "The Barrens", 21, 2050, "A", "Elite", "Pick one: cholaruks trophy sword, big bad basher, quilboar toothpick, thornwoven shield" }, -- Chol'aruk the Ravener
    [97006] = { "Mount Hyjal", 60, 660, "H" }, -- Notarized Claim
    [97007] = { "Mount Hyjal", 57, 4500, "H", nil, "Pick one: abigails hope, sawyer family seal, hand hewn buckler" }, -- Wood Remains
    [97009] = { "Mount Hyjal", 59, 6400 }, -- Maerion's Misery
    [97010] = { "Mount Hyjal", 59, 3200, nil, nil, "Thaelemaches' Talisman" }, -- Blind Vengeance
    [97017] = { "Dun Morogh", 40, 1550, "A", nil, "Pick one: brown ram, gray ram, white ram" }, -- Your First Riding Ram
    [97018] = { "Dun Morogh", 40, 0, "A" }, -- Learning to Ride
    [97022] = { "Paladin", 40, 780, "H" }, -- Report to Danitha
    [97029] = { "Zephras Isle", 60, 0, nil, nil, "Eluvi'ana" }, -- Eluvi'ana
    [97045] = { "Elwynn Forest", 40, 0, "A", nil, "Pick one: brown horse bridle, chestnut mare bridle, pinto bridle" }, -- Your First Horse
    [97046] = { "Dun Morogh", 40, 1550, "A", nil, "Pick one: red mechanostrider, blue mechanostrider, green mechanostrider, unpainted mechanostrider" }, -- Your First Mechanostrider
    [97047] = { "Stranglethorn Vale", 38, 2850 }, -- The Cook in the Cage
    [97048] = { "Stranglethorn Vale", 38, 2850, nil, nil, "Pick one: kurzen headshrinkers cinch, jailers discarded chain, crusty cuffs" }, -- Returning to Port
    [97049] = { "Shaper's Terrace", 60, 6600, nil, "Dungeon" }, -- Essence of Seeping Slimes
    [97065] = { "Fishing", 60, 0, nil, nil, "Speckled Tastyfish" }, -- Tip the Scales - Keefer's Angelfish
    [97066] = { "Fishing", 60, 0, nil, nil, "Speckled Tastyfish" }, -- Tip the Scales - Brownell's Blue Striped Racer
    [97067] = { "Fishing", 60, 0, nil, nil, "Speckled Tastyfish" }, -- Tip the Scales - Dezian Queenfish
    [97074] = { "Darnassus", 40, 0, "A" }, -- Learning to Ride
    [97119] = { "Mount Hyjal", 57, 3000, "H", nil, "recipe steaming stag steak, steaming stag steak" }, -- Now We're Cooking
    [97130] = { "The Drowned City", 40, 3900, nil, "Dungeon" }, -- Ancient Gurubashi Secrets
    [97168] = { "Shaman", 60, 4950, "A" }, -- Material Assistance
    [97169] = { "Shaman", 60, 9950, "A", "Dungeon", "Pick one: skyfury helm, skyfury gauntlets" }, -- The Darkreaver Menace
    [97170] = { "Elwynn Forest", 40, 0, "A" }, -- Learning to Ride
    [97171] = { "Wetlands", 40, 1550, "A", nil, "Pick one: brown horse bridle, chestnut mare bridle, pinto bridle, black stallion bridle" }, -- Your First Horse
    [97173] = { "Blackmaw Hold", 59, 6400, nil, "Dungeon" }, -- Blackmaw Magic
    [97174] = { "Paladin", 60, 660, "H" }, -- A Worthy Endeavor
    [97175] = { "Paladin", 60, 660, "H" }, -- Due Sacrifice
    [97176] = { "Paladin", 60, 6600, "H" }, -- Exorcising Terrordale
    [97177] = { "Paladin", 60, 660, "H" }, -- Acts of Mercy
    [97178] = { "Paladin", 60, 660, "H" }, -- Ott of Tarren Mill
    [97179] = { "Paladin", 60, 1650, "H", "Dungeon" }, -- Collection of Goods
    [97180] = { "Paladin", 60, 6600, "H" }, -- Ott's Finest Work
    [97182] = { "Paladin", 60, 4950, "H", "Dungeon" }, -- An Offering of Vengeance
    [97183] = { "Paladin", 60, 8300, "H" }, -- Blessed Arcanite Barding
    [97184] = { "Paladin", 60, 3300, "H" }, -- The Divination Scryer
    [97185] = { "Paladin", 60, 9950, "H", "Dungeon" }, -- Justice and Retribution
    [97186] = { "Paladin", 60, 660, "H", nil, "Manna-Enriched Horse Feed" }, -- Manna-Enriched Horse Feed
    [97188] = { "Dun Morogh", 40, 0, "A" }, -- Learning to Ride
    [97194] = { "Orgrimmar", 40, 0, "H" }, -- Learning to Ride
    [97196] = { "Razorfen Downs", 41, 4100, "H", "Dungeon" }, -- The Coldbringer's Eye
    [97197] = { "Blackrock Depths", 55, 7050, "H", "Dungeon" }, -- Fragment of the Firelands
    [97198] = { "Blackmaw Hold", 59, 8050, nil, "Dungeon" }, -- Blackmaw Magic
    [97200] = { "Orgrimmar", 40, 0, "H" }, -- Learning to Ride
    [97203] = { "Tirisfal Glades", 40, 0, "H" }, -- Learning to Ride
    [97204] = { "Mulgore", 40, 0, "H" }, -- Learning to Ride
    [97205] = { "Zephras Isle", 40, 0 }, -- Learning to Ride
    [97220] = { "Stormwind City", 15, 540, "A" }, -- Philmor's Favor
    [97222] = { "Stormwind City", 15, 270, "A", nil, "Dalaran Sharp" }, -- Gatehouse Goods
    [97223] = { "Durotar", 9, 780, "H", nil, "Raptorscale Pants" }, -- Bloodtalon Matriarch
    [97225] = { "Durotar", 9, 780, "H", nil, "Depleted Ritual Band" }, -- Forgotten Loa Idols
    [97234] = { "Stormwind City", 18, 680, "A" }, -- Reading Room
    [97236] = { "Teldrassil", 5, 450, "A" }, -- Fang of Githyiss
    [97237] = { "Stormwind City", 18, 680, "A", nil, "Pick one: rumsey rum light, ice cold milk" }, -- Shelf Picked
    [97242] = { "Orgrimmar", 15, 110, "H" }, -- Yelmak's Medley
    [97243] = { "Shaman", 10, 420, "H" }, -- Call of Fire
    [97244] = { "Shaman", 10, 840, "H" }, -- Call of Fire
    [97245] = { "Shaman", 10, 840, "H" }, -- Call of Fire
    [97246] = { "Orgrimmar", 15, 110, "H" }, -- Meal Appeal
    [97249] = { "Orgrimmar", 15, 110, "H" }, -- Favorite Food
    [97250] = { "The Barrens", 23, 2300, "H", "Elite", "Pick one: encroachers claim, pathfinders clearway, travelers shawl" }, -- Wrongly Blamed, Justly Corrected
    [97253] = { "The Barrens", 15, 1050, nil, nil, "Scuffed Shipping Crate" }, -- Parts and Pieces
    [97257] = { "Shaman", 10, 1050, "H", nil, "fire totem, totem of charged flames" }, -- Call of Fire
    [97263] = { "Ironforge", 2, 50, "A" }, -- Your Package Has Arrived
    [97264] = { "Winterspring", 58, 6200, "H" }, -- Shardtooth Pulling
    [97265] = { "Desolace", 33, 2650, "H", nil, "Pick one: akarais tattered vestments, dagger of deals" }, -- Hate the Hatefury
    [97270] = { "The Maul", 60, 660, nil, "PvP" }, -- Brawl at the Maul
    [97271] = { nil, 60, 0, nil, nil, "Shen'dralar Relic" }, -- Maul or Nothing!
    [97275] = { "Orgrimmar", 15, 800, "H", nil, "Pick one: lesser mana potion, healing potion" }, -- Whuut's the Rush
    [97277] = { "Anvilmar", 6, 410, "A", nil, "Canvas Latchbag" }, -- Grund and Gozwin
    [97279] = { "Durotar", 2, 170, "H" }, -- Wayward Weapons
    [97281] = { "Durotar", 11, 880, "H" }, -- A Simmering Storm
    [97282] = { "Durotar", 10, 840, "H", nil, "Pick one: makeshift stormcaller, rezlaks spare knife; Also get: Makeshift Stormcaller" }, -- Stormy Potential
    [97284] = { "Desolace", 33, 2650, "A" }, -- Vahlarriel's Vengeance
    [97286] = { "Mage", 20, 0 }, -- Research Access
    [97287] = { "Alterac Mountains", 33, 270, "H" }, -- Shrewd Negotiations
    [97288] = { "Ruins of Lordaeron", 21, 1650, nil, "Dungeon" }, -- Unending Torment
    [97289] = { "Ruins of Lordaeron", 21, 1650 }, -- Unending Torment
    [97290] = { "Undercity", 21, 1650, "H", nil, "Pick one: slain barons signet, grave shroud, monstrous cleaver" }, -- Unending Torment
    [97291] = { "Ruins of Lordaeron", 21, 1650 }, -- Unending Torment
    [97292] = { "Ruins of Lordaeron", 21, 1650 }, -- Unending Torment
    [97319] = { "Western Plaguelands", 55, 560, "H" }, -- A Cousin Abroad
    [97326] = { "Orgrimmar", 15, 540, "H", nil, "Pick one: mogras friendship bracelet, thras friendship bracelet, puks friendship bracelet, brogs friendship bracelet, migis friendship bracelet" }, -- Rocks to Rests
    [97327] = { "Blackmaw Hold", 60, 6600, nil, "Dungeon" }, -- Blackmaw Pouches
    [97328] = { "Stranglethorn Vale", 35, 2750 }, -- Anything of Value
    [97329] = { "Stranglethorn Vale", 35, 2750 }, -- Where's the Key?
    [97331] = { "Stranglethorn Vale", 35, 2750 }, -- Zimmix's Great Escape
    [97332] = { "Stranglethorn Vale", 41, 3300, nil, nil, "Pick one: refunded ring, renegotiated ring, apology ring; Also get: Jug of Badlands Bourbon" }, -- Twice Misplaced Trust
    [97378] = { "Feralas", 50, 4700, "H", nil, "Pick one: mantle of scaleslaying, pauldrons of scaleslaying, shoulders of scaleslaying, shoulderplates of scaleslaying" }, -- Mirrorscale
    [97386] = { "Stranglethorn Vale", 44, 4650, "H", "Elite", "Pick one: maulers mutton, ogre bone, souvenir ogre tooth" }, -- The Offense of Grom'gol
    [97403] = { "Winterspring", 59, 6400, "H" }, -- Two-Headed Ravagers
    [97404] = { "Winterspring", 59, 6400, "H", nil, "Pick one: bear fur cowl, matriarchs mantle" }, -- Too Bad to Bear
    [97405] = { "Stranglethorn Vale", 44, 4650, "A", "Elite", "Pick one: maulers mutton, ogre bone, souvenir ogre tooth" }, -- Noise Complaints
    [97411] = { "Orgrimmar", 60, 6600, "H", "Dungeon", "Pick one: soulforge wristguards, soulforge bindings, soulforge bracers" }, -- An Earnest Proposition
    [97412] = { "Orgrimmar", 60, 9950, "H", "Dungeon", "Pick one: merciful gloves and belt set, radiant gloves and belt set, divine will gloves and belt set" }, -- Just Compensation
    [97420] = { "Stranglethorn Vale", 36, 2800, "A" }, -- Reduce, Reuse, Reconcile
    [97446] = { "Stonetalon Mountains", 40, 0, "H", nil, "Pick one: white kodo, brown kodo, gray kodo, lavender kodo" }, -- Your First Riding Kodo
    [97447] = { "Ironforge", 60, 6600, "A", "Dungeon", "Pick one: bindings of the five thunders, bracers of the five thunders, bands of the five thunders" }, -- An Earnest Proposition
    [97448] = { "Ironforge", 60, 9950, "A", "Dungeon", "Pick one: reliefs gloves and belt set, eruptions gloves and belt set, impacts gloves and belt set" }, -- Just Compensation
    [97453] = { "Stranglethorn Vale", 38, 1450, "H" }, -- Weed Whacked
    [97485] = { "Thunder Bluff", 10, 420, "H", nil, "Prepared Incense" }, -- Traditions of the Bluff
    [97490] = { "Mount Hyjal", 60, 6600, nil, "Elite", "Pick one: hailgiants fists, mountain climbers, frosts whisper pendant" }, -- Halt the Hail
    [97530] = { "Tanaris", 47, 4200, nil, nil, "A Little Somethin'" }, -- Dunemaul Dues
    [97534] = { "Tanaris", 45, 2900, "H" }, -- Gritty Business
    [97536] = { "Tanaris", 45, 2900, "A" }, -- Gnomish Garbage
    [97538] = { "Stonetalon Mountains", 26, 2100, "H" }, -- Pigments for Paints
    [97539] = { "Arathi Highlands", 36, 2800, "H" }, -- Silky Sutures
    [97540] = { "Tanaris", 50, 3550 }, -- Oasis
    [97558] = { "Tirisfal Glades", 11, 660, "H", nil, "Pick one: patchwing pants, howlhide vest, finscale soles" }, -- Hides for the Forsaken
    [97583] = { "Special", 1, 10, "H", nil, "Excitable Slime" }, -- WRIGGLE.
    [97617] = { "Badlands", 40, 3150, "A" }, -- Safety Checks
    [97663] = { "Badlands", 40, 3150, "H" }, -- Supplies and Studies
    [97821] = { "Badlands", 42, 4300, nil, "Elite", "Mirage Mirror" }, -- Mirage Mirror
    [97883] = { "Stormwind City", 60, 660, "A" }, -- End of the Dark Horde
    [97884] = { "Riverglades", 40, 3150, "H", nil, "Tome of Tremayne Family Blacksmithing Techniques" }, -- Armory of Sunnyglade
    [97891] = { "Undercity", 16, 1150, "H" }, -- Prompt Potion Runner
    [97894] = { "Darkshore", 17, 630, "A" }, -- Business in Auberdine
    [97899] = { "Camping", 6, 270, "H" }, -- Camping 101: Alchemy
    [97900] = { "Camping", 6, 270, "H" }, -- Camping 101: Blacksmithing
    [97901] = { "Camping", 6, 270, "H" }, -- Camping 101: Enchanting
    [97902] = { "Camping", 6, 270, "H" }, -- Camping 101: Engineering
    [97903] = { "Camping", 6, 270, "H" }, -- Camping 101: First Aid
    [97904] = { "Camping", 6, 270, "H" }, -- Camping 101: Fishing
    [97905] = { "Camping", 6, 270, "H" }, -- Camping 101: Herbalism
    [97906] = { "Camping", 6, 270, "H" }, -- Camping 101: Leatherworking
    [97907] = { "Camping", 6, 270, "H" }, -- Camping 101: Mining
    [97908] = { "Camping", 6, 270, "H" }, -- Camping 101: Skinning
    [97914] = { "Stormwind City", 17, 630, "A" }, -- Expanding Horizons
    [97915] = { "Camping", 6, 270, "A" }, -- Camping 101: Alchemy
    [97916] = { "Camping", 6, 270, "A" }, -- Camping 101: Blacksmithing
    [97917] = { "Camping", 6, 270, "A" }, -- Camping 101: Enchanting
    [97918] = { "Camping", 6, 270, "A" }, -- Camping 101: Engineering
    [97919] = { "Camping", 6, 270, "A" }, -- Camping 101: First Aid
    [97920] = { "Camping", 6, 270, "A" }, -- Camping 101: Fishing
    [97921] = { "Camping", 6, 270, "A" }, -- Camping 101: Herbalism
    [97922] = { "Camping", 6, 270, "A" }, -- Camping 101: Leatherworking
    [97923] = { "Camping", 6, 270, "A" }, -- Camping 101: Mining
    [97924] = { "Camping", 6, 270, "A" }, -- Camping 101: Skinning
    [97925] = { "Camping", 6, 270, "A" }, -- Camping 101: Tailoring
    [97926] = { "Darkshore", 17, 630, "A", nil, "Shipwright's Satchel" }, -- Making Do
    [97927] = { "Camping", 6, 270, "H" }, -- Camping 101: Alchemy
    [97928] = { "Camping", 6, 270, "H" }, -- Camping 101: Blacksmithing
    [97929] = { "Camping", 6, 270, "H" }, -- Camping 101: Enchanting
    [97930] = { "Camping", 6, 270, "H" }, -- Camping 101: Engineering
    [97931] = { "Camping", 6, 270, "H" }, -- Camping 101: First Aid
    [97932] = { "Camping", 6, 270, "H" }, -- Camping 101: Fishing
    [97933] = { "Camping", 6, 270, "H" }, -- Camping 101: Herbalism
    [97934] = { "Camping", 6, 270, "H" }, -- Camping 101: Leatherworking
    [97935] = { "Camping", 6, 270, "H" }, -- Camping 101: Mining
    [97936] = { "Camping", 6, 270, "H" }, -- Camping 101: Skinning
    [97937] = { "Camping", 6, 270, "H" }, -- Camping 101: Tailoring
    [97938] = { "Camping", 6, 270, "A" }, -- Camping 101: Alchemy
    [97939] = { "Camping", 6, 270, "A" }, -- Camping 101: Blacksmithing
    [97940] = { "Camping", 6, 270, "A" }, -- Camping 101: Enchanting
    [97941] = { "Camping", 6, 270, "A" }, -- Camping 101: Engineering
    [97942] = { "Camping", 6, 270, "A" }, -- Camping 101: First Aid
    [97943] = { "Camping", 6, 270, "A" }, -- Camping 101: Fishing
    [97944] = { "Camping", 6, 270, "A" }, -- Camping 101: Herbalism
    [97946] = { "Camping", 6, 270, "A" }, -- Camping 101: Leatherworking
    [97948] = { "Camping", 6, 270, "A" }, -- Camping 101: Mining
    [97949] = { "Camping", 6, 270, "A" }, -- Camping 101: Skinning
    [97950] = { "Camping", 6, 270, "A" }, -- Camping 101: Tailoring
    [97951] = { "Camping", 6, 270, "H" }, -- Camping 101: Alchemy
    [97952] = { "Camping", 6, 270, "H" }, -- Camping 101: Blacksmithing
    [97953] = { "Camping", 6, 270, "H" }, -- Camping 101: Enchanting
    [97954] = { "Camping", 6, 270, "H" }, -- Camping 101: Engineering
    [97955] = { "Camping", 6, 270, "H" }, -- Camping 101: First Aid
    [97956] = { "Camping", 6, 270, "H" }, -- Camping 101: Fishing
    [97957] = { "Camping", 6, 270, "H" }, -- Camping 101: Herbalism
    [97958] = { "Camping", 6, 270, "H" }, -- Camping 101: Leatherworking
    [97959] = { "Camping", 6, 270, "H" }, -- Camping 101: Mining
    [97960] = { "Camping", 6, 270, "H" }, -- Camping 101: Skinning
    [97961] = { "Camping", 6, 270, "H" }, -- Camping 101: Tailoring
    [97963] = { "Camping", 6, 270 }, -- Camping 101: Alchemy
    [97964] = { "Camping", 6, 270 }, -- Camping 101: Blacksmithing
    [97965] = { "Camping", 6, 270 }, -- Camping 101: First Aid
    [97967] = { "Camping", 6, 270 }, -- Camping 101: Fishing
    [97968] = { "Camping", 6, 270 }, -- Camping 101: Herbalism
    [97969] = { "Camping", 6, 270 }, -- Camping 101: Leatherworking
    [97970] = { "Camping", 6, 270 }, -- Camping 101: Mining
    [97971] = { "Camping", 6, 270 }, -- Camping 101: Skinning
    [97972] = { "Camping", 6, 270, "H" }, -- Camping 101: Tailoring
    [97973] = { "Camping", 6, 270, "A" }, -- Camping 101: Tailoring
    [97977] = { "Teldrassil", 3, 250, "A" }, -- Nature's Call
    [97979] = { "Night Elf", 1, 40, "A" }, -- The Goddess Provides
    [97985] = { "Undercity", 33, 3300, "H", "Elite" }, -- Thundering Hearts
    [97986] = { "Eastern Plaguelands", 57, 600 }, -- Argent Arbiter
    [97987] = { "Eastern Plaguelands", 57, 6000, "A", nil, "Pick one: high order pendant, shendorei signet" }, -- Stormwind's High Order
    [97988] = { "Eastern Plaguelands", 57, 6000, "H", nil, "Pick one: windshaper pendant, shendorei signet" }, -- Orgrimmar's Windshapers
    [98013] = { "Darkshore", 20, 1550, "A" }, -- Swelling Forces
    [98021] = { "Westfall", 13, 460, "A" }, -- Journey to Sentinel Hill
    [98024] = { "The Barrens", 13, 460, "H" }, -- Journey to the Crossroads
    [98025] = { "Darkshore", 13, 1150, "A", nil, "Pick one: swordfeather cloak, darnassian knife; Also get: Swordfeather Cloak" }, -- WANTED: Jai'vhanel
    [98027] = { "Ashenvale", 26, 1600, "A", nil, "Replica Crescent Necklace" }, -- Gleaming Crescent Necklace
    [98028] = { "Darkshore", 21, 1650, "A", nil, "Pick one: mathystra channeling orb, onus patience" }, -- Baron Marinous
    [98042] = { "Darkshore", 17, 1250, "A" }, -- It's All Fun and Games Until...
    [98046] = { "Teldrassil", 11, 90, "A" }, -- Crown of the Earth
    [98059] = { "Hillsbrad Foothills", 27, 2200, "A" }, -- Hillsbrad's Hoard
    [98065] = { "Teldrassil", 11, 90, "A" }, -- Crown of the Earth
    [98067] = { "Darnassus", 11, 660, "A" }, -- Eyes of the Sentinels
    [98069] = { "Thousand Needles", 30, 2450, "H" }, -- Stolen Freewind Supplies
    [98070] = { "Thousand Needles", 30, 2450, "H" }, -- Stop the Screeching
    [98071] = { "Hillsbrad Foothills", 27, 2200, "A", nil, "Brewer's Bracers" }, -- Brewer's Trade
    [98072] = { "Wetlands", 27, 2200, "A" }, -- Crocs of the Sky
    [98093] = { "The Barrens", 23, 1850, "H", nil, "Pick one: taurajo headband, beastcullers knife; Also get: Taurajo Headband" }, -- Field to Clear
    [98094] = { "Hillsbrad Foothills", 25, 1000, "H" }, -- Scout Support
    [98095] = { "Hillsbrad Foothills", 25, 2000, "H", nil, "Pick one: weathered deathstalkers blade, expended apothecary vial" }, -- Valuable Vantages
    [98096] = { "Azshara", 47, 420, "A" }, -- Sisters In Duty
    [98109] = { "Eastern Plaguelands", 57, 600 }, -- Bleeding Edge
    [98155] = { "Thousand Needles", 29, 2350, "A" }, -- Pristine Pesterhide Pelts
    [98156] = { "Thousand Needles", 29, 2350, "A", nil, "Pelt Pants" }, -- Packaged Pristine Pelts
    [98166] = { "Wetlands", 40, 1550, "A", nil, "Pick one: brown horse bridle, chestnut mare bridle, pinto bridle" }, -- Your First Horse
    [98189] = { "Wetlands", 25, 200, "A" }, -- Return the Statuette
    [98190] = { "Stormwind City", 25, 200, "A" }, -- A Friend of the Family
    [98191] = { "Stormwind City", 25, 2000, "A", nil, "Pick one: knights lance, royal dagger" }, -- A Friend of the Family
    [98192] = { "Dustwallow Marsh", 43, 3600, "H" }, -- Skin Careful, Skin Sharp
    [98197] = { "Wetlands", 22, 1750, "A" }, -- Spoils of War
    [98203] = { "The Hinterlands", 49, 5700, "H", nil, "Pick one: tiiks tattered trousers, profane ritual robes, sacrificial shackles" }, -- Witch Doctor Ti'ik
    [98205] = { "Dustwallow Marsh", 44, 3750, nil, nil, "Pick one: whelpscale necklace, bleached scale vest" }, -- Whelps are the Worst!
    [98208] = { "Wetlands", 29, 1750, "A", nil, "Bouquet of Auberdine Flowers" }, -- Bloom of the Heavens
    [98209] = { "Wetlands", 29, 1200, "A" }, -- Bloom of the Heavens
    [98215] = { "Dustwallow Marsh", 44, 3750 }, -- Dragon Scales, Post Burnt Tails
    [98216] = { "Wetlands", 31, 3150, "A", "Elite", "Pick one: prospectors signet, excavation cloak" }, -- Understanding Our Present
    [98219] = { "Stormwind City", 30, 250, "A" }, -- The Shamed Lieutenant
    [98221] = { "Wetlands", 28, 2300, "A" }, -- From the Ashes
    [98223] = { "Wetlands", 31, 1250, "A", nil, "Pick one: flamescarred spellbook, dragonmaw buckler" }, -- Old Habits
    [98230] = { "Wetlands", 29, 240, "A" }, -- This Land Was Their Land
    [98231] = { "Dustwallow Marsh", 44, 3750 }, -- Active Ingredient
    [98233] = { "Dustwallow Marsh", 42, 3450, "A", nil, "Jameson's Backup Sword" }, -- Sword in the Slime
    [98240] = { "Wetlands", 29, 1200, "A" }, -- Crimson Crate Delivery
    [98245] = { "Wetlands", 29, 2350, "A" }, -- Razormaw Needling
    [98246] = { "Wetlands", 29, 2350, "A" }, -- Trying Times
    [98247] = { "Redridge Mountains", 60, 660, "A" }, -- Shipping Label
    [98248] = { "The Barrens", 60, 660, "H" }, -- Shipping Label
    [98251] = { "Thunder Bluff", 23, 1400, "H" }, -- Never Coming Back
    [98252] = { "Ashenvale", 23, 920, "H" }, -- A Void Path
    [98282] = { "Wetlands", 22, 1750, "A", nil, "Strong Anti-Venom" }, -- Alchemical Hazards
    [98283] = { "Wetlands", 30, 3050, "A", "Elite", "Pick one: razormaw shorts, carnage trousers" }, -- Carnage
    [98284] = { "Camping", 6, 270, "H" }, -- Camping 101: Enchanting
    [98285] = { "Camping", 6, 270 }, -- Camping 101: Engineering
    [98286] = { "Camping", 6, 270, "A" }, -- Camping 101: Enchanting
    [98287] = { "Camping", 6, 270, "A" }, -- Camping 101: Engineering
    [98291] = { "Wetlands", 30, 3050, "A", "Elite" }, -- Death to the Dragonmaw
    [98293] = { "Wetlands", 30, 2450, "A", "Elite" }, -- Forced Disarmament
    [98297] = { "Wetlands", 34, 2700, "A", "Elite", "Pick one: fallen dragons scepter, trusty sword, subdued dragons fang" }, -- Stopping the Cycle
    [98298] = { "Silverpine Forest", 16, 1150, "H", nil, "Foulfur Gloves" }, -- Arugal's Folly
    [98299] = { "Silverpine Forest", 20, 1550, "H" }, -- Stop the Spread
    [98300] = { "Ironforge", 34, 2700, "A" }, -- Word to Ironforge
    [98310] = { "Wetlands", 32, 3200, "A", "Elite", "Pick one: golem war cloak, rune etched ring, giantstone medallion" }, -- Gleaning Our Future
    [98313] = { "Ironforge", 32, 0, "A" }, -- For Further Study
    [98319] = { "Dun Morogh", 8, 350, "A" }, -- Secure the Mountain
    [98321] = { "Dun Morogh", 7, 630, "A" }, -- Flintfire's Shipment
    [98322] = { "Dun Morogh", 8, 70, "A" }, -- Secure the Mountain
    [98323] = { "Dun Morogh", 8, 70, "A" }, -- Secure the Mountain
    [98325] = { "Blackrock Spire", 60, 660, "H", "Dungeon" }, -- Blood and Thunder
    [98326] = { "Dun Morogh", 9, 780, "A", nil, "Frosthowl's Footwarmers" }, -- Frosthowl
    [98340] = { "Druid", 20, 390, "H" }, -- The Great Cat Spirit
    [98341] = { "Druid", 20, 780 }, -- The Great Windborne Cat Spirit
    [98342] = { "Druid", 20, 780, "H" }, -- The Great Cat Spirit
    [98362] = { "Druid", 20, 160, "H" }, -- To Thunder Bluff
    [98372] = { nil, 60, 0, nil, nil, "Night Watchman's Torch" }, -- An Unfortunate End
    [98386] = { "Redridge Mountains", 21, 1650, "A" }, -- Alther's Mill
    [98387] = { "Redridge Mountains", 21, 1650, "A" }, -- Blackrock Blockade
    [98389] = { "Tirisfal Glades", 4, 360, "H" }, -- A Light in the Darkness
    [98391] = { "Darnassus", 10, 90, "A" }, -- The Sisterhood of Elune
    [98392] = { "Teldrassil", 12, 910, "A" }, -- Darkness in the Glade
    [98393] = { "Druid", 20, 390, "A" }, -- The Great Cat Spirit
    [98394] = { "Druid", 20, 780, "A" }, -- The Great Cat Spirit
    [98396] = { "Druid", 20, 780, "A" }, -- The Great Cat Spirit
    [98397] = { "Druid", 20, 160, "A" }, -- To Darnassus
    [98398] = { "Teldrassil", 12, 90, "A" }, -- The Oracle Tree
    [98403] = { "Teldrassil", 12, 910, "A", "Elite", "Webwood Slicer" }, -- Twisted Hatred
    [98404] = { "Druid", 20, 780 }, -- The Great Windborne Cat Spirit
    [98405] = { "Druid", 20, 780, "H" }, -- The Great Cat Spirit
    [98407] = { "Redridge Mountains", 17, 950, "A" }, -- Show of Force
    [98417] = { "Ashenvale", 28, 1700, "A" }, -- Vengeful Trail
    [98418] = { "Ashenvale", 30, 2450, "A" }, -- Shared Fury
    [98423] = { "Dun Morogh", 16, 1150, "A" }, -- The Treaty of Understanding
    [98424] = { "Mulgore", 10, 840, "H" }, -- Fizsprocket's Notes
    [98427] = { "Mulgore", 12, 1150, "H", "Elite", "loose clearcutter blade, clearcutter key" }, -- Ceasing Operations
    [98430] = { "Mulgore", 8, 700, "H" }, -- The Longwalkers
    [98435] = { "Mulgore", 10, 90, "H", nil, "Pick one: ceremonial tomahawk, dreamwatcher staff" }, -- Thunderhorn's Report
    [98447] = { "Duskwood", 27, 2200 }, -- The Valor Family
    [98459] = { "Wetlands", 21, 170, "A" }, -- A Lack of Virtue
    [98461] = { "Wetlands", 21, 170, "A" }, -- Unrequited Love
    [98462] = { "Winterspring", 60, 0, nil, nil, "Potion of Winterspring Shrouding" }, -- Shroud of the Winter Wilds
    [98463] = { "Stranglethorn Vale", 33, 270, "A" }, -- Talk of the Town
    [98471] = { "Invasion", 35, 1350, "A" }, -- Message from the Supreme Magister
    [98476] = { "Mulgore", 58, 0, "H" }, -- More Unstable Magic
    [98477] = { "Mulgore", 60, 8300, "H", "Elite" }, -- Unstable Magic
    [98512] = { "Zephras Isle", 11, 880 }, -- Al'Aketh Assassins
    [98517] = { "Shaman", 10, 420, "H" }, -- Call of Fire
    [98545] = { "Tirisfal Glades", 12, 90, "H", nil, "Pick one: tims lost rib, mug of muddled memories, misplaced shooter" }, -- Leonid's Letter
    [98574] = { "Priest", 1, 40, "A" }, -- Hallowed Memorandum
    [98575] = { "Warlock", 1, 40, "H" }, -- Tainted Tablet
    [98576] = { "Mage", 1, 40, "H" }, -- Glyphic Parchment
    [98581] = { "Shaman", 1, 40, "A" }, -- Archaic Rune
    [98601] = { "Paladin", 1, 40, "H" }, -- A Difficult Path
    [98685] = { "Dire Maul", 60, 1650, nil, "Dungeon", "Arcanum of Binding" }, -- Libram of Binding
    [98731] = { "Druid", 20, 780, "A" }, -- Blessings of the Great Cat Spirit
    [98738] = { "Druid", 20, 780 }, -- Blessings of the Great Windborne Cat Spirit
    [98739] = { "Druid", 20, 780, "H" }, -- Blessings of the Great Cat Spirit
    [98815] = { "Excavation Site: Wetlands", 28, 1150, nil, "Dungeon" }, -- Highland Hides
    [98823] = { "Excavation Site: Wetlands", 31, 3150, nil, "Dungeon" }, -- Earthen Echo
    [98824] = { "Excavation Site: Wetlands", 31, 3150, nil, "Dungeon" }, -- Prehistoric Prism
    [98830] = { "Dire Maul", 60, 6600, nil, "Dungeon" }, -- The Broken Glaive
    [98887] = { "Darkspear Islands", 39, 1500, "H", "PvP" }, -- Conflict at Darkspear Islands
    [98888] = { "Darkspear Islands", 39, 0, "H", "PvP" }, -- Conflict at Darkspear Islands
    [98889] = { "Darkspear Islands", 49, 0, "H", "PvP" }, -- Conflict at Darkspear Islands
    [98890] = { "Darkspear Islands", 49, 0, "H", "PvP" }, -- Conflict at Darkspear Islands
    [98891] = { "Darkspear Islands", 59, 6400, "H", "PvP" }, -- Conflict at Darkspear Islands
    [98893] = { "Darkspear Islands", 60, 6600, "H", "PvP" }, -- Conflict at Darkspear Islands
    [98895] = { "Darkspear Islands", 39, 1500, "A", "PvP" }, -- Darkspear Islands Clash
    [98896] = { "Darkspear Islands", 39, 0, "A", "PvP" }, -- Darkspear Islands Clash
    [98897] = { "Darkspear Islands", 49, 0, "A", "PvP" }, -- Darkspear Islands Clash
    [98898] = { "Darkspear Islands", 49, 0, nil, "PvP" }, -- Darkspear Islands Clash
    [98899] = { "Darkspear Islands", 59, 6400, "A", "PvP" }, -- Darkspear Islands Clash
    [98901] = { "Darkspear Islands", 60, 6600, "A", "PvP" }, -- Darkspear Islands Clash
    [98903] = { "Darkspear Islands", 39, 3000, "A", "PvP" }, -- The Battle for Darkspear Islands!
    [98904] = { "Darkspear Islands", 49, 4550, "A", "PvP" }, -- The Battle for Darkspear Islands!
    [98905] = { "Darkspear Islands", 60, 6600, nil, "PvP" }, -- The Battle for Darkspear Islands!
    [98906] = { "Darkspear Islands", 39, 3000, "H", "PvP" }, -- The Battle for Darkspear Islands!
    [98907] = { "Darkspear Islands", 49, 4550, "H", "PvP" }, -- The Battle for Darkspear Islands!
    [98908] = { "Darkspear Islands", 60, 6600, nil, "PvP" }, -- The Battle for Darkspear Islands!
    [98910] = { "Darkspear Islands", 39, 300, nil, nil, "Darkspear Basic Care Package" }, -- Darkspear's Basic Care Package
    [98911] = { "Darkspear Islands", 49, 460, nil, nil, "Darkspear Standard Care Package" }, -- Darkspear's Standard Care Package
    [98912] = { "Darkspear Islands", 60, 660, nil, nil, "Darkspear Advanced Care Package" }, -- Darkspear's Advanced Care Package
    [98913] = { "Darkspear Islands", 39, 300, nil, nil, "Theramore Basic Care Package" }, -- Theramore Basic Care Package
    [98914] = { "Darkspear Islands", 49, 460, nil, nil, "Theramore Standard Care Package" }, -- Theramore Standard Care Package
    [98915] = { "Darkspear Islands", 60, 660, nil, nil, "Theramore Advanced Care Package" }, -- Theramore Advanced Care Package
    [98977] = { "Lunar Festival", 60, 0, nil, nil, "Coin of Ancestry" }, -- Mossheart the Elder
    [98983] = { "Lunar Festival", 60, 0, nil, nil, "Coin of Ancestry" }, -- Frostleaf the Elder
    [99046] = { "Teldrassil", 9, 80, "A" }, -- The Lost Runner
    [99047] = { "Teldrassil", 9, 80, "A" }, -- Not Dead Yet
    [99048] = { "Durotar", 9, 80, "H" }, -- A Missing Hand
    [99049] = { "Durotar", 9, 390, "H" }, -- Threat from Below
    [99050] = { "Teldrassil", 10, 840, "A" }, -- The Great Tree Provides
    [99051] = { "Durotar", 11, 880, "H" }, -- Threat from Below
    [99052] = { "Durotar", 11, 1100, "H", "Elite", "Pick one: pristine orcish dagger, aggors refitted belt" }, -- Threat from Below
    [99053] = { "Teldrassil", 10, 840, "A", nil, "Pick one: banethil quiver, sentinels slasher" }, -- Escaping Ban'ethil
    [99073] = { "Teldrassil", 10, 90, "A" }, -- Easing Suffering
    [99079] = { "Mulgore", 9, 80, "H" }, -- Longwalker Malah
    [99080] = { "Mulgore", 11, 880, "H" }, -- Drive Them Out
    [99081] = { "Mulgore", 9, 80, "H" }, -- Grim Tidings
    [99082] = { "Mulgore", 11, 90, "H", nil, "Pick one: proud braves guard, centaur skull basher" }, -- The High Chieftain
    [99101] = { "Mulgore", 9, 80, "H" }, -- Our Ancient Enemy
    [99108] = { "Mulgore", 6, 270, "H", nil, "minor healing potion, linen bandage" }, -- Sparring Match
    [99123] = { "Durotar", 8, 700, "H", nil, "Pick one: kolkar hammer, kolkar bow" }, -- Lost in the Shadows
    [99127] = { "Elwynn Forest", 7, 480, "A" }, -- A Net Disaster
    [99128] = { "Elwynn Forest", 7, 630, "A" }, -- Slimy Menace
    [99129] = { "Elwynn Forest", 7, 70, "A" }, -- A Man About a Murloc
    [99130] = { "Elwynn Forest", 7, 630, "A", nil, "Fightin' Fish" }, -- An Enticing Offer
    [99131] = { "Elwynn Forest", 7, 70, "A" }, -- Baited for Success
    [99134] = { "Tirisfal Glades", 6, 410, "H" }, -- Discipline
    [99141] = { "Tirisfal Glades", 6, 410, "H" }, -- Patience
    [99142] = { "Tirisfal Glades", 11, 880, "H" }, -- Tomb Weed
    [99143] = { "Elwynn Forest", 7, 480, "A", nil, "Shiny Silver Coin" }, -- Bottles and Baubles
    [99144] = { "Tirisfal Glades", 7, 630, "H" }, -- Seeking Refuge
    [99145] = { "Seasonal", 1, 0, nil, nil, "A Winter Veil Gift" }, -- A Winter Veil Gift
    [99152] = { "Tirisfal Glades", 12, 910, "H" }, -- As Above, So Below
    [99153] = { "Tirisfal Glades", 12, 910, "H" }, -- The One That Got Away
    [99156] = { "Tirisfal Glades", 13, 910, "H", "Elite", "Pick one: riptears cleaver, riptears spare arm, thrice stitched flesh" }, -- Rear Guard Patrol
    [99158] = { "Dun Morogh", 8, 70, "A" }, -- Dawn in the Mountains
    [99159] = { "Dun Morogh", 8, 350, "A" }, -- Finding Warmth
    [99160] = { "Dun Morogh", 8, 530, "A" }, -- Rime's Wrath
    [99161] = { "Dun Morogh", 8, 700, "A", nil, "Avala's Binding" }, -- Rime's Wrath
    [99162] = { "Dun Morogh", 8, 700, "A" }, -- Treacherous Cold
    [99187] = { "Paladin", 58, 7750, "H", "Dungeon", "Sword of Mourning" }, -- The Reliquary of Tyr
    [99191] = { "Alterac Mountains", 60, 660, "A" }, -- A Donation of Wool
    [99192] = { "Alterac Mountains", 60, 1650, "A" }, -- A Donation of Silk
    [99193] = { "Alterac Mountains", 60, 3300, "A" }, -- A Donation of Mageweave
    [99194] = { "Alterac Mountains", 60, 6600, "A" }, -- A Donation of Runecloth
    [99195] = { "Alterac Mountains", 60, 0, "A" }, -- Additional Runecloth
    [99196] = { "Mulgore", 60, 660, "H" }, -- A Donation of Wool
    [99197] = { "Mulgore", 60, 1650, "H" }, -- A Donation of Silk
    [99198] = { "Mulgore", 60, 3300, "H" }, -- A Donation of Mageweave
    [99199] = { "Mulgore", 60, 6600, "H" }, -- A Donation of Runecloth
    [99200] = { "Mulgore", 60, 0, "H" }, -- Additional Runecloth
    [99201] = { "Orgrimmar", 60, 0, "H" }, -- Swift as the Wind
    [99202] = { "Mulgore", 60, 0, "H" }, -- Swift as the Wind
    [99203] = { "Zephras Isle", 60, 0 }, -- Swift as the Wind
    [99204] = { "Orgrimmar", 60, 0, "H" }, -- Swift as the Wind
    [99205] = { "Darnassus", 60, 0, "A" }, -- Swift as the Wind
    [99206] = { "Elwynn Forest", 60, 0, "A" }, -- Swift as the Wind
    [99207] = { "Dun Morogh", 60, 0, "A" }, -- Swift as the Wind
    [99208] = { "Tirisfal Glades", 60, 0, "H" }, -- Swift as the Wind
    [99209] = { "Dun Morogh", 60, 0, "A" }, -- Swift as the Wind
    [99210] = { "Dun Morogh", 60, 3300, "A", nil, "Pick one: swift white ram, swift brown ram, swift gray ram" }, -- An Epic Ride
    [99211] = { "Tirisfal Glades", 60, 0, "H", nil, "Pick one: ochre skeletal warhorse, green skeletal warhorse, purple skeletal horse" }, -- An Epic Ride
    [99212] = { "Dun Morogh", 60, 3300, "A", nil, "Pick one: swift green mechanostrider, swift white mechanostrider, swift yellow mechanostrider" }, -- An Epic Ride
    [99213] = { "Elwynn Forest", 60, 0, "A", nil, "Pick one: swift palomino, swift brown steed, swift white steed" }, -- An Epic Ride
    [99214] = { "Darnassus", 60, 3300, "A", nil, "Pick one: reins of the swift stormsaber, reins of the swift mistsaber, reins of the swift frostsaber" }, -- An Epic Ride
    [99215] = { "Orgrimmar", 60, 0, "H", nil, "Pick one: horn of the swift timber wolf, horn of the swift brown wolf, horn of the swift gray wolf" }, -- An Epic Ride
    [99216] = { "Zephras Isle", 60, 6600, nil, nil, "Pick one: swift empyrean galestrider, swift umber galestrider, swift stormy galestrider" }, -- An Epic Ride
    [99217] = { "Mulgore", 60, 0, "H", nil, "Pick one: great gray kodo, great brown kodo, great white kodo" }, -- An Epic Ride
    [99218] = { "Durotar", 60, 0, "H", nil, "Pick one: swift blue raptor, swift olive raptor, swift orange raptor" }, -- An Epic Ride
    [99233] = { "The Maul", 60, 660, nil, "PvP" }, -- Brawl at the Maul
    [99257] = { "Shen'dralas", 43, 3600 }, -- A Heart of Crystal
    [99258] = { "Shen'dralas", 43, 4450, nil, "Elite" }, -- Mana Mania
    [99260] = { "Zephras Isle", 10, 90, "A" }, -- Fillion's Mission
    [99267] = { nil, 60, 0, "A", nil, "Night Watchman's Torch" }, -- An Unfortunate End
    [99326] = { "Hillsbrad Foothills", 40, 0, "A", nil, "Pick one: brown horse bridle, chestnut mare bridle, pinto bridle" }, -- Your First Horse
    [99411] = { "Mulgore", 7, 630, "H" }, -- Kyle's Gone Missing!
    [99435] = { "Stormwind City", 60, 9950, "A", "Raid" }, -- The Great Masquerade
    [99670] = { "Mount Hyjal", 60, 660, nil, nil, "Jereman's Bauble" }, -- Return to Jereman
}

Data.ForeverCatalog = FOREVER_CATALOG

for qid, entry in pairs(FOREVER_CATALOG) do
    local xpVal = entry[3]
    if type(xpVal) == "number" and xpVal > 0 and not Data.QuestXPFallback[qid] then
        Data.QuestXPFallback[qid] = xpVal
    end
end

function Data.GetForeverCatalogEntry(questID)
    local numID = tonumber(questID)
    return numID and FOREVER_CATALOG[numID] or nil
end

function Data.GetForeverCatalogPayoff(questID)
    local entry = Data.GetForeverCatalogEntry(questID)
    if not entry then return nil end

    local cat = entry[1]
    local lvl = entry[2]
    local side = entry[4]
    local tag = entry[5]
    local rew = entry[6]

    local originParts = {}
    if cat and cat ~= "" then table.insert(originParts, cat) end
    if lvl and lvl > 0 then
        table.insert(originParts, tag and string.format("Lvl %d %s", lvl, tag) or string.format("Lvl %d", lvl))
    elseif tag then
        table.insert(originParts, tag)
    end
    if side == "A" then
        table.insert(originParts, "Alliance")
    elseif side == "H" then
        table.insert(originParts, "Horde")
    end

    local unlock = nil
    if (tag == "Dungeon" or tag == "Raid") and cat and cat ~= "" then
        unlock = tag .. ": " .. cat
    end

    if not rew and not unlock and #originParts == 0 then
        return nil
    end

    local origin = (#originParts > 0) and table.concat(originParts, " • ") or nil
    local payoff = {
        unlock = unlock,
        reward = rew,
        origin = origin,
        note = origin and ("WoW Forever Catalog (" .. origin .. ")") or nil,
    }
    if rew and rew ~= "" then
        payoff.summary = "Reward: " .. rew
    end
    return payoff
end

-- =========================================================================
-- 6. Runtime Dynamic Bridge to ForeverDungeonJournal (if loaded)
-- =========================================================================
function Data.SyncWithForeverDungeonJournal()
    local fdj = _G.ForeverDungeonJournal_NS or _G.ForeverDungeonJournal
    if not fdj then return end
    if fdj.QUEST_PREREQ_CHAINS then
        for targetID, steps in pairs(fdj.QUEST_PREREQ_CHAINS) do
            if type(targetID) == 'number' and type(steps) == 'table' and #steps > 0 then
                local qList = {}
                for _, s in ipairs(steps) do
                    if s.id and type(s.id) == 'number' and not s.itemStep then
                        table.insert(qList, s.id)
                    end
                end
                local hasT = false
                for _, id in ipairs(qList) do if id == targetID then hasT = true break end end
                if not hasT then table.insert(qList, targetID) end
                if #qList > 1 then
                    local cID = 5000 + targetID
                    Data.KnownChains[cID] = { quests = qList, isImportant = true }
                end
            end
        end
        if Data.BuildChainIndex then Data.BuildChainIndex() end
    end
    if fdj.FOREVER_QUEST_XP_FALLBACK then
        Data.QuestXPFallback = Data.QuestXPFallback or {}
        for qid, xpVal in pairs(fdj.FOREVER_QUEST_XP_FALLBACK) do
            if type(qid) == "number" and type(xpVal) == "number" and xpVal > 0 and not Data.QuestXPFallback[qid] then
                Data.QuestXPFallback[qid] = xpVal
            end
        end
    end
end

-- Attempt dynamic sync immediately and hook PLAYER_LOGIN
Data.SyncWithForeverDungeonJournal()
