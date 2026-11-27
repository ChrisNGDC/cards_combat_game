extends GdUnitTestSuite


var _backup: PackedByteArray = PackedByteArray()
var _habia_fichero: bool = false


func before_test() -> void:
	_habia_fichero = FileAccess.file_exists(SaveManager.SAVE_PATH)
	if _habia_fichero:
		var fichero: FileAccess = FileAccess.open(SaveManager.SAVE_PATH, FileAccess.READ)
		_backup = fichero.get_buffer(fichero.get_length())
		fichero.close()
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)


func after_test() -> void:
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)
	if _habia_fichero:
		var fichero: FileAccess = FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		fichero.store_buffer(_backup)
		fichero.close()


func _overlay() -> CanvasLayer:
	var overlay: CanvasLayer = auto_free(load("res://scenes/deck_overlay.tscn").instantiate())
	add_child(overlay)
	return overlay


func _deck_data() -> Dictionary:
	return { "name": "DECK_FIGHTER", "cards": [] }


func test_display_history_deck_muestra_items_agrupados() -> void:
	var overlay: CanvasLayer = _overlay()
	overlay.display_history_deck(_deck_data(), ["ITEM_MAX_HP", "ITEM_MAX_HP", "ITEM_REGEN"])
	var seccion: VBoxContainer = overlay.get_node("MarginContainer/VBoxContainer/ItemsSection")
	var contenedor: HFlowContainer = overlay.get_node("MarginContainer/VBoxContainer/ItemsSection/ItemsContainer")
	assert_bool(seccion.visible).is_true()
	assert_int(contenedor.get_children().size()).is_equal(2)


func test_display_history_deck_sin_items_oculta_seccion() -> void:
	var overlay: CanvasLayer = _overlay()
	overlay.display_history_deck(_deck_data(), [])
	var seccion: VBoxContainer = overlay.get_node("MarginContainer/VBoxContainer/ItemsSection")
	assert_bool(seccion.visible).is_false()


func test_items_del_historial_se_muestran_en_fila() -> void:
	var overlay: CanvasLayer = _overlay()
	overlay.display_history_deck(_deck_data(), ["ITEM_MAX_HP", "ITEM_REGEN"])
	await get_tree().process_frame
	await get_tree().process_frame
	var contenedor: HFlowContainer = overlay.get_node("MarginContainer/VBoxContainer/ItemsSection/ItemsContainer")
	var iconos: Array = []
	for hijo: Node in contenedor.get_children():
		if not hijo.is_queued_for_deletion():
			iconos.append(hijo)
	assert_int(iconos.size()).is_equal(2)
	assert_float(iconos[1].position.y).is_equal(iconos[0].position.y)
	assert_float(iconos[1].position.x).is_greater(iconos[0].position.x)


func test_iconos_del_historial_tienen_doble_tamanio() -> void:
	var overlay: CanvasLayer = _overlay()
	overlay.display_history_deck(_deck_data(), ["ITEM_MAX_HP"])
	await get_tree().process_frame
	await get_tree().process_frame
	var contenedor: HFlowContainer = overlay.get_node("MarginContainer/VBoxContainer/ItemsSection/ItemsContainer")
	var icono: Panel = null
	for hijo: Node in contenedor.get_children():
		if not hijo.is_queued_for_deletion():
			icono = hijo
	assert_float(icono.size.x).is_equal(64.0)
	assert_float(icono.size.y).is_equal(64.0)


func test_display_deck_data_no_muestra_items() -> void:
	var overlay: CanvasLayer = _overlay()
	var cartas: Array[CardData] = []
	overlay.display_deck_data(cartas)
	var seccion: VBoxContainer = overlay.get_node("MarginContainer/VBoxContainer/ItemsSection")
	assert_bool(seccion.visible).is_false()


func test_boton_mazo_pasa_items_al_overlay() -> void:
	var run: Dictionary = {
		"date": "2026-01-01 10:00",
		"won": true,
		"player_deck": { "name": "DECK_FIGHTER", "cards": [] },
		"cpu_deck": { "name": "DECK_MAGE", "cards": [] },
		"player_items": ["ITEM_MAX_HP", "ITEM_MAX_HP"],
		"cpu_items": ["ITEM_REGEN"],
	}
	SaveManager.save_run(run)
	var menu: Control = auto_free(load("res://scenes/history_menu.tscn").instantiate())
	add_child(menu)
	var lista: VBoxContainer = menu.get_node("ScrollContainer/HistoryList")
	var entry: HBoxContainer = null
	for hijo: Node in lista.get_children():
		if not hijo.is_queued_for_deletion():
			entry = hijo
	entry.get_node("PlayerDeckButton").pressed.emit()
	var overlay: CanvasLayer = null
	for hijo: Node in menu.get_children():
		if hijo is CanvasLayer:
			overlay = hijo
	assert_object(overlay).is_not_null()
	var contenedor: HFlowContainer = overlay.get_node("MarginContainer/VBoxContainer/ItemsSection/ItemsContainer")
	assert_int(contenedor.get_children().size()).is_equal(1)