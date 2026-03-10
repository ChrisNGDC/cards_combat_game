extends Control

@onready var player_bar: TextureProgressBar = $PlayerHP
@onready var cpu_bar: TextureProgressBar = $CpuHP
@onready var player_hp_label: Label = $PlayerHP/HPLabel
@onready var cpu_hp_label: Label = $CpuHP/HPLabel

var player_display_hp: int
var cpu_display_hp: int

func _ready() -> void:
	player_bar.value = GlobalData.player_max_hp
	cpu_bar.value = GlobalData.cpu_max_hp
	GlobalData.hp_changed.connect(_on_hp_updated)
	setup_hp()

func _process(_delta: float) -> void:
	update_player_hp_label()
	update_cpu_hp_label()

func _on_hp_updated(valor: int, es_jugador: bool) -> void:
	if es_jugador:
		player_bar.value = valor
		animar_cambio_vida(player_bar, valor)
		animar_cambio_cant_vida(true, valor)
	else:
		cpu_bar.value = valor
		animar_cambio_vida(cpu_bar, valor)
		animar_cambio_cant_vida(false, valor)

func animar_cambio_vida(barra: TextureProgressBar, nuevo_valor: int) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(barra, "value", nuevo_valor, 0.6).set_trans(Tween.TRANS_SINE)

func animar_cambio_cant_vida(es_jugador: bool, nuevo_valor: int) -> void:
	var tween: Tween = create_tween()
	if es_jugador:
		tween.tween_property(self , "player_display_hp", nuevo_valor, 0.7) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)
	else:
		tween.tween_property(self , "cpu_display_hp", nuevo_valor, 0.7) \
			.set_trans(Tween.TRANS_SINE) \
			.set_ease(Tween.EASE_IN_OUT)

func setup_hp() -> void:
	player_bar.max_value = GlobalData.player_max_hp
	player_bar.value = GlobalData.player_current_hp
	cpu_bar.max_value = GlobalData.cpu_max_hp
	cpu_bar.value = GlobalData.cpu_current_hp

	player_display_hp = GlobalData.player_current_hp
	cpu_display_hp = GlobalData.cpu_current_hp

	update_player_hp_label()
	update_cpu_hp_label()

func update_player_hp_label() -> void:
	player_hp_label.text = str(player_display_hp) + " / " + str(int(player_bar.max_value))

func update_cpu_hp_label() -> void:
	cpu_hp_label.text = str(cpu_display_hp) + " / " + str(int(cpu_bar.max_value))
