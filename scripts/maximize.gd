extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	text = "\uea72"


func _on_pressed():
	Utils.window_toggle_fullscreen()
