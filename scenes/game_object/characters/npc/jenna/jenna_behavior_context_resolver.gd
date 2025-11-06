extends BehaviorContextResolver


func run_initial_behavior():
	load_schedule("schedule")


func handle_missing_key(door: Door):
	if door.id == "jenna_door":
		GameEvents.emit_show_speech_bubble(npc, "Where's my key?")
		await get_tree().create_timer(3).timeout
		seek_player("missing_house_key")


func check_player_for_door_key():
	var door_key_item_id = "jenna_door_key"
	if player.inventory.has_item(door_key_item_id):
		player.inventory.transfer_item_to(door_key_item_id, npc.inventory)
		npc.load_dialog("player_does_have_key")
	else:
		npc.load_dialog("player_does_not_have_key")
