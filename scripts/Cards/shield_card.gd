extends BaseCard
class_name ShieldCard

func _init(_nivel_actual: int = 0, _nivel_max: int = 0) -> void:
	super ("CARD_SHIELD", "res://images/shield.png", "CARD_DEFENSIVE", _nivel_actual, _nivel_max, "CARD_NONE", "CARD_SHIELD_DESC")


func block_amount() -> int:
	return 10 + nivel_actual * 10