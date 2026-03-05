extends Control

@onready var continue_button: Button = $Continue
@onready var res_button = $ResolutionButton
@onready var lang_button = $LanguageButton

var resolutions: Dictionary = {
	"1280x720": Vector2i(1280, 720),
	"1600x900": Vector2i(1600, 900),
	"1920x1080": Vector2i(1920, 1080),
}


func _ready():
	_fill_resolution_options()
	var current_locale = TranslationServer.get_locale()
	if current_locale.begins_with("es"):
		lang_button.selected = 1
	else:
		lang_button.selected = 0

	res_button.item_selected.connect(_on_resolution_selected)
	lang_button.item_selected.connect(_on_language_selected)


func _fill_resolution_options():
	res_button.clear()
	for res_text in resolutions.keys():
		res_button.add_item(res_text)

	var current_res = DisplayServer.window_get_size()
	for i in res_button.item_count:
		if resolutions.values()[i] == current_res:
			res_button.selected = i


func _on_resolution_selected(index: int):
	var selected_res_text = res_button.get_item_text(index)
	var target_size = resolutions[selected_res_text]

	DisplayServer.window_set_size(target_size)
	var screen_center = DisplayServer.screen_get_position() + (DisplayServer.screen_get_size() / 2)
	DisplayServer.window_set_position(screen_center - (target_size / 2))
	ConfigManager.save_resolution(target_size.x, target_size.y)


func _process(_delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://escenes/decks.tscn")


func _on_history_pressed() -> void:
	get_tree().change_scene_to_file("res://escenes/history_menu.tscn")


func _on_language_selected(index: int):
	match index:
		0:
			ConfigManager.save_language("en")
		1:
			ConfigManager.save_language("es")
	get_tree().reload_current_scene()
