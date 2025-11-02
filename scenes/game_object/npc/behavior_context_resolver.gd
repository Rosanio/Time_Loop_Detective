extends Node
class_name BehaviorContextResolver

@export var npc: Npc
@export_file("*.json") var schedule_json_path: String

# Should be overridden by inheriting class
func run_initial_behavior():
	pass


func handle_missing_key(_door: Door):
	pass


func load_schedule(schedule_key: String):
	var file := FileAccess.open(schedule_json_path, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		var unformatted_schedule: Dictionary = JSON.parse_string(text)
		for event in unformatted_schedule[schedule_key]:
			var x = event["coords"][0]
			var y = event["coords"][1]
			event["coords"] = Vector2i(x, y)
		npc.set_current_schedule(unformatted_schedule[schedule_key])
