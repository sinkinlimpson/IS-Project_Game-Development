extends Camera2D

@export var ui: RichTextLabel

func _process(delta):
	ui.text = str(get_parent().get_parent().health) + " HP"
