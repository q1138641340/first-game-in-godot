extends Node3D

var score = 0

func _ready():
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.02, 0.01, 0.08)
	sky_mat.sky_horizon_color = Color(0.05, 0.02, 0.15)
	sky_mat.ground_horizon_color = Color(0.03, 0.01, 0.1)
	sky_mat.ground_bottom_color = Color(0.01, 0.0, 0.05)
	sky.sky_material = sky_mat
	env.environment.sky = sky
	env.environment.ambient_light_color = Color(0.15, 0.1, 0.2)
	add_child(env)

func add_point():
	score += 1
	print("Ribbons collected: ", score)
