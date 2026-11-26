extends GdUnitTestSuite


func test_init_aplica_datos() -> void:
	var cartas: Array[CardData] = [CardManager.create_card("CARD_SWORD", { "actual": 0, "max": 3 })]
	var datos: Dictionary = {
		"nombre": "DECK_FIGHTER",
		"ruta_imagen": "res://images/characters/fighter.png",
		"vida": 100,
	}
	var mazo: DeckData = DeckData.new(datos, cartas)
	assert_str(mazo.nombre).is_equal("DECK_FIGHTER")
	assert_str(mazo.ruta_imagen).is_equal("res://images/characters/fighter.png")
	assert_int(mazo.vida).is_equal(100)
	assert_array(mazo.cartas).has_size(1)
	assert_object(mazo.cartas[0]).is_not_null()