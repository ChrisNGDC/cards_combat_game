extends Resource
class_name GameCPU

signal hp_changed(nuevo_hp: int, es_jugador: bool)

var max_hp: int
var current_hp: int:
	set(val):
		current_hp = clamp(val, 0, max_hp)
		hp_changed.emit(current_hp, false)
var damage_to_receive: int = 0
var deck: DeckData
var visual_deck: Array[Node2D] = []
var visual_hand: Array[Node2D] = []
@export_enum("EASY_DIFFICULTY", "NORMAL_DIFFICULTY", "HARD_DIFFICULTY") var difficulty: String = "EASY_DIFFICULTY"
var pick_card_logic: PickCardLogic = PickCardLogic.new()
var stunned: bool = false

func _setup() -> void:
	set_initial_hp()
	if difficulty == "NORMAL_DIFFICULTY":
		pick_card_logic.get_cards_by_power(GlobalData.player.deck.cartas)


func set_initial_hp() -> void:
	max_hp = deck.vida
	current_hp = max_hp

func take_damage() -> void:
	current_hp -= damage_to_receive
	damage_to_receive = 0

func reset_round() -> void:
	visual_deck.clear()
	visual_hand.clear()

func pick_card() -> Node2D:
	if visual_hand.size() == 0:
		return null
	match difficulty:
		"HARD_DIFFICULTY":
			# Take into account the player's hand
			var hand: Array[CardData] = pick_card_logic.convert_hand(GlobalData.player.visual_hand)
			pick_card_logic.get_cards_by_power(hand)
			return pick_complex_card()
		"NORMAL_DIFFICULTY":
			# Take into account the player's deck composition
			return pick_complex_card()
		"EASY_DIFFICULTY", _:
			# Pick a random card from the hand
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


func reset() -> void:
	damage_to_receive = 0
	deck = null
	visual_deck.clear()
	visual_hand.clear()

func add_card_to_deck() -> void:
	var card: CardData = deck.cartas.pick_random()
	var new_card: CardData = CardManager.create_card(card.nombre, {"actual": 0, "max": card.nivel_max})
	deck.cartas.append(new_card)

func remove_card_from_deck() -> void:
	var index: int = randi() % deck.cartas.size()
	deck.cartas.remove_at(index)

func choose_card_to_upgrade() -> int:
	var card_pos: int = randi() % deck.cartas.size()
	while not deck.cartas[card_pos].upgradeable():
		card_pos = randi() % deck.cartas.size()
	return card_pos

func upgrade_card_in_deck() -> void:
	var index: int = choose_card_to_upgrade()
	deck.cartas[index].upgrade()
