extends Resource
class_name GameCPU

signal hp_changed(nuevo_hp: int, es_jugador: bool)

var max_hp: int = 100
var current_hp: int = 100:
	set(val):
		current_hp = clamp(val, 0, max_hp)
		hp_changed.emit(current_hp, false)
var damage_to_receive: int = 0
var deck: BaseDeck = FighterDeck.new()
var visual_deck: Array[Node2D] = []
var visual_hand: Array[Node2D] = []
@export_enum("EASY_DIFFICULTY", "NORMAL_DIFFICULTY", "HARD_DIFFICULTY") var difficulty: String = "EASY_DIFFICULTY"

func set_initial_hp() -> void:
	max_hp = deck.vida
	current_hp = max_hp

func take_damage() -> void:
	current_hp -= damage_to_receive
	damage_to_receive = 0


func pick_card() -> Node2D:
	match difficulty:
		"HARD_DIFFICULTY":
			return pick_hard_card()
		"NORMAL_DIFFICULTY":
			return pick_medium_card()
		"EASY_DIFFICULTY", _:
			return pick_easy_card()
		

# Pick a random card
func pick_easy_card() -> Node2D:
	var card_index: int = randi() % visual_hand.size()
	return visual_hand[card_index]

# Take into account the player's deck composition
func pick_medium_card() -> Node2D:
	if GlobalData.player.deck.cartas.size() == 0:
		print("Player deck is empty, picking random card")
	var card_index: int = randi() % visual_hand.size()
	return visual_hand[card_index]

# Take into account the amount of each card in the player's hand
func pick_hard_card() -> Node2D:
	if GlobalData.player.visual_hand.size() == 0:
		print("Player hand is empty, picking random card")
	var card_index: int = randi() % visual_hand.size()
	return visual_hand[card_index]


func reset() -> void:
	damage_to_receive = 0
	deck = null
	visual_deck.clear()
	visual_hand.clear()

func add_card_to_deck() -> void:
	var card: BaseCard = deck.cartas.pick_random()
	var new_card: BaseCard = GlobalData.create_card(card.nombre, [0, card.nivel_max])
	deck.cartas.append(new_card)

func remove_card_from_deck() -> void:
	var index: int = randi() % GlobalData.cpu.deck.cartas.size()
	deck.cartas.remove_at(index)

func choose_card_to_upgrade() -> int:
	var card_pos: int = randi() % deck.cartas.size()
	while not deck.cartas[card_pos].upgradeable():
		card_pos = randi() % deck.cartas.size()
	return card_pos

func upgrade_card_in_deck() -> void:
	var index: int = GlobalData.cpu.choose_card_to_upgrade()
	deck.cartas[index].upgrade()
