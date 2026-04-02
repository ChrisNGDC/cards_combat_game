extends Node2D

var screen_size: Vector2
var card_being_dragged: Node2D
var card_original_pos: Vector2
var card_scene: PackedScene = preload("res://scenes/card.tscn")
var game_over_scene: PackedScene = preload("res://scenes/game_over_ui.tscn")
var overlay_scene: PackedScene = preload("res://scenes/deck_overlay.tscn")
var status_scene: PackedScene = preload("res://scenes/status.tscn")
var player_slot_pos: Vector2
var player_slot_rect: Rect2
var cpu_slot_pos: Vector2
var slot_scale: Vector2
var highlight_color: Color = Color(1.5, 1.5, 1.5, 0.6)
var normal_color: Color = Color(1, 1, 1, 0.4)
var card_in_slot: Node2D
var player_mazo_pos: Vector2
var cpu_mazo_pos: Vector2
var hand_size: int = 4
var last_hand_pos: int = 0
var fighting: bool
var dealing_hand: bool
var card_size: Vector2
var anchor_rect: Rect2
var return_tween: Tween
var player: GamePlayer = GlobalData.player
var cpu: GameCPU = GlobalData.cpu
var viewing_deck: bool
var player_discard_pos: Vector2
var cpu_discard_pos: Vector2

@onready var player_status: HFlowContainer = $PlayerStatus/StatusContainer
@onready var cpu_status: HFlowContainer = $CPUStatus/StatusContainer
@onready var player_card_slot: Sprite2D = $PlayerSlot
@onready var cpu_card_slot: Sprite2D = $CPUSlot
@onready var end_round_button: Button = $Control/EndRound
@onready var end_round_warning: Label = $Control/WarningEndLabel
@onready var see_deck_button: Button = $SeeDeckButton
@onready var fight_button: Button = $Control/Fight

func _ready() -> void:
	randomize()
	screen_size = get_viewport_rect().size
	player_slot_pos = player_card_slot.global_position
	cpu_slot_pos = cpu_card_slot.global_position
	player_card_slot.modulate = normal_color
	cpu_card_slot.modulate = normal_color
	slot_scale = player_card_slot.scale
	var slot_size: Vector2 = player_card_slot.texture.get_size() * slot_scale
	player_slot_rect = Rect2(player_card_slot.global_position - (slot_size / 2), slot_size)
	var card: Node2D = card_scene.instantiate()
	var card_borde: Sprite2D = card.get_node("Borde")
	card_size = card_borde.texture.get_size() * card_borde.scale * card.escala_grande
	card.queue_free()
	fighting = false
	if player.deck != null:
		player_mazo_pos = Vector2(270, screen_size.y - 150)
		player_discard_pos = Vector2(150, screen_size.y - 150)
		cpu_mazo_pos = Vector2(screen_size.x - 270, 150)
		cpu_discard_pos = Vector2(screen_size.x - 150, 150)
		player.deck.cartas.shuffle()
		cpu.deck.cartas.shuffle()
		crear_mazo(player.visual_deck, player_mazo_pos, true)
		crear_mazo(cpu.visual_deck, cpu_mazo_pos, false)
		await get_tree().create_timer(1.0).timeout
		repartir_mano(player.visual_deck, player.visual_hand, true)
		repartir_mano(cpu.visual_deck, cpu.visual_hand, false)
	see_deck_button.pressed.connect(_on_see_deck_button_pressed)
	end_round_button.pressed.connect(_on_end_round_pressed)
	fight_button.pressed.connect(_on_fight_pressed)
	end_of_round_update()
	

func _process(_delta: float) -> void:
	if card_being_dragged:
		card_being_dragged.position = get_global_mouse_position()
		var card_rect: Rect2 = Rect2(card_being_dragged.global_position - (card_size / 2), card_size)
		var debe_resaltar: bool = card_being_dragged and card_rect.intersects(player_slot_rect)
		var target_color: Color = highlight_color if debe_resaltar else normal_color
		var target_scale: Vector2 = slot_scale * 1.2 if debe_resaltar else slot_scale
		if player_card_slot.modulate != target_color:
			var tween: Tween = get_tree().create_tween()
			player_card_slot.modulate = target_color
			tween.tween_property(player_card_slot, "scale", target_scale, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		var tween: Tween = get_tree().create_tween()
		player_card_slot.modulate = normal_color
		tween.tween_property(player_card_slot, "scale", slot_scale, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card: Node2D = check_card_click()
			if return_tween and return_tween.is_running():
				return_tween.kill()
			if card and card.own_by_player and card.card_front.visible and (card != card_in_slot or not fighting) and not viewing_deck:
				card_being_dragged = card
				card_original_pos = card.position
				card_being_dragged.move_to_front()
				card_being_dragged.show_tooltip_info(false)
				show_cards_tooltip(false)
				anchor_rect = Rect2(card.anchor_pos - (card_size / 2), card_size)
		else:
			if card_being_dragged:
				check_drop_card()
				show_cards_tooltip(true)
				card_being_dragged = null

				
func crear_mazo(mazo: Array[Node2D], mazo_pos: Vector2, es_jugador: bool) -> void:
	var mazo_seleccionado: DeckData = player.deck if es_jugador else cpu.deck
	var cartas_mazo: Array[CardData] = mazo_seleccionado.cartas
	var cards_amount: int = cartas_mazo.size()
	var anchor_rel: int = 3
	for i: int in range(cards_amount):
		var nueva_carta: Node2D = card_scene.instantiate()
		add_child(nueva_carta)
		nueva_carta.setup(cartas_mazo[i], es_jugador, mazo_seleccionado.ruta_imagen)
		nueva_carta.anchor_pos = Vector2(0, 0)
		var offset_mazo: Vector2
		if es_jugador:
			if i >= cards_amount - 4:
				nueva_carta.anchor_pos = Vector2(screen_size.x * 0.35 + (anchor_rel * 130), screen_size.y - 150)
				anchor_rel -= 1
			offset_mazo = Vector2(i * 2.5, 0)
		else:
			nueva_carta.quitar_borde()
			if i >= cards_amount - 4:
				nueva_carta.anchor_pos = Vector2(screen_size.x * 0.65 - (anchor_rel * 130), 150)
				anchor_rel -= 1
			offset_mazo = Vector2(-i * 2.5, 0)
		nueva_carta.position = mazo_pos + offset_mazo
		mazo.append(nueva_carta)


func repartir_carta(mazo: Array[Node2D], mano: Array[Node2D], pos: Vector2, es_jugador: bool) -> void:
	var carta: Node2D = mazo.pop_back()
	if carta:
		mano.append(carta)
		if carta.anchor_pos == Vector2(0, 0):
			carta.anchor_pos = pos
		animar_vuelo_repartida(carta, carta.anchor_pos, es_jugador)


func repartir_mano(mazo: Array[Node2D], mano: Array[Node2D], es_jugador: bool) -> void:
	dealing_hand = true
	for i: int in range(min(hand_size, mazo.size())):
		repartir_carta(mazo, mano, Vector2(0, 0), es_jugador)
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
	else:
		carta.quitar_borde()
	tween.chain().tween_callback(func() -> void: carta.z_index = 2)


func check_drop_card() -> void:
	var card_rect: Rect2 = Rect2(card_being_dragged.global_position - (card_size / 2), card_size)
	if card_rect.intersects(player_slot_rect) and not fighting and not dealing_hand:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card_being_dragged, "position", player_slot_pos, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if !card_in_slot:
			card_in_slot = card_being_dragged
		else:
			tween.tween_property(card_in_slot, "position", card_in_slot.anchor_pos, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			card_in_slot.z_index = 2
			card_in_slot = card_being_dragged
	else:
		if return_tween:
			return_tween.kill()
		return_tween = create_tween()
		return_tween.tween_property(card_being_dragged, "position", card_being_dragged.anchor_pos, 0.75).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		card_being_dragged.z_index = 2
		if card_in_slot == card_being_dragged:
			card_in_slot = null
		if card_rect.intersects(anchor_rect):
			card_being_dragged.show_tooltip_info(true)
		

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
	for card: Node2D in player.visual_hand:
		card.show_tooltip = si


func flip_card(carta: Node2D) -> void:
	var flip_tween: Tween = get_tree().create_tween()
	flip_tween.tween_property(carta, "scale:x", 0.0, 0.5).set_ease(Tween.EASE_IN)
	carta.dar_borde()
	flip_tween.tween_callback(func() -> void: carta.show_card(true))
	flip_tween.tween_property(carta, "scale:x", carta.escala_normal.x, 0.5).set_ease(Tween.EASE_OUT)

# Combat logic

func combat(player_card: Node2D, cpu_card: Node2D) -> void:
	var primera: Node2D
	var segunda: Node2D
	var primero_en_jugar: Character
	var segundo_en_jugar: Character

	if player_card.tipo == "CARD_OFFENSIVE" and cpu_card.tipo != "CARD_OFFENSIVE":
		primera = cpu_card
		segunda = player_card
		primero_en_jugar = cpu
		segundo_en_jugar = player
	elif cpu_card.tipo == "CARD_OFFENSIVE" and player_card.tipo != "CARD_OFFENSIVE":
		primera = player_card
		segunda = cpu_card
		primero_en_jugar = player
		segundo_en_jugar = cpu
	elif player_card.nombre == "CARD_SWORD":
		primera = cpu_card
		segunda = player_card
		primero_en_jugar = cpu
		segundo_en_jugar = player
	else:
		primera = player_card
		segunda = cpu_card
		primero_en_jugar = player
		segundo_en_jugar = cpu

	var primero_can_play: bool = primero_en_jugar.can_play()
	var segundo_can_play: bool = segundo_en_jugar.can_play()

	var useless_first: bool = primera.nombre in ["CARD_MIRROR", "CARD_SHIELD"] and not segundo_can_play
	var useless_second: bool = segunda.nombre in ["CARD_MIRROR", "CARD_SHIELD"]

	var invalid_potion: bool = primera.nombre == "CARD_POTION" and segunda.tipo == "CARD_OFFENSIVE"
	var invalid_mirror: bool = primera.nombre == "CARD_MIRROR" and segunda.tipo_danio != "CARD_MAGICAL"
	var invalid_magic: bool = primera.nombre == "CARD_MAGIC" and segunda.nombre == "CARD_SWORD"
	var invalid_stun: bool = primera.nombre == "CARD_STUN" and segunda.tipo == "CARD_OFFENSIVE"
	var invalid_first: bool = invalid_potion or invalid_mirror or invalid_magic or invalid_stun

	var both_shield: bool = primera.nombre == "CARD_SHIELD" and segunda.nombre == "CARD_SHIELD"
	var both_mirror: bool = primera.nombre == "CARD_MIRROR" and segunda.nombre == "CARD_MIRROR"

	print("Primera carta: " + primera.nombre + " Segundo carta: " + segunda.nombre)
	print("Primero puede jugar: " + str(primero_can_play) + " Segundo puede jugar: " + str(segundo_can_play))

	if not both_shield and not both_mirror:
		if primero_can_play:
			if segundo_can_play:
				if not invalid_first:
					await play_card(primera, primero_en_jugar, segundo_en_jugar)
				await play_card(segunda, segundo_en_jugar, primero_en_jugar)
			elif not useless_first:
				await play_card(primera, primero_en_jugar, segundo_en_jugar)
		else:
			if segundo_can_play and not useless_second:
				await play_card(segunda, segundo_en_jugar, primero_en_jugar)
	else:
		await get_tree().create_timer(1).timeout

# Status logic

func end_of_round_update() -> void:
	update_visual_status()
	player.reset_turn()
	cpu.reset_turn()
	apply_status_effects()

func update_visual_status() -> void:
	for child: Control in player_status.get_children():
		child.queue_free()
	for child: Control in cpu_status.get_children():
		child.queue_free()
	for status: StatusData in player.status:
		var status_icon: Panel = status_scene.instantiate()
		status_icon.setup(status)
		player_status.add_child(status_icon)
	for status: StatusData in cpu.status:
		var status_icon: Panel = status_scene.instantiate()
		status_icon.setup(status)
		cpu_status.add_child(status_icon)
	player_status.get_parent().title = tr("STATUS") + " (" + str(player.status.size()) + ")"
	cpu_status.get_parent().title = tr("STATUS") + " (" + str(cpu.status.size()) + ")"

func apply_status_effects() -> void:
	player.apply_status_effects()
	cpu.apply_status_effects()

func play_card(card: Node2D, actor: Character, adversario: Character) -> void:
	var play_sound: bool = true
	match card.nombre:
		"CARD_SWORD":
			var amount: int = card.apply_effect()
			adversario.take_physical_damage(amount)
		"CARD_MAGIC":
			var amount: int = card.apply_effect()
			if adversario.has_rebound():
				play_sound = false
				adversario.remove_rebound()
				actor.take_magical_damage(amount)
				actor.add_status(StatusManager.create_status("STATUS_BURN"))
			else:
				adversario.take_magical_damage(amount)
				adversario.add_status(StatusManager.create_status("STATUS_BURN"))
		"CARD_SHIELD":
			var amount: int = card.apply_effect()
			actor.add_armor(amount)
		"CARD_MIRROR":
			actor.add_rebound()
		"CARD_POTION":
			var amount: int = card.apply_effect()
			actor.heal(amount)
			actor.add_status(StatusManager.create_status("STATUS_REGENERATION"))
		"CARD_STUN":
			var stun: StatusData = StatusManager.create_status("STATUS_STUN")
			adversario.add_status(stun)
	if play_sound:
		card.play_sound()
	await get_tree().create_timer(0.75).timeout


func cpu_choose_card() -> Node2D:
	var cpu_choice: Node2D = cpu.pick_card()
	if cpu_choice:
		animar_vuelo_repartida(cpu_choice, cpu_slot_pos, true)
		await get_tree().create_timer(1.5).timeout
	return cpu_choice
		

func cpu_use_card(cpu_choice: Node2D) -> void:
	var cpu_card_pos: Vector2 = cpu_choice.anchor_pos
	cpu_choice.show_tooltip_info(false)
	cpu.visual_hand.erase(cpu_choice)
	animar_vuelo_repartida(cpu_choice, cpu_discard_pos, false)
	if cpu.visual_hand.size() < hand_size and cpu.visual_deck.size() > 0:
		repartir_carta(cpu.visual_deck, cpu.visual_hand, cpu_card_pos, false)

func player_use_card(player_choice: Node2D) -> void:
	var player_card_pos: Vector2 = card_in_slot.anchor_pos
	player_choice.show_tooltip_info(false)
	player.visual_hand.erase(player_choice)
	animar_vuelo_repartida(player_choice, player_discard_pos, false)
	card_in_slot = null
	if player.visual_hand.size() < hand_size and player.visual_deck.size() > 0:
		repartir_carta(player.visual_deck, player.visual_hand, player_card_pos, true)
	

func _on_fight_pressed() -> void:
	if fighting or dealing_hand or viewing_deck:
		return
	if is_instance_valid(card_in_slot):
		fighting = true
		if player.visual_deck.size() == 0 and player.visual_hand.size() == hand_size:
			end_round_button.hide()
			end_round_warning.hide()
		var cpu_choice: Node2D = await cpu_choose_card()
		if cpu_choice:
			await combat(card_in_slot, cpu_choice)
			cpu_use_card(cpu_choice)
		else:
			play_card(card_in_slot, player, cpu)
		player_use_card(card_in_slot)
		if player.visual_deck.size() == 0 and player.visual_hand.size() == hand_size:
				end_round_button.show()
				end_round_warning.show()
				see_deck_button.hide()
	elif player.visual_hand.size() == 0 and cpu.visual_hand.size() > 0:
		fighting = true
		var cpu_choice: Node2D = await cpu_choose_card()
		play_card(cpu_choice, cpu, player)
		cpu_use_card(cpu_choice)
	fighting = false
	end_of_round_update()
	await get_tree().create_timer(0.5).timeout
	if not check_game_over():
		if player.visual_hand.size() == 0 and cpu.visual_hand.size() == 0:
			_on_end_round_pressed()
		else:
			if player.visual_hand.size() == 0:
				if player.visual_deck.size() > 0:
					repartir_mano(player.visual_deck, player.visual_hand, true)
			if cpu.visual_hand.size() == 0:
				if cpu.visual_deck.size() > 0:
					repartir_mano(cpu.visual_deck, cpu.visual_hand, false)


# Deck viewing logic

func _on_see_deck_button_pressed() -> void:
	if not dealing_hand:
		viewing_deck = true
		show_cards_tooltip(false)
		var overlay: CanvasLayer = overlay_scene.instantiate()
		add_child(overlay)
		overlay.closing.connect(_on_overlay_closed)
		overlay.display_deck(player.visual_deck)

func _on_overlay_closed() -> void:
	viewing_deck = false
	show_cards_tooltip(true)

# Game over logic

func check_game_over() -> bool:
	if player.current_hp > 0 and cpu.current_hp > 0:
		return false
	var won: bool = (player.current_hp > 0 and cpu.current_hp <= 0)
	show_game_over_ui(won)
	return true

func show_game_over_ui(won: bool) -> void:
	var instance: CanvasLayer = game_over_scene.instantiate()
	add_child(instance)
	instance.setup(won)
	var run_data: Dictionary = {
		"date": Time.get_datetime_string_from_system(false, true),
		"won": (player.current_hp > 0),
		"player_deck": {"name": player.deck.nombre, "cards": cards_to_save(player.deck.cartas)},
		"cpu_deck": {"name": cpu.deck.nombre, "cards": cards_to_save(cpu.deck.cartas)}
	}
	SaveManager.save_run(run_data)
	
func cards_to_save(deck: Array[CardData]) -> Array:
	var deck_cards: Array = []
	for card: CardData in deck:
		deck_cards.append({
			"tipo": card.nombre,
			"niveles": {
				"actual": card.nivel_actual,
				"max": card.nivel_max
			}
		})
	return deck_cards

# End round and transition to store

func _on_end_round_pressed() -> void:
	GlobalData.rounds += 1
	await get_tree().create_timer(.5).timeout
	GlobalData.player.reset_round()
	GlobalData.cpu.reset_round()
	SceneLoader.load_scene("res://scenes/store.tscn")