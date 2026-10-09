extends Node2D

@export var rooms: Array[PackedScene] = []

@export var camera: Camera2D
@export var player: Node2D

@export var gridWidth: int = 17
@export var gridHeight: int = 17
@export var maxRooms: int = 12
@export var roomPixelSize: int = 272

var dungeonGrid = {}
var roomInstances = {}

var bossRoomPosition: Vector2i = Vector2i(-1, -1)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		generate()

func generate():
	dungeonGrid.clear()

	for room in roomInstances.values():
		room.queue_free()

	roomInstances.clear()
	randomize()
	generateDungeonLayout()
	ensureStraggler()
	selectBossRoom()
	spawnDungeonRooms()

	if is_instance_valid(camera) and camera.has_method("snapToPlayer"):
		camera.snapToPlayer()

func _ready():
	for x in range(1, 16):
		rooms.append(load("res://rooms/room_" + str(x) + ".tscn"))
	for x in range(1, 5):
		rooms.append(load("res://rooms/boss_" + str(x) + ".tscn"))
	
	generate()

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

func getDeadEndPositions():
	var startPos = Vector2i(gridWidth / 2, gridHeight / 2)
	var deadEnds = []

	for pos in dungeonGrid.keys():
		if pos != startPos and countNeighors(pos) == 1:
			deadEnds.append(pos)
	
	return deadEnds

func countNeighors(pos: Vector2i) -> int:
	var count = 0
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	for dir in directions:
		if dungeonGrid.has(pos + dir):
			count += 1
	
	return count

func ensureStraggler():
	var deadEnds = getDeadEndPositions()

	if deadEnds.is_empty():
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		var keys = dungeonGrid.keys()
		keys.shuffle()

		for pos in keys:
			for dir in directions:
				var nextPos = pos + dir
				if nextPos.x >= 0 and nextPos.x < gridWidth and nextPos.y >= 0 and nextPos.y < gridHeight and not dungeonGrid.has(nextPos):
					if not dungeonGrid.has(nextPos) and countNeighors(nextPos) == 1:
						dungeonGrid[nextPos] = true
						return

func selectBossRoom():
	var startPos = Vector2i(gridWidth / 2, gridHeight / 2)
	var deadEnds = getDeadEndPositions()

	if deadEnds.is_empty():
		return
	
	var furthestPos = deadEnds[0]
	var maxDistance = startPos.distance_squared_to(furthestPos)

	for pos in deadEnds:
		var distance = startPos.distance_squared_to(pos)
		if distance > maxDistance:
			maxDistance = distance
			furthestPos = pos
	
	bossRoomPosition = furthestPos

func spawnDungeonRooms():
	for pos in dungeonGrid.keys():
		var requiresN = dungeonGrid.has(pos + Vector2i.UP)
		var requiresS = dungeonGrid.has(pos + Vector2i.DOWN)
		var requiresW = dungeonGrid.has(pos + Vector2i.LEFT)
		var requiresE = dungeonGrid.has(pos + Vector2i.RIGHT)

		var isBossLocation = pos == bossRoomPosition
		var validRoomScene = findValidRoom(requiresN, requiresS, requiresE, requiresW, isBossLocation)
		
		if validRoomScene:
			var roomInstance = validRoomScene.instantiate()
			roomInstance.position = Vector2(pos.x * roomPixelSize, pos.y * roomPixelSize)
			add_child(roomInstance)
			roomInstances[pos] = roomInstance

func findValidRoom(n: bool, s: bool, e: bool, w: bool, isBossLocation: bool = false) -> PackedScene:
	var matchingRooms: Array[PackedScene] = []

	var shuffled = rooms.duplicate()
	shuffled.shuffle()

	for prefab in shuffled:
		var isBossRoom = prefab.resource_path.begins_with("res://rooms/boss_")

		if isBossLocation != isBossRoom:
			continue

		var tempRoom = prefab.instantiate()

		var rNorth = tempRoom.get("hasNorth") if "hasNorth" in tempRoom else false
		var rSouth = tempRoom.get("hasSouth") if "hasSouth" in tempRoom else false
		var rEast = tempRoom.get("hasEast") if "hasEast" in tempRoom else false
		var rWest = tempRoom.get("hasWest") if "hasWest" in tempRoom else false

		tempRoom.queue_free()

		if rNorth == n and rSouth == s and rEast == e and rWest == w:
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
