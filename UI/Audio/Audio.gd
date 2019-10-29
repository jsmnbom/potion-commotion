extends Node2D

const MASTER = 0
const MUSIC = 1
const SFX = 2
const AMBIANCE = 3

var current_song = 'Midnight in the Garden'

var music = {
	'Midnight in the Garden': preload('res://assets/audio/music/midnight_in_the_garden.ogg'),
	'Arden Silvera': preload('res://assets/audio/music/arden_silvera.ogg'),
	'Crystal Stalk': preload('res://assets/audio/music/crystal_stalk.ogg')
}

func _ready():
	$Music.connect('finished', self, '_on_music_finished')
	$MusicNowPlayingLabel.modulate.a = 0
	play_music()

func random_music():
	return music.keys()[Utils.rng.randi() % music.size()]

func play_music():
	$Music.stream = music[current_song]
	$Music.play(0.0)

	if AudioServer.get_bus_volume_db(MASTER) != -INF and AudioServer.get_bus_volume_db(MUSIC) != -INF:
		show_music_now_playing_label()

func show_music_now_playing_label():
	var label = $MusicNowPlayingLabel
	label.set_text('Now playing: %s' % current_song)
	$Tween.interpolate_property(label, 'modulate:a',
		0.0, 1.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(label, 'modulate:a',
		1.0, 0.0, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_OUT, 2)
	$Tween.start()

func _on_music_finished():
	var new_song = random_music()
	while new_song == current_song:
		new_song = random_music()
	current_song = new_song
	play_music()

func set_volume(bus, volume):
	if (bus == MASTER or bus == MUSIC):
		if AudioServer.get_bus_volume_db(bus) == -INF and volume > 0:
			show_music_now_playing_label()
			$Music.stream_paused = false
		elif volume == 0:
			$Music.stream_paused = true
	AudioServer.set_bus_volume_db(bus, linear2db(volume/100))