extends Button

@export var description_label: Label
@export var hover_text: String = ""
@export_enum("STORE_ADD", "STORE_REMOVE", "STORE_UPGRADE") var mode: String

@export var footer_node: Control
@export var next_button: Button

@onready var shelf: Control = get_tree().get_root().find_child("ItemShelf", true, false)

var player: GamePlayer = GlobalData.player
var cpu: GameCPU = GlobalData.cpu

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	pivot_offset = size / 2

func _on_mouse_entered() -> void:
	create_tween().tween_property(self , "scale", Vector2(1.1, 1.1), 0.1)
	if description_label:
		description_label.text = hover_text

func _on_mouse_exited() -> void:
	create_tween().tween_property(self , "scale", Vector2(1.0, 1.0), 0.1)
	if description_label:
		description_label.text = ""
		description_label.add_theme_color_override("font_color", Color.BLACK)

func _on_pressed() -> void:
	var selected_card: CardData = shelf.selected_card_data
	var selected_index: int = shelf.selected_card_index
	var action_success: bool = false
	match mode:
		"STORE_ADD":
			if selected_card:
				player.add_card_to_deck(selected_card)
				cpu.add_card_to_deck()
				action_success = true
		"STORE_REMOVE":
			if selected_index != -1:
				player.remove_card_from_deck(selected_index)
				cpu.remove_card_from_deck()
				shelf.selected_card_index = -1
				shelf.selected_card_data = null
				action_success = true
		"STORE_UPGRADE":
			if selected_index != -1 and selected_card and selected_card.upgradeable():
				player.upgrade_card_in_deck(selected_index)
				cpu.upgrade_card_in_deck()
				action_success = true
			else:
				description_label.text = tr("STORE_INVALID_UPGRADE")
				description_label.add_theme_color_override("font_color", Color.RED)
				var tween: Tween = create_tween()
				tween.tween_property(description_label, "position:x", description_label.position.x + 10, 0.075)
				tween.tween_property(description_label, "position:x", description_label.position.x - 10, 0.075)
				tween.set_loops(2)
	shelf.mostrar_cartas()
	if action_success:
		finalize_transaction()

func finalize_transaction() -> void:
	if footer_node:
		footer_node.visible = false
	if next_button:
		next_button.visible = true
	if description_label:
		description_label.text = tr(mode)
		description_label.add_theme_color_override("font_color", Color.GREEN)


func _on_next_round_button_pressed() -> void:
	SceneLoader.load_scene("res://scenes/combat.tscn")
