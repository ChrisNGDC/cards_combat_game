extends Node2D

var escala_normal = Vector2(0.3, 0.3)
var escala_grande = Vector2(0.35, 0.35)
var datos_mazo: BaseDeck = null

func setup(datos: BaseDeck):
	datos_mazo = datos
	if is_inside_tree():
		_aplicar_datos()

func _ready():
	_aplicar_datos()

func _aplicar_datos():
	if datos_mazo == null: return
	if has_node("LineEdit"):
		get_node("LineEdit").text = datos_mazo.nombre
	if has_node("Sprite2D"):
		var tex = load(datos_mazo.ruta_imagen)
		if tex:
			get_node("Sprite2D").texture = tex
	self.scale = escala_normal
	
func _on_area_2d_mouse_entered():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", escala_grande, 0.1).set_trans(Tween.TRANS_QUAD)

func _on_area_2d_mouse_exited():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", escala_normal, 0.1).set_trans(Tween.TRANS_QUAD)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
