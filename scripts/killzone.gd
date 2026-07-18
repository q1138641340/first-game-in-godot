extends Area2D

func _on_body_entered(body):
	if not body.is_in_group("player") or not body.has_method("die"):
		return

	var enemy = get_parent()
	var is_stomp_from_above = (
		enemy.has_method("die")
		and body.velocity.y > 0
		and body.global_position.y < enemy.global_position.y
	)
	if is_stomp_from_above:
		return

	body.die()
