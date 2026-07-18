extends Node2D

const SPEED = 40.0
const FLY_RANGE = 30.0

var start_y: float
var time: float = 0.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	start_y = position.y
	# Random start phase so enemies don't all sync
	time = randf() * PI * 2

func _process(delta):
	time += delta
	position.y = start_y + sin(time * SPEED / FLY_RANGE) * FLY_RANGE
