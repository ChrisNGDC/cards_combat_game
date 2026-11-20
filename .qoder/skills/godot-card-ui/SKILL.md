---
name: godot-card-ui
description: Card UI, animation, tooltip, drag-and-drop, and localization patterns for the cards-combat Godot 4.7 project. Use when working on card visuals, hand/deck layout, Tweens, hover effects, tooltips, drag and drop, HP bars, status icons, scene transitions, or translated labels.
---

# Card UI patterns (cards-combat)

## Overview

All card visuals are Node2D-based (not Control), animated exclusively with Tweens. Window is 1280x720 fixed, stretch mode canvas_items — layout math uses `get_viewport_rect().size`.

## Card scene anatomy (scenes/card.tscn, scripts/cards/card.gd)

```
Card (Node2D)
├── Borde (Sprite2D)          # border; self_modulate tints by tipo
├── Front (Node2D)            # face: BackgroundImage, NameLabel(+AutoTranslate), UpgradeLabel, Icon
├── Back (Node2D)             # card back: BackgroundImage, CharacterImage
└── Area2D + CollisionShape2D # mouse input (collision mask 1)
```

- Initialize via `setup(datos: CardData, player: bool, deck_type: String = "")` — never wire data in `_ready`.
- Scales: `escala_normal` (0.3, 0.3), `escala_grande` (0.325, 0.325).
- `show_card(si)`: Front.visible = si, Back.visible = !si.
- `dar_borde()` / `quitar_borde()`: tint border red (offensive) / blue (defensive) / transparent.
- Preserve `unique_id` attributes and uid:// refs when editing .tscn; prefer editing scenes in the Godot editor.

## Hover (Area2D signals, not Control)

```gdscript
collision.mouse_entered.connect(_on_area_2d_mouse_entered)
# inside the handler:
borde.self_modulate *= 1.5
Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
apply_scale_tween(escala_grande)
```

- Reverse on mouse_exited (divide 1.5, restore cursor, scale back).
- Only when `card_front.visible`; skip the scale tween when `selected`.

## Tween idioms (project style)

```gdscript
# flight: parallel move + rotate, then chained callback
var tween: Tween = get_tree().create_tween().set_parallel(true)
carta.z_index = 100
tween.tween_property(carta, "position", destino, 1.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
tween.tween_property(carta, "rotation", 0, 1.0)
tween.chain().tween_callback(func() -> void: carta.z_index = 2)

# flip: shrink x to 0, swap face, grow back
var flip: Tween = get_tree().create_tween()
flip.tween_property(carta, "scale:x", 0.0, 0.5).set_ease(Tween.EASE_IN)
flip.tween_callback(func() -> void: carta.show_card(true))
flip.tween_property(carta, "scale:x", carta.escala_normal.x, 0.5).set_ease(Tween.EASE_OUT)
```

- Slot snap / return: TRANS_BACK + EASE_OUT (0.1s snap, 0.75s return).
- Kill competing tweens first (`return_tween.kill()` pattern in combat.gd).
- HP bars: tween TextureProgressBar `"value"` over 0.7s, TRANS_SINE EASE_IN_OUT, on `hp_changed` (scripts/combat/health_manager.gd). Labels read `bar.value` in `_process`.

## Drag & drop (physics query, NOT the Control drag API)

The project does not use `_get_drag_data` / `_can_drop_data` / `_drop_data`. Pattern in combat.gd:

1. Pick: `_input` left-press → `check_card_click()` — PhysicsPointQueryParameters2D at mouse position, `collide_with_areas = true`, `collision_mask = 1`, `intersect_point`, return `result[0].collider.get_parent()`.
2. Drag: store `card_being_dragged` + original position; `_process` sets position to `get_global_mouse_position()`; highlight the slot when the card's Rect2 intersects `player_slot_rect`.
3. Drop: left-release → `check_drop_card()` — `Rect2(card.global_position - card_size / 2, card_size).intersects(player_slot_rect)`; guards: not `fighting`, not `dealing_hand`. Swap `card_in_slot` if occupied; otherwise tween back to `anchor_pos`.
4. Draw order: `move_to_front()` while dragging; restore `z_index = 2` on drop/return.

## Tooltips (TooltipManager CanvasLayer, layer 20)

Lifecycle (card.gd):

1. `create_tooltip()` inside `setup()`: instantiate card_info_tooltip.tscn, `TooltipManager.add_child(tooltip)`, `tooltip.setup(self)`, `hide()`.
2. Show/hide via `show_tooltip_info(si)` (hover, drag start/end).
3. Follow the mouse in `_process` with screen-edge clamp (offset 20,20; flip the offset when overflowing the viewport).
4. Free on `tree_exited` → `current_tooltip.queue_free()`.

Never parent a tooltip to the card — it would inherit card scale/rotation. TooltipManager keeps tooltips above everything (layer 20). Status tooltips (status.gd) create/destroy on hover under the same layer.

## Localization (AutoTranslate child node)

- Labels that need translation carry an AutoTranslate child (scenes/auto_translate.tscn, scripts/utils/auto_translate.gd).
- Initial key = parent Label.text at `_ready`. Change the key from code:

```gdscript
card_name.get_node("AutoTranslate").set_translation(datos_carta.nombre)
# with format args:
label.get_node("AutoTranslate").set_translation("KEY", [valor])
```

- AutoTranslate re-renders on NOTIFICATION_TRANSLATION_CHANGED: `tr(key) % args`.
- Dynamic strings (counts, warnings): direct `tr("STATUS") + " (" + str(n) + ")"`.
- New keys go in resources/translations.csv (id,en,es); Godot reimports to .translation. Default locale: es.

## Status icons

combat.gd `update_visual_status()`: queue_free all children of the HFlowContainer panels, instantiate status.tscn per StatusData, `setup(status)`, add_child. Panel title shows `tr("STATUS")` + count. Rebuilt after every exchange.

## Scene transitions

Always `SceneLoader.load_scene("res://scenes/x.tscn")` — threaded ResourceLoader + loading screen, then `change_scene_to_packed`. Signals: `progress_changed`, `load_finished`. Never call `get_tree().change_scene_to_file` directly in game flow.

Deck inspection: SeeDeckButton instantiates deck_overlay.tscn, connects its `closing` signal, calls `display_deck(player.visual_deck)`; sets `viewing_deck` to block input meanwhile.

## Hand/deck layout

- Deck piles: `crear_mazo()` stacks Node2D cards with 2.5px offsets; the top 4 get fan `anchor_pos` positions.
- Hand: `repartir_mano()` deals up to `hand_size = 4` with 0.75s stagger (await timer), flight tween + flip for the player.
- Discard: played cards fly to discard positions; combat.gd does not append them to `Character.visual_discard`.