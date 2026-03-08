extends BaseCard
class_name MagicCard

func _init(_nivel_actual = 0, _nivel_max = 0):
	super ("CARD_MAGIC", "res://images/magic.png", "CARD_OFFENSIVE", _nivel_actual, _nivel_max, "CARD_MAGICAL", "CARD_OFFENSIVE_DESC")


func damage_amount():
	return 10 + nivel_actual * 5