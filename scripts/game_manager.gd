extends Node

var score = 0

@onready var score_label = $ScoreLabel

func _ready():
	# Fixed screen-space night sky background
	var bg_canvas = CanvasLayer.new()
	bg_canvas.name = "BackgroundLayer"
	bg_canvas.layer = -1

	var bg = TextureRect.new()
	bg.texture = load("res://assets/sprites/background.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	bg_canvas.add_child(bg)
	get_tree().root.add_child(bg_canvas)

	# Place decorations and monsters after scene is ready
	await get_tree().process_frame
	_spawn_decorations()
	_spawn_monster()

func _spawn_decorations():
	var parent = get_parent()
	var tex = load("res://assets/sprites/world_tileset.png")

	# Row 1 (grass variations): col 0=tuft, 1=flower, 2=dense, 3=tuft, 4=flower
	_add_sprite(parent, tex, 130, 70, 0, 1)
	_add_sprite(parent, tex, 220, 67, 1, 1)
	_add_sprite(parent, tex, 310, 65, 2, 1)
	_add_sprite(parent, tex, 420, 62, 3, 1)
	_add_sprite(parent, tex, 530, 59, 4, 1)
	_add_sprite(parent, tex, 650, 55, 1, 1)
	_add_sprite(parent, tex, 780, 50, 2, 1)
	_add_sprite(parent, tex, 900, 48, 0, 1)

	# Row 2 (plastic ribbons): 0=cyan, 1=pink, 2=blue, 3=cluster, 4=plastic_ground
	_add_sprite(parent, tex, 180, 64, 0, 2)
	_add_sprite(parent, tex, 350, 58, 1, 2)
	_add_sprite(parent, tex, 480, 55, 2, 2)
	_add_sprite(parent, tex, 600, 52, 3, 2)
	_add_sprite(parent, tex, 720, 48, 4, 2)
	_add_sprite(parent, tex, 850, 44, 0, 2)

	# Row 3 (futuristic AI): 0=hologram, 1=crystal, 2=circuit, 3=orb, 4=hologram
	_add_sprite(parent, tex, 160, 66, 0, 3)
	_add_sprite(parent, tex, 290, 63, 1, 3)
	_add_sprite(parent, tex, 450, 59, 2, 3)
	_add_sprite(parent, tex, 570, 54, 3, 3)
	_add_sprite(parent, tex, 700, 50, 4, 3)
	_add_sprite(parent, tex, 830, 46, 1, 3)
	_add_sprite(parent, tex, 960, 42, 3, 3)

	# Row 4 (more decorations): 0=flower, 1=ribbon_cluster, 2=orb, 3=grass, 4=circuit
	_add_sprite(parent, tex, 200, 65, 0, 4)
	_add_sprite(parent, tex, 380, 57, 1, 4)
	_add_sprite(parent, tex, 510, 53, 2, 4)
	_add_sprite(parent, tex, 640, 49, 3, 4)
	_add_sprite(parent, tex, 770, 46, 4, 4)

	# Row 5 (neon platforms): 0=cyan, 1=pink, 2=blue_grid, 3=mint, 4=purple
	_add_sprite(parent, tex, 250, 64, 0, 5)
	_add_sprite(parent, tex, 400, 60, 1, 5)
	_add_sprite(parent, tex, 550, 56, 2, 5)
	_add_sprite(parent, tex, 680, 52, 3, 5)
	_add_sprite(parent, tex, 800, 48, 4, 5)

	# Row 6 (depth/holograms): 0=shadow, 1=ring, 2=neon_grass, 3=shadow, 4=ring
	_add_sprite(parent, tex, 330, 63, 0, 6)
	_add_sprite(parent, tex, 460, 58, 1, 6)
	_add_sprite(parent, tex, 590, 53, 2, 6)
	_add_sprite(parent, tex, 730, 49, 3, 6)
	_add_sprite(parent, tex, 870, 45, 4, 6)

	# Row 7 (stars/data/energy): 0=stars, 1=dataBits, 2=pillar, 3=stars, 4=dataBits
	_add_sprite(parent, tex, 140, 68, 0, 7)
	_add_sprite(parent, tex, 270, 64, 1, 7)
	_add_sprite(parent, tex, 430, 60, 2, 7)
	_add_sprite(parent, tex, 560, 56, 3, 7)
	_add_sprite(parent, tex, 690, 51, 4, 7)
	_add_sprite(parent, tex, 820, 47, 0, 7)
	_add_sprite(parent, tex, 940, 43, 2, 7)

func _add_sprite(parent, tex, wx, wy, acol, arow):
	var sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.region_enabled = true
	sprite.region_rect = Rect2(acol * 16, arow * 16, 16, 16)
	sprite.position = Vector2(wx, wy)
	sprite.z_index = 1
	sprite.centered = true
	sprite.scale = Vector2(1.5, 1.5)
	parent.add_child.call_deferred(sprite)

func _spawn_monster():
	var bs_scene = load("res://scenes/black_sheep.tscn")
	var bs = bs_scene.instantiate()
	bs.position = Vector2(500, 55)
	get_parent().add_child.call_deferred(bs)

func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " ribbons."
