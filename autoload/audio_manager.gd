extends Node

const MASTER_BUS_NAME: String = "Master"
const MUSIC_BUS_NAME: String = "Music"
const SOUND_EFFECTS_BUS_NAME: String = "SFX"

@onready var master_bus_index: int = AudioServer.get_bus_index(MASTER_BUS_NAME)
@onready var music_bus_index: int = AudioServer.get_bus_index(MUSIC_BUS_NAME)
@onready var sfx_bus_index: int = AudioServer.get_bus_index(SOUND_EFFECTS_BUS_NAME)

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var main_music: Resource = load("res://music/main_theme.ogg")

func _ready() -> void:
	add_child(music_player)
	music_player.bus = MUSIC_BUS_NAME
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_bgm(stream: AudioStream) -> void:
	if music_player.stream == stream:
		return
	music_player.stream = stream
	music_player.play()

func play_main_theme() -> void:
	play_bgm(main_music)

func play_sfx(stream: AudioStream) -> void:
	var instance: AudioStreamPlayer = AudioStreamPlayer.new()
	instance.stream = stream
	instance.bus = "SFX"
	
	add_child(instance)
	instance.play()
	instance.finished.connect(instance.queue_free)

func get_master_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))

func get_music_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))

func get_sfx_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))

func set_master_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus_index, value < 0.01)

func set_music_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus_index, value < 0.01)

func set_sfx_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_index, value < 0.01)