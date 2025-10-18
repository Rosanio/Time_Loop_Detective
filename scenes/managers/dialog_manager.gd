extends Node
class_name DialogManager

var current_dialog: Array = []
var current_dialog_index: int = 0



func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		current_dialog_index += 1
		if current_dialog_index >= current_dialog.size():
			current_dialog = []
			current_dialog_index = 0
			GameEvents.emit_hide_dialog()
			# Briefly delay unpausing so that the interact input event doesn't trigger the dialog box to
			# re-open
			await get_tree().create_timer(0.01).timeout
			get_tree().paused = false
		else:
			process_current_dialog_branch()


func show_dialog(dialog: Array):
	current_dialog = dialog
	process_current_dialog_branch()
	get_tree().paused = true

func process_current_dialog_branch():
	var type = current_dialog[current_dialog_index]["type"]
	if type == 'basic':
		GameEvents.emit_show_dialog(current_dialog[current_dialog_index]["text"])
	elif type == 'prompt':
		GameEvents.emit_show_dialog_prompt(current_dialog[current_dialog_index])
	else:
		print("Not yet implemented")
