extends Resource
class_name BaseCard

@export var nombre: String
@export var ruta_imagen: String
@export_enum("Ofensivo", "Defensivo") var tipo: String
@export var nivel_actual: int
@export var nivel_max: int
@export_enum("Fisico", "Magico", "Ninguno") var tipo_danio: String

func _init(nombre, ruta_imagen, tipo, nivel_actual, nivel_max, tipo_danio):
	self.nombre = nombre
	self.ruta_imagen = ruta_imagen
	self.tipo = tipo
	self.nivel_actual = nivel_actual
	self.nivel_max = nivel_max
	self.tipo_danio = tipo_danio

func upgradeable():
	return nivel_actual < nivel_max

func upgrade():
	nivel_actual += 1
