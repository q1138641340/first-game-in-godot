extends Node2D

const SPEED = 60

var direction = 1
var is_dead = false

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var particles = $ParticleEmitter

func die():
	if is_dead:
		return
	is_dead = true
	particles.burst_green()
	animated_sprite.visible = false
	$StompHitbox/CollisionShape2D.set_deferred("disabled", true)
	$Killzone/CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(0.3).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_dead:
		return
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	position.x += direction * SPEED * delta
