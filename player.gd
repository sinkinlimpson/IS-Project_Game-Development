extends CharacterBody2D


const MAX_SPEED = 200.0
const ACCELERATION = 1400.0
const FRICTION = 900.0

@export var health = 5

var flip = false

func _physics_process(delta):

	#handle player input

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# handle movement

	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()

	# handle flipping
	flip = get_global_mouse_position().x < global_position.x

	$Sprite2D.flip_h = flip

func takeDamage(amount):
	health -= amount

	print("damage taken")

	if health <= 0:
		die()

func die():
	queue_free()
	
