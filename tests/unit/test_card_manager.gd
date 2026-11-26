extends GdUnitTestSuite


func test_clave_desconocida_devuelve_null() -> void:
	assert_object(CardManager.create_card("CARD_UNKNOWN", { "actual": 0, "max": 3 })).is_null()


func test_las_seis_cartas_con_datos_correctos() -> void:
	var esperados: Dictionary = {
		"CARD_SWORD": { "tipo": "CARD_OFFENSIVE", "danio": "CARD_PHYSICAL", "max": 3, "base": 10, "paso": 10 },
		"CARD_SHIELD": { "tipo": "CARD_DEFENSIVE", "danio": "CARD_NONE", "max": 3, "base": 10, "paso": 10 },
		"CARD_MAGIC": { "tipo": "CARD_OFFENSIVE", "danio": "CARD_MAGICAL", "max": 3, "base": 10, "paso": 5 },
		"CARD_MIRROR": { "tipo": "CARD_DEFENSIVE", "danio": "CARD_NONE", "max": 0, "base": 0, "paso": 0 },
		"CARD_POTION": { "tipo": "CARD_DEFENSIVE", "danio": "CARD_NONE", "max": 2, "base": 10, "paso": 15 },
		"CARD_STUN": { "tipo": "CARD_DEFENSIVE", "danio": "CARD_NONE", "max": 0, "base": 0, "paso": 0 },
	}
	for clave: String in esperados:
		var datos: Dictionary = esperados[clave]
		var carta: CardData = CardManager.create_card(clave, { "actual": 0, "max": datos.max })
		assert_object(carta).is_not_null()
		assert_str(carta.nombre).is_equal(clave)
		assert_str(carta.tipo).is_equal(datos.tipo)
		assert_str(carta.tipo_danio).is_equal(datos.danio)
		assert_int(carta.nivel_actual).is_equal(0)
		assert_int(carta.nivel_max).is_equal(datos.max)
		assert_int(carta.actuar()).is_equal(datos.base)
		carta.nivel_actual = datos.max
		assert_int(carta.actuar()).is_equal(datos.base + datos.max * datos.paso)


func test_niveles_se_aplican_al_crear() -> void:
	var carta: CardData = CardManager.create_card("CARD_SWORD", { "actual": 2, "max": 3 })
	assert_int(carta.nivel_actual).is_equal(2)
	assert_int(carta.nivel_max).is_equal(3)
	assert_int(carta.actuar()).is_equal(30)


func test_espejo_y_aturdir_nunca_mejorables() -> void:
	for clave: String in ["CARD_MIRROR", "CARD_STUN"]:
		var carta: CardData = CardManager.create_card(clave, { "actual": 0, "max": 0 })
		assert_bool(carta.upgradeable()).is_false()
		carta.upgrade()
		assert_int(carta.nivel_actual).is_equal(0)


func test_diccionario_de_niveles_incompleto_usa_defaults() -> void:
	var vacia: CardData = CardManager.create_card("CARD_SWORD", {})
	assert_int(vacia.nivel_actual).is_equal(0)
	assert_int(vacia.nivel_max).is_equal(3)
	var parcial: CardData = CardManager.create_card("CARD_SWORD", { "actual": 2 })
	assert_int(parcial.nivel_actual).is_equal(2)
	assert_int(parcial.nivel_max).is_equal(3)