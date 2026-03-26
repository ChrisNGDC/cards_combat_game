extends Resource
class_name GamePlayer

signal hp_changed(nuevo_hp: int, es_jugador: bool)

var max_hp: int
var current_hp: int:
	set(val):
		current_hp = clamp(val, 0, max_hp)
		hp_changed.emit(current_hp, true)
var damage_to_receive: int = 0
var deck: DeckData = DeckManager.create_deck("DECK_MAGE")
var visual_deck: Array[Node2D] = []
var visual_hand: Array[Node2D] = []
var status: Array[StatusData] = []

func set_initial_hp() -> void:
	max_hp = deck.vida
	current_hp = max_hp

func take_damage() -> void:
	current_hp -= damage_to_receive
	damage_to_receive = 0

func reset_round() -> void:
	visual_deck.clear()
	visual_hand.clear()

func add_status(new_status: StatusData) -> void:
	status.append(new_status)

func remove_status_by_name(old_status_name: String) -> void:
	for _status: StatusData in status:
		if _status.nombre == old_status_name:
			status.erase(_status)
			return


func has_status(status_name: String) -> bool:
	for _status: StatusData in status:
		if _status.nombre == status_name:
			return true
	return false

func reset() -> void:
	damage_to_receive = 0
	deck = null
	visual_deck.clear()
	visual_hand.clear()

func add_card_to_deck(card: CardData) -> void:
	var new_card: CardData = CardManager.create_card(card.nombre, {"actual": 0, "max": card.nivel_max})
	deck.cartas.append(new_card)

func remove_card_from_deck(index: int) -> void:
	deck.cartas.remove_at(index)

func upgrade_card_in_deck(index: int) -> void:
	deck.cartas[index].upgrade()