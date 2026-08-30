extends CharacterBody2D

@export var health = 5

func _process(delta):
	pass

func takeDamage(amount):
	health -= amount

	print(str(amount) + " damage taken!")

	if health <= 0:
		die()

func die():
	queue_free()