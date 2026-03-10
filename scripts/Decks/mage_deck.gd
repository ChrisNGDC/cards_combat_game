extends BaseDeck
class_name MageDeck

func _init() -> void:
	nombre = "DECK_MAGE"
	ruta_imagen = "res://images/dorso.jpg"
	crear_cartas()
	
func crear_cartas() -> void:
	cartas.append(MagicCard.new(0, 3))
	cartas.append(MagicCard.new(0, 3))
	cartas.append(MagicCard.new(0, 3))
	cartas.append(MagicCard.new(0, 3))
	cartas.append(MirrorCard.new(0, 0))
	cartas.append(MirrorCard.new(0, 0))
	cartas.append(MirrorCard.new(0, 0))
	cartas.append(PotionCard.new(0, 2))
