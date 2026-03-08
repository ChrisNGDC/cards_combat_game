extends Button

@export var description_label: Label
@export var hover_text: String = ""
@export_enum("STORE_ADD", "STORE_REMOVE", "STORE_UPGRADE") var mode: String

@export var footer_node: Control
@export var next_button: Button

@onready var shelf = get_tree().get_root().find_child("ItemShelf", true, false)

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	pivot_offset = size / 2

func _on_mouse_entered():
	create_tween().tween_property(self , "scale", Vector2(1.1, 1.1), 0.1)
	if description_label:
		description_label.text = hover_text

func _on_mouse_exited():
	create_tween().tween_property(self , "scale", Vector2(1.0, 1.0), 0.1)
	if description_label:
		description_label.text = ""
		description_label.add_theme_color_override("font_color", Color.BLACK)

func _on_pressed():
	var selected_data = shelf.selected_card_data
	var selected_index = shelf.selected_card_index
	var action_success = false
	match mode:
		"STORE_ADD":
			if selected_data:
				var player_new_card = GlobalData.create_card(selected_data.nombre, [0, selected_data.nivel_max])
				var cpu_card = GlobalData.cpu_deck.cartas.pick_random()
				var cpu_new_card = GlobalData.create_card(cpu_card.nombre, [0, cpu_card.nivel_max])
				GlobalData.player_deck.cartas.append(player_new_card)
				GlobalData.cpu_deck.cartas.append(cpu_new_card)
				action_success = true
		"STORE_REMOVE":
			if selected_index != -1:
				GlobalData.player_deck.cartas.remove_at(selected_index)
				var cpu_card_pos = randi() % GlobalData.cpu_deck.cartas.size()
				GlobalData.cpu_deck.cartas.remove_at(cpu_card_pos)
				shelf.selected_card_index = -1
				shelf.selected_card_data = null
				action_success = true
		"STORE_UPGRADE":
			if selected_index != -1 and selected_data and selected_data.upgradeable():
				GlobalData.player_deck.cartas[selected_index].upgrade()
				var cpu_card_pos = randi() % GlobalData.cpu_deck.cartas.size()
				while not GlobalData.cpu_deck.cartas[cpu_card_pos].upgradeable():
					cpu_card_pos = randi() % GlobalData.cpu_deck.cartas.size()
				GlobalData.cpu_deck.cartas[cpu_card_pos].upgrade()
				action_success = true
			else:
				description_label.text = tr("STORE_INVALID_UPGRADE")
				description_label.add_theme_color_override("font_color", Color.RED)
				var tween = create_tween()
				tween.tween_property(description_label, "position:x", description_label.position.x + 10, 0.075)
				tween.tween_property(description_label, "position:x", description_label.position.x - 10, 0.075)
				tween.set_loops(2)
	shelf.mostrar_cartas()
	if action_success:
		finalize_transaction()

func finalize_transaction():
	if footer_node:
		footer_node.visible = false
	if next_button:
		next_button.visible = true
	if description_label:
		description_label.text = tr(mode)
		description_label.add_theme_color_override("font_color", Color.GREEN)


func _on_next_round_button_pressed() -> void:
	get_tree().change_scene_to_file("res://escenes/combat.tscn")
