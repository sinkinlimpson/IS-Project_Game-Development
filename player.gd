extends CharacterBody2D


const MAX_SPEED = 100.0
const ACCELERATION = 1200.0
const FRICTION = 900.0

@export var health = 5

func _physics_process(delta):

	#handle player input

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# handle movement

	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()

func takeDamage(amount):
	health -= amount

	print("damage taken")

	if health <= 0:
		die()

func die():
	queue_free()
	
