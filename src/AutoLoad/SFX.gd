extends Node

class SingleSound:
	var volume: float
	var stream: AudioStream
	var bus: String
	
	func _init(volume: float, stream: AudioStream):
		self.volume = volume
		self.stream = stream
		self.bus = bus

	func play(parent: Node):
		self._play(AudioStreamPlayer.new(), parent)
	
	func play2d(parent: Node):
		var player = AudioStreamPlayer2D.new()
		player.attenuation = 0.7
		player.max_distance = INF
		self._play(player, parent)
		
	func _play(player, parent):
		player.stream = self.stream
		player.bus = self._get_bus(parent)
		player.volume_db = linear2db(self.volume)
		self.call_deferred("_play_deferred", parent, player)
	
	func _get_bus(parent) -> String:
		var path = parent.get_path()
		for i in range(path.get_name_count()):
			var name = path.get_name(i)
			if name == "Greenhouse":
				return "GreenhouseSFX"
			elif name == "Basement":
				return "BasementSFX"
		return "SFX"
	
	func _play_deferred(parent, player):
		parent.add_child(player)
		player.play()
		player.connect("finished", player, "queue_free")

class MultiSound:
	var sounds
	var last_sound = 0.0
	var limit_msec
	
	func _init(volume: float, streams, limit_msec: float = 100.0):
		self.limit_msec = limit_msec
		self.sounds = []
		for stream in streams:
			self.sounds.append(SingleSound.new(volume, stream))
	
	func _get_random_sound() -> SingleSound:
		return Utils.rng_choose(sounds)
	
	func play(parent: Node):
		if self.check_limit():
			self._get_random_sound().play(parent)
	
	func play2d(parent: Node):
		if self.check_limit():
			self._get_random_sound().play2d(parent)
	
	func check_limit() -> bool:
		var now = OS.get_ticks_msec()
		if last_sound + limit_msec < now:
			last_sound = now
			return true
		return false

var hover: SingleSound
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
var bird_wings: SingleSound
var bird_call: SingleSound
var footsteps: SingleSound

var shovel: MultiSound
var gem: MultiSound
var plant: MultiSound
var harvest: MultiSound
var splash: MultiSound
var page_flip: MultiSound
var pop: MultiSound
var footstep: MultiSound

func _ready():
	hover = SingleSound.new(0.2, preload("res://assets/audio/sfx/hover.wav"))
	shovel_activate = SingleSound.new(1.0, preload("res://assets/audio/sfx/shovel_activate.wav"))
	shovel_deactivate = SingleSound.new(1.0, preload("res://assets/audio/sfx/shovel_deactivate.wav"))
	potion_fill = SingleSound.new(0.8, preload("res://assets/audio/sfx/potion_fill.wav"))
	potion_use = SingleSound.new(1.0, preload("res://assets/audio/sfx/potion_use.wav"))
	freeze = SingleSound.new(1.0, preload("res://assets/audio/sfx/freeze.wav"))
	ignite = SingleSound.new(1.0, preload("res://assets/audio/sfx/ignite.wav"))
	hydration_potion_use = SingleSound.new(1.0, preload("res://assets/audio/sfx/hydration_potion_use.wav"))
	luck_potion_use = SingleSound.new(1.0, preload("res://assets/audio/sfx/luck_potion_use.wav"))
	sunlight_potion_use = SingleSound.new(1.0, preload("res://assets/audio/sfx/sunlight_potion_use.wav"))
	midnight_potion_use = SingleSound.new(1.0, preload("res://assets/audio/sfx/midnight_potion_use.wav"))
	error = SingleSound.new(0.2, preload("res://assets/audio/sfx/error.wav"))
	save_game = SingleSound.new(0.6, preload("res://assets/audio/sfx/save_game.wav"))
	bird_wings = SingleSound.new(0.7, preload("res://assets/audio/sfx/bird_wings.wav"))
	bird_call = SingleSound.new(0.7, preload("res://assets/audio/sfx/bird_call.wav"))
	footsteps = SingleSound.new(1.5, preload("res://assets/audio/sfx/footsteps.wav"))
	
	shovel = MultiSound.new(1.0, [
		preload("res://assets/audio/sfx/shovel0.wav"),
		preload("res://assets/audio/sfx/shovel1.wav"),
		preload("res://assets/audio/sfx/shovel2.wav"),
		preload("res://assets/audio/sfx/shovel3.wav")
	])
	
	gem = MultiSound.new(0.8, [
		preload("res://assets/audio/sfx/gem0.wav"),
		preload("res://assets/audio/sfx/gem1.wav"),
		preload("res://assets/audio/sfx/gem2.wav"),
		preload("res://assets/audio/sfx/gem3.wav"),
		preload("res://assets/audio/sfx/gem4.wav"),
		preload("res://assets/audio/sfx/gem5.wav")
	], 0)
	
	plant = MultiSound.new(1.3, [
		preload("res://assets/audio/sfx/plant0.wav"),
		preload("res://assets/audio/sfx/plant1.wav"),
		preload("res://assets/audio/sfx/plant2.wav"),
		preload("res://assets/audio/sfx/plant3.wav")
	], 50)
	
	harvest = MultiSound.new(0.7, [
		preload("res://assets/audio/sfx/harvest0.wav"),
		preload("res://assets/audio/sfx/harvest1.wav"),
		preload("res://assets/audio/sfx/harvest2.wav"),
		preload("res://assets/audio/sfx/harvest3.wav"),
		preload("res://assets/audio/sfx/harvest4.wav")
	], 50)
	
	splash = MultiSound.new(1.5, [
		preload("res://assets/audio/sfx/splash0.wav"),
		preload("res://assets/audio/sfx/splash1.wav"),
		preload("res://assets/audio/sfx/splash2.wav"),
		preload("res://assets/audio/sfx/splash3.wav")
	], 0)
	
	page_flip = MultiSound.new(1.3, [
		preload("res://assets/audio/sfx/page_flip0.wav"),
		preload("res://assets/audio/sfx/page_flip1.wav")
	])
	
	pop = MultiSound.new(1.0, [
		preload("res://assets/audio/sfx/pop0.wav"),
		preload("res://assets/audio/sfx/pop1.wav"),
		preload("res://assets/audio/sfx/pop2.wav")
	])
	
	footstep = MultiSound.new(0.5, [
		preload("res://assets/audio/sfx/footstep0.wav"),
		preload("res://assets/audio/sfx/footstep1.wav"),
		preload("res://assets/audio/sfx/footstep2.wav")
	])
	
