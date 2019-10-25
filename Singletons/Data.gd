extends Node

var _plant_hitboxes

func _init():
	clear()
	
	var file = File.new()
	file.open("res://assets/plants/hitboxes.bin", File.READ)
	_plant_hitboxes = file.get_var()

	var version_file = File.new()
	version_file.open("res://VERSION", File.READ)
	version = version_file.get_line()
	
func clear():
	plants = {
		'hydroangea': _PlantData.new(
			'hydroangea',
			'Hydroangea',
			30,
			"The Hydroangea is a tall flower. It has blue petals and grows rather fast. Having a hydroangea is essential for having a farm, since it's a component of the Potion of Hydration."
		),
		'fire_flower': _PlantData.new(
			'fire_flower',
			'Fire Flower',
			60,
			"You might want to wear gloves when handling this plant. It gets incredibly hot and even glows bright orange at night. That being said, it is a very pretty plant, and also quite useful since it allows for the creation of the Potion of Flames which can be used to burn plants into Ash. The Fire Flower loves the warm sunlight and refuses to grow during the day."
		),
		'cool_beans': _PlantData.new(
			'cool_beans',
			'Cool Beans',
			60,
			"This plant is ice cold to the touch. It hates the warmth of the sun and only thrives during the night where it’s nice and cold. It’s used in the Potion of Ice to turn plants into icy Frost."
		),
		'mandrake': _PlantData.new(
			'mandrake',
			'Mandrake',
			5*60,
			"Now you want to be careful with this little bugger. Mandrakes love to play tricks on humans, and generally just be a nuisance. They are best harvested at night where they are docile, though they grow both night and day. Mandrakes are a key ingredient in potions that boost plant growth."
		),
		'lucky_clover': _PlantData.new(
			'lucky_clover',
			'Lucky Clover',
			10*60,
			"I feel more lucky just being near this plant. It seems to almost emit a lucky aura - whatever that means. It grows both at night and during the day, and can be used to brew the Potion of Fortune."
		),
		'nightshade': _PlantData.new(
			'nightshade',
			'Nightshade',
			20*60,
			"This violet flower is quite poisonous, and should therefore be handled with care. It should never be ingested, and as such it’s use in potions is quite sparse. As the name suggests it loves the night, and sleeps during the day."
		),
		'golden_berry': _PlantData.new(
			'golden_berry',
			'Golden Berry',
			30*60,
			"This green bush has numerous berries that shine a bright gold colour. I wouldn’t go eating the berries though, some say they are actually made of gold. The Golden Berries can be used in the Potion of Midas for it’s golden properties, but it is also a component of the highly valuable Potion of Romance. The golden berry loves the bright sun that makes it berries shine, and refuses to grow in the dimmer moonlight."
		),
		'star_flower': _PlantData.new(
			'star_flower',
			'Star Flower',
			45*60,
			"This flower glows bright as a star. The flower only has one use that I have found thus far - the elusive Potion of the Stars. The Star Flower only grows when it can see all it’s friends up in the night sky."
		),
		'jade_sunflower': _PlantData.new(
			'jade_sunflower',
			'Jade Sunflower',
			60*60,
			"The Jade Sunflower is not your regular kind of sunflower. Instead of the usual yellow, it is instead bright emerald. It only grows in the day, where it can feel the bright sun shining down upon it. It is used in the Potion of Sunlight and the Potion of Midnight for it’s mystifying time warping abilities."
		),
		'crystal_stalk': _PlantData.new(
			'crystal_stalk',
			'Crystal Stalk',
			2*60*60,
			"Ahh, the Crystal Stalk. The hardest plant to grow I have ever come across. This makes it extremely valuable, but it also means that I haven’t had a chance to really discover new potions that it’s an ingredient of. The stalk grows very slow. Luckily it grows both day and night. I was surprised to discover it grows a big, glowing, yellow eye in its final stage. The eyeball even follows my movement. Quite creepy."
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
			'Hydrates dry fields',
			"""
			The Potion of Hydration is the simplest of all potions. This is the first one any alchemist learns. It only requires five samples of the Hydroangea flower. The potion is used for many things such as staying hydrated on work. It's also used to water crop fields at farms.
			"""
		), _InventoryPotion.new('ice',
			'Ice',
			['cool_beans', 'cool_beans', 'cool_beans', 'cool_beans', 'cool_beans'],
			'Freezes everything it touches',
			"""
			This potion will freeze anything it touches to ice. While it is quite easy to make potion, it’s effects can be quite destructive. Be careful to not accidentally freeze your fingers! The Potion of Ice is made from nothing more than some cool beans.
			"""
		), _InventoryPotion.new('flames',
			'Flames',
			['fire_flower', 'fire_flower', 'fire_flower', 'fire_flower', 'fire_flower'],
			'Burns everything it touches',
			"""
			This is a rather basic potion but it's quite dangerous. This Potion of Flames is able to burn anything into ash. Though that is sometimes a good thing since ash can be used in potions. The Potion of Flames is made from the hot Fire Flower.
			"""
		), _InventoryPotion.new('midas',
			'Midas',
			['golden_berry', 'golden_berry', 'golden_berry', 'golden_berry', 'golden_berry'],
			'Turns everything it touches to gold',
			"""
			This innocent looking potion will turn anything it touches into gold. Now this might seem like a good thing, but you will want to be really careful with it. Gold is quite fragile and the things that have been turned will therefore quickly crumble into a fine gold powder.
			"""
		), _InventoryPotion.new('stars',
			'the Stars',
			['star_flower', 'star_flower', 'star_flower', 'lucky_clover', 'aurum_dust'],
			'Summons the power of the stars unto a plant',
			"""
			This potion seems to summon the power of the stars. Using it on a plant will make it imbued with star power and drop stardust.
			"""
		), _InventoryPotion.new('midnight',
			'Midnight',
			['cool_beans', 'frost', 'frost', 'jade_sunflower', 'jade_sunflower'],
			'Warps time to nearest nighttime',
			"""
			This inky black potion is able to change time. It's quite a difficult potion to pull off, since it contains the rare Jade Sunflower. If this potion is used, it will warp time into the nearest nighttime. Handle with care. Time travel isn’t for beginners.
			"""
		), _InventoryPotion.new('sunlight',
			'Sunlight',
			['fire_flower', 'ash', 'ash', 'jade_sunflower', 'jade_sunflower'],
			'Warps time to nearest daytime.',
			"""
			This bright and sunny potion is able to change time. It's quite a difficult potion to pull off, since it contains the rare Jade Sunflower. If this potion is used, it will warp time into the nearest daytime. Handle with care. Time travel isn’t for beginners.
			"""
		), _InventoryPotion.new('growth',
			'Growth',
			['mandrake', 'weeds', 'weeds', 'weeds', 'hydroangea'],
			'Makes plants grow much faster',
			"""
			A simple potion that makes plants grow faster. Alchemists have tried to find a good use for those damn weeds and it turns out they can make other plants grow faster. This effective and simple potion can make take up to 50% less time for a plant to mature. No mandrakes were harmed in the production of this potion… or actually... They probably were.
			"""
		), _InventoryPotion.new('growth2',
			'Growth II',
			['mandrake', 'mandrake', 'mandrake', 'weeds', 'hydroangea'],
			'A much more potent growth potion',
			"""
			This potion works just like the original Potion of Growth. This is just stronger. Alchemist found out if you use less weeds and more mandrakes, the plants take up to 75% less time for a plant to mature.
			"""
		), _InventoryPotion.new('romance',
			'Romance',
			['golden_berry', 'star_dust', 'star_dust', 'aurum_dust', 'nightshade'],
			'Makes people fall in love - highly valuable',
			"""
			The Potion of Romance makes people fall in love. Though it might sound useful, it has quite some ethical problems. Even though it has been banned in many places, it is still highly valuable. While the Nightshade might seem like a bad idea in a potion, the magical properties of the star dust seems to nullify any ill effects of the Nightshade.
			"""
		), _InventoryPotion.new('healing',
			'Healing',
			['mandrake', 'ash', 'hydroangea', 'hydroangea', 'hydroangea'],
			'Heals sick plants',
			"""
			Now this is a very important potion. It uses the magical properties of the mandrake to heal plants that have become sick. While plants getting sick is generally quite rare, it is always a good idea to have a couple of these potions on hand.
			"""
		), _InventoryPotion.new('poison',
			'Poison',
			['nightshade', 'nightshade', 'nightshade', 'nightshade', 'hydroangea'],
			'Highly poisonous… duh',
			"""
			This purple potion with green mist, is extremely dangerous. The Potion of Poison is deadly. The potion is brewed on the poisonous Nightshade flower. The recipe has even been officially changed so it has less Nightshade. It's now watered down with a bit of Hydroangea. Handle with extreme caution.
			"""
		), _InventoryPotion.new('gardening',
			'Gardening',
			['weeds', 'weeds', 'weeds', 'hydroangea', 'hydroangea'],
			'Feeds weeds so they don’t disturb plant growth',
			"""
			I discovered this potion one morning when i discovered some weeds in my Potion of Hydration. Turns out this potion is capable of feeding nearby weeds so they leave other plants alone. That means that if you use his on a field, the weeds won’t disturb your plant. The weeds will return though. And they will get annoying again.
			"""
		), _InventoryPotion.new('wealth',
			'Wealth',
			['crystal_stalk', 'crystal_stalk', 'crystal_stalk', 'star_dust', 'aurum_dust'],
			'Drops a huge amount of gems',
			"""
			This purple concoction is definitely one of the weirder ones. Instead of being used on a plant, you simply pour it out wherever you would like, and as the liquid comes into contact with air, it turns into a large sum of gems. It mostly consists of the very valuable Crystal Stalk.
			Warning: Might destroy capitalism if brewed in large quantities.			
			""",
			-1
		), _InventoryPotion.new('fortune',
			'Fortune',
			['lucky_clover', 'lucky_clover', 'lucky_clover', 'lucky_clover', 'frost'],
			'Increases luck',
			"""
			This very green looking potion is a peculiar one. It somehow makes whoever used it more lucky. I don’t even want to begin to get into how that could possibly work. It consists of almost nothing but Lucky Clovers, but watered down with some Hydroangea.
			"""
		)
	]

	achievements = [
		_AchievementDiff.new('diff_plants', 'Harvest %s different plants', [2, 5, 10]),
		_AchievementTotal.new('total_brew', 'Brew a total of %s potions', [200, 2000, 5000]),
		_AchievementDiff.new('diff_brew', 'Brew %s different potions', [5, 10, 20]),
		_AchievementTotal.new('total_plants', 'Harvest a total of %s plants.', [500, 5000, 50000]),
		_AchievementTotal.new('total_potions', 'Use a total of %s potions', [100, 1000, 2500]),
		_AchievementTotal.new('total_items', 'Gain a total of %s items', [3000, 30000, 300000]),
		_AchievementTotal.new('total_gems', 'Gain a total of %s gems', [1000, 100000, 1000000]),
		_AchievementTotal.new('total_seeds', 'Gain a total of %s seeds', [500, 5000, 50000]),
		_AchievementDiff.new('diff_pages', 'Collect all journal pages', [0, 0, 30], true),
	]

	unlocked_journal_pages = ['index']

	time = 9*60

	luck = 0.0

	play_time = 0

	inventory_by_id = {
		'seed': {},
		'resource': {},
		'potion': {}
	}

	for item in inventory:
		if item is _InventoryPotion:
			item.ingredients.sort()
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
					'hydroangea':
						sell_price += 1
					_:
						sell_price += inventory_by_id['seed'][ingredient].cost / 2
			if sell_price < 100:
				sell_price = stepify(sell_price, 5)
			elif sell_price < 1000:
				sell_price = stepify(sell_price, 10)
			elif sell_price < 10000:
				sell_price = stepify(sell_price, 100)
			elif sell_price < 100000:
				sell_price = stepify(sell_price, 1000)
			else:
				sell_price = stepify(sell_price, 25000)
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
	var collision_polygons_small setget ,get_collision_polygons_small
	var description
	
	func _init(id, name, growth_time, description):
		self.id = id
		self.name = name
		self.growth_time = max(growth_time / 60, 5) if Debug.FAST_PLANTS else growth_time
		self.description = description

	func get_collision_polygons():
		return Data._plant_hitboxes[self.id][0]

	func get_collision_polygons_small():
		return Data._plant_hitboxes[self.id][1]

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
	var big
		
	func get_value():
		return 0

class _AchievementTotal extends _Achievement:
	var total = 0
	
	func _init(id, text, steps, big=false):
		self.id = id
		self.text = text
		self.steps = steps
		self.big = big

	func get_value():
		return self.total

class _AchievementDiff extends _Achievement:
	var seen = []
	
	func _init(id, text, steps, big=false):
		self.id = id
		self.text = text
		self.steps = steps
		self.big = big

	func get_value():
		return seen.size()

var plants

var inventory

var inventory_by_id 

var achievements

var unlocked_journal_pages = []

var time = 0.0

var player_name = ''

var luck = 0.0

var play_time = 0

var version = ''

var day_duration = 24*60