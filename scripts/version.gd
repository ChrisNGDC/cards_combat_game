extends Label

func _ready() -> void:
    var path: String = "res://version.txt"
    if FileAccess.file_exists(path):
        var file: FileAccess = FileAccess.open(path, FileAccess.READ)
        var content: String = file.get_as_text().strip_edges()
        text = content
    else:
        text = "0.0.0-dev"