extends Node

class SingleSound extends Object:
	var parent: Node
	var stream: AudioStream
	var bus: String
	
	func _init(parent: Node, stream: AudioStream, bus: String = "SFX"):
		self.parent = parent
		self.stream = stream
		self.bus = bus

	func play(volume: float = 1.0, pitch_scale: float = 1.0):
		self._play(AudioStreamPlayer.new(), self.parent.get_tree().root, volume, pitch_scale)
	
	func play2d(parent: Node, volume: float = 1.0, pitch_scale: float = 1.0):
		self._play(AudioStreamPlayer2D.new(), parent, volume, pitch_scale)
		
	func _play(player, parent, volume, pitch_scale):
		player.stream = self.stream
		player.bus = self.bus
		player.volume_db = linear2db(volume)
		player.pitch_scale = pitch_scale
		self.call_deferred("_play_deferred", parent, player)
		
	func _play_deferred(parent, player):
		parent.add_child(player)
		player.play()
		player.connect("finished", player, "queue_free")

class MultiSound:
	var sounds
	var last_sound = 0.0
	var limit_msec
	
	func _init(parent: Node, streams, limit_msec: float = 100.0, bus: String = "SFX"):
		self.limit_msec = limit_msec
		self.sounds = []
		for stream in streams:
			self.sounds.append(SingleSound.new(parent, stream, bus))
	
	func _get_random_sound() -> SingleSound:
		return Utils.rng_choose(sounds)
	
	func play(volume: float = 1.0, pitch_scale: float = 1.0):
		if self.check_limit():
			self._get_random_sound().play(volume, pitch_scale)
	
	func play2d(parent: Node, volume: float = 1.0, pitch_scale: float = 1.0):
		if self.check_limit():
			self._get_random_sound().play2d(parent, volume, pitch_scale)
	
	func check_limit() -> bool:
		var now = OS.get_ticks_msec()
		if last_sound + limit_msec < now:
			last_sound = now
			return true
		return false

var hover: SingleSound
var press: SingleSound
var shovel_activate: SingleSound
var shovel_deactivate: SingleSound
var potion_fill: SingleSound
var freeze: SingleSound
var ignite: SingleSound
var potion_use: SingleSound
var hydration_potion_use: SingleSound
var luck_potion_use: SingleSound
var sunlight_potion_use: SingleSound
var midnight_potion_use: SingleSound
var error: SingleSound
var save_game: SingleSound

var shovel: MultiSound
var gem: MultiSound
var plant: MultiSound
var harvest: MultiSound
var splash: MultiSound
var page_flip: MultiSound

func _ready():
	hover = SingleSound.new(self, preload("res://assets/audio/sfx/hover.wav"))
	press = SingleSound.new(self, preload("res://assets/audio/sfx/press.wav"), "SFX_lowpass")
	shovel_activate = SingleSound.new(self, preload("res://assets/audio/sfx/shovel_activate.wav"))
	shovel_deactivate = SingleSound.new(self, preload("res://assets/audio/sfx/shovel_deactivate.wav"))
	potion_fill = SingleSound.new(self, preload("res://assets/audio/sfx/potion_fill.wav"))
	potion_use = SingleSound.new(self, preload("res://assets/audio/sfx/potion_use.wav"))
	freeze = SingleSound.new(self, preload("res://assets/audio/sfx/freeze.wav"))
	ignite = SingleSound.new(self, preload("res://assets/audio/sfx/ignite.wav"))
	hydration_potion_use = SingleSound.new(self, preload("res://assets/audio/sfx/hydration_potion_use.wav"))
	luck_potion_use = SingleSound.new(self, preload("res://assets/audio/sfx/luck_potion_use.wav"))
	sunlight_potion_use = SingleSound.new(self, preload("res://assets/audio/sfx/sunlight_potion_use.wav"))
	midnight_potion_use = SingleSound.new(self, preload("res://assets/audio/sfx/midnight_potion_use.wav"))
	error = SingleSound.new(self, preload("res://assets/audio/sfx/error.wav"))
	save_game = SingleSound.new(self, preload("res://assets/audio/sfx/save_game.wav"))
	
	shovel = MultiSound.new(self, [
		preload("res://assets/audio/sfx/shovel0.wav"),
		preload("res://assets/audio/sfx/shovel1.wav"),
		preload("res://assets/audio/sfx/shovel2.wav"),
		preload("res://assets/audio/sfx/shovel3.wav")
	])
	
	gem = MultiSound.new(self, [
		preload("res://assets/audio/sfx/gem0.wav"),
		preload("res://assets/audio/sfx/gem1.wav"),
		preload("res://assets/audio/sfx/gem2.wav"),
		preload("res://assets/audio/sfx/gem3.wav"),
		preload("res://assets/audio/sfx/gem4.wav"),
		preload("res://assets/audio/sfx/gem5.wav")
	], 0)
	
	plant = MultiSound.new(self, [
		preload("res://assets/audio/sfx/plant0.wav"),
		preload("res://assets/audio/sfx/plant1.wav"),
		preload("res://assets/audio/sfx/plant2.wav"),
		preload("res://assets/audio/sfx/plant3.wav")
	])
	
	harvest = MultiSound.new(self, [
		preload("res://assets/audio/sfx/harvest0.wav"),
		preload("res://assets/audio/sfx/harvest1.wav"),
		preload("res://assets/audio/sfx/harvest2.wav"),
		preload("res://assets/audio/sfx/harvest3.wav"),
		preload("res://assets/audio/sfx/harvest4.wav")
	])
	
	splash = MultiSound.new(self, [
		preload("res://assets/audio/sfx/splash0.wav"),
		preload("res://assets/audio/sfx/splash1.wav"),
		preload("res://assets/audio/sfx/splash2.wav"),
		preload("res://assets/audio/sfx/splash3.wav"),
	])
	
	page_flip = MultiSound.new(self, [
		preload("res://assets/audio/sfx/page_flip0.wav"),
		preload("res://assets/audio/sfx/page_flip1.wav"),
	])
	
