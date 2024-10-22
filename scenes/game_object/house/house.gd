extends StaticBody2D


@export var player: CharacterBody2D
@export var enterSpawnPoint: Node2D

func _ready():
	($InteractableComponent as Interactable).interact.connect(on_interact)


func on_interact():
	player.position = enterSpawnPoint.position
