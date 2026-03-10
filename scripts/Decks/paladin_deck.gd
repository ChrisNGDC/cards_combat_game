extends BaseDeck
class_name PaladinDeck

func _init() -> void:
	nombre = "DECK_PALADIN"
	ruta_imagen = "res://images/dorso.jpg"
	crear_cartas()
	
func crear_cartas() -> void:
	cartas.append(SwordCard.new(0, 3))
	cartas.append(SwordCard.new(0, 3))
	cartas.append(MagicCard.new(0, 3))
	cartas.append(MagicCard.new(0, 3))
	cartas.append(ShieldCard.new(0, 3))
	cartas.append(ShieldCard.new(0, 3))
	cartas.append(PotionCard.new(0, 2))
	cartas.append(PotionCard.new(0, 2))
