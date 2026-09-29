extends Node2D

@export var rooms: Array[PackedScene] = [
	preload("res://rooms/room_1.tscn"),
	preload("res://rooms/room_2.tscn"),
	preload("res://rooms/room_3.tscn"),
	preload("res://rooms/room_4.tscn"),
	preload("res://rooms/room_5.tscn"),
	preload("res://rooms/room_6.tscn"),
	preload("res://rooms/room_7.tscn"),
	preload("res://rooms/room_8.tscn"),
	preload("res://rooms/room_9.tscn"),
	preload("res://rooms/room_10.tscn"),
	preload("res://rooms/room_11.tscn"),
	preload("res://rooms/room_12.tscn"),
	preload("res://rooms/room_13.tscn")
]

@export var gridWidth: int = 17
@export var gridHeight: int = 17
@export var maxRooms: int = 12
@export var roomPixelSize: int = 272

var dungeonGrid = {}
var roomInstances = {}

func _ready():
	randomize()
	generateDungeonLayout()
	spawnDungeonRooms()
	printDungeonLayout() # Print ASCII map to output console

func generateDungeonLayout():
	var currentPos = Vector2i(gridWidth / 2, gridHeight / 2)
	dungeonGrid[currentPos] = true

	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	while dungeonGrid.size() < maxRooms:
		var branchPoints = dungeonGrid.keys()
		var randomBranch = branchPoints[randi() % branchPoints.size()]
		var randomDirection = directions[randi() % directions.size()]

		var nextPos = randomBranch + randomDirection

		if nextPos.x >= 0 and nextPos.x < gridWidth and nextPos.y >= 0 and nextPos.y < gridHeight and not dungeonGrid.has(nextPos):
			dungeonGrid[nextPos] = true

func spawnDungeonRooms():
	for pos in dungeonGrid.keys():
		var requiresN = dungeonGrid.has(pos + Vector2i.UP)
		var requiresS = dungeonGrid.has(pos + Vector2i.DOWN)
		var requiresW = dungeonGrid.has(pos + Vector2i.LEFT)
		var requiresE = dungeonGrid.has(pos + Vector2i.RIGHT)

		var validRoomScene = findValidRoom(requiresN, requiresS, requiresW, requiresE)
		
		if validRoomScene:
			var roomInstance = validRoomScene.instantiate()
			roomInstance.position = Vector2(pos.x * roomPixelSize, pos.y * roomPixelSize)
			add_child(roomInstance)
			roomInstances[pos] = roomInstance

func findValidRoom(n: bool, s: bool, e: bool, w: bool):
	var matchingRooms: Array[PackedScene] = []

	var shuffled = rooms.duplicate()
	shuffled.shuffle()

	for prefab in shuffled:
		var tempRoom = prefab.instantiate()

		var rNorth = tempRoom.get("hasNorth") if "hasNorth" in tempRoom else false
		var rSouth = tempRoom.get("hasSouth") if "hasSouth" in tempRoom else false
		var rEast = tempRoom.get("hasEast") if "hasEast" in tempRoom else false
		var rWest = tempRoom.get("hasWest") if "hasWest" in tempRoom else false

		tempRoom.queue_free()

		var matches = true
		if n and not rNorth: matches = false
		if s and not rSouth: matches = false
		if e and not rEast: matches = false
		if w and not rWest: matches = false

		if matches:
			return prefab

	return rooms[0]

func printDungeonLayout():
	print("\n--- DUNGEON LAYOUT ---")
	var startPos = Vector2i(gridWidth / 2, gridHeight / 2)
	
	for y in range(gridHeight):
		var rowStr = ""
		for x in range(gridWidth):
			var pos = Vector2i(x, y)
			if pos == startPos:
				rowStr += "[S]"
			elif dungeonGrid.has(pos):
				rowStr += "[R]"
			else:
				rowStr += " . "
		print(rowStr)
	print("Total Rooms Generated: ", dungeonGrid.size())
	print("---------------------\n")

func _process(delta):
	pass
