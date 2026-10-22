extends CharacterBody2D

@export var health = 5
@export var bulletScene: PackedScene

@export var shootEnemy: bool = false
@export var meleeEnemy: bool = false

# variables for shooting
@export_group("Shooting")

@export var shootCooldown = 2.0

#variables for melee
@export_group("Melee")

enum Behaviors {WANDER, CHASE, CHARGER}
enum States {MOVE, CHARGE_WINDUP, CHARGING, RECOVER}

@export var behavior: Behaviors = Behaviors.WANDER
@export var fourDirection = false

@export var moveSpeed = 60.0
@export var detectionRange = 250.0
@export var contactDamage = 1
@export var contactCooldown = 0.6

# first type
@export_subgroup("Wander")

@export var wanderTimeMin = 0.8
@export var wanderTimeMax = 2.0
@export var chaseChance = 0.4
@export var idleChance = 0.2

#second type
@export_subgroup("Charger")

@export var alignTolerance = 12.0
@export var chargeWindup = 0.5
@export var chargeMaxTime = 1.2
@export var chargeRecover = 1.0
@export var chargeSpeed = 220.0
@export var windupColor = Color(1.0, 0.45, 0.45)

var player: Node2D

var state = States.MOVE
var stateTimer = 0.0

var moveDir = Vector2.ZERO
var wanderTimer = 0.0
var chargeDir = Vector2.ZERO
var contactTimer = 0.0

var invincible = false

var knockbackStrength = 200.0
var knockbackFriction = 500.0
var knockbackVelocity = Vector2.ZERO

func _ready():
	if shootEnemy:
		$ShootTimer.wait_time = shootCooldown
		$ShootTimer.start()
	
	if meleeEnemy:
		pickWanderDirection()

func _physics_process(delta):
	updatePlayer()

	var desiredVelocity = Vector2.ZERO

	if meleeEnemy:
		desiredVelocity = meleeLogic(delta)

		checkContactDamage(delta)

	knockbackVelocity = knockbackVelocity.move_toward(Vector2.ZERO, knockbackFriction * delta)

	velocity = desiredVelocity + knockbackVelocity

	move_and_slide()

func meleeLogic(delta):
	match state:
		States.MOVE:
			if behavior == Behaviors.CHARGER:
				checkChargeTrigger()

				if state != States.MOVE:
					return Vector2.ZERO
				
			return moveVelocity(delta)
		States.CHARGE_WINDUP:
			stateTimer -= delta
			if stateTimer <= 0.0:
				$Sprite2D.self_modulate = Color.WHITE

				state = States.CHARGING
				stateTimer = chargeMaxTime

				return Vector2.ZERO
		States.CHARGING:
			stateTimer -= delta
			if stateTimer <= 0.0 or is_on_wall():
				state = States.RECOVER
				stateTimer = chargeRecover
				
				return Vector2.ZERO
			return chargeDir * chargeSpeed
		States.RECOVER:
			stateTimer -= delta
			if stateTimer <= 0.0:
				state = States.MOVE
				pickWanderDirection()
			return Vector2.ZERO
	return Vector2.ZERO

func moveVelocity(delta):
	if behavior == Behaviors.CHASE:
		if player != null and distanceToPlayer() <= detectionRange:
			var dir = (player.global_position - global_position).normalized()
			return _snap(dir) * moveSpeed
		return Vector2.ZERO
	
	wanderTimer -= delta
	if wanderTimer <= 0.0 or is_on_wall():
		pickWanderDirection()
	return moveDir * moveSpeed

func pickWanderDirection():
	wanderTimer = randf_range(wanderTimeMin, wanderTimeMax)
	var roll = randf()

	if roll < idleChance:
		moveDir = Vector2.ZERO
	elif player!= null and roll < idleChance + chaseChance and distanceToPlayer() <= detectionRange:
		moveDir = _snap((player.global_position - global_position).normalized())
	elif fourDirection:
		moveDir = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT].pick_random()
	else:
		moveDir = Vector2.from_angle(randf() * TAU)
	
func _snap(dir: Vector2):
	if not fourDirection or dir == Vector2.ZERO:
		return dir
	if abs(dir.x) > abs(dir.y):
		return Vector2(sign(dir.x), 0)
	return Vector2(0, sign(dir.y))

# stuff specifically for charger

func checkChargeTrigger():
	if player == null:
		return
	
	var offset = player.global_position - global_position

	if offset.length() > detectionRange:
		return
	
	if abs(offset.x) <= alignTolerance:
		chargeDir = Vector2(0, sign(offset.y))
	elif abs(offset.y) <= alignTolerance:
		chargeDir = Vector2(sign(offset.x), 0)
	else:
		return
	
	state = States.CHARGE_WINDUP
	stateTimer = chargeWindup
	$Sprite2D.self_modulate = windupColor

# damage stuff

func checkContactDamage(delta):
	contactTimer -= delta

	if contactTimer > 0.0:
		return
	
	var hitbox = $Hitbox
	if hitbox == null:
		return
	
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.takeDamage(contactDamage, global_position)
			contactTimer = contactCooldown
			break
				

func takeDamage(amount, fromDirection: Vector2):
	if !invincible:
		health -= amount
		flicker(4)

		if fromDirection != Vector2.ZERO:
			var knockbackDirection = (global_position - fromDirection).normalized()
			knockbackVelocity = knockbackDirection * knockbackStrength
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
	if get_parent() is Room:
		get_parent().enemyCount -= 1

	queue_free()

func _on_shoot_timer_timeout():
	if shootEnemy:
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

func distanceToPlayer():
	return global_position.distance_to(player.global_position)

func updatePlayer():
	if is_instance_valid(player):
		return
	
	player = get_tree().get_first_node_in_group("player")
