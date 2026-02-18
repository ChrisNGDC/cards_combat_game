extends BaseCard
class_name DefenseCard

func _init(n_actual, n_max) -> void:
	nombre = "Defense"
	ruta_imagen = "res://images/defense_card.png"
	tipo = "Defensivo"
	tipo_danio = "Ninguno"
	self.nivel_actual = n_actual
	self.nivel_max = n_max

func efecto(cantidad):
	return max(cantidad - 1 - (1 * nivel_actual), 0)
