extends Node2D


func _ready():
	pass

func _process(delta):
	look_at(get_global_mouse_position())
