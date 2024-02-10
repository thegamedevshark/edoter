extends Control


@onready var open_dir_dialog = %OpenDirDialog
@onready var open_file_dialog = %OpenFileDialog
@onready var save_file_dialog = %SaveFileDialog
@onready var explorer = %Explorer
@onready var code_edit = %CodeEdit

@onready var edoter_label = %EdoterLabel
@onready var filename_label = %FilenameLabel
@onready var dot_label = %Dot

@onready var minimize_button = %MinimizeButton
@onready var maximize_button = %MaximizeButton
@onready var close_button = %CloseButton

@onready var titlebar = %Titlebar
@onready var body = %Body


var filepath = ""
var directory = ""
var filename = ""


var outfit: Dictionary
var data = {
	"outfit": "gruvbox"
}


# Called when the node enters the scene tree for the first time.
func _ready():
	code_edit.grab_focus()
	print(data["outfit"])
	outfit = load_json("res://data/outfits/" + data["outfit"] + ".json")
	dressup()


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


# Take a filepath for a JSON file and return its contents as a dictionary.
func load_json(path: String) -> Dictionary:
	var f = FileAccess.open(path, FileAccess.READ)
	var result = f.get_as_text()
	f.close()
	return JSON.parse_string(result)


# Take an outfit and trigger all the neccessary theme changes.
# The extension is the file extension and is used for setting up the syntax highlighting.
func dressup(extension: String = ""):
	# Change the titlebar theme settings.
	titlebar.get_theme_stylebox("panel").bg_color = Color.html(outfit["titlebar"])
	titlebar.get_theme_stylebox("panel").border_color = Color.html(outfit["outline"])
	
	# Change the body theme settings.
	body.get_theme_stylebox("panel").bg_color = Color.html(outfit["body"])
	body.get_theme_stylebox("panel").border_color = Color.html(outfit["outline"])
	
	# Change the A, B, and C theme settings for fonts.
	edoter_label.add_theme_color_override("font_color", outfit["a"])
	filename_label.add_theme_color_override("font_color", outfit["b"])
	dot_label.add_theme_color_override("font_color", outfit["c"])
	
	minimize_button.add_theme_color_override("font_color", outfit["b"])
	minimize_button.add_theme_color_override("font_hover_color", outfit["a"])
	minimize_button.add_theme_color_override("font_hover_pressed_color", outfit["b"])
	minimize_button.add_theme_color_override("font_pressed_color", outfit["b"])
	minimize_button.add_theme_color_override("font_focus_color", outfit["b"])
	
	maximize_button.add_theme_color_override("font_color", outfit["b"])
	maximize_button.add_theme_color_override("font_hover_color", outfit["a"])
	maximize_button.add_theme_color_override("font_hover_pressed_color", outfit["b"])
	maximize_button.add_theme_color_override("font_pressed_color", outfit["b"])
	maximize_button.add_theme_color_override("font_focus_color", outfit["b"])
	
	close_button.add_theme_color_override("font_color", outfit["b"])
	close_button.add_theme_color_override("font_hover_color", outfit["a"])
	close_button.add_theme_color_override("font_hover_pressed_color", outfit["b"])
	close_button.add_theme_color_override("font_pressed_color", outfit["b"])
	close_button.add_theme_color_override("font_focus_color", outfit["b"])
	
	# Change the syntax highlighting settings.
	code_edit.add_theme_color_override("font_color", outfit["a"])
	code_edit.add_theme_color_override("caret_color", outfit["b"])
	code_edit.add_theme_color_override("line_number_color", outfit["c"])
	code_edit.highlight(extension, outfit)


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
	var extension = f.get_path().get_extension()
	f.close()
	
	code_edit.highlight(extension, outfit)
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
	# Get the selected item from the explorer.
	var item = explorer.get_selected()
	
	# Get the full path to the selected item.
	var path = directory + "\\" + item.get_text(0)
	
	# Open the file at the path.
	var f = FileAccess.open(path, FileAccess.READ)
	
	# Set the code edit text to the contents of the file.
	code_edit.text = f.get_as_text()
	
	# Get the file extension.
	var extension = f.get_path().get_extension()
	
	# Close the file.
	f.close()

	# Setup syntax highlighting on the code edit for the filetype.
	code_edit.highlight(extension, outfit)
	
	filepath = path
	filename = item.get_text(0)
	filename_label.text = filename


func _on_explorer_item_activated():
	explorer.visible = false
	code_edit.grab_focus()


func _on_code_edit_focus_entered():
	explorer.visible = false
