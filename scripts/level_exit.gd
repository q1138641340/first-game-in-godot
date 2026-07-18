extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Walk up to find the Game scene root, then find GameManager
		var node = get_parent()
		while node:
			if node.has_node("GameManager"):
				var manager = node.get_node("GameManager")
				if manager.has_method("level_complete"):
					manager.level_complete()
				return
			node = node.get_parent()
