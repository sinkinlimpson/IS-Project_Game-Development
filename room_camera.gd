
extends Camera2D

@export var player: Node2D

@export var roomWidth: int = 256
@export var roomHeight: int = 192

@export var transitionDuration: float = 0.25

@export var playerHealth: RichTextLabel

var currentRoom: Vector2i
var activeTween: Tween


func _ready():
	enabled = true

	if not is_instance_valid(player):
		push_error("Camera has no player assigned!")
		return

	currentRoom = getPlayerRoom()
	global_position = getRoomCenter(currentRoom)


func getPlayerRoom() -> Vector2i:
	return Vector2i(
		floori(player.global_position.x / roomWidth),
		floori(player.global_position.y / roomHeight)
	)


func getRoomCenter(room: Vector2i) -> Vector2:
	return Vector2(
		room.x * roomWidth + roomWidth / 2.0,
		room.y * roomHeight + roomHeight / 2.0
	)


func _process(_delta):
	if not is_instance_valid(player):
		return

	if is_instance_valid(playerHealth):
		playerHealth.text = "Health: " + str(player.health)

	var playerRoom = getPlayerRoom()

	if playerRoom == currentRoom:
		return

	currentRoom = playerRoom
	transitionToRoom(currentRoom)


func transitionToRoom(room: Vector2i):
	if activeTween and activeTween.is_running():
		activeTween.kill()

	activeTween = create_tween()

	activeTween.set_trans(Tween.TRANS_QUAD)
	activeTween.set_ease(Tween.EASE_OUT)

	activeTween.tween_property(
		self,
		"global_position",
		getRoomCenter(room),
		transitionDuration
	)


func snapToPlayer():
	if not is_instance_valid(player):
		return

	if activeTween and activeTween.is_running():
		activeTween.kill()

	currentRoom = getPlayerRoom()
	global_position = getRoomCenter(currentRoom)
