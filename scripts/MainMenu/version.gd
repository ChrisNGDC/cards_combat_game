extends Label


func _ready() -> void:
	var file = FileAccess.open("res://version.txt", FileAccess.READ)
	if file:
		text = file.get_as_text().strip_edges()


func _process(_delta: float) -> void:
	pass
