extends VBoxContainer

@onready var shelf: Control = $ScrollContainer/ItemShelf
@onready var footer_node: Control = $Footer
@onready var description_label: Label = $ActionHoverEffect
@onready var next_button: Button = $NextRoundButton
@onready var add_button: StoreButton = $Footer/Add
@onready var remove_button: StoreButton = $Footer/Remove
@onready var upgrade_button: StoreButton = $Footer/Upgrade

@onready var buttons: Array = [add_button, remove_button, upgrade_button]
var player: GamePlayer = GlobalData.player
var cpu: GameCPU = GlobalData.cpu

func _ready() -> void:
	connect_buttons_signals()


func connect_buttons_signals() -> void:
	for button: Button in buttons:
		button.mouse_entered.connect(_on_mouse_entered.bind(button, button.description))
		button.mouse_exited.connect(_on_mouse_exited)
		button.pressed.connect(_on_pressed.bind(button.mode))
		button.pivot_offset = button.size / 2
	next_button.pressed.connect(_on_next_round_button_pressed)

func _on_mouse_entered(button: Button, description: String) -> void:
	create_tween().tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	if description_label:
		description_label.text = tr(description)

func _on_mouse_exited() -> void:
	create_tween().tween_property(self , "scale", Vector2(1.0, 1.0), 0.1)
	if description_label:
		description_label.text = ""
		description_label.add_theme_color_override("font_color", Color.BLACK)

func _on_pressed(mode: String) -> void:
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
		finalize_transaction(mode)

func finalize_transaction(mode: String) -> void:
	if footer_node:
		footer_node.visible = false
	if next_button:
		next_button.visible = true
	if description_label:
		description_label.text = tr(mode)
		description_label.add_theme_color_override("font_color", Color.GREEN)


func _on_next_round_button_pressed() -> void:
	SceneLoader.load_scene("res://scenes/combat.tscn")
