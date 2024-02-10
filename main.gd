extends Control

@onready var open_dir_dialog = %OpenDirDialog
@onready var open_file_dialog = %OpenFileDialog
@onready var save_file_dialog = %SaveFileDialog
@onready var explorer = %Explorer
@onready var code_edit = %CodeEdit
@onready var filename_label = %FilenameLabel

var filepath = ""
var directory = ""
var filename = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	code_edit.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	elif Input.is_action_just_pressed("new"):
		explorer.visible = false
		code_edit.grab_focus()
		directory = ""
		filename = ""
		filename_label.text = "untitled"
		filepath = ""
		code_edit.text = "\n"
	
	elif Input.is_action_just_pressed("open_dir"):
		open_dir_dialog.popup_centered()

	elif Input.is_action_just_pressed("open_file"):
		open_file_dialog.popup_centered()
	
	elif Input.is_action_just_pressed("save"):
		if filename == "":
			# In this case it is a new file and should be saved as.
			save_file_dialog.popup_centered()
		else:
			# In this case the file being edited already has a path.
			# We can save overwrite the file at the path to save.
			var f = FileAccess.open(filepath, FileAccess.WRITE)
			f.store_string(code_edit.text)
			f.close()
	
	elif Input.is_action_just_pressed("explorer"):
		if explorer.get_root() != null:
			explorer.visible = !explorer.visible
		else:
			explorer.visible = false
		
		if explorer.visible:
			explorer.grab_focus()
			var selected = explorer.get_selected()
			print(selected)

func _on_open_dir_dialog_dir_selected(dir):
	directory = dir
	
	# Remove all items in the explorer.
	explorer.clear()
	
	# Make the explorer visible and grab the focus.
	explorer.visible = true
	explorer.grab_focus()
	
	# Set the text of the explorer root to the path.
	var root = explorer.create_item()
	root.set_text(0, dir)
	
	# Get all the files in the directory and add them to the explorer.
	var files = DirAccess.get_files_at(dir)
	
	if len(files) > 0:
		# Add all the files to the explorer.
		for f in files:
			var item = explorer.get_root().create_child()
			item.set_text(0, f.get_file())
		
		# Focus the first file in the explorer.
		var first = root.get_child(0)
		explorer.set_selected(first, 0)
		
		# Open the first file in the explorer.
		var f = FileAccess.open(dir + "\\" + first.get_text(0), FileAccess.READ)
		filepath = f.get_path()
		code_edit.set_text(f.get_as_text())
		f.close()
		filename = first.get_text(0)
		filename_label.set_text(filename)
	else:
		# Make a new file (untitled).
		# Close the explorer.
		# User can save this.
		
		# Hide the explorer and set focus to the code edit.
		explorer.visible = false
		code_edit.grab_focus()
		
		filename = ""

func _on_open_file_dialog_file_selected(path):
	directory = ""
	filepath = path
	
	explorer.visible = false
	explorer.clear()
	
	var f = FileAccess.open(path, FileAccess.READ)
	filename = f.get_path().get_file()
	code_edit.text = f.get_as_text()
	f.close()
	
	filename_label.text = filename

func _on_save_file_dialog_file_selected(path):
	# Save the file.
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(code_edit.get_text())
	filename = f.get_path().get_file()
	f.close()
	
	filepath = path
	filename_label.text = filename

func _on_explorer_item_selected():
	var item = explorer.get_selected()
	var path = directory + "\\" + item.get_text(0)
	var f = FileAccess.open(path, FileAccess.READ)
	code_edit.text = f.get_as_text()
	
	var extension = f.get_path().get_extension()
	var languages = DirAccess.get_files_at("res://data/languages")
	code_edit.syntax_highlighter = CodeHighlighter.new()
	for lang in languages:
		if extension == lang.get_basename():
			var flang = FileAccess.open("res://data/languages/" + lang, FileAccess.READ)
			var json = JSON.parse_string(flang.get_as_text())
			
			var highlighter = code_edit.syntax_highlighter
			highlighter.set_number_color(Color.html(json["number"]))
			highlighter.set_symbol_color(Color.html(json["symbol"]))
			highlighter.set_function_color(Color.html(json["function"]))
			highlighter.set_member_variable_color(Color(0.50196081399918, 0.55686277151108, 0.60784316062927))
			
			for keyword in json["keywords"]:
				highlighter.add_keyword_color(keyword, Color.html(json["keywords"][keyword]))
			
			for region in json["regions"]:
				highlighter.add_color_region(region[0], region[1], Color.html(region[2]))
			
			flang.close()
			break
	
	
	
	f.close()

	filepath = path
	filename = item.get_text(0)
	filename_label.text = filename

func _on_explorer_item_activated():
	explorer.visible = false
	code_edit.grab_focus()

func _on_code_edit_focus_entered():
	explorer.visible = false
