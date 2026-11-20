class_name TooltipFollower
extends RefCounted


static func follow(tooltip: Control, source: CanvasItem, offset: Vector2) -> void:
	var mouse_pos: Vector2 = source.get_global_mouse_position()
	var screen_size: Vector2 = source.get_viewport_rect().size
	var tooltip_size: Vector2 = tooltip.get_global_rect().size
	var final_offset: Vector2 = offset

	if mouse_pos.x + final_offset.x + tooltip_size.x > screen_size.x:
		final_offset.x = -tooltip_size.x

	if mouse_pos.y + final_offset.y + tooltip_size.y > screen_size.y:
		final_offset.y = -tooltip_size.y

	tooltip.global_position = mouse_pos + final_offset