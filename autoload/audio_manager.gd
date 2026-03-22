extends Node

const MASTER_BUS_NAME: String = "Master"
const MUSIC_BUS_NAME: String = "Music"
const SOUND_EFFECTS_BUS_NAME: String = "SFX"

var master_bus_index: int = AudioServer.get_bus_index(MASTER_BUS_NAME)
var music_bus_index: int = AudioServer.get_bus_index(MUSIC_BUS_NAME)
var sfx_bus_index: int = AudioServer.get_bus_index(SOUND_EFFECTS_BUS_NAME)

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

func get_volume(bus_index: int) -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index)) * 2.5

func get_master_volume() -> float:
	return get_volume(master_bus_index)

func get_music_volume() -> float:
	return get_volume(music_bus_index)

func get_sfx_volume() -> float:
	return get_volume(sfx_bus_index)

func set_volume(bus_index: int, value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value / 2.5))
	AudioServer.set_bus_mute(bus_index, value < 0.01)

func set_master_volume(value: float) -> void:
	set_volume(master_bus_index, value)

func set_music_volume(value: float) -> void:
	set_volume(music_bus_index, value)

func set_sfx_volume(value: float) -> void:
	set_volume(sfx_bus_index, value)