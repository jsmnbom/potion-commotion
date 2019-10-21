extends Node

var _plant_hitboxes

func _init():
	clear()
	
	var file = File.new()
	file.open("res://assets/plants/hitboxes.bin", File.READ)
	_plant_hitboxes = file.get_var()
	
func clear():
	plants = {
		'hydroangea': _PlantData.new(
			'hydroangea',
			'Hydroangea',
			30,
			'The simplest of the plants it seems, but also one of the most useful ones.'
		),
		'fire_flower': _PlantData.new(
			'fire_flower',
			'Fire Flower',
			60,
			'Very hot to the touch, the Fire flower gives off a pretty light when it gets dark.'
		),
		'cool_beans': _PlantData.new(
			'cool_beans',
			'Cool Beans',
			60,
			'Very cool to the touch.'
		),
		'mandrake': _PlantData.new(
			'mandrake',
			'Mandrake',
			5*60,
			'This little bugger seems to love mischeif. Try harvesting it while it sleeps.'
		),
		'lucky_clover': _PlantData.new(
			'lucky_clover',
			'Lucky Clover',
			10*60,
			'A clover has got to be magical if it is this lucky!'
		),
		'nightshade': _PlantData.new(
			'nightshade',
			'Nightshade',
			20*60,
			'Seems to love the night, so much so that it refuses to grow during the day.'
		),
		'golden_berry': _PlantData.new(
			'golden_berry',
			'Golden Berry',
			30*60,
			'Maybe... do not try to eat them.'
		),
		'star_flower': _PlantData.new(
			'star_flower',
			'Star Flower',
			45*60,
			'Bright as a star.'
		),
		'jade_sunflower': _PlantData.new(
			'jade_sunflower',
			'Jade Sunflower',
			60*60,
			'Not your regular kind of sunflower.'
		),
		'crystal_stalk': _PlantData.new(
			'crystal_stalk',
			'Crystal Stalk',
			2*60*60,
			'Shineyyyy'
		)
	}

	inventory = [
		_InventorySeed.new('hydroangea',
			0,
			'Use on an empty field to plant.',
			-1
		), _InventorySeed.new('cool_beans',
			10,
			'Use on an empty field to plant.'
		), _InventorySeed.new('fire_flower',
			10,
			'Use on an empty field to plant.'
		), _InventorySeed.new('mandrake',
			100,
			'Use on an empty field to plant.'
		), _InventorySeed.new('lucky_clover',
			500,
			'Use on an empty field to plant.'
		), _InventorySeed.new('nightshade',
			2500,
			'Use on an empty field to plant.'
		), _InventorySeed.new('golden_berry',
			10000,
			'Use on an empty field to plant.'
		), _InventorySeed.new('star_flower',
			25000,
			'Use on an empty field to plant.'
		), _InventorySeed.new('jade_sunflower',
			100000,
			'Use on an empty field to plant.'
		), _InventorySeed.new('crystal_stalk',
			1000000,
			'Use on an empty field to plant.'
		), _InventoryPlantResource.new('hydroangea',
			''
		), _InventoryPlantResource.new('cool_beans',
			''
		), _InventoryPlantResource.new('fire_flower',
			''
		), _InventoryPlantResource.new('mandrake',
			''
		), _InventoryPlantResource.new('lucky_clover',
			''
		), _InventoryPlantResource.new('nightshade',
			''
		), _InventoryPlantResource.new('golden_berry',
			''
		), _InventoryPlantResource.new('star_flower',
			''
		), _InventoryPlantResource.new('jade_sunflower',
			''
		), _InventoryPlantResource.new('crystal_stalk',
			''
		), _InventoryResource.new('ash',
			'Ash',
			'Obtained from burning plants using the Potion of Flames.'
		), _InventoryResource.new('frost',
			'Frost',
			'Obtained from freezing plants using the Potion of Ice.'
		), _InventoryResource.new('aurum_dust',
			'Aurum Dust',
			'Obtained from using the Potion of Midas on a plant.'
		), _InventoryResource.new('star_dust',
			'Star Dust',
			'Obtained from using the Potion of the Stars on a plant.'
		), _InventoryResource.new('weeds',
			'Weeds',
			'Obtained from de-weeding your garden.'
		), _InventoryPotion.new('hydration',
			'Hydration',
			['hydroangea', 'hydroangea', 'hydroangea', 'hydroangea', 'hydroangea'],
			'Used to water your plants to make it drop more seeds.',
			"""
			
			Use:
			On a dried out field
			""",
			2
		), _InventoryPotion.new('ice',
			'Ice',
			['cool_beans', 'cool_beans', 'cool_beans', 'cool_beans', 'cool_beans'],
			'Freezes plants.',
			"""
			Freezes plants. Frozen plants drop frost when harvested, though it does make it impossile to harvest seeds from the plant.
			
			Use:
			On a plant
			Selling
			"""
		), _InventoryPotion.new('flames',
			'Flames',
			['fire_flower', 'fire_flower', 'fire_flower', 'fire_flower', 'fire_flower'],
			'Sets plants on fire.',
			"""
			Sets plants on fire. Burned plants drop ash when harvested, though it does make it impossile to harvest seeds from the plant.
			
			Use:
			On a plant
			Selling
			"""
		), _InventoryPotion.new('midas',
			'Midas',
			['golden_berry', 'golden_berry', 'golden_berry', 'golden_berry', 'golden_berry'],
			'Turns everything it touches to gold.',
			"""
			Turns everything it touches to gold. 
			
			Use:
			On a plant
			Selling
			"""
		), _InventoryPotion.new('stars',
			'the Stars',
			['star_flower', 'star_flower', 'star_flower', 'lucky_clover', 'aurum_dust'],
			'Summons the power of the stars onto a plant.',
			"""
			Summons the power of the stars onto a plant.
	
			Use:
			On a plant
			Selling
			"""
		), _InventoryPotion.new('midnight',
			'Midnight',
			['cool_beans', 'frost', 'frost', 'jade_sunflower', 'jade_sunflower'],
			'Makes it night.',
			"""
			
			Use:
			Anywhere in the greenhouse
			Selling
			"""
		), _InventoryPotion.new('sunlight',
			'Sunlight',
			['fire_flower', 'ash', 'ash', 'jade_sunflower', 'jade_sunflower'],
			'Makes it day.',
			"""
			Use:
			Anywhere in the greenhouse
			Selling
			"""
		), _InventoryPotion.new('growth',
			'Growth',
			['mandrake', 'weeds', 'weeds', 'weeds', 'hydroangea'],
			'Helps plants grow. No mandrakes were harmed in the brewing on this potion. maybe.',
			"""
			Use:
			On a plant
			Selling
			"""
		), _InventoryPotion.new('growth2',
			'Growth II',
			['mandrake', 'mandrake', 'mandrake', 'weeds', 'hydroangea'],
			'Helps plants grow. \nMuch more potent than the regular Potion of Growth.',
			"""
			
			Use:
			On a plant
			Selling
			"""
		), _InventoryPotion.new('romance',
			'Romance',
			['golden_berry', 'star_dust', 'star_dust', 'aurum_dust', 'nightshade'],
			'Love potion? Not exactly ethical is it?',
			"""
			
			Use:
			Selling"""
		), _InventoryPotion.new('healing',
			'Healing',
			['mandrake', 'ash', 'hydroangea', 'hydroangea', 'hydroangea'],
			'Heals sick plants.',
			"""
			
			Use:
			Selling"""
		), _InventoryPotion.new('poison',
			'Poison',
			['nightshade', 'nightshade', 'nightshade', 'hydroangea', 'hydroangea'],
			'Poisons plants. Whyever would you wanna do that??',
			"""
			Use:
			Selling"""
		), _InventoryPotion.new('gardening',
			'Gardening',
			['weeds', 'weeds', 'hydroangea', 'frost', 'ash'],
			'Makes plants grow even when infested with weeds.',
			"""
			Use:
			On weed infested plants
			Selling
			"""
		), _InventoryPotion.new('wealth',
			'Wealth',
			['crystal_stalk', 'crystal_stalk', 'crystal_stalk', 'star_dust', 'aurum_dust'],
			'Seems to somehow produce a big sum of gums.',
			"""
			Use:
			Anywhere in the greenhouse
			""",
			-1
		), _InventoryPotion.new('fortune',
			'Fortune',
			['lucky_clover', 'lucky_clover', 'lucky_clover', 'lucky_clover', 'frost'],
			'Increases luck.',
			"""
			Use:
			Anywhere in the greenhouse
			"""
		)
	]

	achievements = [
		_AchievementDiff.new('diff_plants', 'Harvest %s different plants', [2, 5, 10]),
		_AchievementTotal.new('total_brew', 'Brew a total of %s potions', [10, 100, 1000]),
		_AchievementDiff.new('diff_brew', 'Brew %s different potions', [5, 10, 20]),
		_AchievementTotal.new('total_plants', 'Harvest a total of %s plants.', [50, 500, 1000]),
		_AchievementTotal.new('total_potions', 'Use a total of %s potions', [20, 200, 2000]),
		_AchievementTotal.new('total_items', 'Gain a total of %s items', [1000, 10000, 100000]),
		_AchievementTotal.new('total_gems', 'Gain a total of %s gems', [1000, 300000, 1000000]),
		_AchievementTotal.new('total_seeds', 'Gain a total of %s seeds', [100, 1000, 10000]),
		# Feeds birds
		# Book pages
	]

	unlocked_journal_pages = ['index']

	time = 9*60

	luck = 0.0

	inventory_by_id = {
		'seed': {},
		'resource': {},
		'potion': {}
	}

	for item in inventory:
		inventory_by_id[item.type][item.id] = item

	_calculate_potion_prices()

func _calculate_potion_prices():
	for potion_id in inventory_by_id['potion']:
		var potion = inventory_by_id['potion'][potion_id]
		if potion.sell_price_overwrite == null:
			var sell_price = 0.0
			for ingredient in potion.ingredients:
				match ingredient:
					'ash':
						sell_price += float(inventory_by_id['potion']['flames'].sell_price) * 1.1
					'frost':
						sell_price += float(inventory_by_id['potion']['ice'].sell_price) * 1.1
					'aurum_dust':
						sell_price += float(inventory_by_id['potion']['midas'].sell_price) * 1.1
					'star_dust':
						sell_price += float(inventory_by_id['potion']['stars'].sell_price) *1.1
					'weeds':
						sell_price += 2
					_:
						sell_price += inventory_by_id['seed'][ingredient].cost / 2
			if sell_price < 100:
				sell_price = stepify(sell_price, 5)
			elif sell_price < 1000:
				sell_price = stepify(sell_price, 10)
			elif sell_price < 10000:
				sell_price = stepify(sell_price, 50)
			elif sell_price < 100000:
				sell_price = stepify(sell_price, 1000)
			potion.sell_price = sell_price
		else:
			potion.sell_price = potion.sell_price_overwrite

class _ResourceData:
	var res setget ,get_res  
	var res_path setget ,get_res_path

	func get_res_path():
		return null
	
	func get_res():
		return ResourceLoader.load(self.res_path)

	func get_scaled_res(height, width):
		return Utils.get_scaled_res(self.res_path, height, width)

class _PlantData extends _ResourceData:
	var id
	var name
	var growth_time
	var collision_polygons setget ,get_collision_polygons
	var description
	
	func _init(id, name, growth_time, description):
		self.id = id
		self.name = name
		self.growth_time = max(growth_time / 60, 5) if Debug.FAST_PLANTS else growth_time
		self.description = description

	func get_collision_polygons():
		return Data._plant_hitboxes[self.id]

	func get_res_path():
		return 'res://assets/plants/%s.png' % self.id
	
	func get_res():
		return ResourceLoader.load(self.res_path)

class _InventoryItem extends _ResourceData:
	var type  
	var count  
	var id
	var seen = false  
	var description = ''

class _InventorySeed extends _InventoryItem:
	var plant
	var cost
	var name setget ,get_name  
	
	func _init(plant, cost, description, default_count=0):
		self.type = 'seed'
		self.count = default_count
		self.plant = plant
		self.cost = cost
		self.id = plant
		self.description = description
	
	func get_name():
		return Data.plants[self.plant].name + ' seed'

	func get_res_path():
		return 'res://assets/seeds/%s.png' % self.plant

class _InventoryPotion extends _InventoryItem:
	var ingredients
	var short_name
	var name
	var sell_price
	var sell_price_overwrite
	var long_description

	func _init(id, name, ingredients, description, long_description, sell_price_overwrite=null, default_count=0):
		self.type = 'potion'
		self.count = default_count
		self.id = id
		self.short_name = name
		self.name = 'Potion of %s' % name
		self.ingredients = ingredients
		self.sell_price_overwrite = sell_price_overwrite
		self.description = description
		self.long_description = long_description

	func get_res_path():
		return 'res://assets/potions/%s.png' % self.id
	
class _InventoryPlantResource extends _InventoryItem:
	var plant
	var name setget ,get_name  
	
	func _init(plant, description, default_count=0):
		self.type = 'resource'
		self.plant = plant
		self.count = default_count
		self.id = plant
		self.description = description
		
	func get_name():
		return Data.plants[self.plant].name

	func get_res_path():
		return 'res://assets/resources/%s.png' % self.id

class _InventoryResource extends _InventoryItem:
	var name
	
	func _init(id, name, description, default_count=0):
		self.type = 'resource'
		self.count = default_count
		self.id = id
		self.name = name
		self.description = description

	func get_res_path():
		return 'res://assets/resources/%s.png' % self.id

class _Achievement:
	var id
	var text
	var steps
	var value setget ,get_value
		
	func get_value():
		return 0

class _AchievementTotal extends _Achievement:
	var total = 0
	
	func _init(id, text, steps):
		self.id = id
		self.text = text
		self.steps = steps

	func get_value():
		return self.total

class _AchievementDiff extends _Achievement:
	var seen = []
	
	func _init(id, text, steps):
		self.id = id
		self.text = text
		self.steps = steps

	func get_value():
		return seen.size()

var plants

var inventory

var inventory_by_id 

var achievements

var unlocked_journal_pages

var time

var player_name

var luck