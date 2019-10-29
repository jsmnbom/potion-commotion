extends Node2D

const MASTER = 0
const MUSIC = 1
const SFX = 2
const AMBIANCE = 3

var music = {
	'Midnight in the Garden': preload('res://assets/audio/music/midnight_in_the_garden.ogg'),
	# 'Arden Silvera': preload('res://assets/audio/music/arden_silvera.ogg')
	# 'Crystal Stalk': preload('res://assets/audio/music/crystal_stalk.ogg')
}

func _ready():
	$Music.stream = music[0]
	$Music.play(0.0)
	$Music.connect('finished', self, '_on_music_finished')
	
func _on_music_finished():
	$Music.play(0.0)

func set_volume(bus, volume):
	AudioServer.set_bus_volume_db(bus, linear2db(volume/100))