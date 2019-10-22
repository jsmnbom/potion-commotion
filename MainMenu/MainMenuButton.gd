extends Button

func _ready():
	pass

func _on_Button_mouse_entered():
	if not disabled:
		$Label.add_color_override("font_color", Color('#dc51ca'))
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_Button_mouse_exited():
	$Label.add_color_override("font_color", Color('#90721a'))
	mouse_default_cursor_shape = Control.CURSOR_ARROW
