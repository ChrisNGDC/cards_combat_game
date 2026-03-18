class_name PickCardLogic

var matchups: Matchups = Matchups.new()
var cards_power: Dictionary = {}
var cards_to_play: Array = []

func get_cards_frequency(cards: Array[CardData]) -> Dictionary:
	var cards_frequency: Dictionary = {}
	for card: CardData in cards:
		if card.nombre in cards_frequency:
			cards_frequency[card.nombre] += 1
		else:
			cards_frequency[card.nombre] = 1
	return cards_frequency


func dict_to_sorted_array(dict: Dictionary) -> Array:
	var keys: Array = dict.keys()
	keys.sort_custom(func(a: String, b: String) -> bool: return dict[a] > dict[b])
	return keys

func get_cards_by_power(cartas: Array[CardData]) -> void:
	var cards_frequency: Dictionary = get_cards_frequency(cartas)
	var sorted_cards: Array = dict_to_sorted_array(cards_frequency)
	for card: String in sorted_cards:
		var card_matchups: Dictionary = matchups.get_card_matchup(card)
		var card_frequency: int = cards_frequency[card]
		for matchup: String in card_matchups:
			var card_power: int = card_matchups[matchup] * card_frequency
			if matchup in cards_power:
				cards_power[matchup] += card_power
			else:
				cards_power[matchup] = card_power
	cards_to_play = dict_to_sorted_array(cards_power)


func convert_hand(cartas: Array[Node2D]) -> Array[CardData]:
	var cards: Array[CardData] = []
	for card: Node2D in cartas:
		cards.append(card.datos_carta)
	return cards
