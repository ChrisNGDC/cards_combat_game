extends GdUnitTestSuite


func _personaje() -> Character:
	var personaje: Character = Character.new()
	personaje.set_deck(DeckManager.create_deck("DECK_FIGHTER"))
	personaje.set_initial_hp()
	return personaje


func test_set_hp_clampa_entre_cero_y_maximo() -> void:
	var personaje: Character = _personaje()
	personaje.set_hp(500)
	assert_int(personaje.current_hp).is_equal(100)
	personaje.set_hp(-10)
	assert_int(personaje.current_hp).is_equal(0)


func test_heal_no_supera_el_maximo() -> void:
	var personaje: Character = _personaje()
	personaje.set_hp(98)
	personaje.heal(10)
	assert_int(personaje.current_hp).is_equal(100)


func test_hp_changed_emite_con_argumentos_correctos() -> void:
	var personaje: Character = _personaje()
	# La señal debe emitirse despues de que is_emitted registre el collector
	var temporizador: SceneTreeTimer = get_tree().create_timer(0.1)
	temporizador.timeout.connect(func() -> void: personaje.set_hp(90))
	await assert_signal(personaje).is_emitted("hp_changed", 90, true)


func test_armadura_absorbe_danio_fisico_y_se_consume() -> void:
	var personaje: Character = _personaje()
	personaje.add_armor(10)
	personaje.take_physical_damage(15)
	assert_int(personaje.current_hp).is_equal(95)
	assert_int(personaje.physical_defense).is_equal(0)


func test_armadura_se_consume_incluso_con_danio_cero() -> void:
	var personaje: Character = _personaje()
	personaje.add_armor(10)
	personaje.take_physical_damage(0)
	assert_int(personaje.current_hp).is_equal(100)
	assert_int(personaje.physical_defense).is_equal(0)


func test_danio_magico_ignora_armadura() -> void:
	var personaje: Character = _personaje()
	personaje.add_armor(10)
	personaje.take_magical_damage(10)
	assert_int(personaje.current_hp).is_equal(90)
	assert_int(personaje.physical_defense).is_equal(10)


func test_rebound_agregar_quitar_consultar() -> void:
	var personaje: Character = _personaje()
	assert_bool(personaje.has_rebound()).is_false()
	personaje.add_rebound()
	assert_bool(personaje.has_rebound()).is_true()
	personaje.remove_rebound()
	assert_bool(personaje.has_rebound()).is_false()


func test_reset_turn_limpia_defensas_y_quita_un_stun() -> void:
	var personaje: Character = _personaje()
	personaje.add_armor(10)
	personaje.add_rebound()
	personaje.add_status(StatusManager.create_status("STATUS_STUN"))
	personaje.can_play_card = false
	personaje.reset_turn()
	assert_int(personaje.physical_defense).is_equal(0)
	assert_bool(personaje.has_rebound()).is_false()
	assert_bool(personaje.can_play_card).is_true()
	assert_bool(personaje.has_status("STATUS_STUN")).is_false()


func test_reset_turn_con_dos_stun_solo_quita_uno() -> void:
	var personaje: Character = _personaje()
	personaje.add_status(StatusManager.create_status("STATUS_STUN"))
	personaje.add_status(StatusManager.create_status("STATUS_STUN"))
	personaje.can_play_card = false
	personaje.reset_turn()
	assert_bool(personaje.can_play_card).is_true()
	assert_bool(personaje.has_status("STATUS_STUN")).is_true()
	assert_int(personaje.status_effects.size()).is_equal(1)


func test_estados_apilados_se_aplican_todos() -> void:
	var personaje: Character = _personaje()
	personaje.last_card_played = CardManager.create_card("CARD_SWORD", { "actual": 0, "max": 3 })
	personaje.add_status(StatusManager.create_status("STATUS_BURN"))
	personaje.add_status(StatusManager.create_status("STATUS_BURN"))
	personaje.apply_status_effects()
	assert_int(personaje.current_hp).is_equal(90)


func test_remove_status_by_name_quita_solo_el_primero() -> void:
	var personaje: Character = _personaje()
	personaje.add_status(StatusManager.create_status("STATUS_BURN"))
	personaje.add_status(StatusManager.create_status("STATUS_BURN"))
	personaje.remove_status_by_name("STATUS_BURN")
	assert_int(personaje.status_effects.size()).is_equal(1)


func test_has_status_con_lista_vacia() -> void:
	var personaje: Character = _personaje()
	assert_bool(personaje.has_status("STATUS_BURN")).is_false()


func test_reset_round_limpia_estado_y_arrays_visuales() -> void:
	var personaje: Character = _personaje()
	var carta: Node2D = auto_free(load("res://scenes/card.tscn").instantiate())
	add_child(carta)
	carta.setup(CardManager.create_card("CARD_SWORD", { "actual": 0, "max": 3 }), true)
	personaje.visual_hand.append(carta)
	personaje.add_status(StatusManager.create_status("STATUS_BURN"))
	personaje.add_armor(5)
	personaje.reset_round()
	assert_int(personaje.status_effects.size()).is_equal(0)
	assert_int(personaje.physical_defense).is_equal(0)
	assert_int(personaje.visual_hand.size()).is_equal(0)
	assert_int(personaje.visual_deck.size()).is_equal(0)
	assert_object(personaje.deck).is_not_null()


func test_reset_ademas_deja_deck_null() -> void:
	var personaje: Character = _personaje()
	personaje.reset()
	assert_object(personaje.deck).is_null()