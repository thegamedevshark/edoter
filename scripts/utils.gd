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
