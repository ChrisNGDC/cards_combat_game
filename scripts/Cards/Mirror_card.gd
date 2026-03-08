extends BaseCard
class_name MirrorCard

func _init(_nivel_actual = 0, _nivel_max = 0):
	super ("CARD_MIRROR", "res://images/mirror.png", "CARD_DEFENSIVE", _nivel_actual, _nivel_max, "CARD_NONE", "CARD_MIRROR_DESC")
