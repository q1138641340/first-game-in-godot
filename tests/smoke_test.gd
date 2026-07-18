extends SceneTree

var failures = []

func _init():
	call_deferred("_run")

func _check(condition, message):
	if not condition:
		failures.append(message)
		push_error("SMOKE TEST: " + message)

func _run():
	var intro = load("res://scenes/intro.tscn").instantiate()
	root.add_child(intro)
	current_scene = intro
	await process_frame
	_check(not intro.get_node("VideoStreamPlayer").is_playing(), "intro video started before user interaction")
	_check(intro.get_node("VideoStreamPlayer").get_stream_length() > 49.0, "intro video has an invalid duration")
	intro._on_start_button_pressed()
	await process_frame
	_check(intro.get_node("VideoStreamPlayer").is_playing(), "intro video did not start after user interaction")
	var skip_event = InputEventAction.new()
	skip_event.action = "jump"
	skip_event.pressed = true
	Input.parse_input_event(skip_event)
	await process_frame
	await process_frame
	await process_frame
	await process_frame
	var game_2d = current_scene
	_check(game_2d != null and game_2d.name == "Game", "intro did not enter the 2D game")
	if not game_2d or game_2d.name != "Game":
		_finish()
		return

	var manager_2d = game_2d.get_node("GameManager")
	var player_2d = game_2d.get_node("Player")
	_check(game_2d.get_node_or_null("Section2/LevelExit") != null, "2D exit is missing")
	_check(manager_2d.get_node_or_null("BackgroundLayer") != null, "background layer was not attached")
	_check(game_2d.get_node_or_null("BlackSheep") != null, "black sheep was not spawned")
	_check(game_2d.get_node_or_null("AIMonster") != null, "AI monster was not spawned")
	_check(manager_2d.total_ribbons == 27, "2D ribbon count should be 27")
	_check(player_2d.has_node("JumpSound") and player_2d.has_node("HurtSound"), "player audio nodes are missing")
	_check(player_2d.has_node("ParticleEmitter"), "player particles are missing")

	var black_sheep = game_2d.get_node_or_null("BlackSheep")
	var ai_monster = game_2d.get_node_or_null("AIMonster")
	if black_sheep:
		_check(black_sheep.collision_layer == 8 and black_sheep.collision_mask == 3, "black sheep collision setup is invalid")
		_check(black_sheep.has_method("die"), "black sheep cannot be stomped")
	if ai_monster:
		_check(ai_monster.collision_layer == 8 and ai_monster.collision_mask == 3, "AI monster collision setup is invalid")

	player_2d._trigger_scare()
	await process_frame
	_check(player_2d.get_node_or_null("ScareOverlay") != null, "random scare overlay was not created")
	player_2d.die()
	await create_timer(1.1, true, false, true).timeout
	await process_frame
	await process_frame
	_check(current_scene != null and current_scene.name == "Game", "2D death did not reload the level")
	_check(root.find_child("ScareOverlay", true, false) == null, "random scare overlay survived a death reload")
	game_2d = current_scene
	manager_2d = game_2d.get_node("GameManager")

	await manager_2d.level_complete()
	await process_frame
	await process_frame
	var game_3d = current_scene
	_check(game_3d != null and game_3d.name == "Game3D", "2D exit did not enter the 3D branch")
	if not game_3d or game_3d.name != "Game3D":
		_finish()
		return

	await process_frame
	var manager_3d = game_3d.get_node("GameManager")
	var player_3d = game_3d.get_node("Player")
	_check(manager_3d.total_ribbons == 6, "3D ribbon count should be 6")
	_check(game_3d.get_node_or_null("LevelExit") != null, "3D exit is missing")
	_check(player_3d.has_method("die"), "3D player has no death flow")
	_check(game_3d.get_node("Enemies/Slime1").has_method("die"), "3D slime cannot be stomped")
	player_3d.die()
	await create_timer(1.1, true, false, true).timeout
	await process_frame
	await process_frame
	_check(current_scene != null and current_scene.name == "Game3D", "3D death did not reload the branch")
	game_3d = current_scene
	manager_3d = game_3d.get_node("GameManager")

	await manager_3d.level_complete()
	await process_frame
	await process_frame
	_check(current_scene != null and current_scene.name == "Game", "3D branch did not return to the 2D game")
	_finish()

func _finish():
	var music = root.get_node_or_null("Music")
	if music and music.has_method("prepare_for_shutdown"):
		music.prepare_for_shutdown()
	await process_frame
	if failures.is_empty():
		print("SMOKE TEST PASSED")
		quit(0)
	else:
		print("SMOKE TEST FAILED: ", failures)
		quit(1)
