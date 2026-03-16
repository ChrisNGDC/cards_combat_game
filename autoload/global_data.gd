extends Node

var rounds: int = 1
var cpu: GameCPU
var player: GamePlayer

func _init() -> void:
	print("Creating actors")
	cpu = GameCPU.new()
	player = GamePlayer.new()

func reset_game() -> void:
	cpu.reset()
	player.reset()
