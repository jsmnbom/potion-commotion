extends Control

var IndexItem = preload('res://UI/Journal/IndexItem.tscn')
var IndexTitle = preload('res://UI/Journal/IndexTitle.tscn')
var PagePlant = preload('res://UI/Journal/PagePlant.tscn')
var PotionPage = preload('res://UI/Journal/PotionPage.tscn')

var index_per_page = 14
onready var index_items = [$Pages/Index/Items1, $Pages/Index/Items2]

onready var PAGES = {
	'index': ['Index', $Pages/Index],
	'AStrangeGarden': ['A Strange Garden', $Pages/AStrangeGarden],
	'TheApprenticeship': ['The Apprenticeship', $Pages/TheApprenticeship],
	'TheCauldron1': ['The Cauldron #1', $Pages/TheCauldron1],
	'TheCauldron2': ['The Cauldron #2', $Pages/TheCauldron2],
	'TheCauldron3': ['The Cauldron #3', $Pages/TheCauldron3]
}

var viewed_pages = ['index']

var index_areas = []

var current_page = 'index'

var animation_timer = 0
var animation_timer_paused = false

func _physics_process(delta):
	if not animation_timer_paused:
		animation_timer = (animation_timer + 1) % 240

func add_page(key, title, page):
	$Pages.add_child(page)
	page.hide()
	PAGES[key] = [title, page]

func _ready():
	Events.connect('show_journal', self, '_on_show_journal')
	Events.connect('unlock_journal_page', self, '_on_unlock_journal_page')
	Events.connect('show_journal_page', self, '_on_show_journal_page')
	Events.connect('loaded', self, '_on_loaded')

	Utils.register_mouse_area(self, $Area)
	Utils.register_mouse_area(self, $CloseArea)
	Utils.register_mouse_area(self, $Return/Area)
	Utils.register_mouse_area(self, $Forward/Area)
	Utils.register_mouse_area(self, $Back/Area)
	
	for page in PAGES:
		PAGES[page][1].hide()
	
	var potions = {}
	for item in Data.inventory:
		if item is Data._InventoryPotion:
			potions[item.id] = item
	
	for plant_id in Data.plants:
		var plant = Data.plants[plant_id]
		var page = PagePlant.instance()
		page.set_meta('page_type', 'plant')
		page.name = plant_id
		var text = plant.description + '\n\n'
		var used_in = []
		for potion in potions:
			var potion_item = potions[potion]
			if plant_id in potion_item.ingredients:
				used_in.append(potion)
				continue
		var seed_res_path = Data.inventory_by_id['seed'][plant_id].res_path
		var resource_res_path = Data.inventory_by_id['resource'][plant_id].res_path
		
		page.init(plant.name, text, plant.res_path, seed_res_path, resource_res_path, used_in, plant.collision_polygons_small)
		add_page(plant_id, plant.name, page)
		
	for potion in potions:
		var potion_item = potions[potion]
		var page = PotionPage.instance()
		page.set_meta('page_type', 'potion')
		page.name = potion_item.id
		var text = potion_item.long_description.dedent().lstrip('\n').rstrip('\n') + '\n\n'
		page.init(potion_item.short_name, text, potion_item.res_path, potion_item.ingredients, self)
		add_page(potion_item.id, potion_item.name, page)

	if Debug.JOURNAL:
		for page in PAGES:
			if not page in Data.unlocked_journal_pages:
				if not page in ['AStrangeGarden', 'TheApprenticeship']:
					Events.emit_signal('unlock_journal_page', {'id': page})
	
	update_index()
	show_page(current_page)
	_on_show_journal(false)

func _on_loaded():
	if Data.player_name.ends_with('s'):
		$Pages/Index/Title.text = '%s\' Journal' % Data.player_name
	else:
		$Pages/Index/Title.text = '%s\'s Journal' % Data.player_name
	
	$Pages/TheApprenticeship/Signature.text = '~%s' % Data.player_name

func _unhandled_input(event):
	if visible:
		if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down') or event.is_action_pressed('ui_back'):
			Events.emit_signal('show_journal_page', {'id': 'index'})
		elif event.is_action_pressed('ui_right') and Data.unlocked_journal_pages.find(current_page) < Data.unlocked_journal_pages.size() - 1:
			show_next_page()
		elif event.is_action_pressed('ui_left') and Data.unlocked_journal_pages.find(current_page) > 0:
			show_prev_page()


func show_next_page():
	Events.emit_signal('show_journal_page', {'id': Data.unlocked_journal_pages[Data.unlocked_journal_pages.find(current_page)+1]})

func show_prev_page():
	Events.emit_signal('show_journal_page', {'id': Data.unlocked_journal_pages[Data.unlocked_journal_pages.find(current_page)-1]})

func _mouse_area(area, msg):
	match msg:
		{'mouse_over': var mouse_over, 'button_left_click': var left, ..}:
			if area == $Area:
					Utils.set_cursor_hand(false)
			if area == $CloseArea:
				if mouse_over:
					Utils.set_custom_cursor('close', Utils.get_scaled_res('res://assets/ui/close.png', 32, 32), Vector2(14,14))
					if left:
						Events.emit_signal('show_journal', false)
						SFX.page_flip.play()
				else:
					Utils.set_custom_cursor('close', null)
			if area in [$Return/Area, $Forward/Area, $Back/Area]:
				Utils.set_cursor_hand(mouse_over)
				if mouse_over and left:
					if area == $Return/Area:
						Events.emit_signal('show_journal_page', {'id': 'index'})
						Utils.set_cursor_hand(false)
					elif area == $Forward/Area:
						show_next_page()
						Utils.set_cursor_hand(false)
					elif area == $Back/Area:
						show_prev_page()
						Utils.set_cursor_hand(false)
			if area in index_areas.keys():
				var item = index_areas[area]
				item.get_node('BG').color = Color(0,0,0,0.1 if mouse_over else 0)
				Utils.set_cursor_hand(mouse_over)
				if left and mouse_over:
					var page = item.get_meta('page')
					Events.emit_signal('show_journal_page', {'id': page})
					Utils.set_cursor_hand(false)

func show_page(page):
	PAGES[current_page][1].hide()
	current_page = page
	PAGES[current_page][1].show()
	$Return.visible = current_page != 'index'
	$Forward.visible = Data.unlocked_journal_pages.find(current_page) < Data.unlocked_journal_pages.size() - 1
	$Back.visible = Data.unlocked_journal_pages.find(current_page) > 0
	if not current_page in viewed_pages:
		viewed_pages.append(current_page)
		update_index()
	for i in range(2):
		for item in index_items[i].get_children():
			item.visible = visible and current_page == 'index'

func update_index():
	for area in index_areas:
		Utils.unregister_mouse_area(area)
		index_areas[area].queue_free()
	for i in range(2):
		for item in index_items[i].get_children():
			item.queue_free()
	index_areas = {}
	var j = 0
	var last_category = ''
	for i in range(PAGES.keys().size()):
		var page = PAGES.keys()[i]
		if page == 'index' or not page in Data.unlocked_journal_pages:
			continue

		var category = 'Lore'
		if PAGES[page][1].has_meta('page_type'):
			if PAGES[page][1].get_meta('page_type') == 'plant':
				category = 'Plants'
			elif PAGES[page][1].get_meta('page_type') == 'potion':
				category = 'Potions'

		if category != last_category:
			var title_item = IndexTitle.instance()
			title_item.get_node('Label').bbcode_text = '[b][u]%s[/u][/b]' % category
			if category != 'Potions':
				index_items[0].add_child(title_item)
			else:
				index_items[1].add_child(title_item)
		last_category = category
		
		var item = IndexItem.instance()
		item.set_meta('page', page)
		var text = PAGES[page][0]
		if not page in viewed_pages:
			text += ' [color=#dc51ca]NEW[/color]'
		item.get_node('Label').bbcode_text = text
		index_areas[item.get_node('Area')] = item
		Utils.register_mouse_area(self, item.get_node('Area'))
		if category != 'Potions':
			index_items[0].add_child(item)
		else:
			index_items[1].add_child(item)
		j += 1
	Events.emit_signal('journal_has_new', Data.unlocked_journal_pages.size() > viewed_pages.size())

func _pages_comparison(a,b):
	return PAGES.keys().find(a) < PAGES.keys().find(b)

func sort_unlocked_pages():
	Data.unlocked_journal_pages.sort_custom(self, '_pages_comparison')

func _on_show_journal(show):
	if show:
		show()
		Events.emit_signal('show_journal_page', {'id': current_page})
		SFX.page_flip.play()
	else:
		PAGES[current_page][1].hide()
		for node in [self, $Forward, $Return, $Back]:
			node.hide()
		for i in range(2):
			for item in index_items[i].get_children():
				item.visible = false

func _on_unlock_journal_page(msg):
	var page_id = msg['id']
	if not page_id in Data.unlocked_journal_pages:
		Data.unlocked_journal_pages.append(page_id)
		
		var page = PAGES[page_id][1]
		if page.has_meta('page_type'):
			var page_type = page.get_meta('page_type')
			if page_type == 'plant':
				Data.inventory_by_id['seed'][page_id].hidden = false
			elif page_type == 'potion':
				Data.inventory_by_id['potion'][page_id].hidden = false
		
	update_index()
	sort_unlocked_pages()

	Events.emit_signal('achievement', {'diff_id': 'diff_pages', 'diff_add': page_id})
	Events.emit_signal('show_journal_page', {'id': 'index', "silent": true})

func _on_show_journal_page(msg):
	if not (msg.has("silent") and msg["silent"]):
		SFX.page_flip.play()
	var page_id = msg['id']
	if page_id in Data.unlocked_journal_pages:
		show_page(page_id)

func serialize():
	return {
		'unlocked': Data.unlocked_journal_pages,
		'viewed': viewed_pages
	}

func deserialize(data):
	viewed_pages = data['viewed']
	if data['unlocked'].size() > 0:
		Events.emit_signal('unlock_journal')
		for page in data['unlocked']:
			_on_unlock_journal_page({'id': page})
