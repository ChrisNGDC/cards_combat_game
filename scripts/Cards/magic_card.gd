extends BaseCard
class_name MagicCard

func _init(_nivel_actual = 0, _nivel_max = 0):
	super ("CARD_MAGIC", "res://images/magic.png", "Ofensivo", _nivel_actual, _nivel_max, "Magico")
