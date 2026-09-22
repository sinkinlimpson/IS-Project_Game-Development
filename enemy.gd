extends CharacterBody2D

@export var health = 5
@export var bulletScene: PackedScene

@export var shootCooldown = 2.0

var player: Node2D

var invincible = false

var knockbackStrength = 5.0
var knockbackFriction = 500.0

func _ready():
	$ShootTimer.wait_time = shootCooldown
	$ShootTimer.start()

func _process(delta):
	if velocity != Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, knockbackFriction * delta)

	move_and_slide()

func takeDamage(amount, fromDirection: Vector2):
	if !invincible:
		health -= amount
		flicker(4)

		if fromDirection != Vector2.ZERO:
			var knockbackDirection = (global_position - fromDirection).normalized()
			velocity = knockbackDirection * 200
	if health <= 0:
		die()

func flicker(amt):
	invincible = true

	var tween = create_tween().set_loops(amt)
	tween.tween_property($Sprite2D, "modulate:a", 0.2, 0.05)
	tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.05)

	tween.connect("finished", Callable(self, "_on_flicker_finished"))

func _on_flicker_finished():
	invincible = false

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
