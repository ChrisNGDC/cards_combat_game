extends Node

var rounds: int = 1
var cpu: GameCPU
var player: GamePlayer

func _init() -> void:
	cpu = GameCPU.new()
	player = GamePlayer.new()

func reset_game() -> void:
	rounds = 1
	cpu.reset()
	player.reset()
