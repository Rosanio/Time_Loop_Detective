extends Node
class_name BehaviorContextResolver

@export var npc: Npc
@export_file("*.json") var schedule_json_path: String

@onready var player: Player = $"/root/Main/Player"

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
		npc.current_schedule = unformatted_schedule[schedule_key]


func return_to_path_and_resume_schedule(schedule_key: String):
	await npc.return_to_path()
	load_schedule(schedule_key)
	npc.resume_schedule()


func run_dialog_tree(dialog_key: String):
	npc.load_dialog(dialog_key)
	await GameEvents.hide_dialog


func pause_and_show_speech_bubble(text: String, duration: int = 3):
	GameEvents.emit_show_speech_bubble(npc, text, duration)
	await get_tree().create_timer(duration).timeout
