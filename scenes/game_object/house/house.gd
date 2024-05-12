extends StaticBody2D


func _ready():
	($InteractableComponent as Interactable).interact.connect(on_interact)


func on_interact():
	print("House interacted with")
