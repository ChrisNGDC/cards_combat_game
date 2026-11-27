extends ItemShelf


const ITEM_TOOLTIP_SCENE: PackedScene = preload("res://scenes/item_tooltip.tscn")

signal item_selected(item: ItemData)

var mazo: Array[CardData] = []
var selected_card_data: CardData = null
var current_selected_wrapper: Control = null
var selected_card_index: int = -1
var current_item_tooltip: PanelContainer = null
var hovered_item_wrapper: Control = null


func _ready() -> void:
	wrapper_size = Vector2(130, 180)
	mazo = GlobalData.player.deck.cartas
	mostrar_cartas()
	tree_exited.connect(_limpiar_tooltip_item)


func _process(_delta: float) -> void:
	if current_item_tooltip and hovered_item_wrapper:
		TooltipFollower.follow(current_item_tooltip, hovered_item_wrapper, Vector2(20, 20))


func _on_slot_gui_input(event: InputEvent, slot: Control, card_node: Node2D, data: CardData, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		seleccionar_carta(slot, card_node, data, index)


func mostrar_cartas(cartas: Array[CardData] = []) -> void:
	if cartas.is_empty():
		cartas = mazo
	selected_card_data = null
	selected_card_index = -1
	current_selected_wrapper = null
	super(cartas)


func mostrar_items(items: Array[ItemData]) -> void:
	for child: Node in get_children():
		child.queue_free()
	selected_card_data = null
	selected_card_index = -1
	current_selected_wrapper = null
	for i: int in range(items.size()):
		_crear_wrapper_item(items[i], i)


func _crear_wrapper_item(item: ItemData, _index: int) -> Control:
	var wrapper: Control = Control.new()
	wrapper.custom_minimum_size = wrapper_size
	wrapper.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(wrapper)

	var imagen: TextureRect = TextureRect.new()
	imagen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(item.ruta_imagen):
		imagen.texture = load(item.ruta_imagen)
	imagen.mouse_filter = Control.MOUSE_FILTER_PASS
	wrapper.add_child(imagen)

	wrapper.gui_input.connect(_on_item_gui_input.bind(item))
	wrapper.mouse_entered.connect(_on_item_mouse_entered.bind(wrapper, item))
	wrapper.mouse_exited.connect(_on_item_mouse_exited.bind(wrapper))
	wrapper.tree_exited.connect(_on_item_wrapper_tree_exited.bind(wrapper))
	return wrapper


func _on_item_gui_input(event: InputEvent, item: ItemData) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		item_selected.emit(item)


func _on_item_mouse_entered(wrapper: Control, item: ItemData) -> void:
	_limpiar_tooltip_item()
	wrapper.pivot_offset = wrapper.size / 2
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(wrapper, "scale", Vector2(1.08, 1.08), 0.2)
	hovered_item_wrapper = wrapper
	current_item_tooltip = ITEM_TOOLTIP_SCENE.instantiate()
	TooltipManager.add_child(current_item_tooltip)
	current_item_tooltip.setup(item.nombre, item.description, item.descripcion_valor)


func _on_item_mouse_exited(wrapper: Control) -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(wrapper, "scale", Vector2.ONE, 0.2)
	_limpiar_tooltip_item()


func _on_item_wrapper_tree_exited(wrapper: Control) -> void:
	if hovered_item_wrapper == wrapper:
		_limpiar_tooltip_item()


func _limpiar_tooltip_item() -> void:
	if current_item_tooltip:
		TooltipManager.remove_child(current_item_tooltip)
		current_item_tooltip.queue_free()
		current_item_tooltip = null
	hovered_item_wrapper = null


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
	card_node.aplicar_hover(true)


func deseleccionar(slot: Control) -> void:
	slot.get_node("SelectionBG").visible = false

	for node: Node in get_tree().get_nodes_in_group("cards"):
		var card: Node2D = node as Node2D
		if card.get_parent() == slot:
			card.selected = false
			card.aplicar_hover(false)
			break
