extends BaseCard
class_name MagicCard

func _init(n_actual, n_max) -> void:
	nombre = "Magic"
	ruta_imagen = "res://images/magic_card.png"
	tipo = "Ofensivo"
	tipo_danio = "Magico"
	self.nivel_actual = n_actual
	self.nivel_max = n_max

func efecto(cantidad):
	return cantidad + 1 + (1 * nivel_actual)
