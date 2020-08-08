extends Node2D

# Needed because viewport inputs and raycasting is odd
# A lot could be simplified by https://github.com/godotengine/godot/issues/31856

var last_button_mask = 0
var mouse_over_area = null
var areas = {}
var area_nodes = {}
var was_just_hidden = false
var right_click_handled = null
var global_viewport

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
var layers_reversed = []

func _init():
	for layer in AREA_INTERSECT_LAYER:
		AREA_INTERSECT_LAYER[layer] = int(AREA_INTERSECT_LAYER[layer])
		AREA_INTERSECT_ALL_LAYERS += AREA_INTERSECT_LAYER[layer]
		areas[int(AREA_INTERSECT_LAYER[layer])] = []
	AREA_INTERSECT_ALL_LAYERS = int(AREA_INTERSECT_ALL_LAYERS)
	layers_reversed = AREA_INTERSECT_LAYER.values()
	layers_reversed.invert()

func _ready():
	global_viewport = get_viewport()

func _area_intersect(local_position, world):
	return world.direct_space_state.intersect_point(local_position, 128, [], AREA_INTERSECT_ALL_LAYERS, false, true)

class GlobalPositionYSorter:
	static func sort(a, b):
		if a.global_position.y > b.global_position.y:
			return true
		return false

func local_mouse_position_viewport(viewport, global_position=null):
	if global_position == null:
		global_position = global_viewport.get_mouse_position()
	var container = viewport.get_parent()
	var scale_factor = container.rect_size / viewport.size
	return (global_position - container.rect_position) / scale_factor

func _local_mouse_positions(global_position):
	var local_positions = {}
	var sub_viewports = get_tree().get_nodes_in_group('sub_viewports')
	for viewport in sub_viewports:
		local_positions[viewport] = local_mouse_position_viewport(viewport, global_position)
	return local_positions

func _find_top_areas(global_position, local_positions):
	var raw_results = _area_intersect(global_position, get_tree().get_root().get_world_2d())

	var sub_viewports = get_tree().get_nodes_in_group('sub_viewports')
	for viewport in sub_viewports:
		raw_results += _area_intersect(local_positions[viewport], viewport.get_world_2d())

	if raw_results.size() > 0:
		var top_areas = []
		var raw_collisions = {}
		for layer in AREA_INTERSECT_LAYER.values():
			raw_collisions[layer] = []
		for raw_result in raw_results:
			var collider = raw_result['collider']
			if collider.collision_layer & AREA_INTERSECT_ALL_LAYERS > 0 and collider.is_visible() and collider.get_parent().is_visible():
				if collider in areas[collider.collision_layer]:
					if collider.has_meta('area_pretend_to_be'):
						collider = collider.get_meta('area_pretend_to_be')
					raw_collisions[collider.collision_layer].append(collider)
		
		for layer in layers_reversed:
			var collisions = raw_collisions[layer]
			if collisions.size() > 0:
				collisions.sort_custom(GlobalPositionYSorter, 'sort')
				var collision = collisions[0]
				top_areas.append(collision)
		
		return top_areas
	return null

func _button_clicks(button_mask):
	var click_mask = 0
	for index in [1,2]:
		if last_button_mask & index == index and button_mask & index == 0:
			click_mask |= index
	return click_mask

func _make_data(mouse_over, global_position, local_positions, button_mask, button_click_mask):
	return {
		'mouse_over': mouse_over,
		'global_position': global_position,
		'local_positions': local_positions,
		'button_left': button_mask & BUTTON_LEFT == BUTTON_LEFT,
		'button_right': button_mask & BUTTON_RIGHT == BUTTON_RIGHT,
		'button_left_click': button_click_mask & BUTTON_LEFT == BUTTON_LEFT,
		'button_right_click': button_click_mask & BUTTON_RIGHT == BUTTON_RIGHT
	}
	
func get_local_position_for_viewport(viewport):
	pass

func register(node, area):
	areas[area.collision_layer].append(area)
	area_nodes[area] = node

func unregister(area):
	areas[area.collision_layer].erase(area)
	area_nodes.erase(area)

func _physics_process(delta):
	var button_mask = Input.get_mouse_button_mask()
	if visible or was_just_hidden:
		was_just_hidden = false
		var global_position = global_viewport.get_mouse_position()
		var local_positions = _local_mouse_positions(global_position)
		var button_click_mask = _button_clicks(button_mask)
		if button_click_mask & BUTTON_LEFT == BUTTON_LEFT or button_click_mask & BUTTON_RIGHT == BUTTON_RIGHT:
			Data.plant_current_click_action = null
		
		if button_click_mask & BUTTON_RIGHT == BUTTON_RIGHT:
			if right_click_handled != true or right_click_handled == null:
				right_click_handled = false

		var top_areas = null
		if Rect2(Vector2(0,0), Vector2(1920, 1080)).has_point(global_position):
			top_areas = _find_top_areas(global_position, local_positions)

		if mouse_over_area != null and is_instance_valid(mouse_over_area) and (top_areas == null or top_areas.size() == 0 or not mouse_over_area == top_areas[0] or was_just_hidden):
			area_nodes[mouse_over_area]._mouse_area(mouse_over_area, _make_data(false, global_position, local_positions, button_mask, button_click_mask))
			mouse_over_area = null
		if top_areas != null and not was_just_hidden:
			var cont_layer = null
			for top_area in top_areas:
				if cont_layer == null or cont_layer == top_area.collision_layer:
					var top_node = area_nodes[top_area]
					if not top_area == mouse_over_area or last_button_mask != button_mask:
						if cont_layer == null:
							mouse_over_area = top_area
						#prints(top_area.name, top_area.get_parent().name, top_area.is_visible(), top_area.get_parent().is_visible(), top_area.get_parent().rect_position if top_area.get_parent() is Control else 0)
						cont_layer = top_node._mouse_area(top_area, _make_data(true, global_position, local_positions, button_mask, button_click_mask))
						if cont_layer:
							continue
					break
					
		if right_click_handled == false:
			Events.emit_signal('unhandled_right_click')
		if button_click_mask & BUTTON_RIGHT == BUTTON_RIGHT:
			right_click_handled = null
	last_button_mask = button_mask


func _on_MouseHelper_visibility_changed():
	if not visible:
		was_just_hidden = true
