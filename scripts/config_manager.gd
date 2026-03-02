extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready():
	load_settings()

func save_resolution(width: int, height: int):
	config.set_value("video", "width", width)
	config.set_value("video", "height", height)
	config.save(SETTINGS_PATH)

func load_settings():
	var err = config.load(SETTINGS_PATH)
	
	if err != OK:
		return

	var w = config.get_value("video", "width", 640)
	var h = config.get_value("video", "height", 480)
	
	DisplayServer.window_set_size(Vector2i(w, h))
	var screen_center = DisplayServer.screen_get_position() + (DisplayServer.screen_get_size() / 2)
	DisplayServer.window_set_position(screen_center - (Vector2i(w, h) / 2))
