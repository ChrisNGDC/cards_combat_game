extends CanvasLayer

@onready var result_label = $CenterContainer/VBoxContainer/ResultLabel
@onready var description_label = $CenterContainer/VBoxContainer/DescriptionLabel

func setup(won: bool):
	if won:
		result_label.text = "VICTORY"
		result_label.add_theme_color_override("font_color", Color.GREEN)
		description_label.text = "You won on %d turns." % GlobalData.turns
		description_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		result_label.text = "DEFEAT"
		result_label.add_theme_color_override("font_color", Color.RED)
		description_label.text = "You lost on %d turns." % GlobalData.turns
		description_label.add_theme_color_override("font_color", Color.WHITE)

func _on_restart_button_pressed():
	GlobalData.reset_game()
	get_tree().change_scene_to_file("res://escenes/main_menu.tscn")
