extends CharacterBody2D

const SPEED = 100.0
const CHASE_SPEED = 170.0
const JUMP_VELOCITY = -320.0
const DETECT_RANGE = 400.0

var player = null
var _patrol_dir = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _jump_cooldown = 0.0

@onready var sprite = $AnimatedSprite2D

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
		sprite.play("jump")
	else:
		_jump_cooldown -= delta

	var dist = global_position.distance_to(player.global_position)
	var player_dir = 1 if player.global_position.x > global_position.x else -1
	var height_diff = global_position.y - player.global_position.y

	if dist < DETECT_RANGE:
		# Chase mode
		velocity.x = player_dir * CHASE_SPEED

		# Jump if player is above or there's a gap ahead
		var should_jump = false

		# Player is higher → jump to reach them
		if height_diff > 40:
			should_jump = true

		# Gap ahead → jump over it
		if not _is_ground_ahead(player_dir) and is_on_floor():
			should_jump = true

		# Random jump to navigate platforms
		if is_on_floor() and is_on_wall():
			should_jump = true

		if should_jump and is_on_floor() and _jump_cooldown <= 0.0:
			velocity.y = JUMP_VELOCITY
			_jump_cooldown = 0.4

		sprite.play("run")
	else:
		# Patrol mode
		if (player_dir > 0 and not _is_ground_ahead(1)) or (player_dir < 0 and not _is_ground_ahead(-1)):
			_patrol_dir = player_dir  # already facing player, just keep going
		velocity.x = player_dir * SPEED * 0.3
		sprite.play("idle")

	# Update sprite direction
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

	move_and_slide()

	# Kill player on contact
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col.get_collider() == player:
			if player.has_method("die"):
				player.die()

func _is_ground_ahead(dir):
	var check_pos = global_position + Vector2(dir * 20, 10)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(check_pos, check_pos + Vector2(0, 40))
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	return not result.is_empty()
