extends PanelContainer

@onready var descripcion: RichTextLabel = $RichTextLabel


func setup(nombre: String, raw_desc: String, valor: int) -> void:
	var color: String = "#00FF00"
	match nombre:
		"ITEM_SWORD_DAMAGE", "ITEM_MAGIC_DAMAGE":
			color = "#FF0000"
		"ITEM_SHIELD_ARMOR":
			color = "#FFFF00"
	var desc: String = tr(raw_desc) % [color, valor]
	descripcion.text = "[font_size=18][b]%s[/b][/font_size]\n%s" % [tr(nombre), desc]
