extends Node
class_name DialogManager


func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		GameEvents.emit_hide_dialog()
		# Briefly delay unpausing so that the interact input event doesn't trigger the dialog box to
		# re-open
		await get_tree().create_timer(0.01).timeout
		get_tree().paused = false


func show_dialog(dialog: String):
	print(get_tree().paused)
	GameEvents.emit_show_dialog(dialog)
	get_tree().paused = true
