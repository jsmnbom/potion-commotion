extends Node2D

onready var greenhouse_viewport_container = $GreenhouseViewportContainer
onready var basement_viewport_container = $BasementViewportContainer
onready var greenhouse_viewport = $GreenhouseViewportContainer/GreenhouseViewport
onready var basement_viewport = $BasementViewportContainer/BasementViewport
onready var greenhouse = $GreenhouseViewportContainer/GreenhouseViewport/Greenhouse
onready var basement = $BasementViewportContainer/BasementViewport/Basement

onready var audio = get_node('/root/PotionCommotion/Audio')

var basement_tooltip = 'Click to start brewing!'
var greenhouse_tooltip = 'Click to go back to your greenhouse!'

var greenhouse_active = true

var selected_item = null
var shovel_picked_up = false

var main_rect = Rect2(Vector2(32, 32), Vector2(1355, 1080-32-32))
var sub_rect = Rect2(Vector2(32+1355+32, 32), Vector2(1920-(32+1355+32+32), 352))

func _ready():
	$ViewportTween.connect('tween_completed', self, '_on_tween_complete')

	Events.connect('save_game', self, 'save_game')
	Events.connect('load_game', self, 'load_game')
	
	Events.connect('inventory_item', self, '_on_inventory_item')
	Events.connect('shovel', self, '_on_shovel')
	Events.connect('unhandled_right_click', self, '_on_unhandled_right_click')
	
	basement_viewport_container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	Utils.register_mouse_area(self, $SubViewportArea)
	
	audio.set_current(true)

func _on_inventory_item(msg):
	match(msg):
		{'selected': var item}:
			selected_item = item
		{'deselected': true}:
			selected_item = null

func _on_shovel(picked_up):
	shovel_picked_up = picked_up

func _on_unhandled_right_click():
	if selected_item:
		Events.emit_signal('inventory_deselect')
	elif shovel_picked_up:
		Events.emit_signal('shovel', false)

func ui_cancel():
	if $Achievements.visible:
		Events.emit_signal('show_achievements', false)
		return true
	elif $Journal.visible:
		Events.emit_signal('show_journal', false)
		return true
	elif selected_item:
		Events.emit_signal('inventory_deselect')
		return true
	elif shovel_picked_up:
		Events.emit_signal('shovel', false)
		return true
	return false

func _input(event):
	if event.is_action_pressed("open_journal") and $JournalPopout.visible:
		Events.emit_signal('show_journal', !$Journal.visible)
	if event.is_action_pressed("open_achevements"):
		Events.emit_signal('show_achievements', !$Achievements.visible)
	if event.is_action_pressed("ui_quit"):
		get_tree().quit()
	if event.is_action_pressed("ui_save"):
		save_game()
	if event.is_action_pressed("ui_load"):
		load_game()

func switch():
	var main_viewport = basement_viewport
	var main_container = basement_viewport_container
	var sub_viewport = greenhouse_viewport
	var sub_container = greenhouse_viewport_container
	if greenhouse_active:
		main_viewport = greenhouse_viewport
		main_container = greenhouse_viewport_container
		sub_viewport = basement_viewport
		sub_container = basement_viewport_container

	greenhouse_viewport_container.mouse_default_cursor_shape = Control.CURSOR_ARROW
	basement_viewport_container.mouse_default_cursor_shape = Control.CURSOR_ARROW
		
	var tween = $ViewportTween
	tween.interpolate_property(sub_container, 'modulate:a',
		1, 0, 0.6, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_property(main_container, 'modulate:a',
		1, 0, 0.6, Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.interpolate_callback(self, 0.6, '_switch_inner', main_container, sub_container, main_viewport, sub_viewport)
	tween.interpolate_property(sub_container, 'modulate:a',
		0, 1, 0.6, Tween.TRANS_QUAD, Tween.EASE_IN, 0.6)
	tween.interpolate_property(main_container, 'modulate:a',
		0, 1, 0.6, Tween.TRANS_QUAD, Tween.EASE_IN, 0.6)
	tween.start()
	
	SFX.footsteps.play(self)
	audio.set_current(greenhouse_active)

func _switch_inner(main_container, sub_container, main_viewport, sub_viewport):
	sub_container.rect_position = sub_rect.position
	sub_container.rect_size = sub_rect.size
	sub_viewport.size = main_rect.size
	main_container.rect_position = main_rect.position
	main_container.rect_size = main_rect.size
	main_viewport.size = main_rect.size

func _on_tween_complete(object, key):
	if greenhouse_active:
		basement_viewport_container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		greenhouse_viewport_container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func serialize_array(nodes):
	var data = []
	for node in nodes:
		data.append(node.serialize())
	return data

func deserialize_array(nodes, array):
	for i in nodes.size():
		var node = nodes[i]
		node.deserialize(array[i])

func save_game():
	print('saving!')
	var data = {
		'time': Data.time,
		'inventory': $Inventory.serialize(),
		'plants': serialize_array(get_tree().get_nodes_in_group('Plants')),
		'achievements': $Achievements.serialize(),
		'gems': $GemDisplay.serialize(),
		'luck': $LuckDisplay.serialize(),
		'birbs': greenhouse.get_node('BirbController').serialize(),
		'play_time': Data.play_time,
		'player_name': Data.player_name,
		'journal': $Journal.serialize()
	}

	var save_file = File.new()
	save_file.open("user://savegame.save", File.WRITE)
	save_file.store_line(to_json(data))
	save_file.close()
	Events.emit_signal('saved')
	
	var sf = $SaveNotification
	var tween = $SaveNotification/Tween

	$SaveNotification/Label2.text = 'Current playtime: %s' % Utils.time_string(Data.play_time)
	
	tween.remove_all()
	sf.show()
	tween.interpolate_property(sf, 'modulate:a',
		sf.modulate.a, 1.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(sf, 'modulate:a',
		1.0, 0.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT, 2)
	tween.interpolate_callback(sf, 2.5, 'hide')
	tween.start()
	

func load_game():
	print('loading!')
	var save_file = File.new()
	if not save_file.file_exists("user://savegame.save"):
		print('No savegame found!')
		return
	save_file.open("user://savegame.save", File.READ)
	var data = parse_json(save_file.get_line())
	
	print('loading time')
	Data.time = int(clamp(data['time'] - 1, 0, 24*60))
	greenhouse._on_DayTimer_timeout()
	print('loading inventory')
	$Inventory.deserialize(data['inventory'])
	print('loading plants')
	deserialize_array(get_tree().get_nodes_in_group('Plants'), data['plants'])
	print('loading achievements')
	$Achievements.deserialize(data['achievements'])
	print('loading gems')
	$GemDisplay.deserialize(data['gems'])
	print('loading luck')
	$LuckDisplay.deserialize(data['luck'])
	print('loading birbs')
	greenhouse.get_node('BirbController').deserialize(data['birbs'])
	print('loading play_time')
	Data.play_time = data['play_time']
	print('loading player_name')
	Data.player_name = data['player_name']
	print('loading journal')
	$Journal.deserialize(data['journal'])
	save_file.close()
	print('done loading!')

	Events.emit_signal('loaded')
		
func _mouse_area(area, msg):
	if area == $SubViewportArea:
		match msg:
			{'mouse_over': false, ..}:
				Events.emit_signal('tooltip', {'hide': true})
			{'mouse_over': true, 'button_left_click': var left, ..}:
				if greenhouse_active:
					Events.emit_signal('tooltip', {'description': basement_tooltip})
					if left:
						greenhouse_active = false
						switch()
				else:
					Events.emit_signal('tooltip', {'description': greenhouse_tooltip})
					if left:
						greenhouse_active = true
						switch()

func _on_PlayTimeTimer_timeout():
	Data.play_time += 1
