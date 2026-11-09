# WorthIt (QuestWorth) - WoW Quest Worth Meter (v2.0.0)

**WorthIt** is an advanced World of Warcraft addon engineered specifically for **WoW Forever / Classic Plus** (Interface 16001, modern 11.x client engine with 2004 Classic Level 60 content, `AllowLoadGameType: Camelot`).

It computes a **real-time 5-Factor Weighted Worth Score (0–100%)** for each quest, showing players dynamically whether a quest is worth picking up and doing **right now** based on difficulty, rewards, quest chain progression, class itemization fit, and hub density.

---

## 🛡️ WoW Forever Notes

WoW Forever introduces major systemic and itemization overhauls compared to standard Classic Era:
- **Unified Hit & Hard Caps**: Hit is unified across melee, ranged, and spells. Hard cap is 8% for raid bosses and 5% for same-level mobs. Overcapping Hit diminishes its value by 90%.
- **Expertise System**: Expertise rating reduces boss dodge chance (6.5% hard cap). Like Hit, gear overcapping Expertise is diminished by 90%.
- **Weapon Proficiencies**:
  - **Rogues** can learn One-Handed Axes.
  - **Druids** can learn Polearms.
  - **Paladins** use One-Handed and Two-Handed Axes, Swords, Maces, and Polearms (no Daggers, no Staves).
  - **Hunters** use Staves, Polearms, Swords, Axes, Bows, Crossbows, and Guns.
- **Caster Weapons with Spell Power**: Caster weapons carry inherent Spell Power, making weapon upgrades directly feed spell damage and healing.
- **Class Mechanics**:
  - **Enhancement Shamans**: *Mental Quickness* converts Intellect to Attack Power and Spell Damage.
  - **Feral Druids**: Shapeshift forms scale directly with base weapon DPS in addition to Attack Power.
  - **Warrior Rage**: Critical strikes directly fuel rage generation; unified Hit ensures off-hand hits land reliably.
- **Client Directive**: Uses `## AllowLoadGameType: Camelot` in `QuestWorth.toc` for seamless loading on Forever client builds.

---

## 📊 The 5-Factor "Worth Meter" Formula

$$\text{Worth} = (D \cdot w_D) + (R \cdot w_R) + (C \cdot w_C) + (F \cdot w_F) + (H \cdot w_H)$$

- **Default Leveling Weights**:
  - $w_D = 0.00$ (**Difficulty** - Decoupled Danger Skull `💀` mode)
  - $w_R = 0.40$ (**Reward Value**)
  - $w_C = 0.30$ (**Quest Chain Value**)
  - $w_F = 0.15$ (**Class Fit**)
  - $w_H = 0.15$ (**Hub Density & Clustering**)
- **Decoupled Danger Skull Indicator**: Hard/Dangerous quests (Orange $\ge +3$ levels, Red $\ge +5$ levels, Elite, or Dungeon) display a danger skull icon `💀` next to their badge without dragging down the pure value percentage score.
- **Endgame Weights (Level 60)**: Automatically adapts to Gold & Economy priority:
  - $w_D = 0.00, \ w_R = 0.50, \ w_C = 0.25, \ w_F = 0.15, \ w_H = 0.10$.
- **Dynamic Weight Redistribution**: Quests with no equipment or item rewards automatically redistribute their Class Fit weight ($w_F$) proportionally across the other active factors.
- **Viability Damping**: Red/impossible quests and trivial Gray quests are intelligently capped when custom difficulty weight is configured.

---

### 1. Difficulty ($D$)
- **Melee-Aware Level Curve**: Melee classes (Rogue, Warrior, Paladin, Feral Druid, Enhancement Shaman) evaluate mob glancing/dodge/miss brackets.
- **Classic Dynamic Green Range**: Seamlessly scales from delta $-3$ to $-greenRange$, returning $0.00$ only for true gray trivial quests.
- **Elite & Dungeon Handling**: Unsoloable high-level Elites and 5-man Dungeons apply realistic solo overhead penalties without double-penalizing level deltas.

### 2. Reward Value ($R$)
- **Mob Kill XP Benchmark**: Scales against expected mob XP $((playerLevel \cdot 5) + 45)$. Top quests equal ~8–9 mob kills ($mobXP \times 8.5$ target benchmark).
- **Unaccepted Quest Offer Valuation**: Accurately fetches XP directly from dialog offer rewards before accepting.
- **Vendor Gold Valuation**: Evaluates highest choice vendor price and fixed reward values (vital for mount savings).

### 3. Quest Chain Value ($C$)
- **Progressive Chain Curve**: Evaluates chain length, current step, and finale status:
  $$\text{Score} = \text{isCap} \ ? \ 1.00 : \left(0.40 + 0.50 \cdot \frac{\text{step}}{\text{totalSteps}}\right)$$
- **Standalone Baseline**: Standalone quests with no follow-up receive a clean $0.10$ baseline.
- **Class & Profession Quests**: Automatically scored at $1.00$.

### 4. Class Fit ($F$)
- **Forever Stat Weights**: Fine-tuned per class and talent specialization.
- **Cap-Aware Diminishing Returns**: Hit above 8% and Expertise above 6.5% diminish in value.
- **Conflicting Stat Penalty**: Items with conflicting primary stats (e.g. Intellect on Rogue) are penalized and cannot qualify for upgrade bonuses.
- **Bag Upgrade Analysis**: Compares rewarded containers against currently equipped bag slots.
- **Weapon DPS & Rogue MH Daggers**: Dagger assassination/subtlety builds require main-hand daggers.

### 5. Hub Density & Clustering ($H$)
- **Zone Clustering Synergies**:
  - 1 quest in a zone: $0.35$ (isolated travel penalty).
  - 2 quests: $0.65$.
  - 3 quests: $0.85$.
  - 4+ quests: $1.00$ (dense hub synergy).

### 🗺️ Zone Header Worth %
Geographical Zone Headers in the Quest Log (e.g. `Westfall`, `Loch Modan`, `Redridge Mountains`) dynamically calculate a composite zone score:
$$\text{Zone Worth} = (0.60 \cdot \text{avgWorth}) + (0.40 \cdot \text{maxWorth})$$
- Displays a clean `[XX%]` badge next to each zone name.
- Persistent zone-to-quest tracking preserves accurate cluster counts and zone scores even when headers are collapsed (`[+]`) in the Quest Log.
- Allows players to instantly see if a zone is worth traveling to or has been depleted/outleveled.

---

## 🎨 Color Coding

Continuous, smooth chromatic gradient:
- **0%**: Crimson Red (`#ff2020`)
- **30%**: Vivid Orange (`#ff7a1a`)
- **50%**: Bright Yellow (`#ffe600`)
- **70%**: Lime Green (`#a6ff00`)
- **85%**: Vibrant Green (`#38ff1a`)
- **100%**: Radiant Emerald Green (`#1aff4d`)
- **Completed / Turn-In**: Bright Green **`[OK]`** badge.

---

## ⌨️ Slash Commands

- `/worthit` or `/qw` - Open configuration panel
- `/worthit test` - Run diagnostic simulator on all 5 scoring criteria
- `/worthit weights <d> <r> <c> <f> <h>` - Configure custom weights (e.g. `0.00 0.40 0.30 0.15 0.15`)
- `/worthit questlog` - Toggle Worth % badges in Quest Log and Objective Tracker
- `/worthit debug` - Toggle debug mode or print breakdown for hovered quest
- `/worthit reset` - Reset weights and settings to default

---

## 📜 Changelog

### v2.0.0 (November 2026) - The WoW Forever Engine Overhaul
- **Engine & Architecture**:
  - Full support for WoW Forever client engine (Interface 16001, `AllowLoadGameType: Camelot`).
  - Added Dynamic Weight Redistribution for quests without item rewards.
  - Added Viability Damping against Red and trivial Gray quests.
  - Eviction-guarded Engine cache (`MAX_CACHE_SIZE = 500`).
  - Hoisted `_approxEq` floating-point evaluator for accurate level 60 weight transitions.
- **Scores & Itemization**:
  - Implemented WoW Forever weapon proficiencies (Rogue 1H Axes, Druid Polearms, Paladin Axes).
  - Implemented unified Hit and Expertise rating evaluation with cap-aware diminishing returns.
  - Fixed Elite detection bug in `Core/Utils.lua` (`tagID 1` is Group, not Elite).
  - Fixed unaccepted quest XP retrieval for offer dialogs in `Scores/Reward.lua`.
  - Replaced hardcoded deep-green cutoffs with dynamic Classic `greenRange` in `Scores/Difficulty.lua`.
  - Normalized reward mob kills to 8–9 mob baseline ($mobXP \times 8.5$).
  - Set standalone quest baseline to 0.10 in `Scores/Chain.lua`.
- **UI & Performance**:
  - Throttled `UpdateQuestLog` and `UpdateObjectiveTracker` to max 10 Hz debounce.
  - Deferred async `LayoutContents` and `Update` hooks via `C_Timer.After` to prevent UI thread recursion.
  - Added session memoization for item inspection (`addon.SafeGetItemInfo`) and equipped gear stats (`GetPlayerEquippedHitAndExpertise`).
  - Added 200-bucket hex color cache (`_hexCache`) eliminating string formatting garbage allocations.
  - Hardened fuzzy title matching in tracker blocks (`#title >= 10`).

---

## 📦 Installation

1. Copy the `QuestWorth` folder to:
   `World of Warcraft\_forever_\Interface\AddOns\QuestWorth`
2. Ensure `QuestWorth.toc` is located directly in the addon directory.
3. In-game, type `/reload` or log in.
