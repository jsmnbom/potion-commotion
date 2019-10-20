extends 'res://UI/Popout.gd'

func _init():
	icon_res = 'res://assets/ui/journal/journal.png'
	speeds[0] = 0.3

func _on_click():
	Events.emit_signal('inventory_deselect')
	Events.emit_signal('show_journal', true)