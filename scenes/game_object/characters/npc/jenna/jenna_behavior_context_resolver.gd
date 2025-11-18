extends BehaviorContextResolver

var thinks_player_has_key = false

func run_initial_behavior():
	load_schedule("schedule")


func handle_missing_key(door: Door):
	if door.id == "jenna_door":
		await pause_and_show_speech_bubble("Where's my key?")
		npc.seek_entities(true, ["jenna_door_key"])
		var found_sought_entity = await npc.search_area(npc.global_position, 200, 100, 30)
		if found_sought_entity:
			var tracked_entity = await tracked_entity_reached()
			if tracked_entity == null: return
			elif tracked_entity is Player:
				npc.load_dialog("missing_house_key")
			else:
				npc.inventory.add_item(tracked_entity)
				npc.stop_tracking(player)
				await pause_and_show_speech_bubble("Here it is!")
				return_to_path_and_resume_schedule("schedule")
		else:
			return_to_path_and_resume_schedule("missing_key")
			var tracked_entity = await tracked_entity_reached()
			if tracked_entity == null: return
			elif tracked_entity is Player:
				npc.load_dialog("missing_house_key")


func sought_item_dropped_in_vision(item: Item):
	if item.item_data.id == "jenna_door_key":
		npc.override_tracked_entity(item)
		var tracked_entity = await tracked_entity_reached()
		if tracked_entity == null: return
		npc.inventory.add_item(tracked_entity)
		npc.override_tracked_entity(player)
		tracked_entity = await tracked_entity_reached()
		if tracked_entity == null: return
		await run_dialog_tree("saw_player_drop_key")
		return_to_path_and_resume_schedule("schedule")


func sought_item_picked_up_in_vision(item: Item):
	if item.item_data.id == "jenna_door_key":
		npc.override_tracked_entity(player)
		var tracked_entity = await tracked_entity_reached()
		if tracked_entity == null: return
		npc.load_dialog("saw_player_pick_up_key")


func check_player_for_door_key():
	var door_key_item_id = "jenna_door_key"
	if player_has_item(door_key_item_id):
		player.inventory.transfer_item_to(door_key_item_id, npc.inventory)
		await run_dialog_tree("player_does_have_key")
		return_to_path_and_resume_schedule("schedule")
	else:
		await run_dialog_tree("player_does_not_have_key")
		didnt_get_key_back(false)


func get_help_from_henry(dialog: String):
	await run_dialog_tree(dialog)
	npc.move_to_npc("Henry")
	GameEvents.emit_show_speech_bubble(npc, "Henry! Help!")
	var last_player_position = player.global_position
	var tracked_entity = await tracked_entity_reached()
	if tracked_entity == null: return
	(tracked_entity as Npc).behavior_context.request_help_getting_back_key(last_player_position)


func didnt_get_key_back(blames_player: bool):
	thinks_player_has_key = blames_player
	return_to_path_and_resume_schedule("missing_key")


func player_gives_back_key():
	var door_key_item_id = "jenna_door_key"
	if player_has_item(door_key_item_id):
		player.inventory.transfer_item_to(door_key_item_id, npc.inventory)
	await run_dialog_tree("player_gave_back_key")
	return_to_path_and_resume_schedule("schedule")


func player_gives_back_key_after_pick_up():
	var door_key_item_id = "jenna_door_key"
	if player_has_item(door_key_item_id):
		player.inventory.transfer_item_to(door_key_item_id, npc.inventory)
	await run_dialog_tree("player_gave_back_key_after_pick_up")
	return_to_path_and_resume_schedule("schedule")
