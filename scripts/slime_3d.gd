extends CharacterBody3D

const SPEED = 2.0
var direction = 1

@onready var mesh = $SlimeMesh

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	if is_on_wall():
		direction *= -1
		mesh.rotation.y += PI

	velocity.x = direction * SPEED
	move_and_slide()

func die():
	queue_free()
