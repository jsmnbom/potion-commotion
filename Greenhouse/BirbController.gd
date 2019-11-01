extends Node2D

var BirbPage = preload('res://Greenhouse/BirbPage.tscn')

var birb_pages_created = []

func _ready():
	$Timer.wait_time = 2
	$Timer.start()

	if Debug.DISABLE_BIRBS:
		$Timer.stop()

func seen(type, id):
	return Data.inventory_by_id[type][id].seen

func seen_list(type, list):
	for id in list:
		if not seen(type, id):
			return false
	return true

func _on_Timer_timeout():
	$Timer.wait_time = 10
	var unlocked = Data.unlocked_journal_pages
	var should_have = []
	
	# Gotten in the beginning
	should_have.append('index')
	should_have.append('AStrangeGarden')
	if 'AStrangeGarden' in unlocked:
		should_have.append('TheApprenticeship')
	if 'TheApprenticeship' in unlocked:
		should_have.append('hydroangea')
	
	if seen('potion', 'hydration'):
		should_have.append('fire_flower')
		should_have.append('cool_beans')
		
	if seen('seed', 'fire_flower') or seen('seed', 'cool_beans'):
		should_have.append('mandrake')
		
	var plants = ['mandrake', 'lucky_clover', 'nightshade', 'golden_berry', 'star_flower', 'jade_sunflower', 'crystal_stalk']
	var plants_shifted = plants.duplicate()
	plants_shifted.pop_front()
	
	for i in plants_shifted.size():
		if seen('seed', plants[i]):
			should_have.append(plants_shifted[i])
			
	for potion_id in Data.inventory_by_id['potion']:
		var potion = Data.inventory_by_id['potion'][potion_id]
		if seen_list('resource', potion.ingredients):
			should_have.append(potion_id)
	if 'growth2' in should_have and not 'growth' in unlocked:
		should_have.erase('growth2')
 			
	if 'mandrake' in should_have:
		should_have.append('TheCauldron1')
	if 'golden_berry' in should_have:
		should_have.append('TheCauldron2')
	if 'crystal_stalk' in should_have:
		should_have.append('TheCauldron3')
		
	var missing = []
	for page in should_have:
		if not page in unlocked and not page in birb_pages_created:
			missing.append(page)
	
	if missing.size() < 1:
		return
		
	var page_id = Utils.rng_choose(missing)
	for birb in [$Birb1, $Birb2]:
		if birb.is_offscreen and not birb.flying:
			birb_fetch_page(birb, page_id)
			return
	for birb in [$Birb1, $Birb2]:
		if not birb.flying and not birb.is_offscreen:
			birb_fetch_page(birb, page_id)
			return

func birb_fetch_page(birb, page_id):
	var page = BirbPage.instance()
	birb_pages_created.append(page_id)
	page.position = Vector2(-256, -256)
	page.init(page_id)
	page.hide()
	$BirbPages.add_child(page)
	birb.fetch_page(page)

func serialize():
	var data = {
		'birbs': [],
		'birb_pages': []
	}

	for birb in [$Birb1, $Birb2]:
		data['birbs'].append(birb.serialize())

	for page in $BirbPages.get_children():
		data['birb_pages'].append({
			'pos': [page.destination.x, page.destination.y],
			'page_id': page.page_id
		})

	return data

func deserialize(data):
	for i in range(2):
		[$Birb1, $Birb2][i].deserialize(data['birbs'][i])

	for page_data in data['birb_pages']:
		var page = BirbPage.instance()
		birb_pages_created.append(page_data['page_id'])
		page.position = Vector2(page_data['pos'][0], page_data['pos'][1])
		page.init(page_data['page_id'])
		page.show()
		$BirbPages.add_child(page)