extends Node2D

@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.RIGHT

func _process(delta):
	position += direction * speed * delta
