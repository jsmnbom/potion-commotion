extends Node2D

var weed_wait_min = 30
var weed_wait_max = 5*30

var selected_potion = null

var GemParticles = preload('res://Greenhouse/GemParticles.tscn')

var time = 9*60
var day_duration = 20*60

func _ready():
	if Debug.WEEDS:
		weed_wait_min = 5
		weed_wait_max = 5
	$WeedsTimer.wait_time = Utils.rng.randf_range(weed_wait_min, weed_wait_max)
	$WeedsTimer.start()

	$DayTimer.wait_time = float(day_duration) / (24.0*60)
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
	Events.connect('mouse_area', self, '_on_mouse_area')

func _on_mouse_area(msg):
	if msg['node'] == $BGArea:
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
							time = 9*60
							_on_DayTimer_timeout()
						'midnight':
							time = 21*60
							_on_DayTimer_timeout()
	
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
	var wet_plants = []
	for plant in $Plants.get_children():
		if not plant.dried_out:
			wet_plants.append(plant)
	if wet_plants.size() > 0:
		var plant = wet_plants[Utils.rng.randi_range(0, wet_plants.size()-1)]
		plant.set_weeds()

func _on_DayTimer_timeout():
	time = (time + 1) % (24*60)

	var NIGHT = Color(0.427451, 0.376471, 0.788235)
	var DAY = Color(1.28, 1.18, 1.03)
	
	var t = 0.0
	
	if time > 21*60 or time < 6*60:
		t = time - 21*60 if time > 21*60 else time + 3*60
		if t < 4.5*60:
			t = range_lerp(float(t), 0, 4.5*60, 0.2, 0)
		else:
			t = range_lerp(float(t), 4.5*60, 9*60, 0, 0.2)
	elif (time < 9*60):
		t = range_lerp(float(time), 6*60, 9*60, 0.2, 0.8)
	elif (time < 18*60):
		if time < 13.5*60:
			t = range_lerp(float(time), 9*60, 13.5*60, 0.8, 1)
		else:
			t = range_lerp(float(time), 13.5*60, 18*60, 1, 0.8)
	elif (time <= 21*60):
		t = range_lerp(float(time), 18*60, 21*60, 0.8, 0.2)
	#prints(time, t)
	modulate = NIGHT.linear_interpolate(DAY, t)

	for plant in $Plants.get_children():
		plant.light.energy = 1 - t
	#print(modulate)
