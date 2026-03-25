extends Node2D

@onready var nombre: Label = $Name
@onready var imagen: Sprite2D = $CharacterImage

var datos_mazo: DeckData = null

func setup(datos: DeckData) -> void:
	datos_mazo = datos
	nombre.text = tr(datos_mazo.nombre)
	imagen.texture = load(datos_mazo.ruta_imagen)