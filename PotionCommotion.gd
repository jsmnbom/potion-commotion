extends Node2D

var Game = preload('res://Game/Game.tscn')
var game = null

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	Events.connect('new_game', self, '_on_new_game')
	Events.connect('continue_game', self, '_on_continue_game')
	Events.connect('exit_confirm', self, '_on_exit_confirm')
	Events.connect('exit_confirm_close', self, '_on_exit_confirm_close')

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
			if game and not game.ui_cancel():
					game.hide()
					$MouseHelper.hide()
					$MainMenu.show()

func _on_new_game():
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

func _on_continue_game():
	if game:
		game.show()
		$MouseHelper.show()
		$MainMenu.hide()
	else:
		var new_game = Game.instance()
		game = new_game
		add_child_below_node($MainMenu, new_game)

func _on_exit_confirm():
	$QuitDialog.show()
	$MouseHelper.show()
	
func _on_exit_confirm_close():
	$QuitDialog.hide()
	if not game or not game.visible:
		$MouseHelper.hide()