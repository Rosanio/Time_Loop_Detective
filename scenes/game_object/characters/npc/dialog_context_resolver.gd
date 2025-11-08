extends Node
class_name DialogContextResolver

@export_file("*.json") var dialog_json_path: String

@onready var dialog_manager: DialogManager = $"/root/Main/DialogManager"
@onready var npc: Npc = get_parent()

# Should be overridden by inheriting class
func get_dialog_for_current_context():
	pass


func load_dialog_from_json(key: String):
	var file := FileAccess.open(dialog_json_path, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		var dialog = JSON.parse_string(text)
		dialog_manager.show_dialog(dialog[key], self)
