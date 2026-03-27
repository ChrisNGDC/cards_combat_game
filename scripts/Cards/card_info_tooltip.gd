extends PanelContainer

@onready var label: Label = $VBox/HBox/TypeLabel
@onready var level_label: Label = $VBox/HBox/LevelLabel
@onready var description: RichTextLabel = $VBox/InfoText

var gold_style: LabelSettings = preload("res://resources/max_level_label_settings.tres")
var basic_style: LabelSettings = preload("res://resources/basic_level_label_settings.tres")

var raw_description: String = ""
var raw_description_values: Array = []

func setup(datos: Node2D) -> void:
	raw_description = datos.datos_carta.description
	label.get_node("AutoTranslate").set_translation(datos.nombre)
	level_label.text = "Lvl." + (str(datos.nivel_actual) if datos.nivel_actual < datos.nivel_max else "Max")
	level_label.modulate = (gold_style.font_color if datos.nivel_actual == datos.nivel_max else basic_style.font_color)
	match datos.nombre:
		"CARD_SWORD":
			raw_description_values = ["#ff0000", datos.apply_effect(), datos.tipo_danio]
		"CARD_MAGIC":
			raw_description_values = ["#ffff00", datos.apply_effect(), datos.tipo_danio]
		"CARD_SHIELD":
			raw_description_values = ["#0000ff", datos.apply_effect()]
		"CARD_MIRROR":
			raw_description_values = []
		"CARD_POTION":
			raw_description_values = ["#00ff00", datos.apply_effect()]
		"CARD_STUN":
			raw_description_values = []
	_update_translation()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if raw_description != "":
			_update_translation()

func _update_translation() -> void:
	var description_values: Array = raw_description_values.duplicate()
	if description_values.size() == 3:
		description_values[2] = tr(description_values[2])
	description.text = tr(raw_description) % description_values
