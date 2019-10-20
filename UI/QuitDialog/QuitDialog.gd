extends Control

var quit_after_save = false

func _ready():
	Events.connect('mouse_area', self, '_on_mouse_area')
	Events.connect('saved', self, '_on_saved')
	
	_on_QuitDialog_visibility_changed()

func _on_mouse_area(msg):
	var node = msg['node']
	if node in [$CloseArea, $QuitWithSave/Area, $QuitWithoutSave/Area]:
		match msg:
			{'mouse_over': var mouse_over, 'button_left_click': var left, ..}:
				Utils.set_cursor_hand(mouse_over)
				if node == $CloseArea:
					if mouse_over and left:
						hide()
				else:
					node.get_parent().add_color_override("font_color",  Color('#89874f') if mouse_over else Color.black)
					if left:
						if node == $QuitWithoutSave/Area:
							get_tree().quit()
						else:
							quit_after_save = true
							Events.emit_signal('save_game')
					
					
func _on_saved():
	if quit_after_save:
		get_tree().quit()

func _on_QuitDialog_visibility_changed():
	$QuitWithSave.visible = visible
	$QuitWithoutSave.visible = visible
