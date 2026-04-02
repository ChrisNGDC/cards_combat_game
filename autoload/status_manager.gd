extends Node

var stun: Dictionary = {
	"nombre": "STATUS_STUN",
	"ruta_imagen": "res://images/combat/stun.png",
	"description": "STATUS_STUN_DESC",
	"effect": func(character: Character) -> void: character.can_play_card = false,
}
var burn: Dictionary = {
	"nombre": "STATUS_BURN",
	"ruta_imagen": "res://images/combat/burn.png",
	"description": "STATUS_BURN_DESC",
	"effect": func(character: Character) -> void: if character.last_card_played and character.last_card_played.tipo == "CARD_OFFENSIVE": character.take_magical_damage(5),
}
var regeneration: Dictionary = {
	"nombre": "STATUS_REGENERATION",
	"ruta_imagen": "res://images/combat/regeneration.png",
	"description": "STATUS_REGENERATION_DESC",
	"effect": func(character: Character) -> void: character.heal(5),
}

var statuses: Dictionary = {
	"STATUS_STUN": stun,
	"STATUS_BURN": burn,
	"STATUS_REGENERATION": regeneration,
}


func create_status(tipo: String) -> StatusData:
	if statuses.has(tipo):
		return StatusData.new(statuses[tipo])
	return null
