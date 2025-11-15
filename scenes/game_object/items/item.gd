extends Area2D
class_name Item

@export var item_data: ItemData

@onready var interactable: Interactable = $InteractableComponent

func _ready():
	interactable.interact.connect(on_interact)
	ItemsRegistry.register_item(item_data.id, self)


func on_interact(interactor: Node):
	if interactor is Player:
		interactor.inventory.add_item(self)
	elif interactor is Npc:
		interactor.handle_item_interact(self)
