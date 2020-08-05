extends Node

var _plant_hitboxes

func _init():
	clear()
	
	var file = File.new()
	file.open("res://assets/plants/hitboxes.bin", File.READ)
	_plant_hitboxes = file.get_var()

	var version_file = File.new()
	if version_file.file_exists('res://VERSION'):
		version_file.open("res://VERSION", File.READ)
		version = version_file.get_line()
	elif OS.is_debug_build():
		version = 'DEBUG BUILD'
	else:
		version = 'ERROR: VERSION NOT FOUND'
	
func clear():
	plants = {
		'hydroangea': _PlantData.new(
			'hydroangea',
			'Hydroangea',
			30,
			"The Hydroangea is a tall, pretty flower. I’ve grown so many of these. As the Hydroangea grows, it sucks out all the water from the earth around it and stores it in its blue petals. The Hydroangea grows extremely fast and is fully grown in only 30 seconds. It’s truly incredible that a plant can grow this fast. The Hydroangea even grows at any time of the day, as long as it has access to plenty of water.			"
		),
		'fire_flower': _PlantData.new(
			'fire_flower',
			'Fire Flower',
			60,
			"You might want to wear gloves when handling this plant. It gets incredibly hot and even glows bright orange in the night. That being said, it is a very pretty plant, and also quite useful since it allows for the creation of the Potion of Flames. The Fire Flower loves the warm sunlight and refuses to grow during the cold night. This is quite important - make sure you don’t plant a batch of these right before night time. The Fire Flower matures in only 1 minute."
		),
		'cool_beans': _PlantData.new(
			'cool_beans',
			'Cool Beans',
			60,
			"This plant is ice cold to the touch. It hates the warmth of the sun and only thrives during the night where it’s dark and cold. It’s used in the Potion of Ice. The Cool Beans plant takes 1 minute to fully grow. It grows many beans but sadly a lot of them go bad. The beans are quite big actually. One Cool Bean is about the size of an apple. It tastes like snow though - so, it’s not a very tasty snack."
		),
		'mandrake': _PlantData.new(
			'mandrake',
			'Mandrake',
			5*60,
			"Now, you want to be careful with this little bugger. Mandrakes love to play tricks and just be a nuisance in general. They are best harvested at night where they are asleep, though they grow both night and day. Mandrakes are a key ingredient in the famous potions of growth. The Mandrake takes 5 minutes to grow. You can see it’s fully grown when it sticks its evil little eyes up over the soil and takes a peek at you."
		),
		'lucky_clover': _PlantData.new(
			'lucky_clover',
			'Lucky Clover',
			10*60,
			"The Lucky Clover is a tall green clover with 4 leaves. I feel more lucky just being near this plant. It seems to almost emit a lucky aura - whatever that means. It grows both at night and during the day and can be used to brew the Potion of Fortune as well as the Potion of the Stars. This clover takes around 10 minutes to grow. I recommend using growth potions on them if you’re as impatient as me."
		),
		'nightshade': _PlantData.new(
			'nightshade',
			'Nightshade',
			20*60,
			"This violet flower is quite poisonous and should, therefore, be handled with care. It should never be ingested and as such its use in potions is quite sparse. As the name suggests it loves the night and sleeps during the day. Nightshade is an essential component for producing a good Potion of Poison. The flower itself takes 20 minutes before it is fully grown. Growing Nightshade is illegal in some places but here it’s alright... I think."
		),
		'golden_berry': _PlantData.new(
			'golden_berry',
			'Golden Berry',
			30*60,
			"This green bush has numerous berries that shine a bright golden color. I wouldn’t go eating the berries though, some say they are actually made of gold, but it hasn’t been proven yet. The Golden Berries can be used in the Potion of Midas for its golden properties, but it is also a component of the highly valuable Potion of Romance. The Golden Berry loves the bright sun that makes its berries shine, and refuses to grow in the dim moonlight."
		),
		'star_flower': _PlantData.new(
			'star_flower',
			'Star Flower',
			45*60,
			"The Star Flower grows a purple stalk and eventually grows a big star shaped flower on its top. This flower glows bright like a star in the midnight. The flower only has one use that I have found thus far - the elusive Potion of the Stars. The Star Flower only grows when it can see all it’s friends up in the night sky. When the flower blooms, it will face towards the brightest star it can see. Growth time for this flower is a whole 30 minutes."
		),
		'jade_sunflower': _PlantData.new(
			'jade_sunflower',
			'Jade Sunflower',
			60*60,
			"The Jade Sunflower is not your regular kind of sunflower. Instead of the usual yellow shade, it is instead bright emerald. It only grows in the day, where it can feel the bright sun shining down upon it. It is used in the Potion of Sunlight and the Potion of Midnight for it’s mystifying time warping abilities. The Jade Sunflower takes about an hour to fully grow. For flowers like this, I recommend using some strong growth potions."
		),
		'crystal_stalk': _PlantData.new(
			'crystal_stalk',
			'Crystal Stalk',
			2*60*60,
			"The famous Crystal Stalk. The hardest plant to grow of all the plants I have ever come across. This makes it extremely valuable, but it also means that I haven’t had a chance to really discover new potions it can be used in. The stalk grows has a slow growth rate of 2 hours. Luckily it grows both day and night. I was surprised to discover it grows a big, glowing, yellow eye in its final stage. The eyeball even follows my movement. Quite unsettling."
		)
	}

	inventory = [
		_InventorySeed.new('hydroangea',
			0,
			'',
			-1
		), _InventorySeed.new('cool_beans',
			10,
			''
		), _InventorySeed.new('fire_flower',
			10,
			''
		), _InventorySeed.new('mandrake',
			100,
			''
		), _InventorySeed.new('lucky_clover',
			500,
			''
		), _InventorySeed.new('nightshade',
			2500,
			''
		), _InventorySeed.new('golden_berry',
			10000,
			''
		), _InventorySeed.new('star_flower',
			25000,
			''
		), _InventorySeed.new('jade_sunflower',
			100000,
			''
		), _InventorySeed.new('crystal_stalk',
			1000000,
			''
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
			The Potion of Hydration is the simplest of all potions. This is the first one any alchemist learns. The potion is used for many things such as staying hydrated on work. It's also used to water crop fields at farms. I usually begin all my days by drinking one of these. It tastes way better than normal water.
			""",
			[1,1,2]
		), _InventoryPotion.new('ice',
			'Ice',
			['cool_beans', 'cool_beans', 'cool_beans', 'cool_beans', 'cool_beans'],
			'Freezes everything it touches',
			"""
			This potion will freeze anything it touches. While it is quite easy to make this potion, it’s effects can be quite destructive. Be careful to not accidentally freeze your fingers off! It’s handy to have a couple of these on you since it’s used to produce Frost. I shouldn’t ramble about Frost here though. I did make a dedicated page about that topic.
			""",
			[1,1,1,1,2]
		), _InventoryPotion.new('flames',
			'Flames',
			['fire_flower', 'fire_flower', 'fire_flower', 'fire_flower', 'fire_flower'],
			'Burns everything it touches',
			"""
			This is a rather basic potion but it's quite dangerous. This Potion of Flames can burn anything to ash. Though that is sometimes a good thing since ash can be used in potions. I’ve gotten my hand burned multiple times by using this potion. So, please take care!
			""",
			[1,1,1,1,2]
		), _InventoryPotion.new('midas',
			'Midas',
			['golden_berry', 'golden_berry', 'golden_berry', 'golden_berry', 'golden_berry'],
			'Turns everything it touches to gold',
			"""
			This innocent looking potion will turn anything it touches into gold. Now, this might seem like a good thing, but you will want to be really careful with it. Gold is quite fragile and the things that have been turned will therefore quickly crumble into a fine gold powder, also called Aurum Dust. That powder can be used for potion production.
			""",
			[1]
		), _InventoryPotion.new('stars',
			'the Stars',
			['star_flower', 'star_flower', 'star_flower', 'lucky_clover', 'aurum_dust'],
			'Summons the power of the stars unto a plant',
			"""
			This potion seems to summon the power of the stars. Using it on a plant will make it imbued with star power and drop a purple powder called stardust, which can be used in potions. I must say, It’s not the easiest potion to pull off.
			""",
			[1]
		), _InventoryPotion.new('midnight',
			'Midnight',
			['cool_beans', 'frost', 'frost', 'jade_sunflower', 'jade_sunflower'],
			'Warps time to nearest nighttime',
			"""
			This inky black potion is able to change the time. If you look closely at it you can see tiny star-like objects in it, resembling a nighttime sky. It's quite a difficult potion to pull off since it contains the rare Jade Sunflower. If this potion is used, it will warp time towards the nearest nighttime. Handle with care. Time travel isn’t for beginners. 
			""",
			[1,1,1,1,1,1,2]
		), _InventoryPotion.new('sunlight',
			'Sunlight',
			['fire_flower', 'ash', 'ash', 'jade_sunflower', 'jade_sunflower'],
			'Warps time to nearest daytime.',
			"""
			This bright and sunny potion is able to change the time. It's quite a difficult potion to pull off since it contains the rare Jade Sunflower. If this potion is used, it will warp time into the nearest daytime. Handle with care. Time travel isn’t for beginners.
			""",
			[1,1,1,1,1,1,2]
		), _InventoryPotion.new('growth',
			'Growth',
			['mandrake', 'weeds', 'weeds', 'weeds', 'hydroangea'],
			'Makes plants grow much faster',
			"""
			A simple potion that makes plants grow faster. Alchemists have tried to find a good use for those damn weeds and it turns out they can make other plants grow faster. This effective and simple potion can make take up to 50% less time for a plant to mature. No mandrakes were harmed in the production of this potion. Actually, now that I think about it, they probably were. Sorry, little Mandrakes!
			""",
			[1,1,1,2,2]
		), _InventoryPotion.new('growth2',
			'Growth II',
			['mandrake', 'mandrake', 'mandrake', 'weeds', 'hydroangea'],
			'A much more potent growth potion',
			"""
			This potion works just like the original Potion of Growth. This is just stronger. Alchemist found out if you use less weeds and more mandrakes, the plants take up to 75% less time for a plant to mature. Just for the record, this is my favorite potion I’ve ever had the pleasure of using. It’s probably because I’m so impatient though.
			""",
			[1]
		), _InventoryPotion.new('romance',
			'Romance',
			['golden_berry', 'star_dust', 'star_dust', 'aurum_dust', 'nightshade'],
			'Makes people fall in love - highly valuable',
			"""
			To put it simply, The Potion of Romance makes people fall in love. Though it might sound useful, it has quite some ethical problems. Even though it has been banned in many places, it is still highly valuable. While the Nightshade might seem like a bad idea in a potion meant for not killing someone, the magical properties of the Star dust seems to nullify any ill effects of the Nightshade. I wonder, if you drank this and looked in the mirror, would you fall in love with yourself?
			""",
			[1]
		), _InventoryPotion.new('healing',
			'Healing',
			['mandrake', 'ash', 'hydroangea', 'hydroangea', 'hydroangea'],
			'Heals sick plants',
			"""
			Now, this is a very important potion. It uses the magical properties of the mandrake to heal plants that have become ill. While plants getting sick is generally quite rare, it is always a good idea to have a couple of these potions on hand. I found out these also work on humans. I had a cold for a week and I got so tired of it I just downed one of these. It worked!
			""",
			[1]
		), _InventoryPotion.new('poison',
			'Poison',
			['nightshade', 'nightshade', 'nightshade', 'nightshade', 'hydroangea'],
			'Highly poisonous… duh',
			"""
			This purple potion with a green mist is extremely dangerous. Dangerous as in deadly. The potion is brewed on the poisonous Nightshade flower. The recipe has even been officially changed so it contains less Nightshade. It's now watered down with a bit of Hydroangea. Handle with extreme caution.
			""",
			[1]
		), _InventoryPotion.new('gardening',
			'Gardening',
			['weeds', 'weeds', 'weeds', 'hydroangea', 'hydroangea'],
			'Feeds weeds so they don’t disturb plant growth',
			"""
			I discovered this potion one morning when I discovered some weeds in my Potion of Hydration. Turns out this potion is capable of feeding nearby weeds so they leave other plants alone. That means that if you use his on a field, the weeds won’t disturb your plant. The weeds will return though. And they will get annoying again.
			""",
			[2,2,3]
		), _InventoryPotion.new('wealth',
			'Wealth',
			['crystal_stalk', 'crystal_stalk', 'crystal_stalk', 'star_dust', 'aurum_dust'],
			'Drops a huge amount of gems',
			"""
			This purple concoction is definitely one of the weirder ones. Instead of being used on a plant, you simply pour it out wherever you would like, and as the liquid comes into contact with air, it turns into a large sum of gems. It mostly consists of the very valuable Crystal Stalk. Warning: Might destroy capitalism if brewed in large quantities.
			""",
			[1],
			-1
		), _InventoryPotion.new('fortune',
			'Fortune',
			['lucky_clover', 'lucky_clover', 'lucky_clover', 'lucky_clover', 'frost'],
			'Increases luck',
			"""
			This very green looking potion is a peculiar one. It somehow makes whoever used it more lucky. I don’t even want to begin to get into how that could possibly work. Like, is luck even a real thing? I’ve had a lot of fun with these myself. One day I used so many that I made more gems than if I had to use a Potion of Wealth!
			""",
			[1,1,1,1,2]
		)
	]

	achievements = [
		_AchievementDiff.new('diff_plants', 'Harvest %s different plants', [2, 5, 10]),
		_AchievementTotal.new('total_brew', 'Brew a total of %s potions', [200, 2000, 5000]),
		_AchievementDiff.new('diff_brew', 'Brew %s different potions', [3, 7, 15]),
		_AchievementTotal.new('total_plants', 'Harvest a total of %s plants.', [500, 5000, 50000]),
		_AchievementTotal.new('total_potions', 'Use a total of %s potions', [100, 1000, 2500]),
		_AchievementTotal.new('total_items', 'Gain a total of %s items', [3000, 30000, 300000]),
		_AchievementTotal.new('total_gems', 'Gain a total of %s gems', [1000, 100000, 1000000]),
		_AchievementTotal.new('total_seeds', 'Gain a total of %s seeds', [500, 5000, 50000]),
		_AchievementDiff.new('diff_pages', 'Collect all journal pages', [0, 0, 30], true),
	]

	unlocked_journal_pages = ['index']
	has_new_journal_pages = false

	time = 9*60

	luck = 0.0

	play_time = 0

	plant_current_click_action = null

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
			var average_yield = 0.0
			for y in potion.yields:
				average_yield += y
			average_yield = average_yield / potion.yields.size()
			
			sell_price /= average_yield
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
	var hidden = true
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
	var yields

	func _init(id, name, ingredients, description, long_description, yields, sell_price_overwrite=null, default_count=0):
		self.type = 'potion'
		self.count = default_count
		self.id = id
		self.short_name = name
		self.name = 'Potion of %s' % name
		self.ingredients = ingredients
		self.yields = yields
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
var has_new_journal_pages = false

var time = 0.0

var player_name = ''

var luck = 0.0

var play_time = 0

var version = ''

var day_duration = 24*60

var plant_current_click_action = null
