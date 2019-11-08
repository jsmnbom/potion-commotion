extends Node2D

var Game = preload('res://Game/Game.tscn')
var game = null
var continue_game_wait = 0
var new_game_wait = 0
var has_game_opened = false
var last_screenshot_time = null
var screenshot_index = 1

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	Events.connect('start_new_game', self, '_on_start_new_game')
	Events.connect('continue_game', self, '_on_continue_game')
	Events.connect('exit_confirm', self, '_on_exit_confirm')
	Events.connect('exit_confirm_close', self, '_on_exit_confirm_close')
	Events.connect('show_main_menu', self, '_on_show_main_menu')
	Events.connect('loaded', self, '_on_loaded')

	OS.set_window_title('Potion Commotion: Heart Edition %s' % Data.version)

func _process(delta):
	if new_game_wait != 0:
		new_game_wait -= 1
		if new_game_wait == 0:
			Data.clear()
			has_game_opened = true
			var new_game = Game.instance()
			if not game:
				game = new_game
				add_child_below_node($MainMenu, new_game)
			else:
				game.queue_free()
				game = new_game
				add_child_below_node($MainMenu, new_game)
			Events.emit_signal('loaded')
	elif continue_game_wait != 0:
		continue_game_wait -= 1
		if continue_game_wait == 0:
			has_game_opened = true
			if game:
				game.show()
				$MouseHelper.show()
				$MainMenu.hide()
			else:
				var new_game = Game.instance()
				game = new_game
				add_child_below_node($MainMenu, new_game)
				Events.emit_signal('load_game')

func _on_loaded():
	$MouseHelper.show()
	$MainMenu.hide()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if has_game_opened:
			Events.emit_signal('exit_confirm')
		else:
			get_tree().quit()

func _input(event):
	if event.is_action_pressed('ui_cancel'):
		if $QuitDialog.visible:
			$QuitDialog.hide()
			if not game or not game.visible:
				$MouseHelper.hide()
		else:
			if $MainMenu.visible:
				$MainMenu.ui_cancel()
			elif game:
				if not game.ui_cancel():
					game.hide()
					$MouseHelper.hide()
					$MainMenu.show()
	elif event.is_action_pressed('ui_screenshot'):
		screenshot()
		
func screenshot():
	var time = OS.get_datetime()
	var time_str = "%s_%02d_%02d_%02d%02d%02d" % [time['year'], time['month'], time['day'], 
										time['hour'], time['minute'], time['second']]
	if time_str == last_screenshot_time:
		screenshot_index += 1
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")		
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var dir = Directory.new()
	dir.open('user://')
	dir.make_dir('screenshots')
	img.save_png('user://screenshots/%s_%s.png' % [time_str, screenshot_index])
	last_screenshot_time = time_str

func _on_show_main_menu():
	$MainMenu.stop_loading()
	game.hide()
	$MouseHelper.hide()
	$MainMenu.show()

func _on_start_new_game():
	$MainMenu.start_loading()
	new_game_wait = 2

func _on_continue_game():
	$MainMenu.start_loading()
	continue_game_wait = 2

func _on_exit_confirm():
	yield(get_tree(), "idle_frame")
	$QuitDialog.show()
	$MouseHelper.show()
	
func _on_exit_confirm_close():
	$QuitDialog.hide()
	if not game or not game.visible:
		$MouseHelper.hide()