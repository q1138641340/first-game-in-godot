extends Area3D

var collected = false

func _ready():
	add_to_group("coin_3d")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if collected:
		return
	if body.is_in_group("player"):
		collected = true
		set_deferred("monitoring", false)
		var gm = get_tree().get_first_node_in_group("game_manager_3d")
		if gm and gm.has_method("add_point"):
			gm.add_point()
		var tween = create_tween()
		tween.tween_property($MeshInstance3D, "scale", Vector3.ZERO, 0.2)
		tween.tween_callback(queue_free)
