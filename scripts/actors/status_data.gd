extends Resource
class_name StatusData

var image: String
var description: String
var nombre: String

func _init(data: Dictionary) -> void:
    nombre = data.nombre
    image = data.ruta_imagen
    description = data.description