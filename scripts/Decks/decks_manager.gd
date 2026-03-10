extends Node2D

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var deck_list: HBoxContainer = $ScrollContainer/DeckList

var dragging: bool = false
var last_mouse_pos: Vector2 = Vector2()
var deck_scene: PackedScene = preload("res://escenes/deck.tscn")
var lista_mazos: Array = GlobalData.decks_classes.keys()
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	if lista_mazos:
		crear_mazos_en_pantalla()

func crear_mazos_en_pantalla() -> void:
	for child: Node2D in deck_list.get_children():
		child.queue_free()
		
	for nombre: String in lista_mazos:
		var wrapper: Control = Control.new()
		wrapper.custom_minimum_size = Vector2(300, 350)
		wrapper.mouse_filter = Control.MOUSE_FILTER_PASS
		deck_list.add_child(wrapper)
		
		var nuevo_mazo: Node2D = deck_scene.instantiate()
		wrapper.add_child(nuevo_mazo)
		nuevo_mazo.position = wrapper.custom_minimum_size / 2
		
		nuevo_mazo.setup(GlobalData.create_deck(nombre))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var deck: Node2D = check_deck_click()
		if deck:
			GlobalData.player_deck = GlobalData.create_deck(deck.datos_mazo.nombre)
			GlobalData.init_hp(true, GlobalData.player_deck.vida)
			var cpu_deck_name: String = lista_mazos.pick_random()
			GlobalData.cpu_deck = GlobalData.create_deck(cpu_deck_name)
			GlobalData.init_hp(false, GlobalData.cpu_deck.vida)
			get_tree().change_scene_to_file("res://escenes/combat.tscn")
		else:
			dragging = event.pressed
			last_mouse_pos = event.position
	elif event is InputEventMouseMotion and dragging:
		var delta: Vector2 = event.position - last_mouse_pos
		scroll_container.scroll_horizontal -= delta.x
		last_mouse_pos = event.position

func check_deck_click() -> Node2D:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result: Array[Dictionary] = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
