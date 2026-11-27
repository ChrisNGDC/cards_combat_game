extends Resource

class_name ItemData

@export var nombre: String
@export var ruta_imagen: String
@export var description: String
@export var apilable: bool
var bonos: Dictionary = {}
var efecto_adquisicion: Callable
var descripcion_valor: int = 0


func _init(datos: Dictionary) -> void:
	nombre = datos.nombre
	ruta_imagen = datos.ruta_imagen
	description = datos.description
	apilable = datos.apilable
	bonos = datos.get("bonos", {})
	efecto_adquisicion = datos.get("efecto_adquisicion", Callable())
	descripcion_valor = datos.get("descripcion_valor", 0)


func get_bono(clave: String) -> int:
	return bonos.get(clave, 0)
