extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	var manager = get_tree().get_first_node_in_group("game_manager_3d")
	if manager and manager.has_method("level_complete"):
		manager.level_complete()
