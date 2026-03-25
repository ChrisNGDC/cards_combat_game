extends Control

@onready var round_label: RichTextLabel = $RoundLabel
@onready var help: TextureRect = $Help

func _ready() -> void:
	help.mouse_entered.connect(_on_help_mouse_entered)
	help.mouse_exited.connect(_on_help_mouse_exited)
	round_label.text = "[font_size=50]" + tr("COMBAT_ROUND") + " %d" % (GlobalData.rounds) + "[/font_size]"

func _on_help_mouse_entered() -> void:
	var help_text: String = "[code][font_size=15]Gana a ━>
┏━━━━━> %s ━━━━━━┓
┃          ┃         ┃
┃          ˅         ˅
%s <━ %s ━> %s
˄          ˄         ┃
┃          ┃         ┃
┗━━━━━━━ %s <━━━━━┛[/font_size][/code]" % [tr("CARD_SWORD"), tr("CARD_SHIELD"), tr("CARD_POTION"), tr("CARD_MIRROR"), tr("CARD_MAGIC")]
	round_label.text = help_text
	help.self_modulate.a = 0.25


func _on_help_mouse_exited() -> void:
	round_label.text = "[font_size=50]" + tr("COMBAT_ROUND") + " %d" % (GlobalData.rounds) + "[/font_size]"
	help.self_modulate.a = 0.75