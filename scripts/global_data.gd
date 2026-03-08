extends Node

signal hp_changed(nuevo_hp, es_jugador)

var screen_size: Vector2
var player_hp: int = 100:
	set(val):
		player_hp = clamp(val, 0, 100)
		hp_changed.emit(player_hp, true)
var player_damage_to_recieve: int = 0
var cpu_hp: int = 100:
	set(val):
		cpu_hp = clamp(val, 0, 100)
		hp_changed.emit(cpu_hp, false)
var cpu_damage_to_recieve: int = 0
var player_deck: BaseDeck = null
var cpu_deck: BaseDeck = null
var rounds = 1

var cards_classes = {
	"CARD_SWORD": SwordCard,
	"CARD_SHIELD": ShieldCard,
	"CARD_MIRROR": MirrorCard,
	"CARD_MAGIC": MagicCard,
	"CARD_POTION": PotionCard
}

var decks_classes = {
	"DECK_FIGHTER": FighterDeck,
	"DECK_MAGE": MageDeck,
	"DECK_PALADIN": PaladinDeck
}

func create_deck(tipo: String):
	if decks_classes.has(tipo):
		var nuevo_mazo = decks_classes[tipo].new()
		return nuevo_mazo

func create_card(tipo: String, datos: Array):
	if cards_classes.has(tipo):
		var nueva_carta = cards_classes[tipo].new(datos[0], datos[1])
		return nueva_carta

func reset_damages():
	player_damage_to_recieve = 0
	cpu_damage_to_recieve = 0
	
func reset_game():
	player_hp = 100
	cpu_hp = 100
	rounds = 0
	reset_damages()
	player_deck = null
	cpu_deck = null
