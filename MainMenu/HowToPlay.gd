extends NinePatchRect


func _ready():
	pass

func _on_Back_mouse_entered():
	$Back.add_color_override("font_color", Color('#c7a33b'))
	$Back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_Back_mouse_exited():
	$Back.add_color_override("font_color", Color('1a1d1d'))
	$Back.mouse_default_cursor_shape = Control.CURSOR_ARROW
	

func _on_HowToPlay_visibility_changed():
	if not visible:
		_on_Back_mouse_exited()
