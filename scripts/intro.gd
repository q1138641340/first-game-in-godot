extends Control

var _video_done = false
var _video_started = false

@onready var video_player = $VideoStreamPlayer
@onready var start_overlay = $StartOverlay
@onready var start_button = $StartOverlay/StartButton

func _ready():
	video_player.stop()
	Music.stream_paused = true
	start_button.grab_focus()

func _input(event):
	if event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		if _video_started:
			_go_to_game()
		else:
			_start_video()

func _on_start_button_pressed():
	_start_video()

func _start_video():
	if _video_started or _video_done:
		return
	_video_started = true
	start_overlay.hide()
	video_player.play()

func _on_video_stream_player_finished():
	_go_to_game()

func _go_to_game():
	if _video_done:
		return
	_video_done = true
	video_player.stop()
	Music.stream_paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")
