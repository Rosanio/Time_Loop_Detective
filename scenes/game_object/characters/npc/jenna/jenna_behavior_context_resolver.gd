extends BehaviorContextResolver


func run_initial_behavior():
	load_schedule("schedule")


func handle_missing_key(door: Door):
	if door.id == "jenna_door":
		await pause_and_show_speech_bubble("Where's my key?")
		npc.seek_entities(true, ["jenna_door_key"])
		var tracked_entity = await npc.tracked_entity_reached
		if tracked_entity is Player:
			npc.load_dialog("missing_house_key")
		else:
			npc.inventory.add_item(tracked_entity.item_component)
			await pause_and_show_speech_bubble("Here it is!")
			return_to_path_and_resume_schedule("schedule")


func check_player_for_door_key():
	var door_key_item_id = "jenna_door_key"
	if player.inventory.has_item(door_key_item_id):
		player.inventory.transfer_item_to(door_key_item_id, npc.inventory)
		await run_dialog_tree("player_does_have_key")
		return_to_path_and_resume_schedule("schedule")
	else:
		npc.load_dialog("player_does_not_have_key")


func get_help_from_henry(dialog: String):
	npc.move_to_npc("Henry")
	await run_dialog_tree(dialog)
	GameEvents.emit_show_speech_bubble(npc, "Henry! Help!")
	var last_player_position = player.global_position
	await npc.tracked_entity_reached
	(npc.tracked_entity as Npc).behavior_context.request_help_getting_back_key(last_player_position)
