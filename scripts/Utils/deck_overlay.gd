extends CanvasLayer

@onready var shelf: HFlowContainer = $MarginContainer/VBoxContainer/ItemShelf
@onready var deck_name: Label = $MarginContainer/VBoxContainer/DeckName
signal closing

func update_name(new_name: String) -> void:
	deck_name.text = new_name

func display_history_deck(deck_data: Dictionary) -> void:
	for child: Control in shelf.get_children():
		child.queue_free()
	

	var cartas: Array[CardData] = []
	for card_info: Dictionary in deck_data.cards:
		var nueva_carta: CardData = CardManager.create_card(card_info.tipo, card_info.niveles)
		cartas.append(nueva_carta)
	
	update_name(deck_data.name)
	shelf.mostrar_cartas(cartas)

func display_deck(deck_data: Array[CardData]) -> void:
	for child: Control in shelf.get_children():
		child.queue_free()
		
	shelf.mostrar_cartas(deck_data)


func _on_close_button_pressed() -> void:
	closing.emit()
	queue_free()
