extends BehaviorContextResolver

func run_initial_behavior():
	load_schedule("schedule")


func request_help_getting_back_key(last_known_player_position: Vector2):
	npc.pathfinding_mode = Npc.PathfindingMode.NAVMESH
	npc.nav_agent.target_position = last_known_player_position
	npc.seek_entities(true)
	await npc.tracked_entity_reached
	npc.load_dialog("get_back_jenna_key")


func player_returns_jenna_key():
	return_key_to_jenna()
	await run_dialog_tree("jenna_key_returned")
	return_to_path_and_resume_schedule("schedule")


func check_player_for_jenna_door_key():
	await run_dialog_tree("check_player_for_jenna_door_key")
	if player.inventory.has_item("jenna_door_key"):
		return_key_to_jenna()
		await run_dialog_tree("found_jenna_key_on_player")
		return_to_path_and_resume_schedule("schedule")
	else:
		await run_dialog_tree("did_not_find_jenna_key")
		return_to_path_and_resume_schedule("schedule")
		get_other_npc("Jenna").behavior_context.didnt_get_key_back(true)


func return_key_to_jenna():
	var jenna = get_other_npc("Jenna")
	player.inventory.transfer_item_to("jenna_door_key", jenna.inventory)
	jenna.behavior_context.return_to_path_and_resume_schedule("schedule")
