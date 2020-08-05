extends 'res://UI/Popout.gd'

func _init():
	clickable = false
	speeds[0] = 0.3

func _ready():
	update_luck()
	
	$Timer.start()
	
	Events.connect('add_luck', self, '_on_add_luck')
	
func update_luck():
	print(Data.luck)
	$Icon.material.set_shader_param('luck', Data.luck)
	
func _on_Timer_timeout():
	Events.emit_signal('add_luck', (-0.2)/(6*20))

func _on_add_luck(luck):
	Data.luck = clamp(Data.luck + luck, 0.0, 1.0)
	update_luck()

func serialize():
	return Data.luck

func deserialize(data):
	Data.luck = data
	update_luck()
