extends HBoxContainer

signal show_deck_requested(deck_data: Dictionary)

var run_data: Dictionary

func setup(data: Dictionary) -> void:
	run_data = data
	$DateLabel.text = data["date"]
	$ResultLabel.text = tr("GAMEOVER_WIN_TITLE") if data["won"] else tr("GAMEOVER_LOSS_TITLE")
	$ResultLabel.add_theme_color_override("font_color", Color.GREEN if data["won"] else Color.RED)

func _on_player_deck_button_pressed() -> void:
	var deck_data: Dictionary = {}
	deck_data.assign(run_data["player_deck"])
	show_deck_requested.emit(deck_data)

func _on_cpu_deck_button_pressed() -> void:
	var deck_data: Dictionary = {}
	deck_data.assign(run_data["cpu_deck"])
	show_deck_requested.emit(deck_data)
