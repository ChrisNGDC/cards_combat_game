extends GdUnitTestSuite


func before() -> void:
	GlobalData.reset_game()
	GlobalData.player._setup({ "deck": DeckManager.create_deck("DECK_FIGHTER") })


func after() -> void:
	GlobalData.reset_game()


func _carta(nombre: String, es_jugador: bool) -> Node2D:
	var carta: Node2D = auto_free(load("res://scenes/card.tscn").instantiate())
	add_child(carta)
	carta.setup(CardManager.create_card(nombre, { "actual": 0, "max": 3 }), es_jugador)
	return carta


func _cpu(dificultad: String) -> GameCPU:
	var cpu: GameCPU = GameCPU.new()
	cpu._setup({ "deck": DeckManager.create_deck("DECK_MAGE"), "difficulty": dificultad })
	return cpu


func _mazo_sin_mejorables() -> DeckData:
	var cartas: Array[CardData] = [
		CardManager.create_card("CARD_MIRROR", { "actual": 0, "max": 0 }),
		CardManager.create_card("CARD_STUN", { "actual": 0, "max": 0 }),
	]
	return DeckData.new({ "nombre": "DECK_TEST", "ruta_imagen": "", "vida": 100 }, cartas)


func test_pick_card_con_mano_vacia_devuelve_null() -> void:
	var cpu: GameCPU = _cpu("EASY_DIFFICULTY")
	assert_object(cpu.pick_card()).is_null()


func test_easy_elige_un_elemento_de_la_mano() -> void:
	seed(42)
	var cpu: GameCPU = _cpu("EASY_DIFFICULTY")
	cpu.visual_hand.append(_carta("CARD_SWORD", false))
	cpu.visual_hand.append(_carta("CARD_SHIELD", false))
	var elegida: Node2D = cpu.pick_card()
	assert_array(cpu.visual_hand).contains(elegida)


func test_normal_elige_la_primera_coincidente_con_cards_to_play() -> void:
	var cpu: GameCPU = _cpu("NORMAL_DIFFICULTY")
	var espada: Node2D = _carta("CARD_SWORD", false)
	var escudo: Node2D = _carta("CARD_SHIELD", false)
	cpu.visual_hand.append(espada)
	cpu.visual_hand.append(escudo)
	cpu.pick_card_logic.cards_to_play.assign(["CARD_SHIELD", "CARD_SWORD"])
	assert_object(cpu.pick_card()).is_same(escudo)


func test_normal_sin_coincidencias_cae_a_aleatorio() -> void:
	seed(42)
	var cpu: GameCPU = _cpu("NORMAL_DIFFICULTY")
	cpu.visual_hand.append(_carta("CARD_SWORD", false))
	cpu.visual_hand.append(_carta("CARD_SHIELD", false))
	cpu.pick_card_logic.cards_to_play.assign(["CARD_MAGIC"])
	assert_array(cpu.visual_hand).contains(cpu.pick_card())


func test_hard_elige_un_elemento_de_la_mano() -> void:
	var cpu: GameCPU = _cpu("HARD_DIFFICULTY")
	GlobalData.player.visual_hand.append(_carta("CARD_SWORD", true))
	GlobalData.player.visual_hand.append(_carta("CARD_SHIELD", true))
	cpu.visual_hand.append(_carta("CARD_MAGIC", false))
	cpu.visual_hand.append(_carta("CARD_MIRROR", false))
	assert_array(cpu.visual_hand).contains(cpu.pick_card())


func test_choose_card_to_upgrade_sin_mejorables_devuelve_menos_uno() -> void:
	var cpu: GameCPU = GameCPU.new()
	cpu._setup({ "deck": _mazo_sin_mejorables(), "difficulty": "EASY_DIFFICULTY" })
	assert_int(cpu.choose_card_to_upgrade()).is_equal(-1)


func test_choose_card_to_upgrade_devuelve_indice_mejorable() -> void:
	var cpu: GameCPU = _cpu("EASY_DIFFICULTY")
	cpu.set_deck(DeckManager.create_deck("DECK_FIGHTER"))
	var indice: int = cpu.choose_card_to_upgrade()
	assert_int(indice).is_between(0, cpu.deck.cartas.size() - 1)
	assert_bool(cpu.deck.cartas[indice].upgradeable()).is_true()


func test_operaciones_con_mazo_vacio_no_fallan() -> void:
	var cpu: GameCPU = GameCPU.new()
	var mazo_vacio: DeckData = DeckData.new({ "nombre": "DECK_TEST", "ruta_imagen": "", "vida": 100 }, [])
	cpu._setup({ "deck": mazo_vacio, "difficulty": "EASY_DIFFICULTY" })
	cpu.add_card_to_deck()
	cpu.remove_card_from_deck()
	cpu.upgrade_card_in_deck()
	assert_int(cpu.deck.cartas.size()).is_equal(0)
	assert_int(cpu.choose_card_to_upgrade()).is_equal(-1)


func test_normal_inicializa_cards_power_desde_el_mazo_del_jugador() -> void:
	var cpu: GameCPU = _cpu("NORMAL_DIFFICULTY")
	assert_bool(cpu.pick_card_logic.cards_power.is_empty()).is_false()
	assert_bool(cpu.pick_card_logic.cards_to_play.is_empty()).is_false()