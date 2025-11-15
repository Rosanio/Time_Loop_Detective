extends Node
class_name DialogManager

var current_dialog_tree: Array = []
var current_dialog_index: int = 0
var current_dialog_context: DialogContextResolver
var speaker: String

@onready var dialog_box := $/root/Main/ActiveUILayer/DialogBoxUI


func _ready():
	GameEvents.dialog_prompt_chosen.connect(update_dialog)


func _process(_delta):
	if InputManager.current_context != InputManager.Context.DIALOG:
		return

	if Input.is_action_just_pressed("interact") and current_dialog_tree and not is_prompt_with_options():
		update_dialog()


func _unhandled_input(event: InputEvent):
	if InputManager.current_context != InputManager.Context.DIALOG:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if current_dialog_tree and is_prompt_with_options():
			if event.keycode >= KEY_1 and event.keycode <= KEY_9:
				var prompt_index = event.keycode - KEY_1
				if prompt_index <  current_dialog_tree[current_dialog_index]["options"].size():
					update_dialog(prompt_index)


func update_dialog(prompt_index: int = -1):
	current_dialog_index += 1
	if current_dialog_index >= current_dialog_tree.size():
		current_dialog_tree = []
		current_dialog_index = 0
		current_dialog_context = null
		# Briefly delay unpausing so that the interact input event doesn't trigger the dialog box to
		# re-open
		await get_tree().process_frame
		get_tree().paused = false
		GameEvents.emit_hide_dialog()
	else:
		process_current_dialog_branch(prompt_index)


func show_dialog(dialog: Array, dialog_context: DialogContextResolver):
	current_dialog_tree = dialog
	current_dialog_context = dialog_context
	current_dialog_index = 0
	process_current_dialog_branch()
	get_tree().paused = true


func process_current_dialog_branch(prompt_index: int = -1):
	var current_dialog = current_dialog_tree[current_dialog_index]
	var type = current_dialog["type"]
	if type == 'basic':
		dialog_box.show_dialog_text(current_dialog["text"], speaker)
	elif type == 'prompt':
		remove_invalid_prompt_options()
		dialog_box.show_dialog_prompt(current_dialog, speaker)
	elif type == "prompt-response":
		dialog_box.show_dialog_text(current_dialog["options"][prompt_index], speaker)
	elif type == "prompt-branch":
		current_dialog_context.load_dialog_from_json(current_dialog["options"][prompt_index])
	elif type == "prompt-action":
		if current_dialog["options"].size() == 0:
			update_dialog()
			return
		var method_name = current_dialog["options"][prompt_index]["action"]
		call_method(method_name, current_dialog["options"][prompt_index]["args"])
	elif type == "narration":
		dialog_box.show_dialog_text(current_dialog["text"], "")
	else:
		printerr("Not yet implemented")


func call_method(method_name: String, args: Array):
	if current_dialog_context.npc.has_method(method_name):
		var method = Callable(current_dialog_context.npc, method_name)
		return await method.callv(args)
	elif current_dialog_context.npc.behavior_context.has_method(method_name):
		var method = Callable(current_dialog_context.npc.behavior_context, method_name)
		return await method.callv(args)
	else:
		printerr("Method " + method_name + " could not be found on npc or behavior_context")
		return null


func remove_invalid_prompt_options():
	var options = current_dialog_tree[current_dialog_index]["options"]
	var invalid_indicies = []
	for i in range(options.size()):
		if options[i].has("condition"):
			if not await call_method(options[i]["condition"]["method"], options[i]["condition"]["args"]):
				invalid_indicies.append(i)
	for index in invalid_indicies:
		current_dialog_tree[current_dialog_index]["options"].remove_at(index)
		current_dialog_tree[current_dialog_index + 1]["options"].remove_at(index)


func is_prompt_with_options():
	return current_dialog_tree[current_dialog_index]["type"] == "prompt" and current_dialog_tree[current_dialog_index]["options"].size() > 0
