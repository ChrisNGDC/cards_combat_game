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


func test_items_del_jugador_se_muestran_agrupados() -> void:
	GlobalData.player.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	GlobalData.player.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	GlobalData.player.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	var escena: Node2D = _escena()
	assert_int(escena.player_items.get_children().size()).is_equal(2)
	assert_int(escena.cpu_items.get_children().size()).is_equal(0)


func test_items_de_la_cpu_se_muestran() -> void:
	GlobalData.cpu.add_item(ItemManager.create_item("ITEM_REGEN"))
	var escena: Node2D = _escena()
	assert_int(escena.cpu_items.get_children().size()).is_equal(1)


func test_titulo_panel_cuenta_total() -> void:
	GlobalData.player.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	GlobalData.player.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	var escena: Node2D = _escena()
	assert_str(escena.player_items_panel.title).is_equal(tr("ITEMS") + " (2)")


func test_panel_items_jugador_sobre_la_vida_y_expande_hacia_arriba() -> void:
	GlobalData.player.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	GlobalData.player.add_item(ItemManager.create_item("ITEM_REGEN"))
	var escena: Node2D = _escena()
	var panel: FoldableContainer = escena.get_node("PlayerItems")
	var hp: TextureProgressBar = escena.get_parent().get_node("HPManager/PlayerHP")
	var top_antes: float = panel.global_position.y
	var bottom_antes: float = panel.global_position.y + panel.size.y
	panel.folded = false
	await get_tree().process_frame
	await get_tree().process_frame
	var bottom_despues: float = panel.global_position.y + panel.size.y
	assert_float(bottom_despues).is_equal(bottom_antes)
	assert_float(bottom_despues).is_less_equal(hp.global_position.y)
	assert_float(panel.global_position.y).is_less(top_antes)


func test_panel_items_cpu_sobre_la_vida_y_expande_hacia_arriba() -> void:
	GlobalData.cpu.add_item(ItemManager.create_item("ITEM_REGEN"))
	var escena: Node2D = _escena()
	var panel: FoldableContainer = escena.get_node("CPUItems")
	var hp: TextureProgressBar = escena.get_parent().get_node("HPManager/CpuHP")
	var bottom_antes: float = panel.global_position.y + panel.size.y
	panel.folded = false
	await get_tree().process_frame
	await get_tree().process_frame
	var bottom_despues: float = panel.global_position.y + panel.size.y
	assert_float(bottom_despues).is_equal(bottom_antes)
	assert_float(bottom_despues).is_less_equal(hp.global_position.y)
