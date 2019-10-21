extends Button

func _ready():
	pass

func _on_Button_mouse_entered():
	if not disabled:
		$Label.add_color_override("font_color", Color('#c7a33b'))
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_Button_mouse_exited():
	$Label.add_color_override("font_color", Color('1a1d1d'))
	mouse_default_cursor_shape = Control.CURSOR_ARROW
