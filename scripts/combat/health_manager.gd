extends Control

@onready var player_bar: TextureProgressBar = $PlayerHP
@onready var cpu_bar: TextureProgressBar = $CpuHP
@onready var player_hp_label: Label = $PlayerHP/HPLabel
@onready var cpu_hp_label: Label = $CpuHP/HPLabel


func _ready() -> void:
	setup_hp()
	GlobalData.player.hp_changed.connect(_on_hp_updated)
	GlobalData.cpu.hp_changed.connect(_on_hp_updated)


func _process(_delta: float) -> void:
	update_player_hp_label()
	update_cpu_hp_label()


func _on_hp_updated(valor: int, es_jugador: bool) -> void:
	if es_jugador:
		animar_cambio_vida(player_bar, valor)
	else:
		animar_cambio_vida(cpu_bar, valor)


func animar_cambio_vida(barra: TextureProgressBar, nuevo_valor: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(barra, "value", nuevo_valor, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func setup_hp() -> void:
	player_bar.max_value = GlobalData.player.max_hp
	player_bar.value = GlobalData.player.current_hp
	cpu_bar.max_value = GlobalData.cpu.max_hp
	cpu_bar.value = GlobalData.cpu.current_hp
	update_player_hp_label()
	update_cpu_hp_label()


func update_player_hp_label() -> void:
	player_hp_label.text = str(int(player_bar.value)) + " / " + str(int(player_bar.max_value))


func update_cpu_hp_label() -> void:
	cpu_hp_label.text = str(int(cpu_bar.value)) + " / " + str(int(cpu_bar.max_value))
