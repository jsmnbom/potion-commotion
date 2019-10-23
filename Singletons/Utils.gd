extends Node

var rng = RandomNumberGenerator.new()
var custom_cursors = {}
var custom_cursor_stack = []

func _init():
	rng.randomize()

func rng_sample(n, _list):
	var list = _list.duplicate()
	var sample = []
	for i in range(n):
		var x = rng.randi() % list.size()
		sample.append(list[x])
		list.remove(x)
	return sample

func rng_choose(list):
	return list[rng.randi() % list.size()]

func rng_sign():
	return -1 if randf() > 0.5 else 1

func format_number(n):
	var string = str(n)
	var mod = string.length() % 3
	var res = ""

	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ' '
		res += string[i]

	return res

func get_scaled_res(res_path, height, width):
	var img = ResourceLoader.load(res_path)
	if img is ImageTexture or img is StreamTexture:
		img = img.get_data()
	img.resize(height, width, 0)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	return tex

func pluralise(amount, singular_form, plural_form):
	if amount > 1:
		return plural_form
	return singular_form

func time_string(time):
	if time > 60*60-1:
		var n = int(int(time+1)/60/60)
		return '%s %s' % [n, Utils.pluralise(n, 'hour', 'hours')]
	elif time > 60-1:
		var n = int(int(time+1)/60) % 60
		return '%s %s' % [n, Utils.pluralise(n, 'minute', 'minutes')]
	else:
		var n = int(time) % 60
		if n == 0:
			n = 1
		return '%s %s' % [n, Utils.pluralise(n, 'second', 'seconds')]

func set_custom_cursor(name, res, hotspot=null):
	if res == null:
		if custom_cursor_stack.size() > 1:
			if name == custom_cursor_stack[-1]:
				custom_cursor_stack.pop_back()
				var last = custom_cursors[custom_cursor_stack[-1]]
				Input.set_custom_mouse_cursor(last[0], Input.CURSOR_ARROW, last[1])
		elif (custom_cursor_stack.size() == 1 and name == custom_cursor_stack[-1]) or custom_cursor_stack.size() == 0:
			Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
			custom_cursor_stack = []
	else:
		Input.set_custom_mouse_cursor(res, Input.CURSOR_ARROW, hotspot)
		custom_cursors[name] = [res, hotspot]
		while name in custom_cursor_stack:
			custom_cursor_stack.erase(name)
		custom_cursor_stack.append(name)

func set_cursor_arrow():
	for viewport_container in get_tree().get_nodes_in_group('ViewportContainer'):
		viewport_container.mouse_default_cursor_shape = Control.CURSOR_ARROW
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func set_cursor_hand(enabled):
	if not enabled:
		Utils.set_cursor_arrow()
		return
	for viewport_container in get_tree().get_nodes_in_group('ViewportContainer'):
		viewport_container.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
func is_night():
	# Dusk and dawn count too
	if Data.time > 21*60 or Data.time < 6*60:
		return true
	elif (Data.time < 9*60):
		return true
	elif (Data.time < 18*60):
		return false
	elif (Data.time <= 21*60):
		return true
		
func is_day():
	# Dusk and dawn count too
	if Data.time > 21*60 or Data.time < 6*60:
		return false
	elif (Data.time < 9*60):
		return true
	elif (Data.time < 18*60):
		return true
	elif (Data.time <= 21*60):
		return true

func get_global_position(local_position, viewport):
	var container = viewport.get_parent()
	var scale_factor = container.rect_size / viewport.size
	return local_position * scale_factor + container.rect_position


func collision_layer(x):
	return pow(2, x-1)
