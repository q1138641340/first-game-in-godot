extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 8.0
const MAX_JUMPS = 3

var jumps_left = MAX_JUMPS
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var body_mesh = $SheepBody
@onready var stomp_area = $StompArea

func _ready():
	add_to_group("player")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		jumps_left = MAX_JUMPS

	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	if velocity.y < 0:
		var bodies = stomp_area.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("die"):
				velocity.y = 6.0
				body.die()

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			body_mesh.rotation.y = 0
		else:
			body_mesh.rotation.y = PI
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
