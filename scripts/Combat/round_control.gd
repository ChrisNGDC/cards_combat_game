extends Control

@onready var round_label: RichTextLabel = $RoundLabel
@onready var help: TextureRect = $Help

func _ready() -> void:
	help.mouse_entered.connect(_on_help_mouse_entered)
	help.mouse_exited.connect(_on_help_mouse_exited)
	round_label.text = "[font_size=50]" + tr("COMBAT_ROUND") + " %d" % (GlobalData.rounds) + "[/font_size]"

func _on_help_mouse_entered() -> void:
	var help_text: String = "[code][font_size=16][b][u]" + tr("CARDS_HELP") + "[/u][/b][/font_size][font_size=14]\n"
	help_text += "%s -> " % tr("CARD_SWORD") + "%s, %s y %s\n" % [tr("CARD_MIRROR"), tr("CARD_MAGIC"), tr("CARD_POTION")]
	help_text += "%s -> " % tr("CARD_SHIELD") + "%s\n" % tr("CARD_SWORD")
	help_text += "%s -> " % tr("CARD_MAGIC") + "%s y %s\n" % [tr("CARD_POTION"), tr("CARD_SHIELD")]
	help_text += "%s -> " % tr("CARD_MIRROR") + "%s\n" % tr("CARD_MAGIC")
	help_text += "%s -> " % tr("CARD_POTION") + "%s y %s\n" % [tr("CARD_SHIELD"), tr("CARD_MIRROR")]
	help_text += "[/font_size][/code]"
	round_label.text = help_text
	help.self_modulate.a = 0.25


func _on_help_mouse_exited() -> void:
	round_label.text = "[font_size=50]" + tr("COMBAT_ROUND") + " %d" % (GlobalData.rounds) + "[/font_size]"
	help.self_modulate.a = 0.75