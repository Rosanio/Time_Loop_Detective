extends Node
class_name Item

@export var interactable: Interactable

var item_data: ItemData

func _ready():
	interactable.interact.connect(on_interact)
	# Wait for item_data to be initialized
	await get_tree().create_timer(0.01).timeout
	ItemsRegistry.register_item(item_data.id, get_parent())


func on_interact(interactor: Node):
	if interactor is Player:
		interactor.inventory.add_item(self)
