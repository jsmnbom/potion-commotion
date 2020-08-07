extends Node2D	

var full_size = Vector2(1355, 1016)
var bounding_box = Rect2(128, 128, 1355-256, 1016-256)

var jump_wait = 0
var jump_wait_max = Utils.rng.randf_range(10, 90)

var goal_pos
var last_pos
var small_goal = Vector2(0,0)
var top = 0
var jumping = false
var flying = false

var page_node_ref = null
var is_offscreen = true

func random_pos():
	return Vector2(
		Utils.rng.randf_range(bounding_box.position.x, bounding_box.position.x + bounding_box.size.x),
		Utils.rng.randf_range(bounding_box.position.y, bounding_box.position.y + bounding_box.size.y)
	)
	
func random_offscreen_pos():
	return Vector2(Utils.rng_sample(1, [-128, full_size.x+128])[0], position.y + (Utils.rng_sign() * Utils.rng.randf_range(50, 200)))

func _ready():
	position = random_pos()
	position = random_offscreen_pos()
	last_pos = position
	
	random_goal()
	
	$Sprite.frame = 0

	z_index = 5
	
func random_goal():
	goal_pos = Vector2(
		Utils.rng.randf_range(bounding_box.position.x, bounding_box.position.x + bounding_box.size.x),
		position.y + (Utils.rng_sign() * Utils.rng.randf_range(50, 200))
	)
	if goal_pos.y > bounding_box.position.y + bounding_box.size.y:
		goal_pos.y = bounding_box.position.y + bounding_box.size.y
	if goal_pos.y < bounding_box.position.y:
		goal_pos.y = bounding_box.position.y
	
	
func _physics_process(delta):
	#update()

	if not flying:
		for plant in overlapping_plants:
			if self.position.y > overlapping_plants[plant] or small_goal.y > overlapping_plants[plant] or top > overlapping_plants[plant]:
				z_index = plant.plant_sprite.z_index + 2
				if not plant in in_front_of_plants:
					in_front_of_plants.append(plant)
			else:
				if plant in in_front_of_plants:
					in_front_of_plants.erase(plant)
					if in_front_of_plants.size() == 0:
						z_index = 5

	if page_node_ref != null:
		var page_node = page_node_ref.get_ref()
		if page_node:
			page_node.position = position + Vector2(0,32)
			page_node.z_index = 17
			page_node.destination = last_pos
	
	if not jumping and not flying and not is_offscreen:
		jump_wait += 1
		if jump_wait >= jump_wait_max:
			jump_wait = 0
			jump_wait_max = Utils.rng.randf_range(30, 60)

			var start_pos = position
			if (goal_pos-position).length() < 50:
				random_goal()
			
			small_goal = position + (goal_pos-position).clamped(100)
			
			if small_goal.x > position.x:
				scale.x = -1
			else:
				scale.x = 1
			
			$Tween.stop_all()
			$Tween.remove_all()
			top = min(small_goal.y, start_pos.y)-50
			$Tween.interpolate_property(self, 'position:x', start_pos.x, small_goal.x, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.interpolate_property(self, 'position:y', start_pos.y, top, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			$Tween.interpolate_property(self, 'position:y', top, small_goal.y, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN, 0.5)
			$Tween.interpolate_callback(self, 1, 'stop_jumping')
			$Tween.start()
			jumping = true
	
func stop_jumping():
	jumping = false
	small_goal = Vector2(0,0)
	top = 0
	SFX.footstep.play(self)

func fetch_page(node):
	page_node_ref = weakref(node)
	#prints(name, 'start_flying')
	flying = true
	
	var offscreen_pos
	
	if is_offscreen:
		last_pos = random_pos()
		offscreen_pos = position
	else:
		last_pos = position
		offscreen_pos = random_offscreen_pos()
	var time = (offscreen_pos-last_pos).length()/400
	
	$Tween.stop_all()
	$Tween.remove_all()
	jumping = false
	
	if offscreen_pos.x > last_pos.x:
		scale.x = -1
	else:
		scale.x = 1
	
	z_index = 18
	
	if is_offscreen:
		midway()
		$Tween.interpolate_property(self, 'position', offscreen_pos, last_pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
		$Tween.interpolate_callback(self, time, 'stop_flying')
		is_offscreen = false
	else:
		$Tween.interpolate_property(self, 'position', last_pos, offscreen_pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.interpolate_callback(self, time+1, 'midway')
		$Tween.interpolate_property(self, 'position', offscreen_pos, last_pos, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, time+5)
		$Tween.interpolate_callback(self, time+time+5, 'stop_flying')
		SFX.bird_wings.play2d(self)
	
	$Tween.start()
	$AnimationPlayer.play('Flying')
	
func midway():
	scale.x *= -1
	
	page_node_ref.get_ref().show()
	
func stop_flying():
	#prints(name, 'stop_flying')
	$AnimationPlayer.stop()
	$Sprite.frame = 0
	z_index = 5
	if page_node_ref != null:
		var page_node = page_node_ref.get_ref()
		if page_node:
			page_node.z_index = 3
	page_node_ref = null
	flying = false
	SFX.bird_call.play2d(self)

func serialize():
	return {
		'is_offscreen': is_offscreen,
		'pos': [last_pos.x, last_pos.y] if flying else [position.x, position.y],
		'goal_pos': [goal_pos.x, goal_pos.y]
	}

func deserialize(data):
	is_offscreen = data['is_offscreen']
	position = Vector2(data['pos'][0], data['pos'][1])
	goal_pos = Vector2(data['goal_pos'][0], data['goal_pos'][1])
	stop_flying()

# func _draw():
# 	#draw_line(Vector2(0, 500)- self.position,Vector2(1355, 500)- self.position , Color(255,0,0), 5)
# 	for plant in in_front_of_plants:
# 		if plant.planted:
# 			draw_line(Vector2(0, plant.bottom_y())- self.position, Vector2(1355, plant.bottom_y())-self.position, Color(255,0 if name == 'Birb2' else 255,0), 5)

var overlapping_plants = {}
var in_front_of_plants = []

func _on_Area_area_entered(area):
	var plant =  area.get_parent()
	if plant.planted:
		overlapping_plants[area.get_parent()] = area.get_parent().bottom_y()


func _on_Area_area_exited(area):
	var plant =  area.get_parent()
	if plant in overlapping_plants:
		overlapping_plants.erase(plant)
		if plant in in_front_of_plants:
			in_front_of_plants.erase(plant)
			if in_front_of_plants.size() == 0:
				z_index = 5
