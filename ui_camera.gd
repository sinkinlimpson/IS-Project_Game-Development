extends Camera2D

@export var ui: RichTextLabel
@export var stateUI: RichTextLabel
@export var directionUI: RichTextLabel

func _process(delta):
	ui.text = str(get_parent().get_parent().health) + " HP"

	stateUI.text = str(get_parent().get_parent().state)

	directionUI.text = str(get_parent().get_parent().lookDirection)
