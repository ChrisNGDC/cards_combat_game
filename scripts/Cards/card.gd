extends Node2D

const COLOR_OFENSIVO: Color = Color(0.8, 0.2, 0.2)
const COLOR_DEFENSIVO: Color = Color(0.2, 0.2, 0.8)

@onready var borde: Sprite2D = $Borde
@onready var card_front: Node2D = $Front
@onready var card_name: Label = $Front/NameLabel
@onready var level_label: Label = $Front/UpgradeLabel
@onready var card_front_image: Sprite2D = $Front/Icon
@onready var card_back: Node2D = $Back
@onready var card_back_image: Sprite2D = $Back/CharacterImage
@onready var collision: Area2D = $Area2D

var tooltip_scene: PackedScene = preload("res://scenes/card_info_tooltip.tscn")
var gold_style: LabelSettings = preload("res://resources/max_level_label_settings.tres")
var basic_style: LabelSettings = preload("res://resources/basic_level_label_settings.tres")
var sword_hit_sound: Resource = preload("res://sounds/sword_hit.wav")
var shield_sound: Resource = preload("res://sounds/shield.wav")
var mirror_sound: Resource = preload("res://sounds/mirror.wav")
var potion_sound: Resource = preload("res://sounds/potion.wav")
var magic_sound: Resource = preload("res://sounds/magic.wav")
var stun_sound: Resource = preload("res://sounds/stun.wav")

var nombre: String
var tipo: String
var nivel_actual: int
var nivel_max: int
var tipo_danio: String
var escala_normal: Vector2 = Vector2(0.3, 0.3)
var escala_grande: Vector2 = Vector2(0.325, 0.325)
var datos_carta: CardData = null
var anchor_pos: Vector2
var own_by_player: bool
var selected: bool = false
var show_tooltip: bool = true
var current_tooltip: PanelContainer = null


func _ready() -> void:
	self.scale = escala_normal
	tree_exited.connect(_on_tree_exited)
	collision.mouse_entered.connect(_on_area_2d_mouse_entered)
	collision.mouse_exited.connect(_on_area_2d_mouse_exited)


func play_sound() -> void:
	match nombre:
		"CARD_SWORD":
			AudioManager.play_sfx(sword_hit_sound)
		"CARD_SHIELD":
			AudioManager.play_sfx(shield_sound)
		"CARD_MAGIC":
			AudioManager.play_sfx(magic_sound)
		"CARD_MIRROR":
			AudioManager.play_sfx(mirror_sound)
		"CARD_POTION":
			AudioManager.play_sfx(potion_sound)
		"CARD_STUN":
			AudioManager.play_sfx(stun_sound)
	

func _process(_delta: float) -> void:
	if current_tooltip:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var screen_size: Vector2 = get_viewport_rect().size
		var tooltip_size: Vector2 = current_tooltip.get_global_rect().size
		var offset: Vector2 = Vector2(20, 20)
		if mouse_pos.x + offset.x + tooltip_size.x > screen_size.x:
			offset.x = - tooltip_size.x
		if mouse_pos.y + offset.y + tooltip_size.y > screen_size.y:
			offset.y = - tooltip_size.y
			
		current_tooltip.global_position = mouse_pos + offset


func setup(datos: CardData, player: bool, deck_type: String = "") -> void:
	datos_carta = datos
	own_by_player = player
	if deck_type:
		card_back_image.texture = load(deck_type)
	show_card(false)
	_aplicar_datos()
	create_tooltip()


func show_card(si: bool) -> void:
	card_front.visible = si
	card_back.visible = !si


func create_tooltip() -> void:
	current_tooltip = tooltip_scene.instantiate()
	TooltipManager.add_child(current_tooltip)
	current_tooltip.setup(self )
	current_tooltip.hide()

func show_tooltip_info(si: bool) -> void:
	if si:
		current_tooltip.show()
	else:
		current_tooltip.hide()


func _aplicar_datos() -> void:
	var tex_front: Texture2D = load(datos_carta.ruta_imagen)
	card_front_image.texture = tex_front
	nombre = datos_carta.nombre
	card_name.get_node("AutoTranslate").set_translation(datos_carta.nombre)
	tipo = datos_carta.tipo
	nivel_actual = datos_carta.nivel_actual
	nivel_max = datos_carta.nivel_max
	tipo_danio = datos_carta.tipo_danio
	update_level_display()

func dar_borde() -> void:
	match tipo:
		"CARD_OFFENSIVE":
			borde.self_modulate = COLOR_OFENSIVO
		"CARD_DEFENSIVE":
			borde.self_modulate = COLOR_DEFENSIVO

func quitar_borde() -> void:
	borde.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
		
func update_level_display() -> void:
	if nivel_max > nivel_actual:
		if nivel_actual > 0:
			level_label.text = "+" + str(nivel_actual)
		else:
			level_label.text = ""
		level_label.label_settings = basic_style
	else:
		level_label.text = "Max"
		level_label.label_settings = gold_style

func _on_area_2d_mouse_entered() -> void:
	if self.card_front.visible:
		if self.own_by_player:
			borde.self_modulate *= 1.5
		if not self.selected:
			apply_scale_tween(self.escala_grande)
		if show_tooltip:
			show_tooltip_info(true)


func _on_area_2d_mouse_exited() -> void:
	if self.card_front.visible:
		if self.own_by_player:
			borde.self_modulate /= 1.5
		if not self.selected:
			apply_scale_tween(self.escala_normal)
		show_tooltip_info(false)

func apply_scale_tween(target_scale: Vector2) -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self , "scale", target_scale, 0.2)

func apply_effect() -> int:
	return datos_carta.actuar()


func _on_tree_exited() -> void:
	if current_tooltip:
		current_tooltip.queue_free()
