--[[
    WorthIt / QuestWorth - Localization.lua
    Supports enUS and elGR with automatic fallback to enUS.
]]

local addonName, addon = ...
addon.L = addon.L or {}
local L = addon.L

local locale = GetLocale and GetLocale() or "enUS"

-- Default translations (enUS)
local enUS = {
    ["ADDON_LOADED"] = "|cff00ccffWorthIt|r loaded. Type |cffffcc00/worthit|r or |cffffcc00/qw|r for help.",
    ["WORTH_METER"] = "Worth Meter",
    ["WORTH_SCORE"] = "Worth Score",
    ["BREAKDOWN"] = "Score Breakdown",
    ["DIFFICULTY"] = "Difficulty",
    ["REWARD"] = "Reward Value",
    ["CHAIN"] = "Chain Value",
    ["CLASS_FIT"] = "Class Fit",
    ["DENSITY"] = "Hub Density",
    ["WEIGHTS"] = "Weights",
    ["WEIGHTS_UPDATED"] = "Weights updated: Difficulty=%.2f, Reward=%.2f, Chain=%.2f, ClassFit=%.2f, Density=%.2f (Sum: %.2f)",
    ["WEIGHTS_ERROR"] = "Invalid weights! Provide 5 numbers (e.g., /worthit weights 0.00 0.40 0.25 0.25 0.10). They will be normalized to sum to 1.0.",
    ["DEBUG_MODE_ON"] = "Debug mode: |cff00ff00ENABLED|r",
    ["DEBUG_MODE_OFF"] = "Debug mode: |cffff0000DISABLED|r",
    ["ADDON_ENABLED"] = "WorthIt is now |cff00ff00ENABLED|r.",
    ["ADDON_DISABLED"] = "WorthIt is now |cffff0000DISABLED|r.",
    ["QUEST_LOG_TAG_TOGGLED"] = "Quest Log tags: %s",
    ["TRACKER_TAG_TOGGLED"] = "Objective Tracker tags: %s",
    ["NO_QUEST_HOVERED"] = "No quest currently hovered or selected.",
    ["DEBUG_BREAKDOWN_HEADER"] = "--- WorthIt Debug Breakdown for Quest %d: [%s] ---",
    ["DEBUG_BREAKDOWN_FOOTER"] = "--------------------------------------------------",
    ["RESET_DEFAULTS"] = "Settings and weights reset to defaults.",
    ["HELP_TITLE"] = "|cff00ccffWorthIt Slash Commands:|r",
    ["HELP_TOGGLE"] = "  |cffffcc00/worthit toggle|r - Enable or disable the addon",
    ["HELP_DEBUG"] = "  |cffffcc00/worthit debug|r - Toggle debug mode / print debug for current quest",
    ["HELP_WEIGHTS"] = "  |cffffcc00/worthit weights <d> <r> <c> <f> <h>|r - Set custom weights (e.g. 0.00 0.40 0.25 0.25 0.10)",
    ["HELP_QUESTLOG"] = "  |cffffcc00/worthit questlog|r - Toggle score tags in Quest Log",
    ["HELP_TRACKER"] = "  |cffffcc00/worthit tracker|r - Toggle score tags in Objective Tracker",
    ["HELP_TEST"] = "  |cffffcc00/worthit test|r - Run diagnostic tests on all 5 scores",
    ["HELP_RESET"] = "  |cffffcc00/worthit reset|r - Reset to default weights and settings",
    ["SUITABILITY"] = "Suitability",
    ["HIGHLIGHTS"] = "Highlights",
    ["PAYOFF_HEADER"] = "Key Unlock & Payoff:",
    ["PAYOFF_UNLOCKS"] = "Unlocks:",
    ["PAYOFF_REWARD"] = "Top Reward:",
    ["PAYOFF_CHAIN"] = "Chain:",
    ["PAYOFF_NOTE"] = "Note:",
    ["PAYOFF_TYPE"] = "Type:",
    ["PAYOFF_TIP"] = "Tip / Guide:",
    ["HOVER_TITLE_HINT"] = "Hover title for Worth details & score breakdown",
    ["ITEM_QUEST_STARTER"] = "Hidden / Item Quest Starter:",
    ["ITEM_STARTS_QUEST"] = "Starts Quest:",
    ["ITEM_CLICK_TO_START"] = "Right-click in inventory to start quest!",
    ["TALK_TO_SUITABILITY"] = "Do Now (Talk to NPC)",
    ["TALK_TO_CHAIN_START"] = "Do Now (Talk to NPC • Chain Start)",
    ["TALK_TO_HIGHLIGHT"] = "Talk to NPC",
    ["SAFE_TALK_TO"] = "Safe (Talk to NPC)",
    ["HELP_OBJECTS"] = "  |cffffcc00/worthit objects|r - Toggle 3D glow, sparkles & interact icon on quest world objects",
    ["OBJECT_HIGHLIGHT_TOGGLED"] = "Quest Object Highlight (Sparkles & 3D Glow): %s",
    ["QUEST_OBJECT_HEADER"] = "QUEST OBJECT (Interact!)",
}

-- Greek translations (elGR)
local elGR = {
    ["ADDON_LOADED"] = "Το |cff00ccffWorthIt|r φορτώθηκε. Πληκτρολογήστε |cffffcc00/worthit|r ή |cffffcc00/qw|r για βοήθεια.",
    ["WORTH_METER"] = "Αξία Quest",
    ["WORTH_SCORE"] = "Σκορ Αξίας",
    ["BREAKDOWN"] = "Ανάλυση Σκορ",
    ["DIFFICULTY"] = "Δυσκολία",
    ["REWARD"] = "Ανταμοιβή",
    ["CHAIN"] = "Αλυσίδα",
    ["CLASS_FIT"] = "Ταίριασμα Κλάσης",
    ["DENSITY"] = "Πυκνότητα Hub",
    ["WEIGHTS"] = "Βάρη",
    ["WEIGHTS_UPDATED"] = "Τα βάρη ενημερώθηκαν: Δυσκολία=%.2f, Ανταμοιβή=%.2f, Αλυσίδα=%.2f, Κλάση=%.2f, Hub=%.2f (Σύνολο: %.2f)",
    ["WEIGHTS_ERROR"] = "Μη έγκυρα βάρη! Δώστε 5 αριθμούς (π.χ. /worthit weights 0.00 0.40 0.25 0.25 0.10). Θα κανονικοποιηθούν σε άθροισμα 1.0.",
    ["DEBUG_MODE_ON"] = "Debug mode: |cff00ff00ΕΝΕΡΓΟ|r",
    ["DEBUG_MODE_OFF"] = "Debug mode: |cffff0000ΑΠΕΝΕΡΓΟΠΟΙΗΜΕΝΟ|r",
    ["ADDON_ENABLED"] = "Το WorthIt είναι τώρα |cff00ff00ΕΝΕΡΓΟ|r.",
    ["ADDON_DISABLED"] = "Το WorthIt είναι τώρα |cffff0000ΑΠΕΝΕΡΓΟΠΟΙΗΜΕΝΟ|r.",
    ["QUEST_LOG_TAG_TOGGLED"] = "Εμφάνιση στο Quest Log: %s",
    ["TRACKER_TAG_TOGGLED"] = "Εμφάνιση στο Objective Tracker: %s",
    ["NO_QUEST_HOVERED"] = "Δεν υπάρχει επιλεγμένο ή hovered quest.",
    ["DEBUG_BREAKDOWN_HEADER"] = "--- WorthIt Debug Ανάλυση για το Quest %d: [%s] ---",
    ["DEBUG_BREAKDOWN_FOOTER"] = "--------------------------------------------------",
    ["RESET_DEFAULTS"] = "Επαναφορά προεπιλεγμένων ρυθμίσεων και βαρών.",
    ["HELP_TITLE"] = "|cff00ccffΕντολές WorthIt:|r",
    ["HELP_TOGGLE"] = "  |cffffcc00/worthit toggle|r - Ενεργοποίηση/απενεργοποίηση του addon",
    ["HELP_DEBUG"] = "  |cffffcc00/worthit debug|r - Εναλλαγή debug mode / εκτύπωση ανάλυσης",
    ["HELP_WEIGHTS"] = "  |cffffcc00/worthit weights <d> <r> <c> <f> <h>|r - Ορισμός βαρών (π.χ. 0.00 0.40 0.25 0.25 0.10)",
    ["HELP_QUESTLOG"] = "  |cffffcc00/worthit questlog|r - Εμφάνιση σκορ στο Quest Log",
    ["HELP_TRACKER"] = "  |cffffcc00/worthit tracker|r - Εμφάνιση σκορ στο Objective Tracker",
    ["HELP_TEST"] = "  |cffffcc00/worthit test|r - Εκτέλεση διαγνωστικών ελέγχων και στα 5 σκορ",
    ["HELP_RESET"] = "  |cffffcc00/worthit reset|r - Επαναφορά προεπιλογών",
    ["SUITABILITY"] = "Καταλληλότητα",
    ["HIGHLIGHTS"] = "Κυριότερα",
    ["PAYOFF_HEADER"] = "Ξεκλείδωμα & Ανταμοιβή:",
    ["PAYOFF_UNLOCKS"] = "Ξεκλειδώνει:",
    ["PAYOFF_REWARD"] = "Κύρια Ανταμοιβή:",
    ["PAYOFF_CHAIN"] = "Αλυσίδα:",
    ["PAYOFF_NOTE"] = "Σημείωση:",
    ["PAYOFF_TYPE"] = "Τύπος:",
    ["PAYOFF_TIP"] = "Οδηγία / Tip:",
    ["HOVER_TITLE_HINT"] = "Περάστε το ποντίκι πάνω από τον τίτλο για λεπτομέρειες & ανάλυση",
    ["ITEM_QUEST_STARTER"] = "Έναρξη Κρυφού Quest (Αντικείμενο):",
    ["ITEM_STARTS_QUEST"] = "Ξεκινάει Quest:",
    ["ITEM_CLICK_TO_START"] = "Δεξί κλικ στην τσάντα για να ξεκινήσετε!",
    ["TALK_TO_SUITABILITY"] = "Κάντε το τώρα (Μιλήστε σε NPC)",
    ["TALK_TO_CHAIN_START"] = "Κάντε το τώρα (Μιλήστε σε NPC • Αρχή Αλυσίδας)",
    ["TALK_TO_HIGHLIGHT"] = "Ομιλία σε NPC",
    ["SAFE_TALK_TO"] = "Ασφαλές (Ομιλία σε NPC)",
    ["HELP_OBJECTS"] = "  |cffffcc00/worthit objects|r - Εναλλαγή 3D λάμψης, sparkles & εικονιδίου σε αντικείμενα quest στον κόσμο",
    ["OBJECT_HIGHLIGHT_TOGGLED"] = "Επισήμανση Αντικειμένων Quest (Sparkles & 3D Glow): %s",
    ["QUEST_OBJECT_HEADER"] = "ΑΝΤΙΚΕΙΜΕΝΟ QUEST (Interact!)",
}

for k, v in pairs(enUS) do
    L[k] = (locale == "elGR" and elGR[k]) or v
end

-- Fallback metatable for any missing keys
setmetatable(L, {
    __index = function(_, key)
        return enUS[key] or key
    end
})
