extends Area3D

var collected = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if collected:
		return
	if body.is_in_group("player"):
		collected = true
		var gm = get_node_or_null("%GameManager")
		if gm and gm.has_method("add_point"):
			gm.add_point()
		var tween = create_tween()
		tween.tween_property($MeshInstance3D, "scale", Vector3.ZERO, 0.2)
		tween.tween_callback(queue_free)
