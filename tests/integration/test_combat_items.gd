extends GdUnitTestSuite


func before_test() -> void:
	GlobalData.reset_game()


func after_test() -> void:
	GlobalData.reset_game()


func _escena() -> Node2D:
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


func test_sword_con_item_suma_bonus() -> void:
	var escena: Node2D = _escena()
	GlobalData.player.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	await escena.combat(_carta("CARD_SWORD", true), _carta("CARD_MIRROR", false))
	assert_int(GlobalData.cpu.current_hp).is_equal(87)


func test_shield_con_item_suma_bonus() -> void:
	var escena: Node2D = _escena()
	GlobalData.player.add_item(ItemManager.create_item("ITEM_SHIELD_ARMOR"))
	await escena.combat(_carta("CARD_SHIELD", true), _carta("CARD_MIRROR", false))
	assert_int(GlobalData.player.physical_defense).is_equal(15)


func test_potion_con_item_suma_bonus() -> void:
	var escena: Node2D = _escena()
	GlobalData.player.add_item(ItemManager.create_item("ITEM_POTION_HEAL"))
	GlobalData.player.set_hp(80)
	await escena.combat(_carta("CARD_POTION", true), _carta("CARD_MIRROR", false))
	assert_int(GlobalData.player.current_hp).is_equal(95)


func test_magic_reflejado_usa_amount_con_bonus() -> void:
	var escena: Node2D = _escena()
	GlobalData.player.add_item(ItemManager.create_item("ITEM_MAGIC_DAMAGE"))
	await escena.combat(_carta("CARD_MAGIC", true), _carta("CARD_MIRROR", false))
	assert_int(GlobalData.player.current_hp).is_equal(87)


func test_exchange_heal_se_aplica_en_combate() -> void:
	var escena: Node2D = _escena()
	GlobalData.player.add_item(ItemManager.create_item("ITEM_REGEN"))
	GlobalData.player.set_hp(90)
	await escena.combat(_carta("CARD_SHIELD", true), _carta("CARD_SHIELD", false))
	assert_int(GlobalData.player.current_hp).is_equal(92)


func test_game_over_guarda_items_en_run() -> void:
	var habia_fichero: bool = FileAccess.file_exists(SaveManager.SAVE_PATH)
	var backup: PackedByteArray = PackedByteArray()
	if habia_fichero:
		var fichero: FileAccess = FileAccess.open(SaveManager.SAVE_PATH, FileAccess.READ)
		backup = fichero.get_buffer(fichero.get_length())
		fichero.close()
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)
	var escena: Node2D = _escena()
	GlobalData.player.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	GlobalData.player.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	GlobalData.cpu.add_item(ItemManager.create_item("ITEM_REGEN"))
	GlobalData.cpu.set_hp(0)
	escena.check_game_over()
	var historial: Array = SaveManager.load_history()
	assert_int(historial.size()).is_equal(1)
	assert_int(historial[0]["player_items"].size()).is_equal(2)
	assert_str(historial[0]["player_items"][0]).is_equal("ITEM_MAX_HP")
	assert_int(historial[0]["cpu_items"].size()).is_equal(1)
	assert_str(historial[0]["cpu_items"][0]).is_equal("ITEM_REGEN")
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)
	if habia_fichero:
		var restaurar: FileAccess = FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
		restaurar.store_buffer(backup)
		restaurar.close()
