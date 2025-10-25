extends DialogContextResolver

func get_dialog_for_current_context():
	var current_time = WorldTimeManager.get_current_time()
	if current_time.is_in_range(TimeData.new(10, 0, "PM"), TimeData.new(5, 0, "AM")):
		load_dialog_from_json("nighttime")
	else:
		load_dialog_from_json("dialog")
