extends Node

const GAME_3D_SCENE = "res://scenes/game_3d.tscn"
const BACKGROUND_TEXTURE = preload("res://assets/sprites/background.png")
const DECORATION_TEXTURE = preload("res://assets/sprites/world_tileset.png")
const BLACK_SHEEP_SCENE = preload("res://scenes/black_sheep.tscn")
const AI_MONSTER_SCENE = preload("res://scenes/ai_monster.tscn")

var score = 0
var collected_ribbons = 0
var total_ribbons = 0
var elapsed_time = 0.0
var is_finished = false
var _all_ribbons_collected = false

@onready var score_label = $UILayer/ScoreLabel
@onready var win_label = $UILayer/WinLabel
@onready var complete_label = $UILayer/CompleteLabel

func _ready():
	await get_tree().process_frame
	_create_background()
	_spawn_decorations()
	_spawn_monsters()
	total_ribbons = get_tree().get_nodes_in_group("coin").size()
	_refresh_score_label()

func _process(delta):
	if not is_finished:
		elapsed_time += delta

func _create_background():
	if has_node("BackgroundLayer"):
		return

	var background_layer = CanvasLayer.new()
	background_layer.name = "BackgroundLayer"
	background_layer.layer = -1

	var background = TextureRect.new()
	background.name = "Background"
	background.texture = BACKGROUND_TEXTURE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	background_layer.add_child(background)
	add_child(background_layer)

func _spawn_decorations():
	var positions = [
		Vector4(130, 70, 0, 1), Vector4(220, 67, 1, 1), Vector4(310, 65, 2, 1),
		Vector4(420, 62, 3, 1), Vector4(530, 59, 4, 1), Vector4(650, 55, 1, 1),
		Vector4(780, 50, 2, 1), Vector4(900, 48, 0, 1), Vector4(180, 64, 0, 2),
		Vector4(350, 58, 1, 2), Vector4(480, 55, 2, 2), Vector4(600, 52, 3, 2),
		Vector4(720, 48, 4, 2), Vector4(850, 44, 0, 2), Vector4(160, 66, 0, 3),
		Vector4(290, 63, 1, 3), Vector4(450, 59, 2, 3), Vector4(570, 54, 3, 3),
		Vector4(700, 50, 4, 3), Vector4(830, 46, 1, 3), Vector4(960, 42, 3, 3),
		Vector4(200, 65, 0, 4), Vector4(380, 57, 1, 4), Vector4(510, 53, 2, 4),
		Vector4(640, 49, 3, 4), Vector4(770, 46, 4, 4), Vector4(250, 64, 0, 5),
		Vector4(400, 60, 1, 5), Vector4(550, 56, 2, 5), Vector4(680, 52, 3, 5),
		Vector4(800, 48, 4, 5), Vector4(330, 63, 0, 6), Vector4(460, 58, 1, 6),
		Vector4(590, 53, 2, 6), Vector4(730, 49, 3, 6), Vector4(870, 45, 4, 6),
		Vector4(140, 68, 0, 7), Vector4(270, 64, 1, 7), Vector4(430, 60, 2, 7),
		Vector4(560, 56, 3, 7), Vector4(690, 51, 4, 7), Vector4(820, 47, 0, 7),
		Vector4(940, 43, 2, 7),
	]

	for item in positions:
		_add_decoration(item.x, item.y, int(item.z), int(item.w))

func _add_decoration(world_x, world_y, atlas_column, atlas_row):
	var sprite = Sprite2D.new()
	sprite.texture = DECORATION_TEXTURE
	sprite.region_enabled = true
	sprite.region_rect = Rect2(atlas_column * 16, atlas_row * 16, 16, 16)
	sprite.position = Vector2(world_x, world_y)
	sprite.z_index = 1
	sprite.scale = Vector2(1.5, 1.5)
	get_parent().add_child(sprite)

func _spawn_monsters():
	var black_sheep = BLACK_SHEEP_SCENE.instantiate()
	black_sheep.position = Vector2(500, 55)
	get_parent().add_child(black_sheep)

	var ai_monster = AI_MONSTER_SCENE.instantiate()
	ai_monster.position = Vector2(1280, 70)
	get_parent().add_child(ai_monster)

func add_point():
	if is_finished:
		return
	score += 1
	collected_ribbons += 1
	_refresh_score_label()
	if collected_ribbons >= total_ribbons and total_ribbons > 0:
		show_all_ribbons_collected()

func add_bonus():
	if is_finished:
		return
	score += 3
	_refresh_score_label()

func _refresh_score_label():
	score_label.text = "Ribbons: %d  Found: %d/%d" % [score, collected_ribbons, total_ribbons]

func show_all_ribbons_collected():
	if _all_ribbons_collected:
		return
	_all_ribbons_collected = true
	win_label.visible = true
	win_label.text = "All ribbons collected!\nFind the exit."

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
		player.velocity = Vector2.ZERO
		player.collision_layer = 0
		player.collision_mask = 0
		player.set_physics_process(false)
	var total_seconds = int(elapsed_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	var millis = int((elapsed_time - total_seconds) * 100.0)
	var time_text = "%d:%02d.%02d" % [minutes, seconds, millis]

	complete_label.visible = true
	complete_label.text = "Level Clear!\nTime: %s\nRibbons: %d" % [time_text, score]
	await get_tree().create_timer(2.0, true, false, true).timeout
	get_tree().change_scene_to_file(GAME_3D_SCENE)

func _exit_tree():
	Engine.time_scale = 1.0
