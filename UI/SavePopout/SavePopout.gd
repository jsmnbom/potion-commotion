extends 'res://UI/Popout.gd'

func _init():
	icon_res = 'res://assets/ui/save.png'
	speeds[0] = 0.3

func _on_click():
	Events.emit_signal('save_game')