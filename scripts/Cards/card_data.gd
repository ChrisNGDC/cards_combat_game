extends Resource
class_name CardData

@export var nombre: String
@export var ruta_imagen: String
@export_enum("Ofensivo", "Defensivo") var tipo: String
@export var nivel_actual: int
@export var nivel_max: int
@export_enum("Fisico", "Magico", "Ninguno") var tipo_danio: String
@export var description: String
var efecto: Callable

func _init(datos: Dictionary) -> void:
	self.nombre = datos.nombre
	self.ruta_imagen = datos.ruta_imagen
	self.tipo = datos.tipo
	self.nivel_actual = datos.niveles.actual
	self.nivel_max = datos.niveles.max
	self.tipo_danio = datos.tipo_danio
	self.description = datos.description
	self.efecto = datos.efecto

func upgradeable() -> bool:
	return nivel_actual < nivel_max

func upgrade() -> void:
	nivel_actual += 1

func actuar() -> int:
	var resultado: int = 0
	if efecto.is_valid():
		resultado = efecto.call()
	return resultado