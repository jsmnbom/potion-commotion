extends "res://UI/Popout.gd"

func _init():
	icon_res = 'res://assets/ui/menu_icon.png'
	speeds[0] = 0.3

func _on_click():
	Events.emit_signal('show_main_menu')
	popin()