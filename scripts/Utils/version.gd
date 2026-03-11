extends Label

func _ready() -> void:
	var current_version: String = ProjectSettings.get_setting("application/config/version")
	if current_version:
		text = current_version
	else:
		text = "0.0.0dev"
