extends Node2D

@onready var scroll_container = $ScrollContainer
@onready var deck_list = $ScrollContainer/DeckList

var dragging = false
var last_mouse_pos = Vector2()
var deck_scene = preload("res://escenes/deck.tscn")
var lista_mazos = [
	FighterDeck.new(),
	MageDeck.new(),
	PaladinDeck.new()
	]
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	if lista_mazos:
		crear_mazos_en_pantalla()

func crear_mazos_en_pantalla():
	for child in deck_list.get_children():
		child.queue_free()
		
	for data in lista_mazos:
		var wrapper = Control.new()
		wrapper.custom_minimum_size = Vector2(300, 350)
		wrapper.mouse_filter = Control.MOUSE_FILTER_PASS
		deck_list.add_child(wrapper)
		
		var nuevo_mazo = deck_scene.instantiate()
		wrapper.add_child(nuevo_mazo)
		nuevo_mazo.position = wrapper.custom_minimum_size / 2
		
		nuevo_mazo.setup(data)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var deck = check_deck_click()
		if deck:
			GlobalData.selected_deck = deck.datos_mazo
			get_tree().change_scene_to_file("res://escenes/combat.tscn")
		else:
			dragging = event.pressed
			last_mouse_pos = event.position
	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		scroll_container.scroll_horizontal -= delta.x
		last_mouse_pos = event.position

func check_deck_click() -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
