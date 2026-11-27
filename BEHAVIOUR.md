# BEHAVIOUR — Comportamiento técnico del juego

Descripción técnica de cards_combat_game para desarrolladores: flujo, reglas de combate, contenido, IA, persistencia, tests y CI. El documento de diseño/ideas es [README.md](README.md); las reglas duras para contribuir están en [AGENTS.md](AGENTS.md).

Motor: **Godot 4.7.2**, solo GDScript con tipado estático explícito (warnings de tipado como error en `project.godot`). Ventana 1280x720, stretch `canvas_items`. Animación exclusivamente con `create_tween()` (sin AnimationPlayer).

---

## 1. Flujo de escenas y estado de la run

```
main_menu → decks → combat ⇄ store → … → game_over_ui → main_menu
```

- Toda transición pasa por `SceneLoader.load_scene("res://scenes/x.tscn")` (`autoload/scene_loader.gd`): carga threaded + loading screen; nunca `change_scene_to_file` directo.
- El estado de la run vive en `GlobalData` (`autoload/global_data.gd`): `rounds`, `player` y `cpu` (Resources `Character`) persisten entre escenas. **No hay guardado a mitad de run.**
- Selección de mazo y dificultad en `scripts/decks/decks.gd`; las claves String (`DECK_*`, `*_DIFFICULTY`) viajan sin traducir.
- Fin de run: `check_game_over()` en `scripts/combat/combat.gd` — cualquier HP ≤ 0 termina; el doble KO cuenta como derrota. Se instancia `game_over_ui` (que recibe `setup(won)`, nunca se auto-inicializa) y `SaveManager` guarda la run.

## 2. Modelo de datos

- `CardData`, `DeckData`, `StatusData`, `Character` son `extends Resource` con `class_name` (`scripts/cards/`, `scripts/decks/`, `scripts/actors/`).
- Las definiciones de contenido son **Diccionarios hardcoded con efectos `Callable`** dentro de los autoloads `CardManager`, `DeckManager` y `StatusManager` — no hay .tres ni CSV de datos.
- Claves String en todo: `CARD_*`, `STATUS_*`, `DECK_*`, `STORE_*`, `*_DIFFICULTY` (`@export_enum`), nunca enums de GDScript.
- Las factories (`create_card`, `create_deck`, `create_status`) devuelven `null` para claves desconocidas — comprobar siempre antes de usar.
- `CardData.actuar() -> int` invoca `efecto.call(nivel_actual)`; `upgrade()` topa en `nivel_max` y `upgradeable()` es false en el tope.

## 3. Cartas

Definiciones en `autoload/card_manager.gd`; efectos de juego en `play_card()` de `scripts/combat/combat.gd`.

| Carta | Tipo | Daño | Efecto (fórmula) | Nivel máx | Efecto en combate |
|---|---|---|---|---|---|
| `CARD_SWORD` | ofensiva | físico | `10 + nivel*10` | 3 | Daño físico (la armadura absorbe y se consume) |
| `CARD_MAGIC` | ofensiva | mágico | `10 + nivel*5` | 3 | Daño mágico (ignora armadura) + Quemadura al rival; si el rival tiene rebote, el daño y la quemadura se reflejan al caster |
| `CARD_SHIELD` | defensiva | — | `10 + nivel*10` | 3 | Armadura: absorbe el siguiente daño físico del turno |
| `CARD_POTION` | defensiva | — | `10 + nivel*15` | 2 | Cura (sin superar `max_hp`) + Regeneración propia |
| `CARD_MIRROR` | defensiva | — | 0 | 0 | Rebote: refleja un ataque mágico y se consume |
| `CARD_STUN` | defensiva | — | 0 | 0 | Aturdir al rival: no puede jugar su siguiente carta |

Espejo y Aturdir no son mejorables (nivel máx 0).

## 4. Mazos

Definiciones en `autoload/deck_manager.gd`. Todas las cartas empiezan a nivel 0.

| Mazo | Vida | Composición |
|---|---|---|
| `DECK_FIGHTER` (Luchador) | 100 | 4 espadas, 2 escudos, 2 pociones, 1 aturdir (9 cartas) |
| `DECK_MAGE` (Mago) | 100 | 4 magias, 2 espejos, 2 pociones (8) |
| `DECK_PALADIN` (Paladín) | 100 | 2 espadas, 2 magias, 2 escudos, 2 pociones (8) |
| `DECK_DEFENDER` (Tanque) | 150 | 2 espadas, 4 escudos, 2 pociones (8) |

## 5. Estados

Definiciones en `autoload/status_manager.gd`; aplicación en `Character` (`scripts/actors/character.gd`).

- Se aplican **al inicio de cada intercambio, antes que las cartas**, a ambos personajes.
- **Se apilan por append**: los duplicados acumulan y todos aplican cada intercambio (deliberado).
- `STATUS_STUN`: `can_play_card = false`; expira en `reset_turn()` tras un intercambio bloqueado.
- `STATUS_BURN`: 5 de daño mágico (`BURN_DAMAGE`), **solo si** la última carta jugada del personaje fue ofensiva.
- `STATUS_REGENERATION`: cura 5 (`REGENERATION_HEAL`) sin superar `max_hp`.
- `reset_turn()` (fin de intercambio): armadura a 0, rebote fuera, expira un stun. `reset_round()` (fin de ronda): además limpia estados, última carta y arrays visuales.

## 6. Resolución del combate

Todo en `scripts/combat/combat.gd` (`combat()` y `play_card()`), hardcoded. **`Matchups.MATCHUP_TABLE` puntúa solo la IA — nunca interviene en la resolución.**

Orden y reglas por intercambio:

1. Efectos de estado primero, en ambos personajes.
2. La carta no ofensiva resuelve antes que la ofensiva; si ambas son ofensivas, `CARD_SWORD` resuelve **última**; en otro caso, jugador primero.
3. `can_play()` bloquea al personaje aturdido.
4. Carta **inválida como primera** (solo se chequea si ambos pueden jugar; se salta y solo resuelve la segunda): poción vs ofensiva, espejo vs carta no mágica, magia vs espada, aturdir vs ofensiva.
5. Carta **inútil** (mirror/escudo sin oposición que pueda jugar): se salta.
6. Escudo vs escudo y espejo vs espejo: pausa de 1 s, ningún efecto.
7. Cada carta jugada vuela al descarte y su dueño roba una carta de reposición (si la mano queda bajo `HAND_SIZE = 4` y hay mazo).

Flujo de la ronda (`round_control.gd` lleva el label de ronda y la ayuda de counters; el botón de fin de ronda está en `combat.gd`):

- Mano de 4 cartas; el jugador arrastra una al slot y pulsa Fight (`_on_fight_pressed()`).
- Sin cartas en mano pero con mazo: se reparte mano nueva (hasta 4); ambas manos vacías: fin de ronda automático. También hay botón de finalizar ronda cuando no se puede robar.
- Fin de ronda: `GlobalData.rounds += 1`, `reset_round()` en ambos, transición a `store.tscn`.
- `Character` es un Resource con refs a nodos visuales (`visual_deck`/`visual_hand`): se limpian antes de liberar la escena; nunca mantener refs entre escenas.

## 7. IA del CPU

`scripts/actors/cpu.gd`, `pick_card_logic.gd`, `matchups.gd`.

| Dificultad | Comportamiento |
|---|---|
| `EASY_DIFFICULTY` | Carta aleatoria de la mano |
| `NORMAL_DIFFICULTY` | Puntúa contra la composición del **mazo** del jugador (calculado una vez al elegir dificultad, en `setup_difficulty`) |
| `HARD_DIFFICULTY` | Puntúa contra la **mano viva** del jugador |

- `PickCardLogic.get_cards_by_power`: frecuencia × puntuación de `MATCHUP_TABLE` (6×6, valores {1, 4, 5}) por carta de counter, orden descendente; `pick_complex_card` recorre la lista con fallback aleatorio.
- `cards_power` **acumula entre llamadas** (comportamiento existente, no "arreglar").
- En tienda, el CPU hace su propia acción en paralelo (ver §8).

## 8. Tienda

`scripts/store/store_actions.gd` + `scripts/store/item_shelf.gd` (extiende `scripts/utils/item_shelf.gd`). Una sola acción por ronda de tienda, sin monedas:

| Acción | Jugador | CPU |
|---|---|---|
| `STORE_ADD` | Añade una copia a nivel 0 de la carta elegida | Añade una copia a nivel 0 de una carta aleatoria de su mazo |
| `STORE_REMOVE` | Elimina la carta seleccionada | Elimina una aleatoria |
| `STORE_UPGRADE` | `nivel_actual + 1` de la seleccionada | Mejora una aleatoria mejorable |

- Upgrade inválido (espejo/aturdir): mensaje rojo, sin cambios y la selección se resetea (nada de selección invisible).
- Tras una acción válida: mensaje verde persistente, footer oculto y botón NextRound visible → carga `combat.tscn` vía SceneLoader.

## 9. Persistencia y configuración

- `autoload/save_manager.gd` → `user://run_history.save`: JSON `[VERSION, run, run, …]`; run = `{date, won, player_deck, cpu_deck}` con cartas `{tipo, niveles {actual, max}}`. `VERSION` se compara como float (JSON devuelve floats — deliberado). Versión distinta o JSON corrupto → borrado del fichero. **Bumpear `VERSION` si cambia la estructura.**
- `autoload/config_manager.gd` → `user://settings.cfg`: idioma (default `es`), volúmenes master/music/sfx, resolución (default 1280x720) y pantalla completa. Se aplica al arrancar.
- El historial se muestra en `history_menu.tscn` (`scripts/mainMenu/history_menu.gd`); las entradas basura se descartan al mostrar.

## 10. UI, audio y localización

- Cartas Node2D (no Control): hover por señales de Area2D, drag & drop por query física (`intersect_point`), tweens para vuelo/flip/snap. Tooltips bajo `TooltipManager` (CanvasLayer 20), nunca hijos de la carta.
- `AudioManager`: buses Master/Music/SFX; `play_sfx()` crea players que se liberan solos; slider 1.0 = 0 dB reales.
- Localización: `resources/translations.csv` (en, es) → `.translation`; los labels llevan un nodo hijo `AutoTranslate` (`scripts/utils/auto_translate.gd`) que reacciona a `NOTIFICATION_TRANSLATION_CHANGED`. Claves nuevas siempre en ambos idiomas.
- `DebugOverlay`: FPS + ajustes (resolución, idioma, volúmenes) con mapeos por `set_item_metadata`, no por índice.

## 11. Tests

Suite **GdUnit4 v6.2.3** (addon en `addons/gdUnit4/`, commiteado; solo GDScript). 103 tests en `tests/unit/`, `tests/integration/`, `tests/smoke/`.

Ejecución local headless (Windows):

```powershell
# Importar assets/clases globales primero (obligatorio tras añadir clases nuevas)
D:\Godot\Godot_v4.7.2-stable_win64.exe --headless --path . --import

# Suite completa (exit ≠ 0 si hay fallos; reportes HTML/XML en reports/)
D:\Godot\Godot_v4.7.2-stable_win64.exe --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --add res://tests --ignoreHeadlessMode --continue

# Smoke check del proyecto
D:\Godot\Godot_v4.7.2-stable_win64.exe --headless --path . --quit-after 2
```

Convenciones de los tests:

- `extends GdUnitTestSuite`, ficheros `test_<modulo>.gd`; tipado estático explícito igual que el juego (sin `:=`).
- Nodos con `auto_free(...)`; cero huérfanos (el leak detector del addon los reporta).
- `before()`/`after()`: `GlobalData.reset_game()` y backup/restore de `user://run_history.save` y `user://settings.cfg` (las rutas son const, no inyectables).
- RNG determinista con `seed()` fija donde hay aleatoriedad; audio headless usa driver Dummy → se testea estado del API, no sonido audible.
- Integración de combate: instanciar `combat.tscn` con `GlobalData` preparado y llamar `combat()`/`play_card()` directamente (más rápido y determinista que simular drag & drop). No se rediseña la resolución para hacerla testeable.
- No conmutar `TranslationServer.set_locale` para leer labels con claves crudas bajo el runner headless: la autotraducción del motor devuelve textos corruptos de forma no determinista (ver `tests/smoke/test_debug_overlay.gd`).

Regresiones históricas fijadas por la suite:

| Bug histórico | Dónde se fija |
|---|---|
| Tooltips burn/regen mostraban 2 en vez de 5 | `test_status_manager.gd` (constantes como fuente única) |
| Swap de slot con la misma carta dejaba selección fantasma | `test_combat_resolution.gd` |
| Volumen con escalado ×2.5 (slider 1.0 ≠ 0 dB) | `test_audio_manager.gd` |
| `choose_card_to_upgrade` en bucle infinito sin mejorables | `test_cpu.gd` (devuelve -1) |
| "y" español hardcodeado en la ayuda de combate con locale en | `test_translations.gd` |
| Doble init de `game_over_ui` (victory flash al perder) | `test_scenes.gd` |
| Cabeceras AUDIO/LANGUAGE intercambiadas en el overlay | `test_debug_overlay.gd` |
| Selección invisible tras upgrade inválido en tienda | `test_store_flow.gd` |

## 12. CI (GitHub Actions)

Workflow único: `.github/workflows/main.yml`, dos jobs:

- **`tests`** — en cada push/PR a `main`, **salvo pushes cuyo mensaje empiece por `docs`** (cambios de solo documentación no corren la suite): instala Godot 4.7.2 Linux, `--import` (con `|| true`, los warnings de import no fallan el job), smoke check, suite GdUnit4 y sube `reports/` como artifact. Los commits del bot con `[skip actions]` no relanzan nada.
- **`export_game`** — solo con `workflow_dispatch` o mensajes de commit que empiecen por `build` (`build-minor`/`build-major` controlan el bump): bump de versión, export Windows + Web (`firebelley/godot-export`), release en GitHub y deploy a itch.io (butler, acción pineada por versión).

Reglas críticas del export:

- Ambos presets de `export_presets.cfg` llevan `exclude_filter="addons/gdUnit4/*,tests/*"`. **No quitarlo jamás**: exportar con el addon GdUnit4 incluido crashea el exporter de Godot (signal 11; en CI se ve como "exit code null"). El plugin sigue activo en el proyecto — el job `tests` lo necesita.
- Tras cualquier invocación local de Godot en modo editor (p. ej. `--export-release`), revisar `git diff export_presets.cfg`: el re-guardado del editor puede corromper los strings multilínea de `ssh_remote_deploy`.
- **Nunca empezar commits rutinarios por `build`** — dispararía el pipeline de release completo. Usar `fix:`, `refactor:`, `test:`, `chore:`, `docs:` (este último además se salta el job `tests`).

## 13. Invariantes (no cambiar)

- Resolución de combate hardcoded en `combat.gd`; `MATCHUP_TABLE` solo para la IA.
- Diccionarios hardcoded en autoloads; claves String; identificadores mixtos es/en deliberados (nombre, mazo, repartir_mano…).
- Tweens vía `create_tween()`; sin AnimationPlayer.
- Ficheros `.gd.uid`, referencias `uid://` y atributos `unique_id` de las `.tscn` se preservan siempre; escenas se editan preferentemente en el editor de Godot.
- Gotchas deliberados: `cards_power` acumulativo, `VERSION` float, apilado de estados por append.