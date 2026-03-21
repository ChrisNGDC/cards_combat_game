extends Control

func _ready() -> void:
	if OS.has_feature("web"):
		$Exit.hide()

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	SceneLoader.load_scene("res://scenes/decks.tscn")


func _on_history_pressed() -> void:
	SceneLoader.load_scene("res://scenes/history_menu.tscn")
