extends CharacterBody2D


const SPEED = 300.0

func _physics_process(delta):

	#handle player input

	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# handle movement

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	print(velocity)

	move_and_slide()
	