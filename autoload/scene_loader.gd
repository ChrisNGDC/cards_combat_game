extends Node

const LOADING_SCENE: PackedScene = preload("res://scenes/loading_screen.tscn")

signal progress_changed(progress: float)
signal load_finished()

var loaded_resource: PackedScene
var scene_path: String
var progress: Array[float] = []
var use_sub_thread: bool = true
var is_loading: bool = false
var current_loading_screen: Node = null


func _ready() -> void:
	set_process(false)
	use_sub_thread = not OS.has_feature("web")


func load_scene(_scene_path: String) -> void:
	if is_loading:
		return
	is_loading = true
	scene_path = _scene_path
	current_loading_screen = LOADING_SCENE.instantiate()
	add_child(current_loading_screen)
	progress_changed.connect(current_loading_screen.on_progress_changed)
	load_finished.connect(current_loading_screen.on_load_finished)
	await current_loading_screen.loading_screen_ready
	start_load()


func start_load() -> void:
	var state: int = ResourceLoader.load_threaded_request(scene_path, "", use_sub_thread)
	if state == OK:
		set_process(true)
	else:
		push_error("Failed to start loading scene: " + scene_path)
		_abort_load()


func _process(_delta: float) -> void:
	var load_status: int = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("Failed to load scene: " + scene_path)
			set_process(false)
			_abort_load()
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			set_process(false)
			is_loading = false
			load_finished.emit()
			_disconnect_loading_screen()
			get_tree().change_scene_to_packed(loaded_resource)


func _disconnect_loading_screen() -> void:
	if current_loading_screen:
		if progress_changed.is_connected(current_loading_screen.on_progress_changed):
			progress_changed.disconnect(current_loading_screen.on_progress_changed)
		if load_finished.is_connected(current_loading_screen.on_load_finished):
			load_finished.disconnect(current_loading_screen.on_load_finished)
		current_loading_screen = null


func _abort_load() -> void:
	set_process(false)
	is_loading = false
	if current_loading_screen:
		current_loading_screen.queue_free()
	_disconnect_loading_screen()