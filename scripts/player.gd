extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 3

var jumps_left = MAX_JUMPS
var is_stomping = false
var _scare_overlay = null
var _scare_sound = null
var _shake_tween = null
var _scare_active = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var stomp_detector = $StompDetector

func _ready():
	add_to_group("player")
	_scare_sound = load("res://assets/sounds/scare.wav")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jumps_left = MAX_JUMPS
		is_stomping = false

	if Input.is_action_just_pressed("jump") and jumps_left > 0:
		velocity.y = JUMP_VELOCITY
		jumps_left -= 1
		# 50% chance jump scare (only if not already active)
		if not _scare_active and randi() % 2 == 0:
			_trigger_scare()

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

	var direction = Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _trigger_scare():
	if _scare_active:
		return
	_scare_active = true

	# Clean up any leftover overlay
	if _scare_overlay:
		_scare_overlay.queue_free()
		_scare_overlay = null

	# Play scare sound
	if _scare_sound:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = _scare_sound
		audio.bus = "SFX"
		add_child(audio)
		audio.play()
		await get_tree().create_timer(0.4).timeout
		audio.queue_free()

	# Show fullscreen scare image
	var canvas = CanvasLayer.new()
	canvas.layer = 128

	var tex_rect = TextureRect.new()
	tex_rect.texture = load("res://assets/sprites/scare.png")
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_SCALE
	tex_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	canvas.add_child(tex_rect)
	get_tree().root.add_child(canvas)
	_scare_overlay = canvas

	# Screen shake
	var cam = $Camera2D
	var original_offset = cam.offset
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	_shake_tween.set_loops(6)
	_shake_tween.tween_property(cam, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.03)
	_shake_tween.tween_property(cam, "offset", Vector2(randf_range(-8, 8), randf_range(-8, 8)), 0.03)
	_shake_tween.tween_callback(func(): cam.offset = original_offset)

	# Flash duration
	await get_tree().create_timer(0.35).timeout

	# Remove overlay
	if _scare_overlay:
		_scare_overlay.queue_free()
		_scare_overlay = null
	_scare_active = false

func die():
	get_tree().reload_current_scene()
