extends CanvasLayer

@onready var result_label: Label = $CenterContainer/VBoxContainer/ResultLabel
@onready var description_label: Label = $CenterContainer/VBoxContainer/DescriptionLabel
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton

var result_key: String
var description_key: String

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)
	setup(true)


func set_won() -> void:
	result_key = "GAMEOVER_WIN_TITLE"
	description_key = "GAMEOVER_WIN_MSG"
	result_label.add_theme_color_override("font_color", Color.GREEN)
	description_label.add_theme_color_override("font_color", Color.WHITE)

func set_lost() -> void:
	result_key = "GAMEOVER_LOSS_TITLE"
	description_key = "GAMEOVER_LOSS_MSG"
	result_label.add_theme_color_override("font_color", Color.RED)
	description_label.add_theme_color_override("font_color", Color.WHITE)


func setup(won: bool) -> void:
	if won:
		set_won()
	else:
		set_lost()
	result_label.get_node("AutoTranslate").set_translation(result_key)
	description_label.get_node("AutoTranslate").set_translation(description_key, [GlobalData.rounds])
		

func _on_restart_button_pressed() -> void:
	GlobalData.reset_game()
	SceneLoader.load_scene("res://scenes/main_menu.tscn")
