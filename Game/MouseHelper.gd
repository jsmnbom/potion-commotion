extends Node2D

# Needed because viewport inputs and raycasting is odd
# A lot could be simplified by https://github.com/godotengine/godot/issues/31856

var last_button_mask = 0
var mouse_over_node = null

func layer(x):
	return Utils.collision_layer(x)

var AREA_INTERSECT_LAYER = {
	'game_bg': layer(1),
	'game1': layer(2),
	'game2': layer(3),
	'game3': layer(4),
	'game_ui': layer(5),
	'overlay_close': layer(11),
	'overlay_bg': layer(12),
	'overlay_ui1': layer(13),
	'overlay_ui2': layer(14),
	'overlay2_close': layer(16),
	'overlay2_bg': layer(17),
	'overlay2_ui': layer(18)
}
var AREA_INTERSECT_ALL_LAYERS = 0

func _init():
	for layer in AREA_INTERSECT_LAYER:
		AREA_INTERSECT_LAYER[layer] = int(AREA_INTERSECT_LAYER[layer])
		AREA_INTERSECT_ALL_LAYERS += AREA_INTERSECT_LAYER[layer]
	AREA_INTERSECT_ALL_LAYERS = int(AREA_INTERSECT_ALL_LAYERS)

func _area_intersect(local_position, world):
	return world.direct_space_state.intersect_point(local_position, 128, [], AREA_INTERSECT_ALL_LAYERS, false, true)

class GlobalPositionYSorter:
	static func sort(a, b):
		if a.global_position.y > b.global_position.y:
			return true
		return false

func _local_mouse_positions(global_position):
	var local_positions = {}
	var sub_viewports = get_tree().get_nodes_in_group('sub_viewports')
	for viewport in sub_viewports:
		var container = viewport.get_parent()
		var scale_factor = container.rect_size / viewport.size
		local_positions[viewport] = (global_position - container.rect_position) / scale_factor
	return local_positions

func _find_top_node(global_position, local_positions):
	var raw_results = _area_intersect(global_position, get_tree().get_root().get_world_2d())

	var sub_viewports = get_tree().get_nodes_in_group('sub_viewports')
	for viewport in sub_viewports:
		raw_results += _area_intersect(local_positions[viewport], viewport.get_world_2d())

	if raw_results.size() > 0:
		var raw_collisions = {}
		for layer in AREA_INTERSECT_LAYER:
			raw_collisions[AREA_INTERSECT_LAYER[layer]] = []
		var highest_layer = 0
		for raw_result in raw_results:
			var collider = raw_result['collider']
			if collider is Area2D and collider.collision_layer & AREA_INTERSECT_ALL_LAYERS > 0 and collider.is_visible() and collider.get_parent().is_visible():
				raw_collisions[collider.collision_layer].append(collider)
				if collider.collision_layer > highest_layer:
					highest_layer = collider.collision_layer
		# for layer in raw_collisions:
		# 	for collision in raw_collisions[layer]:
		# 		prints('collision', layer, collision.get_parent().name, collision.get_parent().visible)
		if highest_layer > 0:
			var collisions = raw_collisions[highest_layer]
			collisions.sort_custom(GlobalPositionYSorter, 'sort')
			return collisions[0]
	return null

func _button_clicks(button_mask):
	var click_mask = 0
	for index in [1,2]:
		if last_button_mask & index == 0 and button_mask & index == index:
			click_mask |= index
	return click_mask

func _make_data(node, mouse_over, global_position, local_positions, button_mask, button_click_mask):
	return {
		'node': node,
		'mouse_over': mouse_over,
		'global_position': global_position,
		'local_positions': local_positions,
		'button_left': button_mask & BUTTON_LEFT == BUTTON_LEFT,
		'button_right': button_mask & BUTTON_RIGHT == BUTTON_RIGHT,
		'button_left_click': button_click_mask & BUTTON_LEFT == BUTTON_LEFT,
		'button_right_click': button_click_mask & BUTTON_RIGHT == BUTTON_RIGHT
	}

func _physics_process(delta):
	var button_mask = Input.get_mouse_button_mask()
	if visible:
		var global_position = get_viewport().get_mouse_position()
		var local_positions = _local_mouse_positions(global_position)
		var top_node = null
		if Rect2(Vector2(0,0), Vector2(1920, 1080)).has_point(global_position):
			top_node = _find_top_node(global_position, local_positions)
		if top_node == null or (mouse_over_node != null and top_node != mouse_over_node):
			Events.emit_signal('mouse_area', _make_data(mouse_over_node, false, global_position, local_positions, button_mask, _button_clicks(button_mask)))
			mouse_over_node = null
		if top_node != null:
			if not (top_node == mouse_over_node and button_mask == last_button_mask):
				mouse_over_node = top_node
				prints(mouse_over_node.name, mouse_over_node.get_parent().name,  mouse_over_node.get_parent().rect_position if mouse_over_node.get_parent() is Control else 0)
				Events.emit_signal('mouse_area', _make_data(top_node, true, global_position, local_positions, button_mask, _button_clicks(button_mask)))

	last_button_mask = button_mask
