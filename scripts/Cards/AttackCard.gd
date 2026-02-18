extends BaseCard
class_name AttackCard

func _init(n_actual, n_max) -> void:
	nombre = "Attack"
	ruta_imagen = "res://images/attack_card.jpg"
	tipo = "Ofensivo"
	tipo_danio = "Fisico"
	self.nivel_actual = n_actual
	self.nivel_max = n_max

func efecto(cantidad):
	return cantidad + 1 + (1 * nivel_actual)
