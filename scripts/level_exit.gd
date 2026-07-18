extends Area2D

func _on_body_entered(body):
	if body is CharacterBody2D:
		# Walk up to find the Game scene root, then find GameManager
		var node = get_parent()
		while node:
			if node.has_node("GameManager"):
				node.get_node("GameManager").level_complete()
				return
			node = node.get_parent()
