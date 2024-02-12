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
	return path.get_file()


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


func get_all_file_paths_in_dir(path: String) -> Array[String]:
	var result: Array[String] = []
	var filenames = DirAccess.get_files_at(path)
	for filename in filenames:
		result.append(path + "/" + filename.get_file())
	return result


func get_all_dir_paths_in_dir(path: String) -> Array[String]:
	var result: Array[String] = []
	var dirs = DirAccess.get_directories_at(path)
	for dir in dirs:
		result.append(path + "/" + dir.get_file())
	return result


func get_all_dir_names_in_dir(path: String) -> Array[String]:
	var result: Array[String] = []
	var dirs = DirAccess.get_directories_at(path)
	for dir in dirs:
		result.append(dir.get_file())
	return result


func has_dir(path: String, dirname: String):
	var dirnames: Array[String] = get_all_dir_names_in_dir(path)
	return dirname in dirnames


func ensure_edoter_directory(path: String) -> void:
	if not has_dir(path, ".edoter"):
		DirAccess.make_dir_absolute(path + "/.edoter")
	
	var launch: String = path + "/.edoter/launch.bat"
	if not FileAccess.file_exists(launch):
		write_file(launch, "\n")
