extends GdUnitTestSuite


func before_test() -> void:
	GlobalData.reset_game()
	GlobalData.player._setup({ "deck": DeckManager.create_deck("DECK_FIGHTER") })
	GlobalData.cpu._setup({ "deck": DeckManager.create_deck("DECK_MAGE"), "difficulty": "EASY_DIFFICULTY" })


func after_test() -> void:
	GlobalData.reset_game()


func _tienda() -> Node2D:
	var tienda: Node2D = auto_free(load("res://scenes/store.tscn").instantiate())
	add_child(tienda)
	return tienda


func _acciones(tienda: Node2D) -> Node:
	return tienda.get_node("CanvasLayer/MarginContainer/VBoxContainer")


func _indice_de(nombre: String) -> int:
	for i: int in range(GlobalData.player.deck.cartas.size()):
		if GlobalData.player.deck.cartas[i].nombre == nombre:
			return i
	return -1


func _seleccionar(estante: Node, indice: int) -> void:
	# Los wrappers reconstruidos conviven con los queue_free hasta fin de frame
	var wrappers: Array[Node] = []
	for hijo: Node in estante.get_children():
		if not hijo.is_queued_for_deletion():
			wrappers.append(hijo)
	var wrapper: Control = wrappers[indice]
	var carta_nodo: Node2D = wrapper.get_child(1)
	estante.call("seleccionar_carta", wrapper, carta_nodo, GlobalData.player.deck.cartas[indice], indice)


func test_store_add_copia_a_nivel_cero_y_cpu_gana_carta() -> void:
	var acciones: Node = _acciones(_tienda())
	var estante: Node = acciones.get("shelf")
	var indice: int = _indice_de("CARD_SWORD")
	_seleccionar(estante, indice)
	acciones.call("_on_pressed", "STORE_ADD")
	var cartas: Array[CardData] = GlobalData.player.deck.cartas
	assert_int(cartas.size()).is_equal(10)
	assert_str(cartas[9].nombre).is_equal("CARD_SWORD")
	assert_int(cartas[9].nivel_actual).is_equal(0)
	assert_int(GlobalData.cpu.deck.cartas.size()).is_equal(9)


func test_store_remove_elimina_por_indice_y_resetea_seleccion() -> void:
	var acciones: Node = _acciones(_tienda())
	var estante: Node = acciones.get("shelf")
	_seleccionar(estante, 0)
	acciones.call("_on_pressed", "STORE_REMOVE")
	assert_int(GlobalData.player.deck.cartas.size()).is_equal(8)
	assert_int(GlobalData.cpu.deck.cartas.size()).is_equal(7)
	assert_int(estante.get("selected_card_index")).is_equal(-1)
	assert_object(estante.get("selected_card_data")).is_null()


func test_store_upgrade_valido_sube_un_nivel() -> void:
	var acciones: Node = _acciones(_tienda())
	var indice: int = _indice_de("CARD_SWORD")
	_seleccionar(acciones.get("shelf"), indice)
	acciones.call("_on_pressed", "STORE_UPGRADE")
	assert_int(GlobalData.player.deck.cartas[indice].nivel_actual).is_equal(1)


func test_store_upgrade_invalido_no_cambia_mazo_ni_deja_seleccion_invisible() -> void:
	var acciones: Node = _acciones(_tienda())
	var estante: Node = acciones.get("shelf")
	var indice: int = _indice_de("CARD_STUN")
	_seleccionar(estante, indice)
	acciones.call("_on_pressed", "STORE_UPGRADE")
	var etiqueta: Label = acciones.get("description_label")
	assert_str(etiqueta.text).is_equal(tr("STORE_INVALID_UPGRADE"))
	assert_bool(etiqueta.get_theme_color("font_color") == Color.RED).is_true()
	assert_int(GlobalData.player.deck.cartas.size()).is_equal(9)
	assert_int(GlobalData.player.deck.cartas[indice].nivel_actual).is_equal(0)
	assert_int(estante.get("selected_card_index")).is_equal(-1)
	assert_object(estante.get("current_selected_wrapper")).is_null()


func test_accion_valida_oculta_footer_y_muestra_next() -> void:
	var acciones: Node = _acciones(_tienda())
	_seleccionar(acciones.get("shelf"), _indice_de("CARD_SWORD"))
	acciones.call("_on_pressed", "STORE_ADD")
	assert_bool(acciones.get("transaction_done")).is_true()
	assert_bool((acciones.get("footer_node") as Control).visible).is_false()
	assert_bool((acciones.get("next_button") as Button).visible).is_true()


func test_mensaje_de_confirmacion_no_se_borra_al_salir_el_raton() -> void:
	var acciones: Node = _acciones(_tienda())
	_seleccionar(acciones.get("shelf"), _indice_de("CARD_SWORD"))
	acciones.call("_on_pressed", "STORE_ADD")
	var etiqueta: Label = acciones.get("description_label")
	var texto: String = etiqueta.text
	acciones.call("_on_mouse_exited", acciones.get("add_button"))
	assert_str(etiqueta.text).is_equal(texto)
	assert_bool(etiqueta.text.is_empty()).is_false()


func test_next_round_carga_combat_via_scene_loader() -> void:
	var acciones: Node = _acciones(_tienda())
	(acciones.get("next_button") as Button).pressed.emit()
	assert_bool(SceneLoader.is_loading).is_true()
	assert_str(SceneLoader.scene_path).is_equal("res://scenes/combat.tscn")
	SceneLoader.load_scene("res://scenes/store.tscn")
	assert_str(SceneLoader.scene_path).is_equal("res://scenes/combat.tscn")
	await SceneLoader.current_loading_screen.loading_screen_ready
	# Se congela _process y se consume la carga thread antes de abortar:
	# asi no hay cambio de escena ni peticiones pendientes al salir
	SceneLoader.set_process(false)
	var estado: int = ResourceLoader.load_threaded_get_status(SceneLoader.scene_path)
	while estado == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		estado = ResourceLoader.load_threaded_get_status(SceneLoader.scene_path)
	ResourceLoader.load_threaded_get(SceneLoader.scene_path)
	SceneLoader.call("_abort_load")
	assert_bool(SceneLoader.is_loading).is_false()
