extends CharacterBody2D

const MAX_SPEED = 100.0
const ACCELERATION = 1200.0
const FRICTION = 900.0

@export var health = 5

enum States {IDLE, WALKING, ATTACKING, ROLLING, DEAD}

var state: States = States.IDLE
var lookDirection = "down"
var invincible = false

func _ready():
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	# get input
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# movement states
	match state:
		States.IDLE, States.WALKING:
			if direction != Vector2.ZERO:
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				state = States.WALKING
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
				state = States.IDLE
			
			handleDirection(direction)

			if Input.is_action_just_pressed("attack"):
				attack()
			elif Input.is_action_just_pressed("dodgeRoll"):
				dodgeRoll(direction, lookDirection)

		States.ROLLING:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * 0.5 * delta)

		States.ATTACKING:
			velocity = Vector2.ZERO

	move_and_slide()
	handleAnim()

func handleDirection(direction):
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			lookDirection = "right"
		else:
			lookDirection = "left"
	elif abs(direction.y) > abs(direction.x):
		if direction.y > 0:
			lookDirection = "down"
		else:
			lookDirection = "up"

func handleAnim():
	var animToPlay = ""

	match state:
		States.IDLE, States.WALKING:
			animToPlay = lookDirection
		States.ATTACKING:
			animToPlay = "attack_" + lookDirection
		States.ROLLING:
			animToPlay = "roll"

	if $AnimationPlayer.current_animation != animToPlay:
		$AnimationPlayer.play(animToPlay)

func attack():
	state = States.ATTACKING

func dodgeRoll(direction, lookDirection):
	state = States.ROLLING
	
	if direction == Vector2.ZERO:
		match lookDirection:
			"up":
				velocity = Vector2(0, -MAX_SPEED * 2.5)
			"down":
				velocity = Vector2(0, MAX_SPEED * 2.5)
			"left":
				velocity = Vector2(-MAX_SPEED * 2.5, 0)
			"right":
				velocity = Vector2(MAX_SPEED * 2.5, 0)
	else:
		velocity = direction.normalized() * MAX_SPEED * 2.5
	flicker(4)

func takeDamage(amount):
	health -= amount
	print("damage taken")
	flicker(10)
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

	print("flicker finished")

func _on_animation_finished(anim_name: String):
	if state == States.ATTACKING or state == States.ROLLING:
		state = States.IDLE

func die():
	queue_free()
