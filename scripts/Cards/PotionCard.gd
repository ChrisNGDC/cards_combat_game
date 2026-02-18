extends BaseCard
class_name PotionCard

func _init(n_actual, n_max) -> void:
	nombre = "Potion"
	ruta_imagen = "res://images/potion_card.png"
	tipo = "Defensivo"
	tipo_danio = "Ninguno"
	self.nivel_actual = n_actual
	self.nivel_max = n_max

func efecto(cantidad):
	return cantidad - 10 - (10 * nivel_actual)
