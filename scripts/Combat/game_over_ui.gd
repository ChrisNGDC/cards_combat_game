extends CanvasLayer

@onready var result_label: Label = $CenterContainer/VBoxContainer/ResultLabel
@onready var description_label: Label = $CenterContainer/VBoxContainer/DescriptionLabel
@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton

func _ready() -> void:
	restart_button.pressed.connect(_on_restart_button_pressed)

func setup(won: bool) -> void:
	if won:
		result_label.text = tr("GAMEOVER_WIN_TITLE")
		result_label.add_theme_color_override("font_color", Color.GREEN)
		description_label.text = tr("GAMEOVER_WIN_MSG") % GlobalData.rounds
		description_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		result_label.text = tr("GAMEOVER_LOSS_TITLE")
		result_label.add_theme_color_override("font_color", Color.RED)
		description_label.text = tr("GAMEOVER_LOSS_MSG") % GlobalData.rounds
		description_label.add_theme_color_override("font_color", Color.WHITE)

func _on_restart_button_pressed() -> void:
	GlobalData.reset_game()
	SceneLoader.load_scene("res://scenes/main_menu.tscn")
