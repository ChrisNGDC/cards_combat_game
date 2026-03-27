extends PanelContainer

@onready var descripcion: RichTextLabel = $RichTextLabel

func setup(nombre: String, desc: String) -> void:
	descripcion.text = "[font_size=18][b]%s[/b][/font_size]\n%s" % [tr(nombre), tr(desc)]
