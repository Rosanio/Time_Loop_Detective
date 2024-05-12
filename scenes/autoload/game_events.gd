extends Node

signal interactable_area_entered(interactable: Interactable)
signal interactable_area_exited(interactable: Interactable)

func emit_interactable_area_entered(interactable: Interactable):
	interactable_area_entered.emit(interactable)


func emit_interactable_area_exited(interactable: Interactable):
	interactable_area_exited.emit(interactable)
