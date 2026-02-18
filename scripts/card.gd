extends Node2D

const COLOR_OFENSIVO = Color(0.8, 0.2, 0.2)
const COLOR_DEFENSIVO = Color(0.2, 0.2, 0.8)

var tipo
var nivel_actual: int
var nivel_max: int
var tipo_danio: String
var escala_normal = Vector2(0.3, 0.3)
var escala_grande = Vector2(0.325, 0.325)
var datos_carta: BaseCard = null
var anchor_pos: Vector2


func _ready():
	_aplicar_datos()
	self.scale = escala_normal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setup(datos: BaseCard):
	datos_carta = datos
	if is_inside_tree():
		_aplicar_datos()


func show_card(si: bool):
	$CardFrontImage.visible = si
	$CardBackImage.visible = !si


func _aplicar_datos():
	if datos_carta == null:
		return
	if has_node("CardFrontImage"):
		var tex = load(datos_carta.ruta_imagen)
		if tex:
			get_node("CardFrontImage").texture = tex
	if has_node("Borde"):
		var nodo_borde = get_node("Borde")
		match datos_carta.tipo:
			"Ofensivo":
				nodo_borde.self_modulate = COLOR_OFENSIVO
			"Defensivo":
				nodo_borde.self_modulate = COLOR_DEFENSIVO
	tipo = datos_carta.tipo
	nivel_actual = datos_carta.nivel_actual
	nivel_max = datos_carta.nivel_max
	tipo_danio = datos_carta.tipo_danio

func quitar_borde():
	if has_node("Borde"):
		var nodo_borde = get_node("Borde")
		nodo_borde.self_modulate = Color(1, 1, 1)

func _on_area_2d_mouse_entered():
	if self.position.x >= 350 and self.position.y >= 350:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", escala_grande, 0.1).set_trans(Tween.TRANS_QUAD)
		get_node("Borde").self_modulate *= 1.5


func _on_area_2d_mouse_exited():
	if self.position.x >= 350 and self.position.y >= 350:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", escala_normal, 0.1).set_trans(Tween.TRANS_QUAD)
		get_node("Borde").self_modulate /= 1.5
