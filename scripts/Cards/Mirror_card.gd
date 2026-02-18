extends BaseCard
class_name MirrorCard

func _init(n_actual, n_max) -> void:
	nombre = "Mirror"
	ruta_imagen = "res://images/mirror_card.png"
	tipo = "Defensivo"
	tipo_danio = "Ninguno"
	self.nivel_actual = n_actual
	self.nivel_max = n_max

func efecto(cantidad):
	return cantidad
