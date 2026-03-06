extends Label

func _ready():
    var path = "res://version.txt"
    if FileAccess.file_exists(path):
        var file = FileAccess.open(path, FileAccess.READ)
        var content = file.get_as_text().strip_edges()
        text = content
    else:
        text = "0.0.0-dev"