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
    [226]  = "The Raven Hill Tome is inside a chest in the southern mausoleum/crypt of Raven Hill Cemetery.",
    [93]   = "Lean Wolf Flanks drop from Prairie Wolves & Starving Dire Wolves in western Duskwood (around Raven Hill). Can also be bought on the Auction House.",
    [174]  = "The Bronze Tube is crafted by Engineers (skill 65) or sold in limited quantities by trade vendors in Ironforge, Orgrimmar, or Duskwood.",
    [148]  = "Abercrombie's crate is located behind his wooden shack in southern Duskwood.",
    [66]   = "Stalvan clue 1: Inside a chest in the abandoned Moonbrook schoolhouse in Westfall.",
    [67]   = "Stalvan clue 2: Inside a chest on the 2nd floor of Lion's Pride Inn in Goldshire.",
    [70]   = "Stalvan clue 3: Search the storage chest inside the canal house in Stormwind.",
    [101]  = "Target Morbent Fel and USE the Holy Water in your bags to strip his protective shield before attacking!",
    [173]  = "Rot Blossoms grow near the large corrupted tree and Defias camp in southern Duskwood.",
    [149]  = "Ghost Hair Thread is looted from weeping/wailing spirits in Raven Hill Cemetery.",
    [153]  = "Gather Ghoul Ribs and Skeleton Fingers from undead in Raven Hill, then mix them at the cemetery cauldron.",

    -- Westfall & Elwynn
    [151]  = "Handfuls of Oats are scattered on the ground around the farms in Westfall (near Saldean and Furlbrow).",
    [22]   = "Ingredients: Stringy Vulture Meat (fleshrippers), Goretusk Liver (boars), Murloc Eye (coast), Okra (Saldean's farm crates).",
    [12]   = "Goretusk Livers drop from all wild boars and goretusks in Westfall.",
    [36]   = "Billy's Lost Necklace is looted from Goldtooth, a named kobold inside the Fargodeep Mine.",
    [88]   = "Wood bundles are scattered on the ground around the timber yard in Eastvale Logging Camp.",
    [106]  = "Buy 'Special Chicken Feed' from Farmer Saldean in Westfall. Target a chicken and type /chicken repeatedly until it offers the quest.",

    -- Redridge Mountains
    [129]  = "Hilary's Necklace is inside a glinting object on the lake floor right near the wooden dock in Lakeshire.",
    [92]   = "Ingredients: Crisp Spider Meat (spiders), Tough Condor Meat (condors), Great Goretusk Snout (Westfall boars).",
    [119]  = "Bailiff's documents are inside a chest within the gnoll camp in southern Redridge.",
    [125]  = "Loot Underbelly Scales from dragon whelps flying in the mountains northeast of Lake Everstill.",

    -- Darkshore & Ashenvale
    [982]  = "Two waterlogged silver & iron chests are located inside the sunken ship ruins off the Darkshore coast. Keep an eye on your breath bar!",
    [3524] = "Click the giant Sea Creature Ribcage skeleton washed up on the shoreline of Darkshore.",
    [1007] = "Blow the horn at Kerlonian's camp to awaken him. Stay close to protect him from ambushes and wake him if he falls asleep.",
    [963]  = "Follow the glowing runes on the shore to find the ancient statue near the cliffs.",
    [654]  = "Stardust bushes grow on the shrine island in the center of the lake in southern Ashenvale.",

    -- The Barrens & Durotar
    [870]  = "Dive to the bottom of the northern pool in the Barrens and interact with the bubbling white fissure.",
    [871]  = "Swim to the bottom center of the stagnant oasis and interact with the bubbling white water fissure.",
    [872]  = "Dive to the bubbling fissure on the bottom floor of the southern oasis.",
    [3961] = "Pull control valves 1, 2, 3 inside the Venture Co building. The main console is up on the metal catwalk.",
    [881]  = "Stand on the white lion bone pile on the mountain slope north of Crossroads and blow the horn in your bags.",
    [819]  = "Plainstrider Beaks drop from Fleeting and Greater Plainstriders across central Barrens.",
    [821]  = "Zhevra Hooves drop from Zhevra Chargers and Coursers throughout the Barrens plains.",

    -- Hillsbrad & Arathi
    [555]  = "Turtle Meat drops from River Snappers in the rivers. Soothing Spices are purchased directly from any Cooking Supplies vendor.",
    [1241] = "Question Innkeeper Allison in Menethil Harbor, then travel to Stormwind to confront Dashel Stonefist.",

    -- Stranglethorn Vale
    [625]  = "Cortello's Riddle 1: The scroll is hidden under the stone bridge along the main road in Stranglethorn.",
    [626]  = "Cortello's Riddle 2: The scroll is hidden inside a cave in Swamp of Sorrows near the pool.",
    [627]  = "Cortello's Riddle 3: The treasure chest is submerged under the waterfall in the Hinterlands.",
    [185]  = "Collect Chapter pages 1-27. Pages can be traded or bought directly from other players on the Auction House.",
    [194]  = "Mistvale Giblets drop from elder mistvale gorillas in the valley south of Booty Bay.",
    [578]  = "Akiris reeds grow in large bundles along the riverbanks in northern Stranglethorn.",

    -- Tanaris & Un'Goro
    [2605] = "Dew Glands drop from Wasps and Scorpids throughout the Tanaris desert dunes.",
    [3844] = "Defeat primal oozes in Felwood / Un'Goro, then target the remains and USE the Empty Canteen in your bags.",
    [3984] = "Use the Golden Flame near Fire Plume Ridge in Un'Goro to strip Blazerunner's elemental invulnerability.",
}

-- 2. Title-based lookup (case-insensitive & stripped of prefixes)
Data.QuestTipsByTitle = {
    -- Duskwood
    ["the valor family"]                  = "The Raven Hill Tome is inside a chest in the southern mausoleum/crypt of Raven Hill Cemetery.",
    ["seasoned wolf kabobs"]              = "Lean Wolf Flanks drop from Prairie Wolves & Starving Dire Wolves in western Duskwood (around Raven Hill). Can also be bought on AH.",
    ["look to the stars"]                 = "The Bronze Tube is crafted by Engineers (skill 65) or sold in limited quantities by trade vendors in Ironforge, Orgrimmar, or Duskwood.",
    ["the hermit"]                        = "Abercrombie's crate is located behind his wooden shack in southern Duskwood.",
    ["the legend of stalvan"]             = "Clue 1: Moonbrook schoolhouse chest. Clue 2: Goldshire Lion's Pride Inn (2nd floor). Clue 3: Stormwind Canal house.",
    ["morbent fel"]                       = "Target Morbent Fel and USE the Holy Water in your bags to strip his shield before attacking!",
    ["rot blossom"]                       = "Rot Blossoms grow near the large corrupted tree and Defias camp in southern Duskwood.",
    ["the totem of infliction"]           = "Gather Ghoul Ribs and Skeleton Fingers from undead in Raven Hill, then mix them at the cemetery cauldron.",
    ["a recipe for death"]                = "Collect reagents from spiders and ghouls, then interact with the Cauldron in Raven Hill cemetery.",
    ["worgen in the woods"]               = "Nightbane Worgens prowl in and around the Roland's Doom mine in eastern Duskwood.",

    -- Westfall & Elwynn
    ["poor old blanchy"]                  = "Handfuls of Oats are scattered on the ground around the farms in Westfall (near Saldean and Furlbrow).",
    ["westfall stew"]                     = "Stringy Vulture Meat (fleshrippers), Goretusk Liver (boars), Murloc Eye (coast), Okra (Saldean's farm crates).",
    ["goretusk liver pie"]                = "Goretusk Livers drop from all wild boars and goretusks across Westfall.",
    ["cluck!"]                            = "Buy 'Special Chicken Feed' from Farmer Saldean in Westfall. Target a chicken and /chicken repeatedly until it offers the quest.",
    ["the lost necklace"]                 = "Billy's Necklace drops from Goldtooth, a named kobold inside the Fargodeep Mine.",
    ["a bundle of wood"]                  = "Wood bundles are scattered on the ground around the timber yard in Eastvale Logging Camp.",
    ["gold dust exchange"]                = "Gold Dust drops from all kobolds inside the Elwynn mines (Fargodeep & Jasperlode).",

    -- Redridge
    ["hilary's necklace"]                 = "Hilary's Necklace is inside a glinting object on the lake floor right near the wooden dock in Lakeshire.",
    ["redridge goulash"]                  = "Crisp Spider Meat (spiders), Tough Condor Meat (condors), Great Goretusk Snout (Westfall boars).",
    ["solomon's law"]                     = "Bailiff's documents are inside a chest within the gnoll camp in southern Redridge.",
    ["underbelly scales"]                 = "Loot Underbelly Scales from dragon whelps flying in the mountains northeast of Lake Everstill.",

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
    ["the green hills of stranglethorn"]  = "Collect Chapter pages 1-27. Pages can be traded or bought directly from other players on the Auction House.",
    ["cortello's riddle"]                 = "Step 1: Under bridge in STV. Step 2: Swamp of Sorrows cave. Step 3: Hinterlands waterfall.",
    ["scaring shaky"]                     = "Mistvale Giblets drop from elder mistvale gorillas in the valley south of Booty Bay.",
    ["akiris by the bundle"]              = "Akiris reeds grow in large bundles along the riverbanks in northern Stranglethorn.",

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
    local targetID = tonumber(questID) or questID
    local cleanTitle = CleanKey(questTitle)

    -- If title not provided, attempt to look it up from quest log or basic info
    if (not cleanTitle or cleanTitle == "") and targetID and targetID > 0 then
        local basic = addon.Utils and addon.Utils.GetQuestBasicInfo and addon.Utils.GetQuestBasicInfo(targetID)
        if basic and basic.title then
            cleanTitle = CleanKey(basic.title)
        end
    end

    -- 1. Exact questID lookup
    if targetID and Data.QuestTips[targetID] then
        return Data.QuestTips[targetID]
    end

    -- 2. Exact Title lookup
    if cleanTitle and cleanTitle ~= "" and Data.QuestTipsByTitle[cleanTitle] then
        return Data.QuestTipsByTitle[cleanTitle]
    end

    -- Flexible Title lookup (without 'the ' prefix)
    if cleanTitle and cleanTitle ~= "" then
        local noThe = string.gsub(cleanTitle, "^the%s+", "")
        if Data.QuestTipsByTitle[noThe] then
            return Data.QuestTipsByTitle[noThe]
        end
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
