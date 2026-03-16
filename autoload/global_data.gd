extends Node

var rounds: int = 1
var cpu: GameCPU = GameCPU.new()
var player: GamePlayer = GamePlayer.new()

func reset_game() -> void:
	cpu.reset()
	player.reset()
