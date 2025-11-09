extends BehaviorContextResolver

func run_initial_behavior():
	load_schedule("schedule")


func request_help_getting_back_key(last_known_player_position: Vector2):
	npc.pathfinding_mode = Npc.PathfindingMode.NAVMESH
	npc.nav_agent.target_position = last_known_player_position
	npc.seek_entities(true)
	await npc.tracked_entity_reached
	npc.load_dialog("get_back_jenna_key")
