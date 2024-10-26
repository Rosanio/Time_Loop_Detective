extends Node

signal interactable_area_entered(interactable: Interactable)
signal interactable_area_exited(interactable: Interactable)
signal show_dialog(dialog: String)

func emit_interactable_area_entered(interactable: Interactable):
	interactable_area_entered.emit(interactable)


func emit_interactable_area_exited(interactable: Interactable):
	interactable_area_exited.emit(interactable)

func emit_show_dialog(dialog: String):
	show_dialog.emit(dialog)
