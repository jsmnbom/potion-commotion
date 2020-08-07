extends 'res://UI/Popout.gd'

var gems: int = 0
var display_gems = 0.0
onready var gem_tween = $GemTween

func _init():
	clickable = false

func _ready():
	$Label.text = Utils.format_number(gems)

	Events.connect('gems_add', self, '_on_gems_add')

	if Debug.GEMS:
		Events.emit_signal('gems_add', {'amount': 100000000})

func _process(delta):
	$Label.text = Utils.format_number(gems+int(display_gems))

func add_gems(amount):
	gems += amount

	Events.emit_signal('gems_update', {'amount': gems})
	if amount > 0:
		Events.emit_signal('achievement', {'total_id': 'total_gems', 'total_add': amount})

	var time = 0.75
	$GemSFXTimer.wait_time = 0.05

	if abs(amount) <= 10:
		$GemSFXTimer.wait_time = 0.2
		time = 1.0/30
	elif abs(amount) <= 50:
		$GemSFXTimer.wait_time = 0.15
		time = 1.0/15
	elif abs(amount) <= 1000:
		$GemSFXTimer.wait_time = 0.1
		time = 1.0/4
	elif abs(amount) <= 10000:
		time = 1.0/2
		$GemSFXTimer.wait_time = 0.08
		
	$GemSFXTimer.start()

	gem_tween.stop_all()
	gem_tween.interpolate_property(self, 'display_gems',
			-float(amount)+display_gems, 0, time,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	gem_tween.start()

	popoutin()
	
	yield(get_tree().create_timer(max(time+0.1, 0.5)), "timeout")
	if display_gems == 0:
		$GemSFXTimer.stop()

func _on_gems_add(msg):
	match(msg):
		{'amount': var amount}:
			add_gems(amount)

func serialize():
	return gems

func deserialize(data):
	gems = data
	Events.emit_signal('gems_add', {'amount': 0})

func _on_GemSFXTimer_timeout():
	SFX.gem.play(self)
