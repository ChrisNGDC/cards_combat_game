extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()


func _ready():
	load_settings()


func save_resolution(width: int, height: int):
	config.set_value("video", "width", width)
	config.set_value("video", "height", height)
	config.save(SETTINGS_PATH)

func save_fullscreen(is_full: bool):
	config.set_value("video", "fullscreen", is_full)
	config.save(SETTINGS_PATH)
	apply_fullscreen(is_full)

func apply_fullscreen(is_full: bool):
	if is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func load_resolution():
	var err = config.load(SETTINGS_PATH)

	if err != OK:
		return

	var w = config.get_value("video", "width", 1280)
	var h = config.get_value("video", "height", 720)

	return Vector2i(w, h)


func load_settings():
	var resolution = load_resolution()
	DisplayServer.window_set_size(resolution)
	var screen_center = DisplayServer.screen_get_position() + Vector2i(DisplayServer.screen_get_size() / 2.0)
	DisplayServer.window_set_position(screen_center - Vector2i(resolution / 2.0))

	var is_full = config.get_value("video", "fullscreen", false)
	apply_fullscreen(is_full)

	var lang = config.get_value("general", "language", "es")
	TranslationServer.set_locale(lang)


func save_language(locale: String):
	config.set_value("general", "language", locale)
	config.save(SETTINGS_PATH)
	TranslationServer.set_locale(locale)
