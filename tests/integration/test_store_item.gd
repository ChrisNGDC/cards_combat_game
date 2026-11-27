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


func _vivos(estante: Node) -> int:
	var cuenta: int = 0
	for hijo: Node in estante.get_children():
		if not hijo.is_queued_for_deletion():
			cuenta += 1
	return cuenta


func _nombres_en_estante(estante: Node) -> Array:
	var nombres: Array = []
	for hijo: Node in estante.get_children():
		if hijo.is_queued_for_deletion():
			continue
		for nieto: Node in hijo.get_children():
			if nieto is Label:
				nombres.append(nieto.text)
	return nombres


func test_store_item_muestra_oferta_de_tres_y_no_finaliza() -> void:
	var acciones: Node = _acciones(_tienda())
	acciones.call("_on_pressed", "STORE_ITEM")
	assert_bool(acciones.get("viewing_items")).is_true()
	assert_bool(acciones.get("transaction_done")).is_false()
	assert_int(_vivos(acciones.get("shelf"))).is_equal(3)


func test_store_item_toma_item_y_espeja_cpu() -> void:
	var acciones: Node = _acciones(_tienda())
	acciones.call("_on_pressed", "STORE_ITEM")
	acciones.call("_on_item_selected", ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	assert_int(GlobalData.player.items.size()).is_equal(1)
	assert_int(GlobalData.cpu.items.size()).is_equal(1)
	assert_bool(acciones.get("transaction_done")).is_true()


func test_shelf_item_selected_conecta_a_toma() -> void:
	var acciones: Node = _acciones(_tienda())
	acciones.call("_on_pressed", "STORE_ITEM")
	var estante: Node = acciones.get("shelf")
	estante.emit_signal("item_selected", ItemManager.create_item("ITEM_REGEN"))
	assert_int(GlobalData.player.items.size()).is_equal(1)
	assert_str(GlobalData.player.items[0].nombre).is_equal("ITEM_REGEN")


func test_store_item_cancelar_vuelve_a_cartas() -> void:
	var acciones: Node = _acciones(_tienda())
	acciones.call("_on_pressed", "STORE_ITEM")
	acciones.call("_on_pressed", "STORE_ADD")
	assert_bool(acciones.get("viewing_items")).is_false()
	assert_int(_vivos(acciones.get("shelf"))).is_equal(GlobalData.player.deck.cartas.size())


func test_store_item_segundo_press_vuelve_a_cartas() -> void:
	var acciones: Node = _acciones(_tienda())
	acciones.call("_on_pressed", "STORE_ITEM")
	acciones.call("_on_pressed", "STORE_ITEM")
	assert_bool(acciones.get("viewing_items")).is_false()
	assert_bool(acciones.get("transaction_done")).is_false()
	assert_int(_vivos(acciones.get("shelf"))).is_equal(GlobalData.player.deck.cartas.size())


func test_oferta_fija_al_entrar_a_la_tienda() -> void:
	var acciones: Node = _acciones(_tienda())
	var oferta: Array = acciones.get("oferta_items")
	assert_int(oferta.size()).is_equal(3)
	acciones.call("_on_pressed", "STORE_ITEM")
	var primera: Array = _nombres_en_estante(acciones.get("shelf"))
	acciones.call("_on_pressed", "STORE_ITEM")
	acciones.call("_on_pressed", "STORE_ITEM")
	var segunda: Array = _nombres_en_estante(acciones.get("shelf"))
	assert_array(segunda).is_equal(primera)
	assert_array(acciones.get("oferta_items")).is_same(oferta)


func _wrapper_item(estante: Node) -> Control:
	for hijo: Node in estante.get_children():
		if not hijo.is_queued_for_deletion():
			return hijo
	return null


func test_hover_item_muestra_tooltip_y_no_texto_inferior() -> void:
	var acciones: Node = _acciones(_tienda())
	acciones.call("_on_pressed", "STORE_ITEM")
	var wrapper: Control = _wrapper_item(acciones.get("shelf"))
	var antes: int = TooltipManager.get_child_count()
	wrapper.mouse_entered.emit()
	assert_int(TooltipManager.get_child_count()).is_equal(antes + 1)
	var tooltip: PanelContainer = TooltipManager.get_child(TooltipManager.get_child_count() - 1)
	var texto: String = tooltip.get_node("RichTextLabel").text
	assert_bool(texto.contains("%d")).is_false()
	assert_bool(texto.contains("[color")).is_true()
	assert_str(acciones.get("description_label").text).is_empty()
	wrapper.mouse_exited.emit()
	assert_int(TooltipManager.get_child_count()).is_equal(antes)


func test_hover_item_agranda_wrapper_como_las_cartas() -> void:
	var acciones: Node = _acciones(_tienda())
	acciones.call("_on_pressed", "STORE_ITEM")
	var wrapper: Control = _wrapper_item(acciones.get("shelf"))
	wrapper.mouse_entered.emit()
	await get_tree().create_timer(0.25).timeout
	assert_float(wrapper.scale.x).is_greater(1.0)
	wrapper.mouse_exited.emit()
	await get_tree().create_timer(0.25).timeout
	assert_float(wrapper.scale.x).is_equal(1.0)
