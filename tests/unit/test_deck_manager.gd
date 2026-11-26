extends GdUnitTestSuite


func _composicion(mazo: DeckData) -> Dictionary:
	var cuentas: Dictionary = {}
	for carta: CardData in mazo.cartas:
		cuentas[carta.nombre] = cuentas.get(carta.nombre, 0) + 1
	return cuentas


func test_clave_desconocida_devuelve_null() -> void:
	assert_object(DeckManager.create_deck("DECK_UNKNOWN")).is_null()


func test_fighter_9_cartas_vida_100() -> void:
	var mazo: DeckData = DeckManager.create_deck("DECK_FIGHTER")
	assert_str(mazo.nombre).is_equal("DECK_FIGHTER")
	assert_int(mazo.vida).is_equal(100)
	assert_array(mazo.cartas).has_size(9)
	assert_dict(_composicion(mazo)).is_equal({
		"CARD_SWORD": 4, "CARD_SHIELD": 2, "CARD_POTION": 2, "CARD_STUN": 1,
	})


func test_mage_8_cartas_vida_100() -> void:
	var mazo: DeckData = DeckManager.create_deck("DECK_MAGE")
	assert_int(mazo.vida).is_equal(100)
	assert_array(mazo.cartas).has_size(8)
	assert_dict(_composicion(mazo)).is_equal({
		"CARD_MAGIC": 4, "CARD_MIRROR": 2, "CARD_POTION": 2,
	})


func test_paladin_8_cartas_vida_100() -> void:
	var mazo: DeckData = DeckManager.create_deck("DECK_PALADIN")
	assert_int(mazo.vida).is_equal(100)
	assert_array(mazo.cartas).has_size(8)
	assert_dict(_composicion(mazo)).is_equal({
		"CARD_SWORD": 2, "CARD_MAGIC": 2, "CARD_SHIELD": 2, "CARD_POTION": 2,
	})


func test_defender_8_cartas_vida_150() -> void:
	var mazo: DeckData = DeckManager.create_deck("DECK_DEFENDER")
	assert_int(mazo.vida).is_equal(150)
	assert_array(mazo.cartas).has_size(8)
	assert_dict(_composicion(mazo)).is_equal({
		"CARD_SWORD": 2, "CARD_SHIELD": 4, "CARD_POTION": 2,
	})


func test_cartas_del_mazo_son_instancias_independientes() -> void:
	var mazo_a: DeckData = DeckManager.create_deck("DECK_FIGHTER")
	var mazo_b: DeckData = DeckManager.create_deck("DECK_FIGHTER")
	mazo_a.cartas[0].upgrade()
	assert_int(mazo_a.cartas[0].nivel_actual).is_equal(1)
	assert_int(mazo_b.cartas[0].nivel_actual).is_equal(0)