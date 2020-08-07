extends "res://UI/Popout.gd"

func _init():
	speeds[0] = 0.3

func _on_click():
	Events.emit_signal('show_main_menu')
	popin()
	SFX.pop.play(self)
