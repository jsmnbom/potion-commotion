extends Node2D

var picked_up = false

func _ready():
	$Sprite.texture = Utils.get_scaled_res('res://assets/shovel_dirt.png', 96, 96)
	Events.connect('mouse_area', self, '_on_mouse_area')
	Events.connect('shovel', self, '_on_shovel')
	
func _on_mouse_area(msg):
	if msg['node'] == $Area:
		match msg:
			{'mouse_over': false, ..}:
				Events.emit_signal('tooltip', {'hide': true})
			{'mouse_over': true, 'button_left_click': var left, ..}:
				Events.emit_signal('tooltip', {'title': 'Use me!!', 'description': '- to dig up unwanted plants for seeds.'})
				if left:
					if picked_up:
						Events.emit_signal('shovel', false)
					else:
						Events.emit_signal('inventory_deselect')
						Utils.set_custom_cursor('shovel', Utils.get_scaled_res('res://assets/shovel.png', 64, 64), Vector2(32, 48))
						picked_up = true
						Events.emit_signal('shovel', true)
				
func _on_shovel(x):
	if not x:
		Utils.set_custom_cursor('shovel', null)
		picked_up = false