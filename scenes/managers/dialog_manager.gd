extends Node
class_name DialogManager


func show_dialog(dialog: String):
	GameEvents.emit_show_dialog(dialog)
