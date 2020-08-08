extends Node2D

var weed_wait_min = 30
var weed_wait_max = 3*30
var rain_wait_min = 5*60
var rain_wait_max = 20*60
var raining = false
var rain_hydrated_fields = 0

var selected_potion = null

var GemParticles = preload('./GemParticles.tscn')

func _ready():
	if Debug.WEEDS:
		weed_wait_min = 5
		weed_wait_max = 5
	$WeedsTimer.wait_time = Utils.rng.randf_range(weed_wait_min, weed_wait_max)
	$WeedsTimer.start()

	if Debug.RAIN:
		rain_wait_min = 60
		rain_wait_max = 2*60
	$RainTimer.wait_time = Utils.rng.randf_range(rain_wait_min, rain_wait_max)
	$RainTimer.start()

	$DayTimer.wait_time = float(Data.day_duration) / (24.0*60)
	$DayTimer.start()
	_on_DayTimer_timeout()

	var plants = $Plants.get_children()
	for plant in plants:
		if Debug.START_WET:
			plant.make_wet()
		plant.add_to_group('Plants')
		
	for plant in Utils.rng_sample(2, plants):
		plant.make_wet()

	Events.connect('inventory_item', self, '_on_inventory_item')
	
	Utils.register_mouse_area(self, $BGArea)

func _mouse_area(area, msg):
	if area == $BGArea:
		match msg:
			{'mouse_over': true, 'button_left_click': var left, 'local_positions': var local_positions, ..}:
				if left and selected_potion != null:
					match(selected_potion.id):
						'wealth':
							Events.emit_signal('inventory_add', {'type': 'potion', 'id': 'wealth', 'count': -1})
							Events.emit_signal('achievement', {'total_id': 'total_potions', 'total_add': 1})
							Events.emit_signal('gems_add', {'amount': pow(10, 6)})
							var particles = GemParticles.instance()
							particles.position = local_positions[get_viewport()]
							particles.emitting = true
							add_child(particles)
						'sunlight':
							Data.time = 9*60
							_on_DayTimer_timeout()
							Events.emit_signal('inventory_add', {'type': 'potion', 'id': 'sunlight', 'count': -1})
							Events.emit_signal('achievement', {'total_id': 'total_potions', 'total_add': 1})
							SFX.sunlight_potion_use.play(self)
						'midnight':
							Data.time = 21*60
							_on_DayTimer_timeout()
							Events.emit_signal('inventory_add', {'type': 'potion', 'id': 'midnight', 'count': -1})
							Events.emit_signal('achievement', {'total_id': 'total_potions', 'total_add': 1})
							SFX.midnight_potion_use.play(self)
						'fortune':
							if Data.luck <= 0.8001:
								Events.emit_signal('add_luck', 0.2)
								Events.emit_signal('inventory_add', {'type': 'potion', 'id': 'fortune', 'count': -1})
								Events.emit_signal('achievement', {'total_id': 'total_potions', 'total_add': 1})
								luck_potion_effect(local_positions[get_viewport()])
								SFX.luck_potion_use.play(self)
							else:
								SFX.error.play(self)

func luck_potion_effect(pos):
	var tween = Tween.new()

	var sprite = Sprite.new()
	sprite.texture = load('res://assets/greenhouse/luck_potion_effect.png')

	sprite.scale = Vector2(0,0)
	sprite.modulate = Color(1,1,1,0.3)
	sprite.position = pos
	sprite.z_as_relative = false
	sprite.z_index = 19

	tween.add_child(sprite)

	tween.interpolate_property(sprite, 'scale',
		sprite.scale, Vector2(15, 15), 1.0,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.interpolate_callback(tween, 1.0, 'queue_free')
	tween.interpolate_property(sprite, 'rotation',
		0, TAU, 1.0,
		Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.interpolate_property(sprite, 'modulate:a',
		0.3, 0.0, 0.2,
		Tween.TRANS_QUART, Tween.EASE_OUT, 0.8)

	add_child(tween)
	tween.start()

func _on_inventory_item(msg):
	match(msg):
		{'selected': var item}:
			selected_potion = null
			if item.type == 'potion':
				selected_potion = item
		{'deselected': true}:
			selected_potion = null

func _on_WeedsTimer_timeout():
	$WeedsTimer.wait_time = Utils.rng.randf_range(weed_wait_min, weed_wait_max)
	var unweeded = []
	for plant in $Plants.get_children():
		if not plant.weeds:
			unweeded.append(plant)
	if unweeded.size() > 0:
		var plant = unweeded[Utils.rng.randi_range(0, unweeded.size()-1)]
		plant.set_weeds()

func _on_DayTimer_timeout():
	Data.time = (Data.time + 1) % (24*60)

	var NIGHT = Color(0.427451, 0.376471, 0.788235)
	var DAY = Color(1.28, 1.18, 1.03)
	
	var t = 0.0
	
	if Data.time > 21*60 or Data.time < 6*60:
		t = Data.time - 21*60 if Data.time > 21*60 else Data.time + 3*60
		if t < 4.5*60:
			t = range_lerp(float(t), 0, 4.5*60, 0.2, 0)
		else:
			t = range_lerp(float(t), 4.5*60, 9*60, 0, 0.2)
	elif (Data.time < 9*60):
		t = range_lerp(float(Data.time), 6*60, 9*60, 0.2, 0.8)
	elif (Data.time < 18*60):
		if Data.time < 13.5*60:
			t = range_lerp(float(Data.time), 9*60, 13.5*60, 0.8, 1)
		else:
			t = range_lerp(float(Data.time), 13.5*60, 18*60, 1, 0.8)
	elif (Data.time <= 21*60):
		t = range_lerp(float(Data.time), 18*60, 21*60, 0.8, 0.2)
	modulate = NIGHT.linear_interpolate(DAY, t)

func _on_RainTimer_timeout():
	if raining:
		var dried_out = []
		for plant in $Plants.get_children():
			if plant.dried_out:
				dried_out.append(plant)
		if dried_out.size() > 1:
			Utils.rng_choose(dried_out).make_wet()
		rain_hydrated_fields += 1

		if rain_hydrated_fields >= 5:
			$Rain.emitting = false
			$RainSplash.emitting = false
			$RainTimer.wait_time = Utils.rng.randf_range(rain_wait_min, rain_wait_max)
			$RainTimer.start()
			raining = false
			Audio.set_rain(false)
	else:
		$Rain.emitting = true
		$RainSplash.emitting = true
		$RainTimer.wait_time = Utils.rng.randf_range(rain_wait_min/60, rain_wait_max/60)
		$RainTimer.start()
		raining = true
		Audio.set_rain(true)
