---
name: godot-4-gdscript
description: Godot 4.7 GDScript API correctness and typed style for the cards-combat project. Use when writing or reviewing GDScript, calling engine APIs (nodes, signals, tweens, resources, input, files, JSON), or whenever Godot 3 vs Godot 4 syntax is in doubt.
---

# Godot 4.7 GDScript

## Overview

This project is Godot 4.7 (GL Compatibility renderer), GDScript only. Never emit C# or Godot 3 syntax. Match the project's explicit-typing style.

## Godot 3 → 4 blockers (most common hallucinations)

| Godot 3 (wrong here) | Godot 4 (correct) |
|---|---|
| `yield(obj, "signal")` | `await obj.signal` |
| `yield(get_tree().create_timer(1), "timeout")` | `await get_tree().create_timer(1.0).timeout` |
| Tween node + `interpolate_property(...)` | `create_tween()` + `tween_property(obj, "prop", val, dur)` |
| `connect("pressed", self, "_on_pressed")` | `pressed.connect(_on_pressed)` |
| `emit_signal("x", a)` | `x.emit(a)` (legacy form still parses; prefer `.emit`) |
| `export(int) var x` | `@export var x: int` |
| `onready var n = $N` | `@onready var n: Node = $N` |
| `scene.instance()` | `scene.instantiate()` |
| `PoolStringArray` etc. | `PackedStringArray` etc. |
| `rand_range(a, b)` | `randf_range(a, b)` / `randi_range(a, b)` |
| `stepify(v, s)` | `snappedf(v, s)` |
| `KinematicBody2D` | `CharacterBody2D` |
| `tool` | `@tool` |
| `OS.window_size` | `get_window().size` |
| `Thread.start(self, "m", [args])` | `Thread.start(callable.bind(args))` |

## Typed style (project-mandated)

project.godot warns on `untyped_declaration` and `inferred_declaration`. Always:

```gdscript
var cantidad: int = 0
var cartas: Array[CardData] = []
var mazo: Dictionary = {}

func repartir_carta(mazo: Array[Node2D], mano: Array[Node2D], es_jugador: bool) -> void:
	for carta: Node2D in mazo:
		mano.append(carta)

func crear_mazo(tipo: String) -> DeckData:
	return DeckManager.create_deck(tipo)
```

- Never `:=` (inferred), never untyped `var x = ...`.
- `@export_enum("CARD_OFFENSIVE", "CARD_DEFENSIVE") var tipo: String` — string keys, not enums.
- Typed signals: `signal hp_changed(nuevo_hp: int, es_jugador: bool)`.
- Lambdas: `var efecto: Callable = func(nivel: int) -> int: return 10 + nivel * 10`.
- narrowing_conversion is off project-wide: int/float mixes are tolerated (e.g. `const VERSION: int = 2.0`).

## Signals and Callables

```gdscript
signal hp_changed(nuevo_hp: int, es_jugador: bool)

GlobalData.player.hp_changed.connect(_on_hp_updated)  # recommended form
hp_changed.emit(current_hp, is_player)
overlay.closing.connect(func() -> void: viewing_deck = false)
```

- `Signal.connect(Callable)` is the recommended API; `Object.connect("name", callable)` is also valid.
- Check `sig.is_connected(callable)` before connecting when wiring may run twice; disconnect with `sig.disconnect(callable)`.

## await

```gdscript
await get_tree().create_timer(0.75).timeout   # delay
await tween.finished                          # wait for an animation
var choice: Node2D = await cpu_choose_card()  # coroutine result
```

- A function containing `await` becomes a coroutine; callers that need its result must `await` it.
- `yield` does not exist in Godot 4.

## Resources and class_name

```gdscript
extends Resource
class_name CardData

@export var nombre: String
var efecto: Callable

func _init(datos: Dictionary) -> void:
	nombre = datos.nombre
	efecto = datos.efecto
```

- class_name only for data/logic classes (project convention); scene scripts and autoloads extend without class_name.
- `_init` with required params means `.new()` must pass them: `CardData.new(dict)`.
- Resources are RefCounted — they persist without a scene tree (Character lives in GlobalData across scenes).

## Nodes and scenes

- `@onready var slot: Sprite2D = $PlayerSlot` — typed.
- `preload("res://scenes/card.tscn")` at top of file; `instantiate()`; `add_child()`.
- `queue_free()` (deferred, safe) vs `free()` (immediate — avoid).
- Cross-scene node refs go stale: check `is_instance_valid(node)` before use (project does this for `card_in_slot`).
- `call_deferred("method")` / `set_deferred("prop", v)` when touching physics state from callbacks.
- 2D draw order: `z_index` + `move_to_front()` (this project is Node2D-based, not Control).

## Tweens

```gdscript
var tween: Tween = create_tween()  # bound to this node; killed when the node is freed
tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
tween.tween_property(card, "position", destino, 0.5)
tween.tween_callback(func() -> void: card.z_index = 2)
```

- `get_tree().create_tween()` is NOT node-bound — it keeps running after the node frees. The project uses it deliberately for HP bars and card flights.
- `set_parallel(true)` runs following tweeners together; `chain()` returns to sequential.
- Sub-properties: `tween_property(carta, "scale:x", 0.0, 0.5)` (card flip).
- Kill competing tweens first: `if return_tween and return_tween.is_running(): return_tween.kill()`.
- No AnimationPlayer in this project — Tweens only.

## Files, JSON, config

```gdscript
var file: FileAccess = FileAccess.open("user://run_history.save", FileAccess.WRITE)
file.store_string(JSON.stringify(data))

var json: JSON = JSON.new()
json.parse(file.get_as_text())
var data: Array = json.get_data()
```

- JSON numbers come back as float — compare accordingly (`data[0] is float`).
- `user://` is writable; `res://` is read-only in exported builds.
- ConfigFile for settings (see ConfigManager).

## Pitfalls

- Integer division: `5 / 2 == 2`; use `5.0 / 2` for floats.
- `Array.erase(value)` removes first match; `remove_at(index)` removes by position.
- `Dictionary.has(key)` before access; factories return null on unknown keys — check.
- `tr("KEY")` for localized text; `tr("KEY") % args` for placeholders.
- `randf_range` / `randi_range`; Godot 4 auto-seeds RNG (`randomize()` is legacy but harmless).

## When unsure about an API

Verify against Godot 4.7 docs before answering: context7 library `/websites/godotengine_en/4.7` (or `/godotengine/godot-docs`), or https://docs.godotengine.org/en/stable/. Do not guess version-specific features (4.5–4.7 additions).