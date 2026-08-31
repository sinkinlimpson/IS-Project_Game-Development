extends Area2D

@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.RIGHT

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		body.takeDamage(1)
		queue_free()
