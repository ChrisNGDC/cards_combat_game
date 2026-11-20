# Combat flow and content checklists

All line numbers refer to the state of the repo at skill creation; re-verify with grep if code has moved.

## Exchange flow (scripts/combat/combat.gd)

1. Player drags a card into PlayerSlot (drop = Rect2 intersection, `check_drop_card()` ~:169).
2. Fight button → `_on_fight_pressed()` (~:371). Guards: `fighting`, `dealing_hand`, `viewing_deck`; requires `is_instance_valid(card_in_slot)`.
3. CPU picks (`cpu_choose_card()` ~:343) → `await combat(player_card, cpu_card)` (~:220).
4. Both cards fly to discard; hands refill toward `hand_size = 4` from deck; `end_of_combat_update()` resets turn state (armor, rebound, stun expiry).
5. `check_game_over()` (~:432): any HP ≤ 0 ends the run; double KO counts as a loss.
6. Both hands empty → auto end round. Empty hand with deck remaining → refill hand.
7. End round (`_on_end_round_pressed()` ~:469): `GlobalData.rounds += 1`, `reset_round()` both characters, `SceneLoader.load_scene("res://scenes/store.tscn")`.

## Resolution order — combat() (~:220)

- Order: non-offensive resolves before offensive; both offensive → CARD_SWORD resolves last; otherwise player first.
- `apply_status_effects()` runs BEFORE any card, on both characters.
- `can_play()` gates each side (stun sets `can_play_card = false`).
- `useless_first`: mirror/shield playing first when the opponent cannot play → skipped. `useless_second`: mirror/shield playing second when the first side cannot play → skipped.
- `invalid_first` (only the FIRST card is checked):
  - potion vs offensive second card
  - mirror vs second card with `tipo_danio != "CARD_MAGICAL"`
  - magic vs CARD_SWORD second card
  - stun vs offensive second card
- `both_shield` / `both_mirror` → 1s pause, no effects.
- Both can play and first is valid: play first, then second. Only one can play: play it unless useless.

## play_card() (~:310) — match on card.nombre

| Card | Effect |
|---|---|
| CARD_SWORD | `apply_effect()` physical damage to opponent (armor absorbs, then armor resets to 0) |
| CARD_MAGIC | magical damage + STATUS_BURN on opponent; if opponent has rebound: rebound consumed, damage + burn reflect onto the CASTER, no sound |
| CARD_SHIELD | `add_armor(amount)` — absorbs the next physical damage only |
| CARD_MIRROR | `add_rebound()` — reflects one magical attack |
| CARD_POTION | heal + STATUS_REGENERATION on self |
| CARD_STUN | STATUS_STUN on opponent |

Each play awaits 0.75s; sound via `card.play_sound()` unless reflected.

## Card numbers (autoload/card_manager.gd)

- sword: `10 + nivel * 10` physical (deck max level 3)
- shield: `10 + nivel * 10` armor (max 3)
- magic: `10 + nivel * 5` magical (max 3)
- potion: `10 + nivel * 15` heal (deck max level 2)
- mirror / stun: no level (max 0), `efecto: print` placeholder

## Statuses (autoload/status_manager.gd, scripts/actors/character.gd)

- Applied each exchange before cards; stack by append — duplicates accumulate.
- STATUS_STUN: `can_play_card = false`; expires in `reset_turn()` after one blocked exchange.
- STATUS_BURN: 5 magical damage, only if `last_card_played.tipo == "CARD_OFFENSIVE"`.
- STATUS_REGENERATION: heal 5.
- `reset_turn()`: armor = 0, rebound = false, stun expiry. `reset_round()`: also clears statuses, last_card_played, and visuals.

## CPU AI (scripts/actors/cpu.gd, pick_card_logic.gd, matchups.gd)

- EASY: random. NORMAL: scores against player deck composition. HARD: scores against the player's live hand.
- `PickCardLogic.get_cards_by_power`: frequency × MATCHUP_TABLE score per counter-card, sorted descending; `pick_complex_card` walks the priority list with random fallback.
- MATCHUP_TABLE: 6×6 scores {1, 4, 5}. AI scoring only — never combat resolution.

## Add a card — checklist

1. autoload/card_manager.gd: definition Dictionary (`nombre`, `ruta_imagen`, `tipo`, `niveles {actual, max}`, `tipo_danio`, `description` key, `efecto` lambda `func(nivel: int) -> int:` or `print` placeholder) + entry in `cards_classes`.
2. scripts/combat/combat.gd `play_card()`: new match branch with the gameplay effect.
3. scripts/combat/combat.gd `combat()`: update order / `invalid_*` rules if the card interacts with existing ones.
4. scripts/cards/card.gd: preload the sound + `play_sound()` match branch (add .wav under sounds/).
5. scripts/cards/card_info_tooltip.gd: check whether per-card tooltip text needs updating.
6. scripts/actors/matchups.gd: add row AND column entries to MATCHUP_TABLE (AI scoring).
7. resources/translations.csv: NAME key + `_DESC` key, en and es columns.
8. images/cards/<name>.png (the editor generates .import).
9. Optional: add to decks in autoload/deck_manager.gd.

Verify: run a combat with the new card in both hands; check the CPU picks it sensibly on NORMAL/HARD.

## Add a status — checklist

1. autoload/status_manager.gd: Dictionary (`nombre`, `ruta_imagen`, `description`, `effect: func(character: Character) -> void:`) + entry in `statuses`.
2. Apply site: a `combat.play_card()` branch or an existing status application.
3. Expiry: per-turn → extend `Character.reset_turn()`; per-round is automatic (`reset_round()` clears all).
4. images/combat/<icon>.png; translations.csv NAME + `_DESC` (en, es).
5. Stacking is by design: duplicates accumulate. If uniqueness is wanted, guard with `character.has_status()` at the apply site.

## Add a deck — checklist

1. autoload/deck_manager.gd: Dictionary (`nombre "DECK_*"`, `ruta_imagen` character art, `vida`, `cartas` array of `{tipo, niveles}`) + entry in `decks_classes`.
2. images/characters/<name>.png; translations.csv DECK_* key (en, es).
3. Check scripts/decks/decks.gd — deck selection builds its options from DeckManager.

## Save format (autoload/save_manager.gd)

- `user://run_history.save`: JSON array `[VERSION, run, run, ...]`.
- Run = `{date, won, player_deck {name, cards [{tipo, niveles {actual, max}}]}, cpu_deck {...}}`.
- Bump VERSION when the structure changes; a mismatch deletes the file.
- Settings are separate: `user://settings.cfg` via ConfigManager.
- No mid-run saves — run state lives only in GlobalData.