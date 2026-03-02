extends CanvasLayer

@onready var shelf = $ItemShelf

func display_deck(deck_data: Array):
	for child in shelf.get_children():
		child.queue_free()
	
	var mazo = []
	for card_info in deck_data:
		var nueva_carta = GlobalData.create_card(card_info.tipo, card_info.datos)
		mazo.append(nueva_carta)
		
	shelf.mostrar_cartas(mazo)

func _on_close_button_pressed():
	queue_free()
