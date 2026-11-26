extends GdUnitTestSuite


func before_test() -> void:
	GlobalData.reset_game()


func after_test() -> void:
	GlobalData.reset_game()


func _escena() -> Node2D:
	# Se instancia con mazos vacios para evitar el reparto con timers de _ready;
	# los mazos se asignan despues y se llama a combat() directamente
	var escena: Node2D = auto_free(load("res://scenes/combat.tscn").instantiate())
	add_child(escena)
	GlobalData.player._setup({ "deck": DeckManager.create_deck("DECK_FIGHTER") })
	GlobalData.cpu._setup({ "deck": DeckManager.create_deck("DECK_MAGE"), "difficulty": "EASY_DIFFICULTY" })
	return escena.get_node("CombatLogic")


func _carta(nombre: String, es_jugador: bool, nivel: int = 0) -> Node2D:
	var carta: Node2D = auto_free(load("res://scenes/card.tscn").instantiate())
	add_child(carta)
	carta.setup(CardManager.create_card(nombre, { "actual": nivel, "max": 3 }), es_jugador)
	return carta


func test_sword_vs_shield_armadura_absorbe_primero() -> void:
	var escena: Node2D = _escena()
	await escena.combat(_carta("CARD_SWORD", true, 1), _carta("CARD_SHIELD", false))
	assert_int(GlobalData.cpu.current_hp).is_equal(90)
	assert_int(GlobalData.player.current_hp).is_equal(100)
	assert_int(GlobalData.cpu.physical_defense).is_equal(0)


func test_magic_vs_mirror_refleja_danio_y_quema_al_caster() -> void:
	var escena: Node2D = _escena()
	await escena.combat(_carta("CARD_MAGIC", true), _carta("CARD_MIRROR", false))
	assert_int(GlobalData.player.current_hp).is_equal(90)
	assert_bool(GlobalData.player.has_status("STATUS_BURN")).is_true()
	assert_int(GlobalData.cpu.current_hp).is_equal(100)
	assert_bool(GlobalData.cpu.has_rebound()).is_false()


func test_sword_vs_sword_resuelven_ambos_aunque_el_segundo_muera() -> void:
	var escena: Node2D = _escena()
	GlobalData.player.set_hp(10)
	await escena.combat(_carta("CARD_SWORD", true), _carta("CARD_SWORD", false))
	assert_int(GlobalData.player.current_hp).is_equal(0)
	assert_int(GlobalData.cpu.current_hp).is_equal(90)


func test_sword_vs_magic_salta_la_magia_invalida() -> void:
	var escena: Node2D = _escena()
	await escena.combat(_carta("CARD_SWORD", true), _carta("CARD_MAGIC", false))
	assert_int(GlobalData.cpu.current_hp).is_equal(90)
	assert_int(GlobalData.player.current_hp).is_equal(100)
	assert_bool(GlobalData.player.has_status("STATUS_BURN")).is_false()


func test_potion_vs_ofensiva_se_salta() -> void:
	var escena: Node2D = _escena()
	GlobalData.player.set_hp(80)
	await escena.combat(_carta("CARD_POTION", true), _carta("CARD_SWORD", false))
	assert_int(GlobalData.player.current_hp).is_equal(70)
	assert_bool(GlobalData.player.has_status("STATUS_REGENERATION")).is_false()


func test_shield_vs_shield_y_mirror_vs_mirror_sin_efecto() -> void:
	var escena: Node2D = _escena()
	await escena.combat(_carta("CARD_SHIELD", true), _carta("CARD_SHIELD", false))
	assert_int(GlobalData.player.current_hp).is_equal(100)
	assert_int(GlobalData.cpu.current_hp).is_equal(100)
	assert_int(GlobalData.player.physical_defense).is_equal(0)
	assert_int(GlobalData.cpu.physical_defense).is_equal(0)
	await escena.combat(_carta("CARD_MIRROR", true), _carta("CARD_MIRROR", false))
	assert_bool(GlobalData.player.has_rebound()).is_false()
	assert_bool(GlobalData.cpu.has_rebound()).is_false()


func test_stun_sin_oposicion_anula_el_siguiente_intercambio() -> void:
	var escena: Node2D = _escena()
	await escena.combat(_carta("CARD_STUN", true), _carta("CARD_SHIELD", false))
	assert_bool(GlobalData.cpu.has_status("STATUS_STUN")).is_true()
	escena.end_of_combat_update()
	await escena.combat(_carta("CARD_SWORD", true), _carta("CARD_SWORD", false))
	assert_int(GlobalData.player.current_hp).is_equal(100)
	assert_int(GlobalData.cpu.current_hp).is_equal(90)


func test_burn_y_regen_se_aplican_antes_que_las_cartas() -> void:
	var escena: Node2D = _escena()
	GlobalData.player.last_card_played = CardManager.create_card("CARD_SWORD", { "actual": 0, "max": 3 })
	GlobalData.player.add_status(StatusManager.create_status("STATUS_BURN"))
	GlobalData.cpu.set_hp(90)
	GlobalData.cpu.add_status(StatusManager.create_status("STATUS_REGENERATION"))
	await escena.combat(_carta("CARD_SHIELD", true), _carta("CARD_SHIELD", false))
	assert_int(GlobalData.player.current_hp).is_equal(95)
	assert_int(GlobalData.cpu.current_hp).is_equal(95)
	assert_int(GlobalData.player.physical_defense).is_equal(0)


func test_game_over_instancia_ui_y_guarda_la_run() -> void:
	var habia_fichero: bool = FileAccess.file_exists(SaveManager.SAVE_PATH)
	var backup: PackedByteArray = PackedByteArray()
	if habia_fichero:
		var lectura: FileAccess = FileAccess.open(SaveManager.SAVE_PATH, FileAccess.READ)
		backup = lectura.get_buffer(lectura.get_length())
		lectura.close()
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)
	var escena: Node2D = _escena()
	GlobalData.cpu.set_hp(0)
	assert_bool(escena.check_game_over()).is_true()
	var historial: Array = SaveManager.load_history()
	assert_int(historial.size()).is_equal(1)
	assert_bool(historial[0]["won"]).is_true()
	var ui: Node = null
	for hijo: Node in escena.get_children():
		var script: Script = hijo.get_script()
		if script != null and script.resource_path == "res://scripts/combat/game_over_ui.gd":
			ui = hijo
	assert_object(ui).is_not_null()
	DirAccess.remove_absolute(SaveManager.SAVE_PATH)
	if habia_fichero:
		var escritura: FileAccess = FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		escritura.store_buffer(backup)
		escritura.close()


func test_drop_de_la_misma_carta_en_slot_mantiene_seleccion() -> void:
	var escena: Node2D = _escena()
	var carta: Node2D = _carta("CARD_SWORD", true)
	carta.global_position = escena.player_slot_rect.get_center()
	escena.card_being_dragged = carta
	escena.check_drop_card()
	assert_object(escena.card_in_slot).is_same(carta)
	escena.card_being_dragged = carta
	escena.check_drop_card()
	assert_object(escena.card_in_slot).is_same(carta)
