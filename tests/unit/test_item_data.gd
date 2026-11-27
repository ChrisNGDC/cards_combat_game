extends GdUnitTestSuite


func _datos() -> Dictionary:
	return {
		"nombre": "ITEM_TEST",
		"ruta_imagen": "res://images/items/test.png",
		"description": "ITEM_TEST_DESC",
		"apilable": false,
		"bonos": { "SWORD_DAMAGE": 3 },
		"descripcion_valor": 3,
	}


func test_init_popula_campos() -> void:
	var item: ItemData = ItemData.new(_datos())
	assert_str(item.nombre).is_equal("ITEM_TEST")
	assert_str(item.ruta_imagen).is_equal("res://images/items/test.png")
	assert_str(item.description).is_equal("ITEM_TEST_DESC")
	assert_bool(item.apilable).is_false()
	assert_int(item.descripcion_valor).is_equal(3)


func test_get_bono_devuelve_valor() -> void:
	var item: ItemData = ItemData.new(_datos())
	assert_int(item.get_bono("SWORD_DAMAGE")).is_equal(3)


func test_get_bono_clave_ausente_devuelve_cero() -> void:
	var item: ItemData = ItemData.new(_datos())
	assert_int(item.get_bono("MAGIC_DAMAGE")).is_equal(0)


func test_sin_bonos_ni_efecto_usa_defaults() -> void:
	var datos: Dictionary = _datos()
	datos.erase("bonos")
	var item: ItemData = ItemData.new(datos)
	assert_int(item.get_bono("SWORD_DAMAGE")).is_equal(0)
	assert_bool(item.efecto_adquisicion.is_valid()).is_false()
