extends Node

var parent: Node
var current_key: String = ""
var current_args: Array = []

func _ready() -> void:
	parent = get_parent()
	current_key = parent.text
	_update_translation()

func set_translation(key: String, args: Array = []) -> void:
	current_key = key
	current_args = args
	_update_translation()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and parent:
		_update_translation()

func _update_translation() -> void:
	if current_key == "" or not parent:
		return
	var raw_translation: String = tr(current_key)
	var final_text: String = raw_translation
	if not current_args.is_empty():
		final_text = raw_translation % current_args
	parent.text = final_text