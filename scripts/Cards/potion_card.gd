extends BaseCard
class_name PotionCard

func _init(_nivel_actual = 0, _nivel_max = 0):
	super ("CARD_POTION", "res://images/potion.png", "CARD_DEFENSIVE", _nivel_actual, _nivel_max, "CARD_NONE", "CARD_POTION_DESC")


func heal_amount():
	return 10 + nivel_actual * 15