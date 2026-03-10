extends Resource
class_name BaseCard

@export var nombre: String
@export var ruta_imagen: String
@export_enum("Ofensivo", "Defensivo") var tipo: String
@export var nivel_actual: int
@export var nivel_max: int
@export_enum("Fisico", "Magico", "Ninguno") var tipo_danio: String
@export var description: String

func _init(_nombre: String, _ruta_imagen: String, _tipo: String, _nivel_actual: int, _nivel_max: int, _tipo_danio: String, _description: String) -> void:
	self.nombre = _nombre
	self.ruta_imagen = _ruta_imagen
	self.tipo = _tipo
	self.nivel_actual = _nivel_actual
	self.nivel_max = _nivel_max
	self.tipo_danio = _tipo_danio
	self.description = _description

func upgradeable() -> bool:
	return nivel_actual < nivel_max

func upgrade() -> void:
	nivel_actual += 1
