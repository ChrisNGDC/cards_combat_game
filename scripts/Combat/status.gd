extends Panel

var nombre: String
var description: String
var imageLoaded: CompressedTexture2D
var tooltip_scene: PackedScene = preload("res://scenes/status_tooltip.tscn")
var current_tooltip: PanelContainer = null

func setup(status_data: StatusData) -> void:
	nombre = status_data.nombre
	description = status_data.description
	imageLoaded = load(status_data.image)
	if imageLoaded:
		var new_imagen: Sprite2D = Sprite2D.new()
		new_imagen.texture = imageLoaded
		new_imagen.centered = false
		add_child(new_imagen)
	connect_signals()

func connect_signals() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_leave)

func _process(_delta: float) -> void:
	if current_tooltip:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var screen_size: Vector2 = get_viewport_rect().size
		var tooltip_size: Vector2 = current_tooltip.get_global_rect().size
		var offset: Vector2 = Vector2(15, -5)
		if mouse_pos.x + offset.x + tooltip_size.x > screen_size.x:
			offset.x = - tooltip_size.x
		if mouse_pos.y + offset.y + tooltip_size.y > screen_size.y:
			offset.y = - tooltip_size.y
			
		current_tooltip.global_position = mouse_pos + offset

func _on_mouse_enter() -> void:
	current_tooltip = tooltip_scene.instantiate()
	TooltipManager.add_child(current_tooltip)
	current_tooltip.setup(nombre, description)


func _on_mouse_leave() -> void:
	TooltipManager.remove_child(current_tooltip)
	current_tooltip = null
