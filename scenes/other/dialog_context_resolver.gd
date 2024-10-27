extends Node
class_name DialogContextResolver


@export var dialogManager: DialogManager


# Should be overridden by inheriting class
func GetDialogForCurrentContext():
	pass
