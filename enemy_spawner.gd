extends Area2D

@export var enemy: PackedScene

func _ready():
	pass

func spawnEnemies():
	var enemyInstance = enemy.instantiate()
	enemyInstance.position = position
	get_parent().add_child(enemyInstance)