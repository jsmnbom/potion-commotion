extends Control

var IndexItem = preload('res://UI/Journal/IndexItem.tscn')
var PagePlant = preload('res://UI/Journal/PagePlant.tscn')
var PotionPage = preload('res://UI/Journal/PotionPage.tscn')

var index_per_page = 15
onready var index_items1 = $Pages/Index/Items1
onready var index_items2 = $Pages/Index/Items2

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

var current_page = 'AStrangeGarden'

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
	Events.connect('mouse_area', self, '_on_mouse_area')
	Events.connect('show_journal', self, '_on_show_journal')
	Events.connect('unlock_journal_page', self, '_on_unlock_journal_page')
	Events.connect('show_journal_page', self, '_on_show_journal_page')

	if Data.player_name.ends_with('s'):
		$Pages/Index/Title.text = '%s\' Journal' % Data.player_name
	else:
		$Pages/Index/Title.text = '%s\'s Journal' % Data.player_name
	
	$Pages/TheApprenticeship/Signature.text = '~%s' % Data.player_name
	
	for page in PAGES:
		PAGES[page][1].hide()
	
	var potions = {}
	for item in Data.inventory:
		if item is Data._InventoryPotion:
			potions[item.id] = item
	
	for plant_id in Data.plants:
		var plant = Data.plants[plant_id]
		var page = PagePlant.instance()
		page.name = plant_id
		var text = plant.description + '\n\n'
		text += 'Growth time: %s' % Utils.time_string(plant.growth_time)
		var used_in = []
		for potion in potions:
			var potion_item = potions[potion]
			if plant_id in potion_item.ingredients:
				used_in.append(potion)
				continue
		
		page.init(plant.name, text, plant.res_path, used_in, plant.collision_polygons_small)
		add_page(plant_id, plant.name, page)
		
	for potion in potions:
		var potion_item = potions[potion]
		var page = PotionPage.instance()
		page.name = potion_item.id
		var text = potion_item.long_description.dedent().lstrip('\n').rstrip('\n') + '\n\n'
		page.init(potion_item.short_name, text, potion_item.res_path, potion_item.ingredients, self)
		add_page(potion_item.id, potion_item.name, page)
	
	if Debug.JOURNAL:
		for page in PAGES:
			if not page in Data.unlocked_journal_pages:
				Events.emit_signal('unlock_journal_page', {'id': page})
	
	update_index()
	show_page(current_page)
	_on_show_journal(false)

func _unhandled_input(event):
	if event.is_action_pressed('ui_up') or event.is_action_pressed('ui_down'):
		show_page('index')
	elif event.is_action_pressed('ui_right') and Data.unlocked_journal_pages.find(current_page) < Data.unlocked_journal_pages.size() - 1:
		show_next_page()
	elif event.is_action_pressed('ui_left') and Data.unlocked_journal_pages.find(current_page) > 0:
		show_prev_page()


func show_next_page():
	show_page(Data.unlocked_journal_pages[Data.unlocked_journal_pages.find(current_page)+1])

func show_prev_page():
	show_page(Data.unlocked_journal_pages[Data.unlocked_journal_pages.find(current_page)-1])

func _on_mouse_area(msg):
	match msg:
		{'mouse_over': var mouse_over, 'button_left_click': var left, ..}:
			if msg['node'] == $Area:
					Utils.set_cursor_hand(false)
			if msg['node'] == $CloseArea:
				if mouse_over:
					Utils.set_custom_cursor('close', Utils.get_scaled_res('res://assets/ui/close.png', 32, 32), Vector2(14,14))
					if left:
						Events.emit_signal('show_journal', false)
				else:
					Utils.set_custom_cursor('close', null)
			if msg['node'] in [$Return/Area, $Forward/Area, $Back/Area]:
				Utils.set_cursor_hand(mouse_over)
				if mouse_over and left:
					if msg['node'] == $Return/Area:
						show_page('index')
						Utils.set_cursor_hand(false)
					elif msg['node'] == $Forward/Area:
						show_next_page()
						Utils.set_cursor_hand(false)
					elif msg['node'] == $Back/Area:
						show_prev_page()
						Utils.set_cursor_hand(false)
			if msg['node'] in index_areas:
				var i = index_areas.find(msg['node'])
				var item
				if i < index_per_page:
					item = index_items1.get_child(i)
				else:
					item = index_items2.get_child(i-index_per_page)
				item.get_node('BG').color = Color(0,0,0,0.1 if mouse_over else 0)
				Utils.set_cursor_hand(mouse_over)
				if left and mouse_over:
					var page = item.get_meta('page')
					show_page(page)
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
	for item in index_items1.get_children():
		item.visible = current_page == 'index'
	for item in index_items2.get_children():
		item.visible = current_page == 'index'

func update_index():
	for item in index_items1.get_children():
		item.queue_free()
	for item in index_items2.get_children():
		item.queue_free()
	index_areas = []
	var j = 0
	for i in range(PAGES.keys().size()):
		var page = PAGES.keys()[i]
		if page == 'index' or not page in Data.unlocked_journal_pages:
			continue
		var item = IndexItem.instance()
		item.set_meta('page', page)
		var text = PAGES[page][0]
		if not page in viewed_pages:
			text += ' [color=#dc51ca]NEW[/color]'
		item.get_node('Label').bbcode_text = text
		index_areas.append(item.get_node('Area'))
		item.hide()
		if j < index_per_page:
			index_items1.add_child(item)
		else:
			index_items2.add_child(item)
		j += 1

func _pages_comparison(a,b):
    return PAGES.keys().find(a) < PAGES.keys().find(b)

func sort_unlocked_pages():
	Data.unlocked_journal_pages.sort_custom(self, '_pages_comparison')

func _on_show_journal(show):
	if show:
		show_page(current_page)
		show()
	else:
		for node in [self, $Forward, $Return, $Back]:
			node.hide()
		for item in index_items1.get_children():
			item.visible = false
		for item in index_items2.get_children():
			item.visible = false

func _on_unlock_journal_page(msg):
	var page_id = msg['id']
	if not page_id in Data.unlocked_journal_pages:
		if Data.unlocked_journal_pages.size() == 1:
			Events.emit_signal('unlock_journal')
		Data.unlocked_journal_pages.append(page_id)
		
	update_index()
	sort_unlocked_pages()

	Events.emit_signal('achievement', {'diff_id': 'diff_pages', 'diff_add': page_id})

func _on_show_journal_page(msg):
	var page_id = msg['id']
	if page_id in Data.unlocked_journal_pages:
		show_page(page_id)

func serialize():
	return {
		'unlocked': Data.unlocked_journal_pages
	}

func deserialize(data):
	for page in data['unlocked']:
		_on_unlock_journal_page({'id': page})