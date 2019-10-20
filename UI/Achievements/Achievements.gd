extends Control

var Achievement = preload('res://UI/Achievements/Achievement.tscn')

var achievements = {}

func _ready():
	Events.connect('mouse_area', self, '_on_mouse_area')
	Events.connect('achievement', self, '_on_achievement')

	var bar_texture = AnimatedTexture.new()
	bar_texture.frames = 6
	bar_texture.fps = 8
	for i in range(6):
		bar_texture.set_frame_texture(i, Utils.get_scaled_res('res://assets/ui/bar/%s.png' % i, 68, 34))

	for i in Data.achievements.size():
		var data = Data.achievements[i]
		if Debug.ACHIEVEMENTS:
			if data is Data._AchievementTotal:
				data.total = 150
		var achievement_node = Achievement.instance()
		achievement_node.set_data(data)
		achievement_node.rect_position = Vector2(360+56,180+24)+Vector2((512+64)*floor(i/4), (112+24)*(i%4))
		achievement_node.get_node('BarTexture').texture = bar_texture
		add_child(achievement_node)
		achievements[data.id] = [data, achievement_node]

	_on_Achievements_visibility_changed()

func _on_mouse_area(msg):
	if msg['node'] == $CloseArea:
		match msg:
			{'mouse_over': var mouse_over, 'button_left_click': var left, ..}:
				Utils.set_cursor_hand(mouse_over)
				if mouse_over and left:
					Events.emit_signal('show_achievements', false)

func _on_achievement(msg):
	match msg:
		{'total_id': var total_id, 'total_add': var total_add}:
			achievements[total_id][0].total += total_add
			achievements[total_id][1].set_data(achievements[total_id][0])
		{'diff_id': var diff_id, 'diff_add': var diff_add}:
			var data = achievements[diff_id][0]
			if not diff_add in data.seen:
				data.seen.append(diff_add)
				achievements[diff_id][1].set_data(data)
		{'total_id': var total_id, 'total_add': var total_add, 'diff_id': var diff_id, 'diff_add': var diff_add}:
			var data = achievements[diff_id][0]
			if not diff_add in data.seen:
				data.seen.append(diff_add)
				achievements[diff_id][1].set_data(data)
			achievements[total_id][0].total += total_add
			achievements[total_id][1].set_data(achievements[total_id][0])

func _on_Achievements_visibility_changed():
	for i in achievements:
		achievements[i][1].visible = visible

func serialize():
	var data = {}
	for i in Data.achievements.size():
		var a = Data.achievements[i]
		if a is Data._AchievementDiff:
			data[a.id] = a.seen
		else:
			data[a.id] = a.total
	return data

func deserialize(data):
	for i in data:
		if typeof(data[i]) == TYPE_ARRAY:
			achievements[i][0].seen = []
			for seen in data[i]:
				Events.emit_signal('achievement', {'diff_id': i, 'diff_add': seen})
		else:
			achievements[i][0].total = 0
			Events.emit_signal('achievement', {'total_id': i, 'total_add': data[i]})