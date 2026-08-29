extends Node2D

@export var bulletScene: PackedScene

func _process(delta):
	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("mouse_click"):
		shoot()

func shoot():
	var bullet = bulletScene.instantiate()
	bullet.position = $Muzzle.global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	get_tree().root.add_child(bullet)
