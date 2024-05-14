extends Node


func _ready():
	($InteractableComponent as Interactable).interact.connect(on_interact)


func on_interact():
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
