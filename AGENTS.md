# cards_combat_game — agent instructions

Godot 4.7 2D card-combat game (PvE, card-vs-card matchups). GDScript only — never emit C#.

## Hard rules

- Explicit static types on every var, param, return, and loop iterator. No `:=`, no untyped declarations (project.godot errors on both).
- String keys, not enums: `"CARD_*"`, `"STATUS_*"`, `"DECK_*"` via `@export_enum`.
- Mixed Spanish/English identifiers (nombre, mazo, cartas, repartir_mano) are deliberate — match local naming, never rename.
- Card/deck/status definitions are hardcoded Dictionaries with Callable effects in autoloads (CardManager, DeckManager, StatusManager) — not .tres or CSV data files.
- `Matchups.MATCHUP_TABLE` scores CPU card choices only. Combat resolution is hardcoded in scripts/combat/combat.gd — never wire the table into resolution.
- Animation is `create_tween()` only; no AnimationPlayer.
- Scene transitions go through `SceneLoader.load_scene("res://scenes/x.tscn")`.
- Localized labels use an AutoTranslate child node; keys live in resources/translations.csv (en, es).
- Preserve `.gd.uid` files, `uid://` references, and `unique_id` attributes in .tscn — never regenerate them. Prefer editing scenes in the Godot editor.
- Commit messages starting with `build` trigger the CI release pipeline (version bump + Windows/Web export + GitHub release + itch.io). `build-minor` / `build-major` control the bump. Never start routine commits with `build`.

## Details

Project skills in `.qoder/skills` carry the full knowledge:

- `cards-combat-project` — architecture, combat flow, gotchas, add-card/status/deck checklists
- `godot-4-gdscript` — Godot 4.7 API correctness and typed GDScript style
- `godot-card-ui` — Tweens, tooltips, drag & drop, localization UI

## Verification

No test suite. After script changes, run the project in Godot (headless smoke check if godot is on PATH: `godot --headless --path . --quit-after 2`) and check for script errors before claiming success.