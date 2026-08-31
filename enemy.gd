extends CharacterBody2D

@export var health = 5
@export var bulletScene: PackedScene

@export var shootCooldown = 2.0

var player: Node2D

func _ready():
	$ShootTimer.wait_time = shootCooldown
	$ShootTimer.start()

func _process(delta):
	pass

func takeDamage(amount):
	health -= amount

	if health <= 0:
		die()

func die():
	queue_free()

func _on_shoot_timer_timeout():
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		player = players[0]
		shoot()
		$ShootTimer.start()

func shoot():
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()

	var bullet = bulletScene.instantiate()
	bullet.position = global_position
	bullet.direction = direction
	get_tree().root.add_child(bullet)
