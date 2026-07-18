extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 3

var jumps_left = MAX_JUMPS
var is_stomping = false
var is_dead = false
var was_on_floor = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var stomp_detector = $StompDetector
@onready var jump_sound = $JumpSound
@onready var hurt_sound = $HurtSound
@onready var particles = $ParticleEmitter

func _physics_process(delta):
	if is_dead:
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_left = MAX_JUMPS
		is_stomping = false

	# Handle jump.
	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		jump_sound.play()

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")

	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Landing dust
	if is_on_floor() and not was_on_floor:
		particles.burst_white()
	was_on_floor = is_on_floor()

	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Check for enemy stomp — MUST be after move_and_slide so overlaps are up to date
	if velocity.y > 0:
		var areas = stomp_detector.get_overlapping_areas()
		for area in areas:
			var enemy = area
			if area.get_parent().has_method("die"):
				enemy = area.get_parent()
			if enemy.has_method("die"):
				velocity.y = -200
				is_stomping = true
				enemy.die()

func die():
	if is_dead:
		return
	is_dead = true
	hurt_sound.play()
	Engine.time_scale = 0.5
	animated_sprite.visible = false

	# Show death message through GameManager's UI
	var gm = %GameManager
	gm.show_death()

	await get_tree().create_timer(1.0).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
