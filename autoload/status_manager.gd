extends Node

var stunned: Dictionary = {
    "nombre": "STATUS_STUNNED",
    "ruta_imagen": "res://images/combat/stun.png",
    "description": "STATUS_STUNNED_DESC"
}

var statuses: Dictionary = {
    "STATUS_STUNNED": stunned
}

func create_status(tipo: String) -> StatusData:
    if statuses.has(tipo):
        return StatusData.new(statuses[tipo])
    return null