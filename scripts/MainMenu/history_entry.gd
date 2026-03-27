extends HBoxContainer

signal show_deck_requested(deck_data: Dictionary)

@onready var player_deck_button: Button = $PlayerDeckButton
@onready var cpu_deck_button: Button = $CPUDeckButton

var run_data: Dictionary

func _ready() -> void:
	player_deck_button.pressed.connect(_on_player_deck_button_pressed)
	cpu_deck_button.pressed.connect(_on_cpu_deck_button_pressed)

func setup(data: Dictionary) -> void:
	run_data = data
	$DateLabel.text = data["date"]
	$ResultLabel.get_node("AutoTranslate").set_translation("GAMEOVER_WIN_TITLE" if data["won"] else "GAMEOVER_LOSS_TITLE")
	$ResultLabel.add_theme_color_override("font_color", Color.GREEN if data["won"] else Color.RED)

func _on_player_deck_button_pressed() -> void:
	var deck_data: Dictionary = {}
	deck_data.assign(run_data["player_deck"])
	show_deck_requested.emit(deck_data)

func _on_cpu_deck_button_pressed() -> void:
	var deck_data: Dictionary = {}
	deck_data.assign(run_data["cpu_deck"])
	show_deck_requested.emit(deck_data)
