extends Node

var score = 0
var total_coins = 0
var elapsed_time: float = 0.0
var is_finished = false

@onready var score_label = $UILayer/ScoreLabel
@onready var win_label = $UILayer/WinLabel
@onready var complete_label = $UILayer/CompleteLabel

func _ready():
	total_coins = get_tree().get_nodes_in_group("coin").size()

func _process(delta):
	if not is_finished:
		elapsed_time += delta

func add_point():
	score += 1
	score_label.text = "Coins: " + str(score) + "/" + str(total_coins)
	if score >= total_coins and total_coins > 0:
		win()

func add_bonus():
	score += 3
	score_label.text = "Coins: " + str(score) + "/" + str(total_coins)
	if score >= total_coins and total_coins > 0:
		win()

func show_death():
	is_finished = true
	complete_label.visible = true
	complete_label.text = "You Died!\nTry again..."

func win():
	win_label.visible = true
	win_label.text = "You Win! All " + str(total_coins) + " coins!"
	Engine.time_scale = 0.3
	await get_tree().create_timer(2.0).timeout
	Engine.time_scale = 1.0

func level_complete():
	if is_finished:
		return
	is_finished = true
	var t = elapsed_time
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	var millis = int((t - int(t)) * 100)
	var time_str = "%d:%02d.%02d" % [minutes, seconds, millis]

	complete_label.visible = true
	complete_label.text = "Level Clear!\nTime: " + time_str + "\nCoins: " + str(score) + "/" + str(total_coins)

	Engine.time_scale = 0.3
	await get_tree().create_timer(3.0).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
