extends Camera2D

@export var player: Node2D
@export var roomPixelSize:int = 272
@export var transitionDuration: float = 0.35

var currentRoomPosition = Vector2i(-999, -999)
var currentRoomRect: Rect2
var activeTween: Tween

func _ready():
	anchor_mode =  Camera2D.ANCHOR_MODE_DRAG_CENTER
	enabled = true

	await get_tree().process_frame
	snapToPlayer()

func _process(delta):
	if not is_instance_valid(player):
		return
	
	var playerRect = getPlayerRect()

	if not currentRoomRect.intersects(playerRect):
		updateCurrentRoom()

func getPlayerRect():
	var collisionShape = player.get_node("CollisionShape2D")
	if collisionShape and collisionShape.shape:
		var shape = collisionShape.shape.get_rect()

		return Rect2(player.global_position + shape.position, shape.size)

func updateCurrentRoom():
	var gridX = floori(player.global_position.x / roomPixelSize)
	var gridY = floori(player.global_position.y / roomPixelSize)
	currentRoomPosition = Vector2i(gridX, gridY)

	var roomTopLeft = Vector2(currentRoomPosition.x * roomPixelSize, currentRoomPosition.y * roomPixelSize)
	currentRoomRect = Rect2(roomTopLeft, Vector2(roomPixelSize, roomPixelSize))

	var roomCenter = roomTopLeft + Vector2(roomPixelSize / 2, roomPixelSize / 2)

	if activeTween and activeTween.is_running():
		activeTween.kill()
	
	activeTween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	activeTween.tween_property(self, "global_position", roomCenter, transitionDuration)

func snapToPlayer():
	if not is_instance_valid(player):
		return
	
	var gridX = floori(player.global_position.x / roomPixelSize)
	var gridY = floori(player.global_position.y / roomPixelSize)

	var roomTopLeft = Vector2(gridX * roomPixelSize, gridY * roomPixelSize)
	currentRoomRect = Rect2(roomTopLeft, Vector2(roomPixelSize, roomPixelSize))

	global_position = roomTopLeft + Vector2(roomPixelSize / 2, roomPixelSize / 2)