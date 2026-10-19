extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("debug_toggle"):
		$RoomCamera.enabled = not $RoomCamera.enabled
		$DebugCamera.enabled = not $DebugCamera.enabled
