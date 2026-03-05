extends BaseCard
class_name PotionCard

func _init(_nivel_actual = 0, _nivel_max = 0):
	super ("CARD_POTION", "res://images/potion.png", "Defensivo", _nivel_actual, _nivel_max, "Ninguno")
