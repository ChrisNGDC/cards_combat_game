extends PanelContainer

@onready var descripcion: RichTextLabel = $RichTextLabel

func setup(nombre: String, raw_desc: String) -> void:
	var desc: String = ""
	match nombre:
		"STATUS_STUN":
			desc = tr(raw_desc)
		"STATUS_BURN":
			desc = tr(raw_desc) % ["#FF0000", 2]
		"STATUS_REGENERATION":
			desc = tr(raw_desc) % ["#00FF00", 2]
	descripcion.text = "[font_size=18][b]%s[/b][/font_size]\n%s" % [tr(nombre), desc]