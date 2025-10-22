extends DialogContextResolver

func GetDialogForCurrentContext():
	var file := FileAccess.open(dialog_json_path, FileAccess.READ)
	if file:
		var text := file.get_as_text()
		var dialog = JSON.parse_string(text)
		dialog_manager.show_dialog(dialog["dialog"])
