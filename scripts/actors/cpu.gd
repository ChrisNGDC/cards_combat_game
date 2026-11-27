extends Character

class_name GameCPU

@export_enum("EASY_DIFFICULTY", "NORMAL_DIFFICULTY", "HARD_DIFFICULTY") var difficulty: String
var pick_card_logic: PickCardLogic = PickCardLogic.new()


func _setup(params: Dictionary) -> void:
	super({ "deck": params.deck })
	is_player = false
	setup_difficulty(params.difficulty)


func setup_difficulty(new_difficulty: String) -> void:
	difficulty = new_difficulty
	if new_difficulty == "NORMAL_DIFFICULTY":
		pick_card_logic.get_cards_by_power(GlobalData.player.deck.cartas)


func pick_card() -> Node2D:
	if visual_hand.size() == 0:
		return null
	match difficulty:
		"HARD_DIFFICULTY":
			var hand: Array[CardData] = pick_card_logic.convert_hand(GlobalData.player.visual_hand)
			pick_card_logic.get_cards_by_power(hand)
			return pick_complex_card()
		"NORMAL_DIFFICULTY":
			# Take into account the player's deck composition
			return pick_complex_card()
		"EASY_DIFFICULTY", _:
			return pick_easy_card()


func pick_easy_card() -> Node2D:
	var card_index: int = randi() % visual_hand.size()
	return visual_hand[card_index]


func pick_complex_card() -> Node2D:
	var card_index: int
	for card_name: String in pick_card_logic.cards_to_play:
		for card: Node2D in visual_hand:
			if card.datos_carta.nombre == card_name:
				card_index = visual_hand.find(card)
				return visual_hand[card_index]
	return pick_easy_card()


func add_card_to_deck(_card: CardData = null) -> void:
	if deck.cartas.is_empty():
		return
	var card: CardData = deck.cartas.pick_random()
	super(card)


func remove_card_from_deck(_index: int = -1) -> void:
	if deck.cartas.is_empty():
		return
	var index: int = randi() % deck.cartas.size()
	super(index)


func choose_card_to_upgrade() -> int:
	var upgradeables: Array[int] = []
	for i: int in range(deck.cartas.size()):
		if deck.cartas[i].upgradeable():
			upgradeables.append(i)
	if upgradeables.is_empty():
		return -1
	return upgradeables.pick_random()


func upgrade_card_in_deck(_index: int = -1) -> void:
	var index: int = choose_card_to_upgrade()
	if index == -1:
		return
	super(index)


func pick_item() -> ItemData:
	var oferta: Array[ItemData] = ItemManager.get_oferta(self)
	if oferta.is_empty():
		return null
	return oferta.pick_random()
