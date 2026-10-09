extends Node2D

@export var hasNorth: bool = false
@export var hasSouth: bool = false
@export var hasEast: bool = false
@export var hasWest: bool = false

@export var door: PackedScene = preload("res://door.tscn")
@export var debug_visuals: bool = true

@export var hasEnemies: bool = false
@export var enemyCount: int = 0


var doorCoordinates = {
	"north": Vector2(8, -120),
	"south": Vector2(8, 136),
	"east": Vector2(136, 8),
	"west": Vector2(-120, 8)
}

func _ready():
	print("[Room Debug] Initializing room: ", name)
	print("  -> Flags | N:", hasNorth, " S:", hasSouth, " E:", hasEast, " W:", hasWest)

	for child in get_children():
		if child.scene_file_path == "res://enemy_spawner.tscn":
			hasEnemies = true
			enemyCount += 1

	if not door:
		push_error("[Room Debug] ERROR: door.tscn scene is NULL or failed to load!")
		return

	if hasNorth:
		spawnDoor("north", doorCoordinates["north"], 0.0)
	if hasSouth:
		spawnDoor("south", doorCoordinates["south"], 0.0)
	if hasEast:
		spawnDoor("east", doorCoordinates["east"], PI/2)
	if hasWest:
		spawnDoor("west", doorCoordinates["west"], -PI/2)
	
	spawnEnemies()

func spawnEnemies():
	if hasEnemies:
		for child in get_children():
			if child.scene_file_path == "res://enemy_spawner.tscn":
				child.spawnEnemies()
	else:
		print("[Room Debug] No enemies to spawn in this room.")

func spawnDoor(dir_name: String, pos: Vector2, rot: float):
	var doorInstance = door.instantiate()
	doorInstance.position = pos
	doorInstance.rotation = rot
	add_child(doorInstance)
	print("  -> Spawned ", dir_name, " door at local pos: ", pos, " (Global: ", doorInstance.global_position, ")")

	if debug_visuals:
		create_debug_marker(pos)

func create_debug_marker(pos: Vector2):
	var marker = ColorRect.new()
	marker.color = Color.RED
	marker.size = Vector2(8, 8)
	marker.position = pos - Vector2(4, 4)