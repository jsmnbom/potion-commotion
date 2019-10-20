extends Control

func _ready():
	pass
	
func init(title, description, res):
	$Title.text = title
	$Description.text = description
	$Preview.texture = Utils.get_scaled_res(res, 128*5, 256*2)
	$AnimationPlayer.play('PlantPreview')
