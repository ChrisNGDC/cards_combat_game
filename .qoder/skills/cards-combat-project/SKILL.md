---
name: cards-combat-project
description: Project knowledge for cards_combat_game, a Godot 4.7 GDScript 2D card battler (PvE card-vs-card). Use when reading, modifying, or extending anything in this repo — combat, cards, decks, statuses, autoload managers, store, saves, scenes, UI — or when planning changes that touch game logic.
---

# cards-combat-project

## Overview

PvE card battler: player and CPU pick decks, play cards head-to-head each exchange; a round ends when both hands are exhausted, then a store round (one action: add, remove, or upgrade a card). Repeat until one side's HP reaches 0. Runs target 10–15 minutes.

Content: 6 cards (sword, shield, magic, mirror, potion, stun), 4 decks (fighter, mage, paladin, defender), 3 statuses (stun, burn, regeneration), 3 CPU difficulties.

## Layout

```
autoload/    10 singleton managers (+ tooltip_layer.tscn, debug_overlay.tscn)
scenes/      all .tscn, flat
scripts/     actors/ cards/ combat/ decks/ mainMenu/ store/ utils/
resources/   themes, LabelSettings, translations.csv (+ compiled .translation)
images/ fonts/ music/ sounds/
```

## Autoloads (registered by uid:// in project.godot)

| Singleton | Role |
|---|---|
| CardManager | card definition Dictionaries + `create_card(tipo, niveles)` |
| DeckManager | deck definitions + `create_deck(tipo)` |
| StatusManager | status definitions + `create_status(tipo)` |
| GlobalData | shared run state: `rounds`, `player: GamePlayer`, `cpu: GameCPU` (created in `_init`, persist across scenes) |
| SaveManager | JSON run history at `user://run_history.save` |
| ConfigManager | `user://settings.cfg` (locale, audio), applied on load |
| AudioManager | Master/Music/SFX buses; `play_sfx()` spawns self-freeing players |
| SceneLoader | threaded scene loads + loading screen; signals `progress_changed`, `load_finished` |
| TooltipManager | scriptless CanvasLayer, layer=20; parent for all tooltips |
| DebugOverlay | FPS + settings overlay |

Communication style: direct singleton calls + GlobalData shared state. Signals are the exception: `hp_changed` (Character → health_manager), SceneLoader progress, deck overlay `closing`.

## Data model

- CardData, DeckData, StatusData, Character are `extends Resource` + `class_name`. Scene scripts and autoloads have no class_name.
- Definitions are hardcoded Dictionaries inside managers, with Callable effects — no .tres/CSV card data.
- `CardData.new(datos: Dictionary)` — `_init` requires the dict. `efecto: Callable` is invoked as `efecto.call(nivel_actual)` through `actuar() -> int`. Mirror/stun use `print` as placeholder effect (deliberate).
- Factories return null for unknown keys — check before use.
- String keys everywhere: `"CARD_*"`, `"STATUS_*"`, `"DECK_*"`, `"*_DIFFICULTY"` (`@export_enum`), never GDScript enums.

## Combat summary

Resolution lives in scripts/combat/combat.gd, `combat()` and `play_card()`:

1. Status effects apply first, to both characters.
2. Defensive card resolves before offensive; if both offensive, CARD_SWORD resolves last; otherwise player first.
3. Invalid first-card combos are skipped (potion vs offensive, mirror vs non-magical, magic vs sword, stun vs offensive).
4. Shield vs shield and mirror vs mirror: nothing happens.
5. `play_card()` matches on `card.nombre`: damage / armor / rebound / heal / stun. Magic reflects off rebound onto the caster.

**Matchups.MATCHUP_TABLE is CPU-AI scoring only. Never use it for combat resolution.**

Full flow, numbers, and content checklists: read `references/combat-and-content.md` before changing combat or adding content.

## Conventions

- Explicit static types everywhere — vars, params, returns, loop iterators (`for card: CardData in ...`). No `:=`, no untyped declarations (project.godot errors on both; narrowing_conversion deliberately off).
- snake_case files/vars/funcs; UPPER_SNAKE consts. Mixed Spanish/English identifiers are deliberate (nombre, mazo, cartas, repartir_mano, si, es_jugador). Match local naming; never rename.
- `@onready` typed node refs; `preload` as UPPER_SNAKE `const` at top of file. Comments only when they explain something not obvious from reading the code for a few seconds; no section/doc comments.
- Characters initialize via `_setup(params: Dictionary)`; instantiated scenes via `setup(...)`.
- Sequencing with `await get_tree().create_timer(x).timeout`; lambdas in dicts and tween callbacks.
- `self.` prefix is common; legacy `emit_signal("hp_changed", ...)` exists — prefer `hp_changed.emit(...)` in new code.

## Gotchas — do not "fix" these

1. MATCHUP_TABLE is AI-only — never use it for combat resolution.
2. combat.tscn's combat-logic node is named "CombatLogic" (renamed from "CardManager", which collided with the autoload name) — it is NOT the CardManager autoload.
3. Character is a Resource in GlobalData holding Node2D refs (visual_deck/hand). Call `reset_round()` / `clear_visuals()` before the combat scene frees; never keep node refs across scene changes. combat.gd manipulates visual_deck/visual_hand directly — no helper API.
4. PickCardLogic.cards_power accumulates across calls — existing behavior.
5. SaveManager: `const VERSION: int = 2.0`; JSON returns floats, check is `data[0] is float and data[0] == VERSION`. Version mismatch deletes the save. Bump VERSION when changing save structure.
6. Statuses stack by plain append — duplicates accumulate and all apply each exchange.
7. Every .gd has a paired .gd.uid; .tscn nodes carry `unique_id` (4.7). Preserve all uid:// references; never regenerate.
8. Commit messages starting with `build` trigger the CI release pipeline (version bump + Windows/Web export + GitHub release + itch.io deploy). `build-minor` / `build-major` control the bump. Never start routine commits with `build`.
9. Both export presets carry `exclude_filter="addons/gdUnit4/*,tests/*"` — exporting with GdUnit4 included crashes the Godot exporter (signal 11; CI shows "exit code null"). Never remove these filters. Running Godot in editor mode (e.g. `--export-release`) re-saves export_presets.cfg and can corrupt the multiline `ssh_remote_deploy` strings — check `git diff export_presets.cfg` after any local export attempt.

## Verification

GdUnit4 v6.2.3 suite in `tests/` (unit, integration, smoke). Run it headless: `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --add res://tests --ignoreHeadlessMode --continue` (exit ≠ 0 on failure; reports in `reports/`). Also run the smoke check `godot --headless --path . --quit-after 2` and watch for script errors. CI job `tests` runs on every push/PR to main, independent of the `build` release gate. Engine API questions: use the godot-4-gdscript skill. UI/animation: use godot-card-ui.