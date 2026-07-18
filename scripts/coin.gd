extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer
@onready var particles = $ParticleEmitter

var collected = false

func _ready():
	add_to_group("coin")

func _on_body_entered(body):
	if collected or not body.is_in_group("player"):
		return
	collected = true
	set_deferred("monitoring", false)
	game_manager.add_point()
	particles.burst_gold()
	animation_player.play("pickup")
