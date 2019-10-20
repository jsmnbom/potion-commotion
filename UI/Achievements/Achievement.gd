extends Control

var BRONZE_MODULATE = Color(0.670898, 0.460699, 0.209001)
var SILVER_MODULATE = Color(0.807843, 0.807843, 0.807843)
var GOLD_MODULATE = Color(0.94902, 0.866667, 0.254902)

var value: float
var raw_text
var steps
var mouse_over = false

func _ready():
	Events.connect('mouse_area', self, '_on_mouse_area')

	set_value(0)

func set_data(data):
	raw_text = data.text.replace(' ', '  ')
	steps = data.steps
	set_value(data.value)

func set_value(_value):
	value = _value
	var goal: float
	var progress
	if value < steps[0]:
		$BarTexture.modulate = BRONZE_MODULATE
		goal = steps[0]
		progress = value / goal
	elif value < steps[1]:
		$BarTexture.modulate = SILVER_MODULATE
		goal = steps[1]
		progress = value / goal
	else:
		$BarTexture.modulate = GOLD_MODULATE
		goal = steps[2]
		progress = value / goal

	if mouse_over:
		$ProgressLabel.set_text('%s  /  %s' % [Utils.format_number(value), Utils.format_number(goal)])
	elif progress >= 1.0:
		$ProgressLabel.set_text('COMPLETE')
	else:
		$ProgressLabel.set_text('%s%%' % min(100, floor(progress*100)))

	$Progress.value = 100 - (progress * 100)
	
	$Text.set_text(raw_text % Utils.format_number(goal))


func _on_mouse_area(msg):
	if msg['node'] == $BarArea:
		match msg:
			{'mouse_over': var val, ..}:
				mouse_over = val
				set_value(value)