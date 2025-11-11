extends DialogContextResolver

func get_dialog_for_current_context():
	var current_time = WorldTimeManager.get_current_time()
	if current_time.is_in_range(TimeData.new(10, 1, "AM"), TimeData.new(2, 3, "PM")):
		load_dialog_from_json("inside_house")
	else:
		load_dialog_from_json("chilling")
