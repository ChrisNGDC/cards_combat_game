extends HFlowContainer

var card_scene: PackedScene = preload("res://scenes/card.tscn")

func mostrar_cartas(mazo: Array) -> void:
	for child: Node in get_children():
		child.queue_free()
	
	for carta: CardData in mazo:
		var wrapper: Control = Control.new()
		wrapper.custom_minimum_size = Vector2(150, 200)
		wrapper.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(wrapper)
		
		var nueva_carta: Node2D = card_scene.instantiate()
		wrapper.add_child(nueva_carta)
		nueva_carta.setup(carta, true)
		nueva_carta.show_card(true)
		nueva_carta.dar_borde()
		nueva_carta.position = wrapper.custom_minimum_size / 2
