extends CanvasLayer

@onready var shelf: HFlowContainer = $ItemShelf

func display_deck(deck_data: Array) -> void:
	for child: Control in shelf.get_children():
		child.queue_free()
	
	var mazo: Array = []
	for card_info: Dictionary in deck_data:
		var nueva_carta: BaseCard = GlobalData.create_card(card_info.tipo, card_info.datos)
		mazo.append(nueva_carta)
		
	shelf.mostrar_cartas(mazo)

func _on_close_button_pressed() -> void:
	queue_free()
