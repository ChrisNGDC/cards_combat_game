extends Panel

const TOOLTIP_SCENE: PackedScene = preload("res://scenes/item_tooltip.tscn")

var nombre: String
var description: String
var valor: int
var image_loaded: CompressedTexture2D
var current_tooltip: PanelContainer = null


func _process(_delta: float) -> void:
	if current_tooltip:
		TooltipFollower.follow(current_tooltip, self, Vector2(15, -5))


func setup(item: ItemData, cantidad: int) -> void:
	nombre = item.nombre
	description = item.description
	valor = item.descripcion_valor
	if ResourceLoader.exists(item.ruta_imagen):
		image_loaded = load(item.ruta_imagen)

	if image_loaded:
		var new_imagen: TextureRect = TextureRect.new()
		new_imagen.texture = image_loaded
		new_imagen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		new_imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		new_imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		new_imagen.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(new_imagen)

	if cantidad > 1:
		var contador: Label = Label.new()
		contador.text = "x" + str(cantidad)
		contador.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		contador.grow_vertical = Control.GROW_DIRECTION_BEGIN
		contador.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		contador.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(contador)

	connect_signals()
	tree_exited.connect(_on_tree_exited)


func connect_signals() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_leave)


func _on_mouse_enter() -> void:
	current_tooltip = TOOLTIP_SCENE.instantiate()
	TooltipManager.add_child(current_tooltip)
	current_tooltip.setup(nombre, description, valor)


func _on_mouse_leave() -> void:
	if current_tooltip:
		TooltipManager.remove_child(current_tooltip)
		current_tooltip.queue_free()
		current_tooltip = null


func _on_tree_exited() -> void:
	if is_instance_valid(current_tooltip):
		current_tooltip.queue_free()
	current_tooltip = null
