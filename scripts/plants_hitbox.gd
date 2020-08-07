extends SceneTree

var GROW_PIXELS = 10

func get_scaled_img(res_path, height, width):
	var img = ResourceLoader.load(res_path)
	if img is ImageTexture or img is StreamTexture:
		img = img.get_data()
	img.resize(height, width, 0)
	return img

func get_plants():
	var plant_files = []
	var dir = Directory.new()
	if dir.open('res://assets/plants/originals') == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if not file_name.ends_with('.import') and not file_name.ends_with('~') and file_name.ends_with('.png'):
					file_name = file_name.trim_suffix('.png')
					plant_files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
		return
	return plant_files


func _init():
	var hitboxes = {}
	var plants = get_plants()
	for plant in plants:
		hitboxes[plant] = []

		var atlas_img = get_scaled_img('res://assets/plants/originals/%s.png' % plant, 640, 256)
		var atlas_rect = Rect2(0, 0, 640, 256)

		var bitmap = BitMap.new()
		bitmap.create_from_image_alpha(atlas_img, 0.5)
		bitmap.grow_mask(GROW_PIXELS, atlas_rect)
		
		hitboxes[plant]= [[], []]

		for i in range(5):
			var rect = Rect2(Vector2(i*128, 0), Vector2(128, 256))
			var polygons = bitmap.opaque_to_polygons(rect, 2)
			var small_polygons = []
			for poly in polygons:
				var small_poly = PoolVector2Array()
				for point in poly:
					small_poly.append(point * 0.75)
				small_polygons.append(small_poly)
			hitboxes[plant][0].append(polygons)
			hitboxes[plant][1].append(small_polygons)

	var file = File.new()
	file.open("res://assets/plants/hitboxes.bin", File.WRITE)
	file.store_var(hitboxes)
	file.close()
	quit()
