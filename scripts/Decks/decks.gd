extends CanvasLayer

@onready var scroll_container: ScrollContainer = $MarginContainer/SelectionUI/HBoxDecks/ScrollContainer
@onready var deck_list: HBoxContainer = $MarginContainer/SelectionUI/HBoxDecks/ScrollContainer/MarginContainer/DeckList
@onready var select_deck_button: Button = $MarginContainer/SelectionUI/HBoxButtons/SelectDeckButton
@onready var view_deck_button: Button = $MarginContainer/SelectionUI/HBoxButtons/ViewDeckButton
@onready var left_arrow: TextureRect = $MarginContainer/SelectionUI/HBoxDecks/LeftArrow
@onready var right_arrow: TextureRect = $MarginContainer/SelectionUI/HBoxDecks/RightArrow
@onready var selection_ui: Control = $MarginContainer/SelectionUI
@onready var difficulty_ui: Control = $MarginContainer/DifficultyUI
@onready var difficulty_selection: Button = $MarginContainer/DifficultyUI/HBoxContainer/DifficultySelection
@onready var blank_selected_deck: Node2D = $MarginContainer/DifficultyUI/HBoxContainer/Control/Deck
@onready var fight_button: Button = $MarginContainer/DifficultyUI/Fight


var dragging: bool = false
var last_mouse_pos: Vector2 = Vector2()
var deck_scene: PackedScene = preload("res://scenes/deck.tscn")
var overlay_scene: PackedScene = preload("res://scenes/deck_overlay.tscn")
var lista_mazos: Array = DeckManager.decks_classes.keys()
var selected_deck: Node2D = null
var escala_normal: Vector2 = Vector2(0.25, 0.25)
var escala_grande: Vector2 = Vector2(0.3, 0.3)
var viewing_deck: bool = false
var difficulty: String


func _ready() -> void:
	select_deck_button.pressed.connect(_on_select_deck_button_pressed)
	view_deck_button.pressed.connect(_on_view_deck_button_pressed)
	fight_button.pressed.connect(_on_fight_pressed)
	difficulty_selection.item_selected.connect(_on_option_button_item_selected)
	select_deck_button.disabled = true
	view_deck_button.disabled = true
	if lista_mazos:
		crear_mazos_en_pantalla()

func crear_mazos_en_pantalla() -> void:
	for child: Node2D in deck_list.get_children():
		child.queue_free()
		
	for nombre: String in lista_mazos:
		var wrapper: Control = Control.new()
		wrapper.custom_minimum_size = Vector2(210, 310)
		wrapper.mouse_filter = Control.MOUSE_FILTER_STOP
		deck_list.add_child(wrapper)
		
		var nuevo_mazo: Node2D = deck_scene.instantiate()
		wrapper.add_child(nuevo_mazo)
		nuevo_mazo.position = wrapper.custom_minimum_size / 2
		nuevo_mazo.setup(DeckManager.create_deck(nombre))
		nuevo_mazo.scale = escala_normal

		wrapper.gui_input.connect(_on_deck_wrapper_input.bind(nuevo_mazo))
		wrapper.mouse_entered.connect(_on_deck_hover.bind(nuevo_mazo, true))
		wrapper.mouse_exited.connect(_on_deck_hover.bind(nuevo_mazo, false))

func _input(event: InputEvent) -> void:
	if !viewing_deck:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_pos = event.position
		elif event is InputEventMouseMotion and dragging:
			var delta: Vector2 = event.position - last_mouse_pos
			scroll_container.scroll_horizontal -= delta.x
			last_mouse_pos = event.position


func _on_select_deck_button_pressed() -> void:
	if selected_deck:
		blank_selected_deck.setup(selected_deck.datos_mazo)
		difficulty_selection.selected = 0
		selection_ui.hide()
		difficulty_ui.show()


func _on_fight_pressed() -> void:
	if difficulty_selection.selected != 0:
		GlobalData.player.deck = DeckManager.create_deck(selected_deck.datos_mazo.nombre)
		GlobalData.player.set_initial_hp()
		var cpu_deck_name: String = lista_mazos.pick_random()
		GlobalData.cpu.deck = DeckManager.create_deck(cpu_deck_name)
		GlobalData.cpu.difficulty = difficulty
		GlobalData.cpu._setup()
		SceneLoader.load_scene("res://scenes/combat.tscn")


func _on_view_deck_button_pressed() -> void:
	viewing_deck = true
	var overlay: CanvasLayer = overlay_scene.instantiate()
	add_child(overlay)
	overlay.closing.connect(_on_overlay_closed)
	overlay.display_deck_data(selected_deck.datos_mazo.cartas)


func _on_overlay_closed() -> void:
	viewing_deck = false


func _on_deck_wrapper_input(event: InputEvent, deck_node: Node2D) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selected_deck:
			selected_deck.modulate = Color.WHITE
		selected_deck = deck_node
		selected_deck.modulate = Color.CYAN
		select_deck_button.disabled = false
		view_deck_button.disabled = false

func _on_deck_hover(deck_node: Node2D, is_hovering: bool) -> void:
	var target_scale: Vector2 = escala_grande if is_hovering else escala_normal
	var tween: Tween = create_tween()
	tween.tween_property(deck_node, "scale", target_scale, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _process(_delta: float) -> void:
	var h_bar: HScrollBar = scroll_container.get_h_scroll_bar()
	var max_scroll: float = h_bar.max_value - scroll_container.size.x
	var target_left: float = 1.0 if scroll_container.scroll_horizontal > 0 else 0.0
	var target_right: float = 1.0 if scroll_container.scroll_horizontal < max_scroll else 0.0
	left_arrow.modulate.a = lerp(left_arrow.modulate.a, target_left, 0.1)
	right_arrow.modulate.a = lerp(right_arrow.modulate.a, target_right, 0.1)


func _on_option_button_item_selected(index: int) -> void:
	difficulty = difficulty_selection.get_item_text(index)
