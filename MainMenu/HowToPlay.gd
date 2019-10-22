extends NinePatchRect


func _ready():
	pass

func _on_Back_mouse_entered():
	$Back.add_color_override("font_color", Color('#dc51ca'))
	$Back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_Back_mouse_exited():
	$Back.add_color_override("font_color", Color('#90721a'))
	$Back.mouse_default_cursor_shape = Control.CURSOR_ARROW
	

func _on_HowToPlay_visibility_changed():
	if not visible:
		_on_Back_mouse_exited()
