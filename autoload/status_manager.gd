extends Node

var stun: Dictionary = {
    "nombre": "STATUS_STUN",
    "ruta_imagen": "res://images/combat/stun.png",
    "description": "STATUS_STUN_DESC",
    "effect": func(character: Character) -> void: character.can_play_card = false
}

var burn: Dictionary = {
    "nombre": "STATUS_BURN",
    "ruta_imagen": "res://images/combat/burn.png",
    "description": "STATUS_BURN_DESC",
    "effect": func(character: Character) -> void: character.take_magical_damage(2)
}

var regeneration: Dictionary = {
    "nombre": "STATUS_REGENERATION",
    "ruta_imagen": "res://images/combat/regeneration.png",
    "description": "STATUS_REGENERATION_DESC",
    "effect": func(character: Character) -> void: character.heal(2)
}


var statuses: Dictionary = {
    "STATUS_STUN": stun,
    "STATUS_BURN": burn,
    "STATUS_REGENERATION": regeneration
}

func create_status(tipo: String) -> StatusData:
    if statuses.has(tipo):
        return StatusData.new(statuses[tipo])
    return null