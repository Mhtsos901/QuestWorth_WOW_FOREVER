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
    ["WEIGHTS_ERROR"] = "Invalid weights! Provide 5 numbers (e.g., /worthit weights 0.00 0.40 0.15 0.30 0.15). They will be normalized to sum to 1.0.",
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
    ["HELP_WEIGHTS"] = "  |cffffcc00/worthit weights <d> <r> <c> <f> <h>|r - Set custom weights (e.g. 0.00 0.40 0.15 0.30 0.15)",
    ["HELP_QUESTLOG"] = "  |cffffcc00/worthit questlog|r - Toggle score tags in Quest Log",
    ["HELP_TRACKER"] = "  |cffffcc00/worthit tracker|r - Toggle score tags in Objective Tracker",
    ["HELP_TEST"] = "  |cffffcc00/worthit test|r - Run diagnostic tests on all 5 scores",
    ["HELP_RESET"] = "  |cffffcc00/worthit reset|r - Reset to default weights and settings",
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
    ["WEIGHTS_ERROR"] = "Μη έγκυρα βάρη! Δώστε 5 αριθμούς (π.χ. /worthit weights 0.00 0.40 0.15 0.30 0.15). Θα κανονικοποιηθούν σε άθροισμα 1.0.",
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
    ["HELP_WEIGHTS"] = "  |cffffcc00/worthit weights <d> <r> <c> <f> <h>|r - Ορισμός βαρών (π.χ. 0.00 0.40 0.15 0.30 0.15)",
    ["HELP_QUESTLOG"] = "  |cffffcc00/worthit questlog|r - Εμφάνιση σκορ στο Quest Log",
    ["HELP_TRACKER"] = "  |cffffcc00/worthit tracker|r - Εμφάνιση σκορ στο Objective Tracker",
    ["HELP_TEST"] = "  |cffffcc00/worthit test|r - Εκτέλεση διαγνωστικών ελέγχων και στα 5 σκορ",
    ["HELP_RESET"] = "  |cffffcc00/worthit reset|r - Επαναφορά προεπιλογών",
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
