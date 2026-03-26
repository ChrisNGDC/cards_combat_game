extends Node

var fighter: Dictionary = {
	"nombre": "DECK_FIGHTER",
	"ruta_imagen": "res://images/characters/fighter.png",
	"vida": 100,
	"cartas": [
		{"tipo": "CARD_SWORD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SWORD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SWORD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SWORD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SHIELD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SHIELD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_POTION", "niveles": {"actual": 0, "max": 2}},
		{"tipo": "CARD_POTION", "niveles": {"actual": 0, "max": 2}},
		{"tipo": "CARD_STUN", "niveles": {"actual": 0, "max": 0}}
	]
}

var mage: Dictionary = {
	"nombre": "DECK_MAGE",
	"ruta_imagen": "res://images/characters/mage.png",
	"vida": 100,
	"cartas": [
		{"tipo": "CARD_MAGIC", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_MAGIC", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_MAGIC", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_MAGIC", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_MIRROR", "niveles": {"actual": 0, "max": 0}},
		{"tipo": "CARD_MIRROR", "niveles": {"actual": 0, "max": 0}},
		{"tipo": "CARD_POTION", "niveles": {"actual": 0, "max": 2}},
		{"tipo": "CARD_POTION", "niveles": {"actual": 0, "max": 2}}
	]
}

var paladin: Dictionary = {
	"nombre": "DECK_PALADIN",
	"ruta_imagen": "res://images/characters/paladin.png",
	"vida": 100,
	"cartas": [
		{"tipo": "CARD_SWORD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SWORD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_MAGIC", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_MAGIC", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SHIELD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SHIELD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_POTION", "niveles": {"actual": 0, "max": 2}},
		{"tipo": "CARD_POTION", "niveles": {"actual": 0, "max": 2}}
	]
}

var defender: Dictionary = {
	"nombre": "DECK_DEFENDER",
	"ruta_imagen": "res://images/characters/defender.png",
	"vida": 150,
	"cartas": [
		{"tipo": "CARD_SWORD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SWORD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SHIELD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SHIELD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SHIELD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_SHIELD", "niveles": {"actual": 0, "max": 3}},
		{"tipo": "CARD_POTION", "niveles": {"actual": 0, "max": 2}},
		{"tipo": "CARD_POTION", "niveles": {"actual": 0, "max": 2}}
	]
}
		

var decks_classes: Dictionary = {
	"DECK_FIGHTER": fighter,
	"DECK_MAGE": mage,
	"DECK_PALADIN": paladin,
	"DECK_DEFENDER": defender
}

func create_deck(tipo: String) -> DeckData:
	if decks_classes.has(tipo):
		var cartas: Array[CardData] = []
		for carta: Dictionary in decks_classes[tipo]["cartas"]:
			cartas.append(CardManager.create_card(carta["tipo"], carta["niveles"]))
		var nuevo_mazo: DeckData = DeckData.new(decks_classes[tipo], cartas)
		return nuevo_mazo
	return null