extends Node

var sword: Dictionary = {
	"nombre": "CARD_SWORD",
	"ruta_imagen": "res://images/sword.png",
	"tipo": "CARD_OFFENSIVE",
	"niveles": {
		"actual": 0,
		"max": 0
	},
	"tipo_danio": "CARD_PHYSICAL",
	"description": "CARD_OFFENSIVE_DESC",
	"efecto": func(nivel: int) -> int: return 10 + nivel * 10
}
var shield: Dictionary = {
	"nombre": "CARD_SHIELD",
	"ruta_imagen": "res://images/shield.png",
	"tipo": "CARD_DEFENSIVE",
	"niveles": {
		"actual": 0,
		"max": 3
	},
	"tipo_danio": "CARD_NONE",
	"description": "CARD_SHIELD_DESC",
	"efecto": func(nivel: int) -> int: return 10 + nivel * 10
}
var mirror: Dictionary = {
	"nombre": "CARD_MIRROR",
	"ruta_imagen": "res://images/mirror.png",
	"tipo": "CARD_DEFENSIVE",
	"niveles": {
		"actual": 0,
		"max": 0
	},
	"tipo_danio": "CARD_NONE",
	"description": "CARD_MIRROR_DESC",
	"efecto": print
}
var magic: Dictionary = {
	"nombre": "CARD_MAGIC",
	"ruta_imagen": "res://images/magic.png",
	"tipo": "CARD_OFFENSIVE",
	"niveles": {
		"actual": 0,
		"max": 3
	},
	"tipo_danio": "CARD_MAGICAL",
	"description": "CARD_OFFENSIVE_DESC",
	"efecto": func(nivel: int) -> int: return 10 + nivel * 5
}
var potion: Dictionary = {
	"nombre": "CARD_POTION",
	"ruta_imagen": "res://images/potion.png",
	"tipo": "CARD_DEFENSIVE",
	"niveles": {
		"actual": 0,
		"max": 3
	},
	"tipo_danio": "CARD_NONE",
	"description": "CARD_POTION_DESC",
	"efecto": func(nivel: int) -> int: return 10 + nivel * 15
}
var stun: Dictionary = {
	"nombre": "CARD_STUN",
	"ruta_imagen": "res://images/stun.png",
	"tipo": "CARD_DEFENSIVE",
	"niveles": {
		"actual": 0,
		"max": 0
	},
	"tipo_danio": "CARD_NONE",
	"description": "CARD_STUN_DESC",
	"efecto": print
}

var cards_classes: Dictionary = {
	"CARD_SWORD": sword,
	"CARD_SHIELD": shield,
	"CARD_MIRROR": mirror,
	"CARD_MAGIC": magic,
	"CARD_POTION": potion,
	"CARD_STUN": stun
}

func create_card(tipo: String, niveles: Dictionary) -> CardData:
	if cards_classes.has(tipo):
		var nueva_carta: CardData = CardData.new(cards_classes[tipo])
		nueva_carta.nivel_actual = niveles.actual
		nueva_carta.nivel_max = niveles.max
		return nueva_carta
	return null