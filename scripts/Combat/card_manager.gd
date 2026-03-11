extends Node2D

var screen_size: Vector2
var card_being_dragged: Node2D
var card_original_pos: Vector2
var card_scene: PackedScene = preload("res://scenes/card.tscn")
var game_over_scene: PackedScene = preload("res://scenes/game_over_ui.tscn")
var player_slot_pos: Vector2
var cpu_slot_pos: Vector2
var slot_scale: Vector2
var highlight_color: Color = Color(1.5, 1.5, 1.5, 0.6)
var normal_color: Color = Color(1, 1, 1, 0.4)
var card_in_slot: Node2D
var player_deck: Array[BaseCard]
var cpu_deck: Array[BaseCard]
var player_mazo_pos: Vector2
var cpu_mazo_pos: Vector2
var hand_size: int = 4
var cartas_mazo_player: Array[Node2D] = []
var cartas_mano_player: Array[Node2D] = []
var cartas_mazo_cpu: Array[Node2D] = []
var cartas_mano_cpu: Array[Node2D] = []
var last_hand_pos: int = 0
var fighting: bool
var dealing_hand: bool

@onready var player_card_slot: Sprite2D = $PlayerSlot
@onready var cpu_card_slot: Sprite2D = $CPUSlot
@onready var round_label: Label = $RoundLabel
@onready var end_round_button: Button = $Control/EndRound
@onready var end_round_warning: Label = $Control/WarningEndLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	screen_size = get_viewport_rect().size
	player_slot_pos = player_card_slot.global_position
	cpu_slot_pos = cpu_card_slot.global_position
	player_card_slot.modulate = normal_color
	cpu_card_slot.modulate = normal_color
	slot_scale = player_card_slot.scale
	fighting = false
	round_label.text = tr("COMBAT_ROUND") + " %d" % (GlobalData.rounds)
	if GlobalData.player_deck != null:
		player_mazo_pos = Vector2(160, screen_size.y - 100)
		cpu_mazo_pos = Vector2(screen_size.x - 160, 100)
		player_deck = GlobalData.player_deck.cartas
		cpu_deck = GlobalData.cpu_deck.cartas
		player_deck.shuffle()
		cpu_deck.shuffle()
		crear_mazo(cartas_mazo_player, player_mazo_pos, true)
		crear_mazo(cartas_mazo_cpu, cpu_mazo_pos, false)

		repartir_mano(cartas_mazo_player, cartas_mano_player, true)
		repartir_mano(cartas_mazo_cpu, cartas_mano_cpu, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if card_being_dragged:
		show_cards_tooltip(false)
		card_being_dragged.show_tooltip_info(false)
		card_being_dragged.position = get_global_mouse_position()
	var debe_resaltar: bool = card_being_dragged and card_being_dragged.position.distance_to(player_slot_pos) < 120
	var target_color: Color = highlight_color if debe_resaltar else normal_color
	var target_scale: Vector2 = slot_scale * 1.2 if debe_resaltar else slot_scale
	if player_card_slot.modulate != target_color:
		var tween: Tween = get_tree().create_tween()
		player_card_slot.modulate = target_color
		tween.tween_property(player_card_slot, "scale", target_scale, 0.1)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card: Node2D = check_card_click()
			if card and card.own_by_player and card.card_front.visible and (card != card_in_slot or not fighting):
				card_being_dragged = card
				card_original_pos = card.position
				card_being_dragged.move_to_front()
		else:
			if card_being_dragged:
				check_drop_card()
				show_cards_tooltip(true)
				card_being_dragged.show_tooltip_info(true)
				card_being_dragged = null
				

func crear_mazo(mazo: Array[Node2D], mazo_pos: Vector2, player: bool) -> void:
	var mazo_seleccionado: Array[BaseCard] = player_deck if player else cpu_deck
	var cards_amount: int = mazo_seleccionado.size()
	var anchor_rel: int = 0
	for i: int in range(cards_amount):
		var nueva_carta: Node2D = card_scene.instantiate()
		add_child(nueva_carta)
		nueva_carta.setup(mazo_seleccionado[i], player)
		nueva_carta.anchor_pos = Vector2(0, 0)
		var offset_mazo: Vector2
		if player:
			if i < 4:
				nueva_carta.anchor_pos = Vector2(screen_size.x / 3 + (anchor_rel * 160), screen_size.y - 150)
			offset_mazo = Vector2(i * -2, i * -2)
		else:
			nueva_carta.quitar_borde()
			if i < 4:
				nueva_carta.anchor_pos = Vector2(screen_size.x * 0.75 - (anchor_rel * 160), 150)
			offset_mazo = Vector2(i * +2, i * +2)
		nueva_carta.position = mazo_pos + offset_mazo
		mazo.append(nueva_carta)
		anchor_rel += 1


func repartir_carta(mazo: Array[Node2D], mano: Array[Node2D], pos: Vector2, player: bool) -> void:
	var carta: Node2D = mazo.pop_front()
	if carta:
		mano.append(carta)
		if carta.anchor_pos == Vector2(0, 0):
			carta.anchor_pos = pos
		animar_vuelo_repartida(carta, carta.anchor_pos, player)


func repartir_mano(mazo: Array[Node2D], mano: Array[Node2D], player: bool) -> void:
	dealing_hand = true
	for i: int in range(min(hand_size, mazo.size())):
		repartir_carta(mazo, mano, mazo[i].anchor_pos, player)
		await get_tree().create_timer(0.75).timeout
	dealing_hand = false


func animar_vuelo_repartida(carta: Node2D, destino: Vector2, flip: bool) -> void:
	var tween: Tween = get_tree().create_tween().set_parallel(true)
	carta.z_index = 100
	carta.show_card(false)
	carta.scale = carta.escala_normal
	tween.tween_property(carta, "position", destino, 1.0) \
	.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(carta, "rotation", 0, 1.0)
	if flip:
		flip_card(carta)
	tween.chain().tween_callback(func() -> void: carta.z_index = 2)


func check_drop_card() -> void:
	var distancia: float = card_being_dragged.position.distance_to(player_slot_pos)
	if distancia < 120 and not fighting and not dealing_hand:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card_being_dragged, "position", player_slot_pos, 0.1)
		if !card_in_slot:
			card_in_slot = card_being_dragged
		else:
			tween.tween_property(card_in_slot, "position", card_in_slot.anchor_pos, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			card_in_slot.z_index = 2
			card_in_slot = card_being_dragged
	else:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card_being_dragged, "position", card_being_dragged.anchor_pos, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_being_dragged.z_index = 2
		if card_in_slot == card_being_dragged:
			card_in_slot = null


func check_card_click() -> Node2D:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var parameters: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = 1
	var result: Array[Dictionary] = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null


func show_cards_tooltip(si: bool) -> void:
	for card: Node2D in cartas_mano_player:
		card.show_tooltip = si


func flip_card(carta: Node2D) -> void:
	var flip_tween: Tween = get_tree().create_tween()
	flip_tween.tween_property(carta, "scale:x", 0.0, 0.5).set_ease(Tween.EASE_IN)
	carta.dar_borde()
	flip_tween.tween_callback(func() -> void: carta.show_card(true))
	flip_tween.tween_property(carta, "scale:x", carta.escala_normal.x, 0.5).set_ease(Tween.EASE_OUT)


func combat(player_card: BaseCard, cpu_card: BaseCard) -> void:
	var primera: BaseCard
	var segunda: BaseCard
	var player_va_primero: bool

	var cpu_sword_prio: bool = (cpu_card.nombre == "CARD_SWORD" and player_card.nombre == "CARD_MAGIC")

	if (cpu_card.tipo == "CARD_OFFENSIVE" and player_card.tipo != "CARD_OFFENSIVE") or cpu_sword_prio:
		primera = cpu_card
		segunda = player_card
		player_va_primero = false
	else:
		primera = player_card
		segunda = cpu_card
		player_va_primero = true

	var invalid_potion: bool = primera.tipo == "CARD_OFFENSIVE" and segunda.nombre == "CARD_POTION"
	var invalid_mirror: bool = primera.tipo_danio == "CARD_PHYSICAL" and segunda.nombre == "CARD_MIRROR"
	var invalid_shield: bool = primera.tipo_danio == "CARD_MAGICAL" and segunda.nombre == "CARD_SHIELD"
	var invalid_magic: bool = primera.nombre == "CARD_SWORD" and segunda.nombre == "CARD_MAGIC"
	var invalid_second: bool = invalid_potion or invalid_mirror or invalid_shield or invalid_magic

	await play_card(primera, player_va_primero)

	if not invalid_second:
		await play_card(segunda, !player_va_primero)

	GlobalData.player_current_hp -= GlobalData.player_damage_to_recieve
	GlobalData.cpu_current_hp -= GlobalData.cpu_damage_to_recieve
	GlobalData.reset_damages()


func play_card(card: BaseCard, es_jugador: bool) -> void:
	match card.nombre:
		"CARD_SWORD":
			var damage: int = card.damage_amount()
			if es_jugador:
				GlobalData.cpu_damage_to_recieve += damage
			else:
				GlobalData.player_damage_to_recieve += damage
		"CARD_MAGIC":
			var damage: int = card.damage_amount()
			if es_jugador:
				GlobalData.cpu_damage_to_recieve += damage
			else:
				GlobalData.player_damage_to_recieve += damage
		"CARD_SHIELD":
			var damage: int = card.block_amount()
			if es_jugador:
				GlobalData.player_damage_to_recieve = max(0, GlobalData.player_damage_to_recieve - damage)
			else:
				GlobalData.cpu_damage_to_recieve = max(0, GlobalData.cpu_damage_to_recieve - damage)
		"CARD_MIRROR":
			if es_jugador:
				GlobalData.cpu_damage_to_recieve += GlobalData.player_damage_to_recieve
				GlobalData.player_damage_to_recieve = 0
			else:
				GlobalData.player_damage_to_recieve += GlobalData.cpu_damage_to_recieve
				GlobalData.cpu_damage_to_recieve = 0
		"CARD_POTION":
			var healing: int = card.heal_amount()
			if es_jugador:
				GlobalData.player_damage_to_recieve -= healing
			else:
				GlobalData.cpu_damage_to_recieve -= healing
	await get_tree().create_timer(0.5).timeout


func _on_fight_pressed() -> void:
	fighting = true
	if is_instance_valid(card_in_slot):
		if cartas_mazo_player.size() == 0 and cartas_mano_player.size() == hand_size:
			end_round_button.visible = false
			end_round_warning.visible = false
		var cpu_choice: Node2D = cartas_mano_cpu.pick_random()
		var cpu_card_pos: Vector2 = cpu_choice.anchor_pos
		var player_card_pos: Vector2 = card_in_slot.anchor_pos
		animar_vuelo_repartida(cpu_choice, cpu_slot_pos, true)
		await get_tree().create_timer(1.5).timeout
		await combat(card_in_slot.datos_carta, cpu_choice.datos_carta)
		card_in_slot.show_tooltip_info(false)
		cpu_choice.show_tooltip_info(false)
		cartas_mano_player.erase(card_in_slot)
		cartas_mano_cpu.erase(cpu_choice)
		card_in_slot.queue_free()
		cpu_choice.queue_free()
		if cartas_mano_player.size() < hand_size and cartas_mazo_player.size() > 0:
			repartir_carta(cartas_mazo_player, cartas_mano_player, player_card_pos, true)
		if cartas_mano_cpu.size() < hand_size and cartas_mazo_cpu.size() > 0:
			repartir_carta(cartas_mazo_cpu, cartas_mano_cpu, cpu_card_pos, false)
		if cartas_mazo_player.size() == 1 and cartas_mano_player.size() == 3:
			end_round_button.visible = true
			end_round_warning.visible = true
		
	if not check_game_over():
		if cartas_mano_player.size() == 0:
			if cartas_mazo_player.size() > 0:
				repartir_mano(cartas_mazo_player, cartas_mano_player, true)
				repartir_mano(cartas_mazo_cpu, cartas_mano_cpu, false)
			else:
				GlobalData.rounds += 1
				await get_tree().create_timer(.5).timeout
				SceneLoader.load_scene("res://scenes/store.tscn")
	fighting = false

func check_game_over() -> bool:
	if GlobalData.player_current_hp > 0 and GlobalData.cpu_current_hp > 0:
		return false
	var won: bool = (GlobalData.player_current_hp > 0 and GlobalData.cpu_current_hp <= 0)
	show_game_over_ui(won)
	return true

func show_game_over_ui(won: bool) -> void:
	var instance: CanvasLayer = game_over_scene.instantiate()
	add_child(instance)
	instance.setup(won)
	var run_data: Dictionary = {
		"date": Time.get_datetime_string_from_system(false, true),
		"won": (GlobalData.player_current_hp > 0),
		"player_deck": cards_to_save(GlobalData.player_deck.cartas),
		"cpu_deck": cards_to_save(GlobalData.cpu_deck.cartas)
	}
	SaveManager.save_run(run_data)
	
func cards_to_save(deck: Array[BaseCard]) -> Array:
	var deck_cards: Array = []
	for card: BaseCard in deck:
		deck_cards.append({
			"tipo": card.nombre,
			"datos": [card.nivel_actual, card.nivel_max]
		})
	return deck_cards


func _on_end_round_pressed() -> void:
	GlobalData.rounds += 1
	SceneLoader.load_scene("res://scenes/store.tscn")
