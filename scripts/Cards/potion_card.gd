extends BaseCard
class_name PotionCard

func _init(_nivel_actual: int = 0, _nivel_max: int = 0) -> void:
	super ("CARD_POTION", "res://images/potion.png", "CARD_DEFENSIVE", _nivel_actual, _nivel_max, "CARD_NONE", "CARD_POTION_DESC")


func heal_amount() -> int:
	return 10 + nivel_actual * 15