extends Control

func _ready():
	$Continue/TextureRect.texture = Utils.get_scaled_res('res://assets/potions/hydration.png', 64, 64)
	$New/TextureRect.texture = Utils.get_scaled_res('res://assets/resources/fire_flower.png', 64, 64)
	$Options/TextureRect.texture = Utils.get_scaled_res('res://assets/ui/sickle.png', 64, 64)
	$Exit/TextureRect.texture = Utils.get_scaled_res('res://assets/resources/ash.png', 64, 64)