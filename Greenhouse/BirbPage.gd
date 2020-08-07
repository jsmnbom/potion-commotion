extends Node2D

var JOURNAL_POS = Vector2(48, 432)
var page_id
var destination = Vector2(1355/2, 1016/2)

func _ready():
	$PageSprite.texture = Utils.get_scaled_res('res://assets/journal_items/page.png', 128, 128)
	
	Utils.register_mouse_area(self, $Area)

func init(_page_id):
	page_id = _page_id
	if ResourceLoader.exists('res://assets/journal_items/%s.png' % page_id):
		$ItemSprite.texture = Utils.get_scaled_res('res://assets/journal_items/%s.png' % page_id, 128, 128)
	else:
		$ItemSprite.texture = Utils.get_scaled_res('res://assets/journal_items/text.png', 128, 128)

func _mouse_area(area, msg):
	if area == $Area:
		match msg:
			{'mouse_over': var mouse_over, 'button_left_click': var left, ..}:
				Utils.set_cursor_hand(mouse_over)
				if left:
					$Area.hide()
					z_index = 17
					$Tween.interpolate_property(self, 'position', position, JOURNAL_POS, 1,  Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					$Tween.interpolate_property(self, 'scale', scale, Vector2(0.25, 0.25), 1,  Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
					$Tween.interpolate_callback(self, 1, 'done')
					$Tween.start()

					Events.emit_signal('unlock_journal')
					SFX.page_flip.play(self)

func done():
	Events.emit_signal('unlock_journal_page', {'id': page_id})
	Utils.unregister_mouse_area($Area)
	queue_free()
