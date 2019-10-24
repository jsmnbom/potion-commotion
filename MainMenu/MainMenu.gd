extends Control

var has_game_opened = false

onready var buttons = [$ContinueButton, $NewButton, $HowToPlayButton, $OptionsButton]
onready var eye = $CrystalStalkEye
onready var eye_middle = $CrystalStalkEye.position


func _ready():
	$ContinueButton/TextureRect.texture = Utils.get_scaled_res('res://assets/potions/hydration.png', 48, 48)
	$NewButton/TextureRect.texture = Utils.get_scaled_res('res://assets/resources/fire_flower.png', 48, 48)
	$HowToPlayButton/TextureRect.texture = Utils.get_scaled_res('res://assets/weeds.png', 64, 64)
	$OptionsButton/TextureRect.texture = Utils.get_scaled_res('res://assets/ui/sickle.png', 48, 48)
	
	$ExitButton.texture_normal =  Utils.get_scaled_res('res://assets/ui/exit.png', 64, 64)
	$ExitButton.texture_hover = Utils.get_scaled_res('res://assets/ui/exit_hover.png', 64, 64)

	_on_MainMenu_visibility_changed()
	
	$Options/Back.connect('gui_input', self, '_on_Options_Back_gui_input')
	$HowToPlay/Back.connect('gui_input', self, '_on_HowToPlay_Back_gui_input')
	$NameEntry/Cancel.connect('gui_input', self, '_on_NameEntry_Cancel_gui_input')
	Events.connect('menu_new_game', self, '_on_menu_new_game')

	$VersionLabel.text = Data.version

func _physics_process(delta):
	if visible:
		var mouse_pos = get_viewport().get_mouse_position()
		eye.position = eye_middle + (mouse_pos - eye_middle).clamped(7)

func hide_buttons():
	for button in buttons:
		button._on_Button_mouse_exited()
		button.hide()

func show_buttons():
	for button in buttons:
		button.show()

func ui_cancel():
	for node in [$HowToPlay, $Options, $NameEntry]:
		if node.visible:
			node.hide()
			show_buttons()
			return true
	return false

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
		show_buttons()

func _on_Options_Back_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		$Options.hide()
		show_buttons()

func _on_HowToPlayButton_pressed():
	hide_buttons()
	$HowToPlay.show()

func _on_OptionsButton_pressed():
	hide_buttons()
	$Options.show()

func _on_ContinueButton_pressed():
	has_game_opened = true
	Events.emit_signal('continue_game')

func _on_NewButton_pressed():
	hide_buttons()
	$NameEntry.show()

func _on_NameEntry_Cancel_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		$NameEntry.hide()
		show_buttons()
	
func _on_menu_new_game():
	$NameEntry.hide()
	show_buttons()
	has_game_opened = true
	Events.emit_signal('start_new_game')

func _on_ExitButton_pressed():
	if has_game_opened:
		Events.emit_signal('exit_confirm')
	else:
		get_tree().quit()

func start_loading():
	hide_buttons()
	$Loading.show()

func stop_loading():
	$Loading.hide()
	show_buttons()
	
