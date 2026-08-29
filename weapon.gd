extends Node2D

@export var bulletScene: PackedScene
var cooldown = 0.15

var flip = false

func _process(delta):
	look_at(get_global_mouse_position())

	if Input.is_action_pressed("mouse_click"):
		if cooldown <= 0:
			shoot()
			cooldown = 0.2
	cooldown -= delta

	# handle flipping

	flip = get_parent().flip

	if flip:
		scale.y = -1
	else:
		scale.y = 1

	# stay in place
	if flip:
		position = get_parent().get_node("HandLeft").position
	else:
		position = get_parent().get_node("HandRight").position

func shoot():
	var bullet = bulletScene.instantiate()
	bullet.position = $Muzzle.global_position
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	get_tree().root.add_child(bullet)
