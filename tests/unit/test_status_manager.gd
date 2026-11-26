extends GdUnitTestSuite


func _personaje() -> Character:
	var personaje: Character = Character.new()
	personaje.set_deck(DeckManager.create_deck("DECK_FIGHTER"))
	personaje.set_initial_hp()
	return personaje


func test_clave_desconocida_devuelve_null() -> void:
	assert_object(StatusManager.create_status("STATUS_UNKNOWN")).is_null()


func test_constantes_son_fuente_unica_de_verdad() -> void:
	assert_int(StatusManager.BURN_DAMAGE).is_equal(5)
	assert_int(StatusManager.REGENERATION_HEAL).is_equal(5)


func test_stun_impide_jugar_carta() -> void:
	var personaje: Character = _personaje()
	var estado: StatusData = StatusManager.create_status("STATUS_STUN")
	assert_str(estado.nombre).is_equal("STATUS_STUN")
	estado.apply_effect(personaje)
	assert_bool(personaje.can_play_card).is_false()


func test_burn_solo_dania_si_la_ultima_carta_fue_ofensiva() -> void:
	var personaje: Character = _personaje()
	var burn: StatusData = StatusManager.create_status("STATUS_BURN")
	burn.apply_effect(personaje)
	assert_int(personaje.current_hp).is_equal(100)
	personaje.last_card_played = CardManager.create_card("CARD_SHIELD", { "actual": 0, "max": 3 })
	burn.apply_effect(personaje)
	assert_int(personaje.current_hp).is_equal(100)
	personaje.last_card_played = CardManager.create_card("CARD_SWORD", { "actual": 0, "max": 3 })
	burn.apply_effect(personaje)
	assert_int(personaje.current_hp).is_equal(95)


func test_regeneration_cura_sin_pasar_del_maximo() -> void:
	var personaje: Character = _personaje()
	var regen: StatusData = StatusManager.create_status("STATUS_REGENERATION")
	personaje.set_hp(90)
	regen.apply_effect(personaje)
	assert_int(personaje.current_hp).is_equal(95)
	regen.apply_effect(personaje)
	regen.apply_effect(personaje)
	assert_int(personaje.current_hp).is_equal(100)