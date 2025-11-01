# This component must be the direct descendant of an Area2D to work properly.

extends Node
class_name Interactable

signal interact

@onready var area: Area2D = get_parent()
@onready var texture_rect: TextureRect = $TextureRect
var active: bool = false


func set_active():
	active = true
	texture_rect.visible = true


func set_inactive():
	active = false
	texture_rect.visible = false


func emit_interact(interactor: Node):
	interact.emit(interactor)
