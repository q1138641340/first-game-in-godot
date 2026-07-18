extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	if body is CharacterBody2D:
		# Don't kill if player is stomping (flag set by player.gd)
		if body.get("is_stomping") == true:
			return
		# Extra check: if player's stomp detector is overlapping any area, it's a stomp
		if body.has_node("StompDetector"):
			var stomp = body.get_node("StompDetector")
			if stomp.get_overlapping_areas().size() > 0:
				body.set("is_stomping", true)
				return
		# Use player's die method if available
		if body.has_method("die"):
			body.die()
			return
	# Fallback for non-player bodies
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	timer.start()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
