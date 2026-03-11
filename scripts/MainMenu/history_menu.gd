extends Control

@onready var list: VBoxContainer = $ScrollContainer/HistoryList
var entry_scene: PackedScene = preload("res://escenes/history_entry.tscn")
var overlay_scene: PackedScene = preload("res://escenes/deck_overlay.tscn")

func _ready() -> void:
	display_history()

func display_history() -> void:
	for child: HBoxContainer in list.get_children():
		child.queue_free()
		
	var history: Array = SaveManager.load_history()
	for run: Dictionary in history:
		var entry: HBoxContainer = entry_scene.instantiate()
		list.add_child(entry)
		entry.setup(run)
		entry.show_deck_requested.connect(_on_show_deck_requested)

func _on_show_deck_requested(deck_data: Array) -> void:
	var overlay: CanvasLayer = overlay_scene.instantiate()
	add_child(overlay)
	overlay.display_history_deck(deck_data)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://escenes/main_menu.tscn")
