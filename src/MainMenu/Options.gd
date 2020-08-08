extends NinePatchRect

var options_theme: Theme = preload('res://src/MainMenu/OptionsTheme.tres')

var default_options = {
	'fullscreen': false,
	'master': 100,
	'music': 100,
	'sfx': 100,
	'ambiance': 100
}
	

func _ready():
	var hydration = Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48)
	options_theme.set_icon('grabber', 'HSlider', hydration)
	options_theme.set_icon('grabber_highlight', 'HSlider', hydration)
	
	load_options()

func _unhandled_input(event):
	if event.is_action_pressed('ui_fullscreen'):
		$Fullscreen.pressed = !$Fullscreen.pressed
		_on_FullScreen_toggled($Fullscreen.pressed)
		save_options()

func _on_FullScreen_toggled(button_pressed):
	SFX.pop.play(self)
	OS.window_fullscreen = button_pressed


func _on_Master_value_changed(value):
	$MasterLabel.text = 'Master volume: %s%%' % round(value)
	Audio.set_volume(Audio.Bus.Master, value)


func _on_Music_value_changed(value):
	$MusicLabel.text = 'Music volume: %s%%' % round(value)
	Audio.set_volume(Audio.Bus.Music, value)


func _on_SFX_value_changed(value):
	$SFXLabel.text = 'Sound FX volume: %s%%' % round(value)
	Audio.set_volume(Audio.Bus.SFX, value)


func _on_Ambience_value_changed(value):
	$AmbienceLabel.text = 'Ambience volume: %s%%' % round(value)
	Audio.set_volume(Audio.Bus.Ambience, value)


func _on_Back_mouse_entered():
	SFX.hover.play(self)
	$Back.add_color_override("font_color", Color('#dc51ca'))
	$Back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_Back_mouse_exited():
	$Back.add_color_override("font_color", Color('#90721a'))
	$Back.mouse_default_cursor_shape = Control.CURSOR_ARROW
	

func _on_Options_visibility_changed():
	if not visible:
		_on_Back_mouse_exited()
		save_options()

func save_options():
	var data = {
		'fullscreen': $Fullscreen.pressed,
		'master': $Master.value,
		'music': $Music.value,
		'sfx': $SFX.value,
		'ambience': $Ambience.value
	}

	var options_file = File.new()
	options_file.open("user://options.save", File.WRITE)
	options_file.store_line(to_json(data))
	options_file.close()

func load_options():
	var options_file = File.new()
	var data
	if options_file.file_exists("user://options.save"):
		options_file.open("user://options.save", File.READ)
		data = parse_json(options_file.get_line())
	else:
		print('No loaded options found, using defaults.')
		data = default_options
	
	if data.has('ambiance'):
		data['ambience'] = data['ambiance']
		data.erase('ambiance')
		save_options()
	
	$Fullscreen.pressed = data['fullscreen']
	_on_FullScreen_toggled($Fullscreen.pressed)
	$Master.value = data['master']
	_on_Master_value_changed($Master.value)
	$Music.value = data['music']
	_on_Music_value_changed($Music.value)
	$SFX.value = data['sfx']
	_on_SFX_value_changed($SFX.value)
	$Ambience.value = data['ambience']
	_on_Ambience_value_changed($Ambience.value)
