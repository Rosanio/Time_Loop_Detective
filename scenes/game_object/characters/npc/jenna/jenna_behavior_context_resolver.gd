extends BehaviorContextResolver


func run_initial_behavior():
	load_schedule("schedule")


func handle_missing_key(door: Door):
	if door.id == "jenna_door":
		GameEvents.emit_show_speech_bubble(npc, "Where's my key?")
		await get_tree().create_timer(3).timeout
		seek_player("missing_house_key")
