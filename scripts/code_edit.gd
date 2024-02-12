extends CodeEdit

var previous_text: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()


func reset():
	syntax_highlighter = CodeHighlighter.new()
	var highlighter = syntax_highlighter
	highlighter.set_number_color(Color(0.82352942228317, 0.85490196943283, 0.88627451658249))
	highlighter.set_symbol_color(Color(0.82352942228317, 0.85490196943283, 0.88627451658249))
	highlighter.set_function_color(Color(0.82352942228317, 0.85490196943283, 0.88627451658249))
	highlighter.set_member_variable_color(Color(0.82352942228317, 0.85490196943283, 0.88627451658249))


func highlight(extension: String, outfit: Dictionary):
	# Reset the code edit
	reset()
	
	# Get the highlighting data from the outfit
	var number: Color = Color.html(outfit["number"])
	var symbol: Color = Color.html(outfit["symbol"])
	var function: Color = Color.html(outfit["function"])
	var member: Color = Color.html(outfit["member"])
	var keyword: Color = Color.html(outfit["keyword"])
	var string: Color = Color.html(outfit["string"])
	var comment: Color = Color.html(outfit["comment"])
	
	# Get all the supported languages.
	# Language filenames match the extensions.
	var languages = DirAccess.get_files_at("res://data/languages")
	
	for l in languages:
		# Check if the extension is the same as the language filename.
		if extension == l.get_basename():
			var f = FileAccess.open("res://data/languages/" + l, FileAccess.READ)
			syntax_highlighter.set_number_color(number)
			syntax_highlighter.set_symbol_color(symbol)
			syntax_highlighter.set_function_color(function)
			syntax_highlighter.set_member_variable_color(member)
			
			var lang: Dictionary = JSON.parse_string(f.get_as_text())
			for k in lang["keywords"]:
				syntax_highlighter.add_keyword_color(k, keyword)
			for region in lang["regions"]:
				var col: Color = Color()
				var line_only = false
				if region[0] == "string":
					col = string
				elif region[0] == "comment":
					col = comment
				syntax_highlighter.add_color_region(region[1], region[2], col, line_only)
			
			f.close()
			return
	
	# In the instance, the extension didn't match anything.
	# Set all colors to the default.
	syntax_highlighter.set_number_color(outfit["a"])
	syntax_highlighter.set_symbol_color(outfit["a"])
	syntax_highlighter.set_function_color(outfit["a"])
	syntax_highlighter.set_member_variable_color(outfit["a"])
