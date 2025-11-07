extends Node
class_name DialogManager

var current_dialog: Array = []
var current_dialog_index: int = 0
var current_dialog_context: DialogContextResolver


func _ready():
	GameEvents.dialog_prompt_chosen.connect(update_dialog)


func _process(_delta):
	if InputManager.current_context != InputManager.Context.DIALOG:
		return

	if Input.is_action_just_pressed("interact") and current_dialog and current_dialog[current_dialog_index]["type"] != "prompt":
		update_dialog()


func _unhandled_input(event: InputEvent):
	if InputManager.current_context != InputManager.Context.DIALOG:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if current_dialog and current_dialog[current_dialog_index]["type"] == "prompt":
			if event.keycode >= KEY_1 and event.keycode <= KEY_9:
				var prompt_index = event.keycode - KEY_1
				if prompt_index <  current_dialog[current_dialog_index]["options"].size():
					update_dialog(prompt_index)


func update_dialog(prompt_index: int = -1):
	current_dialog_index += 1
	if current_dialog_index >= current_dialog.size():
		current_dialog = []
		current_dialog_index = 0
		current_dialog_context = null
		GameEvents.emit_hide_dialog()
		# Briefly delay unpausing so that the interact input event doesn't trigger the dialog box to
		# re-open
		await get_tree().create_timer(0.01).timeout
		get_tree().paused = false
	else:
		process_current_dialog_branch(prompt_index)


func show_dialog(dialog: Array, dialog_context: DialogContextResolver):
	current_dialog = dialog
	current_dialog_context = dialog_context
	current_dialog_index = 0
	process_current_dialog_branch()
	get_tree().paused = true


func process_current_dialog_branch(prompt_index: int = -1):
	var type = current_dialog[current_dialog_index]["type"]
	if type == 'basic':
		GameEvents.emit_show_dialog_text(current_dialog[current_dialog_index]["text"])
	elif type == 'prompt':
		GameEvents.emit_show_dialog_prompt(current_dialog[current_dialog_index])
	elif type == "prompt-response":
		GameEvents.emit_show_dialog_text(current_dialog[current_dialog_index]["options"][prompt_index])
	elif type == "prompt-branch":
		current_dialog_context.load_dialog_from_json(current_dialog[current_dialog_index]["options"][prompt_index])
	elif type == "prompt-action":
		var method_name = current_dialog[current_dialog_index]["options"][prompt_index]["action"]
		if current_dialog_context.npc.has_method(method_name):
			var method = Callable(current_dialog_context.npc, method_name)
			method.callv(current_dialog[current_dialog_index]["options"][prompt_index]["args"])
		elif current_dialog_context.npc.behavior_context.has_method(method_name):
			var method = Callable(current_dialog_context.npc.behavior_context, method_name)
			method.callv(current_dialog[current_dialog_index]["options"][prompt_index]["args"])
		else:
			printerr("Method " + method_name + " could not be found on npc or behavior_context")
	else:
		print("Not yet implemented")
