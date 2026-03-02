extends Control

@onready var list = $ScrollContainer/HistoryList
var entry_scene = preload("res://escenes/history_entry.tscn")
var overlay_scene = preload("res://escenes/deck_overlay.tscn")

func _ready():
	display_history()

func display_history():
	for child in list.get_children():
		child.queue_free()
		
	var history = SaveManager.load_history()
	for run in history:
		var entry = entry_scene.instantiate()
		list.add_child(entry)
		entry.setup(run)
		entry.show_deck_requested.connect(_on_show_deck_requested)

func _on_show_deck_requested(deck_data: Array):
	var overlay = overlay_scene.instantiate()
	add_child(overlay)
	overlay.display_deck(deck_data)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://escenes/main_menu.tscn")
