extends CodeEdit


var keywords = [
	"and",
	"as",
	"assert",
	"break",
	"class",
	"continue",
	"def",
	"del",
	"elif",
	"else",
	"except",
	"False",
	"finally",
	"for",
	"from",
	"global",
	"if",
	"import",
	"in",
	"is",
	"lambda",
	"None",
	"nonlocal",
	"not",
	"or",
	"pass",
	"raise",
	"return",
	"True",
	"try",
	"while",
	"with",
	"yield",
]

var datatypes = [
	"str",
	
	"int",
	"float",
	"complex",
	
	"dict",
	
	"set",
	"frozenset",
	
	"bool",
	
	"bytes",
	"bytearray",
	"memoryview",
	
	"NoneType"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var highlighter = syntax_highlighter
	highlighter.set_number_color(Color(0.82352942228317, 0.85490196943283, 0.88627451658249))
	highlighter.set_symbol_color(Color(0.82352942228317, 0.85490196943283, 0.88627451658249))
	highlighter.set_function_color(Color(0.45882353186607, 0.49019607901573, 0.92941176891327))
	highlighter.set_member_variable_color(Color(0.50196081399918, 0.55686277151108, 0.60784316062927))
	for keyword in keywords:
		highlighter.add_keyword_color(keyword, Color(0.93725490570068, 0.34117648005486, 0.46666666865349))
	highlighter.add_color_region("\"", "\"", Color(1, 0.9450980424881, 0.58431375026703))
	highlighter.add_color_region("'", "'", Color(1, 0.9450980424881, 0.58431375026703))
	highlighter.add_color_region("#", "", Color(0.50196081399918, 0.55686277151108, 0.60784316062927))
	
	for datatype in datatypes:
		highlighter.add_keyword_color(datatype, Color(0.45882353186607, 0.49019607901573, 0.92941176891327))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
