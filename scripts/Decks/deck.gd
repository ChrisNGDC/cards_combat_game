extends Node2D

var datos_mazo: DeckData = null

func setup(datos: DeckData) -> void:
	datos_mazo = datos
	if is_inside_tree():
		_aplicar_datos()

func _ready() -> void:
	_aplicar_datos()

func _aplicar_datos() -> void:
	if datos_mazo == null: return
	if has_node("LineEdit"):
		get_node("LineEdit").text = tr(datos_mazo.nombre)
	if has_node("DeckImage"):
		var tex: Texture2D = load(datos_mazo.ruta_imagen)
		if tex:
			get_node("DeckImage").texture = tex
