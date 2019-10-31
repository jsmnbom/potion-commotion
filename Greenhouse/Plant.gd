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
var shovel_picked_up = false

var dry_out_time_min = 5*60
var dry_out_time_max = 30*60

const FROZEN_MODULATE = Color(0.41, 0.81, 0.89)
const FIRE_MODULATE = Color(0.39, 0.08, 0.02)
const GOLD_MODULATE = Color(2,1.5,0)
const FIELD_DRY_MODULATE = Color(0.69, 0.69, 0.69)

onready var overlay = $Overlay
onready var plant_area = $PlantArea
onready var field_area = $FieldArea
onready var weeds_sprite = $WeedsSprite
onready var plant_sprite = $PlantSprite
onready var field_sprite = $FieldSprite
onready var grow_timer = $GrowTimer
onready var dry_timer = $DryTimer
onready var star_particles = $StarParticles
onready var sleep_particles = $SleepParticles
onready var light = $Light
onready var hydration = $Hydration

func _ready():
	if Debug.DRY:
		dry_out_time_min = 10
		dry_out_time_max = 30
	reset()
	
	dry_out()
	
	$Hydration.texture = Data.inventory_by_id['potion']['hydration'].get_scaled_res(64,64)

	weeds_sprite.texture = Utils.get_scaled_res('res://assets/weeds.png', 128, 128)
	weeds_sprite.hide()

	Events.connect('inventory_item', self, '_on_inventory_item')
	Events.connect('shovel', self, '_on_shovel')
	
	plant_area.set_meta('area_pretend_to_be', field_area)
	Utils.register_mouse_area(self, field_area)
	Utils.register_mouse_area(self, plant_area)


func reset():
	plant_sprite.hide()
	planted = false
	progress = 0
	plant = null
	collision_polygons = []
	offset = Vector2(0, 0)
	used_potions = []
	star_particles.emitting = false
	sleep_particles.emitting = false
	light.enabled = false
	for i in range(plant_area.get_children().size()):
		plant_area.remove_child(plant_area.get_child(0))

	plant_sprite.modulate = Color(1,1,1)
	field_sprite.modulate = Color(1,1,1)
	
	$FieldPotionOverlay.texture = null
	
	dry_timer.paused = true
	
	plant_sprite.z_index = 2
	sleep_particles.z_index = 3
	star_particles.z_index = 3
	weeds_sprite.z_index = 3

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
			if (selected_potion != null and can_use_potion(selected_potion) and progress < 100) or shovel_picked_up:
				overlay.show()
			else:
				overlay.hide()
		elif weeds:
			emit_tooltip()
			overlay.show()
		elif dried_out:
			hydration.show()
			if selected_potion and selected_potion.id == 'hydration':
				overlay.show()
			else:
				overlay.hide()
		else:
			if selected_seed != null and not planted:
				overlay.show()
			else:
				overlay.hide()
			Events.emit_signal('tooltip', {'hide': true})
	else:
		overlay.hide()

func tick():
	if not planted:
		return
		
	var night_plants = ['cool_beans', 'nightshade', 'star_flower']
	var day_plants = ['fire_flower', 'golden_berry', 'jade_sunflower']
	
	if plant in night_plants:
		if Utils.is_night():
			sleep_particles.emitting = false
		else:
			sleep_particles.emitting = true
			return
	if plant in day_plants:
		if Utils.is_day():
			sleep_particles.emitting = false
		else:
			sleep_particles.emitting = true
			return
		
	progress += 1
	
	var plantStage = int(progress / 25)
	if not prev_plant_stage == plantStage:
		plant_sprite.region_rect.position.x = plantStage * 128
		
		if plantStage > 0:
			if position.y > 736:
				# row 4
				plant_sprite.z_index = 15
				sleep_particles.z_index = 16
				star_particles.z_index = 16
				weeds_sprite.z_index = 16
			elif position.y > 544:
				#row 3
				plant_sprite.z_index = 12
				sleep_particles.z_index = 13
				star_particles.z_index = 13
				weeds_sprite.z_index = 13
			elif position.y > 352:
				#row 2
				plant_sprite.z_index = 9
				sleep_particles.z_index = 10
				star_particles.z_index = 10
				weeds_sprite.z_index = 10
			else:
				# row 1
				plant_sprite.z_index = 6
				sleep_particles.z_index = 7
				star_particles.z_index = 7
				weeds_sprite.z_index = 7
			

			for i in range(plant_area.get_children().size()):
				plant_area.remove_child(plant_area.get_child(0))
		
			for poly in collision_polygons[plantStage]:
				var collision = CollisionPolygon2D.new()
				collision.polygon = poly
				collision.position = Vector2(-64, -128-64) + offset
				plant_area.add_child(collision)
		
	prev_plant_stage = plantStage

	if progress >= 100:
		grow_timer.stop()

	update_overlays()
	update_cursor()

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
	tick()

func set_weeds():
	weeds = true
	weeds_sprite.show()
	if not 'gardening' in used_potions:
		grow_timer.paused = true
	update_overlays()
	update_cursor()

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
			var x = 0.75 if potion_id == 'growth' else 0.5
			var time_left = grow_timer.time_left
			grow_timer.stop()
			next_grow_time = grow_timer.wait_time * x
			grow_timer.wait_time = time_left * x
			grow_timer.start()
			field_sprite.modulate = field_sprite.modulate.blend(Color('66d37f42'))
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
			$FieldPotionOverlay.texture = Utils.get_scaled_res('res://assets/field_gardening.png', 128, 128)

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
		offset = Vector2(int(data['offset_x']), int(data['offset_y']))
		plant_sprite.position = offset + Vector2(0, -64)
		plant_sprite.show()

		if data['grow_time_left'] > 0:
			next_grow_time = grow_timer.wait_time
			grow_timer.wait_time = data['grow_time_left']

		for used_potion in used_potions:
			add_potion(used_potion, true)

		grow_timer.start()
		planted = true
		
		tick()
	else:
		offset = Vector2(0,0)
	if data['weeds']:
		set_weeds()
	else:
		weeds = false
		weeds_sprite.hide()

func _on_DryTimer_timeout():
	should_dry_out = true

func update_cursor():
	if is_mouse_over:
		if (planted and progress >= 100) or weeds:
			Utils.set_custom_cursor('sickle', Utils.get_scaled_res('res://assets/ui/sickle.png', 32, 32), Vector2(16,16))
		else:
			Utils.set_custom_cursor('sickle', null)

func _on_shovel(picked_up):
	shovel_picked_up = picked_up
	update_overlays()
	update_cursor()

func _mouse_area(area, msg):
	if area == plant_area or area == field_area:
		match msg:
			{'mouse_over': false, ..}:
				is_mouse_over = false
				overlay.hide()
				Events.emit_signal('tooltip', {'hide': true})
				hydration.hide()
				Utils.set_custom_cursor('sickle', null)
			{'mouse_over': true, 'button_left': var left, 'button_right': var right, 'button_left_click': var left_click, 'button_right_click': var right_click, 'global_position': var position, ..}:
				var used_click = true
				if (left_click or right_click) and weeds:
					weeds = false
					weeds_sprite.hide()
					Events.emit_signal('inventory_add', {
						'type': 'resource',
						'id': 'weeds',
						'animated': true,
						'from_position': position,
						'count': round(Utils.rng_choose([2,2,2,3])*(1+Data.luck))
					})
					grow_timer.paused = false
					update_cursor()
					update_overlays()
					Events.emit_signal('tooltip', {'hide': true})
					if right_click:
						Utils.set_right_click_handled()
				elif left_click and can_use_potion(selected_potion) and not weeds:
					add_potion(selected_potion)
					Events.emit_signal('inventory_add', {'type': 'potion', 'id': selected_potion.id, 'count': -1})
					Events.emit_signal('achievement', {'total_id': 'total_potions', 'total_add': 1})
				elif (left or (right and plant == 'hydroangea')) and planted and progress >= 100 and not weeds and (Data.plant_current_click_action == 'harvest' or Data.plant_current_click_action == null):
					$BreakParticles.process_material.set_shader_param('plant_texture', $PlantSprite.texture.duplicate())
					$BreakParticles.emitting = true
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
						'count': round(Utils.rng_choose([1,1,2])*(1+Data.luck))
					})
					reset()
					update_cursor()
					Data.plant_current_click_action = 'harvest'
					if right:
						Utils.set_right_click_handled()
				elif left and not planted and selected_seed != null and not dried_out and not weeds and (Data.plant_current_click_action == 'planting' or Data.plant_current_click_action == null):
					set_plant(selected_seed.id)
					Events.emit_signal('inventory_add', {'type': 'seed', 'id': plant, 'count': -1})
					plant_sprite.show();
					grow_timer.start()
					planted = true
					Data.plant_current_click_action = 'planting'
				elif (right and planted and progress >= 100 and not weeds and not ('flames' in used_potions or \
																				   'ice' in used_potions or \
																				   'midas' in used_potions or \
																				   'stars' in used_potions) and (Data.plant_current_click_action == 'harvest' or Data.plant_current_click_action == null)):
					$BreakParticles.process_material.set_shader_param('plant_texture', $PlantSprite.texture.duplicate())
					$BreakParticles.emitting = true
					Events.emit_signal('achievement', {'diff_id': 'diff_plants', 'diff_add': plant, 'total_id': 'total_plants', 'total_add': 1})
					Events.emit_signal('inventory_add', {
						'type': 'seed',
						'id': plant,
						'animated': true,
						'from_position': position,
						'count': round(Utils.rng_choose([2,2,3,3,4])*(1+Data.luck))
					})
					reset()
					update_cursor()
					Data.plant_current_click_action = 'harvest'
					Utils.set_right_click_handled()
				elif left and shovel_picked_up and planted and not weeds and (Data.plant_current_click_action == 'shoveling' or Data.plant_current_click_action == null):
					Events.emit_signal('achievement', {'diff_id': 'diff_plants', 'diff_add': plant})
					Events.emit_signal('inventory_add', {
						'type': 'seed',
						'id': plant,
						'animated': true,
						'from_position': position,
						'count': 1
					})
					reset()
					update_cursor()
					Data.plant_current_click_action = 'shoveling'
				else:
					used_click = false
				is_mouse_over = true
				update_overlays()
				update_cursor()
				if not used_click:
					return Utils.collision_layer(1)

func bottom_y():
	var highest = 0
	var plantStage = int(progress / 25)
	for poly in collision_polygons[plantStage]:
		for vec in poly:
			if vec.y > highest:
				highest = vec.y
	return position.y + highest -128-64-8 + offset.y