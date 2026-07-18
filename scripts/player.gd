extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 3
const SCARE_SOUND = preload("res://assets/sounds/scare.wav")

var jumps_left = MAX_JUMPS
var is_stomping = false
var is_dead = false
var was_on_floor = true
var _scare_overlay: CanvasLayer
var _scare_audio: AudioStreamPlayer
var _shake_tween: Tween
var _scare_active = false
var _camera_original_offset = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var stomp_detector = $StompDetector
@onready var jump_sound = $JumpSound
@onready var hurt_sound = $HurtSound
@onready var particles = $ParticleEmitter
@onready var camera = $Camera2D

func _ready():
	add_to_group("player")
	_camera_original_offset = camera.offset

func _physics_process(delta):
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_left = MAX_JUMPS
		is_stomping = false

	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		jump_sound.play()
		if not _scare_active and randi() % 2 == 0:
			_trigger_scare()

	var direction = Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		animated_sprite.play("idle" if direction == 0 else "run")
	else:
		animated_sprite.play("jump")

	if is_on_floor() and not was_on_floor:
		particles.burst_white()
	was_on_floor = is_on_floor()

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var was_falling = velocity.y > 0
	move_and_slide()
	if was_falling:
		_handle_stomps()

func _handle_stomps():
	var targets = stomp_detector.get_overlapping_areas()
	targets.append_array(stomp_detector.get_overlapping_bodies())
	var handled = {}

	for target in targets:
		var enemy = target
		if target.get_parent() and target.get_parent().has_method("die"):
			enemy = target.get_parent()
		if enemy == self or not enemy.has_method("die"):
			continue
		var enemy_id = enemy.get_instance_id()
		if handled.has(enemy_id):
			continue
		handled[enemy_id] = true
		velocity.y = -200.0
		is_stomping = true
		enemy.die()

func _trigger_scare():
	if _scare_active or is_dead:
		return
	_scare_active = true

	_scare_overlay = CanvasLayer.new()
	_scare_overlay.name = "ScareOverlay"
	_scare_overlay.layer = 128
	var image = TextureRect.new()
	image.texture = preload("res://assets/sprites/scare.png")
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_scare_overlay.add_child(image)
	add_child(_scare_overlay)

	_scare_audio = AudioStreamPlayer.new()
	_scare_audio.stream = SCARE_SOUND
	add_child(_scare_audio)
	_scare_audio.play()

	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween().set_loops(6)
	_shake_tween.tween_property(camera, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.03)
	_shake_tween.tween_property(camera, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.03)

	await get_tree().create_timer(0.35).timeout
	_cleanup_scare()

func _cleanup_scare():
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = null
	if is_instance_valid(camera):
		camera.offset = _camera_original_offset
	if is_instance_valid(_scare_overlay):
		_scare_overlay.queue_free()
	_scare_overlay = null
	if is_instance_valid(_scare_audio):
		_scare_audio.queue_free()
	_scare_audio = null
	_scare_active = false

func die():
	if is_dead:
		return
	var manager = get_node_or_null("%GameManager")
	if manager and manager.is_finished:
		return
	is_dead = true
	_cleanup_scare()
	hurt_sound.play()
	Engine.time_scale = 0.5
	animated_sprite.visible = false
	if manager:
		manager.show_death()
	await get_tree().create_timer(1.0, true, false, true).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func _exit_tree():
	Engine.time_scale = 1.0
