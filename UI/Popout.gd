extends Control

onready var position_tween = $PositionTween

var icon_res = ''
var speeds = [0.4, 0.2, 0.5]
var clickable = true

func _ready():
	$Icon.texture = Utils.get_scaled_res(icon_res, 48, 48)

	Events.connect('mouse_area', self, '_on_mouse_area')

func popoutin():
	position_tween.stop_all()
	position_tween.interpolate_property(self, 'rect_position:x',
		self.rect_position.x, 64, speeds[1],
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	position_tween.interpolate_property(self, 'rect_position:x',
		64, -(self.rect_size.x-128), speeds[2],
		Tween.TRANS_LINEAR, Tween.EASE_IN, 1.2)
	position_tween.start()

func popout():
	position_tween.interpolate_property(self, 'rect_position:x',
		self.rect_position.x, 64, speeds[0],
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	position_tween.start()

func popin():
	position_tween.interpolate_property(self, 'rect_position:x',
		self.rect_position.x, -(self.rect_size.x-128), speeds[0],
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	position_tween.start()

func _on_mouse_area(msg):
	if msg['node'] == $Area:
		match msg:
			{'mouse_over': false, ..}:
				popin()
				if clickable:
					Utils.set_cursor_hand(false)
			{'mouse_over': true, 'button_left_click': var left, ..}:
				if clickable:
					Utils.set_cursor_hand(true)
				if left:
					_on_click()
				if not left:
					popout()
				
func _on_click():
	pass