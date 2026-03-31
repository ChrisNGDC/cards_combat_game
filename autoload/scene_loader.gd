extends Node

signal progress_changed(progress: float)
signal load_finished()

var loading_scene: PackedScene = preload("res://scenes/loading_screen.tscn")
var loaded_resorce: PackedScene
var scene_path: String
var progress: Array
var use_sub_thread: bool = true

func _ready() -> void:
	set_process(false)


func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path
	
	var new_loading_scene: Node = loading_scene.instantiate()
	add_child(new_loading_scene)
	progress_changed.connect(new_loading_scene._on_progress_changed)
	load_finished.connect(new_loading_scene._on_load_finished)

	await new_loading_scene.loading_screen_ready
	start_load()

func start_load() -> void:
	var state: int = ResourceLoader.load_threaded_request(scene_path, "", use_sub_thread)
	if state == OK:
		set_process(true)
	else:
		push_error("Failed to start loading scene: " + scene_path)

func _process(_delta: float) -> void:
	var load_status: int = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Failed to load scene: " + scene_path)
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resorce = ResourceLoader.load_threaded_get(scene_path)
			set_process(false)
			load_finished.emit()
			get_tree().change_scene_to_packed(loaded_resorce)
