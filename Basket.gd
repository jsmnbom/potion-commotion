extends Node2D

var item
var last_position
var picked_up
var basket_area
var basket_shape
var position_ok = false
var mouse_offset

var overlapping = []

var bounds = Rect2(128, 300, 1152, 650)

var amount = 0.0

var content_transforms = [
	[Vector2( -25, 0 ), 0.0],
	[Vector2( 25, 0 ), 0.0],
	
	[Vector2( 0, 0 ), 0.0],
	[Vector2( 0, -15 ), 0.0],
	
	[Vector2( 15, -11 ), 0.0],
	[Vector2( -15, -11), 0.0],
	
	[Vector2( -15, 0 ), 0.0],
	[Vector2( 15, 0 ), 0.0],
]
var content_texture = null

func _ready():
	Utils.register_mouse_area(self, $Area)
	
	basket_shape = $Area.shape_owner_get_shape(0, 0)
	
	position = empty_position()
	last_position = position
	update()
	
	material = material.duplicate(true)
	
	for i in content_transforms.size():
		content_transforms[i][1] = Utils.rng.randf_range(-PI/4, PI/4)
	
	
func _draw():
	draw_texture(Utils.get_scaled_res('res://assets/basket/basket_back.png', 128, 128), Vector2(-64,-64))
	
	if content_texture != null:
		for i in range(min(content_transforms.size(), int(amount))):
			var pos = content_transforms[i][0]
			var r = content_transforms[i][1]
			if item.id == 'lucky_clover':
				draw_set_transform(pos+Vector2(0, -25), r, Vector2(0.9,0.9))
			elif item.id == 'fire_flower':
				draw_set_transform(pos+Vector2(0, -25), r, Vector2(1.1,1.1))
			elif item.id in ['mandrake', 'nightshade']:
				draw_set_transform(pos+Vector2(0, -15), r, Vector2(1.3, 1.3))
			elif not item.id in ['ash', 'frost', 'aurum_dust', 'star_dust']:
				draw_set_transform(pos+Vector2(0, -15), r, Vector2(1,1))
			else:
				draw_set_transform(pos+Vector2(0, -15), 0, Vector2(1,1))
			
			draw_texture(content_texture, Vector2(-32,-32))
	
	draw_set_transform(Vector2(0,0), 0, Vector2(1,1))
	
	draw_texture(Utils.get_scaled_res('res://assets/basket/basket_front.png', 128, 128), Vector2(-64,-64))
	
func random_pos():
	return Vector2(Utils.rng.randf_range(bounds.position.x, bounds.position.x + bounds.size.x), Utils.rng.randf_range(bounds.position.y, bounds.position.y + bounds.size.y))

func empty_position():
	var space_state = get_world_2d().direct_space_state
	var pos = random_pos()
	
	while true:
		print(name, pos)
		if is_position_empty(pos, true):
			return pos
		else:
			pos = random_pos()

func is_position_empty(pos, initial=false):
	var space_state = get_world_2d().direct_space_state
	
	var query = Physics2DShapeQueryParameters.new()
	query.collision_layer = Utils.collision_layer(2) # game1
	if initial:
		query.collision_layer = Utils.collision_layer(2) | Utils.collision_layer(3) 
	print(query.collision_layer)
	query.collide_with_bodies = false
	query.collide_with_areas = true
	query.set_transform(Transform2D(0, pos))
	query.set_shape(basket_shape)
	query.exclude = [$Area]
	
	var result = space_state.get_rest_info(query)

	return not result

func init(_item):
	item = _item
	
	content_texture = item.get_scaled_res(64,64)

func _physics_process(delta):
	if not position_ok:
		if is_position_empty(position, true):
			position_ok = true
		else:
			position = empty_position()
			last_position = position
	if picked_up:
		prints(get_viewport(), get_viewport().name, get_viewport().get_mouse_position(), get_global_mouse_position(), Utils.local_mouse_position_viewport(get_viewport()))
		position = Utils.clamp_vector2(Utils.local_mouse_position_viewport(get_viewport()), Rect2(0,0,1355,1016)) + mouse_offset
		if is_position_empty(position) and bounds.has_point(position):
			material.set_shader_param('alpha', 0.7)
			modulate = Color(1,1,1,1)
		else:
			material.set_shader_param('alpha', 0.7)
			modulate = Color(1,0.5,0.5,1)

func set_amount(a):
	amount = a
	update()

func _mouse_area(area, msg):
	if area == $Area:
		match msg:
			{'mouse_over': false, ..}:
				Utils.set_cursor_hand(false)
			{'mouse_over': true, 'button_left_click': var left, 'local_positions': var local_positions,  ..}:
				Utils.set_cursor_hand(true)
				if left:
					if picked_up:
						if not is_position_empty(position) or not bounds.has_point(position):
							position = last_position
						$Area.collision_layer = Utils.collision_layer(3)
						Utils.unregister_mouse_area($Area)
						Utils.register_mouse_area(self, $Area)
						picked_up = false
						modulate = Color(1,1,1,1)
						material.set_shader_param('alpha', 1.0)
					else:
						picked_up = true
						$Area.collision_layer = Utils.collision_layer(4)
						Utils.unregister_mouse_area($Area)
						Utils.register_mouse_area(self, $Area)
						last_position = position
						modulate = Color(1,1,1,1)
						material.set_shader_param('alpha', 0.7)
						mouse_offset = position - local_positions[get_viewport()]

func _on_Area_area_entered(area):
	overlapping.append(area)


func _on_Area_area_exited(area):
	overlapping.erase(area)
