extends Node

const SETTINGS_PATH: String = "user://settings.cfg"
var config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	load_settings()


func save_resolution(width: int, height: int) -> void:
	config.set_value("video", "width", width)
	config.set_value("video", "height", height)
	config.save(SETTINGS_PATH)

func save_fullscreen(is_full: bool) -> void:
	config.set_value("video", "fullscreen", is_full)
	config.save(SETTINGS_PATH)
	apply_fullscreen(is_full)

func apply_fullscreen(is_full: bool) -> void:
	if is_full:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func load_resolution() -> Vector2i:
	var res: int = config.load(SETTINGS_PATH)
	var w: int = 1280
	var h: int = 720

	if res == OK:
		w = config.get_value("video", "width", 1280)
		h = config.get_value("video", "height", 720)

	return Vector2i(w, h)


func load_settings() -> void:
	var resolution: Vector2i = load_resolution()
	DisplayServer.window_set_size(resolution)

	var screen_center: Vector2i = DisplayServer.screen_get_position() + Vector2i(DisplayServer.screen_get_size() / 2.0)
	DisplayServer.window_set_position(screen_center - Vector2i(resolution / 2.0))

	var is_full: bool = config.get_value("video", "fullscreen", false)
	apply_fullscreen(is_full)

	var lang: String = config.get_value("general", "language", "es")
	TranslationServer.set_locale(lang)

	AudioManager.set_master_volume(config.get_value("audio", "master", 1.0))
	AudioManager.set_music_volume(config.get_value("audio", "music", 1.0))
	AudioManager.set_sfx_volume(config.get_value("audio", "sfx", 1.0))


func save_language(locale: String) -> void:
	config.set_value("general", "language", locale)
	config.save(SETTINGS_PATH)
	TranslationServer.set_locale(locale)

func save_audio_volumes() -> void:
	config.set_value("audio", "master", AudioManager.get_master_volume())
	config.set_value("audio", "music", AudioManager.get_music_volume())
	config.set_value("audio", "sfx", AudioManager.get_sfx_volume())
	config.save(SETTINGS_PATH)
