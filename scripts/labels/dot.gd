extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	text = "\uf444"


func _on_close_pressed():
	get_tree().quit()
