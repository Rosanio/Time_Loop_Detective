extends Node


@export var player: CharacterBody2D
@export var exitSpawnPoint: Node2D

func _ready():
	($InteractableComponent as Interactable).interact.connect(on_interact)


func on_interact():
	player.position = exitSpawnPoint.position
