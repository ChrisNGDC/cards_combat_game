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


func _run_con_fecha(fecha: String) -> Dictionary:
	return {
		"date": fecha,
		"won": true,
		"player_deck": { "name": "DECK_FIGHTER", "cards": [] },
		"cpu_deck": { "name": "DECK_MAGE", "cards": [] },
	}


func _entradas_visibles(lista: VBoxContainer) -> Array:
	var entradas: Array = []
	for hijo: Node in lista.get_children():
		if not hijo.is_queued_for_deletion():
			entradas.append(hijo)
	return entradas


func test_boton_eliminar_borra_la_partida_y_refresca() -> void:
	SaveManager.save_run(_run_con_fecha("2026-01-01 10:00"))
	SaveManager.save_run(_run_con_fecha("2026-02-01 10:00"))
	var menu: Control = auto_free(load("res://scenes/history_menu.tscn").instantiate())
	add_child(menu)
	var lista: VBoxContainer = menu.get_node("ScrollContainer/HistoryList")
	var entradas: Array = _entradas_visibles(lista)
	assert_int(entradas.size()).is_equal(2)
	entradas[0].get_node("DeleteButton").pressed.emit()
	var restantes: Array = _entradas_visibles(lista)
	assert_int(restantes.size()).is_equal(1)
	assert_str(restantes[0].run_data["date"]).is_equal("2026-01-01 10:00")
	var historial: Array = SaveManager.load_history()
	assert_int(historial.size()).is_equal(1)
	assert_str(historial[0]["date"]).is_equal("2026-01-01 10:00")