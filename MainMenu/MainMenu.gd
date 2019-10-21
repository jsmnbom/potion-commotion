extends Control

var has_game_opened = false

onready var buttons = [$ContinueButton, $NewButton, $HowToPlayButton, $OptionsButton]

func _ready():
	$ContinueButton/TextureRect.texture = Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48)
	$NewButton/TextureRect.texture = Utils.get_scaled_res('res://assets/resources/fire_flower.png', 48, 48)
	$HowToPlayButton/TextureRect.texture = Utils.get_scaled_res('res://assets/weeds.png', 64, 64)
	$OptionsButton/TextureRect.texture = Utils.get_scaled_res('res://assets/ui/sickle.png', 48, 48)

	_on_MainMenu_visibility_changed()
	
	$Options/Back.connect('gui_input', self, '_on_Options_Back_gui_input')
	$HowToPlay/Back.connect('gui_input', self, '_on_HowToPlay_Back_gui_input')

#func _on_Exit_pressed():
#	if has_game_opened:
#		Events.emit_signal('exit_confirm')
#	else:
#		get_tree().quit()


func _on_MainMenu_visibility_changed():
	if not visible:
		for button in buttons:
			button._on_Button_mouse_exited()
	if has_game_opened:
		$ContinueButton.disabled = false
	else:
		var save_file = File.new()
		if save_file.file_exists("user://savegame.save"):
			$ContinueButton.disabled = false
		else:
			$ContinueButton.disabled = true

func _on_HowToPlay_Back_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		$HowToPlay.hide()
		for button in buttons:
			button.show()

func _on_Options_Back_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		$Options.hide()
		for button in buttons:
			button.show()

func _on_HowToPlayButton_pressed():
	for button in buttons:
		button._on_Button_mouse_exited()
		button.hide()
	$HowToPlay.show()


func _on_OptionsButton_pressed():
	for button in buttons:
		button._on_Button_mouse_exited()
		button.hide()
	$Options.show()


func _on_ContinueButton_pressed():
	has_game_opened = true
	Events.emit_signal('continue_game')


func _on_NewButton_pressed():
	has_game_opened = true
	Events.emit_signal('new_game')
