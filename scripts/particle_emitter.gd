extends Node2D
# Reusable particle emitter — call burst() to spawn colored dots

func burst(count: int = 8, color: Color = Color.WHITE, spread: float = 20.0, lifetime: float = 0.35):
	for i in range(count):
		var dot = ColorRect.new()
		dot.color = color
		dot.size = Vector2(3, 3)
		dot.position = Vector2(-1.5, -1.5)  # center the dot
		dot.z_index = 10
		add_child(dot)

		var tween = create_tween().set_parallel(true)
		var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		tween.tween_property(dot, "position", dot.position + dir * randf_range(spread * 0.4, spread), lifetime)
		tween.tween_property(dot, "color:a", 0.0, lifetime)
		tween.chain().tween_callback(dot.queue_free)

func burst_gold():   burst(8, Color.GOLD, 25.0)
func burst_green():  burst(6, Color.GREEN, 18.0)
func burst_white():  burst(5, Color.WHITE_SMOKE, 15.0)
