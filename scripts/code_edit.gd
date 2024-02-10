extends CodeEdit

var previous_text = ""

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
