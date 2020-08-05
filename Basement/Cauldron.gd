extends Node2D

var ingredients = []

var r = 0
var ingredient_offset_size = 90

var selected_resource
var selected_potion
var last_potion = null

func _ready():
	Events.connect('inventory_item', self, '_on_inventory_item')
	Events.connect('inventory_updated', self, '_on_inventory_updated')

	Utils.register_mouse_area(self, $Area)
	Utils.register_mouse_area(self, $ClearArea)
	Utils.register_mouse_area(self, $MakeAnotherArea)
	
	$Clear.texture = Utils.get_scaled_res('res://assets/ui/close.png', 32, 32)

func get_ingredient_pos(i, r_offset=0):
	var theta = (TAU / 5) * i + r - r_offset
	var offset = Vector2(sin(theta), cos(theta)) * ingredient_offset_size
	return offset

func _physics_process(delta):
	r -= PI / 120
	if r <= -PI * 2:
		r = 0

	var children = $Ingredients.get_children()
	for i in ingredients.size():
		var sprite = children[i]
		sprite.position = get_ingredient_pos(i)

func _add_ingredients_animated(item, count, acc):
	for i in range(count):
		Events.emit_signal('inventory_add', {
			'type': 'resource',
			'id': item.id,
			'count': -1,
			'animated': true,
			'to_position': Utils.get_global_position(position + get_ingredient_pos(i+acc, (PI/2)*(1.0+(0.1*i+acc*0.1))), get_viewport()),
			'callback': [self, 'add_ingredient', item, true],
			'delay': 0.1*i+acc*0.1})
	
func add_ingredient(item, brew_another=false):
	$MakeAnotherArea.hide()
	$LastPotion.hide()
	
	if not brew_another:
		$ClearArea.show()
		$Clear.show()

	var sprite = Sprite.new()
	sprite.texture = item.get_scaled_res(48, 48)
	sprite.position = get_ingredient_pos(ingredients.size())
	sprite.set_meta('item', item)
	$Ingredients.add_child(sprite)
	
	ingredients.append(item.id)
	if ingredients.size() == 5:
		start_brewing()

func potion_to_brew():
	for i in Data.inventory.size():
		var item = Data.inventory[i]
		if item.type == 'potion':
			ingredients.sort()
			item.ingredients.sort()
			if item.ingredients == ingredients:
				return item
	return Data.inventory_by_id['potion']['hydration']

func start_brewing():
	$Area.hide()
	$ClearArea.hide()
	$Clear.hide()
	
	var potion = potion_to_brew()
	var tween = Tween.new()
	add_child(tween)
	
	var end_pos = position
	
	var potion_sprite = Sprite.new()
	potion_sprite.texture = potion.get_scaled_res(48, 48)
	potion_sprite.position = end_pos
	potion_sprite.modulate.a = 0
	add_child(potion_sprite)
	
	tween.interpolate_property(self, 'ingredient_offset_size',
			ingredient_offset_size, 0, 1.5,
			Tween.TRANS_QUART, Tween.EASE_IN_OUT)

	for sprite in $Ingredients.get_children():
		tween.interpolate_property(sprite, 'modulate:a',
				1, 0, 0.5,
				Tween.TRANS_QUART, Tween.EASE_IN_OUT, 1.5)
	tween.interpolate_property(potion_sprite, 'modulate:a',
			0, 0.85, 0.5,
			Tween.TRANS_QUART, Tween.EASE_IN_OUT, 1.5)
	tween.connect('tween_all_completed', self, '_on_brewing_complete',
			[potion, tween, potion_sprite])
	tween.start()

func _on_brewing_complete(potion, tween, potion_sprite):
	potion_sprite.get_parent().remove_child(potion_sprite)
	tween.get_parent().remove_child(tween)
	ingredients = []
	var count = 1
	Events.emit_signal('inventory_add', {
		'type': 'potion',
		'id': potion.id,
		'animated': true,
		'from_position': Utils.get_global_position(position, get_viewport()),
		'count': count
	})
	Events.emit_signal('achievement', {'diff_id': 'diff_brew', 'diff_add': potion.id, 'total_id': 'total_brew', 'total_add': 1})
	ingredient_offset_size = 90
	for child in $Ingredients.get_children():
		child.queue_free()
	
	last_potion = potion
	$LastPotion.texture = potion.get_scaled_res(48, 48)
	$LastPotion.modulate.a = 0.5
	$MakeAnotherLabel.set_text('Click to brew another\n%s' % potion.name)
	yield(get_tree(), "idle_frame")
	$Area.show()
	_on_inventory_updated()

func _on_inventory_item(msg):
	match(msg):
		{'selected': var item}:
			selected_resource = null
			selected_potion = null
			if item.type == 'resource':
				selected_resource = item
			elif item.type == 'potion':
				selected_potion = item
		{'deselected': true}:
			selected_resource = null
			selected_potion = null

func _on_inventory_updated():
	if last_potion != null and $Ingredients.get_children().size() == 0 and $Area.visible:
		var has_items = true
		for resource_id in last_potion.ingredients:
			var item = Data.inventory_by_id['resource'][resource_id]
			if item.count < last_potion.ingredients.count(resource_id):
				has_items = false
		$LastPotion.visible = has_items
		$MakeAnotherArea.visible = has_items

func _mouse_area(area, msg):
	if area == $Area:
		match msg:
			{'mouse_over': true, 'button_left_click': var left_click, ..}:
				if left_click:
					if selected_resource != null:
						if ingredients.size() < 5:
							add_ingredient(selected_resource)
							Events.emit_signal('inventory_add', {'type': 'resource', 'id': selected_resource.id, 'count': -1})
					elif selected_potion != null and ingredients.size() == 0:
						var items = {}
						for resource_id in selected_potion.ingredients:
							var item = Data.inventory_by_id['resource'][resource_id]
							if item.count >= selected_potion.ingredients.count(resource_id):
								if not item in items:
									items[item] = selected_potion.ingredients.count(resource_id)
							else:
								return
						var acc = 0
						for item in items.keys():
							_add_ingredients_animated(item, items[item], acc)
							acc += items[item]
	elif area == $MakeAnotherArea:
		match msg:
			{'mouse_over': false, ..}:
				$MakeAnotherLabel.hide()
				Utils.set_cursor_hand(false)
			{'mouse_over': true, 'button_left_click': var left, ..}:
				$MakeAnotherLabel.show()
				Utils.set_cursor_hand(true)
				if left:
					$MakeAnotherArea.hide()
					$LastPotion.hide()
					$Area.hide()
					var items = {}
					for resource_id in last_potion.ingredients:
						var item = Data.inventory_by_id['resource'][resource_id]
						if not item in items:
							items[item] = last_potion.ingredients.count(resource_id)
					var acc = 0
					for item in items.keys():
						_add_ingredients_animated(item, items[item], acc)
						acc += items[item]
	elif area == $ClearArea:
		match msg:
			{'mouse_over': false, ..}:
				$ClearLabel.hide()
				Utils.set_cursor_hand(false)
			{'mouse_over': true, 'button_left_click': var left, ..}:
				$ClearLabel.show()
				Utils.set_cursor_hand(true)
				if left:
					$ClearArea.hide()
					$Clear.hide()
					ingredients = []
					for ingredient in $Ingredients.get_children():
						#var ingredient = $Ingredients.get_child(0)
						var item = ingredient.get_meta('item')
						Events.emit_signal('inventory_add', {
							'type': 'resource',
							'id': item.id,
							'animated': true,
							'from_position': Utils.get_global_position(ingredient.position, get_viewport()),
							'count': 1
						})
						ingredient.queue_free()
						
