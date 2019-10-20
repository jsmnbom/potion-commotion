extends Button

func _ready():
	pass

func _on_Button_mouse_entered():
	$Label.add_color_override("font_color", Color('#c7a33b'))


func _on_Button_mouse_exited():
	$Label.add_color_override("font_color", Color('1a1d1d'))
