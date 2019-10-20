extends Control

var InventoryItem = preload('res://UI/Inventory/InventoryItem.tscn')

var selected_item_type = null;
var selected_item = null;

var mouse_over_item = null

var gems = 0

var inventory_items = []

func _ready():
	for item in Data.inventory:
		var node = InventoryItem.instance()
		node.get_node('Texture').texture = item.get_scaled_res(48, 48)
		$MarginContainer/GridContainer.add_child(node)
		update_item(node, item)
		inventory_items.append([item, node, node.get_node('Area')])

	Events.connect('inventory_add', self, '_on_inventory_add')
	Events.connect('gems_update', self, '_on_gems_update')
	Events.connect('mouse_area', self, '_on_mouse_area')
	Events.connect('inventory_deselect', self, 'set_selected_item', [null])

func update_item(node, item):
	if item.count == -1:
		node.get_node('Count').set_text('∞')
	else:
		node.get_node('Count').set_text(str(item.count))
	if item.count > 0 or item.count == -1:
		item.seen = true
	if (item.count > 0 or item.count == -1):
		node.get_node('FrameTexture').modulate = Color(1,1,1,1)
		node.get_node('CountFrameTexture').modulate = Color(1,1,1,1)
	else:
		node.get_node('FrameTexture').modulate = Color(0.8,0.8,0.8,1)
		node.get_node('CountFrameTexture').modulate = Color(0.8,0.8,0.8,1)

func _on_mouse_area(msg):
	for inventory_item in inventory_items:
		if msg['node'] == inventory_item[2]:
			var item = inventory_item[0]
			var node = inventory_item[1]
			match msg:
				{'mouse_over': false, ..}:
					mouse_over_item = null
					Events.emit_signal('tooltip', {'hide': true})
					Utils.set_cursor_hand(false)
				{'mouse_over': true, 'button_left_click': var left, 'button_right_click': var right, ..}:
					mouse_over_item = item
					Events.emit_signal('tooltip', {'inventory_item': item})
					if (item.count > 0 or item.count == -1):
						Utils.set_cursor_hand(true)
					if left:
						if (selected_item == item.id and selected_item_type == item.type) or item.count == 0:
							set_selected_item(null)
						elif item.count > 0 or item.count == -1:
							set_selected_item(item)
					elif right:
						if item.count != -1 and item.type == 'seed' and gems >= item.cost:
							add_item(item, node, 1)
							Events.emit_signal('gems_add', {'amount': -item.cost})
						elif item.count > 0 and item.type == 'potion' and item.sell_price > 0:
							add_item(item, node, -1)
							Events.emit_signal('gems_add', {'amount': item.sell_price})

func set_selected_item(item):
	if item != null:
		selected_item = item.id
		selected_item_type = item.type
		Utils.set_custom_cursor('item', item.get_scaled_res(32, 32), Vector2(16, 16))
		#Input.set_custom_mouse_cursor(item.get_scaled_res(32, 32), Input.CURSOR_ARROW, Vector2(16,16))
		#Input.set_custom_mouse_cursor(item.get_scaled_res(32, 32), Input.CURSOR_POINTING_HAND, Vector2(16,16))
		Events.emit_signal('inventory_item', {'selected': item})
	else:
		selected_item = null
		selected_item_type = null
		Utils.set_custom_cursor('item', null)
		#Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
		#Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
		Events.emit_signal('inventory_item', {'deselected': true})

func get_item_index(item_type, item_id):
	for i in Data.inventory.size():
		var item = Data.inventory[i]
		if item.type == item_type and item.id == item_id:
			return i
	return null
	
func get_item(item_type, item_id):
	var i = get_item_index(item_type, item_id)
	if i != null:
		return Data.inventory[i]
	return null

func add_item(item, node, count):
	if item.count != -1:
		item.count += count
		update_item(node, item)
		if count > 0:
			Events.emit_signal('achievement', {'total_id': 'total_items', 'total_add': 1})
			if item.type == 'seed':
				Events.emit_signal('achievement', {'total_id': 'total_seeds', 'total_add': 1})
		if item.count == 0:
			set_selected_item(null)

func add_item_animated(item, node, from_position, count):
	var root = get_tree().get_root()
	var tween = Tween.new()
	root.add_child(tween)

	from_position += Vector2(32, 32)
	
	var sprite = Sprite.new()
	sprite.texture = item.get_scaled_res(48, 48)
	sprite.position = from_position
	sprite.name = item.id
	# TODO: Is this good?
	sprite.modulate.a = 0.75
	tween.add_child(sprite)
	
	var end_position = (node.get_node('Texture').get_global_rect().position +
		(node.get_node('Texture').rect_size / 2))
	
	tween.interpolate_property(sprite, 'position',
		from_position, end_position, 1,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.connect('tween_all_completed', self, '_on_add_item_tween_complete',
			[node, item, tween, count])
	tween.start()

func _on_add_item_tween_complete(node, item, tween, count):
	add_item(item, node, count)
	tween.get_parent().remove_child(tween)

func serialize():
	var data = {
		'seed': {},
		'potion': {},
		'resource': {}
	}
	for i in Data.inventory.size():
		var item = Data.inventory[i]
		data[item.type][item.id] = item.count
	return data

func deserialize(data):
	for i in Data.inventory.size():
		var item = Data.inventory[i]
		item.count = int(data[item.type][item.id])
		update_item(inventory_items[i][1], item)

func _on_inventory_add(msg):
	match(msg):
		{'type': var item_type, 'id': var item_id, 'animated': true, 'from_position': var from_position}:
			var i = get_item_index(item_type, item_id)
			add_item_animated(inventory_items[i][0], inventory_items[i][1], from_position, 1)
		{'type': var item_type, 'id': var item_id, 'animated': true, 'from_position': var from_position, 'count': var count}:
			var i = get_item_index(item_type, item_id)
			add_item_animated(inventory_items[i][0], inventory_items[i][1], from_position, count)
		{'type': var item_type, 'id': var item_id, 'count': var count}:
			var i = get_item_index(item_type, item_id)
			add_item(inventory_items[i][0], inventory_items[i][1], count)
		{'type': var item_type, 'id': var item_id}:
			var i = get_item_index(item_type, item_id)
			add_item(inventory_items[i][0], inventory_items[i][1], 1)

func _on_gems_update(msg):
	match(msg):
		{'amount': var g}:
			gems = g