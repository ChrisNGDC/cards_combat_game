extends BaseDeck
class_name DefenderDeck

func _init() -> void:
	nombre = "DECK_DEFENDER"
	ruta_imagen = "res://images/dorso.jpg"
	vida = 150
	crear_cartas()
	
func crear_cartas():
	cartas.append(SwordCard.new(0, 3))
	cartas.append(SwordCard.new(0, 3))
	cartas.append(ShieldCard.new(0, 3))
	cartas.append(ShieldCard.new(0, 3))
	cartas.append(ShieldCard.new(0, 3))
	cartas.append(ShieldCard.new(0, 3))
	cartas.append(PotionCard.new(0, 2))
	cartas.append(PotionCard.new(0, 2))