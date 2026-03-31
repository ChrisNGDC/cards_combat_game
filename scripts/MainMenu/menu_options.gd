extends Control

@onready var play_button: Button = $Play
@onready var history_button: Button = $History
@onready var exit_button: Button = $Exit

func _ready() -> void:
	if OS.has_feature("web"):
		$Exit.hide()
	else:
		exit_button.pressed.connect(_on_exit_pressed)
	play_button.pressed.connect(_on_play_pressed)
	history_button.pressed.connect(_on_history_pressed)

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	GlobalData.reset_game()
	SceneLoader.load_scene("res://scenes/decks.tscn")


func _on_history_pressed() -> void:
	SceneLoader.load_scene("res://scenes/history_menu.tscn")
