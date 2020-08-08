extends Node2D

var picked_up = false

func _ready():
	$Sprite.texture = Utils.get_scaled_res('res://assets/greenhouse/shovel_dirt.png', 96, 96)
	Events.connect('shovel', self, '_on_shovel')

	Utils.register_mouse_area(self, $Area)
	
func _mouse_area(area, msg):
	if area == $Area:
		match msg:
			{'mouse_over': false, ..}:
				Events.emit_signal('tooltip', {'hide': true})
			{'mouse_over': true, 'button_left_click': var left, ..}:
				Events.emit_signal('tooltip', {'title': 'Use me!!', 'description': '- to dig up unwanted plants for seeds.'})
				if left:
					if picked_up:
						Events.emit_signal('shovel', false)
						SFX.shovel_deactivate.play2d(self)
					else:
						Events.emit_signal('inventory_deselect')
						Utils.set_custom_cursor('shovel', Utils.get_scaled_res('res://assets/greenhouse/shovel.png', 64, 64), Vector2(32, 48))
						picked_up = true
						Events.emit_signal('shovel', true)
						SFX.shovel_activate.play2d(self)
				
func _on_shovel(x):
	if not x:
		if picked_up:
			SFX.shovel_deactivate.play2d(self)
		Utils.set_custom_cursor('shovel', null)
		picked_up = false
		
