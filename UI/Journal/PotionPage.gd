extends Control

func _ready():
	pass
	
func init(title, description, res):
	if title.begins_with('the '):
		$PotionOf.text = 'Potion of the'
		$Title.text = title.trim_prefix('the ')
	else:
		$Title.text = title
	$Description.text = description
	$Preview.texture = Utils.get_scaled_res(res, 128, 128)
