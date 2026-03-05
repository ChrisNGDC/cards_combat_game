extends BaseCard
class_name PotionCard

func _init(nivel_actual = 0, nivel_max = 0):
	super("CARD_POTION", "res://images/potion.png", "Defensivo", nivel_actual, nivel_max, "Ninguno")
