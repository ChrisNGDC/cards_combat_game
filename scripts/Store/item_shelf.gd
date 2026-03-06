extends HFlowContainer

var card_scene = preload("res://escenes/card.tscn")
var mazo
var selected_card_data = null
var current_selected_wrapper = null
var selected_card_index: int = -1


func _ready() -> void:
	mazo = GlobalData.player_deck.cartas
	mostrar_cartas()


func mostrar_cartas():
	for child in get_children():
		child.queue_free()

	for i in range(mazo.size()):
		var wrapper = Control.new()
		wrapper.custom_minimum_size = Vector2(150, 200)
		wrapper.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(wrapper)

		var bg = ColorRect.new()
		bg.name = "SelectionBG"
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.color = Color(0, 0, 0, 0.5)
		bg.visible = false
		bg.mouse_filter = Control.MOUSE_FILTER_PASS
		wrapper.add_child(bg)

		var nueva_carta = card_scene.instantiate()
		wrapper.add_child(nueva_carta)
		nueva_carta.setup(mazo[i], true)
		nueva_carta.show_card(true)
		nueva_carta.dar_borde()
		nueva_carta.position = wrapper.custom_minimum_size / 2

		wrapper.gui_input.connect(_on_slot_gui_input.bind(wrapper, nueva_carta, mazo[i], i))


func seleccionar_carta(slot, card_node, data, index):
	if current_selected_wrapper and current_selected_wrapper != slot:
		deseleccionar(current_selected_wrapper)

	selected_card_data = data
	current_selected_wrapper = slot
	selected_card_index = index
	card_node.selected = true

	slot.get_node("SelectionBG").visible = true

	card_node.apply_scale_tween(card_node.escala_grande)


func deseleccionar(slot):
	slot.get_node("SelectionBG").visible = false
	var card = slot.get_child(1)
	card.selected = false
	card.apply_scale_tween(card.escala_normal)


func _on_slot_gui_input(event: InputEvent, slot: Control, card_node: Node2D, data, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		seleccionar_carta(slot, card_node, data, index)
