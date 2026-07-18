extends CharacterBody2D

const SPEED = 40.0
const CHASE_SPEED = 160.0
const DETECT_RANGE = 300.0

var player = null
var _patrol_dir = 1
var _is_dead = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $AnimatedSprite2D

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if _is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		move_and_slide()
		return

	var dist = global_position.distance_to(player.global_position)
	var direction = _patrol_dir

	if dist < DETECT_RANGE:
		# Chase player
		if player.global_position.x < global_position.x:
			direction = -1
		else:
			direction = 1
		velocity.x = direction * CHASE_SPEED
		sprite.play("chase")
	else:
		# Patrol: turn at edges
		if (direction > 0 and not _is_ground_ahead(1)) or (direction < 0 and not _is_ground_ahead(-1)):
			_patrol_dir *= -1
			direction = _patrol_dir
		velocity.x = direction * SPEED
		sprite.play("idle")

	if direction > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

	move_and_slide()

	# Check collision with player
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col.get_collider() == player:
			if player.velocity.y > 0 and player.global_position.y < global_position.y:
				continue
			if player.has_method("die"):
				player.die()

func _is_ground_ahead(dir):
	# Simple raycast check for ground ahead using a position offset
	var check_pos = global_position + Vector2(dir * 16, 20)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(check_pos, check_pos + Vector2(0, 30))
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	return not result.is_empty()

func die():
	if _is_dead:
		return
	_is_dead = true
	# Death animation: flip upside down and fade
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_property(sprite, "rotation", PI, 0.5)
	tween.tween_callback(queue_free)
	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
