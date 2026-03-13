extends Control

@onready var player_bar: TextureProgressBar = $PlayerHP
@onready var cpu_bar: TextureProgressBar = $CpuHP
@onready var player_hp_label: Label = $PlayerHP/HPLabel
@onready var cpu_hp_label: Label = $CpuHP/HPLabel

var player_display_hp: int
var cpu_display_hp: int

var player_max_hp: int = GlobalData.player.max_hp
var cpu_max_hp: int = GlobalData.cpu.max_hp

func _ready() -> void:
	player_bar.value = player_max_hp
	cpu_bar.value = cpu_max_hp
	GlobalData.player.hp_changed.connect(_on_hp_updated)
	GlobalData.cpu.hp_changed.connect(_on_hp_updated)
	setup_hp()

func _process(_delta: float) -> void:
	update_player_hp_label()
	update_cpu_hp_label()

func _on_hp_updated(valor: int, es_jugador: bool) -> void:
	if es_jugador:
		animar_cambio_vida(player_bar, valor)
		animar_cambio_cant_vida(true, valor)
	else:
		animar_cambio_vida(cpu_bar, valor)
		animar_cambio_cant_vida(false, valor)

func animar_cambio_vida(barra: TextureProgressBar, nuevo_valor: int) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(barra, "value", nuevo_valor, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func animar_cambio_cant_vida(es_jugador: bool, nuevo_valor: int) -> void:
	var tween: Tween = create_tween()
	if es_jugador:
		tween.tween_property(self , "player_display_hp", nuevo_valor, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		tween.tween_property(self , "cpu_display_hp", nuevo_valor, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func setup_hp() -> void:
	player_bar.max_value = player_max_hp
	player_bar.value = player_max_hp
	cpu_bar.max_value = cpu_max_hp
	cpu_bar.value = cpu_max_hp

	player_display_hp = player_max_hp
	cpu_display_hp = cpu_max_hp

	update_player_hp_label()
	update_cpu_hp_label()

func update_player_hp_label() -> void:
	player_hp_label.text = str(player_display_hp) + " / " + str(int(player_bar.max_value))

func update_cpu_hp_label() -> void:
	cpu_hp_label.text = str(cpu_display_hp) + " / " + str(int(cpu_bar.max_value))
