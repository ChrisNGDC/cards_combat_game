extends "res://scripts/utils/item_shelf.gd"


# --- State Variables ---
var mazo: Array[CardData] = []
var selected_card_data: CardData = null
var current_selected_wrapper: Control = null
var selected_card_index: int = -1


# --- Virtual Methods ---
func _ready() -> void:
	wrapper_size = Vector2(130, 180)
	mazo = GlobalData.player.deck.cartas
	mostrar_cartas()


# --- Signal Callbacks ---
func _on_slot_gui_input(event: InputEvent, slot: Control, card_node: Node2D, data: CardData, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		seleccionar_carta(slot, card_node, data, index)


# --- Card Management Logic ---
func mostrar_cartas(cartas: Array[CardData] = []) -> void:
	if cartas.is_empty():
		cartas = mazo
	super(cartas)


func _crear_wrapper(carta: CardData, index: int) -> Control:
	var wrapper: Control = super(carta, index)
	var card_node: Node2D = wrapper.get_child(0)

	var bg: ColorRect = ColorRect.new()
	bg.name = "SelectionBG"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.5)
	bg.visible = false
	bg.mouse_filter = Control.MOUSE_FILTER_PASS
	wrapper.add_child(bg)
	wrapper.move_child(bg, 0)

	wrapper.gui_input.connect(_on_slot_gui_input.bind(wrapper, card_node, carta, index))
	return wrapper


func seleccionar_carta(slot: Control, card_node: Node2D, data: CardData, index: int) -> void:
	if current_selected_wrapper == slot:
		return

	if current_selected_wrapper:
		deseleccionar(current_selected_wrapper)

	selected_card_data = data
	current_selected_wrapper = slot
	selected_card_index = index
	card_node.selected = true

	slot.get_node("SelectionBG").visible = true
	card_node._on_area_2d_mouse_entered()


func deseleccionar(slot: Control) -> void:
	slot.get_node("SelectionBG").visible = false

	for node: Node in get_tree().get_nodes_in_group("cards"):
		var card: Node2D = node as Node2D
		if card.get_parent() == slot:
			card.selected = false
			card._on_area_2d_mouse_exited()
			break