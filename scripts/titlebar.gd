extends Panel


var following: bool = false
var dragging_start_position: Vector2i = Vector2i()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if following:
		DisplayServer.window_set_position(DisplayServer.window_get_position() + Vector2i(get_global_mouse_position()) - dragging_start_position)


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			if event.double_click:
				Utils.window_toggle_maximized()
				if Utils.is_window_windowed():
					following = false
			
			if Utils.is_window_maximized():
				following = false
			elif Utils.is_window_windowed():
				following = !following
				dragging_start_position = get_local_mouse_position()
