extends Resource

class_name StatusData

@export var image: String
@export var description: String
@export var nombre: String
var effect: Callable


func _init(data: Dictionary) -> void:
	nombre = data.nombre
	image = data.ruta_imagen
	description = data.description
	effect = data.effect


func apply_effect(character: Character) -> void:
	if effect.is_valid():
		effect.call(character)
