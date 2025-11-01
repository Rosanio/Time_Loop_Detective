extends Node
class_name Item

@export var interactable: Interactable

var item_data: ItemData

func _ready():
	interactable.interact.connect(on_interact)


func on_interact(interactor: Node):
	if interactor is Player:
		interactor.inventory.add_item(self)
