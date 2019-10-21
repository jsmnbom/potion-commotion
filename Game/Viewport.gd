extends Viewport

# Fix input events through viewports
func _input(event):
	unhandled_input(event)
