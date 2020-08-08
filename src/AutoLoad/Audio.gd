extends Node2D

enum Bus {
	Master = 0
	Music = 1
	SFX = 2
	Ambience = 3
	GreenhouseSFX = 4
	BasementSFX = 5
}

var music = {
	'Midnight in the Garden': preload('res://assets/audio/music/midnight_in_the_garden.ogg'),
	'Arden Silvera': preload('res://assets/audio/music/arden_silvera.ogg'),
	'Crystal Stalk': preload('res://assets/audio/music/crystal_stalk.ogg')
}

var current_music = random_music()

func _ready():
	$Music.connect('finished', self, '_on_music_finished')
	play_music()
	call_deferred('emit_now_playing')
	
	$DayTimer.wait_time = float(Data.day_duration) / (24.0*60)
	$DayTimer.start()
	_on_DayTimer_timeout()

func set_ambience(day, night):
	if day > 0.0:
		if not $AmbienceDay.playing:
			$AmbienceDay.playing = true
		$AmbienceDay.volume_db = linear2db(day)
	elif $AmbienceDay.playing:
		$AmbienceDay.playing = false
	if night > 0.0:
		if not $AmbienceNight.playing:
			$AmbienceNight.playing = true
		$AmbienceNight.volume_db = linear2db(night)
	elif $AmbienceNight.playing:
		$AmbienceNight.playing = false

func set_rain(is_raining):
	if is_raining:
		set_rain_vol(0)
		$AmbienceRainTween.interpolate_method(self, "set_rain_vol", 0.0, 1.0, 1, Tween.TRANS_CIRC, Tween.EASE_IN)
		$AmbienceRainTween.start()
		$AmbienceRain.playing = true
	else:
		$AmbienceRainTween.interpolate_method(self, "set_rain_vol", db2linear($AmbienceRain.volume_db), 0.0, 2, Tween.TRANS_CIRC, Tween.EASE_OUT)
		$AmbienceRainTween.interpolate_callback($AmbienceRain, 2, "stop")
		$AmbienceRainTween.start()

func set_rain_vol(vol):
	$AmbienceRain.volume_db = linear2db(vol)

func set_current(greenhouse):
	if greenhouse:
		AudioServer.set_bus_effect_enabled(Bus.GreenhouseSFX, 0, false)
		AudioServer.set_bus_effect_enabled(Bus.BasementSFX, 0, true)
		AudioServer.set_bus_effect_enabled(Bus.GreenhouseSFX, 1, false)
		AudioServer.set_bus_effect_enabled(Bus.BasementSFX, 1, true)
	else:
		AudioServer.set_bus_effect_enabled(Bus.GreenhouseSFX, 0, true)
		AudioServer.set_bus_effect_enabled(Bus.BasementSFX, 0, false)
		AudioServer.set_bus_effect_enabled(Bus.GreenhouseSFX, 1, true)
		AudioServer.set_bus_effect_enabled(Bus.BasementSFX, 1, false)

func _on_DayTimer_timeout():
	var t = 0.0
	
	if Data.time > 21*60 or Data.time < 6*60:
		set_ambience(0, 1)
	elif (Data.time < 9*60):
		t = range_lerp(float(Data.time), 6*60, 9*60, 0.0, 1.0)
		set_ambience(t, 1.0-t)
	elif (Data.time < 18*60):
		set_ambience(1, 0)
	elif (Data.time <= 21*60):
		t = range_lerp(float(Data.time), 18*60, 21*60, 1.0, 0.0)
		set_ambience(t, 1.0-t)

func random_music():
	return music.keys()[Utils.rng.randi() % music.size()]

func play_music():
	$Music.stream = music[current_music]
	$Music.play(0.0)

	if AudioServer.get_bus_volume_db(Bus.Master) != -INF and AudioServer.get_bus_volume_db(Bus.Music) != -INF:
		emit_now_playing()

func _on_music_finished():
	var new_song = random_music()
	while new_song == current_music:
		new_song = random_music()
	current_music = new_song
	play_music()

func set_volume(bus, volume):
	if (bus == Bus.Master or bus == Bus.Music):
		if AudioServer.get_bus_volume_db(bus) == -INF and volume > 0:
			emit_now_playing()
			$Music.stream_paused = false
		elif volume == 0:
			$Music.stream_paused = true
	AudioServer.set_bus_volume_db(bus, linear2db(volume/100))

func emit_now_playing():
	Events.emit_signal('now_playing', {'current_music': current_music})
