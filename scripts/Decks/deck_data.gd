extends Resource
class_name DeckData

@export var nombre: String
@export var ruta_imagen: String
@export var cartas: Array[CardData]
@export var vida: int

func _init(datos: Dictionary, _cartas: Array[CardData]) -> void:
	nombre = datos.nombre
	ruta_imagen = datos.ruta_imagen
	vida = datos.vida
	cartas = _cartas