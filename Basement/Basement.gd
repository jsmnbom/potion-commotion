extends Node2D

func _ready():
	Events.connect('inventory_updated', self, '_on_inventory_updated')
	
func _on_inventory_updated():
	for child in $ShelvesTop.get_children():
		child.queue_free()
	for child in $ShelvesBottom.get_children():
		child.queue_free()
	var i = 0
	for potion_id in Data.inventory_by_id['potion']:
		var potion = Data.inventory_by_id['potion'][potion_id]
		if potion.count > 0:
			for j in range(2 if potion.count >= 5 else 1):
				var sprite = Sprite.new()
				sprite.texture = potion.get_scaled_res(64,64)
				sprite.position = Vector2(36+56*j+128*(i%8),8)
				
				($ShelvesTop if i < 8 else $ShelvesBottom).add_child(sprite)
				
		
		i += 1;