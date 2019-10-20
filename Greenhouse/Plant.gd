extends Node2D

var planted = false
var progress = 0
var is_mouse_over = false
var prev_plant_stage = 0
var plant = null
var weeds = false
var offset
var collision_polygons = []
var selected_seed
var selected_potion
var used_potions = []
var next_grow_time = -1
var should_dry_out = false
var dried_out = false

var dry_out_time_min = 5*60
var dry_out_time_max = 30*60

const FROZEN_MODULATE = Color(0.41, 0.81, 0.89)
const FIRE_MODULATE = Color(0.39, 0.08, 0.02)
const GOLD_MODULATE = Color(2,1.5,0)
const FIELD_DRY_MODULATE = Color(0.69, 0.69, 0.69)

onready var overlay = $Overlay
onready var plant_area_collision = $PlantArea/Collision
onready var plant_area = $PlantArea
onready var field_area = $FieldArea
onready var weeds_sprite = $WeedsSprite
onready var plant_sprite = $PlantSprite
onready var field_sprite = $FieldSprite
onready var grow_timer = $GrowTimer
onready var dry_timer = $DryTimer
onready var star_particles = $StarParticles
onready var light = $Light
onready var hydration = $Hydration

func _ready():
	if Debug.DRY:
		dry_out_time_min = 10
		dry_out_time_max = 30
	dry_out()
	
	reset()
	
	$Hydration.texture = Data.inventory_by_id['potion']['hydration'].get_scaled_res(64,64)

	weeds_sprite.texture = Utils.get_scaled_res('res://assets/weeds.png', 128, 128)
	weeds_sprite.hide()

	Events.connect('inventory_item', self, '_on_inventory_item')
	Events.connect('mouse_area', self, '_on_mouse_area')

func reset():
	plant_sprite.hide()
	planted = false
	progress = 0
	plant = null
	collision_polygons = []
	offset = Vector2(0, 0)
	used_potions = []
	star_particles.emitting = false
	light.enabled = false
	for i in range(plant_area.get_children().size()-1, 0, -1 ):
		plant_area.remove_child(plant_area.get_child(i))

	plant_sprite.modulate = Color(1,1,1)

	dry_timer.paused = true
	
	plant_sprite.z_index = 1

	if should_dry_out:
		should_dry_out = false
		dry_out()

func dry_out():
	dried_out = true
	field_sprite.modulate = FIELD_DRY_MODULATE
	dry_timer.stop()
	dry_timer.wait_time = Utils.rng.randf_range(dry_out_time_min, dry_out_time_max)
	dry_timer.start()
	dry_timer.paused = true

func make_wet():
	dried_out = false
	dry_timer.paused = true
	field_sprite.modulate = Color(1,1,1)

func set_plant(_plant):
	plant = _plant
	var plantData = Data.plants[plant]

	grow_timer.wait_time = (float(plantData.growth_time)-1) / 100.0
	
	var res = plantData.get_scaled_res(640, 512)

	collision_polygons = plantData.collision_polygons

	plant_sprite.texture = res
	plant_sprite.region_enabled = true
	plant_sprite.region_rect = Rect2(0,0,128,256)

	offset = Vector2(Utils.rng.randi_range(-8, 8), Utils.rng.randi_range(-16,16))
	plant_sprite.position = offset + Vector2(0, -64)

	light.enabled = true
	match (plant):
		'nightshade':
			light.color = Color(0.45098, 0, 0.811765)
		'fire_flower':
			light.color = Color(1, 0.560784, 0)
		'star_flower':
			light.color = Color(1, 0.984314, 0)
		'golden_berry':
			light.color = Color(1, 0.984314, 0)
		_:
			light.enabled = false

	dry_timer.paused = false

func update_overlays():
	if is_mouse_over:
		if planted:
			emit_tooltip()
			if selected_potion != null and can_use_potion(selected_potion) and progress < 100:
				overlay.show()
			else:
				overlay.hide()
		elif weeds:
			emit_tooltip()
			overlay.show()
		elif dried_out:
			hydration.show()
		else:
			if selected_seed != null and not planted:
				overlay.show()
			else:
				overlay.hide()
			Events.emit_signal('tooltip', {'hide': true})

func tick():
	if not planted:
		return
		
	var night_plants = ['cool_beans', 'nightshade', 'star_flower']
	var day_plants = ['fire_flower', 'golden_berry', 'jade_sunflower']
	
	
	
	var plantStage = int(progress / 25);
	if not prev_plant_stage == plantStage:
		plant_sprite.region_rect.position.x = plantStage * 128
		
		if plantStage > 0:
			plant_sprite.z_index = 3

		for i in range(plant_area.get_children().size()-1, 0, -1 ):
			plant_area.remove_child(plant_area.get_child(i))
	
		for poly in collision_polygons[plantStage]:
			var collision = CollisionPolygon2D.new()
			collision.polygon = poly
			collision.position = Vector2(-64, -128-64) + offset
			plant_area.add_child(collision)
		
	prev_plant_stage = plantStage

	if progress >= 100:
		grow_timer.stop()

	update_overlays()
	
	if plant in night_plants:
		if Utils.is_night():
			$SleepParticles.emitting = false
		else:
			$SleepParticles.emitting = true
		return
	if plant in day_plants:
		if Utils.is_day():
			$SleepParticles.emitting = false
		else:
			$SleepParticles.emitting = true
		return

func emit_tooltip():
	if planted:
		var time_left = (100-progress) * (grow_timer.wait_time if next_grow_time == -1 else next_grow_time) + grow_timer.time_left
		Events.emit_signal('tooltip', {
			'plant': plant,
			'progress': progress,
			'time_left': time_left,
			'used_potions': used_potions,
			'weeds': weeds
		})
	elif weeds:
		Events.emit_signal('tooltip', {
			'plant': null,
			'weeds': weeds
		})
	else:
		Events.emit_signal('tooltip', {'hide': true})

func _on_GrowTimer_timeout():
	if next_grow_time != -1:
		grow_timer.stop()
		grow_timer.wait_time = next_grow_time
		grow_timer.start()
		next_grow_time = -1
	progress += 1
	tick()

func set_weeds():
	weeds = true
	weeds_sprite.show()
	if not 'gardening' in used_potions:
		grow_timer.paused = true
	update_overlays()
	if is_mouse_over:
		Utils.set_custom_cursor('sickle', Utils.get_scaled_res('res://assets/ui/sickle.png', 32, 32), Vector2(16,16))

func _on_inventory_item(msg):
	match(msg):
		{'selected': var item}:
			selected_seed = null
			selected_potion = null
			if item.type == 'seed':
				selected_seed = item
			elif item.type == 'potion':
				selected_potion = item
		{'deselected': true}:
			selected_seed = null
			selected_potion = null

func can_use_potion(potion):
	if potion == null:
		return false
	
	var fully_grown = progress >= 100
	if used_potions.size() >= 2:
		return false

	var only_one = ['flames', 'midas', 'ice', 'stars']
	if potion.id in only_one and potion.id in used_potions:
		return false

	var mutually_exclusive = [['ice', 'flames', 'midas', 'stars']]
	for set in mutually_exclusive:
		if potion.id in set:
			for p in set:
				if p in used_potions:
					return false

	match(potion.id):
		'poison', 'romance', 'wealth', 'healing', 'fortune', 'sunlight', 'midnight':
			return false
		'hydration':
			return dried_out
		'flames', 'ice', 'midas', 'stars':
			return planted
	return not fully_grown and planted

func add_potion(potion, deserializing=false):
	var potion_id
	if deserializing:
		potion_id = potion
	else:
		potion_id = potion.id
	
	if potion_id == 'hydration':
		make_wet()
		hydration.hide()
		return
	
	if not deserializing:
		used_potions.append(potion_id)
	match(potion_id):
		'growth', 'growth2':
			var x = 0.8 if potion_id == 'growth' else 0.5
			var time_left = grow_timer.time_left
			grow_timer.stop()
			next_grow_time = grow_timer.wait_time * x
			grow_timer.wait_time = time_left * x
			grow_timer.start()
		'ice':
			plant_sprite.region_rect.position.y = 256
			plant_sprite.modulate = FROZEN_MODULATE
		'flames':
			plant_sprite.region_rect.position.y = 256
			plant_sprite.modulate = FIRE_MODULATE
		'midas':
			plant_sprite.region_rect.position.y = 256
			plant_sprite.modulate = GOLD_MODULATE
			light.color = Color(1, 0.984314, 0)
			light.enabled = true
		'stars':
			star_particles.emitting = true
			light.color = Color(1, 0.984314, 0)
			light.enabled = true
		'gardening':
			grow_timer.paused = false

func serialize():
	return {
		'planted': planted,
		'progress': progress,
		'plant': plant,
		'weeds': weeds,
		'offset_x': offset.x,
		'offset_y': offset.y,
		'used_potions': used_potions,
		'dried_out': dried_out,
		'should_dry_out': should_dry_out,
		'grow_time_left': grow_timer.time_left,
		'dry_time_left': dry_timer.time_left
	}

func deserialize(data):
	reset()
	planted = data['planted']
	progress = int(data['progress'])
	prev_plant_stage = -1
	used_potions = data['used_potions']
	dried_out = data['dried_out']
	if dried_out:
		dry_out()
	else:
		make_wet()
	should_dry_out = data['should_dry_out']
	dry_timer.wait_time = data['dry_time_left']
	if data['plant'] != null:
		set_plant(data['plant'])
		plant_sprite.show()

		if data['grow_time_left'] > 0:
			next_grow_time = grow_timer.wait_time
			grow_timer.wait_time = data['grow_time_left']

		for used_potion in used_potions:
			add_potion(used_potion, true)

		grow_timer.start()
		planted = true
		tick()
	if data['weeds']:
		set_weeds()
	else:
		weeds = false
		weeds_sprite.hide()
	offset = Vector2(int(data['offset_x']), int(data['offset_y']))

func _on_DryTimer_timeout():
	should_dry_out = true

func _on_mouse_area(msg):
	if msg['node'] == plant_area or msg['node'] == field_area:
		match msg:
			{'mouse_over': false, ..}:
				is_mouse_over = false
				overlay.hide()
				Events.emit_signal('tooltip', {'hide': true})
				hydration.hide()
				Utils.set_custom_cursor('sickle', null)
			{'mouse_over': true, 'button_left': var left, 'button_right': var right, 'button_left_click': var left_click, 'global_position': var position, ..}:
				if left_click and weeds:
					weeds = false
					weeds_sprite.hide()
					Events.emit_signal('inventory_add', {
						'type': 'resource',
						'id': 'weeds',
						'animated': true,
						'from_position': position
					})
					grow_timer.paused = false
					Utils.set_custom_cursor('sickle', null)
					Events.emit_signal('tooltip', {'hide': true})
					overlay.hide()
				elif left_click and can_use_potion(selected_potion):
					add_potion(selected_potion)
					Events.emit_signal('inventory_add', {'type': 'potion', 'id': selected_potion.id, 'count': -1})
					Events.emit_signal('achievement', {'total_id': 'total_potions', 'total_add': 1})
				elif left and planted and progress >= 100 and not weeds:
					var drop = plant
					if 'flames' in used_potions:
						drop = 'ash'
					elif 'ice' in used_potions:
						drop = 'frost'
					elif 'midas' in used_potions:
						drop = 'aurum_dust'
					elif 'stars' in used_potions:
						drop = 'star_dust'
					Events.emit_signal('achievement', {'diff_id': 'diff_plants', 'diff_add': plant, 'total_id': 'total_plants', 'total_add': 1})
					Events.emit_signal('inventory_add', {
						'type': 'resource',
						'id': drop,
						'animated': true,
						'from_position': position,
						'count': Utils.rng_choose([1,1,2])
					})
					reset()
					Utils.set_custom_cursor('sickle', null)
				elif left and not planted and selected_seed != null and not dried_out and not weeds:
					set_plant(selected_seed.id)
					Events.emit_signal('inventory_add', {'type': 'seed', 'id': plant, 'count': -1})
					plant_sprite.show();
					grow_timer.start()
					planted = true
				elif (right and planted and progress >= 100 and not ('flames' in used_potions or \
																	 'ice' in used_potions or \
																	 'midas' in used_potions or \
																	 'stars' in used_potions)):
					Events.emit_signal('achievement', {'diff_id': 'diff_plants', 'diff_add': plant, 'total_id': 'total_plants', 'total_add': 1})
					Events.emit_signal('inventory_add', {
						'type': 'seed',
						'id': plant,
						'animated': true,
						'from_position': position,
						'count': Utils.rng_choose([2,2,3,3,4])
					})
					reset()
				elif (planted and progress >= 100) or weeds:
					Utils.set_custom_cursor('sickle', Utils.get_scaled_res('res://assets/ui/sickle.png', 32, 32), Vector2(16,16))
				is_mouse_over = true
				update_overlays()
				