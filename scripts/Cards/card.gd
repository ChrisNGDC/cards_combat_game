extends Node2D

const COLOR_OFENSIVO: Color = Color(0.8, 0.2, 0.2)
const COLOR_DEFENSIVO: Color = Color(0.2, 0.2, 0.8)

@export var tooltip_scene: PackedScene

@onready var level_label: Label = $UpgradeLabel
@onready var card_front: Sprite2D = $CardFrontImage
@onready var card_icon: Sprite2D = $CardFrontIcon
@onready var card_name: Label = $CardLabel
@onready var card_back: Sprite2D = $CardBackImage

var gold_style: LabelSettings = preload("res://resources/max_level_label_settings.tres")
var basic_style: LabelSettings = preload("res://resources/basic_level_label_settings.tres")

var tipo: String
var nivel_actual: int
var nivel_max: int
var tipo_danio: String
var escala_normal: Vector2 = Vector2(0.3, 0.3)
var escala_grande: Vector2 = Vector2(0.325, 0.325)
var datos_carta: CardData = null
var anchor_pos: Vector2
var own_by_player: bool
var selected: bool = false
var show_tooltip: bool = true
var current_tooltip: PanelContainer = null

func _ready() -> void:
	_aplicar_datos()
	self.scale = escala_normal
	connect("tree_exited", Callable(self , "_on_tree_exited"))


func _process(_delta: float) -> void:
	if current_tooltip:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var screen_size: Vector2 = get_viewport_rect().size
		var tooltip_size: Vector2 = current_tooltip.get_global_rect().size
		var offset: Vector2 = Vector2(10, 10)
		if mouse_pos.x + offset.x + tooltip_size.x > screen_size.x:
			offset.x = - tooltip_size.x
		if mouse_pos.y + offset.y + tooltip_size.y > screen_size.y:
			offset.y = - tooltip_size.y
			
		current_tooltip.global_position = mouse_pos + offset


func setup(datos: CardData, player: bool) -> void:
	datos_carta = datos
	own_by_player = player
	create_tooltip()
	show_card(false)
	if is_inside_tree():
		_aplicar_datos()


func show_card(si: bool) -> void:
	card_front.visible = si
	card_icon.visible = si
	card_name.visible = si
	level_label.visible = si
	card_back.visible = !si


func create_tooltip() -> void:
	current_tooltip = tooltip_scene.instantiate()
	TooltipManager.add_child(current_tooltip)
	current_tooltip.get_node("VBox/HBox/TypeLabel").text = tr(datos_carta.tipo)
	var tooltip_level_label: Label = current_tooltip.get_node("VBox/HBox/LevelLabel")
	tooltip_level_label.text = "Lvl." + (str(datos_carta.nivel_actual) if datos_carta.nivel_actual < datos_carta.nivel_max else "Max")
	tooltip_level_label.modulate = (gold_style.font_color if datos_carta.nivel_actual == datos_carta.nivel_max else basic_style.font_color)
	var description_values: Array = []
	match datos_carta.nombre:
		"CARD_SWORD":
			description_values = ["#ff0000", datos_carta.efecto.call(datos_carta.nivel_actual), tr(datos_carta.tipo_danio)]
		"CARD_MAGIC":
			description_values = ["#ffff00", datos_carta.efecto.call(datos_carta.nivel_actual), tr(datos_carta.tipo_danio)]
		"CARD_SHIELD":
			description_values = ["#0000ff", datos_carta.efecto.call(datos_carta.nivel_actual)]
		"CARD_MIRROR":
			description_values = []
		"CARD_POTION":
			description_values = ["#00ff00", datos_carta.efecto.call(datos_carta.nivel_actual)]
	current_tooltip.get_node("VBox/InfoText").text = tr(datos_carta.description) % description_values
	current_tooltip.hide()


func show_tooltip_info(si: bool) -> void:
	if si:
		current_tooltip.show()
	else:
		current_tooltip.hide()


func _aplicar_datos() -> void:
	if datos_carta == null:
		return
	if has_node("CardFrontIcon"):
		var tex: Texture2D = load(datos_carta.ruta_imagen)
		if tex:
			get_node("CardFrontIcon").texture = tex
	card_name.text = tr(datos_carta.nombre)
	tipo = datos_carta.tipo
	nivel_actual = datos_carta.nivel_actual
	nivel_max = datos_carta.nivel_max
	tipo_danio = datos_carta.tipo_danio
	update_level_display()

func dar_borde() -> void:
	if has_node("Borde"):
		var nodo_borde: Sprite2D = get_node("Borde")
		match datos_carta.tipo:
			"CARD_OFFENSIVE":
				nodo_borde.self_modulate = COLOR_OFENSIVO
			"CARD_DEFENSIVE":
				nodo_borde.self_modulate = COLOR_DEFENSIVO

func quitar_borde() -> void:
	if has_node("Borde"):
		var nodo_borde: Sprite2D = get_node("Borde")
		nodo_borde.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
		
func update_level_display() -> void:
	if nivel_max > nivel_actual:
		if nivel_actual > 0:
			level_label.text = "+" + str(nivel_actual)
		else:
			level_label.text = ""
		level_label.label_settings = basic_style
	else:
		level_label.text = "Max"
		level_label.label_settings = gold_style

func _on_area_2d_mouse_entered() -> void:
	if self.card_front.visible:
		if self.own_by_player:
			get_node("Borde").self_modulate *= 1.5
		if not self.selected:
			apply_scale_tween(self.escala_grande)
		if show_tooltip:
			show_tooltip_info(true)


func _on_area_2d_mouse_exited() -> void:
	if self.card_front.visible:
		if self.own_by_player:
			get_node("Borde").self_modulate /= 1.5
		if not self.selected:
			apply_scale_tween(self.escala_normal)
		show_tooltip_info(false)

func apply_scale_tween(target_scale: Vector2) -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self , "scale", target_scale, 0.2)


func _on_tree_exited() -> void:
	if current_tooltip:
		current_tooltip.queue_free()
