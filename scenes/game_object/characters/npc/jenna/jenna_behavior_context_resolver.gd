extends BehaviorContextResolver


func run_initial_behavior():
	load_schedule("schedule")


func handle_missing_key(door: Door):
	if door.id == "jenna_door":
		GameEvents.emit_show_speech_bubble(npc, "Where's my key?")
		await get_tree().create_timer(3).timeout
		npc.desired_item_ids.append("jenna_door_key")
		seek_player("missing_house_key")


func handle_item_found(item: Item):
	if item.item_data.id == "jenna_door_key":
		npc.inventory.add_item(item)
		GameEvents.emit_show_speech_bubble(npc, "Here it is!")
		await get_tree().create_timer(3).timeout
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
	npc.track_npc("Henry")
	npc.load_dialog(dialog)
	await GameEvents.hide_dialog
	GameEvents.emit_show_speech_bubble(npc, "Henry! Help!")
