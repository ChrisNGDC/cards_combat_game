@abstract
extends Resource
class_name BaseCard

@export var nombre: String
@export var ruta_imagen: String
@export_enum("Ofensivo", "Defensivo") var tipo: String
@export var nivel_actual: int
@export var nivel_max: int
@export_enum("Fisico", "Magico", "Ninguno") var tipo_danio: String

func _init(n_actual = 0, n_max = 0) -> void:
	self.nivel_actual = n_actual
	self.nivel_max = n_max
	self.setup()

@abstract
func setup()

func upgradeable():
	return nivel_actual < nivel_max

func upgrade():
	nivel_actual += 1
