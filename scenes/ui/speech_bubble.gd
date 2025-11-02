extends Control
class_name SpeechBubble

@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Label

var speaker: Node2D = null
var camera: Camera2D
var text: String = ""

func _ready():
	if not speaker:
		printerr("SpeechBubble instantiated without speaker")
		return

	camera = get_viewport().get_camera_2d()
	update_bubble_size()


func _process(_delta: float):
	var speaker_position = speaker.get_global_transform_with_canvas()
	global_position = speaker_position.get_origin() - Vector2(10, 40)

func update_bubble_size():
	# Wait for label to update its internal size
	await get_tree().process_frame
	var text_size = label.get_minimum_size()
	panel.custom_minimum_size.x = text_size.x
	panel.custom_minimum_size.y = text_size.y
