extends 'res://UI/Popout.gd'

func _init():
	icon_res = 'res://assets/ui/achievement_cup.png'

func _on_click():
	Events.emit_signal('inventory_deselect')
	Events.emit_signal('show_achievements', true)