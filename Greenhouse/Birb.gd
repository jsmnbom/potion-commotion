extends Node2D	

var full_size = Vector2(1355, 1016)
var bounding_box = Rect2(128, 128, 1355-256, 1016-256)

var jump_wait = 0
var jump_wait_max = Utils.rng.randf_range(10, 90)

var goal_pos
var last_pos
var jumping = false
var flying = false

var page_node = null
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
	
	random_goal()
	
	$Sprite.frame = 0
	
	
	
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
	if page_node != null:
		if page_node.get_ref():
			page_node.get_ref().position = position + Vector2(0,32)
	
	if not jumping and not flying and not is_offscreen:
		jump_wait += 1
		if jump_wait >= jump_wait_max:
			jump_wait = 0
			jump_wait_max = Utils.rng.randf_range(30, 60)

			var start_pos = position
			if (goal_pos-position).length() < 50:
				random_goal()
			
			var small_goal = position + (goal_pos-position).clamped(100)
			
			if small_goal.x > position.x:
				scale.x = -1
			else:
				scale.x = 1
			
			$Tween.stop_all()
			$Tween.remove_all()
			var top = min(small_goal.y, start_pos.y)-50
			$Tween.interpolate_property(self, 'position:x', start_pos.x, small_goal.x, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.interpolate_property(self, 'position:y', start_pos.y, top, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			$Tween.interpolate_property(self, 'position:y', top, small_goal.y, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN, 0.5)
			$Tween.interpolate_callback(self, 1, 'stop_jumping')
			$Tween.start()
			jumping = true
	
func stop_jumping():
	jumping = false
		

func fetch_page(node):
	page_node = weakref(node)
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
	
	z_index = 6
	
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
	
	$Tween.start()
	$AnimationPlayer.play('Flying')
	
func midway():
	scale.x *= -1
	
	page_node.get_ref().show()
	
func stop_flying():
	flying = false
	$AnimationPlayer.stop()
	$Sprite.frame = 0
	z_index = 2
	page_node = null
	