extends Node
class_name DialogContextResolver

@export_file("*.json") var dialog_json_path: String

@onready var dialog_manager: DialogManager = $"../../DialogManager"

# Should be overridden by inheriting class
func GetDialogForCurrentContext():
	pass
