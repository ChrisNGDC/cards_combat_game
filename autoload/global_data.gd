extends Node

signal hp_changed(nuevo_hp: int, es_jugador: bool)

var screen_size: Vector2
var player_max_hp: int = 100
var player_current_hp: int = 100:
	set(val):
		player_current_hp = clamp(val, 0, player_max_hp)
		hp_changed.emit(player_current_hp, true)
var player_damage_to_recieve: int = 0
var cpu_max_hp: int = 100
var cpu_current_hp: int = 100:
	set(val):
		cpu_current_hp = clamp(val, 0, cpu_max_hp)
		hp_changed.emit(cpu_current_hp, false)
var cpu_damage_to_recieve: int = 0
var player_deck: BaseDeck = FighterDeck.new()
var cpu_deck: BaseDeck = FighterDeck.new()
var rounds: int = 1

var cards_classes: Dictionary = {
	"CARD_SWORD": SwordCard,
	"CARD_SHIELD": ShieldCard,
	"CARD_MIRROR": MirrorCard,
	"CARD_MAGIC": MagicCard,
	"CARD_POTION": PotionCard
}

var decks_classes: Dictionary = {
	"DECK_FIGHTER": FighterDeck,
	"DECK_MAGE": MageDeck,
	"DECK_PALADIN": PaladinDeck,
	"DECK_DEFENDER": DefenderDeck
}

func init_hp(es_jugador: bool, cantidad: int) -> void:
	if es_jugador:
		player_max_hp = cantidad
		player_current_hp = player_max_hp
	else:
		cpu_max_hp = cantidad
		cpu_current_hp = cpu_max_hp

func create_deck(tipo: String) -> BaseDeck:
	if decks_classes.has(tipo):
		var nuevo_mazo: BaseDeck = decks_classes[tipo].new()
		return nuevo_mazo
	return null

func create_card(tipo: String, datos: Array) -> BaseCard:
	if cards_classes.has(tipo):
		var nueva_carta: BaseCard = cards_classes[tipo].new(datos[0], datos[1])
		return nueva_carta
	return null

func reset_damages() -> void:
	player_damage_to_recieve = 0
	cpu_damage_to_recieve = 0
	
func reset_game() -> void:
	player_current_hp = 100
	cpu_current_hp = 100
	rounds = 0
	reset_damages()
	player_deck = null
	cpu_deck = null
