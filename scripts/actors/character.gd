extends Resource
class_name Character

signal hp_changed(nuevo_hp: int, es_jugador: bool)

var is_player: bool = true
var max_hp: int = 0
var current_hp: int = 0
var can_play_card: bool = true
var physical_defense: int = 0
var magical_rebound: bool = false
var deck: DeckData = null
var visual_deck: Array[Node2D] = []
var visual_hand: Array[Node2D] = []
var visual_discard: Array[Node2D] = []
var status: Array[StatusData] = []

# Setup

func _setup(params: Dictionary) -> void:
	set_deck(params.deck)
	set_initial_hp()

# HP management

func set_initial_hp() -> void:
	max_hp = deck.vida
	current_hp = max_hp

func set_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	emit_signal("hp_changed", current_hp, is_player)

# Status management

func apply_status_effects() -> void:
	for _status: StatusData in status:
		_status.apply_effect(self )
	if has_status("STATUS_STUN"):
		remove_status_by_name("STATUS_STUN")

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

func can_play() -> bool:
	return can_play_card

# Round management

func clear_visuals() -> void:
	for card: Node2D in visual_deck:
		card.queue_free()
	visual_deck.clear()
	for card: Node2D in visual_hand:
		card.queue_free()
	visual_hand.clear()


func reset_round() -> void:
	physical_defense = 0
	magical_rebound = false
	clear_visuals()
	status.clear()

func reset() -> void:
	reset_round()
	deck = null

# Deck management

func set_deck(new_deck: DeckData) -> void:
	deck = new_deck

func add_card_to_deck(card: CardData) -> void:
	var new_card: CardData = CardManager.create_card(card.nombre, {"actual": 0, "max": card.nivel_max})
	deck.cartas.append(new_card)

func remove_card_from_deck(index: int) -> void:
	deck.cartas.remove_at(index)

func upgrade_card_in_deck(index: int) -> void:
	deck.cartas[index].upgrade()

# Visual Hand management

func add_card_to_hand(card: Node2D) -> void:
	visual_hand.append(card)

func remove_card_from_hand(card: Node2D) -> void:
	visual_hand.erase(card)
	card.queue_free()

# Visual Deck management

func add_card_to_visual_deck(card: Node2D) -> void:
	visual_deck.append(card)

func remove_card_from_visual_deck(card: Node2D) -> void:
	visual_deck.erase(card)
	card.queue_free()

# Combat management

func reset_turn() -> void:
	magical_rebound = false
	physical_defense = 0
	if not has_status("STATUS_STUN"):
		can_play_card = true

func heal(amount: int) -> void:
	set_hp(current_hp + amount)

func add_armor(amount: int) -> void:
	physical_defense += amount

func add_rebound() -> void:
	magical_rebound = true

func remove_rebound() -> void:
	magical_rebound = false

func has_rebound() -> bool:
	return magical_rebound

func take_magical_damage(amount: int) -> void:
	set_hp(current_hp - amount)

func take_physical_damage(amount: int) -> void:
	var damage_after_armor: int = max(amount - physical_defense, 0)
	set_hp(current_hp - damage_after_armor)
	physical_defense = 0