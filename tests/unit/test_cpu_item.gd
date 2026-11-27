extends GdUnitTestSuite


func _cpu() -> GameCPU:
	var cpu: GameCPU = GameCPU.new()
	cpu._setup({ "deck": DeckManager.create_deck("DECK_MAGE"), "difficulty": "EASY_DIFFICULTY" })
	return cpu


func test_pick_item_devuelve_item() -> void:
	var cpu: GameCPU = _cpu()
	assert_object(cpu.pick_item()).is_not_null()


func test_pick_item_nunca_devuelve_unico_poseido() -> void:
	var cpu: GameCPU = _cpu()
	cpu.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	for i: int in range(20):
		var item: ItemData = cpu.pick_item()
		assert_str(item.nombre).is_not_equal("ITEM_SWORD_DAMAGE")


func test_pick_item_con_todos_unicos_solo_apilable() -> void:
	var cpu: GameCPU = _cpu()
	for clave: String in ["ITEM_REGEN", "ITEM_SWORD_DAMAGE", "ITEM_SHIELD_ARMOR", "ITEM_POTION_HEAL", "ITEM_MAGIC_DAMAGE"]:
		cpu.add_item(ItemManager.create_item(clave))
	for i: int in range(5):
		assert_str(cpu.pick_item().nombre).is_equal("ITEM_MAX_HP")
