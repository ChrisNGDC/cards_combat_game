# ITEMS.md — Diseño de la funcionalidad de Items

Documento de diseño y plan de implementación. **Estado: aprobado para planear, sin tocar código todavía.**

## 1. Resumen y objetivos

Agregar **items pasivos permanentes** durante la run, como una **cuarta acción de tienda** ("Item") junto a Add / Remove / Upgrade. La regla de una sola acción por ronda se mantiene: si el jugador elige Item, ve una oferta de 3 items y toma 1; la CPU espeja la acción generando su propia oferta y eligiendo al azar.

Decisiones ya acordadas con el usuario:

- **Enfoque A**: nuevo autoload `ItemManager` con el patrón de CardManager/StatusManager (Diccionarios hardcodeados + Callables), nuevo `ItemData extends Resource`, y bonus consultados en `Character`.
- **Pasivos permanentes** (estilo reliquias), no consumibles.
- **Catálogo**: vida + mejora de cartas. 6 items. `ITEM_MAX_HP` es **apilable**; el resto **únicos** (se excluyen de futuras ofertas del mismo personaje).
- **CPU**: genera su propia oferta de 3 (excluyendo sus propios únicos) y elige al azar por ahora; más adelante un algoritmo por dificultad (igual que `pick_card()`).
- **UI**: items visibles para jugador y CPU durante el combate, y también en el historial de runs.
- **Save**: incluir items en el run guardado, subir `VERSION` de 2 a 3.
- `ITEM_REGEN` cura **2 HP** por intercambio (bajado de 3).

Fuera de alcance de esta iteración (YAGNI): pasivos de combate complejos, items consumibles/activables, algoritmo de selección de la CPU por dificultad, lógica de "item inútil". El diseño deja los puntos de enganche listos para agregarlos después.

## 2. Catálogo de items

Los bonus de mejora de carta se **suman al valor base** que devuelve `CardData.actuar()` **sin tocar el nivel** de la carta (una espada nv2 con item hace 30 + 3 = 33 y todavía puede mejorarse a nv3).

| Clave | Nombre (es / en) | Efecto | Tipo | Clave de bonus |
|---|---|---|---|---|
| `ITEM_MAX_HP` | Vitalidad / Vitality | +20 vida máxima y cura 20 al tomarlo | **Apilable** | (efecto de adquisición) |
| `ITEM_REGEN` | Amuleto vital / Vital Amulet | Cura 2 HP al inicio de cada intercambio | Único | `EXCHANGE_HEAL` |
| `ITEM_SWORD_DAMAGE` | Piedra de afilar / Whetstone | Espadas +3 daño | Único | `SWORD_DAMAGE` |
| `ITEM_SHIELD_ARMOR` | Escudo reforzado / Reinforced Shield | Escudos +5 armadura | Único | `SHIELD_ARMOR` |
| `ITEM_POTION_HEAL` | Poción concentrada / Concentrated Potion | Pociones +5 curación | Único | `POTION_HEAL` |
| `ITEM_MAGIC_DAMAGE` | Grimorio antiguo / Ancient Grimoire | Magia +3 daño | Único | `MAGIC_DAMAGE` |

Balance de referencia: espada 20–40 según nivel (+3 ≈ 10%), escudo 20–40, poción 25–40, magia 15–25. `ITEM_REGEN` cura ~2 × 8 intercambios ≈ 16 HP por ronda.

**Ofertas**: `get_oferta()` devuelve como máximo 3 items del pool = apilables + únicos no poseídos por ese personaje. Cuando el personaje ya tiene los 5 únicos, la oferta solo muestra `ITEM_MAX_HP`. Las ofertas pueden tener menos de 3; la acción Item **nunca se deshabilita** porque el apilable siempre está disponible.

## 3. Modelo de datos y `ItemManager`

### 3.1 `scripts/items/item_data.gd` (nuevo)

`ItemData extends Resource`, `class_name ItemData`, con el mismo estilo de `StatusData` / `CardData`. Campos tipados:

```gdscript
extends Resource

class_name ItemData

@export var nombre: String
@export var ruta_imagen: String
@export var description: String
@export var apilable: bool
var bonos: Dictionary = {}
var efecto_adquisicion: Callable
var descripcion_valor: int = 0


func _init(datos: Dictionary) -> void:
	nombre = datos.nombre
	ruta_imagen = datos.ruta_imagen
	description = datos.description
	apilable = datos.apilable
	bonos = datos.get("bonos", {})
	efecto_adquisicion = datos.get("efecto_adquisicion", Callable())
	descripcion_valor = datos.get("descripcion_valor", 0)


func get_bono(clave: String) -> int:
	return bonos.get(clave, 0)
```

- `bonos`: Diccionario clave→int (p. ej. `{"SWORD_DAMAGE": 3}`). Vacío para `ITEM_MAX_HP`.
- `efecto_adquisicion`: Callable `func(character: Character) -> void`, solo para `ITEM_MAX_HP`. `Callable()` vacío para el resto (se chequea con `is_valid()`).
- `descripcion_valor`: número principal que se formatea en el tooltip (20 para vida, 2 para regen, 3/5 para cartas). **Cada descripción usa un único `%d`** (más el `%s` de color). Para `ITEM_MAX_HP` la curación es igual al aumento, así que un solo número basta (p. ej. "Aumenta la vida máxima en [color=%s]%d[/color] y cura esa misma cantidad.").

### 3.2 `autoload/item_manager.gd` (nuevo autoload `ItemManager`)

Diccionarios hardcodeados con el patrón exacto de CardManager. Ejemplo de dos definiciones:

```gdscript
extends Node

var max_hp: Dictionary = {
	"nombre": "ITEM_MAX_HP",
	"ruta_imagen": "res://images/items/max_hp.png",
	"description": "ITEM_MAX_HP_DESC",
	"apilable": true,
	"descripcion_valor": 20,
	"efecto_adquisicion": func(character: Character) -> void:
		character.max_hp += 20
		character.heal(20),
}
var sword_damage: Dictionary = {
	"nombre": "ITEM_SWORD_DAMAGE",
	"ruta_imagen": "res://images/items/sword_damage.png",
	"description": "ITEM_SWORD_DAMAGE_DESC",
	"apilable": false,
	"bonos": { "SWORD_DAMAGE": 3 },
	"descripcion_valor": 3,
}
# ... regen, shield_armor, potion_heal, magic_damage ...

var items_classes: Dictionary = {
	"ITEM_MAX_HP": max_hp,
	"ITEM_REGEN": regen,
	"ITEM_SWORD_DAMAGE": sword_damage,
	"ITEM_SHIELD_ARMOR": shield_armor,
	"ITEM_POTION_HEAL": potion_heal,
	"ITEM_MAGIC_DAMAGE": magic_damage,
}


func create_item(tipo: String) -> ItemData:
	if not items_classes.has(tipo):
		return null
	return ItemData.new(items_classes[tipo])


func get_oferta(personaje: Character) -> Array[ItemData]:
	var pool: Array[ItemData] = []
	for clave: String in items_classes:
		var definicion: Dictionary = items_classes[clave]
		if definicion.apilable or not personaje.has_item(definicion.nombre):
			pool.append(create_item(clave))
	pool.shuffle()
	var oferta: Array[ItemData] = []
	for i: int in range(min(3, pool.size())):
		oferta.append(pool[i])
	return oferta
```

- `create_item()` devuelve `null` para clave desconocida (patrón de fábrica existente — siempre chequear antes de usar).
- `get_oferta()` se usa **igual para jugador y CPU**; cada uno filtra contra sus propios items.
- Registrar en `project.godot` sección `[autoload]` como `ItemManager="*uid://..."` (el editor genera el `.gd.uid`; **no regenerar uids existentes**).

### 3.3 Cambios en `Character` (`scripts/actors/character.gd`)

Nuevo estado y helpers:

```gdscript
var items: Array[ItemData] = []


func add_item(item: ItemData) -> void:
	items.append(item)
	if item.efecto_adquisicion.is_valid():
		item.efecto_adquisicion.call(self)


func has_item(nombre_item: String) -> bool:
	for item: ItemData in items:
		if item.nombre == nombre_item:
			return true
	return false


func get_item_bonus(clave: String) -> int:
	var total: int = 0
	for item: ItemData in items:
		total += item.get_bono(clave)
	return total
```

- `get_item_bonus()` suma los bonus de todos los items poseídos → el **stacking de `ITEM_MAX_HP` y de cualquier bonus sale gratis** de aquí.
- `reset_round()` **no toca `items`** (los items persisten entre rondas). `reset()` **sí** limpia `items` (nueva run). Agregar `items.clear()` en `reset()`.
- `add_item()` aplica el efecto de adquisición al momento (en la tienda). `heal()` emite `hp_changed`; en la tienda no hay listener conectado, lo cual es inocuo. El combate lee `max_hp`/`current_hp` frescos al cargar ([health_manager.gd](scripts/combat/health_manager.gd) `setup_hp()`).

## 4. Flujo de tienda y espejo CPU

### 4.1 Cuarta acción `STORE_ITEM`

- `scripts/store/store_button.gd`: agregar `"STORE_ITEM"` al `@export_enum` de `mode` y `"STORE_ITEM_MSG"` al de `description`.
- `scenes/store.tscn`: nuevo nodo `Item` (Button con script StoreButton) en `Footer`, hermano de Add/Remove/Upgrade, con `mode = "STORE_ITEM"`, `description = "STORE_ITEM_MSG"` y un icono nuevo (`images/store/`). **Editar la escena en el editor de Godot** para preservar `unique_id`/uids; no regenerar.

### 4.2 Diferencia de flujo respecto a Add/Remove/Upgrade

Add/Remove/Upgrade actúan **inmediatamente** sobre la carta seleccionada al pulsar el botón. Item es en dos pasos: pulsar "Item" **muestra la oferta**, y luego el jugador **hace click en un item** para tomarlo.

En `scripts/store/store_actions.gd`:

- Nueva variable `var viewing_items: bool = false`.
- `_on_pressed("STORE_ITEM")`: genera `var oferta: Array[ItemData] = ItemManager.get_oferta(player)`, llama `shelf.mostrar_items(oferta)`, pone `viewing_items = true`. **No** finaliza la transacción. El footer sigue visible.
- Click en un item del shelf → handler `_on_item_selected(item: ItemData)`:
  ```gdscript
  func _on_item_selected(item: ItemData) -> void:
      player.add_item(item)
      var cpu_item: ItemData = cpu.pick_item()
      if cpu_item:
          cpu.add_item(cpu_item)
      finalize_transaction("STORE_ITEM")
  ```
- **Cancelación implícita**: si `viewing_items` es true y se pulsa Add/Remove/Upgrade, primero `shelf.mostrar_cartas()` y `viewing_items = false`, y luego la lógica normal de carta. Sin botón "volver" extra.
- Pulsar "Item" de nuevo mientras `viewing_items` ya es true: no-op (o regenerar oferta; se elige no-op para estabilidad).

### 4.3 Shelf de items en la tienda

El nodo `ItemShelf` de la tienda usa `scripts/store/item_shelf.gd` (que `extends ItemShelf`, la clase base de `scripts/utils/item_shelf.gd`. **No renombrar** — el nombre "ItemShelf" ya existe como shelf genérico de cartas). Se le agrega capacidad de mostrar items:

```gdscript
signal item_selected(item: ItemData)


func mostrar_items(items: Array[ItemData]) -> void:
	for child: Node in get_children():
		child.queue_free()
	selected_card_data = null
	selected_card_index = -1
	current_selected_wrapper = null
	for i: int in range(items.size()):
		_crear_wrapper_item(items[i], i)
```

- `_crear_wrapper_item(item: ItemData, index: int) -> Control`: wrapper con `TextureRect` (imagen del item) + `Label` (nombre traducido), `gui_input` conectado para emitir `item_selected(item)` al click izquierdo.
- **Hover**: el shelf emite `signal item_hovered(description: String)` al entrar el mouse a un wrapper (y `item_hovered("")` al salir). `store_actions` conecta `item_hovered` y setea `description_label.text = tr(description)` (mismo `description_label` que usan los botones de acción). Se elige señal (no callback directo) para desacoplar el shelf de la tienda.
- `store_actions` conecta `shelf.item_selected.connect(_on_item_selected)` y `shelf.item_hovered.connect(...)` en `_ready()`.
- Las cartas y los items comparten el mismo nodo shelf; `mostrar_cartas()` y `mostrar_items()` se excluyen mutuamente (cada uno limpia los hijos del otro).

### 4.4 Espejo en `GameCPU` (`scripts/actors/cpu.gd`)

```gdscript
func pick_item() -> ItemData:
	var oferta: Array[ItemData] = ItemManager.get_oferta(self)
	if oferta.is_empty():
		return null
	return oferta.pick_random()
```

- Encapsula oferta + azar en un solo método, dejando el punto exacto donde luego enchufar el algoritmo por dificultad (mismo patrón que `pick_card()` / `pick_complex_card()`).
- `add_item()` se hereda de `Character` (aplica efecto de adquisición). La CPU nunca recibe un único que ya tiene, porque `get_oferta(self)` los excluye.

## 5. Enganches en combate

Solo dos puntos, ambos simétricos jugador/CPU. **No** se toca `Matchups.MATCHUP_TABLE`, el orden de resolución, ni `CardData.actuar()`.

### 5.1 Bonus de carta en `play_card()` (`scripts/combat/combat.gd`)

En las 4 ramas que calculan `amount`, sumar el bonus del actor que juega la carta:

```gdscript
"CARD_SWORD":
	var amount: int = card.apply_effect() + actor.get_item_bonus("SWORD_DAMAGE")
	adversario.take_physical_damage(amount)
"CARD_MAGIC":
	var amount: int = card.apply_effect() + actor.get_item_bonus("MAGIC_DAMAGE")
	# ... resto igual (rebound refleja el amount ya modificado del caster) ...
"CARD_SHIELD":
	var amount: int = card.apply_effect() + actor.get_item_bonus("SHIELD_ARMOR")
	actor.add_armor(amount)
"CARD_POTION":
	var amount: int = card.apply_effect() + actor.get_item_bonus("POTION_HEAL")
	actor.heal(amount)
	actor.add_status(StatusManager.create_status("STATUS_REGENERATION"))
```

- El daño reflejado por mirror usa el `amount` ya modificado del caster — consistente (el item del caster potencia su propio magia reflejada).
- `CARD_MIRROR` y `CARD_STUN` no tienen `amount`, no se tocan.

### 5.2 Curación por intercambio en `Character.apply_status_effects()`

Se elige `Character.apply_status_effects()` (no `combat.gd`) para mantener la simetría automática y cohesionar el efecto con el personaje:

```gdscript
func apply_status_effects() -> void:
	var regen: int = get_item_bonus("EXCHANGE_HEAL")
	if regen > 0:
		heal(regen)
	for status: StatusData in status_effects:
		status.apply_effect(self)
```

- `apply_status_effects()` ya corre antes de cualquier carta, en ambos personajes, en todos los caminos de intercambio (incluido cuando solo un lado puede jugar). La curación del item ocurre antes de los statuses.

## 6. UI

### 6.1 Componente reutilizable `item_icon`

Nuevo `scenes/item_icon.tscn` + `scripts/combat/item_icon.gd`, con el mismo patrón que `scenes/status.tscn` / [status.gd](scripts/combat/status.gd):

- `Panel` con `TextureRect` (imagen del item) + `Label` de contador **×N** (visible solo si N > 1, para apilables).
- Hover → instancia `scenes/item_tooltip.tscn` en `TooltipManager`, sigue al mouse con `TooltipFollower`, se libera al salir / `tree_exited`.
- `setup(item: ItemData, cantidad: int) -> void`.

Nuevo `scenes/item_tooltip.tscn` + `scripts/combat/item_tooltip.gd`, espejo de [status_tooltip.gd](scripts/combat/status_tooltip.gd):

```gdscript
func setup(nombre: String, raw_desc: String, valor: int) -> void:
	var desc: String = tr(raw_desc) % ["#00FF00", valor]
	descripcion.text = "[font_size=18][b]%s[/b][/font_size]\n%s" % [tr(nombre), desc]
```

- El color y el formato se ajustan por item si hace falta (match on `nombre`), igual que status_tooltip.

### 6.2 Items en combate (jugador y CPU)

- `scenes/combat.tscn`: dos nuevos `FoldableContainer` `PlayerItems` y `CPUItems` bajo `CombatLogic`, espejo de `PlayerStatus`/`CPUStatus`, cada uno con un `ItemsContainer` (HFlowContainer). Título "ITEMS (N)". Posicionados junto a los paneles de status. **Editar en el editor de Godot**, preservar uids/`unique_id`.
- `scripts/combat/combat.gd`:
  - `@onready var player_items: HFlowContainer = $PlayerItems/ItemsContainer` (y cpu).
  - `@onready var player_items_panel: FoldableContainer = $PlayerItems` (y cpu) para setear el título.
  - Nueva función `update_visual_items()` que agrupa `player.items` / `cpu.items` por `nombre` (cuenta para ×N), instancia un `item_icon` por item distinto, y setea `player_items_panel.title = tr("ITEMS") + " (" + str(player.items.size()) + ")"` (ídem cpu). Se llama en `_ready()` (los items no cambian durante el combate).
  - Preload `const ITEM_ICON_SCENE: PackedScene = preload("res://scenes/item_icon.tscn")`.

### 6.3 Items en el historial

Se **extiende el overlay existente** ([deck_overlay.gd](scripts/utils/deck_overlay.gd) / `scenes/deck_overlay.tscn`) para mostrar items debajo del mazo, en vez de crear botones nuevos por entry (mantiene la UI limpia: un botón por lado que muestra "todo lo de ese jugador").

- `scenes/deck_overlay.tscn`: nueva sección `ItemsSection` (VBoxContainer con un Label "ITEMS" + un HFlowContainer `ItemsContainer`), **oculta por defecto**. Solo se muestra cuando se pasan items.
- `scripts/utils/deck_overlay.gd`:
  ```gdscript
  func display_history_deck(deck_data: Dictionary, items: Array = []) -> void:
      # ... lógica actual de cartas ...
      update_name(deck_data.name)
      shelf.mostrar_cartas(cartas)
      _mostrar_items(items)
  ```
  - `_mostrar_items(items: Array)` agrupa por nombre, instancia `item_icon` por item distinto, y oculta la sección si `items` está vacío. Los demás callers (`display_deck`, `display_deck_data`) no pasan items → sección oculta, comportamiento intacto.
- `scripts/mainMenu/history_entry.gd`:
  - Señal extendida: `signal show_deck_requested(deck_data: Dictionary, items: Array)`.
  - `_on_player_deck_button_pressed()` emite `show_deck_requested(deck_data, run_data.get("player_items", []))` (ídem cpu).
- `scripts/mainMenu/history_menu.gd`:
  - `_on_show_deck_requested(deck_data: Dictionary, items: Array)` → `overlay.display_history_deck(deck_data, items)`.
  - El filtro de validez de entry se mantiene; `player_items`/`cpu_items` son opcionales (runs viejos no los tienen, pero el bump de VERSION borra el historial viejo de todos modos).

### 6.4 Traducciones (`resources/translations.csv`)

Claves nuevas (columnas `en`, `es`):

- Nombres: `ITEM_MAX_HP`, `ITEM_REGEN`, `ITEM_SWORD_DAMAGE`, `ITEM_SHIELD_ARMOR`, `ITEM_POTION_HEAL`, `ITEM_MAGIC_DAMAGE`.
- Descripciones con formato `%d`/`%s`: `ITEM_MAX_HP_DESC`, `ITEM_REGEN_DESC`, `ITEM_SWORD_DAMAGE_DESC`, `ITEM_SHIELD_ARMOR_DESC`, `ITEM_POTION_HEAL_DESC`, `ITEM_MAGIC_DAMAGE_DESC`.
- Tienda: `STORE_ITEM` (confirmación, p. ej. "Item Taken" / "Item Obtenido"), `STORE_ITEM_MSG` (descripción de acción, p. ej. "Take an item" / "Tomar un item").
- UI: `ITEMS` (título de paneles/sección, "Items" / "Objetos").
- Actualizar `STORE_GUIDE` para mencionar la cuarta acción (opcional, recomendado).

Labels localizados usan nodo `AutoTranslate` donde aplique (títulos de paneles, confirmación de tienda). Los tooltips formatean con `tr()` en runtime.

### 6.5 Assets

- `images/items/`: 6 imágenes (max_hp, regen, sword_damage, shield_armor, potion_heal, magic_damage). El editor genera los `.import`.
- `images/store/`: icono para el botón "Item" (o reutilizar uno existente con la región de atlas adecuada).

## 7. Save e historial (`autoload/save_manager.gd`)

- Subir `const VERSION: int = 2.0` → `3.0`. **Comportamiento establecido**: un mismatch de versión borra el archivo de historial. El chequeo `data[0] is float and data[0] == VERSION` se mantiene igual (JSON devuelve floats).
- `scripts/combat/combat.gd` `show_game_over_ui()`: agregar al `run_data`:
  ```gdscript
  "player_items": items_to_save(player.items),
  "cpu_items": items_to_save(cpu.items),
  ```
- Nuevo helper `items_to_save(items: Array[ItemData]) -> Array[String]` que devuelve los `nombre` en orden (con duplicados para apilables, p. ej. `["ITEM_MAX_HP", "ITEM_MAX_HP", "ITEM_SWORD_DAMAGE"]`). Al mostrar en el historial se agrupa por nombre con ×N.
- Formato del run queda: `{date, won, player_deck{name, cards}, cpu_deck{...}, player_items[String], cpu_items[String]}`.

## 8. Plan de tests (GdUnit4 v6.2.3)

### Unit (`tests/unit/`)

- `item_manager_test.gd`:
  - `create_item()` con clave válida → ItemData con campos correctos; clave inválida → `null`.
  - `get_oferta()` excluye únicos ya poseídos por el personaje; siempre incluye el apilable; máximo 3; con los 5 únicos poseídos → solo `ITEM_MAX_HP`.
  - `get_oferta()` para CPU filtra contra los items de la CPU (independiente del jugador).
- `character_items_test.gd`:
  - `add_item()` con `ITEM_MAX_HP` → `max_hp` +20 y `current_hp` +20 (clamp); dos veces → +40 (stacking).
  - `get_item_bonus("SWORD_DAMAGE")` suma correctamente con múltiples items.
  - `has_item()` true/false.
  - `reset_round()` conserva `items`; `reset()` los limpia.
  - `apply_status_effects()` cura `EXCHANGE_HEAL` (2) antes de statuses.
- `cpu_item_test.gd`:
  - `pick_item()` nunca devuelve un único ya poseído; devuelve null si la oferta está vacía (no debería ocurrir con el apilable, pero se cubre el guard).

### Integración (`tests/integration/`)

- Acción `STORE_ITEM` completa el turno: jugador y CPU terminan con +1 item cada uno; `transaction_done` true.
- Bonus de espada aplicado en `play_card()` (daño = base + bonus del actor).
- Curación por intercambio vía item en un combate simulado.
- Save/load con VERSION 3: run con items se guarda y se carga; `player_items`/`cpu_items` presentes.

### Smoke (`tests/smoke/`)

- La suite smoke existente debe seguir pasando. Verificación headless de rigor antes de dar nada por terminado:
  - `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --add res://tests --ignoreHeadlessMode --continue`
  - `godot --headless --path . --quit-after 2` (sin errores de script).

## 9. Checklist de implementación (orden sugerido)

1. **Datos**: `scripts/items/item_data.gd` + `autoload/item_manager.gd` (6 definiciones) + registro en `project.godot`. Tests unit de fábrica y oferta.
2. **Character**: `items`, `add_item`, `has_item`, `get_item_bonus`, `items.clear()` en `reset()`, heal en `apply_status_effects()`. Tests unit.
3. **CPU**: `pick_item()`. Test unit.
4. **Combate**: bonus en `play_card()` (4 ramas). Test de integración.
5. **Tienda**: enum de StoreButton, nodo Item en `store.tscn`, `mostrar_items`/`item_selected` en el shelf, flujo `STORE_ITEM` + cancelación en `store_actions`. Test de integración.
6. **UI combate**: `item_icon` + `item_tooltip`, paneles `PlayerItems`/`CPUItems` en `combat.tscn`, `update_visual_items()`.
7. **Save**: VERSION 3, `items_to_save`, campos en `run_data`. Test de integración save/load.
8. **Historial**: sección de items en `deck_overlay`, señal extendida en `history_entry`/`history_menu`.
9. **Traducciones + assets**: claves en `translations.csv`, imágenes en `images/items/` y `images/store/`.
10. **Verificación final**: suite GdUnit4 headless + smoke + jugar una run completa tomando items en ambos lados y revisando combate e historial.

## 10. Convenciones y gotchas a respetar

- **Tipado estático total** en vars, params, returns e iteradores de loop (`for item: ItemData in ...`). Sin `:=`, sin declaraciones sin tipo (project.godot lo trata como error).
- **Claves string**, no enums: `"ITEM_*"`, bonus `"SWORD_DAMAGE"` etc. vía `@export_enum` donde aplique.
- **Identificadores mixtos es/en** deliberados (nombre, mazo, cartas, oferta, personaje). Calzar el naming local; **nunca renombrar** símbolos existentes (p. ej. la clase base `ItemShelf`).
- Definiciones hardcodeadas en el autoload con Callables — **no** .tres ni CSV de datos de items.
- `Matchups.MATCHUP_TABLE` es **solo IA** — nunca resolución de combate.
- Animación solo con `create_tween()`; sin AnimationPlayer.
- Transiciones con `SceneLoader.load_scene(...)`.
- **Preservar `.gd.uid`, referencias `uid://` y `unique_id`** en .tscn. Editar escenas en el editor de Godot; no regenerar uids.
- `reset_round()` no debe limpiar items; `reset()` sí.
- SaveManager: bump de VERSION borra historial viejo (esperado). El chequeo es `data[0] is float and data[0] == VERSION`.
- Commits que empiezan con `build` disparan el pipeline de release — **nunca** empezar commits rutinarios con `build`.
- Comentarios solo cuando expliquen algo no obvio; sin comentarios de sección/doc.

## 11. Puntos de extensión futuros (no implementar ahora)

- **Algoritmo de CPU por dificultad**: reemplazar `pick_random()` en `GameCPU.pick_item()` por scoring según dificultad, espejo de `pick_complex_card()`.
- **Pasivos de combate**: nuevos items con bonus consultados en otros puntos (p. ej. armadura inicial por ronda en `reset_round()`, daño de quemadura en `apply_status_effects()`). El patrón `get_item_bonus(clave)` ya lo soporta.
- **Más items apilables**: basta marcar `apilable: true` en la definición; el stacking y el ×N en UI salen gratis.
- **Lógica de "item inútil"**: filtrar ofertas según estado del personaje/mazo.