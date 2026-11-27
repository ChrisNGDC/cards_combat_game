extends Control

const ENTRY_SCENE: PackedScene = preload("res://scenes/history_entry.tscn")
const OVERLAY_SCENE: PackedScene = preload("res://scenes/deck_overlay.tscn")

@onready var list: VBoxContainer = $ScrollContainer/HistoryList
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	display_history()


func display_history() -> void:
	for child: HBoxContainer in list.get_children():
		child.queue_free()
		
	var history: Array = SaveManager.load_history()
	history.reverse()
	for run: Variant in history:
		if run is not Dictionary:
			continue
		var entry_data: Dictionary = run
		if not (entry_data.has("date") and entry_data.has("won") and entry_data.has("player_deck") and entry_data.has("cpu_deck")):
			continue
		if entry_data["player_deck"] is not Dictionary:
			continue
		var entry: HBoxContainer = ENTRY_SCENE.instantiate()
		list.add_child(entry)
		entry.setup(entry_data)
		entry.show_deck_requested.connect(_on_show_deck_requested)
		entry.delete_requested.connect(_on_delete_requested)


func _on_show_deck_requested(deck_data: Dictionary, items: Array) -> void:
	var overlay: CanvasLayer = OVERLAY_SCENE.instantiate()
	add_child(overlay)
	overlay.display_history_deck(deck_data, items)


func _on_delete_requested(run_data: Dictionary) -> void:
	var history: Array = SaveManager.load_history()
	for i: int in range(history.size()):
		if history[i] is Dictionary and history[i].get("date", "") == run_data.get("date", ""):
			SaveManager.delete_run(i)
			break
	display_history()


func _on_back_button_pressed() -> void:
	SceneLoader.load_scene("res://scenes/main_menu.tscn")