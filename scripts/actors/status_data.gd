extends Resource
class_name StatusData

var image: String
var description: String
var nombre: String
var effect: Callable

func _init(data: Dictionary) -> void:
    nombre = data.nombre
    image = data.ruta_imagen
    description = data.description
    effect = data.effect

func apply_effect(character: Character) -> void:
    if effect:
        effect.call(character)