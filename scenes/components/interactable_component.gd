# This component must be the direct descendant of an Area2D to work properly.

extends Node2D
class_name Interactable

signal interact

@export var interact_texture: Texture2D

@onready var area: Area2D = get_parent()
@onready var active_ui_layer: CanvasLayer = $"/root/Main/ActiveUILayer"

var texture_rect: TextureRect
var active: bool = false


func set_active():
	active = true
	texture_rect = TextureRect.new()
	texture_rect.position = get_global_transform_with_canvas().get_origin()
	texture_rect.scale = Vector2(2, 2)
	texture_rect.texture = interact_texture
	active_ui_layer.add_child(texture_rect)


func set_inactive():
	active = false
	active_ui_layer.remove_child(texture_rect)
	texture_rect = null


func emit_interact(interactor: Node):
	interact.emit(interactor)
