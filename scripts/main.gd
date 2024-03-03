extends Control


@onready var open_dir_dialog: FileDialog = %OpenDirDialog
@onready var open_file_dialog: FileDialog = %OpenFileDialog
@onready var save_file_dialog: FileDialog = %SaveFileDialog
@onready var explorer: Tree = %Explorer
@onready var code_edit: CodeEdit = %CodeEdit

@onready var edoter_label: Label = %EdoterLabel
@onready var filename_label: Label = %FilenameLabel
@onready var dot_label: Label = %Dot

@onready var minimize_button: Button = %MinimizeButton
@onready var maximize_button: Button = %MaximizeButton
@onready var close_button: Button = %CloseButton

@onready var titlebar: Panel = %Titlebar
@onready var body: Panel = %Body


var file_path: String = ""
var project_path: String = ""
var last_selected_explorer_file_item: TreeItem = null

var current_outfit: Dictionary
var data: Dictionary = {
	"outfit": "edoter"
}
var current_outfit_index: int = 0
var all_outfits: Array[String] = []


# Called when the node enters the scene tree for the firs6t time.
func _ready():
	if FileAccess.file_exists("user://data.json"):
		var json = Utils.load_json("user://data.json")
		data["outfit"] = json["outfit"]
	
	# Set the focus to the code edit so it immediately editable after
	# opening the program.
	code_edit.grab_focus()

	# Load the outfit stored in the data.
	current_outfit = Utils.load_json("res://outfits/" + data["outfit"] + ".json")
	
	# Apply the outfit to all the components.
	dressup(current_outfit)
	
	var filenames = DirAccess.get_files_at("res://outfits")
	var index = 0
	for filename in filenames:
		var basename = filename.get_basename() # E.g. 'gruvbox'.
		all_outfits.append(basename)
		if basename == data["outfit"]:
			current_outfit_index = index
		index += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
			if last_selected_explorer_file_item != null:
				explorer.set_selected(last_selected_explorer_file_item, 0)
		else:
			code_edit.grab_focus()
	
	# Handle launching the project.
	elif Input.is_action_just_pressed("launch"):
		if FileAccess.file_exists(project_path + "/.edoter/launch.bat"):
			OS.create_process(project_path + "/.edoter/launch.bat", [], true)
	
	# Handle changing outfit.
	elif Input.is_action_just_pressed("change_outfit"):
		current_outfit_index += 1
		if current_outfit_index >= len(all_outfits):
			current_outfit_index = 0
		var outfit_name = all_outfits[current_outfit_index]
		var outfit_path = "res://outfits/" + outfit_name + ".json"
		var json = Utils.load_json(outfit_path)
		var extension = Utils.get_file_extension(file_path)
		dressup(json, extension)
		
		data["outfit"] = outfit_name
		Utils.write_file("user://data.json", JSON.stringify(data, "\t"))
	
	# Handle deleting file.
	elif Input.is_action_just_pressed("delete"):
		if explorer.has_focus():
			var item = explorer.get_selected()

			# Get the path to the item.
			var path = item.get_metadata(0)
			OS.move_to_trash(path)

			item.free()


# Take an outfit and trigger all the neccessary theme changes.
# The extension is the file extension and is used for setting up the syntax highlighting.
func dressup(outfit: Dictionary, extension: String = ""):
	current_outfit = outfit
	
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
	code_edit.add_theme_color_override("font_readonly_color", outfit["a"])
	code_edit.add_theme_color_override("caret_color", outfit["b"])
	code_edit.add_theme_color_override("line_number_color", outfit["c"])
	code_edit.highlight(extension, outfit)
	
	# Change the theme settings for the vertical scroll bar
	var v_scroll_bar = code_edit.get_v_scroll_bar()
	v_scroll_bar.get_theme_stylebox("grabber").bg_color = outfit["c"]
	v_scroll_bar.get_theme_stylebox("grabber_highlight").bg_color = outfit["b"]
	v_scroll_bar.get_theme_stylebox("grabber_pressed").bg_color = outfit["c"]
	v_scroll_bar.get_theme_stylebox("scroll").border_color = outfit["c"]
	
	# Change the theme settings for the horizontal scroll bar
	var h_scroll_bar = code_edit.get_h_scroll_bar()
	h_scroll_bar.get_theme_stylebox("grabber").bg_color = outfit["c"]
	h_scroll_bar.get_theme_stylebox("grabber_highlight").bg_color = outfit["b"]
	h_scroll_bar.get_theme_stylebox("grabber_pressed").bg_color = outfit["c"]
	h_scroll_bar.get_theme_stylebox("scroll").border_color = outfit["c"]
	
	# Change the theme settings for the explorer.
	explorer.add_theme_color_override("font_color", outfit["b"])
	explorer.add_theme_color_override("font_selected_color", outfit["a"])
	explorer.add_theme_color_override("guide_color", outfit["c"])


func new_file():
	explorer.visible = false
	explorer.clear()
	code_edit.grab_focus()
	file_path = ""
	filename_label.text = "untitled"
	code_edit.text = "\n"
	code_edit.clear_undo_history()


func save_file():
	if file_path == "":
		# In this case it is a new file and should be saved as.
		save_file_dialog.popup_centered()
	else:
		# In this case the file being edited already has a path.
		# We can save overwrite the file at the path to save.
		Utils.write_file(file_path, code_edit.text)


func fill_explorer(item: TreeItem) -> void:
	var dir = item.get_metadata(0)
	var files =  Utils.get_all_file_paths_in_dir(dir)
	if len(files) == 0:
		return
	
	# Load all directories into the file explorer.
	var directories = Utils.get_all_dir_paths_in_dir(dir)
	if len(directories) > 0:
		for path in directories:
			var new_item = item.create_child()
			var filename = Utils.get_file_name(path)
			new_item.set_text(0, "\uf4d3 \u2009" + filename) # Closed folder icon.
			new_item.set_metadata(0, path)
			new_item.collapsed = true
			fill_explorer(new_item)
	
	# Load all the files into the file explorer.
	for path in files:
		var new_item = item.create_child()
		var filename = Utils.get_file_name(path)
		var extension = Utils.get_file_extension(path)
		var icon = ""
		for file in Utils.get_all_file_paths_in_dir("res://languages"):
			if file.get_file().get_basename() == extension:
				var json = Utils.load_json(file)
				icon = json["icon"]
		
		if icon != "":
			new_item.set_text(0, icon + " \u2009" + filename)
		else:
			new_item.set_text(0, filename)
		
		new_item.set_metadata(0, path)


func _on_open_dir_dialog_dir_selected(dir):
	project_path = dir
	
	# Remove all items in the explorer.
	explorer.clear()
	
	# Make sure there is a .edoter directory.
	# If there isn't then it will create one.
	Utils.ensure_edoter_directory(dir)
	
	# Make the explorer visible and grab the focus.
	explorer.visible = true
	explorer.grab_focus()
	
	# Set the text of the explorer root to the path.
	var root = explorer.create_item()
	root.set_metadata(0, dir)
	root.set_text(0, dir)
	fill_explorer(root)
	
	# Select the first item in the explorer.
	var first = root.get_child(0)
	if first != null:
		explorer.set_selected(first, 0)
	else:
		explorer.visible = false
		code_edit.grab_focus()
		file_path = ""


func _on_open_file_dialog_file_selected(path):
	self.path = path
	
	explorer.visible = false
	explorer.clear()
	
	code_edit.text = Utils.read_file(path)
	filename_label.text = Utils.get_file_name(path)
	var extension = Utils.get_file_extension(path)
	code_edit.highlight(extension, current_outfit)
	code_edit.clear_undo_history()


func _on_save_file_dialog_file_selected(path):
	Utils.write_file(path, code_edit.text)
	filename_label.text = Utils.get_file_name(path)
	self.path = path


func _on_explorer_item_selected():
	# Get the selected item from the explorer.
	var item = explorer.get_selected()
	
	# Get the full path to the selected item.
	# Only change the global path if it is a file.
	if FileAccess.file_exists(item.get_metadata(0)):
		file_path = item.get_metadata(0)

	# If it is a file.
	if FileAccess.file_exists(file_path):
		code_edit.text = Utils.read_file(file_path)
		code_edit.text = code_edit.text.replace("\t", "    ")
		filename_label.text = Utils.get_file_name(file_path)
		var extension = Utils.get_file_extension(file_path)
		code_edit.highlight(extension, current_outfit)
		last_selected_explorer_file_item = item
		code_edit.clear_undo_history()
	
	# If it is a directory.
	elif DirAccess.dir_exists_absolute(file_path):
		pass


func _on_explorer_item_activated():
	var item = explorer.get_selected()
	if FileAccess.file_exists(item.get_metadata(0)):
		explorer.visible = false
		code_edit.grab_focus()
	else:
		item.collapsed = !item.collapsed
		var filename = Utils.get_file_name(item.get_metadata(0))
		if item.collapsed:
			item.set_text(0, "\uf4d3 \u2009" + filename) # Closed folder icon.
		else:
			item.set_text(0, "\uf4d4 \u2009" + filename) # Open folder icon.


func _on_code_edit_focus_entered():
	explorer.visible = false
