extends "res://UI/Popout.gd"

func _init():
	icon_res = 'res://assets/ui/load.png'
	speeds[0] = 0.2

func _on_click():
	Events.emit_signal('load_game')