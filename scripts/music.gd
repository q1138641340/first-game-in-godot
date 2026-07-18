extends AudioStreamPlayer

func _ready():
	if DisplayServer.get_name() == "headless":
		prepare_for_shutdown()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		prepare_for_shutdown()
		get_tree().quit()

func prepare_for_shutdown():
	stop()
	stream = null

func _exit_tree():
	prepare_for_shutdown()
