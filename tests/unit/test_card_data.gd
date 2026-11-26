extends GdUnitTestSuite


func _datos_carta() -> Dictionary:
	return {
		"nombre": "CARD_SWORD",
		"ruta_imagen": "res://images/cards/sword.png",
		"tipo": "CARD_OFFENSIVE",
		"niveles": { "actual": 0, "max": 3 },
		"tipo_danio": "CARD_PHYSICAL",
		"description": "CARD_SWORD_DESC",
		"efecto": func(nivel: int) -> int: return 10 + nivel * 10,
	}


func test_init_aplica_datos() -> void:
	var carta: CardData = CardData.new(_datos_carta())
	assert_str(carta.nombre).is_equal("CARD_SWORD")
	assert_str(carta.ruta_imagen).is_equal("res://images/cards/sword.png")
	assert_str(carta.tipo).is_equal("CARD_OFFENSIVE")
	assert_str(carta.tipo_danio).is_equal("CARD_PHYSICAL")
	assert_str(carta.description).is_equal("CARD_SWORD_DESC")
	assert_int(carta.nivel_actual).is_equal(0)
	assert_int(carta.nivel_max).is_equal(3)


func test_upgrade_incrementa_y_topa_en_max() -> void:
	var carta: CardData = CardData.new(_datos_carta())
	assert_bool(carta.upgradeable()).is_true()
	carta.upgrade()
	assert_int(carta.nivel_actual).is_equal(1)
	carta.upgrade()
	carta.upgrade()
	assert_int(carta.nivel_actual).is_equal(3)
	assert_bool(carta.upgradeable()).is_false()
	carta.upgrade()
	assert_int(carta.nivel_actual).is_equal(3)


func test_actuar_usa_nivel_actual() -> void:
	var carta: CardData = CardData.new(_datos_carta())
	assert_int(carta.actuar()).is_equal(10)
	carta.nivel_actual = 2
	assert_int(carta.actuar()).is_equal(30)


func test_actuar_con_callable_invalido_devuelve_cero() -> void:
	var datos: Dictionary = _datos_carta()
	datos["efecto"] = Callable()
	var carta: CardData = CardData.new(datos)
	assert_int(carta.actuar()).is_equal(0)