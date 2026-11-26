extends GdUnitTestSuite


func before_test() -> void:
	GlobalData.reset_game()


func after_test() -> void:
	GlobalData.reset_game()


func _con_mazos() -> void:
	GlobalData.player._setup({ "deck": DeckManager.create_deck("DECK_FIGHTER") })
	GlobalData.cpu._setup({ "deck": DeckManager.create_deck("DECK_MAGE"), "difficulty": "EASY_DIFFICULTY" })


func test_main_menu_instancia_sin_errores() -> void:
	var menu: Node2D = auto_free(load("res://scenes/main_menu.tscn").instantiate())
	add_child(menu)
	assert_object(menu.get_node("MenuOptions/Play")).is_not_null()
	assert_object(menu.get_node("MenuOptions/History")).is_not_null()


func test_decks_crea_los_cuatro_mazos() -> void:
	var decks: Node2D = auto_free(load("res://scenes/decks.tscn").instantiate())
	add_child(decks)
	var lista: HBoxContainer = decks.get_node("DecksManager/MarginContainer/SelectionUI/HBoxDecks/ScrollContainer/MarginContainer/DeckList")
	assert_int(lista.get_child_count()).is_equal(4)


func test_combat_reparte_mano_inicial() -> void:
	_con_mazos()
	var combate: Node2D = auto_free(load("res://scenes/combat.tscn").instantiate())
	add_child(combate)
	await get_tree().create_timer(5.0).timeout
	assert_int(GlobalData.player.visual_hand.size()).is_equal(4)
	assert_int(GlobalData.cpu.visual_hand.size()).is_equal(4)
	assert_int(GlobalData.player.visual_deck.size()).is_equal(5)
	assert_int(GlobalData.cpu.visual_deck.size()).is_equal(4)


func test_store_muestra_el_mazo_del_jugador() -> void:
	_con_mazos()
	var tienda: Node2D = auto_free(load("res://scenes/store.tscn").instantiate())
	add_child(tienda)
	var estante: Node = tienda.get_node("CanvasLayer/MarginContainer/VBoxContainer/ScrollContainer/ItemShelf")
	assert_int(estante.get_child_count()).is_equal(9)


func test_history_menu_instancia_sin_errores() -> void:
	var menu: Control = auto_free(load("res://scenes/history_menu.tscn").instantiate())
	add_child(menu)
	assert_object(menu.get_node("ScrollContainer/HistoryList")).is_not_null()


func test_deck_overlay_muestra_cartas() -> void:
	var overlay: CanvasLayer = auto_free(load("res://scenes/deck_overlay.tscn").instantiate())
	add_child(overlay)
	overlay.display_deck_data(DeckManager.create_deck("DECK_FIGHTER").cartas)
	var estante: HFlowContainer = overlay.get_node("MarginContainer/VBoxContainer/ItemShelf")
	assert_int(estante.get_child_count()).is_equal(9)


func test_game_over_ui_traduce_resultado() -> void:
	var ui: CanvasLayer = auto_free(load("res://scenes/game_over_ui.tscn").instantiate())
	add_child(ui)
	ui.setup(true)
	var etiqueta: Label = ui.get_node("CenterContainer/VBoxContainer/ResultLabel")
	assert_str(etiqueta.text).is_equal(tr("GAMEOVER_WIN_TITLE"))


func test_game_over_ui_ready_no_aplica_resultado() -> void:
	# Regresion A3: _ready() no debe llamar setup() ni aplicar estado de victoria
	var ui: CanvasLayer = auto_free(load("res://scenes/game_over_ui.tscn").instantiate())
	add_child(ui)
	await get_tree().process_frame
	assert_str(ui.result_key).is_empty()
	assert_str(ui.description_key).is_empty()
	var etiqueta: Label = ui.get_node("CenterContainer/VBoxContainer/ResultLabel")
	assert_bool(etiqueta.has_theme_color_override("font_color")).is_false()
	ui.setup(false)
	assert_str(ui.result_key).is_equal("GAMEOVER_LOSS_TITLE")
	assert_str(etiqueta.text).is_equal(tr("GAMEOVER_LOSS_TITLE"))
	assert_bool(etiqueta.has_theme_color_override("font_color")).is_true()


func test_loading_screen_emite_ready_solo_con_tweens() -> void:
	var pantalla: CanvasLayer = auto_free(load("res://scenes/loading_screen.tscn").instantiate())
	add_child(pantalla)
	await await_signal_on(pantalla, "loading_screen_ready", [], 2000)
	assert_array(pantalla.find_children("*", "AnimationPlayer", true, false)).is_empty()


func test_scene_loader_transicion_completa_y_guarda_de_reentrada() -> void:
	SceneLoader.load_scene("res://scenes/main_menu.tscn")
	SceneLoader.load_scene("res://scenes/decks.tscn")
	assert_str(SceneLoader.scene_path).is_equal("res://scenes/main_menu.tscn")
	await await_signal_on(SceneLoader, "load_finished", [], 5000)
	await get_tree().process_frame
	await get_tree().process_frame
	var actual: Node = get_tree().current_scene
	assert_object(actual).is_not_null()
	assert_str(actual.scene_file_path).is_equal("res://scenes/main_menu.tscn")
	# La loading screen se libera sola tras su tween de salida (0.3 + 0.5 s)
	await get_tree().create_timer(1.0).timeout
	get_tree().current_scene = null
	actual.queue_free()
