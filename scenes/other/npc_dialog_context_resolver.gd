extends DialogContextResolver

func GetDialogForCurrentContext():
	var file := FileAccess.open("res://scenes/game_object/npc/npc_dialog.json", FileAccess.READ)
	if file:
		var text := file.get_as_text()
		var dialog = JSON.parse_string(text)
		dialogManager.show_dialog(dialog["dialog"])
