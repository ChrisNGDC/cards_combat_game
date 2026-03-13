extends Resource
class_name GamePlayer

signal hp_changed(nuevo_hp: int, es_jugador: bool)

var max_hp: int = 100
var current_hp: int = 100:
	set(val):
		current_hp = clamp(val, 0, max_hp)
		hp_changed.emit(current_hp, true)
var damage_to_receive: int = 0
var deck: BaseDeck = FighterDeck.new()
var visual_deck: Array[Node2D] = []
var visual_hand: Array[Node2D] = []

func set_initial_hp() -> void:
	max_hp = deck.vida
	current_hp = max_hp

func take_damage() -> void:
	current_hp -= damage_to_receive
	damage_to_receive = 0

func reset() -> void:
	damage_to_receive = 0
	deck = null
	visual_deck.clear()
	visual_hand.clear()

func add_card_to_deck(card: BaseCard) -> void:
	var new_card: BaseCard = GlobalData.create_card(card.nombre, [0, card.nivel_max])
	deck.cartas.append(new_card)

func remove_card_from_deck(index: int) -> void:
	deck.cartas.remove_at(index)

func upgrade_card_in_deck(index: int) -> void:
	deck.cartas[index].upgrade()