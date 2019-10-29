extends Node2D

func _ready():
	Events.connect('mouse_area', self, '_on_mouse_area')

func _physics_process(delta):
	$ClockHand.rotation = (float(Data.time)/(24*60)) * TAU + PI

	# Day = 9*60
	# Night = 21*60

	var t = 0
	var till = ''
	var unit = 'sec'

	if Data.time > 21*60 or Data.time < 9*60:
		till = 'daytime'
		t = 9*60-Data.time
		if Data.time > 21*60:
			t += 24*60
	elif (Data.time <= 21*60):
		till = 'nighttime'
		t = 21*60-Data.time
	
	t = range_lerp(t, 0, 24*60, 0, Data.day_duration)
	if t > 60:
		t = float(t) / 60
		unit = 'min'
	$Label.set_text('%s %s to\n%s' % [floor(t), unit, till])
	
func _on_mouse_area(msg):
	if msg['node'] == $Area:
		match msg:
			{'mouse_over': false, ..}:
				$Label.hide()
				$ClockHand.show()
			{'mouse_over': true, 'button_left_click': var left, ..}:
				$Label.show()
				$ClockHand.hide()