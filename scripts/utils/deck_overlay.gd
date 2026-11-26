extends CanvasLayer

signal closing

@onready var shelf: HFlowContainer = $MarginContainer/VBoxContainer/ItemShelf
@onready var deck_name: Label = $MarginContainer/VBoxContainer/DeckName
@onready var close_button: Button = $MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)


func update_name(new_name: String) -> void:
	deck_name.get_node("AutoTranslate").set_translation(new_name)


func display_history_deck(deck_data: Dictionary) -> void:
	var cartas: Array[CardData] = []
	for card_info: Dictionary in deck_data.cards:
		var nueva_carta: CardData = CardManager.create_card(card_info.tipo, card_info.niveles)
		if nueva_carta == null:
			push_warning("Unknown card type in saved deck: " + str(card_info.tipo))
			continue
		cartas.append(nueva_carta)
	
	update_name(deck_data.name)
	shelf.mostrar_cartas(cartas)


func display_deck_data(deck_data: Array[CardData]) -> void:
	shelf.mostrar_cartas(deck_data)


func display_deck(deck: Array[Node2D]) -> void:
	var deck_data: Array[CardData] = []
	for card: Node2D in deck:
		deck_data.append(card.datos_carta)
	deck_data.shuffle()

	shelf.mostrar_cartas(deck_data)


func _on_close_button_pressed() -> void:
	closing.emit()
	queue_free()