extends CanvasLayer


signal loading_screen_ready

@export var animation_player: AnimationPlayer
@export var progress_bar: ProgressBar

func _ready() -> void:
	await animation_player.animation_finished
	progress_bar.visible = true
	loading_screen_ready.emit()


func _on_progress_changed(progress: float) -> void:
	progress_bar.value = progress

func _on_load_finished() -> void:
	await get_tree().create_timer(0.5).timeout
	progress_bar_transition()
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()

func progress_bar_transition() -> void:
	create_tween().tween_property(progress_bar, "modulate:a", 0, 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)