extends CanvasLayer

@onready var FPS_counter: Label = $FPSLabel

func _process(_delta: float) -> void:
    FPS_counter.text = "FPS: " + str(Engine.get_frames_per_second())