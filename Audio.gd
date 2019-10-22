extends Node2D

const MASTER = 0
const MUSIC = 1
const SFX = 2
const AMBIANCE = 3

var music = [
	preload('res://assets/audio/music_main.ogg')
]

func _ready():
	$Music.stream = music[0]
	$Music.play(0.0)
	$Music.connect('finished', self, '_on_music_finished')
	
func _on_music_finished():
	$Music.play(0.0)

func set_volume(bus, volume):
	AudioServer.set_bus_volume_db(bus, linear2db(volume/100))