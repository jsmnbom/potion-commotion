extends Control

var GROW_STAGES = ['0-24% grown', '25-49% grown', '50-74% grown', '75-99% grown', 'COMPLETE']
var potion_areas = {}
var plant_areas = []
	
func init(title, description, res_path, seed_res_path, resource_res_path, used_in, collision_polygons):
	$Title.text = title
	$Description.text = description
	$Preview.texture = Utils.get_scaled_res(res_path, 96*5, 192*2)
	$FieldPreview.texture = Utils.get_scaled_res('res://assets/greenhouse/field.png', 96, 96)
	
	$SeedPreview.texture = Utils.get_scaled_res(seed_res_path, 48 ,48)
	$ResourcePreview.texture = Utils.get_scaled_res(resource_res_path, 48, 48)
	
	for potion in used_in:
		var item = Data.inventory_by_id['potion'][potion]
		var sprite = Sprite.new()
		sprite.texture = item.get_scaled_res(48, 48)
		var i = $Potions.get_children().size()
		sprite.position = Vector2(38+(i%2)*48, 24+floor(i/2)*64)
		if i == used_in.size() - 1 and i%2 == 0:
			sprite.position += Vector2(24, 0)
		
		var area = Area2D.new()
		area.monitorable = false
		area.monitoring = false
		area.input_pickable = false
		area.collision_layer = Utils.collision_layer(13)
		var shape = RectangleShape2D.new()
		shape.extents = Vector2(24,24)
		area.shape_owner_add_shape(area.create_shape_owner(sprite), shape)
		potion_areas[area] = [item.name, item.id]
		Utils.register_mouse_area(self, area)
		sprite.add_child(area)
		
		$Potions.add_child(sprite)
	
	for i in range(5):
		var area = Area2D.new()
		area.monitorable = false
		area.monitoring = false
		area.input_pickable = false
		area.collision_layer = Utils.collision_layer(13)
		area.position = Vector2(-192+96*i, 0)
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.extents = Vector2(48, 48)
		collision.shape = shape
		collision.position = Vector2(0, 48)
		area.add_child(collision)
		
		for poly in collision_polygons[i]:
			collision = CollisionPolygon2D.new()
			collision.polygon = poly
			collision.position = Vector2(-48, -96)
			area.add_child(collision)
		
		Utils.register_mouse_area(self, area)
		plant_areas.append(area)
		$Preview.add_child(area)
	
	_on_Plant_visibility_changed()

func _mouse_area(area, msg):
	if area in potion_areas.keys():
		match msg:
			{'mouse_over': false, ..}:
				Utils.set_cursor_hand(false)
				Events.emit_signal('tooltip', {'hide': true})
			{'mouse_over': true, 'button_left_click': var left, ..}:
				var names = potion_areas[area]
				if names[1] in Data.unlocked_journal_pages:
					Utils.set_cursor_hand(true)
					Events.emit_signal('tooltip', {'title': names[0], 'description': 'Click to show page.'})
					if left:
						Events.emit_signal('show_journal_page', {'id': names[1]})
						Utils.set_cursor_hand(false)
				else:
					Events.emit_signal('tooltip', {'title': names[0]})
	elif area in plant_areas:
		match msg:
			{'mouse_over': false, ..}:
				Events.emit_signal('tooltip', {'hide': true})
			{'mouse_over': true, 'button_left_click': var left, ..}:
				Events.emit_signal('tooltip', {'title': GROW_STAGES[plant_areas.find(area)]})

func _on_Plant_visibility_changed():
	for area in potion_areas.keys():
		area.visible = visible
	for area in plant_areas:
		area.visible = visible
