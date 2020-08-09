extends NinePatchRect

onready var title_label = $Title
onready var sell_price_container = $SellPriceContainer
onready var sell_price_label = $SellPriceContainer/SellPriceLabel
onready var sell_price_texture = $SellPriceContainer/SellPriceTexture
onready var price_container = $PriceContainer
onready var price_label = $PriceContainer/PriceLabel
onready var description_label = $Description
onready var description_italics_label = $DescriptionItalics
onready var recipe_container = $RecipeContainer
onready var progress_bar = $Progress
onready var progress_bar_bg = $Progress/BG
onready var progress_bar_label = $Progress/Label
onready var time_left_label = $TimeLeft
onready var used_potions_container = $UsedPotions
onready var used_potions_label = $UsedPotionsLabel

onready var description_font = description_label.get_font('font')
onready var description_italics_font = description_italics_label.get_font('font')
onready var title_font = title_label.get_font('font')

var title_text_width

onready var items = [
	title_label,
	sell_price_container,
	price_container,
	recipe_container,
	description_label,
	description_italics_label,
	used_potions_label,
	used_potions_container,
	progress_bar,
	time_left_label
]

var showing = false
var showing_inventory_item = false
var show_on_next_frame = false

func _ready():
	reset()
	
	var progress_texture = AnimatedTexture.new()
	progress_texture.frames = 6
	progress_texture.fps = 8
	for i in range(6):
		progress_texture.set_frame_texture(i, Utils.get_scaled_res('res://assets/ui/bar/%s.png' % i, 18*2, 18))
	progress_bar_bg.texture = progress_texture

	Events.connect('tooltip', self, '_on_tooltip')

	progress_bar.set_meta('padding_up', 8)
	progress_bar.set_meta('padding_down', 4)
	progress_bar.set_meta('ignore_width', true)
	progress_bar.set_meta('min_width', 150)
	used_potions_container.set_meta('min_width', 96)
	used_potions_container.set_meta('ignore_width', true)
	used_potions_label.set_meta('ignore_width', true)
	time_left_label.set_meta('ignore_width', true)
	

func reset():
	hide()
	title_label.hide()
	sell_price_container.hide()
	price_container.hide()
	recipe_container.hide()
	description_label.hide()
	description_italics_label.hide()
	sell_price_texture.show()
	progress_bar.hide()
	time_left_label.hide()
	used_potions_container.hide()
	used_potions_label.hide()
	showing = false
	showing_inventory_item = false

func update_size_and_pos():
	var height = 4
	var width = 0
	var widths = []
	
	if title_label.visible:
		title_label.rect_size.x = title_text_width

	for item in items:
		if item.visible:
			var padding_up = 0
			var padding_down = 0
			if item.has_meta('padding_up'):
				padding_up = item.get_meta('padding_up')
			if item.has_meta('padding_down'):
				padding_up = item.get_meta('padding_down')

			item.rect_position = Vector2(12, height+padding_up)
			height += item.rect_size.y + padding_up + padding_down

			if item.rect_size.x > width and not item.has_meta('ignore_width'):
				width = item.rect_size.x
			if item.has_meta('min_width') and item.get_meta('min_width') > width:
				width = item.get_meta('min_width')

		widths.append(width)
	
	if description_label.visible:
		description_label.rect_size.y = description_label.get_line_count() * (description_label.get_line_height() - 5)
	if description_italics_label.visible:
		description_italics_label.rect_size.y = description_italics_label.get_line_count() * (description_italics_label.get_line_height() - 5)
	if progress_bar.visible:
		progress_bar.rect_size.x = width
		progress_bar_bg.rect_size.x = width-8
		progress_bar_label.rect_size.x = width-16
	if time_left_label.visible:
		time_left_label.rect_size.x = width
	if used_potions_container.visible:
		used_potions_container.rect_size.x = width
	if used_potions_label.visible:
		used_potions_label.rect_size.x = width
	
	rect_size = Vector2(width+20, height+10)

	var pos = get_viewport().get_mouse_position() + Vector2(10, 10)
	var viewport_size = get_viewport_rect().size
	if pos.x + self.rect_size.x > viewport_size.x or showing_inventory_item:
		pos.x = pos.x - 20 - self.rect_size.x
	if pos.y + self.rect_size.y > viewport_size.y or showing_inventory_item:
		pos.y = pos.y - 20 - self.rect_size.y
	self.rect_position = pos

func _process(delta):
	if showing:
		update_size_and_pos()
	if show_on_next_frame:
		update_size_and_pos()
		show()
		showing = true
		show_on_next_frame = false

func set_title(text):
	title_label.show()
	title_label.text = text
	title_text_width = title_font.get_string_size(text).x

func set_description(text):
	description_label.show()
	description_label.text = text
	description_label.rect_size.x = min(description_font.get_string_size(text).x * 1.2, 250)

func set_description_italics(text):
	description_italics_label.show()
	description_italics_label.text = text
	var width = 0
	for line in text.split('\n'):
		var test = description_italics_font.get_string_size(line).x + 32
		if test > width:
			width = test
	description_italics_label.rect_size.x = min(width, 200)

func show_inventory_item(item):
	if item.hidden:
		set_title('???')
		set_description_italics('You have not yet seen this item.')
		show_on_next_frame = true
		showing_inventory_item = true
		return

	set_title(item.name)
	var description_items = []
	if item.description:
		description_items.append(item.description)

	match item.type:
		'seed':
			if item.cost:
				price_container.show()
				price_label.text = 'Price:  %s' % Utils.format_number(item.cost)
				set_description_italics('Right click to buy.\nUse on a field to plant.')
			else:
				set_description_italics('Use on a field to plant.')
		'resource':
			set_description_italics('Throw 5 ingredients in the cauldron to brew potions.')
		'potion':
			sell_price_container.show()
			if item.sell_price:
				if item.sell_price != -1:
					sell_price_label.text = 'Sell  price:  %s' % Utils.format_number(item.sell_price)
					if item.count > 0:
						set_description_italics('Right click to sell.')
					else:
						description_italics_label.hide()
				else:
					sell_price_texture.hide()
					sell_price_label.text = 'Sell  price:  unsellable'

			recipe_container.show()
			for i in range(item.ingredients.size()):
				var ingredient_item = Data.inventory_by_id['resource'][item.ingredients[i]]
				recipe_container.get_child(i+1).texture = ingredient_item.get_scaled_res(16, 16)
	if description_items.size() > 0:
		set_description(PoolStringArray(description_items).join('\n'))

	show_on_next_frame = true
	showing_inventory_item = true

func show_weeds():
	set_title('Empty field')
	set_description('Infested with weeds.')
	set_description_italics('Click to remove weeds.')

	show_on_next_frame = true
	
func show_plant(plant, progress, time_left, used_potions, weeds):
	print(plant)
	set_title(Data.plants[plant].name)
	description_label.hide()
	description_italics_label.hide()
	progress_bar.show()
	progress_bar.value = 100 - progress
	if progress < 100:
		progress_bar_label.text = '%s%%' % progress
	else:
		progress_bar_label.text = 'COMPLETE'
		var s = 'Click to harvest resource.'
		if not ('flames' in used_potions or 'ice' in used_potions or 'midas' in used_potions or 'stars' in used_potions or plant == 'hydroangea'):
			s += '\nRight-click to harvest seeds.'
		set_description_italics(s)
	if weeds:
		set_description('Infested with weeds.')
		set_description_italics('Click to remove weeds.')
	if time_left > 0:
		time_left_label.show()
		time_left_label.text = Utils.time_string(time_left) + ' left'
	else:
		time_left_label.hide()
	used_potions_label.show()
	if used_potions.size() == 0:
		used_potions_label.text = 'No potions used'
	else:
		used_potions_container.show()
		used_potions_label.text = 'Used potions:'
		for i in range(2):
			var potion_node = used_potions_container.get_node('Potion%s' % i)
			if used_potions.size() > i:
				var potion = Data.inventory_by_id['potion'][used_potions[i]]
				potion_node.show()
				potion_node.texture = potion.get_scaled_res(64, 64)
			else:
				potion_node.hide()
	show_on_next_frame = true

func show_arbitrary(title, description):
	if title:
		set_title(title)
	if description:
		set_description(description)
	show_on_next_frame = true

func _on_tooltip(msg):
	match msg:
		{'plant': var plant, 'progress': var progress, 'time_left': var time_left, 'used_potions': var used_potions, 'weeds': var weeds}:
			show_plant(plant, progress, time_left, used_potions, weeds)
		{'plant': null, 'weeds': true}:
			show_weeds()
		{'inventory_item': var item}:
			show_inventory_item(item)
		{'title': var title}:
			show_arbitrary(title, '')
		{'description': var description}:
			show_arbitrary('', description)
		{'title': var title, 'description': var description}:
			show_arbitrary(title, description)
		{'hide': true}:
			reset()
