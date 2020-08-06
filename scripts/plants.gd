extends SceneTree

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
    var plants = get_plants()
    for plant in plants:
        #print(plant)
        var original_img = get_scaled_img('res://assets/plants/originals/%s.png' % plant, 320, 128)
        var original_rect = Rect2(Vector2(0,0), original_img.get_size())

        var atlas_img = Image.new()
        atlas_img.create(original_rect.size.x, original_rect.size.y*2, false, Image.FORMAT_RGBA8)

        atlas_img.blit_rect(original_img, original_rect, Vector2(0,0))
        atlas_img.blit_rect(original_img, original_rect, Vector2(0,original_rect.size.y))

        atlas_img.lock()

        var bitmap = BitMap.new()
        bitmap.create_from_image_alpha(original_img, 0.5)
        bitmap.grow_mask(1, original_rect)
        var bitmap2 = BitMap.new()
        bitmap2.create_from_image_alpha(original_img, 0.5)
        for x in range(320):
            for y in range(128):
                if bitmap.get_bit(Vector2(x, y)) and not bitmap2.get_bit(Vector2(x, y)):
                    atlas_img.set_pixel(x, y + original_rect.size.y, Color(1,1,1))

        atlas_img.unlock()
        atlas_img.save_png('res://assets/plants/%s.png' % plant)
    quit()
    
    