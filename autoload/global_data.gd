extends Node

var rounds: int = 1
var cpu: GameCPU = GameCPU.new()
var player: GamePlayer = GamePlayer.new()

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
	
func reset_game() -> void:
	cpu.reset()
	player.reset()
