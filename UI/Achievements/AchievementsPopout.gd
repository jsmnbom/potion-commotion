extends 'res://UI/Popout.gd'

func _on_click():
	Events.emit_signal('inventory_deselect')
	Events.emit_signal('show_achievements', true)