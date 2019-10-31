extends 'res://UI/Popout.gd'

func _init():
	icon_res = 'res://assets/ui/journal/journal.png'
	speeds[0] = 0.3
	
	Events.connect('unlock_journal', self, '_on_unlock_journal')
	Events.connect('journal_has_new', self, '_on_journal_has_new')

func _on_click():
	Events.emit_signal('inventory_deselect')
	Events.emit_signal('show_journal', true)
	
func _on_unlock_journal():
	show()
	popin()

func _on_journal_has_new(x):
	$New.visible = x
