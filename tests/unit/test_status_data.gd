extends GdUnitTestSuite


func _datos_estado(efecto: Callable) -> Dictionary:
	return {
		"nombre": "STATUS_TEST",
		"ruta_imagen": "res://images/combat/stun.png",
		"description": "STATUS_STUN_DESC",
		"effect": efecto,
	}


func test_init_aplica_datos() -> void:
	var estado: StatusData = StatusData.new(_datos_estado(Callable()))
	assert_str(estado.nombre).is_equal("STATUS_TEST")
	assert_str(estado.image).is_equal("res://images/combat/stun.png")
	assert_str(estado.description).is_equal("STATUS_STUN_DESC")


func test_apply_effect_invoca_callable() -> void:
	var personaje: Character = Character.new()
	var estado: StatusData = StatusData.new(_datos_estado(func(c: Character) -> void: c.can_play_card = false))
	estado.apply_effect(personaje)
	assert_bool(personaje.can_play_card).is_false()


func test_apply_effect_con_callable_invalido_no_falla() -> void:
	var personaje: Character = Character.new()
	var estado: StatusData = StatusData.new(_datos_estado(Callable()))
	estado.apply_effect(personaje)
	assert_bool(personaje.can_play_card).is_true()