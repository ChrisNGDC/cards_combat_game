extends Panel


var nombre: String
var description: String
var image_loaded: CompressedTexture2D
var tooltip_scene: PackedScene = preload("res://scenes/status_tooltip.tscn")
var current_tooltip: PanelContainer = null


func _process(_delta: float) -> void:
	if current_tooltip:
		TooltipFollower.follow(current_tooltip, self, Vector2(15, -5))


func setup(status_data: StatusData) -> void:
	nombre = status_data.nombre
	description = status_data.description
	image_loaded = load(status_data.image)

	if image_loaded:
		var new_imagen: TextureRect = TextureRect.new()
		new_imagen.texture = image_loaded
		add_child(new_imagen)

	connect_signals()
	tree_exited.connect(_on_tree_exited)


func connect_signals() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_leave)


func _on_mouse_enter() -> void:
	current_tooltip = tooltip_scene.instantiate()
	TooltipManager.add_child(current_tooltip)
	current_tooltip.setup(nombre, description)


func _on_mouse_leave() -> void:
	if current_tooltip:
		TooltipManager.remove_child(current_tooltip)
		current_tooltip.queue_free()
		current_tooltip = null


func _on_tree_exited() -> void:
	if is_instance_valid(current_tooltip):
		current_tooltip.queue_free()
	current_tooltip = null
