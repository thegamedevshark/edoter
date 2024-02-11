extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	text = "\uea72"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pressed():
	Utils.window_toggle_maximized()
