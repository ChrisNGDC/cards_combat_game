extends Node2D

const COLOR_OFENSIVO = Color(0.8, 0.2, 0.2)
const COLOR_DEFENSIVO = Color(0.2, 0.2, 0.8)

@onready var level_label = $UpgradeLabel
@onready var card_front = $CardFrontImage
@onready var card_icon = $CardFrontIcon
@onready var card_name = $CardLabel
@onready var card_back = $CardBackImage

var gold_style = preload("res://resources/max_level_label_settings.tres")
var basic_style = preload("res://resources/basic_level_label_settings.tres")

var tipo
var nivel_actual: int
var nivel_max: int
var tipo_danio: String
var escala_normal = Vector2(0.3, 0.3)
var escala_grande = Vector2(0.325, 0.325)
var datos_carta: BaseCard = null
var anchor_pos: Vector2
var own_by_player: bool
var selected: bool = false


func _ready():
	_aplicar_datos()
	self.scale = escala_normal


func _process(_delta: float) -> void:
	pass


func setup(datos: BaseCard, player: bool):
	datos_carta = datos
	own_by_player = player
	show_card(false)
	if is_inside_tree():
		_aplicar_datos()


func show_card(si: bool):
	card_front.visible = si
	card_icon.visible = si
	card_name.visible = si
	level_label.visible = si
	card_back.visible = !si


func _aplicar_datos():
	if datos_carta == null:
		return
	if has_node("CardFrontIcon"):
		var tex = load(datos_carta.ruta_imagen)
		if tex:
			get_node("CardFrontIcon").texture = tex
	card_name.text = tr(datos_carta.nombre)
	tipo = datos_carta.tipo
	nivel_actual = datos_carta.nivel_actual
	nivel_max = datos_carta.nivel_max
	tipo_danio = datos_carta.tipo_danio
	self.update_level_display()

func dar_borde():
	if has_node("Borde"):
		var nodo_borde = get_node("Borde")
		match datos_carta.tipo:
			"Ofensivo":
				nodo_borde.self_modulate = COLOR_OFENSIVO
			"Defensivo":
				nodo_borde.self_modulate = COLOR_DEFENSIVO

func quitar_borde():
	if has_node("Borde"):
		var nodo_borde = get_node("Borde")
		nodo_borde.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
		
func update_level_display():
	if nivel_max > nivel_actual:
		if nivel_actual > 0:
			level_label.text = "+" + str(nivel_actual)
		else:
			level_label.text = ""
		level_label.label_settings = basic_style
	else:
		level_label.text = "Max"
		level_label.label_settings = gold_style

func _on_area_2d_mouse_entered():
	if self.own_by_player and self.card_front.visible:
		get_node("Borde").self_modulate *= 1.5
		if not self.selected:
			apply_scale_tween(self.escala_grande)


func _on_area_2d_mouse_exited():
	if self.own_by_player and self.card_front.visible:
		get_node("Borde").self_modulate /= 1.5
		if not self.selected:
			apply_scale_tween(self.escala_normal)

func apply_scale_tween(target_scale: Vector2):
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self , "scale", target_scale, 0.2)
