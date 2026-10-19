extends Camera2D

@export var player: Node2D
@export var roomPixelSize: int = 272
@export var transitionDuration: float = 0.25

var currentRoom: Vector2i
var activeTween: Tween

func _ready():
	enabled = true

	currentRoom = getPlayerRoom()

	global_position = getRoomCenter(currentRoom)


func getPlayerRoom():
	return Vector2i(roundi(player.global_position.x / roomPixelSize), roundi(player.global_position.y / roomPixelSize))

func getRoomCenter(room: Vector2i):
	return Vector2(room.x * roomPixelSize, room.y * roomPixelSize)

func _process(_delta):
	if not is_instance_valid(player):
		return

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

	activeTween.tween_property(self, "global_position", getRoomCenter(room), transitionDuration)
