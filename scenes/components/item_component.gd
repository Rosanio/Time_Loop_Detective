extends Node
class_name Item

@export var interactable: Interactable
@export var item_data: ItemData

func _ready():
	interactable.interact.connect(on_interact)


func on_interact(player: CharacterBody2D):
	player.inventory.add_item(self)
