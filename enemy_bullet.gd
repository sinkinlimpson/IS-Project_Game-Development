extends Area2D

@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.RIGHT
@export var damage: int = 1

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if !body.invincible == true:
			body.takeDamage(damage, global_position)
			queue_free()
	elif body.is_in_group("wall"):
		queue_free()
