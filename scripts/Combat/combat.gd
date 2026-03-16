extends Node2D

var screen_size: Vector2
var card_being_dragged: Node2D
var card_original_pos: Vector2
var card_scene: PackedScene = preload("res://scenes/card.tscn")
var game_over_scene: PackedScene = preload("res://scenes/game_over_ui.tscn")
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

@onready var player: GamePlayer = GlobalData.player
@onready var cpu: GameCPU = GlobalData.cpu
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
	var slot_size: Vector2 = player_card_slot.texture.get_size() * slot_scale
	player_slot_rect = Rect2(player_card_slot.global_position - (slot_size / 2), slot_size)
	var card: Node2D = card_scene.instantiate()
	var card_borde: Sprite2D = card.get_node("Borde")
	card_size = card_borde.texture.get_size() * card_borde.scale * card.escala_grande
	card.queue_free()
	fighting = false
	round_label.text = tr("COMBAT_ROUND") + " %d" % (GlobalData.rounds)
	if player.deck != null:
		player_mazo_pos = Vector2(103.2, screen_size.y - 100)
		cpu_mazo_pos = Vector2(screen_size.x - 103.2, 100)
		player.deck.cartas.shuffle()
		cpu.deck.cartas.shuffle()
		crear_mazo(player.visual_deck, player_mazo_pos, true)
		crear_mazo(cpu.visual_deck, cpu_mazo_pos, false)
		await get_tree().create_timer(1.0).timeout
		repartir_mano(player.visual_deck, player.visual_hand, true)
		repartir_mano(cpu.visual_deck, cpu.visual_hand, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card: Node2D = check_card_click()
			if return_tween and return_tween.is_running():
				return_tween.kill()
			if card and card.own_by_player and card.card_front.visible and (card != card_in_slot or not fighting):
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
	var mazo_seleccionado: Array[CardData] = player.deck.cartas if es_jugador else cpu.deck.cartas
	var cards_amount: int = mazo_seleccionado.size()
	var anchor_rel: int = 3
	for i: int in range(cards_amount):
		var nueva_carta: Node2D = card_scene.instantiate()
		add_child(nueva_carta)
		nueva_carta.setup(mazo_seleccionado[i], es_jugador)
		nueva_carta.anchor_pos = Vector2(0, 0)
		var offset_mazo: Vector2
		if es_jugador:
			if i >= cards_amount - 4:
				nueva_carta.anchor_pos = Vector2(screen_size.x * 0.30875 + (anchor_rel * 163.2), screen_size.y - 150)
				anchor_rel -= 1
			offset_mazo = Vector2(i * 2.5, 0)
		else:
			nueva_carta.quitar_borde()
			if i >= cards_amount - 4:
				nueva_carta.anchor_pos = Vector2(screen_size.x * 0.69125 - (anchor_rel * 160.4), 150)
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
		repartir_carta(mazo, mano, mazo[i].anchor_pos, es_jugador)
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
	var card_rect: Rect2 = Rect2(card_being_dragged.global_position - (card_size / 2), card_size)
	if card_rect.intersects(player_slot_rect) and not fighting and not dealing_hand:
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(card_being_dragged, "position", player_slot_pos, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if !card_in_slot:
			card_in_slot = card_being_dragged
		else:
			tween.tween_property(card_in_slot, "position", player_slot_pos, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
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


func combat(player_card: CardData, cpu_card: CardData) -> void:
	var primera: CardData
	var segunda: CardData
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

	player.take_damage()
	cpu.take_damage()


func play_card(card: CardData, es_jugador: bool) -> void:
	match card.nombre:
		"CARD_SWORD":
			var damage: int = card.efecto.call(card.nivel_actual)
			if es_jugador:
				cpu.damage_to_receive += damage
			else:
				player.damage_to_receive += damage
		"CARD_MAGIC":
			var damage: int = card.efecto.call(card.nivel_actual)
			if es_jugador:
				cpu.damage_to_receive += damage
			else:
				player.damage_to_receive += damage
		"CARD_SHIELD":
			var damage: int = card.efecto.call(card.nivel_actual)
			if es_jugador:
				player.damage_to_receive = max(0, player.damage_to_receive - damage)
			else:
				cpu.damage_to_receive = max(0, cpu.damage_to_receive - damage)
		"CARD_MIRROR":
			if es_jugador:
				cpu.damage_to_receive += player.damage_to_receive
				player.damage_to_receive = 0
			else:
				player.damage_to_receive += cpu.damage_to_receive
				cpu.damage_to_receive = 0
		"CARD_POTION":
			var healing: int = card.efecto.call(card.nivel_actual)
			if es_jugador:
				player.damage_to_receive -= healing
			else:
				cpu.damage_to_receive -= healing
	await get_tree().create_timer(0.5).timeout


func _on_fight_pressed() -> void:
	print("is fighting: ", fighting, " dealing hand: ", dealing_hand)
	if is_instance_valid(card_in_slot) and not fighting and not dealing_hand:
		fighting = true
		print("inside fighting: ", fighting, "inside dealing hand: ", dealing_hand)
		if player.visual_deck.size() == 0 and player.visual_hand.size() == hand_size:
			end_round_button.hide()
			end_round_warning.hide()
		var cpu_choice: Node2D = cpu.pick_card()
		var cpu_card_pos: Vector2 = cpu_choice.anchor_pos
		var player_card_pos: Vector2 = card_in_slot.anchor_pos
		animar_vuelo_repartida(cpu_choice, cpu_slot_pos, true)
		await get_tree().create_timer(1.5).timeout
		await combat(card_in_slot.datos_carta, cpu_choice.datos_carta)
		card_in_slot.show_tooltip_info(false)
		cpu_choice.show_tooltip_info(false)
		player.visual_hand.erase(card_in_slot)
		cpu.visual_hand.erase(cpu_choice)
		card_in_slot.queue_free()
		cpu_choice.queue_free()
		if player.visual_hand.size() < hand_size and player.visual_deck.size() > 0:
			repartir_carta(player.visual_deck, player.visual_hand, player_card_pos, true)
		if cpu.visual_hand.size() < hand_size and cpu.visual_deck.size() > 0:
			repartir_carta(cpu.visual_deck, cpu.visual_hand, cpu_card_pos, false)
		if player.visual_deck.size() == 0 and player.visual_hand.size() == hand_size:
			end_round_button.show()
			end_round_warning.show()
		fighting = false

	if not check_game_over():
		if player.visual_hand.size() == 0:
			if player.visual_deck.size() > 0:
				repartir_mano(player.visual_deck, player.visual_hand, true)
				repartir_mano(cpu.visual_deck, cpu.visual_hand, false)
			else:
				GlobalData.rounds += 1
				await get_tree().create_timer(.5).timeout
				SceneLoader.load_scene("res://scenes/store.tscn")
	

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
		"player_deck": cards_to_save(GlobalData.player_deck.cartas),
		"cpu_deck": cards_to_save(cpu.deck.cartas)
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


func _on_end_round_pressed() -> void:
	GlobalData.rounds += 1
	SceneLoader.load_scene("res://scenes/store.tscn")
