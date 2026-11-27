extends GdUnitTestSuite


func _personaje() -> Character:
	var personaje: Character = Character.new()
	personaje.set_deck(DeckManager.create_deck("DECK_FIGHTER"))
	personaje.set_initial_hp()
	return personaje


func test_add_item_max_hp_aumenta_maximo_y_cura() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	assert_int(personaje.max_hp).is_equal(120)
	assert_int(personaje.current_hp).is_equal(120)


func test_add_item_max_hp_apilable_dos_veces() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	personaje.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	assert_int(personaje.max_hp).is_equal(140)
	assert_int(personaje.current_hp).is_equal(140)
	assert_int(personaje.items.size()).is_equal(2)


func test_add_item_max_hp_cura_sin_pasar_del_nuevo_maximo() -> void:
	var personaje: Character = _personaje()
	personaje.set_hp(90)
	personaje.add_item(ItemManager.create_item("ITEM_MAX_HP"))
	assert_int(personaje.max_hp).is_equal(120)
	assert_int(personaje.current_hp).is_equal(110)


func test_get_item_bonus_suma_items_del_mismo_tipo() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_REGEN"))
	personaje.add_item(ItemManager.create_item("ITEM_REGEN"))
	assert_int(personaje.get_item_bonus("EXCHANGE_HEAL")).is_equal(4)


func test_get_item_bonus_por_clave_y_ausente() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	personaje.add_item(ItemManager.create_item("ITEM_MAGIC_DAMAGE"))
	assert_int(personaje.get_item_bonus("SWORD_DAMAGE")).is_equal(3)
	assert_int(personaje.get_item_bonus("MAGIC_DAMAGE")).is_equal(3)
	assert_int(personaje.get_item_bonus("SHIELD_ARMOR")).is_equal(0)


func test_has_item_true_y_false() -> void:
	var personaje: Character = _personaje()
	assert_bool(personaje.has_item("ITEM_SWORD_DAMAGE")).is_false()
	personaje.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	assert_bool(personaje.has_item("ITEM_SWORD_DAMAGE")).is_true()
	assert_bool(personaje.has_item("ITEM_REGEN")).is_false()


func test_reset_round_conserva_items() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	personaje.reset_round()
	assert_int(personaje.items.size()).is_equal(1)
	assert_bool(personaje.has_item("ITEM_SWORD_DAMAGE")).is_true()


func test_reset_limpia_items() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	personaje.reset()
	assert_int(personaje.items.size()).is_equal(0)


func test_apply_status_effects_cura_exchange_heal() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_REGEN"))
	personaje.set_hp(90)
	personaje.apply_status_effects()
	assert_int(personaje.current_hp).is_equal(92)
