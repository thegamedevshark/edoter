extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	text = "\ueaba"


func _on_pressed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
