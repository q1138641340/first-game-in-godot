extends Node3D

const GAME_2D_SCENE = "res://scenes/game.tscn"

var score = 0
var total_ribbons = 0
var is_finished = false

@onready var score_label = $UILayer/ScoreLabel
@onready var complete_label = $UILayer/CompleteLabel

func _ready():
	add_to_group("game_manager_3d")
	_create_environment()
	await get_tree().process_frame
	total_ribbons = get_tree().get_nodes_in_group("coin_3d").size()
	_refresh_score()

func _create_environment():
	var world_environment = WorldEnvironment.new()
	world_environment.environment = Environment.new()
	world_environment.environment.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.02, 0.01, 0.08)
	sky_material.sky_horizon_color = Color(0.05, 0.02, 0.15)
	sky_material.ground_horizon_color = Color(0.03, 0.01, 0.1)
	sky_material.ground_bottom_color = Color(0.01, 0.0, 0.05)
	sky.sky_material = sky_material
	world_environment.environment.sky = sky
	world_environment.environment.ambient_light_color = Color(0.15, 0.1, 0.2)
	add_child(world_environment)

func add_point():
	if is_finished:
		return
	score += 1
	_refresh_score()
	if score >= total_ribbons and total_ribbons > 0:
		complete_label.visible = true
		complete_label.text = "All 3D ribbons found!\nReach the exit."

func _refresh_score():
	score_label.text = "3D Ribbons: %d/%d" % [score, total_ribbons]

func show_death():
	if is_finished:
		return
	is_finished = true
	complete_label.visible = true
	complete_label.text = "You Died!\nTry again..."

func level_complete():
	if is_finished:
		return
	is_finished = true
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.velocity = Vector3.ZERO
		player.collision_layer = 0
		player.collision_mask = 0
		player.set_physics_process(false)
	complete_label.visible = true
	complete_label.text = "3D Branch Complete!"
	await get_tree().create_timer(2.0, true, false, true).timeout
	get_tree().change_scene_to_file(GAME_2D_SCENE)
