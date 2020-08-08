extends Label


func _ready():
	Events.connect('now_playing', self, '_on_now_playing')
	modulate.a = 0.0

func _on_now_playing(msg):
	set_text('Now playing: %s' % msg.current_music)
	$Tween.interpolate_property(self, 'modulate:a',
		0.0, 1.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, 'modulate:a',
		1.0, 0.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT, 2)
	$Tween.start()
