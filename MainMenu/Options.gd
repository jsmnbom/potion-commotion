extends NinePatchRect

onready var audio = get_node('/root/PotionCommotion/Audio')

var default_options = {
	'fullscreen': false,
	'master': 100,
	'music': 100,
	'sfx': 100,
	'ambiance': 100
}
	

func _ready():
	var hydration = Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48)
	$Master.add_icon_override('grabber', hydration)
	$Master.add_icon_override('grabber_highlight', hydration)
	$Music.add_icon_override('grabber', hydration)
	$Music.add_icon_override('grabber_highlight', hydration)
	$SFX.add_icon_override('grabber', hydration)
	$SFX.add_icon_override('grabber_highlight', hydration)
	$Ambiance.add_icon_override('grabber', hydration)
	$Ambiance.add_icon_override('grabber_highlight', hydration)
	
	load_options()

func _unhandled_input(event):
	if event.is_action_pressed('ui_fullscreen'):
		$Fullscreen.pressed = !$Fullscreen.pressed
		_on_FullScreen_toggled($Fullscreen.pressed)

func _on_FullScreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Master_value_changed(value):
	$MasterLabel.text = 'Master volume: %s%%' % round(value)
	audio.set_volume(audio.MASTER, value)


func _on_Music_value_changed(value):
	$MusicLabel.text = 'Music volume: %s%%' % round(value)
	audio.set_volume(audio.MUSIC, value)


func _on_SFX_value_changed(value):
	$SFXLabel.text = 'Sound FX volume: %s%%' % round(value)
	audio.set_volume(audio.SFX, value)


func _on_Ambiance_value_changed(value):
	$AmbianceLabel.text = 'Ambiance volume: %s%%' % round(value)
	audio.set_volume(audio.AMBIANCE, value)


func _on_Back_mouse_entered():
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
		'ambiance': $Ambiance.value
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
	
	$Fullscreen.pressed = data['fullscreen']
	_on_FullScreen_toggled($Fullscreen.pressed)
	$Master.value = data['master']
	_on_Master_value_changed($Master.value)
	$Music.value = data['music']
	_on_Music_value_changed($Music.value)
	$SFX.value = data['sfx']
	_on_SFX_value_changed($SFX.value)
	$Ambiance.value = data['ambiance']
	_on_Ambiance_value_changed($Ambiance.value)
