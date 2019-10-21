extends NinePatchRect


func _ready():
	$Master.add_icon_override('grabber', Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48))
	$Master.add_icon_override('grabber_highlight', Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48))
	$Music.add_icon_override('grabber', Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48))
	$Music.add_icon_override('grabber_highlight', Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48))
	$SFX.add_icon_override('grabber', Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48))
	$SFX.add_icon_override('grabber_highlight', Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48))
	$Ambiance.add_icon_override('grabber', Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48))
	$Ambiance.add_icon_override('grabber_highlight', Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48))
	
	$FullScreen.pressed = OS.window_fullscreen
	_on_Master_value_changed($Master.value)
	_on_Music_value_changed($Music.value)
	_on_SFX_value_changed($SFX.value)
	_on_Ambiance_value_changed($Ambiance.value)

func _on_FullScreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Master_value_changed(value):
	$MasterLabel.text = 'Master volume: %s%%' % round(value)


func _on_Music_value_changed(value):
	$MusicLabel.text = 'Music volume: %s%%' % round(value)


func _on_SFX_value_changed(value):
	$SFXLabel.text = 'Sound FX volume: %s%%' % round(value)


func _on_Ambiance_value_changed(value):
	$AmbianceLabel.text = 'Ambiance volume: %s%%' % round(value)


func _on_Back_mouse_entered():
	$Back.add_color_override("font_color", Color('#c7a33b'))
	$Back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_Back_mouse_exited():
	$Back.add_color_override("font_color", Color('1a1d1d'))
	$Back.mouse_default_cursor_shape = Control.CURSOR_ARROW
	

func _on_Options_visibility_changed():
	if not visible:
		_on_Back_mouse_exited()
