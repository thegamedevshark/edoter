extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	text = "\uea72"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pressed():
	print(DisplayServer.window_get_mode())
	if (DisplayServer.window_get_mode() == 3):
		DisplayServer.window_set_mode(0) # Set the window to windowed.
		DisplayServer.window_set_size(Vector2i(800, 600))
		var screen_size = DisplayServer.screen_get_size()
		var x = -400 + screen_size.x / 2
		var y = -300 + screen_size.y / 2
		DisplayServer.window_set_position(Vector2i(x, y))
	else:
		DisplayServer.window_set_mode(3) # Set the window to maximized.
