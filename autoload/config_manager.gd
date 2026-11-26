extends Node

const SETTINGS_PATH: String = "user://settings.cfg"

var config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	var err: int = config.load(SETTINGS_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_warning("Could not load settings file: " + SETTINGS_PATH)
	load_settings()


func _save_config() -> void:
	var err: int = config.save(SETTINGS_PATH)
	if err != OK:
		push_warning("Could not save settings file: " + SETTINGS_PATH)


func save_resolution(width: int, height: int) -> void:
	config.set_value("video", "width", width)
	config.set_value("video", "height", height)
	_save_config()


func save_fullscreen(is_full: bool) -> void:
	config.set_value("video", "fullscreen", is_full)
	_save_config()
	apply_fullscreen(is_full)


func apply_fullscreen(is_full: bool) -> void:
	if is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func load_resolution() -> Vector2i:
	var w: int = config.get_value("video", "width", 1280)
	var h: int = config.get_value("video", "height", 720)
	return Vector2i(w, h)


func center_window(resolution: Vector2i) -> void:
	DisplayServer.window_set_size(resolution)
	var screen_pos: Vector2i = DisplayServer.screen_get_position()
	var screen_center: Vector2i = screen_pos + Vector2i(DisplayServer.screen_get_size() / 2.0)
	DisplayServer.window_set_position(screen_center - Vector2i(resolution / 2.0))


func load_settings() -> void:
	var resolution: Vector2i = load_resolution()
	center_window(resolution)
	var is_full: bool = config.get_value("video", "fullscreen", false)
	apply_fullscreen(is_full)
	var lang: String = config.get_value("general", "language", "es")
	TranslationServer.set_locale(lang)
	AudioManager.set_master_volume(config.get_value("audio", "master", 1.0))
	AudioManager.set_music_volume(config.get_value("audio", "music", 1.0))
	AudioManager.set_sfx_volume(config.get_value("audio", "sfx", 1.0))


func save_language(locale: String) -> void:
	config.set_value("general", "language", locale)
	_save_config()
	TranslationServer.set_locale(locale)


func save_audio_volumes() -> void:
	config.set_value("audio", "master", AudioManager.get_master_volume())
	config.set_value("audio", "music", AudioManager.get_music_volume())
	config.set_value("audio", "sfx", AudioManager.get_sfx_volume())
	_save_config()
