extends Control

var ingredient_offset_size = 90
var paused = false

var journal
var ingredient_areas = {}

func _ready():
	Utils.register_mouse_area(self, $PauseArea)

func get_ingredient_pos(i):
	var center = $Preview.position
	var theta = (TAU / 5) * i + (float(journal.animation_timer)/240)*TAU
	var offset = Vector2(sin(theta), cos(theta)) * ingredient_offset_size
	return center + offset

func reposition_ingredients():
	var children = $Ingredients.get_children()
	for i in children.size():
		var sprite = children[i]
		sprite.position = get_ingredient_pos(i)

func _physics_process(delta):
	if visible:
		reposition_ingredients()
	
func init(title, description, res, ingredients, journal):
	self.journal = journal
	if title.begins_with('the '):
		$PotionOf.text = 'Potion of the'
		$Title.text = title.trim_prefix('the ')
	else:
		$Title.text = title
	$Description.text = description
	$Preview.texture = Utils.get_scaled_res(res, 96, 96)
	
	for ingredient in ingredients:
		var item = Data.inventory_by_id['resource'][ingredient]
		var sprite = Sprite.new()
		sprite.texture = item.get_scaled_res(48, 48)
		sprite.position = get_ingredient_pos($Ingredients.get_children().size())
		
		var area = Area2D.new()
		area.monitorable = false
		area.monitoring = false
		area.input_pickable = false
		area.collision_layer = Utils.collision_layer(14)
		var shape = RectangleShape2D.new()
		shape.extents = Vector2(24,24)
		area.shape_owner_add_shape(area.create_shape_owner(sprite), shape)
		ingredient_areas[area] = [item.name, item.id]
		Utils.register_mouse_area(self, area)
		sprite.add_child(area)
		
		$Ingredients.add_child(sprite)

func _on_Potion_visibility_changed():
	if visible:
		reposition_ingredients()
	$PauseArea.visible = visible
	for area in ingredient_areas.keys():
		area.visible = visible

func _mouse_area(area, msg):
	if area == $PauseArea:
		match msg:
			{'mouse_over': false, ..}:
				journal.animation_timer_paused = false
			{'mouse_over': true, 'button_left_click': var left, ..}:
				journal.animation_timer_paused = true
	elif area in ingredient_areas:
		match msg:
			{'mouse_over': false, ..}:
				journal.animation_timer_paused = false
				Utils.set_cursor_hand(false)
				Events.emit_signal('tooltip', {'hide': true})
			{'mouse_over': true, 'button_left_click': var left, ..}:
				journal.animation_timer_paused = true
				var names = ingredient_areas[area]
				if names[1] in Data.unlocked_journal_pages:
					Utils.set_cursor_hand(true)
					Events.emit_signal('tooltip', {'title': names[0], 'description': 'Click to show page.'})
					if left:
						Events.emit_signal('show_journal_page', {'id': names[1]})
						Utils.set_cursor_hand(false)
				else:
					Events.emit_signal('tooltip', {'title': names[0]})
