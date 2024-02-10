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


var path = ""
var outfit: Dictionary
var data = {
	"outfit": "gruvbox"
}
var outfit_index = 0
var outfits: Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the focus to the code edit so it immediately editable after
	# opening the program.
	code_edit.grab_focus()

	# Load the outfit stored in the data.
	outfit = Utils.load_json("res://data/outfits/" + data["outfit"] + ".json")
	
	# Apply the outfit to all the components.
	dressup(outfit)
	
	var filenames = DirAccess.get_files_at("res://data/outfits")
	var index = 0
	for filename in filenames:
		var basename = filename.get_basename() # E.g. 'gruvbox'.
		outfits.append(basename)
		if basename == data["outfit"]:
			outfit_index = index
		index += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Handle exiting the program.
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Handle creating a new file.
	elif Input.is_action_just_pressed("new_file"):
		new_file()
	
	# Handle opening a directory.
	elif Input.is_action_just_pressed("open_dir"):
		open_dir_dialog.popup_centered()

	# Handle opening a file.
	elif Input.is_action_just_pressed("open_file"):
		open_file_dialog.popup_centered()
	
	# Handle saving a file.
	elif Input.is_action_just_pressed("save_file"):
		save_file()
	
	# Handle toggling the file explorer.
	elif Input.is_action_just_pressed("toggle_explorer"):
		if explorer.get_root() != null:
			explorer.visible = !explorer.visible
		else:
			explorer.visible = false
		
		if explorer.visible:
			explorer.grab_focus()
			var selected = explorer.get_selected()
		else:
			code_edit.grab_focus()
	
	# Handle changing outfit.
	elif Input.is_action_just_pressed("change_outfit"):
		outfit_index += 1
		if outfit_index >= len(outfits):
			outfit_index = 0
		var outfit_path = "res://data/outfits/" + outfits[outfit_index] + ".json"
		var json = Utils.load_json(outfit_path)
		var extension = Utils.get_file_extension(path)
		dressup(json, extension)


# Take an outfit and trigger all the neccessary theme changes.
# The extension is the file extension and is used for setting up the syntax highlighting.
func dressup(outfit: Dictionary, extension: String = ""):
	self.outfit = outfit
	
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
	
	# Change the theme settings for the explorer.
	explorer.add_theme_color_override("font_color", outfit["b"])
	explorer.add_theme_color_override("font_selected_color", outfit["a"])
	explorer.add_theme_color_override("guide_color", outfit["c"])


func new_file():
	explorer.visible = false
	explorer.clear()
	code_edit.grab_focus()
	path = ""
	filename_label.text = "untitled"
	code_edit.text = "\n"


func save_file():
	if path == "":
		# In this case it is a new file and should be saved as.
		save_file_dialog.popup_centered()
	else:
		# In this case the file being edited already has a path.
		# We can save overwrite the file at the path to save.
		Utils.write_file(path, code_edit.text)


func _on_open_dir_dialog_dir_selected(dir):
	# Remove all items in the explorer.
	explorer.clear()
	
	# Make the explorer visible and grab the focus.
	explorer.visible = true
	explorer.grab_focus()
	
	# Set the text of the explorer root to the path.
	var root = explorer.create_item()
	root.set_text(0, dir)
	
	# Get all the files in the directory and add them to the explorer.
	var filenames = DirAccess.get_files_at(dir)
	
	if len(filenames) > 0:
		# Add all the files to the explorer.
		for filename in filenames:
			var path = dir + "\\" + filename.get_file()
			
			# Add an item to the root of the explorer.
			var item = explorer.get_root().create_child()
			
			# Set the text of the item to the name of the file.
			item.set_text(0, filename.get_file())
			
			# Set the metadata of the item to the file path.
			item.set_metadata(0, path)
		
		# Focus the first file in the explorer.
		var first = root.get_child(0)
		explorer.set_selected(first, 0)
		
		path = dir + "\\" + first.get_text(0)
		code_edit.text = Utils.read_file(path)
		filename_label.text = Utils.get_file_name(path)
	else:
		explorer.visible = false
		code_edit.grab_focus()
		path = ""


func _on_open_file_dialog_file_selected(path):
	self.path = path
	
	explorer.visible = false
	explorer.clear()
	
	code_edit.text = Utils.read_file(path)
	filename_label.text = Utils.get_file_name(path)
	var extension = Utils.get_file_extension(path)
	code_edit.highlight(extension, outfit)


func _on_save_file_dialog_file_selected(path):
	Utils.write_file(path, code_edit.text)
	filename_label.text = Utils.get_file_name(path)
	self.path = path


func _on_explorer_item_selected():
	# Get the selected item from the explorer.
	var item = explorer.get_selected()
	
	# Get the full path to the selected item.
	path = item.get_metadata(0)

	code_edit.text = Utils.read_file(path)
	filename_label.text = Utils.get_file_name(path)
	var extension = Utils.get_file_extension(path)
	code_edit.highlight(extension, outfit)


func _on_explorer_item_activated():
	explorer.visible = false
	code_edit.grab_focus()


func _on_code_edit_focus_entered():
	explorer.visible = false
