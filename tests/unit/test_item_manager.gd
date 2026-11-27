extends GdUnitTestSuite


func test_clave_desconocida_devuelve_null() -> void:
	assert_object(ItemManager.create_item("ITEM_UNKNOWN")).is_null()


func test_create_item_popula_nombre_y_bono() -> void:
	var item: ItemData = ItemManager.create_item("ITEM_SWORD_DAMAGE")
	assert_object(item).is_not_null()
	assert_str(item.nombre).is_equal("ITEM_SWORD_DAMAGE")
	assert_bool(item.apilable).is_false()
	assert_int(item.get_bono("SWORD_DAMAGE")).is_equal(3)


func test_max_hp_es_apilable_con_efecto_adquisicion() -> void:
	var item: ItemData = ItemManager.create_item("ITEM_MAX_HP")
	assert_bool(item.apilable).is_true()
	assert_bool(item.efecto_adquisicion.is_valid()).is_true()


func test_catalogo_tiene_seis_items() -> void:
	assert_int(ItemManager.items_classes.size()).is_equal(6)


func _personaje() -> Character:
	var personaje: Character = Character.new()
	personaje.set_deck(DeckManager.create_deck("DECK_FIGHTER"))
	personaje.set_initial_hp()
	return personaje


func _nombres(oferta: Array[ItemData]) -> Array[String]:
	var nombres: Array[String] = []
	for item: ItemData in oferta:
		nombres.append(item.nombre)
	return nombres


func test_get_oferta_maximo_tres() -> void:
	var oferta: Array[ItemData] = ItemManager.get_oferta(_personaje())
	assert_int(oferta.size()).is_equal(3)


func test_get_oferta_excluye_unicos_poseidos() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	var nombres: Array[String] = _nombres(ItemManager.get_oferta(personaje))
	assert_bool(nombres.has("ITEM_SWORD_DAMAGE")).is_false()


func test_get_oferta_siempre_incluye_apilable() -> void:
	var personaje: Character = _personaje()
	personaje.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	var nombres: Array[String] = _nombres(ItemManager.get_oferta(personaje))
	assert_bool(nombres.has("ITEM_MAX_HP")).is_true()


func test_get_oferta_con_todos_unicos_solo_apilable() -> void:
	var personaje: Character = _personaje()
	for clave: String in ["ITEM_REGEN", "ITEM_SWORD_DAMAGE", "ITEM_SHIELD_ARMOR", "ITEM_POTION_HEAL", "ITEM_MAGIC_DAMAGE"]:
		personaje.add_item(ItemManager.create_item(clave))
	var oferta: Array[ItemData] = ItemManager.get_oferta(personaje)
	assert_int(oferta.size()).is_equal(1)
	assert_str(oferta[0].nombre).is_equal("ITEM_MAX_HP")


func test_get_oferta_es_independiente_por_personaje() -> void:
	var jugador: Character = _personaje()
	var cpu: Character = _personaje()
	for clave: String in ["ITEM_REGEN", "ITEM_SHIELD_ARMOR", "ITEM_POTION_HEAL", "ITEM_MAGIC_DAMAGE"]:
		jugador.add_item(ItemManager.create_item(clave))
	cpu.add_item(ItemManager.create_item("ITEM_SWORD_DAMAGE"))
	# Al jugador solo le quedan max_hp + sword (pool 2): sword aparece seguro.
	assert_bool(_nombres(ItemManager.get_oferta(jugador)).has("ITEM_SWORD_DAMAGE")).is_true()
	# La CPU ya tiene sword: su oferta lo excluye siempre.
	assert_bool(_nombres(ItemManager.get_oferta(cpu)).has("ITEM_SWORD_DAMAGE")).is_false()
