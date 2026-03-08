extends BaseCard
class_name SwordCard

func _init(_nivel_actual = 0, _nivel_max = 0):
	super ("CARD_SWORD", "res://images/sword.png", "CARD_OFFENSIVE", _nivel_actual, _nivel_max, "CARD_PHYSICAL", "CARD_OFFENSIVE_DESC")


func damage_amount():
	return 10 + nivel_actual * 10