class_name Matchups

const INVERT: Dictionary = {
	"1": 5,
	"4": 4,
	"5": 1
}

const MATCHUP_TABLE: Dictionary = {
	"CARD_SWORD": {
		"CARD_SWORD": 4, "CARD_SHIELD": 5, "CARD_MAGIC": 1, "CARD_MIRROR": 1, "CARD_POTION": 1
	},
	"CARD_SHIELD": {
		"CARD_SWORD": 1, "CARD_SHIELD": 4, "CARD_MAGIC": 5, "CARD_MIRROR": 4, "CARD_POTION": 5
	},
	"CARD_MAGIC": {
		"CARD_SWORD": 5, "CARD_SHIELD": 1, "CARD_MAGIC": 4, "CARD_MIRROR": 5, "CARD_POTION": 1
	},
	"CARD_MIRROR": {
		"CARD_SWORD": 5, "CARD_SHIELD": 4, "CARD_MAGIC": 1, "CARD_MIRROR": 4, "CARD_POTION": 5
	},
	"CARD_POTION": {
		"CARD_SWORD": 5, "CARD_SHIELD": 1, "CARD_MAGIC": 5, "CARD_MIRROR": 1, "CARD_POTION": 4
	}
}

func get_card_matchup(card_name: String) -> Dictionary:
	return MATCHUP_TABLE[card_name]