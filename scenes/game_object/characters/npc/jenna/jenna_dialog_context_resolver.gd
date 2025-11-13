extends DialogContextResolver

func get_dialog_for_current_context():
	if npc.current_schedule_key == "missing_key":
		if npc.behavior_context.thinks_player_has_key:
			load_dialog_from_json("resent_player_for_having_key")
		else:
			load_dialog_from_json("ask_for_help_finding_key")
	elif npc.current_schedule_key == "schedule":
		var current_time = WorldTimeManager.get_current_time()
		if current_time.is_in_range(TimeData.new(10, 1, "AM"), TimeData.new(2, 3, "PM")):
			load_dialog_from_json("inside_house")
		else:
			load_dialog_from_json("chilling")
