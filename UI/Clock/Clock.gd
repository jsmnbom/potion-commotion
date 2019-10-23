extends Node2D

func _physics_process(delta):
	$ClockHand.rotation = (float(Data.time)/(24*60)) * TAU + PI