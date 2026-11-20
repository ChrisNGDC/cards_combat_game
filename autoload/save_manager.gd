extends Node

const SAVE_PATH: String = "user://run_history.save"
const VERSION: int = 2.0 # Update when changing save structure


func save_run(run_data: Dictionary) -> void:
	var history: Array = load_history()
	history.append(run_data)
	history.push_front(VERSION)
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open save file for writing: " + SAVE_PATH)
		return
	file.store_string(JSON.stringify(history))
	file.close()


func load_history() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open save file for reading: " + SAVE_PATH)
		return []
	var json_string: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		DirAccess.remove_absolute(SAVE_PATH)
		return []
	var parsed: Variant = json.get_data()
	if parsed is Array:
		var data: Array = parsed
		if not data.is_empty() and data[0] is float and data[0] == VERSION:
			return data.slice(1)
	DirAccess.remove_absolute(SAVE_PATH)
	return []
