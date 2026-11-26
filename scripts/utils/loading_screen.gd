extends CanvasLayer

signal loading_screen_ready

@onready var panel: Panel = $Panel
@onready var progress_bar: ProgressBar = $MarginContainer/ProgressBar


func _ready() -> void:
	panel.modulate = Color(1, 1, 1, 0)
	panel.scale = Vector2.ZERO
	panel.rotation = -TAU
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate", Color(0, 0, 0, 1), 0.5)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.5)
	tween.tween_property(panel, "rotation", 0.0, 0.5)
	await tween.finished
	progress_bar.modulate.a = 1
	loading_screen_ready.emit()


func on_progress_changed(progress: float) -> void:
	progress_bar.value = progress


func on_load_finished() -> void:
	await get_tree().create_timer(.3).timeout
	progress_bar_transition()

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_property(panel, "scale", Vector2.ZERO, 0.5)
	tween.tween_property(panel, "rotation", -TAU, 0.5)
	await tween.finished
	queue_free()


func progress_bar_transition() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(progress_bar, "modulate:a", 0, 0.3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)