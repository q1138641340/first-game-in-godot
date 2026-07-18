extends Control

var _video_done = false

@onready var video_player = $VideoStreamPlayer

func _ready():
	video_player.play()

func _input(event):
	if event.is_action_pressed("jump"):
		get_viewport().set_input_as_handled()
		_go_to_game()

func _on_video_stream_player_finished():
	_go_to_game()

func _go_to_game():
	if _video_done:
		return
	_video_done = true
	video_player.stop()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
