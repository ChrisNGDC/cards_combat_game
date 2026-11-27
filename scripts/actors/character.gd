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
var last_card_played: CardData = null
var visual_deck: Array[Node2D] = []
var visual_hand: Array[Node2D] = []
var status_effects: Array[StatusData] = []
var items: Array[ItemData] = []


func _setup(params: Dictionary) -> void:
	set_deck(params.deck)
	set_initial_hp()


func set_initial_hp() -> void:
	max_hp = deck.vida
	current_hp = max_hp


func set_hp(value: int) -> void:
	current_hp = clamp(value, 0, max_hp)
	hp_changed.emit(current_hp, is_player)


func apply_status_effects() -> void:
	var regen: int = get_item_bonus("EXCHANGE_HEAL")
	if regen > 0:
		heal(regen)
	for status: StatusData in status_effects:
		status.apply_effect(self)


func add_status(new_status: StatusData) -> void:
	status_effects.append(new_status)


func remove_status_by_name(old_status_name: String) -> void:
	for status: StatusData in status_effects:
		if status.nombre == old_status_name:
			status_effects.erase(status)
			return


func has_status(status_name: String) -> bool:
	for status: StatusData in status_effects:
		if status.nombre == status_name:
			return true
	return false


func add_item(item: ItemData) -> void:
	items.append(item)
	if item.efecto_adquisicion.is_valid():
		item.efecto_adquisicion.call(self)


func has_item(nombre_item: String) -> bool:
	for item: ItemData in items:
		if item.nombre == nombre_item:
			return true
	return false


func get_item_bonus(clave: String) -> int:
	var total: int = 0
	for item: ItemData in items:
		total += item.get_bono(clave)
	return total


func can_play() -> bool:
	return can_play_card


func clear_visuals() -> void:
	for card: Node2D in visual_deck:
		if card != null and not card.is_queued_for_deletion():
			card.queue_free()
	visual_deck.clear()
	for card: Node2D in visual_hand:
		if card != null and not card.is_queued_for_deletion():
			card.queue_free()
	visual_hand.clear()


func reset_round() -> void:
	physical_defense = 0
	magical_rebound = false
	last_card_played = null
	can_play_card = true
	clear_visuals()
	status_effects.clear()


func reset() -> void:
	reset_round()
	deck = null
	items.clear()


func set_deck(new_deck: DeckData) -> void:
	deck = new_deck


func add_card_to_deck(card: CardData) -> void:
	var new_card: CardData = CardManager.create_card(card.nombre, { "actual": 0, "max": card.nivel_max })
	deck.cartas.append(new_card)


func remove_card_from_deck(index: int) -> void:
	deck.cartas.remove_at(index)


func upgrade_card_in_deck(index: int) -> void:
	deck.cartas[index].upgrade()


func reset_turn() -> void:
	magical_rebound = false
	physical_defense = 0
	if not can_play_card and has_status("STATUS_STUN"):
		can_play_card = true
		remove_status_by_name("STATUS_STUN")


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
