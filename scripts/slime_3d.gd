extends CharacterBody3D

const SPEED = 2.0
var direction = 1
var is_dead = false

@onready var mesh = $SlimeMesh

func _physics_process(delta):
	if is_dead:
		return
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	if is_on_wall():
		direction *= -1
		mesh.rotation.y += PI

	velocity.x = direction * SPEED
	move_and_slide()

func die():
	if is_dead:
		return
	is_dead = true
	$CollisionShape3D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(mesh, "scale", Vector3.ZERO, 0.2)
	tween.tween_callback(queue_free)
