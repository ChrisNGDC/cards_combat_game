extends Node

const SAVE_PATH: String = "user://run_history.save"
const VERSION: int = 2.0 # Update when changing save structure

func save_run(run_data: Dictionary) -> void:
	var history: Array = load_history()
	history.append(run_data)
	history.push_front(VERSION)
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(history))

func load_history() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string: String = file.get_as_text()
	var json: JSON = JSON.new()
	json.parse(json_string)
	var data: Array = json.get_data()
	if data[0] is float and data[0] == VERSION:
		return data.slice(1)
	else:
		file.close()
		DirAccess.remove_absolute(SAVE_PATH)
		return []
