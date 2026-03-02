extends Node2D

var deck_scene = preload("res://escenes/deck.tscn")
var lista_mazos = [FighterDeck.new(), MageDeck.new(), PaladinDeck.new()]
var screen_size

func _ready() -> void:
	screen_size = get_viewport_rect().size
	if lista_mazos:
		crear_mazos_en_pantalla()

func crear_mazos_en_pantalla():
	for i in range(lista_mazos.size()):
		var nuevo_mazo = deck_scene.instantiate()
		add_child(nuevo_mazo)
		nuevo_mazo.setup(lista_mazos[i])
		nuevo_mazo.position = Vector2(400 + (i * 350), screen_size.y / 2)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var deck = check_deck_click()
			if deck:
				GlobalData.selected_deck = deck.datos_mazo
				get_tree().change_scene_to_file("res://escenes/combat.tscn")

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
