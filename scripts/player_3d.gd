extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 8.0
const MAX_JUMPS = 3

var jumps_left = MAX_JUMPS
var is_dead = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var body_mesh = $SheepBody
@onready var stomp_area = $StompArea

func _ready():
	add_to_group("player")

func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		jumps_left = MAX_JUMPS

	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		body_mesh.rotation.y = 0.0 if direction > 0 else PI
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = 0.0

	var was_falling = velocity.y < 0
	move_and_slide()
	global_position.z = 0.0
	_handle_enemy_contacts(was_falling)

func _handle_enemy_contacts(was_falling):
	var stomped = false
	if was_falling:
		for body in stomp_area.get_overlapping_bodies():
			if body != self and body.has_method("die"):
				body.die()
				stomped = true

	for index in range(get_slide_collision_count()):
		var collider = get_slide_collision(index).get_collider()
		if not collider or not collider.has_method("die"):
			continue
		if was_falling and global_position.y > collider.global_position.y:
			collider.die()
			stomped = true
		else:
			die()
			return

	if stomped:
		velocity.y = 6.0

func die():
	if is_dead:
		return
	var manager = get_tree().get_first_node_in_group("game_manager_3d")
	if manager and manager.is_finished:
		return
	is_dead = true
	body_mesh.visible = false
	if manager:
		manager.show_death()
	await get_tree().create_timer(1.0, true, false, true).timeout
	get_tree().reload_current_scene()
