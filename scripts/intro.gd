extends Control

var _ffplay_pid = -1
var _video_done = false

func _ready():
	_launch_ffplay()

func _launch_ffplay():
	var video_path = ProjectSettings.globalize_path("res://assets/video/intro.mp4")
	_ffplay_pid = OS.create_process("ffplay", [
		"-fs", "-autoexit", "-loglevel", "quiet", video_path
	], false)

func _input(event):
	if event.is_action_pressed("jump") and not _video_done:
		_video_done = true
		_kill_ffplay()
		_go_to_game()

func _process(_delta):
	if not _video_done and _ffplay_pid != -1 and not OS.is_process_running(_ffplay_pid):
		_video_done = true
		_ffplay_pid = -1
		_go_to_game()

func _kill_ffplay():
	if _ffplay_pid != -1:
		OS.kill(_ffplay_pid)
		_ffplay_pid = -1

func _go_to_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")
