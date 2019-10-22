extends SceneTree

func _init():
	var output = []
	OS.execute('git', ['describe', '--tags'], true, output)
	var version_file = File.new()
	version_file.open("res://VERSION", File.WRITE)
	version_file.store_line(output[0].split('\n')[0])
	version_file.close()

	quit()