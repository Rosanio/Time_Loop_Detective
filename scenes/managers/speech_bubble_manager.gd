extends Node

@export var active_ui_layer: CanvasLayer

var speech_bubble_scene

func _ready():
	speech_bubble_scene = preload("res://scenes/ui/speech_bubble.tscn")
	GameEvents.show_speech_bubble.connect(show_speech_bubble)


func show_speech_bubble(speaker: Node, text: String, duration: int = 3):
	var speech_bubble = speech_bubble_scene.instantiate()
	speech_bubble.speaker = speaker
	speech_bubble.text = text
	active_ui_layer.add_child(speech_bubble)
	await get_tree().create_timer(duration).timeout
	speech_bubble.queue_free()
	
