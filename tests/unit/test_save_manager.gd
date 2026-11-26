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


func _escribir_save(contenido: String) -> void:
	var fichero: FileAccess = FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	fichero.store_string(contenido)
	fichero.close()


func _run_valida() -> Dictionary:
	return {
		"date": "2026-01-01 12:00",
		"won": true,
		"player_deck": { "nombre": "DECK_FIGHTER", "cartas": [] },
		"cpu_deck": { "nombre": "DECK_MAGE", "cartas": [] },
	}


func test_roundtrip_save_run_load_history() -> void:
	var run: Dictionary = _run_valida()
	SaveManager.save_run(run)
	var historial: Array = SaveManager.load_history()
	assert_int(historial.size()).is_equal(1)
	assert_dict(historial[0]).is_equal(run)


func test_save_run_acumula_historial() -> void:
	SaveManager.save_run(_run_valida())
	SaveManager.save_run(_run_valida())
	assert_int(SaveManager.load_history().size()).is_equal(2)


func test_json_corrupto_devuelve_vacio_y_borra_fichero() -> void:
	_escribir_save("esto no es json {{{")
	assert_array(SaveManager.load_history()).is_empty()
	assert_bool(FileAccess.file_exists(SaveManager.SAVE_PATH)).is_false()


func test_version_distinta_devuelve_vacio_y_borra_fichero() -> void:
	# La version viaja como float por JSON (gotcha deliberado de VERSION)
	_escribir_save(JSON.stringify([99.0, _run_valida()]))
	assert_array(SaveManager.load_history()).is_empty()
	assert_bool(FileAccess.file_exists(SaveManager.SAVE_PATH)).is_false()


func test_sin_cabecera_de_version_devuelve_vacio() -> void:
	_escribir_save(JSON.stringify([_run_valida()]))
	assert_array(SaveManager.load_history()).is_empty()
	assert_bool(FileAccess.file_exists(SaveManager.SAVE_PATH)).is_false()


func test_history_menu_descarta_entradas_basura() -> void:
	var entradas: Array = [SaveManager.VERSION, "basura", { "date": "x" }, _run_valida()]
	_escribir_save(JSON.stringify(entradas))
	var menu: Control = auto_free(load("res://scenes/history_menu.tscn").instantiate())
	add_child(menu)
	var lista: VBoxContainer = menu.get_node("ScrollContainer/HistoryList")
	var visibles: int = 0
	for hijo: Node in lista.get_children():
		if not hijo.is_queued_for_deletion():
			visibles += 1
	assert_int(visibles).is_equal(1)
