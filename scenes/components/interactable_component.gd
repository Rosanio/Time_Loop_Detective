extends Node
class_name Interactable

signal interact

@export var area: Area2D
@onready var texture_rect: TextureRect = $TextureRect
var active: bool = false


func _ready():
	area.area_entered.connect(on_area_entered)
	area.area_exited.connect(on_area_exited)


func on_area_entered(_other_area: Area2D):
	GameEvents.emit_interactable_area_entered(self)


func on_area_exited(_other_area: Area2D):
	GameEvents.emit_interactable_area_exited(self)


func set_active():
	active = true
	texture_rect.visible = true


func set_inactive():
	active = false
	texture_rect.visible = false


func emit_interact(player: CharacterBody2D):
	interact.emit(player)
