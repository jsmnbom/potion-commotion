extends 'res://UI/Popout.gd'

func _init():
	speeds[0] = 0.3

func _on_click():
	Events.emit_signal('save_game')
	SFX.save_game.play()
