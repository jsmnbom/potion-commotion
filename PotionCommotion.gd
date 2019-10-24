extends Node2D

var Game = preload('res://Game/Game.tscn')
var game = null
var continue_game_wait = 0
var new_game_wait = 0

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	Events.connect('start_new_game', self, '_on_start_new_game')
	Events.connect('continue_game', self, '_on_continue_game')
	Events.connect('exit_confirm', self, '_on_exit_confirm')
	Events.connect('exit_confirm_close', self, '_on_exit_confirm_close')
	Events.connect('show_main_menu', self, '_on_show_main_menu')
	Events.connect('loaded', self, '_on_loaded')

	OS.set_window_title('Potion Commotion %s' % Data.version)

func _physics_process(delta):
	if new_game_wait != 0:
		new_game_wait -= 1
		if new_game_wait == 0:
			Data.clear()
			$MouseHelper.show()
			$MainMenu.hide()
			var new_game = Game.instance()
			if not game:
				game = new_game
				add_child_below_node($MainMenu, new_game)
			else:
				game.queue_free()
				game = new_game
				add_child_below_node($MainMenu, new_game)
	elif continue_game_wait != 0:
		continue_game_wait -= 1
		if continue_game_wait == 0:
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
		$QuitDialog.show()
		$MouseHelper.show()

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
	$QuitDialog.show()
	$MouseHelper.show()
	
func _on_exit_confirm_close():
	$QuitDialog.hide()
	if not game or not game.visible:
		$MouseHelper.hide()