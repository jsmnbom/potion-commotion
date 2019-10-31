extends Control

var quit_after_save = false

func _ready():
	Events.connect('saved', self, '_on_saved')

	Utils.register_mouse_area(self, $CloseArea)
	Utils.register_mouse_area(self, $Area)
	Utils.register_mouse_area(self, $QuitWithSave/Area)
	Utils.register_mouse_area(self, $QuitWithoutSave/Area)
	
	_on_QuitDialog_visibility_changed()

func _mouse_area(area, msg):
	if area in [$CloseArea, $QuitWithSave/Area, $QuitWithoutSave/Area]:
		match msg:
			{'mouse_over': var mouse_over, 'button_left_click': var left, ..}:
				if area == $CloseArea:
					if mouse_over:
						Utils.set_custom_cursor('close', Utils.get_scaled_res('res://assets/ui/close.png', 32, 32), Vector2(14,14))
						if left:
							Events.emit_signal('exit_confirm_close')
					else:
						Utils.set_custom_cursor('close', null)
				elif area != $Area:
					Utils.set_cursor_hand(mouse_over)
					area.get_parent().add_color_override("font_color",  Color('#dc51ca') if mouse_over else Color('#90721a'))
					area.get_parent().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if mouse_over else Control.CURSOR_ARROW
					if left:
						if area == $QuitWithoutSave/Area:
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
