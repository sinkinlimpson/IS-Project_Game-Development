extends CharacterBody2D


const MAX_SPEED = 100.0
const ACCELERATION = 1200.0
const FRICTION = 900.0

@export var health = 5

enum States {IDLE, WALKING, ATTACKING, ROLLING, DEAD}

var state: States = States.IDLE

func _physics_process(delta):

	#handle player input

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# handle movement

	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		state = States.WALKING
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

		state = States.IDLE

	move_and_slide()
	handleAnim(direction)

func handleAnim(direction):
	match state:
		States.WALKING:
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					$AnimationPlayer.play("right")
				else:
					$AnimationPlayer.play("left")
			elif abs(direction.y) > abs(direction.x):
				if direction.y > 0:
					$AnimationPlayer.play("down")
				else:
					$AnimationPlayer.play("up")

func takeDamage(amount):
	health -= amount

	print("damage taken")

	if health <= 0:
		die()

func die():
	queue_free()
	
