extends GdUnitTestSuite


var _locale_original: String = ""


func before_test() -> void:
	_locale_original = TranslationServer.get_locale()
	GlobalData.reset_game()


func after_test() -> void:
	TranslationServer.set_locale(_locale_original)
	GlobalData.reset_game()


func _traducciones() -> Dictionary:
	return {
		"en": load("res://resources/translations.en.translation"),
		"es": load("res://resources/translations.es.translation"),
	}


func test_todas_las_claves_del_csv_estan_traducidas() -> void:
	var fichero: FileAccess = FileAccess.open("res://resources/translations.csv", FileAccess.READ)
	var traducciones: Dictionary = _traducciones()
	var cabecera: PackedStringArray = fichero.get_csv_line()
	assert_int(cabecera.size()).is_equal(3)
	var claves: int = 0
	while not fichero.eof_reached():
		var linea: PackedStringArray = fichero.get_csv_line()
		if linea.size() < 3 or linea[0].is_empty():
			continue
		claves += 1
		for idioma: String in traducciones:
			var traduccion: Translation = traducciones[idioma]
			assert_str(str(traduccion.get_message(linea[0]))).is_not_empty()
	assert_int(claves).is_greater(0)


func test_claves_usadas_por_scripts_existen() -> void:
	var claves: Array[String] = []
	for clave: String in CardManager.cards_classes:
		claves.append(clave)
		claves.append(clave + "_DESC")
	for clave: String in DeckManager.decks_classes:
		claves.append(clave)
	for clave: String in StatusManager.statuses:
		claves.append(clave)
		claves.append(clave + "_DESC")
	claves.append_array([
		"CARD_OFFENSIVE", "CARD_DEFENSIVE", "CARD_PHYSICAL", "CARD_MAGICAL", "CARD_NONE",
		"STORE_ADD", "STORE_REMOVE", "STORE_UPGRADE", "STORE_INVALID_UPGRADE",
		"GAMEOVER_WIN_TITLE", "GAMEOVER_LOSS_TITLE", "GAMEOVER_WIN_MSG", "GAMEOVER_LOSS_MSG",
		"HELP_AND", "STATUS", "COMBAT_ROUND",
	])
	var traducciones: Dictionary = _traducciones()
	for clave: String in claves:
		for idioma: String in traducciones:
			var traduccion: Translation = traducciones[idioma]
			assert_str(str(traduccion.get_message(clave))).is_not_empty()


func test_auto_translate_cambia_el_texto_con_el_locale() -> void:
	var etiqueta: Label = auto_free(Label.new())
	add_child(etiqueta)
	var traductor: Node = auto_free(load("res://scenes/auto_translate.tscn").instantiate())
	etiqueta.add_child(traductor)
	traductor.call("set_translation", "MENU_PLAY")
	TranslationServer.set_locale("en")
	assert_str(etiqueta.text).is_equal("Play")
	TranslationServer.set_locale("es")
	assert_str(etiqueta.text).is_equal("Jugar")


func test_ayuda_de_combate_en_ingles_sin_conjuncion_espanola() -> void:
	var combate: Node2D = auto_free(load("res://scenes/combat.tscn").instantiate())
	add_child(combate)
	var control: Control = combate.get_node("CombatLogic/RoundControl")
	TranslationServer.set_locale("en")
	control.call("_on_help_mouse_entered")
	var texto: String = (control.get_node("RoundLabel") as RichTextLabel).text
	assert_str(texto).contains(" and ")
	assert_bool(texto.contains(" y ")).is_false()


func test_card_stun_desc_es_contiene_cancela() -> void:
	var es: Translation = load("res://resources/translations.es.translation")
	assert_str(str(es.get_message("CARD_STUN_DESC"))).contains("cancela")


func test_status_tooltip_formatea_con_las_constantes() -> void:
	var tooltip: PanelContainer = auto_free(load("res://scenes/status_tooltip.tscn").instantiate())
	add_child(tooltip)
	var descripcion: RichTextLabel = tooltip.get_node("RichTextLabel")
	tooltip.call("setup", "STATUS_BURN", "STATUS_BURN_DESC")
	assert_str(descripcion.text).contains(str(StatusManager.BURN_DAMAGE))
	tooltip.call("setup", "STATUS_REGENERATION", "STATUS_REGENERATION_DESC")
	assert_str(descripcion.text).contains(str(StatusManager.REGENERATION_HEAL))
