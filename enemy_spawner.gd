extends Area2D

@export var enemy: PackedScene

func _ready():
	pass

func spawnEnemies():
	if enemy == null:
		return

	var enemyInstance = enemy.instantiate()
	enemyInstance.position = position
	get_parent().add_child(enemyInstance)
