extends Control

@onready var res_button: Button = $ResolutionButton
@onready var lang_button: Button = $LanguageButton
@onready var fullscreen_button: Button = $FullscreenButton


var resolutions: Dictionary = {
	"1152x648": Vector2i(1152, 648),
	"1280x720": Vector2i(1280, 720),
	"1366x768": Vector2i(1366, 768),
	"1536x864": Vector2i(1536, 864),
	"1600x900": Vector2i(1600, 900),
	"1920x1080": Vector2i(1920, 1080)
}


func _ready() -> void:
	if OS.has_feature("web"):
		res_button.hide()
	else:
		_fill_resolution_options()

	var is_full: bool = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	var current_locale: String = TranslationServer.get_locale()
	
	if current_locale.begins_with("es"):
		lang_button.selected = 1
	else:
		lang_button.selected = 0

	fullscreen_button.button_pressed = is_full
	res_button.disabled = is_full

	res_button.item_selected.connect(_on_resolution_selected)
	lang_button.item_selected.connect(_on_language_selected)
	fullscreen_button.toggled.connect(_on_fullscreen_toggled)


func _fill_resolution_options() -> void:
	res_button.clear()
	for res_text: String in resolutions.keys():
		res_button.add_item(res_text)

	var current_res: Vector2i = ConfigManager.load_resolution()
	for i: int in res_button.item_count:
		if resolutions.values()[i] == current_res:
			res_button.selected = i
			set_resolution(current_res)
			break


func _on_resolution_selected(index: int) -> void:
	var selected_res_text: String = res_button.get_item_text(index)
	var target_size: Vector2i = resolutions[selected_res_text]

	set_resolution(target_size)

func set_resolution(resolution: Vector2i) -> void:
	DisplayServer.window_set_size(resolution)
	var screen_center: Vector2i = DisplayServer.screen_get_position() + Vector2i(DisplayServer.screen_get_size() / 2.0)
	DisplayServer.window_set_position(screen_center - Vector2i(resolution / 2.0))
	ConfigManager.save_resolution(resolution.x, resolution.y)

func _on_fullscreen_toggled(is_pressed: bool) -> void:
	ConfigManager.save_fullscreen(is_pressed)
	res_button.disabled = is_pressed
	

func _process(_delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	SceneLoader.load_scene("res://scenes/decks.tscn")


func _on_history_pressed() -> void:
	SceneLoader.load_scene("res://scenes/history_menu.tscn")


func _on_language_selected(index: int) -> void:
	match index:
		0:
			ConfigManager.save_language("en")
		1:
			ConfigManager.save_language("es")
	get_tree().reload_current_scene()
