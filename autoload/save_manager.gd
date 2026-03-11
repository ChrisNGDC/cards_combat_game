extends Node

const SAVE_PATH: String = "user://run_history.save"

func save_run(run_data: Dictionary) -> void:
	var history: Array = load_history()
	history.append(run_data)
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(history))

func load_history() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	json.parse(json_string)
	return json.get_data()
