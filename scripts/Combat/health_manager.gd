extends Control

@onready var player_bar = $PlayerHP
@onready var cpu_bar = $CpuHP

func _ready():
	player_bar.value = GlobalData.player_hp
	cpu_bar.value = GlobalData.cpu_hp
	GlobalData.hp_changed.connect(_on_hp_updated)

func _on_hp_updated(valor, es_jugador):
	if es_jugador:
		animar_cambio_vida(player_bar, valor)
	else:
		animar_cambio_vida(cpu_bar, valor)

func animar_cambio_vida(barra, nuevo_valor):
	var tween = get_tree().create_tween()
	tween.tween_property(barra, "value", nuevo_valor, 0.4).set_trans(Tween.TRANS_SINE)
