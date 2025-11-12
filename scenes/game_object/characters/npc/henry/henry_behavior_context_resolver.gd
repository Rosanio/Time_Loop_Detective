extends BehaviorContextResolver

func run_initial_behavior():
	load_schedule("schedule")


func request_help_getting_back_key(last_known_player_position: Vector2):
	npc.pathfinding_mode = Npc.PathfindingMode.NAVMESH
	npc.nav_agent.target_position = last_known_player_position
	npc.seek_entities(true)
	await npc.tracked_entity_reached
	npc.load_dialog("get_back_jenna_key")


func return_key_to_jenna():
	var npcs = npc_container.get_children()
	for other_npc in npcs:
		if other_npc.npc_name == "Jenna":
			player.inventory.transfer_item_to("jenna_door_key", other_npc.inventory)
			other_npc.behavior_context.return_to_path_and_resume_schedule("schedule")
			break
	await run_dialog_tree("jenna_key_returned")
	return_to_path_and_resume_schedule("schedule")


func check_player_for_jenna_door_key():
	await run_dialog_tree("check_player_for_jenna_door_key")
