extends NinePatchRect


func _ready():
	pass
	
func _on_StartNewGame_mouse_entered():
	SFX.hover.play()
	$StartNewGame.add_color_override("font_color", Color('#dc51ca'))
	$StartNewGame.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_StartNewGame_mouse_exited():
	$StartNewGame.add_color_override("font_color", Color('#90721a'))
	$StartNewGame.mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_Cancel_mouse_entered():
	SFX.hover.play()
	$Cancel.add_color_override("font_color", Color('#dc51ca'))
	$Cancel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_Cancel_mouse_exited():
	$Cancel.add_color_override("font_color", Color('#90721a'))
	$Cancel.mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_NameEntry_visibility_changed():
	if visible:
		$LineEdit.clear()
		$LineEdit.grab_focus()
		Data.player_name = ''
	if not visible:
		_on_Cancel_mouse_exited()
		_on_StartNewGame_mouse_exited()

func _on_LineEdit_text_entered(new_text):
	SFX.press.play()
	_on_LineEdit_text_changed(new_text)
	Events.emit_signal('menu_new_game')


func _on_LineEdit_text_changed(new_text):
	Data.player_name = new_text
	if Data.player_name == '':
		Data.player_name = 'Apprentice'


func _on_StartNewGame_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		SFX.press.play()
		_on_LineEdit_text_changed(Data.player_name)
		Events.emit_signal('menu_new_game')
