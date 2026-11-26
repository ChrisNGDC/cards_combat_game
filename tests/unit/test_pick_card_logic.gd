extends GdUnitTestSuite


func _mano(nombres: Array[String]) -> Array[CardData]:
	var cartas: Array[CardData] = []
	for nombre: String in nombres:
		cartas.append(CardManager.create_card(nombre, { "actual": 0, "max": 3 }))
	return cartas


func test_get_cards_frequency_cuenta_por_clave() -> void:
	var logic: PickCardLogic = PickCardLogic.new()
	var frecuencia: Dictionary = logic.get_cards_frequency(_mano(["CARD_SWORD", "CARD_SWORD", "CARD_SHIELD"]))
	assert_dict(frecuencia).is_equal({ "CARD_SWORD": 2, "CARD_SHIELD": 1 })


func test_dict_to_sorted_array_ordena_descendente() -> void:
	var logic: PickCardLogic = PickCardLogic.new()
	var ordenadas: Array[String] = logic.dict_to_sorted_array({ "A": 1, "B": 5, "C": 3 })
	assert_array(ordenadas).contains_exactly(["B", "C", "A"])


func test_get_card_matchup_devuelve_la_fila_exacta() -> void:
	var matchups: Matchups = Matchups.new()
	for clave: String in Matchups.MATCHUP_TABLE:
		assert_dict(matchups.get_card_matchup(clave)).is_equal(Matchups.MATCHUP_TABLE[clave])


func test_get_cards_by_power_con_mano_conocida() -> void:
	var logic: PickCardLogic = PickCardLogic.new()
	logic.get_cards_by_power(_mano(["CARD_SWORD", "CARD_SWORD", "CARD_SHIELD"]))
	assert_dict(logic.cards_power).is_equal({
		"CARD_SWORD": 9, "CARD_SHIELD": 14, "CARD_MAGIC": 7,
		"CARD_MIRROR": 6, "CARD_POTION": 7, "CARD_STUN": 7,
	})
	assert_str(logic.cards_to_play[0]).is_equal("CARD_SHIELD")
	assert_str(logic.cards_to_play[1]).is_equal("CARD_SWORD")


func test_cards_power_acumula_entre_llamadas() -> void:
	var logic: PickCardLogic = PickCardLogic.new()
	var mano: Array[CardData] = _mano(["CARD_SWORD", "CARD_SWORD", "CARD_SHIELD"])
	logic.get_cards_by_power(mano)
	logic.get_cards_by_power(mano)
	assert_int(logic.cards_power["CARD_SHIELD"]).is_equal(28)
	assert_int(logic.cards_power["CARD_SWORD"]).is_equal(18)


func test_convert_hand_extrae_datos_carta() -> void:
	var logic: PickCardLogic = PickCardLogic.new()
	var nodos: Array[Node2D] = []
	for nombre: String in ["CARD_SWORD", "CARD_SHIELD"]:
		var carta: Node2D = auto_free(load("res://scenes/card.tscn").instantiate())
		add_child(carta)
		carta.setup(CardManager.create_card(nombre, { "actual": 0, "max": 3 }), true)
		nodos.append(carta)
	var datos: Array[CardData] = logic.convert_hand(nodos)
	assert_array(datos).has_size(2)
	assert_str(datos[0].nombre).is_equal("CARD_SWORD")
	assert_str(datos[1].nombre).is_equal("CARD_SHIELD")