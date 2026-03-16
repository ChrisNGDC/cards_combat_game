extends CanvasLayer

@onready var shelf: HFlowContainer = $MarginContainer/VBoxContainer/ItemShelf
signal closing

func display_history_deck(deck_data: Array[Dictionary]) -> void:
	for child: Control in shelf.get_children():
		child.queue_free()
	
	var mazo: Array[CardData] = []
	for card_info: Dictionary in deck_data:
		var nueva_carta: CardData = CardManager.create_card(card_info.tipo, card_info.niveles)
		mazo.append(nueva_carta)
		
	shelf.mostrar_cartas(mazo)

func display_deck(deck_data: Array[CardData]) -> void:
	for child: Control in shelf.get_children():
		child.queue_free()
		
	shelf.mostrar_cartas(deck_data)


func _on_close_button_pressed() -> void:
	closing.emit()
	queue_free()
