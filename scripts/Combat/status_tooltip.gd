extends PanelContainer

@onready var descripcion: RichTextLabel = $RichTextLabel

func setup(nombre: String, desc: String) -> void:
	descripcion.text = "[code][font_size=18][b]%s[/b][/font_size][/code]\n%s" % [tr(nombre), tr(desc)]
