extends Node2D

var baskets = {}
var Basket = preload('res://src/Basket/Basket.tscn')

var baskets_to_add = []

func _ready():
	Events.connect('inventory_updated', self, '_on_inventory_updated')

func _on_inventory_updated():
	# Potion shelves
	for child in $ShelvesTop.get_children():
		child.queue_free()
	for child in $ShelvesBottom.get_children():
		child.queue_free()
	var i = 0
	for potion_id in Data.inventory_by_id['potion']:
		var potion = Data.inventory_by_id['potion'][potion_id]
		if potion.count > 0:
			for j in range(2 if potion.count >= 5 else 1):
				var sprite = Sprite.new()
				sprite.texture = potion.get_scaled_res(64,64)
				sprite.position = Vector2(36+56*j+128*(i%8),8)
				
				($ShelvesTop if i < 8 else $ShelvesBottom).add_child(sprite)
		i += 1;
		
	# Baskets
	for resource_id in Data.inventory_by_id['resource']:
		var resource = Data.inventory_by_id['resource'][resource_id]
		if not resource_id in baskets and not resource in baskets_to_add and resource.seen:
			baskets_to_add.append(resource)
		elif resource_id in baskets:
			var basket = baskets[resource_id]
			basket.set_amount(_amount(resource.count))

func _amount(count):
	if count < 1:
		return 0
	return range_lerp(clamp(count, 0,100), 0, 100, 1, 8)

func _physics_process(delta):
	for resource in baskets_to_add:
		var basket = Basket.instance()
		basket.init(resource)
		basket.set_amount(_amount(resource.count))
		baskets[resource.id] = basket
		
		$Baskets.add_child(basket)
	baskets_to_add.clear()
	
			
