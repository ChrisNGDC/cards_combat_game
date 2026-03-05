extends Resource
class_name BaseCard

@export var nombre: String
@export var ruta_imagen: String
@export_enum("Ofensivo", "Defensivo") var tipo: String
@export var nivel_actual: int
@export var nivel_max: int
@export_enum("Fisico", "Magico", "Ninguno") var tipo_danio: String

func _init(_nombre, _ruta_imagen, _tipo, _nivel_actual, _nivel_max, _tipo_danio):
	self.nombre = _nombre
	self.ruta_imagen = _ruta_imagen
	self.tipo = _tipo
	self.nivel_actual = _nivel_actual
	self.nivel_max = _nivel_max
	self.tipo_danio = tipo_danio

func upgradeable():
	return nivel_actual < nivel_max

func upgrade():
	nivel_actual += 1
