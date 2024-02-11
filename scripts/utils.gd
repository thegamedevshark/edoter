extends Node


# Take a file path for a JSON file and return its contents as a dictionary.
func load_json(path: String) -> Dictionary:
	var f = FileAccess.open(path, FileAccess.READ)
	var result = f.get_as_text()
	f.close()
	return JSON.parse_string(result)


# Take a file path and return the file extension.
func get_file_extension(path: String) -> String:
	var f = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var result = f.get_path().get_extension()
	f.close()
	return result


func get_file_name(path: String) -> String:
	var f = FileAccess.open(path, FileAccess.READ)
	var result = f.get_path().get_file()
	f.close()
	return result


func read_file(path: String) -> String:
	var f = FileAccess.open(path, FileAccess.READ)
	var result = f.get_as_text()
	f.close()
	return result


func write_file(path: String, content: String) -> void:
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(content)
	f.close()


func set_window_maximized() -> void:
	DisplayServer.window_set_mode(3) # Set the window to maximized.


func set_window_windowed() -> void:
	# Set the window to windowed.
	DisplayServer.window_set_mode(0)
	DisplayServer.window_set_size(Vector2i(800, 600))
	
	# Move the window to the center of the screenn
	var screen_size = DisplayServer.screen_get_size()
	var x = -400 + screen_size.x / 2
	var y = -300 + screen_size.y / 2
	DisplayServer.window_set_position(Vector2i(x, y))


func is_window_maximized() -> bool:
	return DisplayServer.window_get_mode() == 3


func is_window_windowed() -> bool:
	return DisplayServer.window_get_mode() == 0


func window_toggle_maximized() -> void:
	if is_window_windowed():
		set_window_maximized()
	else:
		set_window_windowed()
