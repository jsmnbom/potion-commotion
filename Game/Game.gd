extends Node2D

onready var greenhouse_viewport_container = $GreenhouseViewportContainer
onready var brewing_viewport_container = $BrewingViewportContainer
onready var greenhouse_viewport = $GreenhouseViewportContainer/GreenhouseViewport
onready var brewing_viewport = $BrewingViewportContainer/BrewingViewport
onready var brewing = $BrewingViewportContainer/BrewingViewport/Brewing
onready var greenhouse = $GreenhouseViewportContainer/GreenhouseViewport/Greenhouse

var brewing_tooltip = 'Click to start brewing!'
var greenhouse_tooltip = 'Click to go back to your greenhouse!'

var greenhouse_active = true

var selected_item = null

var main_rect = Rect2(Vector2(32, 32), Vector2(1355, 1080-32-32))
var sub_rect = Rect2(Vector2(32+1355+32, 32), Vector2(1920-(32+1355+32+32), 352))

func _ready():
	Events.connect('mouse_area', self, '_on_mouse_area')
	$ViewportTween.connect('tween_completed', self, '_on_tween_complete')
	Events.connect('show_achievements', self, '_on_show_achievements')

	Events.connect('save_game', self, 'save_game')
	Events.connect('load_game', self, 'load_game')
	
	Events.connect('inventory_item', self, '_on_inventory_item')
	
	brewing_viewport_container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_inventory_item(msg):
	match(msg):
		{'selected': var item}:
			selected_item = item
		{'deselected': true}:
			selected_item = null

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
	var main_viewport = brewing_viewport
	var main_container = brewing_viewport_container
	var sub_viewport = greenhouse_viewport
	var sub_container = greenhouse_viewport_container
	if greenhouse_active:
		main_viewport = greenhouse_viewport
		main_container = greenhouse_viewport_container
		sub_viewport = brewing_viewport
		sub_container = brewing_viewport_container

	greenhouse_viewport_container.mouse_default_cursor_shape = Control.CURSOR_ARROW
	brewing_viewport_container.mouse_default_cursor_shape = Control.CURSOR_ARROW
		
	var tween = $ViewportTween
	tween.interpolate_property(sub_container, 'rect_position',
		sub_container.rect_position, sub_rect.position, 1,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.interpolate_property(sub_container, 'rect_size',
		sub_container.rect_size, sub_rect.size, 1,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.interpolate_property(main_container, 'rect_position',
		main_container.rect_position, main_rect.position, 1,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.interpolate_property(main_container, 'rect_size',
		main_container.rect_size, main_rect.size, 1,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.interpolate_property(main_viewport, 'size',
		main_viewport.size, main_rect.size, 1,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.interpolate_property(sub_viewport, 'size',
		sub_viewport.size, main_rect.size, 1,
		Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	tween.start()

func _on_tween_complete(object, key):
	if greenhouse_active:
		brewing_viewport_container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
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
		'plants': serialize_array(get_tree().get_nodes_in_group('Plants')),
		'inventory': $Inventory.serialize(),
		'achievements': $Achievements.serialize(),
		'gems': $GemDisplay.serialize(),
		'luck': $LuckDisplay.serialize(),
		'birbs': greenhouse.get_node('BirbController').serialize(),
		'time': Data.time,
		'play_time': Data.play_time,
		'journal': $Journal.serialize(),
		'player_name': Data.player_name
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
	print('loading time')
	Data.time = int(clamp(data['time'] - 1, 0, 24*60))
	greenhouse._on_DayTimer_timeout()
	print('loading play_time')
	Data.play_time = data['play_time']
	print('loading journal')
	$Journal.deserialize(data['journal'])
	print('loading player_name')
	Data.player_name = data['player_name']
	save_file.close()
	print('done loading!')

func _on_show_achievements(show):
	if show:
		$Achievements.show()
	else:
		$Achievements.hide()
		
func _on_mouse_area(msg):
	if msg['node'] == $SubViewportArea:
		match msg:
			{'mouse_over': false, ..}:
				Events.emit_signal('tooltip', {'hide': true})
			{'mouse_over': true, 'button_left_click': var left, ..}:
				if greenhouse_active:
					Events.emit_signal('tooltip', {'description': brewing_tooltip})
					if left:
						greenhouse_active = false
						switch()
				else:
					if left:
						greenhouse_active = true
						switch()
					Events.emit_signal('tooltip', {'description': greenhouse_tooltip})

func _on_PlayTimeTimer_timeout():
	Data.play_time += 1
